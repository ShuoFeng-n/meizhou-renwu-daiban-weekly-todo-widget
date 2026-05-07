# 每周任务代办透明桌面小组件

一个用 HTML + Electron 做出来的 Windows 透明桌面待办小组件。它起源于一次 vibecoding：从“我想把每周任务放到桌面上”开始，一步步做成了可拖动、可编辑、可勾选的透明桌面挂件。

![预览](assets/preview.png)

## 功能

- 透明无边框桌面窗口，更像桌面组件而不是普通网页。
- 周一到周日一屏展示，适合每周计划。
- 添加任务、勾选完成、删除任务。
- 点击铅笔或双击任务文字即可行内编辑。
- 编辑内容默认自动保存。
- 同一天内拖动任务，可以交换顺序。
- 一键导出文本。
- 清除已完成、清空本周。
- 支持置顶、最小化、关闭窗口。
- 数据保存在本机浏览器/Electron 本地存储里，不需要账号。

## 适合谁

适合想把轻量计划直接放在桌面上的人：

- 每周任务计划
- 学习/工作待办
- 桌面备忘
- vibecoding 小作品展示

## 环境要求

- Windows 10 或 Windows 11
- Node.js 18 或更高版本
- npm
- Git（如果你要从 GitHub 克隆）

查看是否已安装：

```powershell
node --version
npm --version
git --version
```

## 安装

克隆仓库：

```powershell
git clone https://github.com/ShuoFeng-n/weekly-todo-widget.git
cd weekly-todo-widget
```

安装依赖：

```powershell
cd weekly-widget
npm install
```

## 运行

在 `weekly-widget` 目录运行：

```powershell
npm start
```

也可以在项目根目录运行：

```powershell
.\start-widget.ps1
```

第一次运行时，如果还没有安装依赖，脚本会自动执行 `npm install`。

## 创建桌面快捷方式

在项目根目录运行：

```powershell
.\install-desktop-shortcut.ps1
```

脚本会在桌面创建：

```text
每周任务代办-透明小组件.lnk
```

以后双击这个快捷方式就能打开透明小组件。

## 使用方法

### 添加任务

在顶部输入框输入任务，选择星期，然后点击“添加”。

### 完成任务

点击任务左侧的复选框。

### 修改任务

有两种方式：

- 点击任务右侧的铅笔按钮。
- 双击任务文字。

任务会变成输入框。你修改时会自动保存，按 `Enter` 或点击别处会退出编辑状态。

### 调整顺序

同一天内，按住一个任务拖到另一个任务上松开，就会交换两个任务的位置。

### 导出任务

点击顶部“导出”，当前每周任务会复制到剪贴板，格式类似：

```text
周一
[ ] 规划本周重点
[x] 处理上周遗留事项
```

### 清理任务

- “清除完成”：只删除已经勾选完成的任务。
- “清空”：清空本周全部任务，会先弹出确认。

## 数据保存在哪里

任务保存在本机的 `localStorage` 中。

这意味着：

- 不需要注册账号。
- 不会自动上传到云端。
- 换浏览器/换电脑不会自动同步。
- 清理 Electron 或浏览器应用数据时，任务可能被清除。

## 项目结构

```text
.
├─ weekly-todo.html              # 小组件页面和交互逻辑
├─ weekly-widget/
│  ├─ main.js                    # Electron 透明窗口
│  ├─ preload.js                 # 页面和 Electron 的安全桥接
│  ├─ package.json               # Electron 依赖和启动脚本
│  └─ package-lock.json
├─ start-widget.ps1              # 从项目根目录启动小组件
├─ install-desktop-shortcut.ps1   # 创建桌面快捷方式
├─ README.md
└─ LICENSE
```

## 开发

修改 `weekly-todo.html` 后，重新运行：

```powershell
npm start --prefix weekly-widget
```

如果窗口已经打开，关闭后再启动即可看到新效果。

Electron 默认优先加载桌面上的 `每周任务代办.html`，如果找不到，就加载项目里的 `weekly-todo.html`。

## 常见问题

### 为什么不是普通网页？

普通浏览器窗口无法真正做到透明桌面组件效果。这个项目用 Electron 创建透明、无边框窗口，再加载 HTML 页面，所以看起来更像桌面挂件。

### 为什么没有账号同步？

这个项目刻意保持轻量。它更像桌面便利贴，而不是完整任务管理软件。

### 可以打包成 exe 吗？

可以。后续可以加入 `electron-builder` 或 `electron-forge`，把它打包成可安装的 Windows 应用。

## 后续可以做什么

- 打包成 `.exe`
- 增加开机自启
- 增加窗口位置记忆
- 增加主题颜色
- 支持按周归档
- 支持备份/导入 JSON

## License

MIT
