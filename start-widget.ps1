$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$widgetDir = Join-Path $root "weekly-widget"

if (-not (Test-Path (Join-Path $widgetDir "node_modules"))) {
  Write-Host "Installing dependencies..."
  npm install --prefix $widgetDir
}

npm start --prefix $widgetDir
