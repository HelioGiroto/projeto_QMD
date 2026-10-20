#!/usr/bin/env bash
set -euo pipefail

TRANSCRIPTS_DIR="${TRANSCRIPTS_DIR:-/home/clone/transcricoes_md}"
COLLECTION="${QMD_COLLECTION:-sand-transcricoes}"

if ! command -v qmd >/dev/null 2>&1; then
  echo "Erro: qmd não está instalado ou não está no PATH." >&2
  exit 1
fi

if [ ! -d "$TRANSCRIPTS_DIR" ]; then
  echo "Erro: pasta não encontrada: $TRANSCRIPTS_DIR" >&2
  exit 1
fi

if ! qmd collection list | grep -q "^${COLLECTION} "; then
  qmd collection add "$TRANSCRIPTS_DIR" --name "$COLLECTION"
fi

if ! qmd context list | grep -q "qmd://${COLLECTION}/"; then
  qmd context add "qmd://${COLLECTION}/" "Transcrições Markdown autorizadas para Sand. Fonte oficial do conteúdo; não inventar fatos ou timestamps."
fi

qmd update

if ! qmd embed -c "$COLLECTION"; then
  echo "Aviso: embeddings não foram concluídos; o projeto continuará usando busca lexical BM25." >&2
  echo "Causa comum: memória insuficiente para os modelos locais do QMD." >&2
fi

qmd status
