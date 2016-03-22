#===============================================================
# This .bashrc is written to perform cross platform on Mac
# and Linux systems.
#
#===============================================================

# Perform basic path settings
# ========================================================
# IF NOT RUNNING INTERACTIVELY, STOP RUNNING
# ========================================================
[ -z "$PS1" ] && return

#--------------------------------------
# Sources system-wide aliases/functions
#--------------------------------------
# -f ensures that bashrc exists and is a regular file
if [ -f /etc/bashrc ]; then
   . /etc/bashrc    
fi

#echo "Sourcing .bashrc"

#--------------------------------------
# Set USER and non-platform dependent variables
# any variables used by functions should be placed here
#--------------------------------------

# These local variables should be reset whenever a new build comes out.
BUILD="06" 
BRANCH="16-2"

# $PLAT can either be bob, Darwin, or Linux
if [ `uname -n | grep -i bob` ]; then
	PLAT="bob"
else
	PLAT=$(uname)
fi

echo "You are running on $PLAT using 20$BRANCH build$BUILD"

#--------------------------------------
# Source my functions
#--------------------------------------
if [ -f ~/.bash_functions ]; then
   . ~/.bash_functions
   # I have custom scripts I want to be able to call
   # Could use set -a to export all but I want to be conservative for now 
   export -f jirastatus
   export -f jira_platTest
fi

# source git auto completion
if [ -f  ~/.git-completion.sh ]; then
    source ~/.git-completion.sh
fi

#------------------------------------------------------------
# Set Default $SCHRODINGER & Other Localhost dependent settings
#------------------------------------------------------------

if [ `uname -n | grep pdx-mbp` ]; then 
	echo "You are on your Mac"
	lb
    export SCHRODINGER_THIRDPARTY=/opt/schrodinger/thirdparty/  
    # makes Schrodinger use temp directory on /tmp of local host 
    # instead of on home
    export SCHRODINGER_TEMP_PROJECT=/tmp
    export PATH=$PATH:/Applications/MacPyMOL.app/Contents/MacOS/MacPyMOL
#    export PATH=$PATH:/Applications/PyMOLX11Hybrid.app/Contents/MacOS/MacPyMOL
    export PATH=/home/esmith/src/:$PATH
    # Allows git to use my chosen VIM version for commits
    export EDITOR='/usr/local/bin/vim'
elif [ `uname -n | grep pdx-desk-l29` ]; then
	echo "You are on your Linux machine"
	lb

    export SCHRODINGER_THIRDPARTY=/scr/thirdparty/
    export PATH=$PATH:/scr/pymol/
    # makes Schrodinger use temp directory on /scr of local host 
    # instead of on home
    export SCHRODINGER_TEMP_PROJECT=/scr 
    export PATH=/utils/bin:$PATH
    export PATH=/home/esmith/src/:$PATH
    export PATH=/usr/local/bin/ruby:$PATH

    # post bash 4.2 this is required for tab completion to work
    shopt -s direxpand

else
	echo "You must be where there is not a local installation"
	ob
fi

#------------------------------
# General Environment variables
#------------------------------

export SSH_AUTH_SOCK=0 # Silence an error: Agent admitted failure etc...
export MALLOC_CHECK_=2 # has to do with memory allocation
#export SCHRODINGER_INSTALL_QA=1 # Supposedly this makes installer install QA
								# I think this only actually works for Linux
export SCHRODINGER_RSH=ssh # forces jobcontrol to use ssh instead of rsh. This is
						   # important to set up passwordless ssh 
						   # "first rsh in path [ssh | rsh]"?
#export SCHRODINGER_RCP=scp # ?

export CLICOLOR=1		# Turns on terminal coloring on
export SCHRODINGER_SRC=1  # Ensures that errors are printed directly to the terminal
                          # rather than to a text file.
# Unset SSH_ASKPASS to avoid issue with git http://git.661346.n2.nabble.com/Git-ksshaskpass-to-play-nice-with-https-and-kwallet-td6858195.html
unset SSH_ASKPASS

#--------------
# Set Shell prompt
#--------------

red='\[\e[0;31m\]' # I think these are creating color string constants
RED='\[\e[1;31m\]'  # I think the \e is an ANSI color escape character
blue='\[\e[1;34m\]'  # Note that extra \[\] are a fix for line wrapping
GREEN='\[\e[0;32m\]' # as described in http://hintsforums.macworld.com/archive/index.php/t-17068.html
yellow='\[\e[1;33m\]'
CYAN='\[\e[1;36m\]'
NC='\[\e[0m\]'              # No Color
    
# set the command line prompt
PS1="\n[${red}\u${red}@\h${NC}:${blue}(\$(git branch 2>/dev/null | grep '\*' | sed -e 's/..//')):${GREEN}\w${NC}]\n[\!]> "


#--------------------------------------
# Platform Independent Aliases
#--------------------------------------

alias l29='ssh pdx-desk-l29'
alias dush='du -sh *'
alias df='df -h'
alias sb='source ~/.bashrc'
alias env='env | sort'
alias ll='ls -l'
alias la='ls -a'
alias bob1='ssh bobsub1'
alias bob2='ssh bobsub2'
alias bobio='ssh bobio'
alias smap='"$SCHRODINGER"/sitemap'
alias mmgbsa='"$SCHRODINGER"/prime_mmgbsa'
alias prime='"$SCHRODINGER"/prime'
alias mperm='"$SCHRODINGER"/membrane_permeability'
alias propl='"$SCHRODINGER"/utilities/proplister -c'
alias fun='. "$SCHRODINGER"/qa-v*/bin/Linux-x86_64/setup_funny_env.sh'
alias bldenv='export SCHRODINGER_SRC=/zone2/esmith/src; export SCHRODINGER_LIB=/software/lib/; export SCHRODINGER=/scr/schrod_2013-2_build'
alias wrkup='"$SCHRODINGER"/utilities/stu_workup'
alias stumod='"$SCHRODINGER"/utilities/stu_modify --user smith'
alias stuext='"$SCHRODINGER"/utilities/stu_extract --user smith'
alias stuexe='"$SCHRODINGER"/utilities/stu_execute --user smith'
alias stuadd='"$SCHRODINGER"/utilities/stu_add --user smith'
alias squish='"$SCHRODINGER"/utilities/run_squish -V'
alias greper='grep -iE "warn|fail|error|fatal"'
alias subl='/home/esmith/src/Sublime\ Text\ 2/sublime_text'
alias jirap='ssh pdx-jira-lv01'
alias jirat='ssh pdx-jiratest-lv01'
alias jiracli='/home/share/jira/jira.sh'
alias srun='"$SCHRODINGER"/run'
alias shunt='"$SCHRODINGER"/hunt'
alias cdjl='cd /dstore/atlassian/application-data/jira/log'
alias cdjs='cd /dstore/atlassian/jira/atlassian-jira/WEB-INF/classes/'
#--------------------------------------
# Platform Dependent Aliases
#--------------------------------------
if [ $PLAT == "Darwin" ]; then
	alias tin='open -a Tincta'
    # Use custom version of vim 7.4 built with python to enable use of UltiSnips plugin on Mac
    alias vi='/usr/local/bin/vim'
fi

if [ $PLAT == "Linux" ]; then
	alias kat='kate &'
	alias w03='rdesktop -a 32 -g 1550x1100 pdx-desk-w03' # Note that -a 32 is required for MAE graphics
    alias p1='cd /scr/gui_tests/priority_1/'
    alias p5='cd /scr/gui_tests/priority_5/'
    # Use custom version of vim 7.4 built with python to enable use of UltiSnips plugin on Linux
    alias vi='$HOME/bin/vim'

fi


#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/Users/esmith/.sdkman"
[[ -s "/Users/esmith/.sdkman/bin/sdkman-init.sh" ]] && source "/Users/esmith/.sdkman/bin/sdkman-init.sh"

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
