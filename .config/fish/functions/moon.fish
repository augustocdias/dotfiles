function moon -d "shows phase of the Moon"
  if not type -q curl
    echo "Please install curl"
    return 5
  end
  curl -s -4 "wttr.in/Moon@$argv"
end
