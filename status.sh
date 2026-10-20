#!/usr/bin/env bash
set -euo pipefail

if ! command -v qmd >/dev/null 2>&1; then
  echo "Erro: qmd não está instalado ou não está no PATH." >&2
  exit 1
fi

qmd status
printf '\nColeções:\n'
qmd collection list
printf '\nMCP do perfil Sand:\n'
hermes -p sand mcp list
