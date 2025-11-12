#!/run/current-system/sw/bin/fish

set USERNAME $argv[1]

homectl create $USERNAME --real-name="$USERNAME" --member-of=wheel --shell=/run/current-system/sw/bin/fish --storage=luks

# Get user's home directory
set USER_HOME (homectl inspect "$USERNAME" -j | jq -r ".binding | .[keys_unsorted[0]].homeDirectory")

homectl with $USERNAME -- rsync -arHAXv --remove-source-files /opt/home/ $USER_HOME

# Copy dotfiles to user home
cp -r /opt/first-boot-setup/dotfiles "$USER_HOME/.dotfiles"

# Run stow to create symlinks
cd "$USER_HOME/.dotfiles"
set HOME $USER_HOME
stow .

# Set ownership
set USER_ID (id -u "$USERNAME")
set USER_GID (id -g "$USERNAME")
chown -R "$USER_ID:$USER_GID" "$USER_HOME"

# Clean up
rm -rf /opt/first-boot-setup
rm -rf /opt/home
rm -f /opt/first-boot-setup.fish
