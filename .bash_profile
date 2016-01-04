# Load ~/.extra, ~/.bash_prompt, ~/.exports, ~/.aliases and ~/.functions
# ~/.extra can be used for settings you don’t want to commit
for file in ~/.{extra,bash_prompt,exports,aliases,functions}; do
	[ -r "$file" ] && source "$file"
done
unset file

# init z   https://github.com/rupa/z
. ~/code/z/z.sh

# init rvm
#source ~/.rvm/scripts/rvm

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# Prefer US English and use UTF-8
export LC_ALL="en_US.UTF-8"
export LANG="en_US"

export RBENV_ROOT=/usr/local/var/rbenv

export LEIN_FAST_TRAMPOLINE=y
# export SLIMERJSLAUNCHER=/opt/homebrew-cask/Caskroom/firefox/latest/Firefox.app/Contents/MacOS/firefox

export GITLAB_API_ENDPOINT=http://192.168.1.26/api/v3
export GITLAB_API_PRIVATE_TOKEN=CJ1YUpk2aFZfDs4p8sRS

if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2)" scp sftp ssh

# Add tab completion for `defaults read|write NSGlobalDomain`
# You could just use `-g` instead, but I like being explicit
complete -W "NSGlobalDomain" defaults
