#!/bin/bash
set -e

# handle arguments for script mode
if [ $# -eq 0 ]
then
  SCRIPT_MODE="native"
elif [ $# -eq 1 ]
then
  SCRIPT_MODE=$1
  if [ $SCRIPT_MODE != "native" ] && [ $SCRIPT_MODE != "docker" ]
  then
    echo "usage: mode must be native or docker, not: ${SCRIPT_MODE}"
  fi
else
  echo "usage: user_setup.sh [mode](native, docker)"
  exit -1
fi

ZSDK_VERSION="0.16.1"

# vim setup
mkdir -p ~/.vim/pack/plugins/opt
if ! [ -d ~/.vim/pack/plugins/opt/YouCompleteMe ]; then
  ln -s /opt/vim/YouCompleteMe ~/.vim/pack/plugins/opt/YouCompleteMe
fi

if ! [ -d ~/.vim/pack/plugins/opt/NERDCommenter ]; then
  ln -s /opt/vim/NERDCommenter ~/.vim/pack/plugins/opt/NERDCommenter
fi

if ! [ -d ~/.vim/pack/plugins/opt/securemodelines ]; then
  ln -s /opt/vim/securemodelines ~/.vim/pack/plugins/opt/securemodelines
fi

if ! grep -qF "COGNIPILOT_SETUP" ~/.vimrc; then
cat << EOF >> ~/.vimrc
# COGNIPILOT_SETUP
packadd YouCompleteMe
packadd NERDCommenter
packadd securemodelines

filetype plugin indent on

" Vim5 and later versions support syntax highlighting. Uncommenting the next
" line enables syntax highlighting by default.
if has("syntax")
  syntax on
endif

" If using a dark background within the editing area and syntax highlighting
" turn on this option as well
set background=dark

" Uncomment the following to have Vim jump to the last position when
" reopening a file
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" The following are commented out as they cause vim to behave a lot
" differently from regular Vi. They are highly recommended though.
set showcmd		" Show (partial) command in status line.
set showmatch		" Show matching brackets.
set ignorecase		" Do case insensitive matching
set smartcase		" Do smart case matching
set incsearch		" Incremental search
set autowrite		" Automatically save before commands like :next and :make
set hidden		" Hide buffers when they are abandoned
set mouse=a		" Enable mouse usage (all modes)

hi YcmWarningSection ctermbg=52
EOF
fi

# zephyr
sudo -E /opt/toolchains/zephyr-sdk-${ZSDK_VERSION}/setup.sh -c
sudo chown -R $UID:$UID /home/$USER/.cmake

# update rosdep
if ! [ -f /etc/ros/rosdep/sources.list.d/20-default.list ]; then
  sudo rosdep init
fi
rosdep update

# gdbinit file
cat << EOF > ~/.gdbinit
define hook-stop
  refresh
end
EOF

# create symlink to west in ~/bin
mkdir -p ~/bin
cd ~/bin
cat << EOF > ~/bin/west
#!/bin/bash
set -e
source /opt/.venv-zephyr/bin/activate
/opt/.venv-zephyr/bin/west "\$@"
EOF
chmod +x ~/bin/west

# modify bashrc
if ! grep -qF "COGNIPILOT_SETUP" ~/.bashrc; then
cat << EOF >> ~/.bashrc
# COGNIPILOT_SETUP
source /opt/ros/humble/setup.bash
if [ -f \$HOME/cognipilot/ws/zephyr/scripts/west_commands/completion/west-completion.bash ]; then
  #echo sourcing west completion
  source \$HOME/cognipilot/ws/zephyr/scripts/west_commands/completion/west-completion.bash
fi
if [ -f \$HOME/cognipilot/gazebo/install/setup.sh ]; then
  source \$HOME/cognipilot/gazebo/install/setup.sh
  #echo gazebo built, sourcing
fi
if [ -f \$HOME/cognipilot/cranium/install/setup.sh ]; then
  #echo dream built, sourcing
  source \$HOME/cognipilot/cranium/install/setup.sh
fi
if [ -f \$HOME/cognipilot/ws/cerebri/install/setup.sh ]; then
  #echo cerebri built, sourcing
  source \$HOME/cognipilot/ws/cerebri/install/setup.sh
fi
if [ -f \$HOME/cognipilot/electrode/install/setup.sh ]; then
  #echo electrode built, sourcing
  source \$HOME/cognipilot/electrode/install/setup.sh
fi
source /usr/share/colcon_cd/function/colcon_cd.sh
source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash
if [ -d /opt/poetry/bin ] ; then
  PATH="/opt/poetry/bin:\$PATH"
fi
export POETRY_VIRTUALENVS_PATH=~/cognipilot/.poetry
export POETRY_VIRTUALENVS_OPTIONS_SYSTEM_SITE_PACKAGES=true
export ROS_DOMAIN_ID=7
export CMAKE_EXPORT_COMPILE_COMMANDS=ON
export CCACHE_TEMPDIR=/tmp/ccache
export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
export PYTHONWARNINGS=ignore:::setuptools.installer,ignore:::setuptools.command.install,ignore:::setuptools.command.easy_install
EOF
fi

# native specific install
if [ $SCRIPT_MODE = "native" ]; then

  # setup systemd for zeth
  if ! [ -f  /etc/systemd/system/zeth-vlan.service ]
  then
    sudo cp ~/cognipilot/helmet/install/resources/zeth-vlan.service /etc/systemd/system
    sudo chmod 664 /etc/systemd/system/zeth-vlan.service
    sudo systemctl daemon-reload
    sudo systemctl enable zeth-vlan.service
    sudo systemctl start zeth-vlan.service
  fi

  # create cognipilot directory
  mkdir -p ~/cognipilot

# docker specific install
elif [ $SCRIPT_MODE = "docker" ]; then

  # remove plugins that don't work on docker for terminator
  sudo rm -rf /usr/lib/python3/dist-packages/terminatorlib/plugins/activitywatch.py
  sudo rm -rf /usr/lib/python3/dist-packages/terminatorlib/plugins/command_notify.py

  # append more config to .bashrc for docker
  if ! grep -qF "COGNIPILOT_DOCKER_SETUP" ~/.bashrc; then
  cat << EOF >> ~/.bashrc
# COGNIPILOT_DOCKER_SETUP
export GEN_CERT=yes
export SHELL=/bin/bash
export XDG_RUNTIME_DIR=/tmp/runtime-user
export NO_AT_BRIDGE=1
eval \`keychain -q --eval --agents "gpg,ssh"\`
EOF

  fi
fi

# vi: ts=2 sw=2 et
