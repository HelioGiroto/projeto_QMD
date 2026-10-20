#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRANSCRIPTS_DIR="${TRANSCRIPTS_DIR:-/home/clone/transcricoes_md}"
PROFILE="${HERMES_PROFILE:-sand}"
COLLECTION="${QMD_COLLECTION:-sand-transcricoes}"

fail() { echo "Erro: $*" >&2; exit 1; }

command -v node >/dev/null 2>&1 || fail "Node.js não encontrado. Instale Node.js 22 ou superior."
command -v npm >/dev/null 2>&1 || fail "npm não encontrado."
command -v hermes >/dev/null 2>&1 || fail "Hermes não encontrado. Instale o Hermes Agent primeiro."
[ -d "$TRANSCRIPTS_DIR" ] || fail "Pasta de transcrições não encontrada: $TRANSCRIPTS_DIR"

if ! command -v qmd >/dev/null 2>&1; then
  echo "QMD não encontrado; instalando @tobilu/qmd..."
  npm install -g @tobilu/qmd
fi

PROFILE_LIST="$(hermes profile list 2>/dev/null || true)"
if ! printf '%s\n' "$PROFILE_LIST" | grep -q "${PROFILE}"; then
  echo "Criando o perfil Hermes $PROFILE..."
  hermes profile create "$PROFILE" --clone --description "Sand: autor virtual baseado em transcrições em $TRANSCRIPTS_DIR"
fi

# O SOUL da cópia local é instalado no perfil ativo de Sand.
cp "$PROJECT_DIR/SOUL.md" "$HOME/.hermes/profiles/$PROFILE/SOUL.md"

COLLECTION_LIST="$(qmd collection list 2>/dev/null || true)"
if ! printf '%s\n' "$COLLECTION_LIST" | grep -q "^${COLLECTION} "; then
  qmd collection add "$TRANSCRIPTS_DIR" --name "$COLLECTION"
fi

CONTEXT_LIST="$(qmd context list 2>/dev/null || true)"
if ! printf '%s\n' "$CONTEXT_LIST" | grep -q "qmd://${COLLECTION}/"; then
  qmd context add "qmd://${COLLECTION}/" "Transcrições Markdown autorizadas para Sand. Fonte oficial do conteúdo; não inventar fatos ou timestamps."
fi

# Localiza um Python do ambiente Hermes que tenha o pacote MCP.
MCP_PYTHON=""
while IFS= read -r candidate; do
  if "$candidate" -c 'import mcp' >/dev/null 2>&1; then
    MCP_PYTHON="$candidate"
    break
  fi
done < <(find "$HOME/.hermes" -path '*/venv/bin/python' -type f 2>/dev/null | sort)

[ -n "$MCP_PYTHON" ] || fail "Não encontrei um Python do Hermes com o pacote mcp."

if ! hermes -p "$PROFILE" mcp list 2>/dev/null | grep -q "sand-qmd"; then
  printf 'Y\n' | hermes -p "$PROFILE" mcp add sand-qmd \
    --command "$MCP_PYTHON" \
    --args "$PROJECT_DIR/qmd_mcp.py"
fi

qmd update

if ! qmd embed -c "$COLLECTION"; then
  echo "Aviso: embeddings não concluídos; o modo BM25 continuará disponível." >&2
fi

cat <<EOF

Instalação local concluída.

Verifique:
  cd "$PROJECT_DIR"
  ./start.sh --check

Abra o chat:
  ./chat.sh

Configure o gateway Hermes:
  hermes -p "$PROFILE" gateway setup
  hermes -p "$PROFILE" gateway start

Para instalar o gateway como serviço do usuário:
  hermes -p "$PROFILE" gateway install
EOF
