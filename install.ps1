param(
  [string]$InstallDir = (Join-Path $env:LOCALAPPDATA "Programs\WeeklyTodoWidget"),
  [string]$ShortcutPath,
  [switch]$NoShortcut,
  [switch]$NoStart
)

$ErrorActionPreference = "Stop"

$Repo = "ShuoFeng-n/meizhou-renwu-daiban-weekly-todo-widget"
$Branch = "main"
$TempRoot = Join-Path ([System.IO.Path]::GetTempPath()) "weekly-todo-widget-install"
$ZipPath = Join-Path $TempRoot "source.zip"

function New-UnicodeText([int[]]$Codes) {
  return -join ($Codes | ForEach-Object { [char]$_ })
}

$ShortcutName = (New-UnicodeText @(0x6BCF, 0x5468, 0x4EFB, 0x52A1, 0x4EE3, 0x529E, 0x002D, 0x900F, 0x660E, 0x5C0F, 0x7EC4, 0x4EF6)) + ".lnk"
if (-not $ShortcutPath) {
  $ShortcutPath = Join-Path ([Environment]::GetFolderPath("Desktop")) $ShortcutName
}

function Write-Step([string]$Message) {
  Write-Host ""
  Write-Host "==> $Message" -ForegroundColor Cyan
}

function Test-Command([string]$Name) {
  return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Refresh-Path {
  $machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
  $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
  $env:Path = "$machinePath;$userPath"
}

function Ensure-Node {
  if ((Test-Command "node") -and (Test-Command "npm")) {
    return
  }

  Write-Step "Node.js not found. Trying to install Node.js LTS with winget"
  if (-not (Test-Command "winget")) {
    throw "Node.js is required, but neither node/npm nor winget was found. Please install Node.js LTS from https://nodejs.org/ and run this installer again."
  }

  winget install --id OpenJS.NodeJS.LTS -e --source winget --accept-package-agreements --accept-source-agreements
  Refresh-Path

  if (-not ((Test-Command "node") -and (Test-Command "npm"))) {
    throw "Node.js installation finished, but node/npm are still unavailable in this terminal. Please open a new PowerShell window and run the installer again."
  }
}

function Download-Source {
  Write-Step "Downloading latest source from GitHub"
  if (Test-Path -LiteralPath $TempRoot) {
    Remove-Item -LiteralPath $TempRoot -Recurse -Force
  }

  New-Item -ItemType Directory -Force -Path $TempRoot | Out-Null
  $url = "https://github.com/$Repo/archive/refs/heads/$Branch.zip"
  Invoke-WebRequest -Uri $url -OutFile $ZipPath

  Write-Step "Extracting source"
  Expand-Archive -LiteralPath $ZipPath -DestinationPath $TempRoot -Force
  $sourceDir = Get-ChildItem -LiteralPath $TempRoot -Directory | Where-Object { $_.Name -like "*$Branch*" } | Select-Object -First 1
  if (-not $sourceDir) {
    throw "Could not find extracted source directory."
  }

  if (Test-Path -LiteralPath $InstallDir) {
    Remove-Item -LiteralPath $InstallDir -Recurse -Force
  }

  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $InstallDir) | Out-Null
  Copy-Item -LiteralPath $sourceDir.FullName -Destination $InstallDir -Recurse -Force
}

function Install-Dependencies {
  Write-Step "Installing Electron dependencies"
  $widgetDir = Join-Path $InstallDir "weekly-widget"
  npm install --prefix $widgetDir
}

function Create-Shortcut {
  Write-Step "Creating desktop shortcut"
  $widgetDir = Join-Path $InstallDir "weekly-widget"
  $electron = Join-Path $widgetDir "node_modules\electron\dist\electron.exe"
  if (-not (Test-Path -LiteralPath $electron)) {
    throw "Electron executable not found: $electron"
  }

  $linkDir = Split-Path -Parent $ShortcutPath
  New-Item -ItemType Directory -Force -Path $linkDir | Out-Null
  $wsh = New-Object -ComObject WScript.Shell
  $link = $wsh.CreateShortcut($ShortcutPath)
  $link.TargetPath = $electron
  $link.Arguments = "`"$widgetDir`""
  $link.WorkingDirectory = $widgetDir
  $link.IconLocation = "$electron,0"
  $link.Description = "Open weekly todo transparent desktop widget"
  $link.Save()

  Write-Host "Shortcut: $ShortcutPath" -ForegroundColor Green
}

function Start-Widget {
  Write-Step "Starting widget"
  $widgetDir = Join-Path $InstallDir "weekly-widget"
  $electron = Join-Path $widgetDir "node_modules\electron\dist\electron.exe"
  Start-Process -FilePath $electron -ArgumentList "`"$widgetDir`"" -WorkingDirectory $widgetDir
}

try {
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  Write-Step "Installing weekly todo transparent desktop widget"
  Ensure-Node
  Download-Source
  Install-Dependencies
  if ($NoShortcut) {
    Write-Step "Skipping shortcut creation"
  } else {
    Create-Shortcut
  }
  if ($NoStart) {
    Write-Step "Skipping widget launch"
  } else {
    Start-Widget
  }

  Write-Host ""
  Write-Host "Install complete." -ForegroundColor Green
  Write-Host "Installed to: $InstallDir"
  if (-not $NoShortcut) {
    Write-Host "You can open it later from the shortcut: $ShortcutPath"
  }
}
finally {
  if (Test-Path -LiteralPath $TempRoot) {
    Remove-Item -LiteralPath $TempRoot -Recurse -Force -ErrorAction SilentlyContinue
  }
}
