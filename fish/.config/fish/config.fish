set -g fish_greeting

# Add ~/bin to PATH if it exists
if test -d ~/bin
    set -gx PATH ~/bin $PATH
end
set -e fish_command_not_found

fetch
# Atuin (history)
atuin init fish | source

# Zoxide (directory jumping)
zoxide init fish | source

# Direnv (environment)
#direnv hook fish | source

# Starship prompt
starship init fish | source
function __reload_theme --on-signal USR1
    clear
    fetch
end

set -gx XCURSOR_THEME "Volantes Cursors"
set -gx XCURSOR_SIZE 24

# -------------------------------
# Abbreviations
# -------------------------------
abbr -a n "nvim"
abbr -a ga "git add ."
abbr -a gs "git status"
abbr -a gm "git commit -m "
abbr -a gp "git push"
abbr -a ins "sudo xbps-install "
abbr -a que "sudo xbps-query -Rs "
abbr -a rem "sudo xbps-remove -R "
abbr -a ser "sudo ln -s /etc/sv"
abbr -a blu "python3 ~/dotfiles/Scripts/bluetooth.py"
abbr -a col " npm --prefix ~/Lost/Programming/Rust/Tauri/Lumus run tauri dev"
abbr -a pa "pass show -c"
#abbr -a vivado "~/Applications/Xilinx/2025.2/Vivado/bin/vivado"
#abbr -a vitis "~/Applications/Xilinx/2025.2/Vitis/bin/vitis"

set -Ux EDITOR nvim
# -------------------------------
# Functions
# -------------------------------
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    set cwd (cat "$tmp")
    if test -n "$cwd" -a "$cwd" != "$PWD"
        cd "$cwd"
    end
    rm -f "$tmp"
end
