{ pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [ gh ];

    sessionVariables = {
      GH_TELEMETRY = "0";
    };

    shellAliases = {
      gs = "git status --short --branch";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gpu = "git pull";
      gd = "git diff";
      gdt = "git difftool";
      gl = "git log --oneline -6";
      gi = "git diff --stat";
      gb = "git branch";
      gch = "git checkout";
      gm = "git merge";
    };
  };

  programs.git = {
    enable = true;
    config = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      user = {
        name = "ozozka";
        email = "ozkaya.ogzhn@gmail.com";
      };

      diff.tool = "nvimdiff";
      difftool.nvimdiff.cmd = ''nvim -d "$LOCAL" "$REMOTE"'';
      difftool = {
        prompt = false;
        trustExitCode = true;
      };

      merge.tool = "nvimdiff";
      mergetool.nvimdiff.cmd = ''nvim -d "$LOCAL" "$BASE" "$REMOTE" "$MERGED"'';
      mergetool = {
        prompt = false;
      };
    };
  };
}
