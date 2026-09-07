#!/usr/bin/env bash
# Bash 3.2+; no changes to application dependencies or project files.
set -euo pipefail
umask 077
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
SKILLS_HOME="$HOME/.agents/skills"
TOOLS=false
case "${1:-}" in
  '') ;;
  --tools) TOOLS=true ;;
  --help|-h) printf 'Uso: bash install.sh [--tools]\nSem flags: atualiza as regras e migra a instalação antiga, sem rede.\n--tools: também tenta instalar as ferramentas opcionais ausentes.\n'; exit 0 ;;
  *) printf 'Opção desconhecida. Use --help.\n' >&2; exit 1 ;;
esac
[ "$#" -le 1 ] || { printf 'Use somente uma opção.\n' >&2; exit 1; }
info() { printf '→ %s\n' "$*"; }
warn() { printf '! %s\n' "$*" >&2; }
fail() { warn "$*"; exit 1; }
for cmd in git awk grep cmp mktemp; do
  command -v "$cmd" >/dev/null 2>&1 || fail "Comando necessário não encontrado: $cmd"
done
[ -f "$ROOT_DIR/codex/AGENTS.md" ] || fail 'Arquivo codex/AGENTS.md ausente.'
[ -f "$ROOT_DIR/scripts/migrate-config.awk" ] || fail 'Arquivo de migração ausente.'
WORK="$(mktemp -d "${TMPDIR:-/tmp}/simple-workflow.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
BACKUP_DIR=''
backup() {
  local src="$1" rel="$2"
  if [ -z "$BACKUP_DIR" ]; then
    mkdir -p "$CODEX_HOME/simple-workflow-backups"
    BACKUP_DIR="$(mktemp -d "$CODEX_HOME/simple-workflow-backups/$(date +%Y%m%d-%H%M%S).XXXXXX")"
  fi
  mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
  cp -p "$src" "$BACKUP_DIR/$rel"
}
replace_file() {
  local src="$1" dst="$2" rel="$3" staged
  if [ -f "$dst" ] && cmp -s "$src" "$dst"; then return; fi
  if [ -f "$dst" ]; then backup "$dst" "$rel"; fi
  staged="$(mktemp "$CODEX_HOME/.simple-workflow.XXXXXX")"
  cp "$src" "$staged"
  mv "$staged" "$dst"
}
blob_hash() { git hash-object --no-filters "$1"; }

# Prepare global guidance before changing anything. Preserve personal text.
AGENTS="$CODEX_HOME/AGENTS.md"
[ ! -L "$AGENTS" ] || fail 'AGENTS.md é um link. Faça a integração manual para preservar seu destino.'
[ ! -e "$AGENTS" ] || [ -f "$AGENTS" ] || fail 'AGENTS.md não é um arquivo regular.'
BEGIN_MARK='<!-- simple-workflow:begin -->'
END_MARK='<!-- simple-workflow:end -->'
{ printf '%s\n' "$BEGIN_MARK"; cat "$ROOT_DIR/codex/AGENTS.md"; printf '%s\n' "$END_MARK"; } > "$WORK/block"
legacy=false
if [ -f "$AGENTS" ]; then
  case "$(blob_hash "$AGENTS")" in
    ee03dea8e3c20148b052ae823cab1171bfc4c47b|adf03688766bef802ae265ac78093067f1693e07|a320e632189325ad9e5adb5953ab5b36863ee7d8) legacy=true ;;
  esac
fi
if [ ! -f "$AGENTS" ] || $legacy; then
  cp "$WORK/block" "$WORK/AGENTS.md"
elif grep -Fq "$BEGIN_MARK" "$AGENTS" || grep -Fq "$END_MARK" "$AGENTS"; then
  awk -v begin="$BEGIN_MARK" -v end="$END_MARK" -v block="$WORK/block" '
    $0 == begin { if (seen++ || inside) exit 2; inside=1; while ((getline x < block)>0) print x; close(block); next }
    $0 == end { if (!inside) exit 2; inside=0; finished++; next }
    !inside { print }
    END { if (inside || seen != 1 || finished != 1) exit 2 }
  ' "$AGENTS" > "$WORK/AGENTS.md" || fail 'Marcadores inválidos no AGENTS.md. Nada foi alterado; revise o bloco.'
elif grep -q '^# Simple Workflow' "$AGENTS"; then
  fail 'Seu Simple Workflow antigo foi personalizado. Peça ao Codex para mesclar codex/AGENTS.md preservando suas regras, antes de executar novamente.'
else
  { cat "$AGENTS"; printf '\n'; cat "$WORK/block"; } > "$WORK/AGENTS.md"
fi

# Never parse unfamiliar TOML with broad substitutions. Preserve custom settings.
CONFIG="$CODEX_HOME/config.toml"
MIGRATE_CONFIG=false
if [ -f "$CONFIG" ] && [ ! -L "$CONFIG" ]; then
  if grep -q '"""' "$CONFIG" || grep -q "'''" "$CONFIG" || LC_ALL=C grep -q $'\r' "$CONFIG"; then
    if grep -q '# Simple Workflow' "$CONFIG"; then warn 'config.toml preservado: formato complexo. Revise manualmente os blocos antigos do Simple Workflow.'; fi
  elif grep -q '# Simple Workflow' "$CONFIG"; then
    keep_astra=0
    if grep -Eq "^[[:space:]]*profile[[:space:]]*=[[:space:]]*[\"']astra[\"']" "$CONFIG"; then keep_astra=1; fi
    awk -v keep_astra="$keep_astra" -f "$ROOT_DIR/scripts/migrate-config.awk" "$CONFIG" > "$WORK/config.toml"
    if ! cmp -s "$CONFIG" "$WORK/config.toml"; then MIGRATE_CONFIG=true; fi
    if grep -q '# Simple Workflow' "$WORK/config.toml"; then warn 'Algum bloco antigo foi personalizado/está em uso e foi preservado. Revise-o no Codex.'; fi
  fi
elif [ -L "$CONFIG" ]; then
  warn 'config.toml é um link: preservado, sem limpeza automática de configurações antigas.'
fi

mkdir -p "$CODEX_HOME"
replace_file "$WORK/AGENTS.md" "$AGENTS" 'AGENTS.md'
if $MIGRATE_CONFIG; then
  replace_file "$WORK/config.toml" "$CONFIG" 'config.toml'
  info 'Removidos somente os blocos de modelos antigos reconhecidos e não personalizados.'
fi

# Remove only byte-for-byte known releases of OUR agents; names alone are not proof.
for agent in executor executor_deep reviewer; do
  target="$CODEX_HOME/agents/$agent.toml"
  if [ ! -e "$target" ] && [ ! -L "$target" ]; then continue; fi
  if [ -L "$target" ] || [ ! -f "$target" ]; then warn "Agente preservado (link/formato especial): $target"; continue; fi
  owned=false
  case "$agent:$(blob_hash "$target")" in
    executor:e3077c405f8bb5e3ebd02ee892cfe0874f68daae|executor:c3150e4649bc1a03b28a35b2d7ba2fc83f07fbbf|executor_deep:dc07718c6b1ed15a441f8fe248de91bc4f77f438|reviewer:eec3f99b98408fc61fd053ec8f3734bba04b09bb|reviewer:1f9b43af5c8d8a14007d5b4c879f5af0d0b10714) owned=true ;;
  esac
  if $owned; then
    backup "$target" "agents/$agent.toml"
    rm "$target"
    info "Agente antigo desativado, com backup: $agent"
  else
    warn "Agente personalizado/não reconhecido preservado: $target. Revise se ainda contém roteamento antigo."
  fi
done
if [ -s "$CODEX_HOME/AGENTS.override.md" ]; then warn 'AGENTS.override.md global existe e pode prevalecer sobre estas regras; revise-o no Codex.'; fi
info 'Regras nativas instaladas. Nenhum modelo, esforço, permissão ou subagente novo foi imposto.'

# Optional tools are reused, not reinstalled on every rules update.
skill_present() { [ -f "$SKILLS_HOME/$1/SKILL.md" ] || [ -f "$CODEX_HOME/skills/$1/SKILL.md" ]; }
if $TOOLS; then
  mkdir -p "$SKILLS_HOME"
  missing=false
  for skill in systematic-debugging test-driven-development verification-before-completion; do
    if ! skill_present "$skill"; then missing=true; fi
  done
  if $missing; then
    if git clone --depth 1 --quiet https://github.com/obra/superpowers.git "$WORK/superpowers"; then
      for skill in systematic-debugging test-driven-development verification-before-completion; do
        if skill_present "$skill"; then continue; fi
        src="$WORK/superpowers/skills/$skill"; dst="$SKILLS_HOME/$skill"
        if [ -e "$dst" ] || [ -L "$dst" ] || [ ! -f "$src/SKILL.md" ]; then warn "Skill preservada/indisponível: $skill"; continue; fi
        cp -R "$src" "$dst"
        if [ -f "$WORK/superpowers/LICENSE" ]; then cp "$WORK/superpowers/LICENSE" "$dst/LICENSE"; fi
        mkdir -p "$dst/agents"
        printf 'interface:\n  display_name: "%s"\npolicy:\n  allow_implicit_invocation: false\n' "$skill" > "$dst/agents/openai.yaml"
        info "Skill explícita instalada: $skill"
      done
    else warn 'Não foi possível obter as skills selecionadas do Superpowers.'; fi
  fi
  # Run installers outside project directories to avoid adding project hooks there.
  if ! skill_present impeccable; then
    if command -v npx >/dev/null 2>&1; then
      (cd "$WORK" && npx --yes impeccable@latest install --providers=codex --scope=global) || warn 'Instalador do Impeccable falhou.'
      skill_present impeccable || warn 'Impeccable não confirmado no diretório global. Confira a saída do instalador.'
    else warn 'npx ausente: Impeccable não instalado.'; fi
  fi
  if ! skill_present modern-web-guidance; then
    if command -v npx >/dev/null 2>&1; then
      info 'No assistente Modern Web Guidance, escolha Codex e escopo global/usuário.'
      (cd "$WORK" && npx --yes modern-web-guidance@latest install) || warn 'Instalador do Modern Web Guidance falhou.'
      skill_present modern-web-guidance || warn 'Modern Web Guidance não confirmado globalmente; uma instalação apenas temporária não é válida.'
    else warn 'npx ausente: Modern Web Guidance não instalado.'; fi
  fi
  # macOS also ships an unrelated command named od (octal dump).
  if command -v od >/dev/null 2>&1 && od --help 2>&1 | grep -Eiq 'OpenDesign|Open Design|open-design|od mcp'; then
    if [ "$CODEX_HOME" != "$HOME/.codex" ]; then
      warn 'CODEX_HOME personalizado: configure o MCP do Open Design manualmente no destino correto.'
    else
      if [ -f "$CONFIG" ] && [ ! -L "$CONFIG" ]; then backup "$CONFIG" 'config.before-open-design.toml'; fi
      (cd "$WORK" && od mcp install codex) || warn 'Integração MCP do Open Design não concluída.'
    fi
  else warn 'CLI do Open Design não encontrado/confirmado. O comando od do sistema não é Open Design.'; fi
fi
if [ -n "$BACKUP_DIR" ]; then info "Backup desta atualização: $BACKUP_DIR"; fi
printf '\nAtualização das regras concluída. Confira eventuais avisos acima.\n'
printf 'Reabra o Codex e inicie uma conversa nova. Selecione modelo e esforço no próprio cliente.\n'
printf 'Projetos com regras locais antigas precisam da adoção descrita no README.\n'
