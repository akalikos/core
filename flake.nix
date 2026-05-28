{
  description = "Nave-Mãe McBoxGyver - O OS do Dhamma";

  # A Fonte da Verdade (O Repositório Oficial do NixOS da nossa era)
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  # A Saída (Como a Mente se manifesta no Rūpa)
  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: {
    nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        ./arsenal.nix
        # AQUI entrarão os futuros módulos do McBoxGyver!
      ];
    };
  };
}
