#!/bin/zsh -f

readonly paths=("$@")
local output="{\"items\":["

for path in "${paths[@]}"; do
	local hex="#$path:t:r" # last path component w/o extension
	output+="{\"title\":\"$hex\",\"arg\":\"$hex\",\"icon\":{\"path\":\"$path\"},\"action\":{\"file\":\"$path\"},\"type\":\"file:skipcheck\",\"text\":{\"copy\":\"${hex}\",\"largetype\":\"$hex\"}},"
done

output=${output%?} # drop last comma
output+="]}"
echo -n $output