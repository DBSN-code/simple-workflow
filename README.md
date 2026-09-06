# Simple Workflow for Codex

Um workflow simples, econômico em tokens e reutilizável para executar projetos no Codex — tanto projetos novos quanto projetos que já estão em andamento.

A proposta não é substituir o funcionamento nativo do Codex. O workflow usa as peças que o Codex já oferece (`AGENTS.md`, Plan Mode, subagentes, skills, MCP e Git/GitHub) e adiciona apenas regras claras para escolher **quem planeja, quem executa, quando revisar, quanto contexto carregar e quando usar ferramentas especializadas**.

## Objetivos

- manter o workflow pequeno e previsível;
- gastar modelos mais caros apenas onde agregam valor;
- evitar múltiplos agentes fazendo o mesmo trabalho;
- carregar ferramentas especializadas somente quando relevantes;
- preservar contexto e conhecimento existentes em projetos em andamento;
- usar GitHub Issues como fonte de trabalho, sem backlog paralelo;
- estruturar Issues para que Luna receba trabalho claro e verificável;
- usar OKF somente para conhecimento durável;
- evitar conversas longas carregando contexto que já não ajuda;
- conversar com o usuário em português e linguagem acessível, ensinando programação gradualmente.

## Modelos

| Papel | Modelo | Esforço | Uso |
|---|---|---:|---|
| Orquestrador padrão | GPT-5.6 Sol | Medium | trabalho normal e decisões relativamente claras |
| Planejamento com Sol | GPT-5.6 Sol | High | Plan Mode e problemas difíceis dentro de arquitetura conhecida |
| Orquestrador para alta ambiguidade | GPT-6 Astra | Low | arquitetura nova, muitas decisões conectadas ou alta incerteza |
| Planejamento com Astra | GPT-6 Astra | Medium | Plan Mode em problemas realmente arquiteturais |
| Executor padrão | GPT-5.6 Luna | High | implementação clara e convencional de uma Issue delimitada |
| Executor profundo | GPT-5.6 Luna | xhigh | arquitetura decidida, mas implementação local exige raciocínio especialmente difícil |
| Revisor | GPT-5.6 Terra | High | revisão independente somente quando o risco justificar |

### Regra Sol x Astra

Use **Sol** quando já for possível dizer razoavelmente *o que precisa ser feito e onde a solução vive*.

Use **Astra** quando o principal problema ainda for descobrir *qual arquitetura, direção ou estratégia é a correta*.

Não use Astra apenas porque uma tarefa é grande.

### Regra Luna High x Luna xhigh

**Luna High é o executor padrão.** Use quando a Issue já estiver delimitada e a implementação for convencional: UI comum, CRUD, integração conhecida, refactor localizado, testes normais ou alterações em vários arquivos sem raciocínio particularmente traiçoeiro.

Use **Luna xhigh (`executor_deep`)** somente quando a arquitetura e o escopo já estiverem resolvidos, mas a implementação exigir raciocínio profundo dentro desses limites, por exemplo:

- lógica ou algoritmo delicado;
- muitos casos-limite interagindo;
- transições de estado complexas;
- concorrência, sincronização ou cache;
- comportamento difícil distribuído entre módulos;
- risco alto de uma solução aparentemente correta falhar em casos menos óbvios.

Se a dificuldade vier de **arquitetura não resolvida ou requisitos vagos**, não aumente Luna para xhigh. O trabalho volta para Sol/Astra.

```text
Issue delimitada
      ↓
implementação convencional?
      ├─ sim → Luna High
      └─ não
          ↓
arquitetura já está resolvida?
      ├─ sim → Luna xhigh
      └─ não → Sol/Astra
```

## Fluxo principal

```text
Você
  ↓
Orquestrador (Sol ou Astra)
  ↓
entende intenção + lê apenas contexto necessário
  ↓
Plan Mode somente se necessário
  ↓
cria/ajusta Issue executável pelo Luna
  ↓
Luna High ── ou ── Luna xhigh quando execução exigir
  ↓
verificação
  ↓
review gate?
  ├─ não → concluir
  └─ sim → Terra High (read-only, contexto mínimo primeiro)
               ↓
           findings?
           ├─ não → concluir
           └─ sim → nova slice → Luna
```

Para alterações triviais, mecânicas e de risco muito baixo, o próprio orquestrador pode executar diretamente quando criar um subagente custaria mais contexto do que a mudança.

## GitHub Issues pensadas para o Luna

O planejamento considera **como o trabalho será executado**, e não apenas descreve a feature em alto nível.

Uma Issue está no tamanho certo quando, de forma prática:

- possui um resultado coerente;
- as decisões arquiteturais relevantes já foram resolvidas;
- contém contexto suficiente sem obrigar o executor a redescobrir o projeto inteiro;
- tem critérios claros de aceitação;
- pode ser verificada de forma independente;
- deixa explícito o que está fora de escopo quando isso evita expansão acidental.

Se manter tudo em uma Issue obrigaria Luna a tomar decisões arquiteturais, coordenar resultados pouco relacionados ou refazer trabalho conforme decisões posteriores aparecem, Sol/Astra deve **dividir antes da execução**.

Não existem limites artificiais por número de arquivos, linhas ou duração. Evite micro-Issues cujo custo de coordenação seja maior que a implementação.

Quando útil, mantenha uma Issue maior para a feature e Issues menores para implementação:

```text
#200 Open Finance
├── #201 Conectar uma instituição
├── #202 Importar contas e saldos
├── #203 Importar transações
└── #204 Tratar perda de conexão
```

### A Issue é o pacote de execução

Sempre que possível, a própria GitHub Issue contém o necessário:

```markdown
## Objetivo
O resultado que deve existir ao terminar.

## Contexto
Somente o contexto necessário.

## Escopo
O que esta Issue cobre.

## Critérios de aceitação
- resultado A
- resultado B

## Fora de escopo
O que deliberadamente fica para outra Issue.
```

O formato é uma orientação, não burocracia. Uma Issue simples pode ser muito menor.

O workflow **não cria `task.md`, `plan.md`, handoff ou backlog paralelo** apenas para repetir a Issue.

## Política de conversas

Para evitar carregar histórico desnecessário:

- prefira **uma conversa por Issue ou unidade coerente de trabalho**;
- continue na mesma conversa enquanto a próxima ação depender materialmente do raciocínio, evidências ou decisões ainda ativos nela;
- depois que a Issue/unidade terminar, prefira uma nova conversa para uma Issue independente;
- não mantenha uma conversa longa apenas para “não perder contexto” quando GitHub Issues, OKF, código e Git já guardam o estado durável;
- não crie documento de handoff apenas para transportar histórico da conversa.

A conversa é contexto de trabalho temporário. O projeto é a fonte durável.

## OKF e GitHub Issues

O workflow mantém responsabilidades separadas:

```text
GitHub Issues = o que precisa ser feito
OKF          = o que sabemos sobre o projeto
```

### Gate de escrita no OKF

Não atualize OKF simplesmente porque uma tarefa terminou.

Escreva ou altere OKF somente quando surgir ou mudar **conhecimento durável** que trabalho futuro precisa conhecer, como:

- arquitetura;
- decisão importante;
- regra de domínio;
- comportamento de integração;
- restrição estável;
- verdade relevante sobre o funcionamento do sistema.

Não coloque em OKF:

- progresso rotineiro;
- status de tarefa;
- narrativa de passos concluídos;
- investigação temporária;
- informação já representada adequadamente por Issue, PR ou código.

Quando precisar atualizar, prefira o menor documento relevante em vez de reescrever grandes partes do conhecimento.

Projetos existentes podem continuar usando seu OKF atual. O workflow não recria, converte ou duplica esse conteúdo sem necessidade.

Especificação OKF: https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md

## Review com contexto mínimo

Terra não começa redescobrindo o projeto inteiro.

O contexto inicial do reviewer deve ser, sempre que suficiente:

```text
Issue/requisitos
+ diff concluído
+ critérios de aceitação
+ regras de projeto diretamente relevantes
```

Só depois ele abre código adicional, OKF, arquitetura, histórico ou módulos relacionados quando uma dependência, finding, contrato ou incerteza concreta exigir isso.

Terra continua sendo usado somente quando o **review gate** disparar: segurança, dados persistentes, lógica financeira, concorrência/estado complexo, contratos públicos, infraestrutura, verificação fraca, incerteza do executor, múltiplas correções ou risco material antes de merge.

## Ferramentas sob demanda

Estar instalado **não significa participar de toda tarefa**.

### Open Design

Usado para descoberta visual, direção de UX/UI, protótipos e design system quando a tarefa realmente envolve design.

Projeto: https://github.com/nexu-io/open-design

### Impeccable

Usado em trabalhos de interface quando auditoria, crítica, hardening ou polish visual/UX realmente agregar valor.

Projeto: https://github.com/pbakaus/impeccable

### Modern Web Guidance

Usado pelo executor em trabalhos Web quando HTML, CSS, DOM, APIs do navegador, acessibilidade, compatibilidade ou performance forem relevantes. Recupera somente orientação específica para a tarefa.

Projeto: https://github.com/GoogleChrome/modern-web-guidance

### Superpowers — somente três skills

O plugin completo não faz parte do workflow. A V1 usa apenas:

- `systematic-debugging` — causa de bug não clara ou tentativas anteriores falharam;
- `test-driven-development` — teste de regressão/falha realmente ajuda a provar comportamento;
- `verification-before-completion` — antes de declarar uma tarefa concluída.

Elas ficam instaladas como skills pessoais com invocação implícita desativada.

Projeto: https://github.com/obra/superpowers

## Instalação

### Pré-requisitos

- macOS;
- Codex instalado e atualizado;
- Git;
- Node.js/npm (`npx`) para Impeccable e Modern Web Guidance;
- Open Design instalado caso queira a integração de design.

### 1. Clone

```bash
git clone https://github.com/DBSN-code/simple-workflow.git
cd simple-workflow
```

### 2. Instale

```bash
chmod +x install.sh
./install.sh
```

O instalador:

1. cria backup do `~/.codex/AGENTS.md` atual, se existir;
2. instala o workflow global em `~/.codex/AGENTS.md`;
3. instala `executor` (Luna High), `executor_deep` (Luna xhigh) e `reviewer` (Terra High) em `~/.codex/agents/`;
4. ajusta somente as chaves deste workflow em `~/.codex/config.toml`, preservando demais configurações;
5. instala o perfil opcional `astra`;
6. instala somente as três skills selecionadas do Superpowers;
7. tenta instalar/configurar Impeccable, Modern Web Guidance e Open Design para Codex.

O script cria backups antes de substituir arquivos do Simple Workflow.

## Como começar a usar

Depois da instalação, feche e abra novamente o Codex.

### Projeto novo

Abra o projeto no Codex e converse normalmente. O workflow global já estará ativo; não é necessário um prompt especial para cada tarefa.

Use **Sol Medium** por padrão. Plan Mode sobe Sol para **High**. Quando surgir arquitetura realmente ambígua, use **Astra Low** e **Medium** em Plan Mode.

### Projeto existente

Na primeira conversa após adotar o workflow, use:

> Adote o Simple Workflow neste projeto. Preserve todo o conhecimento e contexto existentes, incluindo OKF, documentação, decisões, GitHub Issues e regras técnicas válidas. Identifique instruções/metodologias antigas de workflow que conflitam com o Simple Workflow e substitua somente essa parte. Não recrie nem duplique conhecimento existente.

Isso é uma **migração do processo**, não uma reinicialização do projeto.

Preserve conhecimento, histórico e regras técnicas. Reestruture apenas workflow conflitante e Issues ainda pendentes que estejam amplas ou ambíguas demais para o executor.

### Astra no CLI

O instalador cria o perfil opcional:

```bash
codex --profile astra
```

## Comunicação com o usuário

O Simple Workflow assume que o usuário pode não ser desenvolvedor profissional.

O Codex deve:

- conversar em português do Brasil por padrão;
- usar linguagem simples antes do jargão;
- explicar rapidamente termos técnicos importantes;
- não repetir conceitos que o usuário já demonstrou entender;
- explicar decisões em termos de consequência prática;
- evitar despejar logs e detalhes internos sem necessidade;
- no fechamento, incluir no máximo um pequeno `Para você aprender` quando houver algo realmente útil.

## Estrutura do repositório

```text
simple-workflow/
├── README.md
├── install.sh
└── codex/
    ├── AGENTS.md
    ├── astra.config.toml
    ├── config.defaults.toml
    └── agents/
        ├── executor.toml
        ├── executor_deep.toml
        └── reviewer.toml
```

## Princípio central

> **Use o mínimo de processo e contexto necessário para concluir a tarefa com segurança.**

Se uma ferramenta, agente, documento, conversa antiga ou etapa não muda a qualidade da decisão atual, ela não deve entrar no caminho apenas porque está disponível.
