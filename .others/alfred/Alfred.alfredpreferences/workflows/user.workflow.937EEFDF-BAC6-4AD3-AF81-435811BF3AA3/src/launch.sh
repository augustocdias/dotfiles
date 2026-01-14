#!/bin/zsh --no-rcs

if command -v swiftc &>/dev/null; then
	[[ -f ./src/ColorPicker ]] || $(swiftc ./src/ColorPicker.swift -o ./src/ColorPicker)
    echo >&2 "[INFO] Running Binary"
    ./src/ColorPicker
	#$HOME$DEV
else
    echo >&2 "[INFO] Running Script"
    swift ./src/ColorPicker.swift
fi