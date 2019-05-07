{ pkgs ? (import ./. {}) }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    contrailIntrospectCli
    contrailApiCliWithExtra
    contrailGremlin
    gremlinChecks
    gremlinConsole
    gremlinServer
    gremlinFsck
    contrail50.lib.hydraEval
  ];
}
