#!/usr/bin/env fish
# Update Raycast extension SHA256 hashes
# Vicinae native extensions don't need hashes (from flake)

# Parse arguments
set -l REBUILD false
set -l HELP false

for arg in $argv
    switch $arg
        case -r --rebuild
            set REBUILD true
        case -h --help
            set HELP true
        case '*'
            set_color red
            echo "Unknown option: $arg"
            set_color normal
            set HELP true
    end
end

if test "$HELP" = true
    echo "Usage: vicinae-update [options]"
    echo ""
    echo "Update Raycast extension SHA256 hashes"
    echo "(Vicinae native extensions come from flake, no hashes needed)"
    echo ""
    echo "Options:"
    echo "  -r, --rebuild    Rebuild NixOS configuration after updating"
    echo "  -h, --help       Show this help message"
    exit 0
end

# Paths to dotfiles
set dotfiles_dir "$HOME/nixos"
set json_file "$dotfiles_dir/home/vicinae/extensions.json"
set nix_file "$dotfiles_dir/home/vicinae/extensions.nix"

set_color blue
echo "Updating Raycast extension SHA256 hashes..."
set_color normal
echo ""

# Create temp directory for parallel results
set temp_dir (mktemp -d)
trap "rm -rf $temp_dir" EXIT

# Get Raycast extension names from JSON
set raycast_extensions (jq -r '.raycast | keys[]' $json_file | sort)
set raycast_count (count $raycast_extensions)

echo "Fetching $raycast_count Raycast extension hashes..."

# Function to fetch a Raycast extension's sha from GitHub sparse checkout
function fetch_raycast_sha
    set ext_name $argv[1]
    set json_file $argv[2]
    set temp_dir $argv[3]

    set result_file "$temp_dir/$ext_name.result"
    set error_file "$temp_dir/$ext_name.error"

    # Get rev from JSON (default to main)
    set rev (jq -r ".raycast.\"$ext_name\".rev // \"main\"" $json_file)

    # Use nix to compute the hash with sparse checkout
    set nix_expr "
      let
        pkgs = import <nixpkgs> {};
      in
        pkgs.fetchFromGitHub {
          owner = \"raycast\";
          repo = \"extensions\";
          rev = \"$rev\";
          sha256 = pkgs.lib.fakeSha256;
          sparseCheckout = [ \"/extensions/$ext_name\" ];
        }
    "

    # Try to build and get the hash from the error message
    set build_output (nix-build --no-out-link -E "$nix_expr" 2>&1)
    set sha256 (echo "$build_output" | grep -oP 'got:\s+sha256-\K[A-Za-z0-9+/=]+' | head -1)

    if test -z "$sha256"
        # Try base32 format
        set sha256 (echo "$build_output" | grep -oP 'got:\s+\K[a-z0-9]{52}' | head -1)
        if test -n "$sha256"
            # Convert to SRI format
            set sha256 (nix hash convert --to sri --hash-algo sha256 $sha256 2>/dev/null | sed 's/sha256-//')
        end
    end

    if test -z "$sha256"
        echo "Failed to fetch sha for $ext_name" >$error_file
        echo "$build_output" >>$error_file
        return 1
    end

    # Handle attribute name quoting for names with special chars
    if string match -qr '^[0-9]|[-]' $ext_name
        echo "    \"$ext_name\" = \"sha256-$sha256\";" >$result_file
    else
        echo "    $ext_name = \"sha256-$sha256\";" >$result_file
    end
    echo "  $ext_name"
    return 0
end

# Launch all Raycast fetches in parallel
for ext_name in $raycast_extensions
    fetch_raycast_sha $ext_name $json_file $temp_dir &
end

# Wait for all background jobs to complete
echo "Waiting for all fetches to complete..."
wait

# Check for errors
set errors (find $temp_dir -name "*.error" -type f)
if test (count $errors) -gt 0
    echo ""
    set_color red
    echo "Failed to fetch shas for the following extensions:"
    set_color normal
    for error_file in $errors
        echo "--- "(basename $error_file .error)" ---"
        head -5 $error_file
    end
    rm -rf $temp_dir
    exit 1
end

# Collect all results and build shas block
set temp_shas "$temp_dir/shas.txt"
echo "  shas = {" >$temp_shas

# Add Raycast extension results (sorted)
for ext_name in $raycast_extensions
    set result_file "$temp_dir/$ext_name.result"
    if test -f $result_file
        cat $result_file >>$temp_shas
    end
end

echo "  };" >>$temp_shas

# Now update the extensions.nix file
# Read the file and replace the entire shas section
set in_shas false
set temp_nix "$temp_dir/extensions_new.nix"

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

    if $in_shas
        if string match -q "*};" $line
            set in_shas false
            # Skip this line as we already added it
            continue
        else
            # Skip lines inside the old shas block
            continue
        end
    end

    echo $line >>$temp_nix
end

# Replace the original file
mv $temp_nix $nix_file

echo ""
set_color green
echo "Extension update complete!"
set_color normal
echo "Extensions updated: $raycast_count"

if test "$REBUILD" = true
    echo ""
    set_color yellow
    echo "Rebuilding Home-Manager configuration..."
    set_color normal
    ifnix run home-manager -- switch --flake ~/nixos#augusto 
        echo ""
        set_color green
        echo "System rebuild complete!"
        set_color normal
    else
        echo ""
        set_color red
        echo "System rebuild failed!"
        set_color normal
        exit 1
    end
else
    echo ""
    echo "To apply changes, run:"
    echo "  nix run home-manager -- switch --flake ~/nixos#augusto"
    echo ""
    echo "Or use: vicinae-update --rebuild"
end
