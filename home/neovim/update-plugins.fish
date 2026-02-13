#!/usr/bin/env fish
# Update Neovim plugin SHA256 hashes automatically

# Colors
set -l RED '\033[0;31m'
set -l GREEN '\033[0;32m'
set -l BLUE '\033[0;34m'
set -l YELLOW '\033[0;33m'
set -l NC '\033[0m'

# Parse arguments
set -l rebuild false
set -l show_help false
set -l update_tags false

for arg in $argv
    switch $arg
        case -r --rebuild
            set rebuild true
        case -t --update-tags
            set update_tags true
        case -h --help
            set show_help true
        case '*'
            echo -e $RED"Unknown option: $arg"$NC
            set show_help true
    end
end

if test $show_help = true
    echo "Usage: nvim-update [options]"
    echo ""
    echo "Update Neovim plugin SHA256 hashes"
    echo ""
    echo "Options:"
    echo "  -t, --update-tags  Update plugins with binary field to latest release tag"
    echo "  -r, --rebuild      Rebuild NixOS configuration after updating"
    echo "  -h, --help         Show this help message"
    exit 0
end

echo -e $BLUE"🔄 Updating Neovim plugins..."$NC
echo ""

# Paths to dotfiles
set dotfiles_dir "$HOME/nixos"
set json_file "$dotfiles_dir/home/neovim/plugins.json"
set nix_file "$dotfiles_dir/home/neovim/plugins.nix"

# Update tags for plugins with binary field if requested
if test $update_tags = true
    echo -e $YELLOW"🏷️  Updating plugin tags..."$NC

    # Get plugins with binary field
    set binary_plugins (jq -r 'to_entries[] | select(.value.binary) | .key' $json_file)

    for plugin in $binary_plugins
        set owner (jq -r ".\"$plugin\".owner" $json_file)
        set repo (jq -r ".\"$plugin\".repo" $json_file)
        set current_tag (jq -r ".\"$plugin\".rev" $json_file)

        # Fetch latest release tag from GitHub API
        set latest_tag (curl -s "https://api.github.com/repos/$owner/$repo/releases/latest" | jq -r '.tag_name // empty')

        if test -z "$latest_tag"
            echo -e $RED"  ✗ $plugin: Failed to fetch latest tag"$NC
            continue
        end

        if test "$current_tag" = "$latest_tag"
            echo "  ✓ $plugin: Already at latest ($latest_tag)"
        else
            echo -e $GREEN"  ↑ $plugin: $current_tag → $latest_tag"$NC
            # Update the JSON file with new tag
            set tmp_json (mktemp)
            jq ".\"$plugin\".rev = \"$latest_tag\"" $json_file >$tmp_json
            mv $tmp_json $json_file
        end
    end

    echo ""
end

# Create temp directory for parallel results
set temp_dir (mktemp -d)

# Cleanup on exit
function cleanup --on-event fish_exit
    rm -rf $temp_dir
end

# Get all plugin names from JSON
set plugins (jq -r 'keys[]' $json_file | sort)
set total (count $plugins)

echo "Fetching $total plugins..."

# Function to fetch a single plugin's sha
function fetch_plugin_sha
    set plugin $argv[1]
    set json_file $argv[2]
    set temp_dir $argv[3]

    set result_file "$temp_dir/$plugin.result"
    set error_file "$temp_dir/$plugin.error"

    # Get plugin info from JSON
    set owner (jq -r ".\"$plugin\".owner" $json_file)
    set repo (jq -r ".\"$plugin\".repo" $json_file)
    set rev (jq -r ".\"$plugin\".rev // null" $json_file)

    # If rev is not specified, detect the default branch
    if test "$rev" = null
        # Use GitHub API to get default branch
        set default_branch (curl -s "https://api.github.com/repos/$owner/$repo" | jq -r '.default_branch // empty')

        if test -n "$default_branch"
            set rev $default_branch
        else
            # Try main first
            set test_sha (nix-prefetch-url --unpack "https://github.com/$owner/$repo/archive/main.tar.gz" 2>/dev/null)
            if test -n "$test_sha"
                set rev main
            else
                # Try master
                set test_sha (nix-prefetch-url --unpack "https://github.com/$owner/$repo/archive/master.tar.gz" 2>/dev/null)
                if test -n "$test_sha"
                    set rev master
                else
                    echo "Failed to detect branch for $plugin" >$error_file
                    return 1
                end
            end
        end
    end

    # Calculate SHA256
    set sha256 (nix-prefetch-url --unpack "https://github.com/$owner/$repo/archive/$rev.tar.gz" 2>/dev/null)

    if test -z "$sha256"
        echo "Failed to fetch source sha for $plugin" >$error_file
        return 1
    end

    # Write source sha result
    echo "    $plugin = \"$sha256\";" >$result_file

    # Check if plugin has a binary field and fetch its sha
    set has_binary (jq -r ".\"$plugin\".binary // null" $json_file)
    if test "$has_binary" != null
        set binary_filename (jq -r ".\"$plugin\".binary.filename" $json_file)
        set binary_url "https://github.com/$owner/$repo/releases/download/$rev/$binary_filename"
        set binary_sha (nix-prefetch-url "$binary_url" 2>/dev/null)

        if test -z "$binary_sha"
            echo "Failed to fetch binary sha for $plugin from $binary_url" >$error_file
            return 1
        end

        echo "    $plugin-binary = \"$binary_sha\";" >>$result_file
    end

    echo "✓ $plugin"
    return 0
end

# Launch all fetches in parallel
for plugin in $plugins
    fetch_plugin_sha $plugin $json_file $temp_dir &
end

# Wait for all background jobs to complete
echo "Waiting for all fetches to complete..."
wait

# Check for errors
set errors (find $temp_dir -name "*.error" -type f)
if test (count $errors) -gt 0
    echo ""
    echo -e $RED"❌ Failed to fetch shas for the following plugins:"$NC
    for error_file in $errors
        cat $error_file
    end
    echo -e "Check if their revisions exist"
    exit 1
end

# Collect all results and build shas block
set temp_shas "$temp_dir/shas.txt"
echo "  shas = {" >$temp_shas

# Sort and append all results
for plugin in $plugins
    set result_file "$temp_dir/$plugin.result"
    if test -f $result_file
        cat $result_file >>$temp_shas
    end
end

echo "  };" >>$temp_shas

# Now update the plugins.nix file
set in_shas false
set temp_nix "$temp_dir/plugins_new.nix"

# Clear the temp file
echo -n "" >$temp_nix

for line in (cat $nix_file)
    if string match -q "*shas = {*" $line
        set in_shas true
        echo $line >>$temp_nix
        # Add all the new shas (skip the first line which is "  shas = {")
        tail -n +2 $temp_shas >>$temp_nix
        continue
    end

    if test $in_shas = true
        if string match -q "*};" $line
            set in_shas false
            continue
        else
            continue
        end
    end

    echo $line >>$temp_nix
end

# Replace the original file
mv $temp_nix $nix_file

echo ""
echo -e $GREEN"✅ Plugin SHA256 hashes updated!"$NC

# Count plugins in JSON vs Nix to verify sync
set json_count (jq -r 'keys | length' $json_file)
set nix_count (grep -c '    .* = "' $nix_file | head -1)

echo "📊 Plugins in JSON: $json_count"
echo "📊 Plugins with SHAs: $nix_count"

if test $json_count -le $nix_count
    echo -e $GREEN"✅ All plugins synced successfully"$NC
else
    echo -e $RED"❌ Plugin count mismatch - some plugins may have failed"$NC
    exit 1
end

if test $rebuild = true
    echo ""
    echo -e $YELLOW"🔨 Rebuilding Home-Manager configuration..."$NC
    nix run home-manager -- switch --flake ~/nixos#augusto

    if test $status -eq 0
        echo ""
        echo -e $GREEN"✅ System rebuild complete!"$NC
    else
        echo ""
        echo -e $RED"❌ System rebuild failed!"$NC
        exit 1
    end
else
    echo ""
    echo "To apply changes, run:"
    echo "  nix run home-manager -- switch --flake ~/nixos#augusto"
    echo ""
    echo "Or use: nvim-update --rebuild"
end
