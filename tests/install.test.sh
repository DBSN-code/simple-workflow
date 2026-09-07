#!/usr/bin/env bash
# Offline installer tests. Never use the actual user's HOME or contact services.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/simple-workflow-tests.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT
REAL_GIT="$(command -v git)"
BASE=fa7549236dc713566805340ba6a07be4949e3586
COUNT=0
pass() { COUNT=$((COUNT+1)); printf 'OK %s: %s\n' "$COUNT" "$*"; }
new_home() { H="$TMP/$1"; mkdir -p "$H/.codex"; }
run() { HOME="$H" CODEX_HOME="$H/.codex" bash "$ROOT/install.sh" "$@" > "$TMP/out" 2>&1; }
fixture() {
  if [ -n "${SW_TEST_LEGACY_DIR:-}" ]; then
    cat "$SW_TEST_LEGACY_DIR/$1"
  else
    "$REAL_GIT" -C "$ROOT" show "$BASE:$1"
  fi
}
legacy_config() {
  cat <<'CONFIG'
# Simple Workflow — managed defaults
model = "gpt-5.6"
model_reasoning_effort = "medium"
plan_mode_reasoning_effort = "high"

approval_policy = "on-request"
[profiles.personal]
model = "personal-model"
model_reasoning_effort = "low"
[mcp_servers.example]
command = "example-mcp"
# Simple Workflow — optional Astra profile
[profiles.astra]
model = "gpt-6-astra"
model_reasoning_effort = "low"
plan_mode_reasoning_effort = "medium"
CONFIG
}

new_home clean
run
[ -f "$H/.codex/AGENTS.md" ]
[ ! -e "$H/.codex/config.toml" ]
[ ! -e "$H/.codex/agents" ]
! grep -Eq 'gpt-|executor_deep|Luna|Terra' "$H/.codex/AGENTS.md"
pass 'instalação limpa sem modelos/agentes impostos'
cp "$H/.codex/AGENTS.md" "$TMP/first"
run
cmp "$TMP/first" "$H/.codex/AGENTS.md"
[ ! -e "$H/.codex/simple-workflow-backups" ]
pass 'reinstalação idêntica sem acumular contexto ou backups'

new_home personal
printf '# Personal\nKeep my rule.\n' > "$H/.codex/AGENTS.md"
printf 'model = "mine"\nmodel_reasoning_effort = "high"\n' > "$H/.codex/config.toml"
cp "$H/.codex/config.toml" "$TMP/personal-config"
run
printf '\nAnother personal rule.\n' >> "$H/.codex/AGENTS.md"
cp "$H/.codex/AGENTS.md" "$TMP/personal-agents"
run
cmp "$TMP/personal-config" "$H/.codex/config.toml"
cmp "$TMP/personal-agents" "$H/.codex/AGENTS.md"
pass 'preferências pessoais e texto fora dos marcadores preservados'

new_home legacy
mkdir -p "$H/.codex/agents"
fixture codex/AGENTS.md > "$H/.codex/AGENTS.md"
for agent in executor executor_deep reviewer; do
  fixture "codex/agents/$agent.toml" > "$H/.codex/agents/$agent.toml"
done
legacy_config > "$H/.codex/config.toml"
cp "$H/.codex/config.toml" "$TMP/legacy-config"
printf 'name = "unrelated"\n' > "$H/.codex/agents/unrelated.toml"
run
for agent in executor executor_deep reviewer; do
  [ ! -e "$H/.codex/agents/$agent.toml" ]
  saved="$(find "$H/.codex/simple-workflow-backups" -name "$agent.toml")"
  [ -f "$saved" ]
  fixture "codex/agents/$agent.toml" > "$TMP/fixture"
  cmp "$TMP/fixture" "$saved"
done
[ -f "$H/.codex/agents/unrelated.toml" ]
! grep -q 'orchestrator\|gpt-5.6\|gpt-6-astra' "$H/.codex/AGENTS.md"
! grep -q 'gpt-5.6\|gpt-6-astra\|profiles.astra' "$H/.codex/config.toml"
grep -q 'personal-model' "$H/.codex/config.toml"
grep -q 'example-mcp' "$H/.codex/config.toml"
grep -q 'on-request' "$H/.codex/config.toml"
saved="$(find "$H/.codex/simple-workflow-backups" -name config.toml)"
cmp "$TMP/legacy-config" "$saved"
saved="$(find "$H/.codex/simple-workflow-backups" -name AGENTS.md)"
fixture codex/AGENTS.md > "$TMP/fixture"
cmp "$TMP/fixture" "$saved"
pass 'migração real dos arquivos legados com backups e preservação de outros agentes/MCPs'
cp "$H/.codex/config.toml" "$TMP/migrated"
run
cmp "$TMP/migrated" "$H/.codex/config.toml"
pass 'migração repetida não muda a configuração novamente'

new_home customized
mkdir -p "$H/.codex/agents"
fixture codex/agents/executor.toml > "$H/.codex/agents/executor.toml"
printf '\n# My addition\n' >> "$H/.codex/agents/executor.toml"
cp "$H/.codex/agents/executor.toml" "$TMP/custom-agent"
legacy_config > "$H/.codex/config.toml"
printf 'model_verbosity = "low"\n' >> "$H/.codex/config.toml"
run
cmp "$TMP/custom-agent" "$H/.codex/agents/executor.toml"
grep -q 'profiles.astra' "$H/.codex/config.toml"
grep -q 'model_verbosity' "$H/.codex/config.toml"
grep -q 'personalizado' "$TMP/out"
pass 'agente e perfil personalizados não são apagados'

new_home customized-guidance
fixture codex/AGENTS.md > "$H/.codex/AGENTS.md"
printf '\nMy extra instruction.\n' >> "$H/.codex/AGENTS.md"
cp "$H/.codex/AGENTS.md" "$TMP/old-custom"
legacy_config > "$H/.codex/config.toml"
cp "$H/.codex/config.toml" "$TMP/old-config"
if run; then echo 'ERRO: deveria recusar orientação legada personalizada' >&2; exit 1; fi
cmp "$TMP/old-custom" "$H/.codex/AGENTS.md"
cmp "$TMP/old-config" "$H/.codex/config.toml"
[ ! -e "$H/.codex/simple-workflow-backups" ]
pass 'orientação antiga personalizada interrompe antes de qualquer alteração'

new_home active-profile
{ printf 'profile = "astra"\n'; legacy_config; } > "$H/.codex/config.toml"
run
grep -q 'profiles.astra' "$H/.codex/config.toml"
pass 'perfil Astra selecionado explicitamente é preservado'
new_home multiline
{ legacy_config; printf 'developer_instructions = """\ncustom\n"""\n'; } > "$H/.codex/config.toml"
cp "$H/.codex/config.toml" "$TMP/complex"
run
cmp "$TMP/complex" "$H/.codex/config.toml"
pass 'TOML complexo não sofre substituição arriscada'

new_home symlinks
printf 'personal\n' > "$H/real-agents"
ln -s "$H/real-agents" "$H/.codex/AGENTS.md"
if run; then echo 'ERRO: deveria recusar AGENTS.md simbólico' >&2; exit 1; fi
[ -L "$H/.codex/AGENTS.md" ]
grep -qx personal "$H/real-agents"
pass 'links simbólicos não são sobrescritos'
new_home markers
printf '<!-- simple-workflow:begin -->\nbroken\n' > "$H/.codex/AGENTS.md"
cp "$H/.codex/AGENTS.md" "$TMP/broken"
if run; then echo 'ERRO: deveria recusar marcadores inválidos' >&2; exit 1; fi
cmp "$TMP/broken" "$H/.codex/AGENTS.md"
pass 'marcadores incompletos não provocam perda de conteúdo'
new_home override
printf 'My override\n' > "$H/.codex/AGENTS.override.md"
run
grep -q 'AGENTS.override.md' "$TMP/out"
grep -qx 'My override' "$H/.codex/AGENTS.override.md"
pass 'override preservado com aviso'

# Fake external commands. No network or real installs, even with --tools.
MOCK="$TMP/bin"; mkdir -p "$MOCK" "$TMP/upstream/skills"
export REAL_GIT
export SW_MOCK_UPSTREAM="$TMP/upstream"
export SW_MOCK_LOG="$TMP/external.log"
printf 'upstream license\n' > "$TMP/upstream/LICENSE"
for skill in systematic-debugging test-driven-development verification-before-completion; do
  mkdir -p "$TMP/upstream/skills/$skill"
  printf '%s\n' "name: $skill" > "$TMP/upstream/skills/$skill/SKILL.md"
done
cat > "$MOCK/git" <<'MOCK'
#!/usr/bin/env bash
if [ "${1:-}" = clone ]; then
  printf 'git clone\n' >> "$SW_MOCK_LOG"
  for dest in "$@"; do :; done
  cp -R "$SW_MOCK_UPSTREAM" "$dest"
else exec "$REAL_GIT" "$@"; fi
MOCK
cat > "$MOCK/npx" <<'MOCK'
#!/usr/bin/env bash
printf 'npx %s cwd=%s\n' "$*" "$PWD" >> "$SW_MOCK_LOG"
case "$*" in
  *impeccable*) name=impeccable ;;
  *modern-web-guidance*) name=modern-web-guidance ;;
  *) exit 1 ;;
esac
mkdir -p "$HOME/.agents/skills/$name"
printf 'mock skill\n' > "$HOME/.agents/skills/$name/SKILL.md"
MOCK
cat > "$MOCK/od" <<'MOCK'
#!/usr/bin/env bash
if [ "${1:-}" = --help ]; then echo 'od: octal dump'; exit 0; fi
printf 'WRONG od invocation\n' >> "$SW_MOCK_LOG"
exit 1
MOCK
chmod +x "$MOCK/"*
export PATH="$MOCK:$PATH"
new_home tools
: > "$SW_MOCK_LOG"
run
[ ! -s "$SW_MOCK_LOG" ]
pass 'atualização padrão não invoca instaladores/rede'
run --tools
for skill in systematic-debugging test-driven-development verification-before-completion; do
  grep -q 'allow_implicit_invocation: false' "$H/.agents/skills/$skill/agents/openai.yaml"
  cmp "$TMP/upstream/LICENSE" "$H/.agents/skills/$skill/LICENSE"
done
grep -q 'impeccable@latest install --providers=codex --scope=global' "$SW_MOCK_LOG"
grep -q 'modern-web-guidance@latest install' "$SW_MOCK_LOG"
! grep -q 'WRONG od invocation' "$SW_MOCK_LOG"
! grep -Fq "cwd=$ROOT" "$SW_MOCK_LOG"
pass 'ferramentas selecionadas, licença, escopo global e proteção contra od do sistema'
: > "$SW_MOCK_LOG"
run --tools
[ ! -s "$SW_MOCK_LOG" ]
pass 'ferramentas já disponíveis não são reinstaladas'
printf '\n%s cenários passaram. Sem testar clientes/modelos reais.\n' "$COUNT"
