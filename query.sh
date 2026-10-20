#!/usr/bin/env bash
set -euo pipefail

COLLECTION="${QMD_COLLECTION:-sand-transcricoes}"

if [ "$#" -eq 0 ]; then
  echo "Uso: $0 \"pergunta\"" >&2
  exit 2
fi

if ! command -v qmd >/dev/null 2>&1; then
  echo "Erro: qmd não está instalado ou não está no PATH." >&2
  exit 1
fi

STATUS="$(qmd status 2>/dev/null || true)"
if printf '%s\n' "$STATUS" | grep -Eq 'Pending:[[:space:]]+[1-9][0-9]*'; then
  echo "Aviso: embeddings ainda não estão prontos; usando busca lexical BM25." >&2
  exec qmd search "$*" --collection "$COLLECTION" --format json --line-numbers
fi

exec qmd query "$*" --collection "$COLLECTION" --format json --line-numbers
