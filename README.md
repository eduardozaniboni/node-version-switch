# Node Version Switch

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PowerShell](https://img.shields.io/badge/Language-PowerShell-blue.svg)](https://docs.microsoft.com/powershell/)
[![GitHub stars](https://img.shields.io/github/stars/eduardozaniboni/node-version-switch?style=social)](https://github.com/eduardozaniboni/node-version-switch)

A lightweight Node.js version manager for Windows, written in PowerShell. Ideal for restricted environments without administrative privileges.

Um gerenciador leve de versões do Node.js para Windows, escrito em PowerShell. Ideal para ambientes restritos sem privilégios administrativos.

## Table of Contents

-   [English](#english)
-   [Português](#português)

## English

### Objective and Context

**Node Version Switch (NVS)** simplifies managing multiple Node.js versions on Windows in restricted environments where users lack administrative access. Switching between legacy and current Node.js versions is seamless with **NVS**, designed for developers needing agility.

Unlike tools like NVM, which may require WSL setup, **NVS** offers:

-   **No system installation**: Stores Node.js binaries in a user-controlled directory.
-   **Lightweight**: Modifies only the user’s PATH, preserving system integrity.
-   **Flexible**: Supports partial versions (e.g., `nvs install 20` installs the latest LTS) and x86/x64 architectures.
-   **Open-source**: MIT License, welcoming community contributions.

Explore the project at [NodeNVS](https://nodenvs.vercel.app/)!

### Important Notice

**No Node.js version should be in the system PATH** (e.g., `C:\Program Files\nodejs`). Global Node.js installations may conflict with **NVS**. Remove any Node.js entries from the system PATH before using **NVS**. In corporate environments, this may require IT support.

### Features

-   Install, activate, uninstall, and list Node.js versions.
-   Support for x86 and x64 architectures.
-   Simple setup with an `nvs` alias in the PowerShell profile.
-   Partial version support (e.g., `nvs install 20` installs the latest LTS).
-   List available versions with LTS filtering and descending order.

### Requirements

-   Windows 10 or 11.
-   PowerShell 5.1 or PowerShell Core 7+.
-   Write permissions in the project directory.
-   Internet connection for downloading Node.js versions.

### Project Structure

```
node-version-switch/
├── nvs/nvs.ps1           # Main script
├── nodejs-versions/      # Node.js version binaries
├── nodejs-configs/       # Configuration files
├── README.md             # Documentation
├── LICENSE.txt           # MIT License
├── .gitignore            # Git ignore file
├── CONTRIBUTING.md       # Contribution guidelines
```

### Installation

1. **Download or Clone**:

    - Clone the repository or download the ZIP from [GitHub](https://github.com/eduardozaniboni/node-version-switch).
    - Place it in a directory with write permissions (e.g., `D:\Projects\node-version-switch`):
        ```powershell
        git clone https://github.com/eduardozaniboni/node-version-switch.git D:\Projects\node-version-switch
        ```

2. **Unblock Files** (if downloaded):

    - If you see a "not digitally signed" error, unblock the script:
        ```powershell
        Unblock-File -Path D:\Projects\node-version-switch\nvs\nvs.ps1
        ```
    - _Note_: The script automatically unblocks itself during `setup`, but manual unblocking may be needed for initial runs.

3. **Set Execution Policy**:

    - Ensure PowerShell allows local scripts:
        ```powershell
        Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
        ```

4. **Run Setup**:

    - Navigate to the project directory:
        ```powershell
        cd D:\Projects\node-version-switch\nvs
        ```
    - Execute the setup to create folders and configure the `nvs` alias:
        ```powershell
        .\nvs.ps1 setup
        ```

5. **Load the Alias**:
    - Apply the alias in the current session:
        ```powershell
        . $PROFILE
        ```
    - Or open a new PowerShell terminal.

_Note_: Commands and help are in English, but full Portuguese instructions are below.

### Usage

Run `nvs help` to see all commands. Below are the available commands with examples:

| Command                         | Description                                                                     | Example                                                                                |
| ------------------------------- | ------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------- | --------------------------------------------- |
| `nvs setup`                     | Sets up folders (`nodejs-versions/`, `nodejs-configs/`) and the `nvs` alias.    | `nvs setup`                                                                            |
| `nvs list`                      | Lists installed Node.js versions.                                               | `nvs list`                                                                             |
| `nvs available [-LTS] [filter]` | Lists available Node.js versions, optionally filtered by LTS or version prefix. | `nvs available -LTS`<br>`nvs available 20`                                             |
| `nvs install <version> [x86     | x64]`                                                                           | Installs a Node.js version (full or partial, e.g., `20` for latest LTS; default: x64). | `nvs install 20 x86`<br>`nvs install 20.17.0` |
| `nvs use <version>`             | Activates a specific Node.js version in the user PATH.                          | `nvs use 20.17.0`                                                                      |
| `nvs uninstall <version>`       | Removes a specific Node.js version.                                             | `nvs uninstall 20.17.0`                                                                |
| `nvs current`                   | Shows the currently active Node.js version.                                     | `nvs current`                                                                          |
| `nvs reset`                     | Removes all folders and the `nvs` alias.                                        | `nvs reset`                                                                            |
| `nvs help`                      | Displays the command list and examples.                                         | `nvs help`                                                                             |

### Examples

```powershell
# List available LTS versions
nvs available -LTS

# Install the latest LTS version of Node.js 20.x.x (x86)
nvs install 20 x86

# Activate Node.js 20.17.0
nvs use 20.17.0

# Check the active version
nvs current

# List installed versions
nvs list

# Uninstall Node.js 20.17.0
nvs uninstall 20.17.0

# Reset all configurations
nvs reset
```

### Troubleshooting

-   **"Not digitally signed" error**:
    -   The script unblocks itself during `setup`. If the error persists, manually unblock:
        ```powershell
        Unblock-File -Path D:\Projects\node-version-switch\nvs\nvs.ps1
        ```
    -   Ensure `RemoteSigned` policy:
        ```powershell
        Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
        ```
    -   In corporate environments, contact IT for policy restrictions.
-   **Permission error**:
    -   Move the project to a directory with write permissions (e.g., `D:\Projects`).
    -   Verify write access:
        ```powershell
        New-Item -Path D:\Projects\node-version-switch\test.txt -ItemType File
        ```
-   **Network failure**:
    -   Check internet connectivity or proxy settings for `nvs install` or `nvs available`.
-   **Conflicts with other Node.js installations**:
    -   Remove Node.js from the system PATH (e.g., `C:\Program Files\nodejs`). Contact IT if restricted.
-   **Alias not working**:
    -   Run `. $PROFILE` or open a new terminal.
    -   Check the alias in `notepad $PROFILE`.
-   **No LTS version found**:
    -   If `nvs install 20` fails, use `nvs available 20` to list all versions.

### How to Contribute

Contributions are welcome! To contribute:

1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/new-feature`).
3. Commit changes (`git commit -m 'Add new feature'`).
4. Push to your fork (`git push origin feature/new-feature`).
5. Open a Pull Request.

See [CONTRIBUTING.md](CONTRIBUTING.md) for details. Report issues at [GitHub Issues](https://github.com/eduardozaniboni/node-version-switch/issues). Portuguese contributions are also welcome!

⭐ **Support the project by starring it on GitHub!**

### Website

Visit the official **Node Version Switch** website for a user-friendly guide and documentation: [NodeNVS](https://nodenvs.vercel.app).

### Contact

-   **GitHub**: [eduardozaniboni](https://github.com/eduardozaniboni)
-   **LinkedIn**: [eduardozaniboni](https://linkedin.com/in/eduardozaniboni)

Feedback and suggestions are appreciated!

### License

Licensed under the MIT License. See [LICENSE.txt](LICENSE.txt) for details.

## Português

### Objetivo e Contexto

O **Node Version Switch (NVS)** simplifica o gerenciamento de versões do Node.js em máquinas Windows com restrições administrativas, onde usuários não têm privilégios de administrador. Alternar entre versões legadas e atuais do Node.js é fácil com o **NVS**, projetado para desenvolvedores que precisam de agilidade.

Diferente de ferramentas como NVM, que podem exigir WSL, o **NVS** oferece:

-   **Sem instalação no sistema**: Armazena binários do Node.js em um diretório controlado pelo usuário.
-   **Leveza**: Modifica apenas o PATH do usuário, sem alterar o sistema.
-   **Flexibilidade**: Suporta versões parciais (ex.: `nvs install 20` instala a LTS mais recente) e arquiteturas x86/x64.
-   **Open-source**: Licença MIT, aberto a contribuições da comunidade.

Explore o projeto em [NodeNVS](https://nodenvs.vercel.app/)!

### Aviso Importante

**Nenhuma versão do Node.js deve estar no PATH do sistema** (ex.: `C:\Program Files\nodejs`). Instalações globais do Node.js podem conflitar com o **NVS**. Remova entradas do Node.js do PATH do sistema antes de usar o **NVS**. Em ambientes corporativos, isso pode exigir suporte de TI.

### Recursos

-   Instala, ativa, desinstala e lista versões do Node.js.
-   Suporte a arquiteturas x86 e x64.
-   Configuração simples com alias `nvs` no perfil do PowerShell.
-   Suporte a versões parciais (ex.: `nvs install 20` instala a LTS mais recente).
-   Lista versões disponíveis com filtro LTS e ordenação decrescente.

### Requisitos

-   Windows 10 ou 11.
-   PowerShell 5.1 ou PowerShell Core 7+.
-   Permissões de escrita no diretório do projeto.
-   Conexão com a internet para baixar versões do Node.js.

### Estrutura do Projeto

```
node-version-switch/
├── nvs/nvs.ps1           # Script principal
├── nodejs-versions/      # Binários das versões do Node.js
├── nodejs-configs/       # Arquivos de configuração
├── README.md             # Documentação
├── LICENSE.txt           # Licença MIT
├── .gitignore            # Arquivo de exclusão do Git
├── CONTRIBUTING.md       # Diretrizes de contribuição
```

### Instalação

1. **Baixar ou Clonar**:

    - Clone o repositório ou baixe o ZIP de [GitHub](https://github.com/eduardozaniboni/node-version-switch).
    - Coloque em um diretório com permissões de escrita (ex.: `D:\Projects\node-version-switch`):
        ```powershell
        git clone https://github.com/eduardozaniboni/node-version-switch.git D:\Projects\node-version-switch
        ```

2. **Desbloquear Arquivos** (se baixado):

    - Se aparecer o erro "not digitally signed", desbloqueie o script:
        ```powershell
        Unblock-File -Path D:\Projects\node-version-switch\nvs\nvs.ps1
        ```
    - _Nota_: O script desbloqueia automaticamente durante o `setup`, mas o desbloqueio manual pode ser necessário inicialmente.

3. **Definir Política de Execução**:

    - Garanta que o PowerShell permita scripts locais:
        ```powershell
        Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
        ```

4. **Executar Configuração**:

    - Navegue até o diretório do projeto:
        ```powershell
        cd D:\Projects\node-version-switch\nvs
        ```
    - Execute a configuração para criar pastas e configurar o alias `nvs`:
        ```powershell
        .\nvs.ps1 setup
        ```

5. **Carregar o Alias**:
    - Aplique o alias na sessão atual:
        ```powershell
        . $PROFILE
        ```
    - Ou abra um novo terminal PowerShell.

_Nota_: Os comandos e a ajuda estão em inglês, mas instruções completas em português estão abaixo.

### Utilização

Execute `nvs help` para ver todos os comandos. Abaixo estão os comandos disponíveis com exemplos:

| Comando                         | Descrição                                                                     | Exemplo                                                                                            |
| ------------------------------- | ----------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------- | --------------------------------------------- |
| `nvs setup`                     | Configura pastas (`nodejs-versions/`, `nodejs-configs/`) e o alias `nvs`.     | `nvs setup`                                                                                        |
| `nvs list`                      | Lista versões do Node.js instaladas.                                          | `nvs list`                                                                                         |
| `nvs available [-LTS] [filtro]` | Lista versões disponíveis do Node.js, com filtro opcional por LTS ou prefixo. | `nvs available -LTS`<br>`nvs available 20`                                                         |
| `nvs install <versão> [x86      | x64]`                                                                         | Instala uma versão do Node.js (completa ou parcial, ex.: `20` para LTS mais recente; padrão: x64). | `nvs install 20 x86`<br>`nvs install 20.17.0` |
| `nvs use <versão>`              | Ativa uma versão específica do Node.js no PATH do usuário.                    | `nvs use 20.17.0`                                                                                  |
| `nvs uninstall <versão>`        | Remove uma versão específica do Node.js.                                      | `nvs uninstall 20.17.0`                                                                            |
| `nvs current`                   | Mostra a versão ativa do Node.js.                                             | `nvs current`                                                                                      |
| `nvs reset`                     | Remove todas as pastas e o alias `nvs`.                                       | `nvs reset`                                                                                        |
| `nvs help`                      | Exibe a lista de comandos e exemplos.                                         | `nvs help`                                                                                         |

### Exemplos

```powershell
# Listar versões LTS disponíveis
nvs available -LTS

# Instalar a versão LTS mais recente da série 20.x.x (x86)
nvs install 20 x86

# Ativar a versão 20.17.0
nvs use 20.17.0

# Verificar a versão ativa
nvs current

# Listar versões instaladas
nvs list

# Desinstalar a versão 20.17.0
nvs uninstall 20.17.0

# Resetar todas as configurações
nvs reset
```

### Solução de Problemas

-   **Erro "not digitally signed"**:
    -   O script desbloqueia automaticamente durante o `setup`. Se o erro persistir, desbloqueie manualmente:
        ```powershell
        Unblock-File -Path D:\Projects\node-version-switch\nvs\nvs.ps1
        ```
    -   Verifique a política `RemoteSigned`:
        ```powershell
        Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
        ```
    -   Em ambientes corporativos, contate a TI para restrições de política.
-   **Erro de permissão**:
    -   Mova o projeto para um diretório com permissões de escrita (ex.: `D:\Projects`).
    -   Verifique o acesso:
        ```powershell
        New-Item -Path D:\Projects\node-version-switch\test.txt -ItemType File
        ```
-   **Falha de rede**:
    -   Verifique a conexão com a internet ou configurações de proxy para `nvs install` ou `nvs available`.
-   **Conflitos com outras instalações do Node.js**:
    -   Remova o Node.js do PATH do sistema (ex.: `C:\Program Files\nodejs`). Contate a TI se restrito.
-   **Alias não funciona**:
    -   Execute `. $PROFILE` ou abra um novo terminal.
    -   Verifique o alias em `notepad $PROFILE`.
-   **Nenhuma versão LTS encontrada**:
    -   Se `nvs install 20` falhar, use `nvs available 20` para listar todas as versões.

### Como Contribuir

Contribuições são bem-vindas! Para contribuir:

1. Faça um fork do repositório.
2. Crie uma branch para sua funcionalidade (`git checkout -b feature/nova-funcionalidade`).
3. Faça commit das alterações (`git commit -m 'Adiciona nova funcionalidade'`).
4. Envie para seu fork (`git push origin feature/nova-funcionalidade`).
5. Abra um Pull Request.

Veja o [CONTRIBUTING.md](CONTRIBUTING.md) para detalhes. Reporte problemas em [GitHub Issues](https://github.com/eduardozaniboni/node-version-switch/issues). Contribuições em inglês também são bem-vindas!

⭐ **Apoie o projeto dando uma estrela no GitHub!**

### Website

Visite o site oficial do **Node Version Switch** para um guia amigável e documentação: [NodeNVS](https://nodenvs.vercel.app).

### Contato

-   **GitHub**: [Eduardo Zaniboni](https://github.com/eduardozaniboni)
-   **LinkedIn**: [Eduardo Zaniboni](https://linkedin.com/in/eduardozaniboni)

Feedback e sugestões são sempre bem-vindos!

### Licença

Licenciado sob a MIT License. Veja o arquivo [LICENSE.txt](LICENSE.txt) para detalhes.

