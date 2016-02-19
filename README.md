# my dotfiles repo
# For VIM plugins make sure to add then as submodules under git
# Note about submodules:
# after a git clone of this repo the submodules WILL NOT be updated
# It is required to also run:
# git submodule update --init --recursive
#
#
# Alternately when first cloning the repo try:
# git clone --recursive git://github.com/ethan235711/dotfile.git
#
# Also not that the current set of plugins for vim installed (specifically UltiSnips)
# requires Vim 7.4.  On Linux, SCHRODINGER only had 7.3 installed.
# As a result I needed to build VIM from source and I included python in the build
# because I think it is also required for python interpolation.  Here are the steps
# I followed during the linux install
#
# git clone https://github.com/vim/vim.git
# cd vim/
# ./configure --with-features=huge --enable-pythoninterp --prefix=$HOME
# make VIMRUNTIMEDIR=$HOME/share/vim/vim74
# make install
# This appears to be working.
