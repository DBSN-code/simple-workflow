# Simple Workflow for Codex

**Codex nativo + contexto organizado + ferramentas sob demanda + comunicação didática.**

Para projetos novos ou em andamento. Você descreve o resultado desejado e o modelo selecionado na conversa entende, planeja quando necessário, implementa e verifica o trabalho. Este repositório adiciona instruções pequenas para organizar esse uso; não cria um framework paralelo.

**Não há mais roteamento obrigatório entre Sol/Astra, Luna e Terra.** Não são instalados agentes personalizados nem impostos modelo, esforço de raciocínio ou permissões. Os subagentes nativos continuam disponíveis quando solicitados ou necessários a uma skill escolhida — não como etapa obrigatória de toda tarefa. [Referência oficial](https://developers.openai.com/codex/subagents).

## Como funciona

```text
Você descreve o resultado
         ↓
Codex consulta apenas o contexto relevante
         ↓
Planeja quando necessário
         ↓
Implementa e verifica
         ↓
Revisão adicional conforme o risco
         ↓
Conclui e registra somente o que precisa permanecer
```

Use o Plan Mode nativo para decisões importantes ou tarefas ambíguas; mudanças claras não precisam de um plano extenso. Use a revisão nativa, como `/review` quando disponível no cliente, para mudanças que justificam um olhar adicional. Uma revisão não implica automaticamente outro modelo. [Boas práticas do Codex](https://developers.openai.com/codex/learn/best-practices).

Modelo e esforço são escolhas suas no Codex, inclusive durante planejamento. O Simple Workflow não promete trocá-los automaticamente nem exige uma família específica de modelos ou assinatura. Remover a delegação fixa pode reduzir repasses de contexto, mas não garante menor custo total: isso depende do modelo e das tarefas.

## O que permanece

**GitHub Issues:** trabalho organizado em resultados claros, com contexto, limites e critérios de aceitação. Dividir apenas quando facilitar implementação, verificação ou acompanhamento, sem fragmentar artificialmente para um modelo específico. A própria Issue contém as instruções do trabalho; nenhum backlog paralelo é criado. O acesso ao GitHub precisa estar autenticado no ambiente do usuário; este instalador não fornece credenciais nem configura uma conta GitHub.

**OKF:** conhecimento durável do projeto — arquitetura, regras, integrações e decisões, incluindo documentação de design por tela/área. Consulta apenas ao material relevante e atualização apenas quando esse conhecimento mudar. Progresso e status ficam nas Issues/PRs. O OKF existente é preservado, sem conversão ou reescrita em massa. [Especificação OKF](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md).

**Conversas:** uma por unidade coerente de trabalho, não uma para o projeto inteiro. Continue enquanto as evidências e decisões anteriores ajudarem; abra outra para trabalho independente. Não é obrigatório trocar de conversa a cada Issue, nem criar um documento de repasse para transportar todo o histórico.

**Verificação e revisão:** conferir a mudança e executar as verificações adequadas antes de declarar sucesso. Revisão adicional para riscos relevantes: segurança, dados persistentes/financeiros, estado complexo, contratos, infraestrutura, verificações insuficientes ou correções repetidas. Começar pelo pedido e pelas alterações, ampliando a leitura quando necessário; não limitar a revisão cegamente ao diff.

**Comunicação:** português brasileiro e linguagem acessível. Explicar brevemente termos técnicos importantes, consequências das decisões e, quando útil, um pequeno `Para você aprender` ao concluir. Esse padrão pode ser ajustado por instruções suas; não é preciso conhecer programação para começar.

## Ferramentas disponíveis sob demanda

| Ferramenta | Quando agrega valor |
|---|---|
| [Open Design](https://github.com/nexu-io/open-design) | Direção visual, protótipos, UX/UI e design system. |
| [Impeccable](https://github.com/pbakaus/impeccable) | Crítica, auditoria e acabamento de interfaces. |
| [Modern Web Guidance](https://github.com/GoogleChrome/modern-web-guidance) | Orientação pontual sobre HTML/CSS, APIs do navegador, compatibilidade, acessibilidade e performance. |
| [Superpowers — seleção de três skills](https://github.com/obra/superpowers) | Investigação de bugs, testes antes da correção quando úteis e verificação de conclusão. |

A seleção do Superpowers contém somente `systematic-debugging`, `test-driven-development` e `verification-before-completion`. **Não instalamos seu plugin/framework completo.** As três skills novas são configuradas como explícitas: selecione a skill no Codex ou mencione, por exemplo, `$systematic-debugging`. Uma vez acionada, a skill segue suas próprias instruções. Verificar o trabalho continua sendo obrigatório mesmo sem carregar uma skill.

Não existe uma sequência automática Open Design → Impeccable → todas as outras ferramentas. Elas apoiam o agente que está trabalhando. Estar instalado não significa ser utilizado em cada tarefa; metadados e ferramentas ainda podem ter custo de contexto. [Como o Codex carrega skills](https://developers.openai.com/codex/skills).

## Instalar e começar

O instalador é voltado ao **macOS**, com Bash e Git disponíveis. O Codex deve estar instalado. Node/npm (`npx`) é usado somente pelos instaladores opcionais de Impeccable e Modern Web Guidance. Open Design precisa estar instalado para conectar seu MCP; não o baixamos automaticamente.

### Primeira instalação

```bash
git clone https://github.com/DBSN-code/simple-workflow.git
cd simple-workflow
bash install.sh --tools
```

`--tools` instala as regras e tenta preparar somente as ferramentas ausentes. No assistente do Modern Web Guidance, escolha **Codex + escopo global/usuário**. Instalações detectadas são reutilizadas, sem sobrescrever skills pessoais. Os instaladores externos rodam fora dos seus projetos; não instalamos hooks em cada projeto. O Open Design é conectado via seu CLI quando reconhecido; o comando `od` que já vem no macOS é outra ferramenta e não é usado por engano.

Instaladores externos podem pedir interação e dependem da rede. **Confira os avisos:** regras instaladas não significam que todas as integrações foram confirmadas. As ferramentas mantêm suas licenças próprias.

### Apenas instalar/atualizar as regras

```bash
bash install.sh
```

Essa opção não acessa a rede nem reinstala ferramentas. Instala as instruções globais e faz a migração conservadora da versão anterior, quando reconhecida.

O destino padrão é `~/.codex/AGENTS.md`; respeita `CODEX_HOME` quando definido. As skills pessoais usam `~/.agents/skills/`. Com `CODEX_HOME` personalizado, a integração MCP do Open Design deve ser conferida manualmente no destino correto.

Depois, **reabra o Codex e inicie uma conversa nova**, selecione modelo/esforço no cliente e converse normalmente. Para conferir sem modificar um projeto, peça:

> Diga quais instruções do Simple Workflow você carregou. Confirme se a execução é nativa, sem encaminhamento obrigatório para agentes personalizados. Não altere arquivos.

As regras globais podem ser sobrepostas por `AGENTS.override.md` ou instruções locais do projeto. O instalador avisa sobre o override global, mas não o apaga. [Hierarquia oficial do AGENTS.md](https://developers.openai.com/codex/guides/agents-md).

### Projeto novo

Abra a pasta do projeto no Codex e descreva o resultado. Por exemplo:

> Quero construir um sistema para organizar pedidos. Primeiro entenda o que preciso e proponha a abordagem em linguagem simples, antes de implementar.

### Projeto existente

Use uma vez, dentro do projeto:

> Adote o Simple Workflow nativo neste projeto. Preserve código, histórico, OKF, documentação de design, decisões, Issues e regras técnicas. Remova somente instruções antigas que obriguem a divisão entre orquestrador, executor e revisor. Confira também os AGENTS.md locais, overrides, skills, hooks e configurações .codex que possam manter esse roteamento. Não recrie conhecimento nem altere configurações não relacionadas. Mostre o que mudou e o que foi preservado.

A adoção é uma mudança de processo, não uma reinicialização. **Atualizar regras globais não altera automaticamente todos os seus projetos.**

## Atualizar quem usava a versão com Luna/Terra

Na cópia local deste repositório:

```bash
git pull --ff-only
bash install.sh
```

A atualização:

- troca as instruções antigas conhecidas pela orientação nativa;
- desativa somente cópias exatas e reconhecidas dos antigos `executor.toml`, `executor_deep.toml` e `reviewer.toml`, com backup;
- remove apenas os blocos exatos, não personalizados, de modelos/perfil Astra gerados pelo instalador anterior; preserva modelos pessoais, outros perfis, MCPs e permissões;
- não reinstala nem remove Open Design, Impeccable, Modern Web Guidance ou as três skills selecionadas.

A partir desta versão, o conteúdo gerenciado no `AGENTS.md` fica entre marcadores; texto pessoal fora deles é preservado nas próximas atualizações.

**Arquivos antigos personalizados exigem cuidado.** Um `AGENTS.md` antigo modificado interrompe a instalação antes de sobrescrevê-lo. Peça ao Codex para mesclar suas regras com `codex/AGENTS.md` e delimitar apenas a parte do Simple Workflow com os marcadores `<!-- simple-workflow:begin -->` e `<!-- simple-workflow:end -->`, mantendo regras pessoais fora. Agentes personalizados, links simbólicos e configurações ambíguas são preservados com aviso, não apagados. Se o perfil Astra ainda estiver explicitamente selecionado no arquivo, ele é mantido; escolha outro perfil no Codex antes de removê-lo.

Backups ficam em `~/.codex/simple-workflow-backups/` (ou no `CODEX_HOME` escolhido), em uma pasta por atualização. Para reverter, copie os arquivos dessa pasta de volta aos caminhos relativos dentro do seu `CODEX_HOME`. Não restaure uma configuração inteira se já fez alterações posteriores que deseja manter.

Nenhuma migração modifica suas Issues, o OKF ou o código dos outros projetos. Não há script de instalação de dependências das aplicações.

## Estrutura

```text
simple-workflow/
├── README.md
├── install.sh
├── codex/AGENTS.md
├── scripts/migrate-config.awk
└── tests/install.test.sh
```

O script de migração existe apenas para retirar configurações legadas com segurança; não é um componente executado a cada conversa.

### Validação do instalador

```bash
bash -n install.sh
bash tests/install.test.sh
```

Os testes usam diretórios temporários e simulações dos instaladores externos, sem acessar a rede ou sua configuração pessoal. Os cenários legados leem o histórico Git local; use um clone com histórico, não apenas o ZIP. Eles verificam migração, backups, reinstalação, preservação de personalizações e seleção das ferramentas — **não validam o aplicativo Codex nem os serviços/modelos reais**. A instalação ponta a ponta no seu Mac ainda precisa ser conferida no cliente.

> Menos repasses entre agentes e menos contexto desnecessário; a qualidade continua sendo demonstrada pela verificação do resultado.
