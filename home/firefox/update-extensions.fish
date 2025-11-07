#!/usr/bin/env fish
# Update Firefox extension URLs and addon IDs from Mozilla API

set -l GREEN '\033[0;32m'
set -l BLUE '\033[0;34m'
set -l RED '\033[0;31m'
set -l NC '\033[0m'

set -l rebuild false
for arg in $argv
    switch $arg
        case -r --rebuild
            set rebuild true
        case -h --help
            echo "Usage: firefox-update [-r|--rebuild]"
            exit 0
    end
end

echo -e $BLUE"Updating Firefox extensions..."$NC

set json_file "$HOME/nixos/home/firefox/extensions.json"
set temp_dir (mktemp -d)

function cleanup --on-event fish_exit
    rm -rf $temp_dir
end

set extensions (jq -r 'keys[]' $json_file | sort)

function fetch_ext
    set -l ext $argv[1]
    set -l json_file $argv[2]
    set -l temp_dir $argv[3]

    set -l slug (jq -r ".\"$ext\".slug" $json_file)
    set -l api (curl -s "https://addons.mozilla.org/api/v5/addons/addon/$slug/")
    set -l ext_url (echo $api | jq -r '.current_version.file.url')
    set -l ext_id (echo $api | jq -r '.guid')
    set -l ext_ver (echo $api | jq -r '.current_version.version')

    if test "$ext_url" = null -o -z "$ext_url"
        touch $temp_dir/$ext.fail
        return 1
    end

    echo "url=$ext_url" >$temp_dir/$ext.result
    echo "addonId=$ext_id" >>$temp_dir/$ext.result
    echo "  $ext ($ext_ver)"
end

for ext in $extensions
    fetch_ext $ext $json_file $temp_dir &
end
wait

for ext in $extensions
    if test -f $temp_dir/$ext.fail
        echo -e $RED"Failed to fetch $ext"$NC
        exit 1
    end
end

# Update JSON
set temp_json "$temp_dir/extensions.json"
cp $json_file $temp_json
for ext in $extensions
    set -l ext_url (grep "^url=" $temp_dir/$ext.result | cut -d= -f2-)
    set -l ext_id (grep "^addonId=" $temp_dir/$ext.result | cut -d= -f2-)
    jq ".\"$ext\".url = \"$ext_url\" | .\"$ext\".addonId = \"$ext_id\"" $temp_json >$temp_dir/tmp.json
    mv $temp_dir/tmp.json $temp_json
end
mv $temp_json $json_file

echo -e $GREEN"Done!"$NC

if test $rebuild = true
    sudo nixos-rebuild switch --flake ~/nixos
else
    echo "Run: sudo nixos-rebuild switch --flake ~/nixos"
end
