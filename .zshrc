
setopt autocd
setopt extendedglob
setopt nomatch
setopt notify

autoload -Uz compinit


# .zcompdump is the cache file used by the completion system. [web:11][web:4]
if [[ ! -f ~/.zcompdump ]] || \
   [[ "$(date +'%j')" != "$(date -d "$(stat -c %y ~/.zcompdump 2>/dev/null)" +'%j' 2>/dev/null)" ]]; then
  compinit
else
  compinit -C
fi

export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$HOME/go/bin:/snap/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# fnm
FNM_PATH="$HOME/.local/share/fnm"
if [[ -d "$FNM_PATH" ]]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$(fnm env)"
fi

# Homebrew (only if installed)
if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Editor
export EDITOR=nvim
export VISUAL=nvim


# ALIASES

alias ls='ls --color=auto'
alias ll='ls -lah'
alias grep='grep --color=auto'
alias cls='clear'
alias cdd='cd ~'
alias v='nvim'

alias ga='git add'
alias gm='git commit -m'
alias gs='git status'
alias gll='git log --oneline'
alias gp='git push'

alias ff='fastfetch'
alias btop='btop --utf-force'
alias nf='neofetch'

alias pn='pnpm run dev'
alias bro='bun run dev'
alias uwu='uv run main.py'
alias dc='docker-compose up'

alias pp='pip3'
alias py='python3'
alias xx='xdg-open .'
alias sv='source ~/.zshrc'
alias vv='nvim ~/.zshrc'

# tmux helpers 
alias tmux='tmux -u'
alias tn='tmux new -s'
alias ts='tmux ls'
alias tk='tmux kill-server'
alias to='tmux a -t'
alias tkk='tmux kill-session -t'

# extra aliases you had
alias bat='batcat'
alias fn='fdfind'
alias mux='tmuxinator'
alias brb='bun run build'

# Neovim test profile
alias nvim-test='NVIM_APPNAME=nvim-test nvim'

# Never alias vim — function only
unalias vim 2>/dev/null
vim() { nvim "$@"; }

# Neovim config selector
qq() {
  local config
  config=$(fd --max-depth 1 --glob 'nvim-*' "$HOME/.config" \
    | fzf --prompt="Neovim Configs > " \
          --height=50% \
          --layout=reverse \
          --border \
          --exit-0)

  [[ -z "$config" ]] && echo "No config selected" && return
  NVIM_APPNAME="$(basename "$config")" nvim "$@"
}


# SSH AGENT

unset SSH_ASKPASS
export SSH_ASKPASS_REQUIRE=never

SSH_ENV="$HOME/.ssh/agent-environment"

start_ssh_agent() {
  ssh-agent > "$SSH_ENV"
  chmod 600 "$SSH_ENV"
  source "$SSH_ENV" >/dev/null
  ssh-add ~/.ssh/id_ed25519
}

if [[ -f "$SSH_ENV" ]]; then
  source "$SSH_ENV" >/dev/null
  ps -p "$SSH_AGENT_PID" >/dev/null 2>&1 || start_ssh_agent
else
  start_ssh_agent
fi


# KEYBINDINGS

bindkey -v
bindkey -M viins '^?' backward-delete-char


# PLUGINS (ZLE FIRST)
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# syntax highlighting should load after other plugins
source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# atuin
. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"

# fzf
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh


# PROMPT 

export STARSHIP_CONFIG="$HOME/.config/starship.toml"
export STARSHIP_DISABLE_KEYMAP=1
unset -f zle-keymap-select 2>/dev/null
eval "$(starship init zsh)"


# ZOXIDE 
eval "$(zoxide init --cmd cd zsh)"


#  eza override
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --color=always --icons=always --no-user'
fi


# TMUX 
if command -v tmux >/dev/null 2>&1; then
  [[ -z "$TMUX" ]] && exec tmux
fi
