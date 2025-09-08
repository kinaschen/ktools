#!/usr/bin/env bash
set -e

GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

echo -e "${GREEN}🚀 开始一键安装 Mac 开发环境 (zsh / Node.js / Python / Plugins)${RESET}"

# ------------------------------
# 1️⃣ 安装 zsh
# ------------------------------
if ! command -v zsh >/dev/null 2>&1; then
  echo -e "${YELLOW}🔧 未检测到 zsh，正在安装...${RESET}"
  brew install zsh
else
  echo -e "${GREEN}✅ 已安装 zsh${RESET}"
fi

# ------------------------------
# 2️⃣ 安装 oh-my-zsh
# ------------------------------
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo -e "${YELLOW}🔧 安装 oh-my-zsh ...${RESET}"
  RUNZSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo -e "${GREEN}✅ 已安装 oh-my-zsh${RESET}"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# ------------------------------
# 3️⃣ 安装插件
# ------------------------------
declare -a plugins=(
  zsh-autosuggestions
  zsh-syntax-highlighting
  extract
)

for plugin in "${plugins[@]}"; do
  if [[ ! -d "${ZSH_CUSTOM}/plugins/$plugin" ]]; then
    echo -e "${YELLOW}🔧 安装插件: $plugin${RESET}"
    git clone https://github.com/zsh-users/$plugin ${ZSH_CUSTOM}/plugins/$plugin || true
  else
    echo -e "${GREEN}✅ 插件已存在: $plugin${RESET}"
  fi
done

# ------------------------------
# 4️⃣ 安装 powerlevel10k
# ------------------------------
if [[ ! -d "${ZSH_CUSTOM}/themes/powerlevel10k" ]]; then
  echo -e "${YELLOW}🔧 安装 powerlevel10k ...${RESET}"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM}/themes/powerlevel10k
else
  echo -e "${GREEN}✅ 已安装 powerlevel10k${RESET}"
fi

# ------------------------------
# 5️⃣ 安装 Python3
# ------------------------------
if ! command -v python3 >/dev/null 2>&1; then
  echo -e "${YELLOW}🔧 安装 Python3 ...${RESET}"
  brew install python
else
  echo -e "${GREEN}✅ 已安装 Python3${RESET}"
fi

# ------------------------------
# 6️⃣ 安装 nvm（Node Version Manager）
# ------------------------------
if [[ ! -d "$HOME/.nvm" ]]; then
  echo -e "${YELLOW}🔧 安装 nvm ...${RESET}"
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.6/install.sh | bash
else
  echo -e "${GREEN}✅ 已安装 nvm${RESET}"
fi

# 加载 nvm 环境
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# 安装最新 LTS Node.js
echo -e "${YELLOW}🔧 安装最新 LTS Node.js ...${RESET}"
nvm install --lts
nvm use --lts
nvm alias default 'lts/*'
echo -e "${GREEN}✅ Node.js 已安装: $(node -v)${RESET}"
echo -e "${GREEN}✅ npm 已安装: $(npm -v)${RESET}"

# ------------------------------
# 7️⃣ 提示安装 MesloLGS NF Nerd Font
# ------------------------------
echo -e "${YELLOW}⚠️ 请手动安装 MesloLGS NF Nerd Font，以确保 powerlevel10k 显示图标${RESET}"
echo "下载地址：https://github.com/ryanoasis/nerd-fonts/releases"
echo "安装完成后在 iTerm2 和 VSCode 设置字体为 'MesloLGS NF'"

# ------------------------------
# 8️⃣ 配置 ~/.zshrc
# ------------------------------
ZSHRC="$HOME/.zshrc"
if [[ -f "$ZSHRC" ]]; then
  cp "$ZSHRC" "$ZSHRC.backup.$(date +%s)"
fi

cat > "$ZSHRC" <<'EOF'
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export TERM="xterm-256color"

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  extract
  npm
  node
  nvm
  fzf
)

source $ZSH/oh-my-zsh.sh
# syntax-highlighting 必须最后加载
source $ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Node.js / npm / uv / Python
export PATH=$HOME/.npm-global/bin:$PATH
export PATH=$HOME/.cargo/bin:$PATH
alias python="python3"
alias uvpip="uv pip"

# 常用别名
alias cls="clear"
alias ll="ls -alF"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"

# zsh-syntax-highlighting 配色
ZSH_HIGHLIGHT_STYLES[command]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[function]='fg=magenta'
ZSH_HIGHLIGHT_STYLES[comment]='fg=blue'
ZSH_HIGHLIGHT_STYLES[valid_path]='fg=white'

# 启动时进入 home
cd ~
EOF

echo -e "${GREEN}✅ zsh 配置完成 (~/.zshrc)${RESET}"

# ------------------------------
# 9️⃣ 设置默认 shell
# ------------------------------
if [[ "$SHELL" != *"zsh" ]]; then
  echo -e "${YELLOW}🔧 设置默认 shell 为 zsh${RESET}"
  chsh -s "$(which zsh)"
fi

# ------------------------------
# 完成
# ------------------------------
echo -e "${GREEN}🎉 安装完成！执行: exec zsh${RESET}"
echo -e "${YELLOW}💡 首次进入会触发 powerlevel10k 配置向导，建议选择简约风格${RESET}"
echo -e "${YELLOW}💡 VSCode / iTerm2 Terminal 记得设置字体为 'MesloLGS NF'${RESET}"

