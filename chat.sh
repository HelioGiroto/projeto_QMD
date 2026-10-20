#!/usr/bin/env bash
set -euo pipefail

PROFILE="${HERMES_PROFILE:-sand}"

if ! command -v hermes >/dev/null 2>&1; then
  echo "Erro: hermes não está instalado ou não está no PATH." >&2
  exit 1
fi

exec hermes -p "$PROFILE" chat
