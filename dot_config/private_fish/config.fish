# =============================================================================
# FISH CONFIGURATION - ENHANCED & MODERN WITH NERD FONTS
# =============================================================================

### PATH CONFIGURATION
set -e fish_user_paths
set -U fish_user_paths $HOME/.bin $HOME/.local/bin $HOME/.config/emacs/bin $HOME/Applications $HOME/.cargo/bin /var/lib/flatpak/exports/bin/ $fish_user_paths

### ENVIRONMENT VARIABLES
set fish_greeting ""                              # Supprime le message d'intro
set -x TERM "xterm-256color"                      # Type de terminal
set -x EDITOR "code --wait"                       # Éditeur principal
set -x VISUAL "code"                              # Éditeur visuel
set -x BROWSER "firefox"                          # Navigateur par défaut
set -x PAGER "bat"                                # Pager moderne avec bat

### MANPAGER with bat
set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"
set -x MANROFFOPT "-c"

### KEY BINDINGS
function fish_user_key_bindings
    fish_default_key_bindings

    # Bind Ctrl+f pour fzf file search
    bind \cf 'fzf_file_search'

    # Bind Ctrl+r pour fzf history search
    bind \cr 'fzf_history_search'

    # Bind Alt+c pour fzf directory change
    bind \ec 'fzf_cd'

    # Bind Ctrl+g pour git status interactif
    bind \cg 'fzf_git_status'
end

### FISH COLORS - Modern theme
set fish_color_normal ffffff
set fish_color_autosuggestion 555555
set fish_color_command 5fd7ff
set fish_color_error ff6c6b
set fish_color_param ffffff
set fish_color_selection --background=3a3a3a
set fish_color_search_match --background=ffff00 --foreground=000000
set fish_color_valid_path --underline
set fish_color_redirection ffffff
set fish_color_end 5fd7ff
set fish_color_operator 5fd7ff

### NERD FONT ICONS CONFIGURATION ###
set -g ICON_OK "󰸞"
set -g ICON_ERROR "󰅙"
set -g ICON_WARNING "󰀦"
set -g ICON_INFO "󰋼"
set -g ICON_FOLDER "󰉋"
set -g ICON_FILE "󰈔"
set -g ICON_GIT "󰊢"
set -g ICON_SEARCH "󰍉"
set -g ICON_CLOCK "󱎫"
set -g ICON_MEMORY "󰍛"
set -g ICON_CPU "󰘚"
set -g ICON_DISK "󰋊"
set -g ICON_NETWORK "󰖩"
set -g ICON_BACKUP "󰁯"
set -g ICON_EXTRACT "󰀼"
set -g ICON_CLEAN "󰃢"
set -g ICON_RELOAD "󰑓"
set -g ICON_EDIT "󰷈"
set -g ICON_TERMINAL "󰞷"
set -g ICON_PACKAGE "󰏗"

### ENHANCED FUNCTIONS WITH NERD FONTS ###

# Messages helper functions
function _msg_success
    set_color green
    echo "$ICON_OK $argv"
    set_color normal
end

function _msg_error
    set_color red
    echo "$ICON_ERROR $argv"
    set_color normal
end

function _msg_warning
    set_color yellow
    echo "$ICON_WARNING $argv"
    set_color normal
end

function _msg_info
    set_color blue
    echo "$ICON_INFO $argv"
    set_color normal
end

# Fonction améliorée pour l'historique avec fzf
function fzf_history_search
    set -l result (history | fzf --height=50% --layout=reverse --border --tac --prompt="$ICON_SEARCH History  ")
    if test -n "$result"
        commandline -rb $result
        commandline -f repaint
    end
end

# Fonction de recherche de fichiers avec fzf
function fzf_file_search
    set -l preview_cmd 'bat --color=always --style=numbers --line-range=:500 {}'
    set -l files_cmd

    # Utiliser fd si disponible (respecter l'alias), sinon find système
    if command -v fd >/dev/null
        set files_cmd "fd -t f -H ."  # fd: type fichier, inclure cachés
    else
        set files_cmd "/usr/bin/find . -type f 2>/dev/null"  # find système
    end

    set -l result (eval $files_cmd | fzf --height=70% --layout=reverse --border --preview="$preview_cmd" --prompt="$ICON_FILE Files  ")
    if test -n "$result"
        commandline -a (string escape $result)
        commandline -f repaint
    end
end

# Fonction de changement de répertoire avec fzf
function fzf_cd
    set -l result (/usr/bin/find . -type d 2>/dev/null | fzf --height=50% --layout=reverse --border --prompt="$ICON_FOLDER Directories  ")
    if test -n "$result"
        cd $result
        commandline -f repaint
    end
end

# Nouvelle fonction pour git avec fzf
function fzf_git_status
    if not git rev-parse --git-dir >/dev/null 2>&1
        _msg_error "Not in a git repository"
        return 1
    end

    set -l result (git status --porcelain | fzf --height=60% --layout=reverse --border --prompt="$ICON_GIT Git Status  " --preview='git diff --color=always {}' | awk '{print $2}')
    if test -n "$result"
        commandline -a (string escape $result)
        commandline -f repaint
    end
end

# Fonction améliorée pour créer et entrer dans un répertoire
function mkcd --description "Create directory and cd into it"
    argparse 'h/help' 'p/parents' -- $argv
    or return

    if set -q _flag_help
        _msg_info "Usage: mkcd [OPTIONS] DIRECTORY"
        echo "  -h, --help     Show this help"
        echo "  -p, --parents  Create parent directories as needed"
        return 0
    end

    if test (count $argv) -eq 0
        _msg_error "Directory name required"
        echo "Usage: mkcd <directory_name>"
        return 1
    end

    set -l dirname $argv[1]

    if set -q _flag_parents
        mkdir -p $dirname
    else
        mkdir $dirname
    end

    if test $status -eq 0
        cd $dirname
        _msg_success "Created and entered: $ICON_FOLDER $dirname"
    else
        _msg_error "Failed to create directory: $dirname"
        return 1
    end
end

# Fonction pour extraire tout type d'archive avec icônes
function extract --description "Extract various archive formats"
    argparse 'h/help' -- $argv
    or return

    if set -q _flag_help
        _msg_info "Usage: extract <archive_file>"
        echo "Supported formats:"
        echo "  󰀼 tar.bz2, tar.gz, tar.xz"
        echo "  󰀼 bz2, gz, xz, lzma"
        echo "  󰀼 zip, rar, 7z"
        return 0
    end

    if test (count $argv) -eq 0
        _msg_error "Archive file required"
        return 1
    end

    set -l file $argv[1]

    if not test -f $file
        _msg_error "File not found: $file"
        return 1
    end

    _msg_info "Extracting: $ICON_EXTRACT $file"

    switch $file
        case "*.tar.bz2"
            tar xjf $file
        case "*.tar.gz"
            tar xzf $file
        case "*.tar.xz"
            tar xJf $file
        case "*.bz2"
            bunzip2 $file
        case "*.rar"
            unrar x $file
        case "*.gz"
            gunzip $file
        case "*.tar"
            tar xf $file
        case "*.tbz2"
            tar xjf $file
        case "*.tgz"
            tar xzf $file
        case "*.zip"
            unzip $file
        case "*.Z"
            uncompress $file
        case "*.7z"
            7z x $file
        case "*.xz"
            unxz $file
        case "*.lzma"
            unlzma $file
        case "*"
            _msg_error "'$file' format not supported"
            echo "Supported: tar.bz2, tar.gz, tar.xz, bz2, rar, gz, tar, tbz2, tgz, zip, Z, 7z, xz, lzma"
            return 1
    end

    if test $status -eq 0
        _msg_success "Successfully extracted: $file"
    else
        _msg_error "Failed to extract: $file"
        return 1
    end
end

# Fonction pour réinitialiser fish rapidement
function reload --description "Reload fish configuration"
    _msg_info "$ICON_RELOAD Reloading Fish configuration..."
    source ~/.config/fish/config.fish
    _msg_success "Fish configuration reloaded!"

    if command -v starship >/dev/null
        _msg_info "󰀘 Starship prompt refreshed!"
    end
end

# Fonction pour backup avec timestamp
function backup --description "Create a timestamped backup of a file"
    argparse 'h/help' 'd/directory=' -- $argv
    or return

    if set -q _flag_help
        _msg_info "Usage: backup [OPTIONS] FILE"
        echo "  -h, --help              Show this help"
        echo "  -d, --directory=DIR     Backup directory (default: same as file)"
        return 0
    end

    if test (count $argv) -eq 0
        _msg_error "Filename required"
        return 1
    end

    set -l filename $argv[1]

    if not test -f $filename
        _msg_error "File not found: $filename"
        return 1
    end

    set -l backup_dir (dirname $filename)
    if set -q _flag_directory
        set backup_dir $_flag_directory
        mkdir -p $backup_dir
    end

    set -l basename (basename $filename)
    set -l timestamp (date +%Y%m%d_%H%M%S)
    set -l backup_name "$backup_dir/$basename.backup.$timestamp"

    _msg_info "$ICON_BACKUP Creating backup..."
    if cp $filename $backup_name
        _msg_success "Backup created: $backup_name"
    else
        _msg_error "Failed to create backup"
        return 1
    end
end

# Fonction pour taille des dossiers
function dirsize --description "Show directory sizes sorted by size"
    argparse 'h/help' 'a/all' 'd/depth=' -- $argv
    or return

    if set -q _flag_help
        _msg_info "Usage: dirsize [OPTIONS] [DIRECTORY]"
        echo "  -h, --help       Show this help"
        echo "  -a, --all        Include hidden directories"
        echo "  -d, --depth=N    Limit depth (default: 1)"
        return 0
    end

    set -l target_dir "."
    if test (count $argv) -gt 0
        set target_dir $argv[1]
    end

    set -l depth_opt "--max-depth=1"
    if set -q _flag_depth
        set depth_opt "--max-depth=$_flag_depth"
    end

    _msg_info "$ICON_DISK Directory sizes in: $target_dir"

    if set -q _flag_all
        du -sh $depth_opt $target_dir/.* $target_dir/* 2>/dev/null | sort -hr
    else
        du -sh $depth_opt $target_dir/* 2>/dev/null | sort -hr
    end
end

# Fonction pour comparer des fichiers avec delta
function diff --description "Compare files with delta (git diff style)"
    if command -v delta >/dev/null
        command delta $argv
    else if command -v diff >/dev/null
        command diff --color=always $argv
    else
        _msg_error "No diff tool available"
        return 1
    end
end

### ALIASES AVEC NERD FONTS ###

# Navigation améliorée
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias back='cd -'
alias home='cd ~'

# Editors et outils
alias vim='nvim'
alias vi='nvim'
alias n='nvim'
alias code='code'
alias codew='code --wait'
alias coden='code --new-window'
alias c.='code .'
alias cc='code .'

# LS avec eza (plus moderne) - avec icônes
if command -v eza >/dev/null
    alias ls='eza --icons --group-directories-first'
    alias la='eza -la --icons --group-directories-first'
    alias ll='eza -l --icons --group-directories-first --header'
    alias lt='eza --tree --level=2 --icons'
    alias lta='eza --tree --level=3 --icons -a'
    alias l.='eza -la --icons | grep "^\."'
    alias lr='eza -la --icons --sort=modified'  # Recently modified
else
    alias ls='ls --color=auto --group-directories-first'
    alias la='ls -la'
    alias ll='ls -l'
end

# Cat avec bat
if command -v bat >/dev/null
    alias cat='bat --style=auto'
    alias catn='bat --style=plain'
    alias catl='bat --style=numbers'
else
    alias cat='cat'
end

# Grep moderne avec ripgrep
if command -v rg >/dev/null
    alias grep='rg'
    alias gi='rg -i'
    alias gr='rg -r'
else
    alias grep='grep --color=auto'
    alias gi='grep -i'
end

# Find moderne avec fd
if command -v fd >/dev/null
    alias find='fd'
    alias fda='fd -H'  # Include hidden
    alias fdd='fd -t d'  # Directories only
    alias fdf='fd -t f'  # Files only
else
    alias find='find'
end

# Pacman et paru (Arch Linux) avec icônes
alias pacsyu="echo '$ICON_PACKAGE Updating system...' && sudo pacman -Syu"
alias pacsyyu="echo '$ICON_PACKAGE Force updating...' && sudo pacman -Syyu"
alias parsua="echo '$ICON_PACKAGE Updating AUR...' && paru -Sua --noconfirm"
alias parsyu="echo '$ICON_PACKAGE Updating all...' && paru -Syu --noconfirm"
alias pacqs='pacman -Qs'
alias pacss='pacman -Ss'
alias paci="echo '$ICON_PACKAGE Installing...' && sudo pacman -S"
alias pacr="echo '$ICON_PACKAGE Removing...' && sudo pacman -R"
alias pacrns="echo '$ICON_PACKAGE Removing with deps...' && sudo pacman -Rns"
alias unlock="echo '$ICON_WARNING Unlocking pacman...' && sudo rm /var/lib/pacman/db.lck"

# Système et monitoring avec icônes
alias df='df -h'
alias free='free -h'
alias du='du -h'
alias ps='ps auxf'
alias psg='ps aux | grep'
alias top='htop'
alias cpu='grep "cpu " /proc/stat | awk "{usage=(\$2+\$4)*100/(\$2+\$3+\$4+\$5)} END {print usage \"%\"}"'
alias temp='sensors 2>/dev/null || echo "Install lm-sensors"'

# Network avec icônes
alias ping='ping -c 5'
alias wget='wget -c'
alias myip="echo '$ICON_NETWORK External IP:' && curl -s ifconfig.me && echo"
alias localip="echo '$ICON_NETWORK Local IP:' && ip route get 1.1.1.1 | awk '{print \$7}'"
alias speedtest='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -'

# Shortcuts pratiques avec icônes
alias h='history'
alias j='jobs'
alias path='echo $PATH | tr ":" "\n"'
alias edit="echo '$ICON_EDIT Editing fish config...' && code ~/.config/fish/config.fish"
alias editkit="echo '$ICON_EDIT Editing kitty config...' && code ~/.config/kitty/kitty.conf"
alias editstar="echo '$ICON_EDIT Editing starship config...' && code ~/.config/starship.toml"

### BETTER DEFAULTS ###
alias mkdir='mkdir -pv'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias ln='ln -i'
alias chmod='chmod --preserve-root'
alias chown='chown --preserve-root'

### INTEGRATIONS AMÉLIORÉES ###

# FZF integration avec icônes
if command -v fzf >/dev/null
    set -x FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border --margin=1 --padding=1 --color=16'

    if command -v fd >/dev/null
        set -x FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
    else
        set -x FZF_DEFAULT_COMMAND 'find . -type f -not -path "*/\.git/*"'
    end

    set -x FZF_CTRL_T_COMMAND '$FZF_DEFAULT_COMMAND'

    if test -f /usr/share/fzf/key-bindings.fish
        source /usr/share/fzf/key-bindings.fish
        fzf_key_bindings
    end
end

# Zoxide integration
if command -v zoxide >/dev/null
    zoxide init fish | source
    alias cd='z'
    alias cdi='zi'
end

# Direnv integration
if command -v direnv >/dev/null
    direnv hook fish | source
end

# Starship prompt
if command -v starship >/dev/null
    starship init fish | source
end

### COMPLETION ENHANCEMENTS ###
complete -c backup -d "Create timestamped backup"
complete -c extract -d "Extract various archive formats"
