$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$widgetDir = Join-Path $root "weekly-widget"
$electron = Join-Path $widgetDir "node_modules\electron\dist\electron.exe"

if (-not (Test-Path $electron)) {
  Write-Host "Installing dependencies..."
  npm install --prefix $widgetDir
}

$desktop = [Environment]::GetFolderPath("Desktop")
$linkPath = Join-Path $desktop "每周任务代办-透明小组件.lnk"
$wsh = New-Object -ComObject WScript.Shell
$link = $wsh.CreateShortcut($linkPath)
$link.TargetPath = $electron
$link.Arguments = "`"$widgetDir`""
$link.WorkingDirectory = $widgetDir
$link.IconLocation = "$electron,0"
$link.Description = "打开透明桌面小组件版每周任务代办"
$link.Save()

Write-Host "Shortcut created: $linkPath"
