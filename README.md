# Simple Workflow for Codex

Um workflow simples, econômico em tokens e reutilizável para executar projetos no Codex — tanto projetos novos quanto projetos que já estão em andamento.

A proposta não é substituir o funcionamento nativo do Codex. O workflow usa as peças que o Codex já oferece (`AGENTS.md`, Plan Mode, subagentes, skills, MCP e Git/GitHub) e adiciona apenas regras claras para escolher **quem planeja, quem executa, quando revisar e quando carregar ferramentas especializadas**.

## Objetivos

- manter o workflow pequeno e previsível;
- gastar modelos mais caros apenas onde eles agregam valor;
- evitar múltiplos agentes fazendo o mesmo trabalho;
- carregar ferramentas especializadas somente quando forem relevantes;
- preservar contexto e conhecimento já existentes em projetos em andamento;
- usar GitHub Issues como fonte de trabalho, sem criar um backlog paralelo;
- estruturar Issues de implementação para que o Luna receba trabalho claro, verificável e com pouca ambiguidade;
- usar OKF como conhecimento do projeto, sem transformá-lo em gerenciador de tarefas;
- conversar com o usuário em português e em linguagem acessível, ensinando conceitos de programação gradualmente.

## Modelos

| Papel | Modelo | Esforço | Uso |
|---|---|---:|---|
| Orquestrador padrão | GPT-5.6 Sol | Medium | trabalho normal e decisões já relativamente claras |
| Planejamento com Sol | GPT-5.6 Sol | High | Plan Mode, problemas difíceis dentro de uma arquitetura conhecida |
| Orquestrador para alta ambiguidade | GPT-6 Astra | Low | arquitetura nova, muitas decisões conectadas ou alto grau de incerteza |
| Planejamento com Astra | GPT-6 Astra | Medium | Plan Mode em problemas realmente arquiteturais |
| Executor | GPT-5.6 Luna | xhigh | implementação de uma tarefa já delimitada |
| Revisor | GPT-5.6 Terra | High | revisão independente somente quando o risco justificar |

### Regra Sol x Astra

Use **Sol** quando já for possível dizer razoavelmente *o que precisa ser feito e onde a solução vive*.

Use **Astra** quando o principal problema ainda for descobrir *qual arquitetura, direção ou estratégia é a correta*.

O esforço maior entra principalmente no **Plan Mode**. Não use Astra só porque uma tarefa é grande.

## Fluxo principal

```text
Você
  ↓
Orquestrador (Sol ou Astra)
  ↓
entende intenção + lê apenas o contexto necessário
  ↓
Plan Mode somente se necessário
  ↓
cria/ajusta Issues executáveis pelo Luna
  ↓
Luna xhigh (executor)
  ↓
verificação
  ↓
review gate?
  ├─ não → concluir
  └─ sim → Terra high (read-only)
               ↓
           findings?
           ├─ não → concluir
           └─ sim → nova tarefa delimitada → Luna
```

Para alterações triviais, mecânicas e de risco muito baixo, o orquestrador pode executar diretamente quando criar um subagente custaria mais contexto do que a própria mudança.

## GitHub Issues pensadas para o Luna

O Luna é usado como executor depois que as decisões importantes já foram tomadas. Por isso, o planejamento deve considerar **como o trabalho será executado**, e não apenas descrever a feature em alto nível.

Antes de entregar uma Issue ao Luna, Sol ou Astra verifica se ela é uma unidade de implementação adequada.

Uma Issue está no tamanho certo quando, de forma prática:

- possui **um resultado coerente**;
- as decisões arquiteturais relevantes já foram resolvidas;
- contém contexto suficiente para executar sem redescobrir o projeto inteiro;
- tem critérios claros de aceitação;
- pode ser verificada de forma independente;
- deixa explícito o que está fora de escopo quando isso evita expansão acidental.

Se uma única Issue obrigaria o Luna a tomar novas decisões arquiteturais, coordenar vários resultados pouco relacionados ou refazer trabalho anterior conforme novas decisões aparecem, o orquestrador deve **dividi-la antes da execução**.

Isso pode aumentar o número de Issues quando necessário, mas o objetivo não é produzir Issues pequenas por regra. Não existem limites artificiais de número de arquivos, linhas de código ou duração. Uma alteração grande e mecânica pode continuar sendo uma única Issue; uma alteração pequena, mas arquiteturalmente ambígua, pode precisar ser planejada antes.

Exemplo:

```text
#200 Open Finance                     ← feature/objetivo maior
├── #201 Conectar uma instituição
├── #202 Importar contas e saldos
├── #203 Importar transações
└── #204 Tratar perda de conexão
```

A Issue de nível mais alto pode continuar servindo para acompanhamento da feature. O Luna recebe as Issues de implementação já delimitadas.

### A Issue é o pacote de execução

Sempre que possível, a própria GitHub Issue deve conter o necessário para o executor:

```markdown
## Objetivo
O resultado que deve existir ao terminar.

## Contexto
Somente o contexto necessário para esta mudança.

## Escopo
O que esta Issue cobre.

## Critérios de aceitação
- resultado A
- resultado B

## Fora de escopo
O que deliberadamente fica para outra Issue.
```

Esse formato é uma orientação, não uma obrigação burocrática. Uma Issue simples pode ser muito menor.

O workflow **não cria `task.md`, `plan.md`, handoff ou outro backlog paralelo** apenas para repetir o conteúdo da Issue.

Se o Luna descobrir durante a execução que a Issue ainda exige uma decisão importante ou está ampla demais, ele deve parar e devolver o bloqueio ao orquestrador. Sol/Astra então esclarece ou divide o trabalho antes de continuar.

## Ferramentas sob demanda

Estar instalado **não significa participar de toda tarefa**.

### Open Design

Usado para descoberta visual, direção de UX/UI, protótipos e design system quando a tarefa realmente envolve design.

Projeto: https://github.com/nexu-io/open-design

### Impeccable

Usado depois ou durante trabalhos de interface quando uma auditoria, crítica, hardening ou polish visual/UX realmente agregar valor.

Projeto: https://github.com/pbakaus/impeccable

### Modern Web Guidance

Usado pelo executor em trabalhos Web quando HTML, CSS, DOM, APIs do navegador, acessibilidade, compatibilidade ou performance da plataforma Web forem relevantes. Ele recupera orientação específica em vez de despejar toda a documentação no contexto.

Projeto: https://github.com/GoogleChrome/modern-web-guidance

### Superpowers — somente três skills

O plugin completo **não faz parte deste workflow**, pois ele traz uma metodologia própria que se sobreporia ao fluxo nativo do Codex.

A V1 usa somente:

- `systematic-debugging` — quando a causa de um bug não está clara ou tentativas anteriores falharam;
- `test-driven-development` — quando um teste de regressão/falha realmente ajuda a provar o comportamento;
- `verification-before-completion` — antes de declarar uma tarefa concluída.

Essas skills são instaladas como skills pessoais e configuradas para não assumir o fluxo automaticamente.

Projeto: https://github.com/obra/superpowers

## OKF e GitHub Issues

O workflow mantém responsabilidades separadas:

```text
GitHub Issues = o que precisa ser feito
OKF          = o que sabemos sobre o projeto
```

Projetos existentes podem continuar usando seu OKF atual. O workflow não recria, converte ou duplica esse conteúdo sem necessidade.

Issues existentes também são preservadas. Ao adotar o workflow em um projeto em andamento, somente trabalho **ainda não concluído** que esteja amplo ou ambíguo demais para o Luna deve ser reestruturado; não é necessário reescrever o histórico do projeto.

Especificação OKF: https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md

## Instalação

### Pré-requisitos

- macOS;
- Codex instalado e atualizado;
- Git;
- Node.js/npm (`npx`) para Impeccable e Modern Web Guidance;
- Open Design instalado caso você queira usar a integração de design.

> Para GPT-6 Astra no Codex, use uma versão atual do Codex. A disponibilidade do modelo também depende da sua conta/plano.

### 1. Clone este repositório

```bash
git clone https://github.com/DBSN-code/simple-workflow.git
cd simple-workflow
```

### 2. Execute o instalador

```bash
chmod +x install.sh
./install.sh
```

O instalador:

1. cria backup do `~/.codex/AGENTS.md` atual, se existir;
2. instala o workflow global em `~/.codex/AGENTS.md`;
3. instala os agentes `executor` e `reviewer` em `~/.codex/agents/`;
4. ajusta somente as chaves deste workflow em `~/.codex/config.toml`, preservando as demais configurações;
5. instala o perfil opcional `astra`;
6. instala somente as três skills selecionadas do Superpowers;
7. tenta instalar/configurar Impeccable, Modern Web Guidance e Open Design para Codex.

O script cria backups antes de substituir arquivos do Simple Workflow.

## Como começar a usar

Depois da instalação, feche e abra novamente o Codex.

### Projeto novo

Abra o diretório do novo projeto no Codex e converse normalmente. O workflow global já estará ativo. Você não precisa usar um prompt especial para cada tarefa.

Por padrão, use **Sol Medium**. Entre em Plan Mode quando a tarefa realmente precisar de planejamento; a configuração sobe o esforço do Sol para **High** automaticamente.

Quando o planejamento gerar trabalho para implementação, Sol/Astra deve estruturar as GitHub Issues já pensando na execução pelo Luna.

### Projeto existente

Abra o projeto e, na primeira conversa após adotar o workflow, use:

> Adote o Simple Workflow neste projeto. Preserve todo o conhecimento e contexto existentes, incluindo OKF, documentação, decisões, GitHub Issues e regras técnicas válidas. Identifique instruções/metodologias antigas de workflow que conflitam com o Simple Workflow e substitua somente essa parte. Não recrie nem duplique conhecimento existente.

Isso é uma **migração do processo**, não uma reinicialização do projeto.

O Codex deve separar:

- **conhecimento e regras técnicas** → preservar;
- **workflow/metodologia antiga conflitante** → substituir;
- **material histórico** → manter quando ainda tiver valor como contexto;
- **Issues em andamento amplas demais para o Luna** → dividir somente quando isso reduzir ambiguidade ou retrabalho.

### Quando usar Astra

No Codex App, selecione **GPT-6 Astra / Low** antes de iniciar uma tarefa cujo problema principal seja arquitetura ou forte ambiguidade. Ao entrar em Plan Mode, use **Medium**.

No Codex CLI, o instalador também cria o perfil `astra`:

```bash
codex --profile astra
```

Para o restante do trabalho, continue com Sol como padrão.

## Comunicação com o usuário

O Simple Workflow assume que o usuário pode não ser desenvolvedor profissional.

O Codex deve:

- conversar em português do Brasil por padrão;
- usar linguagem simples antes do jargão;
- quando um termo técnico importante surgir, dizer o nome correto e explicar rapidamente o que ele significa;
- evitar repetir explicações de conceitos que o usuário já demonstrou entender;
- explicar decisões importantes em termos de consequência prática;
- não despejar logs, stack traces ou detalhes internos sem necessidade;
- no fechamento de uma tarefa, incluir no máximo um pequeno aprendizado técnico quando houver algo útil para ensinar.

O objetivo é que a pessoa consiga conduzir o projeto desde o primeiro dia e, ao mesmo tempo, aprenda programação gradualmente ao longo das tarefas.

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
        └── reviewer.toml
```

## Princípio central

> **Use o mínimo de processo e contexto necessário para concluir a tarefa com segurança.**

Se uma ferramenta, agente, documento ou etapa não muda a qualidade da decisão atual, ela não deve entrar no caminho apenas porque está disponível.
