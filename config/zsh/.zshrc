#!/usr/bin/env zsh

# Table of Contents
# -----------------
# 1. Shellcheck Directives
# 2. Aliases
#    2.1 File Management and Navigation
#    2.2 Safeguards
#    2.3 Postfix (Suffix Aliases)
#    2.4 Highlighting and XDG Compliance
#    2.5 Miscellaneous
# 3. Environment Variables
#    3.1 Editor and Pager
# 4. Functions
#    4.1 Directory Creation and Navigation
#    4.2 File Creation
#    4.3 Diff Utility
#    4.4 Git Prompt Helpers
# 5. Zsh Options and Settings
#    5.1 General Options
#    5.2 Directory Stack
#    5.3 History Settings
# 6. Plugins
# 7. Cursor and Mode Configurations
#    7.1 Cursor Positioning
#    7.2 Vi/Emacs Modes and Cursor Shapes
#    7.3 Yank to Clipboard in Vi Mode
# 8. Custom Widgets and Behaviors
#    8.1 History Search
#    8.2 Ctrl-Z Toggle
#    8.3 Custom CD with PD
# 9. Key Bindings
# 10. Colors and Prompt
#     10.1 Color Helper
#     10.2 Prompt Configuration
#     10.3 Terminal Title
# 11. Completions and Autocompletion
# 12. Secure and Local Configurations

# 1. Shellcheck Directives
# ------------------------
# These disable specific warnings for non-constant sourcing and alias expansions.
# shellcheck disable=SC1090,SC2139
# SC1090: Can't follow non-constant source. Use a directive to specify location.

# 2. Aliases
# ----------
# Aliases are grouped by category for easier maintenance. They enhance common commands
# with safety features, modern alternatives (e.g., eza for ls, bat for cat), and shortcuts.

# 2.1 File Management and Navigation
alias ..='cd ..; l'         # Go to parent directory and list contents
alias ...='cd ../..; l'     # Go to grandparent directory and list contents
alias mkdir='mkdir -p'      # Create directories recursively
alias h='history'           # Show command history
alias dirs='dirs -v'        # Show directory stack with indices
alias ls='eza --group-directories-first --time-style=long-iso --classify'  # Modern ls replacement with grouping and classification
alias l='ls'                # Short alias for ls
alias la='ls -a'            # List all files (including hidden)
alias ld='ls -d .*'         # List hidden directories only
alias ll='ls -l'            # Long listing
alias lla='ls -al'          # Long listing including hidden
alias lld='ls -al -d .*'    # Long listing of hidden files/directories
alias lt='eza --tree --level=3'  # Tree view up to 3 levels

# 2.2 Safeguards
alias rm='rm -i'            # Prompt before deletion
alias mv='mv -i'            # Prompt before overwriting on move
alias cp='cp -i'            # Prompt before overwriting on copy
alias ln='ln -iv'           # Verbose linking with error if link exists

# 2.3 Postfix (Suffix Aliases)
# These are global aliases (-g) that can be appended to any command for piping.
alias -g G='| grep --line-number --context=1'  # Grep with line numbers and 1 line of context
alias -g C='| pbcopy'       # Copy output to clipboard
alias -g P='| less'         # Pipe to pager

# 2.4 Highlighting and XDG Compliance
alias cat='bat'             # Syntax-highlighted cat alternative
alias wget="wget --hsts-file=${XDG_CACHE_HOME}/wget/history"  # Use XDG cache for wget history
alias bash="bash --init-file ${XDG_CONFIG_HOME}/bash/bashrc"  # Load XDG-compliant bashrc

# 2.5 Miscellaneous
alias resign-xcode="sudo codesign -f -s ${USER} /Applications/Xcode.app"  # Re-sign Xcode
alias pp='pretty-print-path'  # Pretty-print PATH variable
alias b='bundle'              # Shortcut for bundle (Ruby)

alias vi='\vim -U $XDG_CONFIG_HOME/vim/vimrc.minimal.vim'  # Vim with minimal config
alias vin='\vim -U NONE'     # Vim with no config
alias vim='nvim'             # Alias vim to neovim

# 3. Environment Variables
# ------------------------
# Set defaults for editor, pager, and less behavior.

# 3.1 Editor and Pager
export EDITOR="nvim"         # Default editor
export PAGER="less"          # Default pager
export LESSOPEN="| src-hilite-lesspipe.sh %s"  # Syntax highlighting for less
export LESS=' --no-init --RAW-CONTROL-CHARS --quit-if-one-screen '  # Less options: no init, raw chars, quit if one screen

# 4. Functions
# ------------
# Custom functions for common tasks, git status parsing, and prompt building.

# 4.1 Directory Creation and Navigation
# Create a directory (replacing spaces with hyphens) and cd into it.
md() {
  local directory_name="${*// /-}"
  mkdir -p "${directory_name}"
  cd "${directory_name}" || return
}

# 4.2 File Creation
# Create an executable bin file, make it executable, and open in editor.
mkbin() {
  local file="${DOTFILES_DIR}/bin/${1}"
  touch "$file"
  chmod u+x "$file"
  e "$file"
}

# 4.3 Diff Utility
# Colorized diff using delta.
diff() {
  [[ -n "${1}" ]] && [[ -n "${2}" ]] || return
  "${HOMEBREW_PREFIX}/bin/diff" -u "${1}" "${2}" | delta
}

# 4.4 Git Prompt Helpers
#
# These parse git status for color and branch info, supporting English and
# Spanish outputs for localization.
git_color() {
  git_status="$(git status 2> /dev/null)"
  case "${git_status}" in
    *'not staged'* | *'to be committed'* | *'untracked files present'* |\
    *'no rastreados'* | *'archivos sin seguimiento'* | *'a ser confirmados'*)
      echo -ne "$(color red)"
      ;;
    *'branch is ahead of'* | *'have diverged'* |\
    *'rama está adelantada'* | *'rama está detrás de'* | *'han divergido'*)
      echo -ne "$(color yellow)"
      ;;
    *'working '*' clean'* | *'está limpio'*)
      echo -ne "$(color green)"
      ;;
    *'Unmerged'* | *'no fusionadas'* | *'rebase interactivo en progreso'*)
      echo -ne "$(color violet)"
      ;;
    *)
      echo -ne "$(color white)"
      ;;
  esac
}

git_branch() {
  git_status="$(git status 2> /dev/null)"
  local is_on_branch='^(On branch|En la rama) ([^[:space:]]+)'
  local is_on_commit='HEAD (detached at|desacoplada en) ([^[:space:]]+)'
  local is_rebasing="(rebasing branch|rebase de la rama) '([^[:space:]]+)' (on|sobre) '([^[:space:]]+)'"
  local branch
  local commit

  if [[ ${git_status} =~ ${is_on_branch} ]]; then
    branch=${match[2]:-${BASH_REMATCH[2]}}  # Zsh/bash portable
    if [[ ${git_status} =~ (Unmerged paths|no fusionadas) ]]; then
      git_color && echo -n "merging into ${branch} "
    else
      git_color && echo -n "${branch} "
    fi
  elif [[ ${git_status} =~ ${is_on_commit} ]]; then
    commit=${match[2]:-${BASH_REMATCH[2]}}
    git_color && echo -n "${commit} "
  elif [[ ${git_status} =~ ${is_rebasing} ]]; then
    branch=${match[2]:-${BASH_REMATCH[2]}}
    commit=${match[4]:-${BASH_REMATCH[4]}}
    git_color && echo -n "rebasing ${branch} onto ${commit} "
  fi
}

gitstatus_prompt() {
  PROMPT="$(color blue)%c$(color reset) "

  if gitstatus_query MY && [[ ${VCS_STATUS_RESULT} == ok-sync ]]; then
    if (( VCS_STATUS_HAS_CONFLICTED )); then
      PROMPT+="$(color violet)"
    elif (( VCS_STATUS_HAS_STAGED )) ||
         (( VCS_STATUS_HAS_UNSTAGED )) ||
         (( VCS_STATUS_HAS_UNTRACKED ));
    then
      PROMPT+="$(color red)"
    elif (( VCS_STATUS_COMMITS_AHEAD )) ||
         (( VCS_STATUS_COMMITS_BEHIND )) ||
         (( VCS_STATUS_PUSH_COMMITS_AHEAD )) ||
         (( VCS_STATUS_PUSH_COMMITS_BEHIND ));
    then
      PROMPT+="$(color yellow)"
    else
      PROMPT+="$(color green)"
    fi
    local hash="${VCS_STATUS_COMMIT:0:10}"
    local branch="${VCS_STATUS_LOCAL_BRANCH:-@${hash}}"
    PROMPT+="${branch//\%/%%} "  # Escape %
  fi

  PROMPT+="$(color reset)%# "
  setopt no_prompt_{bang,subst} prompt_percent  # Enable/disable correct prompt expansions
}

# 5. Zsh Options and Settings
# ---------------------------
# Configure Zsh behaviors for globbing, directories, and history.

# 5.1 General Options
setopt extendedglob         # Enable extended globbing patterns
unsetopt nomatch            # Allow unmatched [ or ] in patterns
autoload -U zmv             # Load zmv for batch renaming (e.g., zmv '(*).txt' '$1.html')

# 5.2 Directory Stack
setopt autocd autopushd pushd_minus pushd_silent  # Auto-cd, push dirs, swap +/-, silent pushd
setopt pushd_to_home cdable_vars pushd_ignore_dups  # Push ~ on empty, vars as dirs, ignore dups
export DIRSTACKSIZE=10      # Limit directory stack size

# 5.3 History Settings
export HISTFILE="${XDG_STATE_HOME}/zsh/history"  # History file location (XDG compliant)
export HISTORY_IGNORE="(ls|cd|pwd|exit|cd|h|l|lla|lld|g|g d|g co)"  # Ignore common commands
export HISTSIZE=1000        # In-memory history size
export SAVEHIST=1000        # Saved history size

setopt EXTENDED_HISTORY       # Save timestamp and duration
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicates first
setopt HIST_FIND_NO_DUPS      # Don't show duplicates in search
setopt HIST_IGNORE_ALL_DUPS   # Delete old duplicates
setopt HIST_IGNORE_DUPS       # Ignore immediate duplicates
setopt HIST_IGNORE_SPACE      # Ignore lines starting with space
setopt HIST_SAVE_NO_DUPS      # Don't save duplicates
setopt INC_APPEND_HISTORY     # Append incrementally
setopt SHARE_HISTORY          # Share history across sessions

# 6. Plugins
# ----------
# To avoid conflicts, these plugins should be loaded in the given order:
# - zsh-autosuggestions
# - zsh-syntax-highlighting
# - zsh-vim-mode
source "${XDG_DATA_HOME}/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

if [[ -z "${INSIDE_EMACS}" ]]; then
  source "${XDG_DATA_HOME}/zsh/zsh-vim-mode/zsh-vim-mode.plugin.zsh"
fi

# 7. Cursor and Mode Configurations
# ---------------------------------
# Manage cursor position, shapes, and vi/emacs modes.

# 7.1 Cursor Positioning
# Widget to move cursor after the first word (e.g., for inserting flags).
after-first-word() {
  zle beginning-of-line
  zle forward-word
}
zle -N after-first-word

# 7.2 Vi/Emacs Modes and Cursor Shapes
if [[ -z "${INSIDE_EMACS}" ]]; then
  # Change cursor shape based on vi mode.
  zle-keymap-select() {
    if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
      echo -ne '\e[1 q'  # Block cursor for command mode
    elif [[ ${KEYMAP} == main ]] || [[ ${KEYMAP} == viins ]] || [[ ${KEYMAP} = '' ]] || [[ $1 = 'beam' ]]; then
      echo -ne '\e[5 q'  # Beam cursor for insert mode
    fi
  }
  zle -N zle-keymap-select

  export KEYTIMEOUT=5  # Low lag for ESC to normal mode
  bindkey -v           # Vi keybindings

  echo -ne '\e[5 q'    # Beam cursor on startup
  preexec() { echo -ne '\e[5 q'; }  # Beam cursor for new prompts
fi

# 7.3 Yank to Clipboard in Vi Mode
if [[ -z "${INSIDE_EMACS}" ]]; then
  vi-yank-to-clipboard() {
    zle vi-yank
    echo -n "$CUTBUFFER" | pbcopy >/dev/null 2>&1
    zle reset-prompt
  }
  zle -N vi-yank-to-clipboard

  vi-yank-eol-to-clipboard() {
    zle vi-yank-eol
    echo -n "$CUTBUFFER" | pbcopy >/dev/null 2>&1
    zle reset-prompt
  }
  zle -N vi-yank-eol-to-clipboard

  bindkey -M vicmd 'y' vi-yank-to-clipboard
  bindkey -M visual 'y' vi-yank-to-clipboard
  bindkey -M vicmd 'Y' vi-yank-eol-to-clipboard
fi

# 8. Custom Widgets and Behaviors
# -------------------------------
# Enhance history, job control, and cd.

# 8.1 History Search
setopt complete_in_word     # Complete from cursor position
autoload -U down-line-or-beginning-search
autoload -U up-line-or-beginning-search
zle -N down-line-or-beginning-search
zle -N up-line-or-beginning-search

# 8.2 Ctrl-Z Toggle
# Toggle between suspending and resuming jobs with Ctrl-Z.
ctrlz() {
  if [[ $#BUFFER -eq 0 ]]; then
    fg >/dev/null 2>&1 && zle redisplay
  else
    zle push-input
  fi
}
zle -N ctrlz

# 8.3 Custom CD with PD
# Use pd if available for path resolution; fallback to builtin cd.
cd() {
  local target
  if type pd >/dev/null; then
    target="$(pd "$1")"
  else
    target="${@}"
  fi

  if [[ "${target}" == -* ]] || [[ -d "${target}" ]]; then
    builtin cd "${target}"
  else
    echo "Directory Not Found: ${target//$HOME/~}"
  fi
}

# 9. Key Bindings
# ---------------
# Define key bindings across modes. Includes FZF integration and history navigation.

# ZLE Definitions (placeholders; assume fzf-file-widget and prefix-2 are defined elsewhere)
zle -N fzf-file-widget
zle -N prefix-2

# All Modes
bindkey "^[[3"  prefix-2         # Delete backwards
bindkey "^[[3~" delete-char      # Delete forwards
bindkey "^t"    fzf-file-widget  # FZF file finder
bindkey "^x"    after-first-word # Move to after first word
bindkey "^z"    ctrlz            # Ctrl-Z toggle

# String-Based (macros)
bindkey -s "^h" "cd\n"           # CD with PD
bindkey -s "^\]" "g cob\n"       # Git change branch

# Emacs Mode
bindkey -M emacs '^y' accept-and-hold
bindkey -M emacs '^o' push-line-or-edit

# Vi Insert Mode
bindkey -M viins '^a' beginning-of-line
bindkey -M viins '^b' backward-char
bindkey -M viins '^d' delete-char
bindkey -M viins '^e' end-of-line
bindkey -M viins '^f' forward-char
bindkey -M viins '^k' kill-line
bindkey -M viins '^n' down-line-or-beginning-search
bindkey -M viins '^o' push-line-or-edit
bindkey -M viins '^p' up-line-or-beginning-search
bindkey -M viins '^r' history-incremental-search-backward
bindkey -M viins '^y' accept-and-hold

# Vi Command Mode
bindkey -M vicmd '^n' down-line-or-beginning-search
bindkey -M vicmd '^p' up-line-or-beginning-search
bindkey -M vicmd '^r' history-incremental-search-backward

# Arrow Keys for History Search
bindkey '\e[A' up-line-or-beginning-search
bindkey '\e[B' down-line-or-beginning-search
bindkey -s '\eOA' '\e[A'
bindkey -s '\eOB' '\e[B'

# 10. Colors and Prompt
# ---------------------
# Load colors and set up a dynamic prompt with git info.

# 10.1 Color Helper
autoload -U colors && colors
color() {
  case $1 in
    red)    printf "%s" "%{${fg_no_bold[red]}%}" ;;
    yellow) printf "%s" "%{${fg_no_bold[yellow]}%}" ;;
    green)  printf "%s" "%{${fg_no_bold[green]}%}" ;;
    violet) printf "%s" "%{${fg_no_bold[magenta]}%}" ;;
    blue)   printf "%s" "%{${fg_no_bold[blue]}%}" ;;
    white)  printf "%s" "%{${fg_no_bold[white]}%}" ;;
    reset)  printf "%s" "%{${reset_color}%}" ;;
  esac
}

# 10.2 Prompt Configuration
setopt prompt_subst  # Enable substitution in prompt

if [[ -f "${HOMEBREW_PREFIX}/opt/gitstatus/gitstatus.plugin.zsh" ]]; then
  source "${HOMEBREW_PREFIX}/opt/gitstatus/gitstatus.plugin.zsh"
  gitstatus_stop 'MY' && gitstatus_start -s -1 -u -1 -c -1 -d -1 'MY'
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd gitstatus_prompt
else
  # Fallback prompt without gitstatus
  PS1=$'$(color blue)%c$(color reset) '  # Current directory basename
  PS1+='$(git_branch)'                    # Git branch/commit with color
  PS1+='$(color reset)%# '                # Reset and prompt symbol
  export PS1
fi

# 10.3 Terminal Title
# Set title to current dir and git branch (for terminals like zellij).
set_title() {
  print -Pn "\e]0;%~$(git_branch)\a"
}
precmd_functions+=(set_title)

# 11. Completions and Autocompletion
# ----------------------------------
# Set up completions, including git alias and FZF if available.

# shellcheck disable=SC2206
fpath=(
  ${BREW_PREFIX}/share/zsh/site-functions
  ${BREW_PREFIX}/share/zsh-completions
  ${ZDOTDIR}/completions
  ${fpath}
)

autoload -Uz compinit
compinit

compdef g=git               # Complete 'g' as git
setopt complete_aliases     # Complete aliased commands

if [[ -d "${XDG_DATA_HOME}/fzf/shell" ]]; then
  . "${XDG_DATA_HOME}/fzf/shell/completion.zsh"
  . "${XDG_DATA_HOME}/fzf/shell/key-bindings.zsh"
fi

# 12. Secure and Local Configurations
# -----------------------------------
# Source private or machine-specific configs last.

[[ -f "${XDG_SECURE_DIR}/config/zsh/zshrc" ]] && \
  . "${XDG_SECURE_DIR}/config/zsh/zshrc"

[[ -f "${XDG_LOCALS_DIR}/config/zsh/zshrc" ]] && \
  . "${XDG_LOCALS_DIR}/config/zsh/zshrc"

[[ -f "${XDG_LOCALS_DIR}/config/zsh/.iterm2_shell_integration.zsh" ]] && \
  . "${XDG_LOCALS_DIR}/config/zsh/.iterm2_shell_integration.zsh"
