{ nixpkgs ? <nixpkgs> }:

let bootstrap_pkgs = import nixpkgs {};
in {
  pkgs = bootstrap_pkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    # Belong to the branch release-19.03
    rev = "67bc63f9a7ac1b4d1a7114c88ca1a4df03bfdb0e";
    sha256 = "0jzy9kd81dz1v0by3h0znz3z6bmpll3ssza5i5f14j2q54ib145g";};
  }
