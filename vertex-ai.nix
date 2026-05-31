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
  '';

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

    environment = {
      GOOGLE_APPLICATION_CREDENTIALS = "/app/gcp-key.json";
      VERTEX_PROJECT = "dhammadana--grin-497813-b7";
      VERTEX_LOCATION = "us-central1";
    };

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
    environment = {
      OPENAI_API_BASE_URL = "http://host.containers.internal:4000/v1";
      OPENAI_API_KEY = "sk-lokuttara-key";
      WEBUI_AUTH = "False";
    };
    extraOptions = [
      "--add-host=host.containers.internal:host-gateway"
    ];
  };
}
