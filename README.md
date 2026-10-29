# ChromeOS KDE

ChromeOS 风格的 KDE Plasma 主题，基于 Materia 设计。

包含内容：

- Aurorae 窗口装饰（ChromeOS / ChromeOS-dark / ChromeOS-light）
- Kvantum 控件样式
- Plasma 配色方案
- Plasma 桌面主题
- Plasma 全局主题（Look-and-Feel）
- SDDM 登录主题（5.0 / 6.0）
- 壁纸与面板布局模板

## 支持的桌面环境

- Debian 13 (trixie) + KDE Plasma 6.3
- 理论上兼容 Plasma 6.x 各版本、arm64 / amd64

## 依赖（重要）

主题本身只负责外观资源，**以下三项必须自行安装**，否则会出现图标空白、控件样式错乱等显示异常：

| 依赖 | 作用 | 安装方式 |
|------|------|----------|
| Kvantum 样式引擎 | 系统设置、Dolphin 等 Qt 应用的控件样式 | `sudo apt install qt6-style-kvantum` |
| Tela 图标主题 | 任务栏、系统设置的全部图标 | `git clone https://github.com/vinceliuice/Tela-icon-theme && cd Tela-icon-theme && ./install.sh -a` |
| Vimix 光标主题 | 鼠标指针 | `git clone https://github.com/vinceliuice/Vimix-cursors && cd Vimix-cursors && ./install.sh` |

`install.sh` 会在安装后自动检查上述依赖，缺失时给出提示。

## 安装

为当前用户安装：

```sh
./install.sh
```

为所有用户安装：

```sh
sudo ./install.sh
```

安装完成后应用全局主题：

```sh
# 深色（默认）
plasma-apply-lookandfeel -a com.github.vinceliuice.ChromeOS

# 深色变体
plasma-apply-lookandfeel -a com.github.vinceliuice.ChromeOS-dark

# 浅色（白色任务栏）
plasma-apply-lookandfeel -a com.github.vinceliuice.ChromeOS-light
```

`install.sh` 会自动把 Kvantum 当前生效主题写入 `~/.config/Kvantum/kvantum.kvconfig`，因为
look-and-feel 中的 `widgetStyle=kvantum` 只负责选择引擎，真正生效的主题由该文件决定。

安装 SDDM 登录主题（可选）：

```sh
cd sddm/6.0 && sudo ./install.sh   # Plasma 6
cd sddm/5.0 && sudo ./install.sh   # Plasma 5
```

## Plasma 6 兼容性修复

原始主题针对 Plasma 5 编写，在 Plasma 6 上会出现显示异常。本项目已包含以下修复：

**桌面主题**

- 补全 Plasma 6 新增的 10 个 widget SVG：`analog_meter`、`branding`、`dragger`、`frame`、
  `margins-highlight`、`media-delegate`、`monitor`、`picker`、`radiobutton`、`timer`
- `widgets/`、`icons/`、`opaque|solid|translucent/widgets/` 下所有 `.svg` 全部转换为
  `.svgz`，因为 Plasma 6 只加载 gzip 压缩的 SVGZ

**窗口装饰**

- 移除 `aurorae/*/decoration.svg` 中 3 处指向不存在分组（`g917`、`g949`、`g969`）的
  `<use>` 引用，消除 kwin 的 `qt.svg: link ... is undefined` 报错与边角渲染残缺

**全局主题**

- `widgetStyle` 统一为 `kvantum`（`qt6-style-kvantum` 只提供该样式键，`kvantum-dark` 不存在）
- 浅色变体图标由 `Tela-circle` 改为 `Tela-light`（Tela 自带，避免额外依赖）

**面板**

- 布局模板 `panel.height` 固定为 48px。Plasma 6 面板厚度只接受偶数，且 ChromeOS 面板背景
  按 56px 设计；未设置时默认约 20px，会导致任务栏过矮、图标被挤压

**SDDM**

- 移除 6.0 主题中未使用的 `org.kde.plasma.plasma5support` import

## 排查显示异常

如果任务栏或系统设置仍有异常，按顺序检查：

```sh
# 1. 图标主题是否生效
kreadconfig6 --file kdeglobals --group Icons --key Theme        # 期望 Tela / Tela-dark
# 2. 控件样式是否生效
kreadconfig6 --file kdeglobals --group KDE --key widgetStyle    # 期望 kvantum
# 3. Kvantum 当前主题
cat ~/.config/Kvantum/kvantum.kvconfig                          # 期望 theme=ChromeOS
# 4. 面板厚度
kreadconfig6 --file plasma-org.kde.plasma.desktop-appletsrc \
             --group Containments --group 156 --key thickness   # 期望 48
# 5. 窗口装饰
kreadconfig6 --file kwinrc --group org.kde.kdecoration2 --key theme
```

修改后重启相关服务：

```sh
systemctl --user restart plasma-plasmashell.service
systemctl --user restart plasma-kwin_x11.service
```

> 注意：不要用 `plasmashell &` 在临时 shell 中启动，shell 退出会连带结束进程，表现为桌面黑屏、
> 任务栏消失。请使用 `systemctl --user restart plasma-plasmashell.service`。

## 卸载

为所有用户安装时：

```sh
sudo ./uninstall.sh
```

当前用户：

```sh
./uninstall.sh
```

## 预览

![preview](../master/plasma/look-and-feel/com.github.vinceliuice.ChromeOS/contents/previews/fullscreenpreview.jpg)

## License

GNU GPL v3
