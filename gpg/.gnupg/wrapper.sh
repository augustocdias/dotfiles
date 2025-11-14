#!/usr/bin/env bash
  REAL_PINENTRY=$(which pinentry-tty)
  {
    while IFS= read -r line; do
      # Check if this is the "not a tty" line and fix it
      if [[ "$line" == "OPTION ttyname=not a tty" ]] && [[ -n "$GPG_TTY" ]]; then
        echo "OPTION ttyname=$GPG_TTY"
      else
        echo "$line"
      fi
    done
  } | {
    "$REAL_PINENTRY" "$@" 2>&1 | while IFS= read -r line; do
      echo "$line"
    done
  }
