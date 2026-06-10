#!/usr/bin/env bash

# Este script consolida todos os arquivos .nix de um diretório em um único arquivo Markdown.

# Define o diretório de destino como o diretório onde o script está localizado.
TARGET_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Gera o nome do arquivo de saída com data e hora (YYYYMMDD_HHMM)
FILENAME="${TARGET_DIR}/All_Nix_$(date +'%Y%m%d_%Hh%M').md"

# Limpa o arquivo de saída, se existir, e adiciona um cabeçalho principal.
echo "# Compilação de Arquivos NixOS" > "$FILENAME"
echo "Gerado em: $(date)" >> "$FILENAME"
echo "" >> "$FILENAME"

echo "Iniciando a compilação de arquivos .nix..."
echo "Diretório alvo: ${TARGET_DIR}"
echo "Arquivo de saída: ${FILENAME}"
echo ""

# Encontra todos os arquivos .nix no diretório do script, excluindo o próprio diretório `.`
# e processa cada um deles. O -print0 e read -d '' tornam o script seguro para
# arquivos com espaços ou caracteres especiais no nome.
find "$TARGET_DIR" -type f -name "*.nix" | while IFS= read -r file; do
    # Extrai o caminho relativo para um cabeçalho mais limpo
    relative_path="${file#"$TARGET_DIR/"}"

    echo "Adicionando: ${relative_path}"

    # Adiciona um separador e o cabeçalho do arquivo ao arquivo de saída
    echo "---" >> "$FILENAME"
    echo "## Arquivo: ${relative_path}" >> "$FILENAME"
    echo "" >> "$FILENAME"

    # Adiciona o conteúdo do arquivo dentro de um bloco de código Nix
    echo '```nix' >> "$FILENAME"
    cat "$file" >> "$FILENAME"
    echo '```' >> "$FILENAME"
    echo "" >> "$FILENAME"
done

echo ""
echo "✅ Compilação concluída!"
echo "Todos os arquivos foram salvos em: ${FILENAME}"