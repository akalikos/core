{
  description = "Nave-Mãe McBoxGyver - O OS do Dhamma";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  # A Saída (A Arquitetura Completa da Nossa Manifestação)
  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    # Definimos um 'pkgs' para nosso sistema alvo uma única vez aqui.
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    # SAÍDA 1: A configuração do nosso Sistema Operacional
    nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
      inherit system; # Herda o sistema que definimos acima
      modules = [
        ./configuration.nix
        ./arsenal.nix
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
