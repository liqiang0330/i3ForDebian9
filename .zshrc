# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh
# Set name of the theme to load.
#ZSH_THEME="pure"
ZSH_THEME="agnoster"

#turn on comments with # in shell
setopt interactivecomments

### ALIASES
alias zshconfig_global="vim ~/.zshrc"
alias vimconfig="vim ~/.vimrc"
alias lh="du -ahd1 | sort -h"
alias update="sudo apt update"
alias upgrade="sudo apt update && sudo apt upgrade"
extract() {
   if [ -f $1 ] ; then
       case $1 in
           *.tar.bz2)	tar xvjf $1    ;;
           *.tar.gz)	tar xvzf $1    ;;
	   *.tar.xz)	tar xJf $1     ;;
           *.bz2)	bunzip2 $1     ;;
           *.rar)	unrar x $1     ;;
           *.gz)	gunzip $1      ;;
           *.tar)	tar xvf $1     ;;
           *.tbz2)	tar xvjf $1    ;;
           *.tgz)	tar xvzf $1    ;;
           *.zip)	unzip $1       ;;
           *.Z)		uncompress $1  ;;
           *.7z)	7z x $1        ;;
           *)		echo "Unable to extract '$1'" ;;
       esac
   else
       echo "'$1' is not a valid file"
   fi
}
alias startx="ssh-add;startx"

### EXPORTS
export EDITOR='vim'
export VISUAL='vim'
export BROWSER='google-chrome-stable'
export POWERLINE_CONFIG_COMMAND=/usr/bin/powerline-config
unset SSH_ASKPASS

## MAN COLORS
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

## SSH AGENT
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

### ZSH CONF
autoload -U zmv
plugins=(git python)
source $ZSH/oh-my-zsh.sh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
