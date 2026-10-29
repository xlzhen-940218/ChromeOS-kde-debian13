#!/bin/bash

SRC_DIR=$(cd $(dirname $0) && pwd)
ROOT_UID=0

# Destination directory
if [ "$UID" -eq "$ROOT_UID" ]; then
  AURORAE_DIR="/usr/share/aurorae/themes"
  SCHEMES_DIR="/usr/share/color-schemes"
  PLASMA_DIR="/usr/share/plasma/desktoptheme"
  LAYOUT_DIR="/usr/share/plasma/layout-templates"
  LOOKFEEL_DIR="/usr/share/plasma/look-and-feel"
  KVANTUM_DIR="/usr/share/Kvantum"
  WALLPAPER_DIR="/usr/share/wallpapers"
else
  AURORAE_DIR="$HOME/.local/share/aurorae/themes"
  SCHEMES_DIR="$HOME/.local/share/color-schemes"
  PLASMA_DIR="$HOME/.local/share/plasma/desktoptheme"
  LAYOUT_DIR="$HOME/.local/share/plasma/layout-templates"
  LOOKFEEL_DIR="$HOME/.local/share/plasma/look-and-feel"
  KVANTUM_DIR="$HOME/.config/Kvantum"
  WALLPAPER_DIR="$HOME/.local/share/wallpapers"
fi

THEME_NAME=ChromeOS

[[ ! -d ${AURORAE_DIR} ]] && mkdir -p ${AURORAE_DIR}
[[ ! -d ${SCHEMES_DIR} ]] && mkdir -p ${SCHEMES_DIR}
[[ ! -d ${PLASMA_DIR} ]] && mkdir -p ${PLASMA_DIR}
[[ ! -d ${LOOKFEEL_DIR} ]] && mkdir -p ${LOOKFEEL_DIR}
[[ ! -d ${KVANTUM_DIR} ]] && mkdir -p ${KVANTUM_DIR}
[[ ! -d ${WALLPAPER_DIR} ]] && mkdir -p ${WALLPAPER_DIR}

install() {
  local name=${1}

  [[ -d ${AURORAE_DIR}/${name} ]] && rm -rf ${AURORAE_DIR}/${name}*
  [[ -d ${PLASMA_DIR}/${name} ]] && rm -rf ${PLASMA_DIR}/${name}*
  [[ -f ${SCHEMES_DIR}/${name}.colors ]] && rm -rf ${SCHEMES_DIR}/${name}*.colors
  [[ -d ${LOOKFEEL_DIR}/com.github.vinceliuice.${name} ]] && rm -rf ${LOOKFEEL_DIR}/com.github.vinceliuice.${name}*
  [[ -d ${KVANTUM_DIR}/${name} ]] && rm -rf ${KVANTUM_DIR}/${name}*
  [[ -d ${WALLPAPER_DIR}/${name} ]] && rm -rf ${WALLPAPER_DIR}/${name}

  cp -r ${SRC_DIR}/aurorae/*                                                         ${AURORAE_DIR}
  cp -r ${SRC_DIR}/color-schemes/*.colors                                            ${SCHEMES_DIR}
  cp -r ${SRC_DIR}/Kvantum/*                                                         ${KVANTUM_DIR}
  cp -r ${SRC_DIR}/plasma/desktoptheme/*                                             ${PLASMA_DIR}
  cp -r ${SRC_DIR}/plasma/layout-templates/*                                         ${LAYOUT_DIR}
  cp -r ${SRC_DIR}/color-schemes/${name}Dark.colors                                  ${PLASMA_DIR}/${name}/colors
  cp -r ${SRC_DIR}/color-schemes/${name}Light.colors                                 ${PLASMA_DIR}/${name}-light/colors
  cp -r ${SRC_DIR}/plasma/look-and-feel/*                                            ${LOOKFEEL_DIR}
  cp -r ${SRC_DIR}/wallpaper/*                                                       ${WALLPAPER_DIR}
}

echo "Installing '${THEME_NAME} kde themes'..."

install "${name:-${THEME_NAME}}"

# Kvantum 主题引擎通过 kvantum.kvconfig 决定当前生效的主题名，
# look-and-feel 的 widgetStyle=kvantum 只负责选择引擎，因此这里显式写入
if [ "$UID" -ne "$ROOT_UID" ]; then
  mkdir -p "$HOME/.config/Kvantum"
  cat > "$HOME/.config/Kvantum/kvantum.kvconfig" <<EOF
[General]
theme=${THEME_NAME}
EOF
fi

# 依赖检查：缺少图标主题或样式引擎会导致任务栏、系统设置显示异常
check_dependency() {
  local ok=1

  if ! command -v kvantummanager >/dev/null 2>&1 && [ ! -f /usr/lib/*/qt6/plugins/styles/libkvantum.so ]; then
    echo "  [缺失] Kvantum 样式引擎 - 系统设置等 Qt 应用将显示异常"
    echo "         Debian/Ubuntu: sudo apt install qt6-style-kvantum"
    ok=0
  fi

  if [ ! -d "$HOME/.local/share/icons/Tela" ] && [ ! -d /usr/share/icons/Tela ]; then
    echo "  [缺失] Tela 图标主题 - 任务栏与系统设置图标将为空白"
    echo "         https://github.com/vinceliuice/Tela-icon-theme"
    ok=0
  fi

  if [ ! -d "$HOME/.local/share/icons/Vimix-cursors" ] && [ ! -d /usr/share/icons/Vimix-cursors ]; then
    echo "  [缺失] Vimix 光标主题 - 鼠标指针显示异常"
    echo "         https://github.com/vinceliuice/Vimix-cursors"
    ok=0
  fi

  if [ "$ok" -eq 0 ]; then
    echo ""
    echo "提示: 以上依赖未安装，主题仍会安装，但界面可能出现图标空白或样式错乱。"
  fi
}

echo ""
echo "Checking dependencies..."
check_dependency

echo ""
echo "Install finished..."
echo "应用主题: plasma-apply-lookandfeel -a com.github.vinceliuice.${THEME_NAME}"
