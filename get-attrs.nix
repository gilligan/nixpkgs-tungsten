{ pkgs ? import <nixpkgs> {} }: 
let
  inherit (pkgs) lib;
  contrailVersions = [ "contrail32" "contrail41" "contrail50" ];
  jobset = import ./jobset.nix {};
  prefixWith = prefix: xs: map (x: "${prefix}.${x}") xs;
  general = lib.subtractLists ["contrail32" "contrail41" "contrail50"]  (lib.attrNames jobset);
  contrail32 = prefixWith "contrail32" (lib.attrNames jobset."contrail32");
  contrail41 = prefixWith "contrail41" (lib.attrNames jobset."contrail41");
  contrail50 = prefixWith "contrail50" (lib.attrNames jobset."contrail50");
  contrail32Tests = prefixWith "contrail32.test" (lib.attrNames jobset.contrail32.test);
  contrail41Tests = prefixWith "contrail41.test" (lib.attrNames jobset.contrail41.test);
  contrail50Tests = prefixWith "contrail50.test" (lib.attrNames jobset.contrail50.test);
in
  {
    all = general ++ contrail32 ++ contrail41 ++ contrail50;
    tests = contrail32Tests ++ contrail41Tests ++ contrail50Tests;
  }
