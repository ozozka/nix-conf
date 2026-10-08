{ pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [
      scc
      github-linguist
    ];

    shellAliases = {
      loc = "scc -s lines --no-size --no-cocomo && github-linguist";
      locd = "scc -s lines -a -p --sloccount-format";
      locf = "scc -s lines -a -p --sloccount-format --by-file";
    };
  };
}
