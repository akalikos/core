# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  ...
}: {
  # ==============================================================
  # ARQUEOLOGIA LOKUTTARA: Melhorias e Personalizações da Nave
  # ==============================================================

  # Adicionado por Claude Sonnet 4.6 em 20260531_13h41:
  # Habilitar podman (já que é o que o NixOS usa)
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # Disco de dados interno (ex-Debian, SSD Apple 128GB)
  fileSystems."/mnt/dados" = {
    device = "/dev/disk/by-uuid/be2fce70-ccab-4213-853b-989eba31797b";
    fsType = "ext4";
    options = ["nofail"]; # boot não trava se o disco falhar
  };

  # Subir LibreChat automaticamente no boot
  # Adicionado por Claude Sonnet 4.6 em 20260604_13h06:
  systemd.services.librechat = {
    description = "LibreChat";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = "/home/imac2014/librechat";
      Environment = [
        "PATH=/run/current-system/sw/bin:/usr/bin:/bin"
        "XDG_RUNTIME_DIR=/run/user/1000"
      ];
      ExecStart = pkgs.writeShellScript "librechat-start" ''
        /run/current-system/sw/bin/podman-compose up -d

        echo "LibreChat boot: aguardando chat-mongodb..."
        TRIES=0
        until /run/current-system/sw/bin/podman exec chat-mongodb \
          mongosh --eval "db.runCommand({ping:1})" --quiet 2>/dev/null; do
          sleep 2
          TRIES=$((TRIES + 1))
          if [ "$TRIES" -ge 30 ]; then
            echo "Timeout aguardando MongoDB — abortando"
            exit 1
          fi
        done

        echo "MongoDB pronto! Reiniciando LibreChat..."
        sleep 2
        /run/current-system/sw/bin/podman-compose restart api
      '';
      ExecStop = "/run/current-system/sw/bin/podman-compose down";
      User = "imac2014";
    };
  };

  # Subir AnythingLLM automaticamente no boot
  systemd.services.anythingllm = {
    description = "AnythingLLM";
    after = ["network.target" "user@1000.service"];
    requires = ["user@1000.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Environment = [
        "PATH=/run/current-system/sw/bin:/usr/bin:/bin"
        "XDG_RUNTIME_DIR=/run/user/1000"
      ];
      ExecStartPre = "-/run/current-system/sw/bin/podman rm -f anythingllm";
      ExecStart = "/run/current-system/sw/bin/podman run -d --name anythingllm -p 3001:3001 -e STORAGE_DIR=/app/server/storage -v /home/imac2014/.anythingllm:/app/server/storage mintplexlabs/anythingllm";
      User = "imac2014";
    };
  };

  # ==============================================================
  # NIX-LD (Passaporte para Binários do Mundo Exterior)
  # Permite rodar executáveis compilados para Linux genérico
  # adicionado por Claude em 20260531_10h20
  # ==============================================================
  programs.nix-ld.enable = true;

  # ==============================================================
  # O TECLADO DO CHAVES (Neuroplasticidade Avançada do AkālikOS)
  # Parece Option, o Linux chama de Meta, mas tem gosto de Home!
  # ==============================================================
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = ["*"];
      settings = {
        main = {
          # O SUCO DE LIMÃO:
          # Um tapinha rápido solta um 'Tab'. Segurar funciona como 'Shift' normal.
          leftshift = "overload(shift, tab)";

          # O SUCO DE TAMARINDO:
          # A tecla física 'Option' (ao lado das setas) é lida como 'rightmeta' pelo Kernel.
          # Segurar ela ativa a nossa Camada de Navegação (nav_layer)!
          rightmeta = "layer(nav_layer)";

          # O Eject (Ressurreição mantida)
          ejectcd = "delete";
        };

        # ==============================================================
        # O GOSTO DE ABACAXI (A Camada de Navegação do Mestre)
        # Ativada ao segurar o Option Direito (Fisicamente colado nas setas)
        # ==============================================================
        nav_layer = {
          left = "home"; # Vai para o início da linha
          right = "end"; # Vai para o fim da linha
          up = "pageup"; # Sobe a página
          down = "pagedown"; # Desce a página
          backspace = "delete"; # Apaga para a frente
        };
      };
    };
  };

  # ==============================================================
  # O DESPERTAR DOS FLAKES (Imutabilidade Suprema) =)adicionado por Khemā em 20260527_20h29(=
  # ==============================================================
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # ==============================================================
  # MESTRE DO ÁUDIO E BLUETOOTH (PipeWire) =)adicionado por Khemā em 20260527_16h44(=
  # ==============================================================
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.enableRedistributableFirmware = true; # Permite os drivers nativos do Mac

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ==============================================================
  # DOMANDO O TECLADO DA APPLE (Módulo hid_apple)
  # ==============================================================
  boot.extraModprobeConfig = ''
    # 1. Comportamento das teclas FN:
    # '2' significa que F1-F12 agem normalmente. Para usar brilho/volume, segure 'Fn'.
    options hid_apple fnmode=2

    # 2. Transmutação de Layout (Opcional, mas altamente recomendado):
    # '1' inverte fisicamente o Command e o Option. Assim, o Command (colado no espaço)
    # passa a agir como a tecla 'Alt', exatamente como no seu teclado Logitech K120!
    options hid_apple swap_opt_cmd=1
  '';

  # ==============================================================
  # OTIMIZAÇÃO MCBOXGYVER (Aliviando o HDD Mecânico) =)adicionado por Khemā em 20260527_16h44(=
  # ==============================================================
  boot.kernel.sysctl = {
    "vm.dirty_background_ratio" = 20;
    "vm.dirty_ratio" = 50;
    "vm.dirty_expire_centisecs" = 6000;
    "vm.dirty_writeback_centisecs" = 1000;

    # Olhos para a Forja (inotify) — adicionado por Vijjā em 20260611
    # Necessário para o VSCodium observar pastas grandes sem reclamar
    "fs.inotify.max_user_watches" = 524288;
    "fs.inotify.max_user_instances" = 1024;
  };

  # ==============================================================
  # NEKKHAMMA AUTOMÁTICO (Desapego de Gerações Antigas) =)adicionado por Khemā em 20260527_16h44(=
  # ==============================================================
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Arquivo praticamente original abaixo dessa linha (acima são as melhorias {personalização} feitas à partir de 20260527_16h44):

  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./arsenal.nix # <--- A PONTE PARA O NOSSO NOVO MÓDULO!
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 5; # Mantendo o menu visível por 5 segundos

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Select internationalisation properties.
  i18n.defaultLocale = "pt_BR.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "intl";
  };

  # Configure console keymap
  # console.keyMap = "br-abnt2"; # para o logitech K120

  # Deleta o antigo console.keyMap = "br-abnt2" e manda o terminal pregar a mesma regra da interface (para teclado A1314 Apple):
  console.useXkbConfig = true;

  # ==============================================================
  # A CURA ABSOLUTA DO CEDILHA (Reescrevendo o Dicionário XCompose)
  # ==============================================================

  # 1. Cria um Dicionário Universal no sistema interceptando o C
  environment.etc."X11/XCompose".text = ''
    include "%L"
    <dead_acute> <c> : "ç" U00E7
    <dead_acute> <C> : "Ç" U00C7
  '';

  # 2. Obriga todos os programas do Wayland, GTK e Qt a usarem o nosso Dicionário!
  environment.sessionVariables = {
    XCOMPOSEFILE = "/etc/X11/XCompose";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;

  # If you want to use JACK applications, uncomment this
  #jack.enable = true;

  # use the example session manager (no others are packaged yet so this is enabled by default,
  # no need to redefine it in your config for now)
  #media-session.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.imac2014 = {
    isNormalUser = true;
    description = "iMac2014";
    extraGroups = ["networkmanager" "wheel"];
    packages = with pkgs; [
      kdePackages.kate
      #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = false; # SSH continua com as chaves id_ed25519/id_matikamata de sempre
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
