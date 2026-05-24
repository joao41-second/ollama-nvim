# ollama-nvim

Um plugin para o Neovim que integra a API do Ollama para gerar respostas de modelos de linguagem.

## Funcionalidades

- Integração com a API do Ollama para gerar respostas de modelos de linguagem.
- Comandos personalizados para interação com a IA:
  - `:Chat` - Abre uma sessão de chat com a IA.
  - `:CreateTempFile` - Cria um arquivo temporário com conteúdo gerado pela IA.

## Estrutura do Projeto

- `lua/ollama/init.lua` - Arquivo principal do plugin, contém funções para interação com a IA e gerenciamento de arquivos temporários.
- `plugin/ollama-nvim.lua` - Configuração inicial do plugin para Neovim.
- `.editorconfig` - Arquivo de configuração de formatação para o projeto.
