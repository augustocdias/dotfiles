function wttr -d "shows the weather to a given city eg. Rio de Janeiro"
  if not type -q curl
    echo "Please install curl"
    return 5
  end
  curl -4 "wttr.in/$argv"
end
