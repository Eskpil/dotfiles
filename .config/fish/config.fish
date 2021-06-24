
### NODE ###
set -U fish_user_paths $HOME/.local/bin $HOME/Applications $fish_user_paths
source ~/.config/fish/nvm-wrapper/nvm.fish

nvm use 15.7.0


### RANDOM COLOR SCRIPT ###
# Get this script from my GitLab: gitlab.com/dwt1/shell-color-scripts
# Or install it from the Arch User Repository: shell-color-scripts
colorscript random

### SETTING THE STARSHIP PROMPT ###
starship init fish | source

### Aliases ###

alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

alias ls='exa -al --color=always --group-directories-first' # my preferred listing
alias la='exa -a --color=always --group-directories-first' # all files and dirs
alias ll='exa -l --color=always --group-directories-first' # long format
alias lt='exa -aT --color=always --group-directories-first' # tree listing
alias l.='exa -a | egrep "^\."'

alias njb='/home/linus/.cargo/bin/nj-cli build'
alias njbr='/home/linus/.cargo/bin/nj-cli build --release'

alias rr='curl -s -L https://raw.githubusercontent.com/keroserene/rickrollrc/master/roll.sh | bash'

alias c="clear"

alias cqlsh='sudo docker exec -it scyllaU cqlsh'
