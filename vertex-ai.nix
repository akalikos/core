{
  config,
  pkgs,
  ...
}: {
  # ==============================================================
  # INFRAESTRUTURA DE IA LOKUTTARA (Saindo da Caixa do Google)
  # LiteLLM Proxy + OpenWebUI isolados via Podman Containers
  # ==============================================================

  environment.systemPackages = with pkgs; [
    google-cloud-sdk
    podman-compose
  ];

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # ==============================================================
  # O CÉREBRO DO ROTEADOR (O Mapa de Modelos do LiteLLM)
  # O NixOS cria este arquivo fisicamente em /etc/litellm_config.yaml
  # ==============================================================
  environment.etc."litellm_config.yaml".text = ''
    model_list:
      - model_name: gemini-2.5-pro
        litellm_params:
          model: vertex_ai/gemini-2.5-pro

      - model_name: gemini-3.1-pro
        litellm_params:
          model: vertex_ai/gemini-3.1-pro-preview

      - model_name: claude-sonnet-4-6
        litellm_params:
          model: anthropic/claude-sonnet-4-6
          api_key: "os.environ/ANTHROPIC_API_KEY"

      - model_name: claude-opus-4-6
        litellm_params:
          model: anthropic/claude-opus-4-6
          api_key: "os.environ/ANTHROPIC_API_KEY"

      # Os modelos abaixo serão para quando assinar créditos em platform.openai.com, que são diferntes da CodeX que usa login ChatGPT (20260602_14h58)
      #- model_name: gpt-4o
      #  litellm_params:
      #    model: openai/gpt-4o
      #    api_key: "os.environ/OPENAI_API_KEY"

      # - model_name: o4-mini
      #  litellm_params:
      #    model: openai/o4-mini
      #    api_key: "os.environ/OPENAI_API_KEY"

    general_settings:
      master_key: "os.environ/LITELLM_MASTER_KEY"
  '';

  # ==============================================================
  # DECRIPTADOR DE SEGREDOS (tmpfs — nunca toca o disco)
  # Roda antes do LiteLLM subir
  # ==============================================================
  systemd.services.age-decrypt-secrets = {
    description = "Decripta segredos age para tmpfs";
    before = ["podman-litellm.service" "podman-openwebui.service"];
    wantedBy = ["podman-litellm.service" "podman-openwebui.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "decrypt-secrets" ''
        mkdir -p /run/secrets
        chmod 700 /run/secrets

        # OpenAI (quando ativar platform.openai.com)
        echo -n "OPENAI_API_KEY=" > /run/secrets/openai-api-key-env
        ${pkgs.age}/bin/age -d \
          -i /home/imac2014/.age-key.txt \
          /home/imac2014/.password-store/axis/openai-key.age \
          >> /run/secrets/openai-api-key-env
        chmod 600 /run/secrets/openai-api-key-env

        # Anthropic Claude
        echo -n "ANTHROPIC_API_KEY=" > /run/secrets/anthropic-key-env
        ${pkgs.age}/bin/age -d \
          -i /home/imac2014/.age-key.txt \
          /home/imac2014/.password-store/axis/anthropic-key.age \
          >> /run/secrets/anthropic-key-env
        chmod 600 /run/secrets/anthropic-key-env

        # LiteLLM master key (auth do proxy)
        echo -n "LITELLM_MASTER_KEY=" > /run/secrets/litellm-master-key-env
        ${pkgs.age}/bin/age -d \
          -i /home/imac2014/.age-key.txt \
          /home/imac2014/.password-store/axis/litellm-master-key.age \
          >> /run/secrets/litellm-master-key-env
        chmod 600 /run/secrets/litellm-master-key-env

        # Mesma chave, nome de variável que o OpenWebUI espera
        echo -n "OPENAI_API_KEY=" > /run/secrets/openwebui-litellm-key-env
        ${pkgs.age}/bin/age -d \
          -i /home/imac2014/.age-key.txt \
          /home/imac2014/.password-store/axis/litellm-master-key.age \
          >> /run/secrets/openwebui-litellm-key-env
        chmod 600 /run/secrets/openwebui-litellm-key-env
      '';
    };
  };

  # ==============================================================
  # CONTÊINER 1: O COFRE (LiteLLM)
  # ==============================================================
  virtualisation.oci-containers.containers.litellm = {
    image = "ghcr.io/berriai/litellm:main-latest";
    ports = ["4000:4000"];

    # O contêiner agora lê a chave do Google E a Tábua de Roteamento!
    volumes = [
      "/var/secrets/gcp-key.json:/app/gcp-key.json:ro"
      "/etc/litellm_config.yaml:/app/config.yaml:ro"
    ];
    environmentFiles = [
      "/run/secrets/openai-api-key-env" # OpenAI (futuro)
      "/run/secrets/anthropic-key-env" # Claude (ativo)
      "/run/secrets/litellm-master-key-env" # Auth do proxy (master_key)
    ];
    environment = {
      GOOGLE_APPLICATION_CREDENTIALS = "/app/gcp-key.json";
      VERTEX_PROJECT = "dhammadana--grin-497813-b7";
      VERTEX_LOCATION = "us-central1";
    };
    extraOptions = [
      # ← ADICIONAR ISSO
      "--dns=8.8.8.8"
      "--dns=8.8.4.4"
    ];

    # Inicia o proxy escutando para fora (0.0.0.0) e lendo o arquivo yaml
    cmd = [
      "--config"
      "/app/config.yaml"
      "--port"
      "4000"
      "--host"
      "0.0.0.0"
      "--detailed_debug"
    ];
  };

  # ==============================================================
  # CONTÊINER 2: A INTERFACE (OpenWebUI)
  # ==============================================================
  virtualisation.oci-containers.containers.openwebui = {
    image = "ghcr.io/open-webui/open-webui:main";
    ports = ["3000:8080"];
    volumes = [
      "/var/lib/openwebui:/app/backend/data"
    ];
    environmentFiles = [
      "/run/secrets/openwebui-litellm-key-env" # OPENAI_API_KEY = master key do LiteLLM
    ];
    environment = {
      OPENAI_API_BASE_URL = "http://host.containers.internal:4000/v1";
      WEBUI_AUTH = "True";

      GOOGLE_APPLICATION_CREDENTIALS = "/app/gcp-key.json";
      VERTEX_PROJECT = "dhammadana--grin-497813-b7";
      VERTEX_LOCATION = "us-central1";
    };
    extraOptions = [
      "--add-host=host.containers.internal:host-gateway"
    ];
  };
}
