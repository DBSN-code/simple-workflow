# Simple Workflow — native Codex

Use the least process and context needed to complete the task safely. This is guidance for native Codex, not a separate agent framework.

## Communication

- Use Brazilian Portuguese and plain language unless the user requests otherwise.
- Explain important technical terms briefly when introduced; do not repeat concepts the user already understands.
- Explain meaningful decisions through their practical consequence and tradeoffs, not implementation trivia.
- Keep updates and completion concise. Avoid raw logs or large code excerpts unless useful or requested.
- At completion, add at most one short `Para você aprender` note when genuinely useful.

## Native execution

- The model selected in the conversation handles understanding, planning, implementation, and verification end to end. Do not impose a model, reasoning effort, or planner/executor/reviewer routing.
- Use native Plan Mode when complexity or ambiguity warrants planning; do not require a formal plan for clear, small changes. Do not claim to switch modes or models without actual client support.
- Resolve important uncertainty before editing dependent code. Investigate first and ask the user only for decisions the available context cannot resolve.
- Direct execution is the normal path. Use native subagents when explicitly requested by the user or required by a relevant, deliberately selected skill; this file does not request routine delegation.
- Do not recreate removed custom roles or a mandatory chain of agents. When delegating, bound the assignment, avoid overlapping edits, and inspect the actual result rather than trusting a success report.
- Preserve native permissions, sandbox, Git/worktree behavior, and user settings. Never relax them merely to make this workflow run.

## Issues and conversations

- When the project uses GitHub Issues, use them as the work record. Keep one coherent outcome, relevant context, constraints, and clear acceptance criteria; no mandatory verbose template.
- Divide work only when it improves clarity, verification, or tracking. Do not split for a particular model or arbitrary limits on lines, files, or time. Avoid micro-Issues and duplicate backlogs.
- Keep a parent Issue for a larger feature only when useful. Use outcome-oriented titles the user can understand. Preserve existing Issues and history; refine unfinished work only as needed.
- Prefer one conversation per coherent task. Continue while its evidence and decisions remain useful; start fresh for independent work after completion, not mechanically at every Issue boundary.
- Before changing conversations, record necessary status/blockers in the existing Issue/PR and durable decisions in the appropriate knowledge document. Do not create handoff files or duplicate `task.md`/`plan.md` just to carry chat history.

## Context and OKF

- Start with relevant indexes and the current Issue, then read only the code/docs needed. Do not load the whole OKF, backlog, repository, or conversation history by default.
- OKF stores durable knowledge, not task status. Update it only when architecture, domain rules, design decisions, integration behavior, or stable constraints change.
- Update the smallest relevant existing document; do not narrate routine progress or duplicate facts already represented adequately by code or Issues/PRs.
- Preserve the existing OKF layout, sources, and per-screen/design documentation. No bulk conversion or automatic replacement by one large design document.

## Verification and risk-based review

- Inspect the diff and run relevant checks; state what was actually verified and what remains untested. Use focused checks during iteration and broader checks when project rules or risk require them.
- Additional review is not mandatory for every edit. Use native code review where available (such as `/review`) for material risks: security/permissions, persistent or financial data, concurrency/state, public contracts, infrastructure, weak verification, or repeated corrections.
- Review starts with requirements, diff, acceptance criteria, and relevant constraints. Follow affected callers, contracts, tests, and related code as needed; a small starting context is not a prohibition on investigation.
- Keep a review-only pass separate from fixes. Prioritize evidence-backed correctness, regression, security, and data-integrity findings over cosmetics. Do not force another model or claim self-review is independent review.
- No duplicate review of an unchanged diff. Never claim success without evidence appropriate to that claim.

## Optional tools

Installed does not mean required. Load only the relevant skill/guidance; no automatic sequence of all tools.

- Open Design: meaningful UX/UI discovery, visual direction, prototypes, or design-system work.
- Impeccable: targeted UI critique, audit, hardening, or polish when useful; do not repeat an already approved design phase.
- Modern Web Guidance: relevant HTML/CSS/DOM, browser APIs, accessibility, compatibility, or performance guidance. Retrieve only relevant guides and respect the project's supported browsers.
- Selected Superpowers techniques: `systematic-debugging` for unclear root causes or failed fixes; `test-driven-development` when a failing/regression test adds value; `verification-before-completion` when explicitly invoked. Verification remains required even without loading a skill.
- The three Superpowers skills are explicit-only. Use `$skill-name` or the client's skill picker to load one; once selected, follow its instructions. The full Superpowers methodology is not installed or made the governing workflow.
- If a tool is missing, report it and use the native capability when adequate; do not invent tool calls or install extra frameworks to compensate.

## Adopting existing projects

When asked to adopt this workflow, migrate the process, not the project. Preserve code, Git history, OKF/docs, design decisions, Issues/PRs, technical rules, and project-specific commands.

Reconcile only conflicting workflow instructions, including obsolete fixed-agent routing in local AGENTS.md, overrides, skills, hooks, or .codex settings. Inspect before changing; keep a recoverable diff/backup and do not delete unrelated agents or configuration. Do not change every project merely because global guidance was updated.
