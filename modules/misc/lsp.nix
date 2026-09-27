{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    bash-language-server
    vscode-langservers-extracted
    docker-language-server
    just-lsp
    marksman
    sqls
    yaml-language-server
  ];
}
