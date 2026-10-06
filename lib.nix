{ lib }:

let
  inherit (builtins) attrNames pathExists readDir;

  joinName = prefix: name: if prefix == "" then name else "${prefix}-${name}";

  selectedEntries =
    {
      dir,
      prefix ? "",
    }:
    let
      entries = readDir dir;
      names = lib.sort builtins.lessThan (attrNames entries);
    in
    lib.concatMap (
      name:
      let
        path = dir + "/${name}";
        type = entries.${name};
      in
      if lib.hasPrefix "_" name then
        [ ]
      else if type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix" then
        [
          {
            name = joinName prefix (lib.removeSuffix ".nix" name);
            inherit path;
          }
        ]
      else if type == "directory" then
        if pathExists (path + "/default.nix") then
          [
            {
              name = joinName prefix name;
              path = path + "/default.nix";
            }
          ]
        else
          selectedEntries {
            dir = path;
            prefix = joinName prefix name;
          }
      else
        [ ]
    ) names;

  checkedEntries =
    dir:
    let
      entries = selectedEntries { inherit dir; };
      grouped = lib.groupBy (entry: entry.name) entries;
      duplicates = lib.filterAttrs (_: matches: builtins.length matches > 1) grouped;

      formatDuplicate =
        name: matches: "${name}: ${lib.concatStringsSep ", " (map (entry: toString entry.path) matches)}";
    in
    if duplicates == { } then
      entries
    else
      throw ''
        Duplicate generated module names:
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList formatDuplicate duplicates)}
      '';
in
{
  paths =
    dir: act:
    lib.listToAttrs (
      map (entry: {
        inherit (entry) name;
        value = act entry.path;
      }) (checkedEntries dir)
    );

  perSystem =
    nixpkgs: systems: f:
    nixpkgs.lib.genAttrs systems (system: f (import nixpkgs { inherit system; }));
}
