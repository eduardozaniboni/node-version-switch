# Node Version Switch

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PowerShell](https://img.shields.io/badge/Language-PowerShell-blue.svg)](https://docs.microsoft.com/powershell/)
[![GitHub stars](https://img.shields.io/github/stars/eduardozaniboni/nodeversionswitch?style=social)](https://github.com/eduardozaniboni/nodeversionswitch)

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

Explore the project at [nodenvs.vercel.app](https://nodenvs.vercel.app/)!

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
nodeversionswitch/
├── nvs/nvs.ps1           # Main script
├── nodejs-versions/      # Node.js version binaries
├── nodejs-configs/       # Configuration files
├── README.md             # Documentation
├── LICENSE.txt           # MIT License
├── .gitignore            # Git ignore file
├── CONTRIBUTING.md       # Contribution guidelines
```

### Installation

_Note_: If you downloaded the script (e.g., as a ZIP from GitHub) or are using a system with restricted PowerShell policies, you must unblock the script and set the execution policy before running it.

1. **Download or Clone**:

    - Clone the repository or download the ZIP from [GitHub](https://github.com/eduardozaniboni/nodeversionswitch).
    - Place it in a directory with write permissions (e.g., `D:\Projects\nodeversionswitch`):
        ```powershell
        git clone https://github.com/eduardozaniboni/nodeversionswitch.git D:\Projects\nodeversionswitch
        ```

2. **Unblock Files**:

    - For downloaded files, unblock the script to avoid the "not digitally signed" error:
        ```powershell
        Unblock-File -Path D:\Projects\nodeversionswitch\nvs\nvs.ps1
        ```

3. **Set Execution Policy**:

    - Allow local scripts by setting the PowerShell execution policy:
        ```powershell
        Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
        ```

4. **Run Setup**:

    - Navigate to the project directory:
        ```powershell
        cd D:\Projects\nodeversionswitch\nvs
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

<table>
  <thead>
    <tr>
      <th>Command</th>
      <th>Description</th>
      <th>Example</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>nvs setup</code></td>
      <td>Sets up folders (<code>nodejs-versions/</code>, <code>nodejs-configs/</code>) and the <code>nvs</code> alias.</td>
      <td><code>nvs setup</code></td>
    </tr>
    <tr>
      <td><code>nvs list</code></td>
      <td>Lists installed Node.js versions.</td>
      <td><code>nvs list</code></td>
    </tr>
    <tr>
      <td><code>nvs available [-LTS] [filter]</code></td>
      <td>Lists available Node.js versions, optionally filtered by LTS or version prefix.</td>
      <td><code>nvs available -LTS</code><br><code>nvs available 20</code></td>
    </tr>
    <tr>
      <td><code>nvs install <version> [x86|x64]</code></td>
      <td>Installs a Node.js version (full or partial, e.g., <code>20</code> for latest LTS; default: x64).</td>
      <td><code>nvs install 20 x86</code><br><code>nvs install 20.17.0</code></td>
    </tr>
    <tr>
      <td><code>nvs use <version></code></td>
      <td>Activates a specific Node.js version in the user PATH.</td>
      <td><code>nvs use 20.17.0</code></td>
    </tr>
    <tr>
      <td><code>nvs uninstall <version></code></td>
      <td>Removes a specific Node.js version.</td>
      <td><code>nvs uninstall 20.17.0</code></td>
    </tr>
    <tr>
      <td><code>nvs current</code></td>
      <td>Shows the currently active Node.js version.</td>
      <td><code>nvs current</code></td>
    </tr>
    <tr>
      <td><code>nvs reset</code></td>
      <td>Removes all folders and the <code>nvs</code> alias.</td>
      <td><code>nvs reset</code></td>
    </tr>
    <tr>
      <td><code>nvs help</code></td>
      <td>Displays the command list and examples.</td>
      <td><code>nvs help</code></td>
    </tr>
  </tbody>
</table>

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
    -   Ensure you ran `Unblock-File` before executing the script:
        ```powershell
        Unblock-File -Path D:\Projects\nodeversionswitch\nvs\nvs.ps1
        ```
    -   Set the execution policy to allow local scripts:
        ```powershell
        Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
        ```
    -   The script unblocks itself during `setup`, but initial runs require manual unblocking if downloaded from the internet.
    -   In corporate environments, contact IT if policies are locked (e.g., `AllSigned` or `Restricted`).
-   **Permission error**:
    -   Move the project to a directory with write permissions (e.g., `D:\Projects`).
    -   Verify write access:
        ```powershell
        New-Item -Path D:\Projects\nodeversionswitch\test.txt -ItemType File
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

See [CONTRIBUTING.md](CONTRIBUTING.md) for details. Report issues at [GitHub Issues](https://github.com/eduardozaniboni/nodeversionswitch/issues). Portuguese contributions are also welcome!

⭐ **Support the project by starring it on GitHub!**

### Website

Visit the official **Node Version Switch** website for a user-friendly guide and documentation: [nodenvs.vercel.app](https://nodenvs.vercel.app).

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

Explore o projeto em [nodenvs.vercel.app](https://nodenvs.vercel.app/)!

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
nodeversionswitch/
├── nvs/nvs.ps1           # Script principal
├── nodejs-versions/      # Binários das versões do Node.js
├── nodejs-configs/       # Arquivos de configuração
├── README.md             # Documentação
├── LICENSE.txt           # Licença MIT
├── .gitignore            # Arquivo de exclusão do Git
├── CONTRIBUTING.md       # Diretrizes de contribuição
```

### Instalação

_Nota_: Se você baixou o script (ex.: como ZIP do GitHub) ou está usando um sistema com políticas restritivas do PowerShell, é necessário desbloquear o script e definir a política de execução antes de executá-lo.

1. **Baixar ou Clonar**:

    - Clone o repositório ou baixe o ZIP de [GitHub](https://github.com/eduardozaniboni/nodeversionswitch).
    - Coloque em um diretório com permissões de escrita (ex.: `D:\Projects\nodeversionswitch`):
        ```powershell
        git clone https://github.com/eduardozaniboni/nodeversionswitch.git D:\Projects\nodeversionswitch
        ```

2. **Desbloquear Arquivos**:

    - Para arquivos baixados, desbloqueie o script para evitar o erro "not digitally signed":
        ```powershell
        Unblock-File -Path D:\Projects\nodeversionswitch\nvs\nvs.ps1
        ```

3. **Definir Política de Execução**:

    - Permita scripts locais definindo a política de execução do PowerShell:
        ```powershell
        Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
        ```

4. **Executar Configuração**:

    - Navegue até o diretório do projeto:
        ```powershell
        cd D:\Projects\nodeversionswitch\nvs
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

<table>
  <thead>
    <tr>
      <th>Comando</th>
      <th>Descrição</th>
      <th>Exemplo</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>nvs setup</code></td>
      <td>Configura pastas (<code>nodejs-versions/</code>, <code>nodejs-configs/</code>) e o alias <code>nvs</code>.</td>
      <td><code>nvs setup</code></td>
    </tr>
    <tr>
      <td><code>nvs list</code></td>
      <td>Lista versões do Node.js instaladas.</td>
      <td><code>nvs list</code></td>
    </tr>
    <tr>
      <td><code>nvs available [-LTS] [filtro]</code></td>
      <td>Lista versões disponíveis do Node.js, com filtro opcional por LTS ou prefixo.</td>
      <td><code>nvs available -LTS</code><br><code>nvs available 20</code></td>
    </tr>
    <tr>
      <td><code>nvs install <versão> [x86|x64]</code></td>
      <td>Instala uma versão do Node.js (completa ou parcial, ex.: <code>20</code> para LTS mais recente; padrão: x64).</td>
      <td><code>nvs install 20 x86</code><br><code>nvs install 20.17.0</code></td>
    </tr>
    <tr>
      <td><code>nvs use <versão></code></td>
      <td>Ativa uma versão específica do Node.js no PATH do usuário.</td>
      <td><code>nvs use 20.17.0</code></td>
    </tr>
    <tr>
      <td><code>nvs uninstall <versão></code></td>
      <td>Remove uma versão específica do Node.js.</td>
      <td><code>nvs uninstall 20.17.0</code></td>
    </tr>
    <tr>
      <td><code>nvs current</code></td>
      <td>Mostra a versão ativa do Node.js.</td>
      <td><code>nvs current</code></td>
    </tr>
    <tr>
      <td><code>nvs reset</code></td>
      <td>Remove todas as pastas e o alias <code>nvs</code>.</td>
      <td><code>nvs reset</code></td>
    </tr>
    <tr>
      <td><code>nvs help</code></td>
      <td>Exibe a lista de comandos e exemplos.</td>
      <td><code>nvs help</code></td>
    </tr>
  </tbody>
</table>

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
    -   Certifique-se de executar `Unblock-File` antes de rodar o script:
        ```powershell
        Unblock-File -Path D:\Projects\nodeversionswitch\nvs\nvs.ps1
        ```
    -   Defina a política de execução para permitir scripts locais:
        ```powershell
        Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
        ```
    -   O script desbloqueia a si mesmo durante o `setup`, mas execuções iniciais exigem desbloqueio manual se baixado da internet.
    -   Em ambientes corporativos, contate a TI se as políticas estiverem bloqueadas (ex.: `AllSigned` ou `Restricted`).
-   **Erro de permissão**:
    -   Mova o projeto para um diretório com permissões de escrita (ex.: `D:\Projects`).
    -   Verifique o acesso:
        ```powershell
        New-Item -Path D:\Projects\nodeversionswitch\test.txt -ItemType File
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

Veja o [CONTRIBUTING.md](CONTRIBUTING.md) para detalhes. Reporte problemas em [GitHub Issues](https://github.com/eduardozaniboni/nodeversionswitch/issues). Contribuições em inglês também são bem-vindas!

⭐ **Apoie o projeto dando uma estrela no GitHub!**

### Website

Visite o site oficial do **Node Version Switch** para um guia amigável e documentação: [nodenvs.vercel.app](https://nodenvs.vercel.app).

### Contato

-   **GitHub**: [Eduardo Zaniboni](https://github.com/eduardozaniboni)
-   **LinkedIn**: [Eduardo Zaniboni](https://linkedin.com/in/eduardozaniboni)

Feedback e sugestões são sempre bem-vindos!

### Licença

Licenciado sob a MIT License. Veja o arquivo [LICENSE.txt](LICENSE.txt) para detalhes.
