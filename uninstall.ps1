$ErrorActionPreference = "Stop"

$InstallDir = Join-Path $env:LOCALAPPDATA "Programs\WeeklyTodoWidget"
function New-UnicodeText([int[]]$Codes) {
  return -join ($Codes | ForEach-Object { [char]$_ })
}

$ShortcutName = (New-UnicodeText @(0x6BCF, 0x5468, 0x4EFB, 0x52A1, 0x4EE3, 0x529E, 0x002D, 0x900F, 0x660E, 0x5C0F, 0x7EC4, 0x4EF6)) + ".lnk"
$ShortcutPath = Join-Path ([Environment]::GetFolderPath("Desktop")) $ShortcutName

Write-Host "Uninstalling weekly todo transparent desktop widget..." -ForegroundColor Cyan

Get-CimInstance Win32_Process -Filter "Name = 'electron.exe'" |
  Where-Object { $_.CommandLine -like "*$InstallDir*" } |
  ForEach-Object {
    Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
  }

if (Test-Path -LiteralPath $ShortcutPath) {
  Remove-Item -LiteralPath $ShortcutPath -Force
}

if (Test-Path -LiteralPath $InstallDir) {
  Remove-Item -LiteralPath $InstallDir -Recurse -Force
}

Write-Host "Uninstall complete." -ForegroundColor Green
Write-Host "Note: local Electron app data may still remain under your AppData profile."
