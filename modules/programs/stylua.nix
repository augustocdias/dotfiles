{den, ...}: {
  den.aspects.stylua = {
    homeManager = _: {
      xdg.configFile."stylua.toml".text = ''
        indent_type = "Spaces"
        quote_style = "AutoPreferSingle"
      '';
    };
  };
}
