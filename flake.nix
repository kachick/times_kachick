{
  inputs = {
    # Candidate channels
    #   - https://github.com/kachick/anylang-template/issues/17
    #   - https://discourse.nixos.org/t/differences-between-nix-channels/13998
    # How to update the revision
    #   - `nix flake update --commit-lock-file` # https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake-update.html
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs =
    { self, nixpkgs }:
    let
      # Candidates: https://github.com/NixOS/nixpkgs/blob/release-23.11/lib/systems/flake-systems.nix
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        # I don't have M1+ mac, providing this for macos-14 free runner https://github.com/actions/runner-images/issues/9741
        "aarch64-darwin"
      ];
    in
    {
      # Q. Why nixfmt? Not nixpkgs-fmt and alejandra?
      # A. nixfmt will be official
      # - https://github.com/NixOS/nixfmt/issues/153
      # - https://github.com/NixOS/nixfmt/issues/129
      # - https://github.com/NixOS/rfcs/pull/166
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default =
            with pkgs;
            mkShell {
              buildInputs = [
                # https://github.com/NixOS/nix/issues/730#issuecomment-162323824
                # https://github.com/kachick/dotfiles/pull/228
                bashInteractive
                findutils # xargs
                nixfmt-rfc-style
                nil

                dprint
                typos
              ];
            };
        }
      );
    };
}
