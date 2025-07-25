# .zshenv is sourced both in login and interactive shells
# session variables
export XDG_CONFIG_HOME="$HOME/.config"

export EDITOR="nvim"
export REACT_EDITOR="nvim"

# used to tell lazygit to use delta as pager (https://github.com/jesseduffield/lazygit/blob/master/docs/Custom_Pagers.md#using-git-config)
export GIT_PAGER="delta"

# remove the direnv log when cd
export DIRENV_LOG_FORMAT=""

# override the default starship config path
export STARSHIP_CONFIG="$HOME/.config/starship/config.toml"

# set the docker host to the colima socket
export DOCKER_HOST="unix://$HOME/.config/colima/docker.sock"

# load session variables from home-manager
. "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh"