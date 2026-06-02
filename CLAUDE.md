# AkālikOS — Nave-Mãe McBoxGyver
> NixOS Flakes — iMac2014 — x86_64-linux — nixos-25.11

## Comandos essenciais

    cd /etc/nixos && sudo nixos-rebuild switch --flake .#
    sudo nixos-rebuild dry-build --flake /etc/nixos#nixos
    alejandra .
    nix develop /etc/nixos

## Módulos

| Arquivo | Propósito |
|---|---|
| flake.nix | Entrypoint — inputs nixpkgs + nix-claude-code |
| configuration.nix | Sistema base: boot, KDE Plasma 6, PipeWire, keyd, cedilha |
| arsenal.nix | Pacotes: browsers, vscodium-fhs, Python stack, scripts |
| vertex-ai.nix | Infra IA: LiteLLM :4000, OpenWebUI :3000, segredos age |
| hardware-configuration.nix | Auto-gerado — não editar |

## Convenções obrigatórias

- Dados: prefixo ponto (.anythingllm, .password-store)
- Código: sem ponto (librechat, axis-niddhi)
- Comentários em português com data: adicionado em YYYYMMDD_HHhMM
- Nunca remover código — comentar com motivo e data

## Orchestra de IAs

- LiteLLM :4000 — roteador (Gemini 2.5 Pro, Claude Sonnet/Opus)
- OpenWebUI :3000 — interface visual
- LibreChat :3080 — interface alternativa
- AnythingLLM :3001 — RAG PureDhamma

## Segredos

- Cofre: age + pass em ~/.password-store/axis/
- Chave privada: ~/.age-key.txt
- NUNCA escrever API keys em texto plano

## Projeto principal

- AXIS-NIDDHI — preservação PureDhamma.net (Prof. Lal)
- Pipeline: CSL → DeepL → Podcast → YouTube/Telegram
- Glossário: Dhamma (nao Karma/Budismo/Nirvana)

## ARCHEOLOGY/

Snapshots históricos — não importar nem editar.
