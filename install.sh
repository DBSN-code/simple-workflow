#!/usr/bin/env bash
set -u

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
SKILLS_HOME="$HOME/.agents/skills"
BACKUP_STAMP="$(date +%Y%m%d-%H%M%S)"

ok()   { printf '✓ %s\n' "$1"; }
info() { printf '→ %s\n' "$1"; }
warn() { printf '! %s\n' "$1"; }

printf '\nSimple Workflow for Codex — installer\n\n'

mkdir -p "$CODEX_HOME/agents" "$SKILLS_HOME"

# -----------------------------------------------------------------------------
# 1. Global AGENTS.md
# -----------------------------------------------------------------------------
if [ -f "$CODEX_HOME/AGENTS.md" ]; then
  cp "$CODEX_HOME/AGENTS.md" "$CODEX_HOME/AGENTS.md.backup-$BACKUP_STAMP"
  info "Backup criado: $CODEX_HOME/AGENTS.md.backup-$BACKUP_STAMP"
fi
cp "$ROOT_DIR/codex/AGENTS.md" "$CODEX_HOME/AGENTS.md"
ok "Workflow global instalado em $CODEX_HOME/AGENTS.md"

# -----------------------------------------------------------------------------
# 2. Custom agents
# -----------------------------------------------------------------------------
for agent in executor reviewer; do
  target="$CODEX_HOME/agents/$agent.toml"
  if [ -f "$target" ]; then
    cp "$target" "$target.backup-$BACKUP_STAMP"
  fi
  cp "$ROOT_DIR/codex/agents/$agent.toml" "$target"
done
ok "Agentes executor (Luna xhigh) e reviewer (Terra high) instalados"

# -----------------------------------------------------------------------------
# 3. Codex config.toml
#    Preserve unrelated config, replace only Simple Workflow model/effort keys
#    and the optional [profiles.astra] table.
# -----------------------------------------------------------------------------
CONFIG="$CODEX_HOME/config.toml"
TMP_CONFIG="$CODEX_HOME/.config.simple-workflow.tmp"

if [ -f "$CONFIG" ]; then
  cp "$CONFIG" "$CONFIG.backup-$BACKUP_STAMP"
  info "Backup criado: $CONFIG.backup-$BACKUP_STAMP"
else
  : > "$CONFIG"
fi

awk '
BEGIN { in_astra=0; defaults_written=0 }
function defaults() {
  if (!defaults_written) {
    print "# Simple Workflow — managed defaults"
    print "model = \"gpt-5.6\""
    print "model_reasoning_effort = \"medium\""
    print "plan_mode_reasoning_effort = \"high\""
    print ""
    defaults_written=1
  }
}
/^[[:space:]]*\[profiles\.astra\][[:space:]]*$/ { in_astra=1; next }
in_astra && /^[[:space:]]*\[/ { in_astra=0 }
in_astra { next }
/^[[:space:]]*model[[:space:]]*=/ { next }
/^[[:space:]]*model_reasoning_effort[[:space:]]*=/ { next }
/^[[:space:]]*plan_mode_reasoning_effort[[:space:]]*=/ { next }
!defaults_written && /^[[:space:]]*\[/ { defaults() }
{ print }
END { defaults() }
' "$CONFIG" > "$TMP_CONFIG"

cat >> "$TMP_CONFIG" <<'EOF'

# Simple Workflow — optional Astra profile
[profiles.astra]
model = "gpt-6-astra"
model_reasoning_effort = "low"
plan_mode_reasoning_effort = "medium"
EOF

mv "$TMP_CONFIG" "$CONFIG"
ok "Sol medium / Plan high e perfil Astra low / Plan medium configurados"

# -----------------------------------------------------------------------------
# 4. Selected Superpowers skills only
# -----------------------------------------------------------------------------
if command -v git >/dev/null 2>&1; then
  TMP_SP="$(mktemp -d 2>/dev/null || mktemp -d -t simple-workflow)"
  if git clone --depth 1 --quiet https://github.com/obra/superpowers.git "$TMP_SP/superpowers"; then
    for skill in systematic-debugging test-driven-development verification-before-completion; do
      source_dir="$TMP_SP/superpowers/skills/$skill"
      target_dir="$SKILLS_HOME/$skill"
      if [ -d "$source_dir" ]; then
        rm -rf "$target_dir"
        cp -R "$source_dir" "$target_dir"
        mkdir -p "$target_dir/agents"
        cat > "$target_dir/agents/openai.yaml" <<EOF
interface:
  display_name: "$skill"
  short_description: "Selected Superpowers skill used explicitly by Simple Workflow"
policy:
  allow_implicit_invocation: false
EOF
      else
        warn "Skill não encontrada no Superpowers atual: $skill"
      fi
    done
    ok "Três skills selecionadas do Superpowers instaladas com invocação implícita desativada"
  else
    warn "Não foi possível baixar Superpowers; as três skills não foram instaladas"
  fi
  rm -rf "$TMP_SP"
else
  warn "Git não encontrado; pulando skills do Superpowers"
fi

# -----------------------------------------------------------------------------
# 5. Impeccable (global Codex skill)
# -----------------------------------------------------------------------------
if command -v npx >/dev/null 2>&1; then
  info "Instalando/atualizando Impeccable para Codex (global)..."
  if npx --yes impeccable@latest install --providers=codex --scope=global; then
    ok "Impeccable disponível globalmente"
  else
    warn "Impeccable não pôde ser instalado automaticamente"
  fi
else
  warn "npx não encontrado; pulando Impeccable e Modern Web Guidance"
fi

# -----------------------------------------------------------------------------
# 6. Modern Web Guidance
#    Official installer may ask which supported agent/location to use.
# -----------------------------------------------------------------------------
if command -v npx >/dev/null 2>&1; then
  printf '\n'
  info "Abrindo o instalador oficial do Modern Web Guidance. Se houver escolha de agente, selecione Codex e instalação de usuário/global."
  if npx --yes modern-web-guidance@latest install; then
    ok "Modern Web Guidance configurado"
  else
    warn "Modern Web Guidance não pôde ser instalado automaticamente"
  fi
fi

# -----------------------------------------------------------------------------
# 7. Open Design MCP
# -----------------------------------------------------------------------------
if command -v od >/dev/null 2>&1; then
  info "Configurando Open Design MCP para Codex..."
  if od mcp install codex; then
    ok "Open Design conectado ao Codex"
  else
    warn "Open Design está instalado, mas a configuração MCP falhou"
  fi
else
  warn "Comando 'od' não encontrado; Open Design foi ignorado. Instale-o quando quiser usar design via MCP."
fi

printf '\nInstalação concluída.\n'
printf 'Feche e abra novamente o Codex para recarregar AGENTS.md, agentes e skills.\n'
printf 'Padrão: Sol medium; Plan Mode: high. Para arquitetura ambígua no CLI: codex --profile astra\n\n'
