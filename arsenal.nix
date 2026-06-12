{
  config,
  pkgs,
  inputs,
  ...
}: {
  # ==============================================================
  # CONFIGURAÇÕES DO SISTEMA (KDE PIM & SEGURANÇA)
  # ==============================================================

  # 1. Habilita a suíte de produtividade do KDE (inclui KMail, Akonadi, KOrganizer)
  programs.kde-pim.enable = true;

  # 2. Ative o KWallet para guardar as senhas de e-mail de forma segura
  security.pam.services.kwallet.enable = true;

  # ==============================================================
  # ARSENAL LOKUTTARA (Módulo Isolado de Pacotes)
  # ==============================================================
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    protonvpn-gui
    chromium
    brave
    telegram-desktop
    ayugram-desktop
    kotatogram-desktop
    tesseract # OCR local — Fase 1.5 da Missão Pentagrama (Para incorporação do Telegram na Orchestra)
    git
    age # Criptografia moderna para segredos do pipeline
    (pass.withExtensions (exts: [exts.pass-otp])) # Cofre de senhas Unix-style + TOTP (2FA GitHub)
    gnupg # Motor GPG — cofre pessoal pass/QtPass (Vijjā 20260611)
    codex # OpenAI Codex CLI (consome créditos Codex workspace)
    # Playwright com libs NixOS para notebooklm-py
    playwright-driver.browsers
    obsidian
    qtpass #pendente de estratégia de configuração
    sshfs #Monta sistemas de arquivos remotos via SSH
    ffmpeg # Pipeline de áudio/vídeo DoDiDha (Opção C)
    pciutils # lspci — diagnóstico de hardware PCI
    usbutils # lsusb — já que estamos nisso
    smartmontools # smartctl — saúde S.M.A.R.T. dos discos
    f3 # fight flash fraud — valida capacidade real de pendrives/HDs USB
    mpv # O motor — minimalista, zero telemetria
    haruna # Interface KDE para o mpv (integra com Plasma)
    vlc # alternativa canivete-suíço, se preferir
    lm_sensors

    # Gerenciador de chaves GPG do KDE para o KMail (NixOS 25.11)
    kdePackages.kleopatra
    kdePackages.kmail
    kdePackages.kmail-account-wizard
    kdePackages.kidentitymanagement
    kdePackages.kontact # <-- O ambiente unificado de comunicação do KDE

    # ==============================================================
    # ORÁCULO DA LINHA DE COMANDO (Claude Code)
    # ==============================================================
    inputs.nix-claude-code.packages.x86_64-linux.default

    # NOVAS ARMAS DO SPRINT:
    micro # Editor de terminal puro, entende Ctrl+C, Ctrl+V e o Mouse! Sem curva de aprendizado.

    # vscodium # O editor visual de código livre de telemetria.
    vscodium-fhs # <-- TROQUE "vscodium" POR "vscodium-fhs" AQUI! (A Bolha FHS que engana as extensões!)

    # A INTELIGÊNCIA DO NIXOS (Para o VSCodium conversar com o código):
    nil # Servidor de linguagem (LSP) para o VSCodium entender o que é Nix.
    alejandra # O "Monge da Faxina" - um formatador que deixa seu código lindo automaticamente.

    # A CHAVE DO GUARDIÃO DOS PORTÕES (Para o MikroTik)
    winbox

    # ==============================================================
    # O PORTAL PUREDHAMMA (O Mosteiro Isolado com Abas - Corrigido)
    # ==============================================================

    # 1. O Script Puro: A lógica de isolamento roda aqui, sem quebrar as regras de texto.
    (writeShellScriptBin "portal-puredhamma" ''
      exec ${pkgs.chromium}/bin/chromium --user-data-dir="$HOME/.puredhamma-profile" "https://puredhamma.net"
    '')

    # 2. O Ícone Visual: O atalho do menu que apenas chama o script puro.
    (makeDesktopItem {
      name = "PortalPureDhamma";
      desktopName = "Santuário PureDhamma";
      exec = "portal-puredhamma";
      icon = "applications-internet";
      comment = "Acesso direto e isolado aos textos do Prof. Debugatti com abas";
      categories = ["Education" "Spirituality"];
    })

    # ==============================================================
    # DIÁRIO CÓSMICO (Script Customizado para #SyncSong)
    # ==============================================================
    (pkgs.writeShellScriptBin "syncsong" ''
      # Cria o texto formatado com a data e hora do sistema
      REGISTRO="- [#SyncSong = $1] - Registrado em: $(date '+%Y-%m-%d %H:%M:%S')"

      # Salva o texto dentro de um arquivo markdown na sua pasta pessoal
      echo "$REGISTRO" >> $HOME/Diario_SyncSongs.md

      # Retorna uma mensagem de paz no terminal
      echo "✨ Sincronicidade ancorada com sucesso no Diario_SyncSongs.md!"
    '')

    # ==============================================================
    # O MOTOR PYTHON E O LABORATÓRIO JUPYTER
    # ==============================================================
    (python3.withPackages (ps: [
      ps.ipykernel # [KHEMĀ] A ponte para o VSCodium descobrir nosso Kernel.
      ps.jupyter # [KHEMĀ] O ecossistema Jupyter.
      ps.pandas # [KHEMĀ] Ferramenta essencial para análise de dados.
      ps.numpy # [KHEMĀ] Ferramenta essencial para computação numérica.
      ps.langchain
      ps.chromadb
      ps.sentence-transformers
    ]))
  ];
}
