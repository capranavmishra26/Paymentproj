# Installs "Fund & Payment Projection" as a desktop app (own window + icon) using Microsoft Edge / Google Chrome app mode.
# Creates shortcuts on the Desktop and in the Start Menu. Run with -Uninstall to remove them.
param([switch]$Uninstall)

$ErrorActionPreference = 'Stop'
$name     = 'Fund & Payment Projection'
$appDir   = $PSScriptRoot
$desktop  = [Environment]::GetFolderPath('Desktop')
$startDir = Join-Path ([Environment]::GetFolderPath('Programs')) $name
$links    = @((Join-Path $desktop "$name.lnk"), (Join-Path $startDir "$name.lnk"))

if ($Uninstall) {
    $links | Where-Object { Test-Path -LiteralPath $_ } | ForEach-Object { Remove-Item -LiteralPath $_ }
    if (Test-Path -LiteralPath $startDir) { Remove-Item -LiteralPath $startDir -Recurse }
    Write-Host "$name shortcuts removed. Your files in '$appDir' are untouched."
    return
}

$browsers = @(
    "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
    "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
    "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
    "$env:LocalAppData\Google\Chrome\Application\chrome.exe"
)
$browser = $browsers | Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Select-Object -First 1
if (-not $browser) { throw 'Microsoft Edge or Google Chrome is required but was not found.' }

$index = Join-Path $appDir 'index.html'
$icon  = Join-Path $appDir 'icons\app.ico'
if (-not (Test-Path -LiteralPath $index)) { throw "index.html not found in $appDir" }
$url = ([System.Uri]$index).AbsoluteUri

New-Item -ItemType Directory -Force -Path $startDir | Out-Null
$shell = New-Object -ComObject WScript.Shell
foreach ($lnk in $links) {
    $s = $shell.CreateShortcut($lnk)
    $s.TargetPath       = $browser
    $s.Arguments        = "--app=`"$url`""
    $s.WorkingDirectory = $appDir
    $s.IconLocation     = "$icon,0"
    $s.Description      = 'Day-wise fund & payment projection'
    $s.Save()
}
Write-Host "Installed '$name'."
Write-Host "  Desktop shortcut : $($links[0])"
Write-Host "  Start Menu       : $($links[1])"
Write-Host "Tip: right-click the Desktop icon > 'Pin to taskbar' to keep it on the taskbar."
