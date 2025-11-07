# eurkey.nix - EURkey keyboard layout configuration
{
  pkgs,
  lib,
  ...
}: {
  # Define EURkey as a custom layout
  services.xserver.xkb.extraLayouts.eu = {
    description = "EURkey layout";
    languages = ["eng"];
    symbolsFile = pkgs.writeText "eurkey-symbols" ''
      // EURkey keyboard layout
      // https://eurkey.steffen.bruentjen.eu

      default partial alphanumeric_keys
      xkb_symbols "basic" {
          include "us(basic)"
          name[Group1]= "EURkey (US based layout with european letters)";

          // Numeric row
          key <TLDE> { [ grave,          asciitilde,    dead_grave,      dead_tilde      ] };
          key <AE01> { [ 1,              exclam,        exclamdown,      onesuperior     ] };
          key <AE02> { [ 2,              at,            twosuperior,     dead_doubleacute] };
          key <AE03> { [ 3,              numbersign,    threesuperior,   dead_macron     ] };
          key <AE04> { [ 4,              dollar,        sterling,        yen             ] };
          key <AE05> { [ 5,              percent,       EuroSign,        dead_cedilla    ] };
          key <AE06> { [ 6,              asciicircum,   dead_circumflex, dead_circumflex ] };
          key <AE07> { [ 7,              ampersand,     dead_horn,       dead_doubleacute] };
          key <AE08> { [ 8,              asterisk,      dead_ogonek,     dead_abovedot   ] };
          key <AE09> { [ 9,              parenleft,     dead_breve,      dead_grave      ] };
          key <AE10> { [ 0,              parenright,    dead_abovering,  dead_diaeresis  ] };
          key <AE11> { [ minus,          underscore,    endash,          emdash          ] };
          key <AE12> { [ equal,          plus,          multiply,        division        ] };

          // Upper row
          key <AD01> { [ q,              Q,             adiaeresis,      Adiaeresis      ] };
          key <AD02> { [ w,              W,             aring,           Aring           ] };
          key <AD03> { [ e,              E,             eacute,          Eacute          ] };
          key <AD04> { [ r,              R,             registered,      trademark       ] };
          key <AD05> { [ t,              T,             thorn,           THORN           ] };
          key <AD06> { [ y,              Y,             udiaeresis,      Udiaeresis      ] };
          key <AD07> { [ u,              U,             uacute,          Uacute          ] };
          key <AD08> { [ i,              I,             iacute,          Iacute          ] };
          key <AD09> { [ o,              O,             oacute,          Oacute          ] };
          key <AD10> { [ p,              P,             odiaeresis,      Odiaeresis      ] };
          key <AD11> { [ bracketleft,    braceleft,     guillemotleft,   leftdoublequotemark  ] };
          key <AD12> { [ bracketright,   braceright,    guillemotright,  rightdoublequotemark ] };

          // Home row
          key <AC01> { [ a,              A,             aacute,          Aacute          ] };
          key <AC02> { [ s,              S,             ssharp,          U1E9E           ] };
          key <AC03> { [ d,              D,             eth,             ETH             ] };
          key <AC04> { [ f,              F,             oe,              OE              ] };
          key <AC05> { [ g,              G,             ae,              AE              ] };
          key <AC06> { [ h,              H,             oslash,          Oslash          ] };
          key <AC07> { [ j,              J,             dead_diaeresis,  dead_abovering  ] };
          key <AC08> { [ k,              K,             dead_acute,      dead_caron      ] };
          key <AC09> { [ l,              L,             dead_stroke,     dead_doubleacute] };
          key <AC10> { [ semicolon,      colon,         paragraph,       degree          ] };
          key <AC11> { [ apostrophe,     quotedbl,      dead_acute,      dead_diaeresis  ] };

          // Lower row
          key <AB01> { [ z,              Z,             agrave,          Agrave          ] };
          key <AB02> { [ x,              X,             dead_currency,   cent            ] };
          key <AB03> { [ c,              C,             ccedilla,        Ccedilla        ] };
          key <AB04> { [ v,              V,             oe,              OE              ] };
          key <AB05> { [ b,              B,             dead_belowdot,   leftarrow       ] };
          key <AB06> { [ n,              N,             ntilde,          Ntilde          ] };
          key <AB07> { [ m,              M,             mu,              masculine       ] };
          key <AB08> { [ comma,          less,          lessthanequal,   guillemotleft   ] };
          key <AB09> { [ period,         greater,       greaterthanequal,guillemotright  ] };
          key <AB10> { [ slash,          question,      questiondown,    dead_hook       ] };

          include "level3(ralt_switch)"
      };
    '';
  };

  # Set EURkey as the default layout
  services.xserver.xkb = {
    layout = "eu";
    options = "";
  };

  # Also set for console (approximation, will be EURkey in graphical)
  console.keyMap = "us";
}
