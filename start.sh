#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRANSCRIPTS_DIR="${TRANSCRIPTS_DIR:-/home/clone/transcricoes_md}"
COLLECTION="${QMD_COLLECTION:-sand-transcricoes}"
PROFILE="${HERMES_PROFILE:-sand}"

if ! command -v qmd >/dev/null 2>&1; then
  echo "Erro: qmd não está instalado ou não está no PATH." >&2
  echo "Instale com: npm install -g @tobilu/qmd" >&2
  exit 1
fi

if [ ! -d "$TRANSCRIPTS_DIR" ]; then
  echo "Erro: pasta de transcrições não encontrada: $TRANSCRIPTS_DIR" >&2
  exit 1
fi

if ! command -v hermes >/dev/null 2>&1; then
  echo "Erro: hermes não está instalado ou não está no PATH." >&2
  exit 1
fi

if ! hermes profile list | grep -q "${PROFILE}"; then
  echo "Erro: perfil Hermes '$PROFILE' não encontrado." >&2
  echo "Crie-o com: hermes profile create $PROFILE --clone" >&2
  exit 1
fi

MCP_LIST="$(hermes -p "$PROFILE" mcp list 2>/dev/null || true)"
if ! printf '%s\n' "$MCP_LIST" | grep -q "sand-qmd"; then
  echo "Aviso: o servidor MCP sand-qmd ainda não está configurado no perfil $PROFILE." >&2
  echo "Consulte README.md para configurar o MCP." >&2
  exit 1
fi

if [ "${1:-}" = "--check" ]; then
  echo "QMD projeto check: OK"
  echo "Transcrições: $TRANSCRIPTS_DIR"
  echo "Coleção: $COLLECTION"
  echo "Perfil Hermes: $PROFILE"
  hermes -p "$PROFILE" mcp test sand-qmd
  exit 0
fi

qmd update >/dev/null
qmd status

echo
echo "Sand está pronto. Iniciando o chat Hermes com o perfil $PROFILE..."
exec hermes -p "$PROFILE" chat
