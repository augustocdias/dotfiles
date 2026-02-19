{...}: {
  xdg.configFile."stylua.toml".text = ''
    indent_type = "Spaces"
    quote_style = "AutoPreferSingle"
  '';
}
