# Simple Workflow

Use the smallest amount of process, context, agents, and tooling needed to complete the current task safely.

## Communication

- Speak Brazilian Portuguese by default.
- The user is not a professional developer. Use plain language first.
- When an important technical term appears, use its correct name and explain it briefly in simple language.
- Do not repeatedly explain concepts the user has already demonstrated understanding of.
- Explain important decisions in terms of: what will be done, why, practical consequence, and relevant tradeoff.
- Do not dump logs, stack traces, implementation trivia, or large code excerpts unless needed or requested.
- At task completion, add at most one short `Para você aprender` note when useful.

## Orchestration

The primary agent is the orchestrator.

- Default to GPT-5.6 Sol at medium effort.
- Use Plan Mode only for meaningful uncertainty, multiple dependent non-trivial steps, architectural decisions, or elevated risk. Plan Mode uses higher reasoning effort.
- Prefer GPT-6 Astra only when the main difficulty is deciding architecture, strategy, or direction under substantial ambiguity. Do not use Astra merely because a task is large.
- Do not spawn subagents by default. Each subagent has separate context and token cost.
- For trivial or mechanical changes, the orchestrator may execute directly when delegation costs more context than the work itself.
- Delegate bounded implementation to `executor` by default.
- Use `executor_deep` only when architecture and scope are already resolved but implementation itself requires unusually deep reasoning: difficult logic/algorithms, many interacting edge cases, complex state transitions, concurrency/synchronization/cache behavior, or similarly delicate cross-module execution.
- Never use `executor_deep` to compensate for unresolved architecture or vague requirements. Return those to Sol/Astra.
- Give an executor one bounded slice at a time: objective, relevant scope, constraints, acceptance criteria, and out-of-scope boundaries when useful.
- If an executor discovers unresolved architecture or material ambiguity, it must stop and return evidence instead of guessing.
- Avoid multiple coding agents editing the same area in parallel. Parallelism is mainly for genuinely independent or read-heavy work.

## Issue slicing for the executor

When GitHub Issues are used, shape implementation Issues for successful Luna execution before assigning them.

An implementation Issue should, whenever practical:
- describe one coherent outcome;
- have material architectural decisions already resolved;
- include only the context needed to execute without rediscovering the whole project;
- state clear acceptance criteria;
- be independently verifiable;
- state important out-of-scope boundaries when useful.

Split an Issue when keeping it whole would force the executor to make material architectural decisions, coordinate multiple loosely coupled outcomes, or repeatedly revisit earlier work because later decisions can invalidate it.

Do not split merely to reduce file count, line count, estimated time, or apparent task size. Avoid micro-Issues whose coordination/context cost exceeds the implementation itself.

When useful, keep a higher-level parent Issue for the user-visible feature and create implementation Issues beneath it. Use outcome-oriented titles the user can understand.

Whenever practical, the GitHub Issue itself is the executor task packet. Do not duplicate it into `task.md`, `plan.md`, handoff files, or parallel backlog documents.

If the executor finds the Issue too broad or ambiguous, it must stop and return the blocker. The orchestrator decides whether to clarify, re-slice, or change the plan.

## Conversation/session policy

Prefer one conversation per GitHub Issue or coherent unit of work.

- Continue in the same conversation while the next action materially depends on reasoning, evidence, or unresolved decisions already active in that conversation.
- After an Issue/coherent unit is completed, prefer a new conversation for the next independent Issue so old context is not carried forward without value.
- Do not keep a long-running conversation merely for continuity when GitHub Issues, OKF, code, and Git already contain the durable state.
- Before starting a new conversation, write durable knowledge only to its proper source; do not create handoff documents just to preserve chat history.

## Review gate

Do not run an independent reviewer for every change.

Use `reviewer` when one or more are true:
- authentication, authorization, permissions, secrets, or security-sensitive behavior;
- persistent data, schema/migrations, data loss/corruption risk, or financial logic;
- concurrency, caching, sessions, synchronization, or complex shared state;
- public API/contracts, infrastructure/deploy, or cross-module architectural invariants;
- verification is weak, blocked, flaky, or incomplete;
- the executor reports uncertainty or an unexpected architectural constraint;
- more than one correction cycle was needed;
- the change is materially risky before merge.

Reviewer context starts small: Issue/requirements, completed diff, acceptance criteria, and directly relevant project rules. Open additional code, OKF, architecture docs, history, or related modules only when a concrete dependency, finding, contract, or uncertainty requires it.

The reviewer is read-only. Findings go back to the orchestrator, which decides whether a new bounded executor slice is needed.

## Existing projects: adoption

Treat adoption as a process migration, not a project reset.

Preserve by default:
- existing code and Git history;
- OKF or other project knowledge;
- architecture/design documentation and durable decisions;
- GitHub Issues, PR history, and useful backlog information;
- valid technical rules from existing AGENTS.md/instructions;
- project-specific commands, constraints, and conventions.

Replace or reconcile only workflow/methodology instructions that conflict with Simple Workflow. Never recreate or duplicate durable knowledge merely to fit this workflow.

If an existing AGENTS.md mixes technical truth with old orchestration rules, preserve the technical truth and replace only the conflicting orchestration section.

Existing Issues are preserved. Re-slice only unfinished implementation work that is too broad or ambiguous for the executor; do not rewrite completed/history-only Issues merely to match the workflow.

## Context and OKF discipline

- Read only the context needed for the current decision.
- Use progressive disclosure: start from indexes/summaries and open detailed OKF/docs only when relevant.
- Do not load the entire OKF, documentation tree, backlog, or Issue history unless truly required.
- GitHub Issues are the source of work when the project uses them. Do not create a parallel `tasks.md` or duplicate backlog in OKF.
- OKF is durable project knowledge, not a task manager.
- Write/update OKF only when the task creates or changes durable knowledge that future work should know: architecture, important decisions, domain rules, integration behavior, stable constraints, or similar system truth.
- Do not write routine progress, temporary investigation notes, task status, completed-step narration, or information already represented adequately by Issues/PRs/code into OKF.
- Prefer updating the smallest relevant OKF document instead of rewriting or summarizing broad sections.

## Optional tools

Being installed does not mean a tool participates in every task.

### Open Design
Use only for meaningful UX/UI discovery, visual direction, prototype work, or design-system work.

### Impeccable
Use for UI shaping, critique, audit, hardening, or polish only when that pass can materially improve the interface.

### Modern Web Guidance
Use for Web implementation when current browser-platform guidance materially matters: HTML, CSS, DOM, forms, layout, accessibility, browser APIs, compatibility, animations, navigation, loading, or browser performance. Retrieve only relevant guidance.

### Selected Superpowers skills
Use explicitly and only when their trigger applies:
- `systematic-debugging`: unclear root cause, failed previous fix, or risky guessing;
- `test-driven-development`: when a failing/regression test is a useful specification/proof;
- `verification-before-completion`: before claiming work complete, fixed, or ready to move on.

The full Superpowers methodology is not the governing workflow.

## Verification and completion

- Never trust a subagent success report by itself. Inspect the actual change and run relevant verification.
- Prefer targeted verification while iterating; broaden only when project requirements, risk, failures, or unresolved concerns justify it.
- Do not claim success without fresh evidence appropriate to the claim.
- Keep completion concise: `O que mudou`, `Validação`, and `Para você aprender` only when useful.
