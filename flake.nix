{
  description = "Nave-Mãe McBoxGyver - O OS do Dhamma";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nix-claude-code.url = "github:ryoppippi/nix-claude-code";
  };

  # A Saída (A Arquitetura Completa da Nossa Manifestação)
  outputs = {
    self,
    nixpkgs,
    nix-claude-code,
    ...
  } @ inputs: let
    # Definimos um 'pkgs' para nosso sistema alvo uma única vez aqui.
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    # SAÍDA 1: A configuração do nosso Sistema Operacional
    nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
      inherit system; # Herda o sistema que definimos acima
      specialArgs = {inherit inputs;};
      modules = [
        ./configuration.nix
        # ./arsenal.nix # já é importado dentro do configuration.nix
        ./vertex-ai.nix
      ];
    };

    # SAÍDAS 2 e 3: Ambientes de desenvolvimento
    devShells.${system} = {
      default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          nil
          alejandra
          git
        ];
      };

      dodidha = let
        browsers = (builtins.fromJSON (builtins.readFile "${pkgs.playwright-driver}/browsers.json")).browsers;
        chromium-rev = (builtins.head (builtins.filter (x: x.name == "chromium") browsers)).revision;
      in
        pkgs.mkShell {
          buildInputs = with pkgs; [
            python3
            playwright-driver.browsers
          ];
          shellHook = ''
            export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
            export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=true
            export PLAYWRIGHT_HOST_PLATFORM_OVERRIDE="ubuntu-24.04"
            export PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH="${pkgs.playwright-driver.browsers}/chromium-${chromium-rev}/chrome-linux64/chrome"
            echo "Chromium do Nix: $PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH"
          '';
        };
    };
  };
}
