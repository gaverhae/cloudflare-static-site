let
  pkgs = import ./nix/nixpkgs.nix;
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    bash
    curl
    imagemagick
    jq
    nodejs
    opentofu
    wrangler
  ];
}
