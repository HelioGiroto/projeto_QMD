# projeto_QMD

Autor: Hélio Giroto
Data de criação: 19/10/2026

Descrição

Projeto para consultar transcrições de vídeo com busca híbrida e responder pelo Hermes com trechos e fontes.

Objetivo

Disponibilizar uma consulta confiável às transcrições, combinando recuperação lexical e semântica, evidências e respostas pelo Hermes.

O que faz

- Indexa arquivos Markdown contendo transcrições.
- Usa busca lexical e semântica para localizar trechos relevantes.
- Permite perguntas em linguagem natural pelo Hermes.
- Recupera evidências antes de gerar a resposta.
- Deve distinguir citação literal, síntese e inferência.
- Deve informar quando não existe evidência suficiente.
- Como as transcrições não possuem timestamps, as fontes devem indicar o arquivo Markdown, o vídeo e, quando necessário, o trecho ou número de linha.

Tecnologias previstas

- Hermes Agent: agente, persona, regras de resposta e interface.
- QMD: busca BM25, busca semântica e reranking local.
- MCP: conexão entre o Hermes e as ferramentas do QMD.
- Markdown: formato das transcrições e metadados.
- Node.js 22 ou superior: execução do QMD.
- Modelos locais do QMD: embeddings, expansão de consulta e reranking.

Fonte de dados

As transcrições sem timestamp são a fonte oficial de informações de todos os projetos e ficam em:

/home/clone/transcricoes_md

Identificação das fontes

As respostas devem citar o nome do arquivo Markdown e o título/ID do vídeo. Como não há timestamps, o sistema não deve inventar minutos ou segundos. Se for necessário localizar um trecho, pode usar número de linha, hash do chunk ou uma citação literal.

Fluxo previsto

transcrições Markdown -> QMD -> MCP -> Hermes -> resposta com citações

Princípio de fidelidade

O QMD encontra evidências; ele não é responsável pela personalidade do autor. O Hermes deve responder somente com base nos trechos recuperados e preservar a proveniência dos vídeos.

Status

Projeto principal do experimento. O MVP deve começar com transcrições sem timestamp, QMD, MCP e um perfil Hermes com regras de citação.

Gateway

O nome a ser chamado no gateway, inclusive no WhatsApp, será Sand. O usuário poderá escrever, por exemplo: “Sand, o que o autor diz sobre disciplina?”. Sand responderá em primeira pessoa como autor virtual baseado nas transcrições, sem afirmar ser a pessoa real.

Implementação atual

Arquivos principais:

- start.sh: verifica o ambiente e inicia o chat Hermes.
- ingest.sh: atualiza a coleção e tenta gerar embeddings.
- query.sh: faz consulta direta; usa BM25 enquanto embeddings não estiverem disponíveis.
- status.sh: mostra o estado do QMD, da coleção e do MCP.
- chat.sh: abre o chat com o perfil Sand.
- qmd_mcp.py: servidor MCP local que expõe busca lexical, recuperação de documentos e status do QMD.
- SOUL.md: referência da persona do projeto.
- .env.example: parâmetros ajustáveis sem segredos.

Pré-requisitos verificados

- Hermes Agent instalado.
- Node.js e npm instalados.
- QMD instalado com @tobilu/qmd.
- 78 transcrições indexadas na coleção sand-transcricoes.
- Perfil Hermes sand criado.
- Servidor MCP sand-qmd configurado e testado.

Comandos

Verificar tudo sem abrir o chat:

`cd /home/clone/projeto_QMD`
`./start.sh --check`

Atualizar a coleção:

`./ingest.sh`

Consultar QMD diretamente:

`./query.sh "AI business demand"`

Ver o estado:

`./status.sh`

Abrir o chat Sand:

`./chat.sh`

ou:

`hermes -p sand chat`

MCP

O perfil sand usa o servidor MCP local sand-qmd, que chama a busca BM25 do QMD e expõe as ferramentas search_transcripts, get_transcript e qmd_status. O servidor nativo qmd foi substituído nesta primeira implementação porque a busca híbrida tentou carregar modelos locais e foi encerrada por falta de memória no ambiente atual.

Limitação atual de embeddings

O índice tem 78 documentos, mas a geração do embeddinggemma-300M foi encerrada com código 137 por falta de memória disponível e ausência de swap. O sistema continua funcional usando busca lexical BM25 pelo MCP sand-qmd. A busca semântica e o reranking serão ativados quando houver memória suficiente ou quando o QMD rodar em uma máquina com mais recursos.

Teste realizado

Foi executado um chat real com o perfil sand. Hermes chamou as ferramentas MCP de busca e recuperação, consultou vários arquivos de transcrição e produziu uma resposta em português em primeira pessoa com nomes de arquivos como fontes.

Status

MVP funcional em modo lexical: transcrições -> QMD BM25 -> MCP sand-qmd -> Hermes/Sand. A etapa pendente é habilitar embeddings para recuperar paráfrases e usar reranking.

Instalação em outra VPS

A instalação precisa ser feita em uma VPS com acesso à internet, Node.js 22 ou superior, Python disponível pelo Hermes e espaço para o Hermes, QMD e seus modelos. As transcrições devem ser copiadas para /home/clone/transcricoes_md ou o caminho TRANSCRIPTS_DIR deve ser ajustado.

1. Instale o Hermes Agent na VPS seguindo a documentação oficial.
2. Copie esta pasta projeto_QMD e a pasta transcricoes_md para a VPS, preservando os arquivos Markdown.
3. Entre na pasta do projeto:

`cd /home/clone/projeto_QMD`

4. Execute o instalador local:

`./setup_vps.sh`

O setup_vps.sh instala QMD se necessário, cria ou reutiliza o perfil Hermes sand, copia o SOUL.md para o perfil, cria a coleção QMD, registra o contexto, localiza um Python do Hermes com MCP, configura o servidor sand-qmd e atualiza o índice.

O script não configura credenciais de modelo, WhatsApp ou outros segredos automaticamente. Isso deve ser feito de forma interativa no servidor, sem colocar segredos no repositório.

5. Verifique a instalação:

`./start.sh --check`

6. Faça uma consulta direta de diagnóstico:

`./query.sh "AI business demand"`

Chamando pelo Hermes

Depois da instalação, abra uma conversa interativa:

`cd /home/clone/projeto_QMD`
`./chat.sh`

ou:

`hermes -p sand chat`

O perfil sand usa o MCP sand-qmd. O usuário pode perguntar em linguagem natural, por exemplo:

Sand, o que você diz sobre disciplina?

No CLI, a palavra Sand é opcional; no gateway ela servirá como nome/chamamento do bot.

Executando pelo gateway

Configure a plataforma no perfil sand:

`hermes -p sand gateway setup`

Escolha e configure WhatsApp quando o assistente oferecer essa plataforma. Depois, teste o gateway em primeiro plano:

`hermes -p sand gateway`

Quando a configuração estiver correta, inicie-o como serviço:

`hermes -p sand gateway install`
`hermes -p sand gateway start`
`hermes -p sand gateway status`

Os comandos exatos de pareamento, token ou sessão dependem do adaptador de WhatsApp escolhido pelo Hermes. Não copie tokens de outra instalação; configure as credenciais da nova VPS no perfil sand.

Uso no WhatsApp

Com o gateway ativo, uma mensagem como esta será encaminhada ao perfil Sand:

Sand, encontre nos vídeos o que você diz sobre demanda em negócios de AI.

O gateway entrega a mensagem ao Hermes, o Hermes chama o MCP sand-qmd, o QMD pesquisa /home/clone/transcricoes_md e Sand responde no mesmo chat.

Operação e atualização

Depois de adicionar ou alterar transcrições:

`cd /home/clone/projeto_QMD`
`./ingest.sh`

Para verificar o gateway:

`hermes -p sand gateway status`

Para verificar o índice e MCP:

`./status.sh`

Arquivos que não devem ser compartilhados

Não versionar nem copiar publicamente:

- ~/.hermes/profiles/sand/.env;
- ~/.hermes/profiles/sand/auth.json;
- tokens do gateway;
- sessões do WhatsApp;
- logs com dados privados.

Faça backup separado das credenciais e configure-as novamente na VPS destino.

Diretrizes de persona e estilo do Sand

Localização

As instruções de identidade e estilo devem ficar principalmente no SOUL.md do perfil Sand:

/home/clone/.hermes/profiles/sand/SOUL.md

O arquivo SOUL.md dentro deste projeto é a referência versionável. O README documenta a organização, mas não é a fonte principal das instruções comportamentais executadas pelo Hermes.

Divisão recomendada

- SOUL.md do perfil sand: identidade, primeira pessoa, tom de voz, postura, vocabulário, palavras evitadas, preferências de simplicidade e transparência de que Sand é uma reconstrução virtual.
- README.md do projeto: documentação humana da arquitetura e dos comandos.
- AGENTS.md ou uma skill sand-voice: regras detalhadas de formato, modos Literal/Fiel/Estilo, validação de evidências e exemplos few-shot extensos.
- QMD/MCP: recuperação do conteúdo das transcrições; não define personalidade nem estilo.
- /home/clone/transcricoes_md: fonte dos fatos e falas do autor; não deve conter instruções de comportamento.

As diretrizes fornecidas para o Sand incluem:

- Tom informal, enérgico, pragmático e levemente irônico com soluções complicadas demais.
- Começar pelo problema real antes de explicar a teoria.
- Usar analogias do cotidiano quando ajudarem.
- Começar com frases curtas de impacto e seguir com explicações práticas passo a passo.
- Preferir expressões como “na prática”, “sem firula”, “gargalo real” e “arquitetura de trincheira”, quando forem realmente naturais.
- Evitar termos corporativos excessivamente formais, como “outrossim”, “doravante” e “sinergia corporativa”.
- Usar travessões para quebras de pensamento e exclamações moderadas.
- Priorizar simplicidade operacional em vez de novidades da moda.
- Apontar abertamente quando uma tecnologia parecer complexa demais para o problema.

Few-shot

Uma versão curta dos exemplos pode ficar no SOUL.md. Exemplos longos devem ficar em uma skill ou em referências carregadas sob demanda, para não aumentar o prompt de todas as conversas.

Atenção sobre a identidade

O exemplo de diretrizes menciona autor: “Hélio”. Antes de aplicar esse nome ao Sand, confirme que Hélio é o autor das transcrições em /home/clone/transcricoes_md. Se o corpus for de outro autor, os exemplos e o campo de identidade devem ser ajustados para não misturar pessoas ou estilos.

O frontmatter YAML pode ser mantido como metadado documental, mas o Hermes trata o conteúdo do SOUL.md como texto de identidade; ele não depende do YAML para ativar a persona.
