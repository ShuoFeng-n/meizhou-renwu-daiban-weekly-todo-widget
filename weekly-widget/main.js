const { app, BrowserWindow, ipcMain, screen } = require("electron");
const fs = require("fs");
const os = require("os");
const path = require("path");

const desktopHtml = path.join(os.homedir(), "Desktop", "每周任务代办.html");
const fallbackHtml = path.join(__dirname, "..", "weekly-todo.html");

let widgetWindow;
let alwaysOnTop = false;

function createWidgetWindow() {
  const workArea = screen.getPrimaryDisplay().workArea;
  const width = 760;
  const height = 860;

  widgetWindow = new BrowserWindow({
    width,
    height,
    x: Math.max(workArea.x + 24, workArea.x + workArea.width - width - 48),
    y: workArea.y + 48,
    minWidth: 560,
    minHeight: 640,
    frame: false,
    transparent: true,
    backgroundColor: "#00000000",
    hasShadow: false,
    resizable: true,
    movable: true,
    show: false,
    title: "每周任务代办",
    webPreferences: {
      preload: path.join(__dirname, "preload.js"),
      contextIsolation: true,
      nodeIntegration: false,
      backgroundThrottling: false
    }
  });

  widgetWindow.setMenuBarVisibility(false);
  widgetWindow.loadFile(fs.existsSync(desktopHtml) ? desktopHtml : fallbackHtml);
  widgetWindow.once("ready-to-show", () => widgetWindow.show());
  widgetWindow.on("closed", () => {
    widgetWindow = null;
  });
}

app.whenReady().then(createWidgetWindow);

app.on("window-all-closed", () => {
  app.quit();
});

ipcMain.on("widget:minimize", () => {
  widgetWindow?.minimize();
});

ipcMain.on("widget:close", () => {
  widgetWindow?.close();
});

ipcMain.handle("widget:toggleAlwaysOnTop", () => {
  if (!widgetWindow) return false;
  alwaysOnTop = !alwaysOnTop;
  widgetWindow.setAlwaysOnTop(alwaysOnTop, "floating");
  return alwaysOnTop;
});
