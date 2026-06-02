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

    # SAÍDA 2: A sala de desenvolvimento da Dra. KhemāDev
    devShells.${system}.default = pkgs.mkShell {
      nativeBuildInputs = with pkgs; [
        nil
        alejandra
        git
      ];
    };
  };
}
