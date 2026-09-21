{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [ fuzzel ];

  environment.etc."xdg/fuzzel/fuzzel.ini".source = (pkgs.formats.ini { }).generate "fuzzel.ini" {
    main = {
      font = "Oziosevka:size=12";
      use-bold = true;
      placeholder = "\"\"";
      prompt = "\"\"";
      icons-enabled = true;
      match-counter = true;
      terminal = "foot  -a '{cmd}' -T '{cmd}' {cmd}";
      list-executables-in-path = false;
      anchor = "top";
      y-margin = 6;
      lines = 6;
      minimal-lines = true;
      width = 30;
      horizontal-pad = 24;
      vertical-pad = 12;
      inner-pad = 6;
      image-size-ratio = 0.3;
      line-height = "24";
    };

    colors = {
      background = "000000e0";
      text = "96929bff";
      message = "ff0000ff";
      prompt = "4e4a53ff";
      placeholder = "ccccccff";
      input = "ffffffff";
      match = "ffffffff";
      selection = "232027e0";
      selection-text = "96929bff";
      selection-match = "ffffffff";
      counter = "96929bff";
      border = "aaaaaaff";
    };

    border = {
      width = 0;
      radius = 12;
      selection-radius = 6;
    };
  };
}
