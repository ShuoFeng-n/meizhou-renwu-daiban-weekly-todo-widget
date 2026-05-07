const { contextBridge, ipcRenderer } = require("electron");

contextBridge.exposeInMainWorld("desktopWidget", {
  close: () => ipcRenderer.send("widget:close"),
  minimize: () => ipcRenderer.send("widget:minimize"),
  toggleAlwaysOnTop: () => ipcRenderer.invoke("widget:toggleAlwaysOnTop")
});
