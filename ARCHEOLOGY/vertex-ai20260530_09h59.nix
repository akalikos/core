{
  config,
  pkgs,
  ...
}: {
  # ==============================================================
  # INFRAESTRUTURA DE IA LOKUTTARA (Saindo da Caixa do Google)
  # LiteLLM Proxy + OpenWebUI isolados via Podman Containers
  # ==============================================================

  # Adiciona as ferramentas do Google Cloud ao seu Arsenal
  environment.systemPackages = with pkgs; [
    google-cloud-sdk
    podman-compose
  ];

  # Habilita o motor de Contêineres (Podman - Mais seguro e leve que Docker)
  virtualisation.podman = {
    enable = true;
    dockerCompat = true; # Permite que comandos Docker funcionem no Podman
    defaultNetwork.settings.dns_enabled = true;
  };

  # ==============================================================
  # CONTÊINER 1: O COFRE (LiteLLM)
  # Traduz as requisições e protege o orçamento do Dhamma Dana
  # ==============================================================
  virtualisation.oci-containers.containers.litellm = {
    image = "ghcr.io/berriai/litellm:main-latest";
    ports = ["4000:4000"];

    # Monta a chave do Google Cloud dentro do contêiner em modo leitura
    volumes = [
      "/var/secrets/gcp-key.json:/app/gcp-key.json:ro"
    ];

    # Aponta as variáveis de ambiente para a chave do Vertex AI
    environment = {
      GOOGLE_APPLICATION_CREDENTIALS = "/app/gcp-key.json";
      # O ID do seu projeto que você me enviou na foto:
      VERTEX_PROJECT = "dhammadana--grin-497813-b7";
      VERTEX_LOCATION = "us-central1";
    };

    # Inicia o proxy na porta 4000 escutando para o mundo externo (0.0.0.0)
    cmd = [
      "--model"
      "vertex_ai/gemini-1.5-pro"
      "--port"
      "4000"
      "--host"
      "0.0.0.0"
      "--detailed_debug"
    ];
  };

  # ==============================================================
  # CONTÊINER 2: A INTERFACE (OpenWebUI)
  # Organização de projetos, chats e RAG sem depender do GCP Web
  # ==============================================================
  virtualisation.oci-containers.containers.openwebui = {
    image = "ghcr.io/open-webui/open-webui:main";
    ports = ["3000:8080"];

    # Volumes para não perder os seus históricos de chat ao reiniciar
    volumes = [
      "/var/lib/openwebui:/app/backend/data"
    ];

    # Conecta o OpenWebUI diretamente ao nosso cofre (LiteLLM)
    environment = {
      # CURA DA REDE: 'host.containers.internal' é a ponte para enxergar o iMac pelo contêiner!
      OPENAI_API_BASE_URL = "http://host.containers.internal:4000/v1";
      OPENAI_API_KEY = "sk-lokuttara-key";
      WEBUI_AUTH = "False";
    };

    # Injeta a regra no Podman para habilitar a ponte de rede
    extraOptions = [
      "--add-host=host.containers.internal:host-gateway"
    ];
  };
}
