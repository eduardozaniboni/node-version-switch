# Node Version Switch

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PowerShell](https://img.shields.io/badge/Language-PowerShell-blue.svg)](https://docs.microsoft.com/powershell/)

A lightweight Node.js version manager for Windows, written in PowerShell. Ideal for restricted environments without administrative privileges.

Um gerenciador leve de versões do Node.js para Windows, escrito em PowerShell. Ideal para ambientes restritos sem privilégios administrativos.

## Table of Contents
- [English](#english)
- [Português](#português)

## English

### Objective and Context
**Node Version Switch** (`nvs`) is designed to simplify managing multiple Node.js versions on Windows machines with restricted permissions, where users lack administrative access. Switching between legacy and current Node.js versions can be challenging in such environments.

Unlike tools like NVM, which require additional setup in WSL, **Node Version Switch** offers:
- **No installation**: Manages Node.js binaries in a user-accessible directory.
- **Lightweight**: Modifies only the user's PATH, leaving the system untouched.
- **Flexible**: Supports partial versions (e.g., `nvs install 20` installs the latest LTS version) and x86/x64 architectures.
- **Open-source**: MIT License, ready for community contributions.

Perfect for developers needing agility in controlled environments!

### Important Notice
**No Node.js version should be configured in the system PATH** (e.g., `C:\Program Files\nodejs`). Global installations may override **Node Version Switch** settings, causing conflicts. Verify and remove any Node.js entries from the system PATH before using the script. In controlled environments, this may require technical support.

### Features
- Installs, activates, uninstalls, and lists Node.js versions.
- Supports x86 and x64 architectures.
- Simple setup with `nvs` alias in the PowerShell profile.
- Supports partial versions (e.g., `nvs install 20` installs the latest LTS version).
- Lists available versions with LTS filter and descending order.

### Requirements
- Windows 10 or 11.
- PowerShell 5.1 or PowerShell Core 7+.
- Write permissions in the project directory.

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
1. Download or clone the repository to a directory with write permissions (e.g., `D:\Projects\nodeversionswitch`).
2. Navigate to the directory:
   ```powershell
   cd D:\Projects\nodeversionswitch
   ```
3. Run the initial setup:
   ```powershell
   .\nvs\nvs.ps1 setup
   ```
4. Load the alias:
   ```powershell
   . $PROFILE
   ```

*Note*: The script's messages and help are in English, but this README provides full instructions in Portuguese below.

### Commands
```powershell
nvs setup                         # Sets up folders and alias
nvs list                          # Lists installed versions
nvs available [-LTS] [filter]     # Lists available versions
nvs install <version> [x86|x64]   # Installs a version (e.g., 20 or 20.17.0; partial versions install the latest LTS)
nvs use <version>                 # Activates a version
nvs uninstall <version>           # Removes a version
nvs current                       # Shows the active version
nvs reset                         # Removes folders and alias
nvs help                          # Displays help
```

### Examples
```powershell
nvs available -LTS                # Lists LTS versions
nvs install 20 x86                # Installs the latest LTS version of the 20.x.x series (x86)
nvs use 20.17.0                   # Activates version 20.17.0
nvs uninstall 20.17.0             # Removes version 20.17.0
```

### Troubleshooting
- **Permission error**:
  - Move the project to a directory with write permissions.
  - Ensure you have write access to the project root.
- **Network failure**:
  - Check your internet connection or proxy settings.
- **Conflicts with other Node.js installations**:
  - Confirm no Node.js versions are in the system PATH.
  - Remove conflicting entries (may require technical support).
- **Alias not working**:
  - Run `. $PROFILE` or open a new PowerShell terminal.
  - Verify the `nvs` alias in `notepad $PROFILE`.
- **No LTS version found**:
  - If `nvs install 20` fails due to no LTS version, use `nvs available 20` to list all versions in the series.

### How to Contribute
Contributions are welcome! To contribute:
1. Fork the repository.
2. Create a branch for your feature (`git checkout -b feature/new-feature`).
3. Commit your changes (`git commit -m 'Add new feature'`).
4. Push to your fork (`git push origin feature/new-feature`).
5. Open a Pull Request.

See [CONTRIBUTING.md](CONTRIBUTING.md) for details, or report issues at [GitHub Issues](https://github.com/eduardozaniboni/node-version-switch/issues). Contributions in Portuguese are also welcome!

### Contact
- **GitHub**: [eduardozaniboni](https://github.com/eduardozaniboni)
- **LinkedIn**: [eduardozaniboni](https://linkedin.com/in/eduardozaniboni)

Feedback and suggestions are always appreciated!

### License
This project is licensed under the MIT License - see the [LICENSE.txt](LICENSE.txt) file for details.

## Português

### Objetivo e Contexto
O **Node Version Switch** (`nvs`) foi criado para simplificar o gerenciamento de múltiplas versões do Node.js em máquinas Windows com restrições de permissões, onde os usuários não possuem acesso administrativo. Alternar entre versões legadas e atuais do Node.js pode ser desafiador nesses ambientes.

Diferentemente de ferramentas como o NVM, que exigem configurações adicionais no WSL, o **Node Version Switch** oferece:
- **Sem instalação**: Gerencia binários do Node.js em um diretório acessível ao usuário.
- **Leveza**: Modifica apenas o PATH do usuário, sem alterar o sistema.
- **Flexibilidade**: Suporta versões parciais (ex.: `nvs install 20` instala a versão LTS mais recente) e arquiteturas x86/x64.
- **Open-source**: Licença MIT, pronto para contribuições da comunidade.

Ideal para desenvolvedores que precisam de agilidade em ambientes controlados!

### Aviso Importante
**Nenhuma versão do Node.js deve estar configurada no PATH do sistema** (ex.: `C:\Program Files\nodejs`). Instalações globais podem sobrescrever as configurações do **Node Version Switch**, causando conflitos. Verifique e remova qualquer entrada do Node.js no PATH do sistema antes de usar o script. Em ambientes controlados, isso pode exigir suporte técnico.

### Recursos
- Instala, ativa, desinstala e lista versões do Node.js.
- Suporte a arquiteturas x86 e x64.
- Configuração simples com alias `nvs` no perfil do PowerShell.
- Suporte a versões parciais (ex.: `nvs install 20` instala a versão LTS mais recente).
- Lista versões disponíveis com filtro LTS e ordenação decrescente.

### Requisitos
- Windows 10 ou 11.
- PowerShell 5.1 ou PowerShell Core 7+.
- Permissões de escrita no diretório do projeto.

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
1. Baixe ou clone o repositório para um diretório com permissões de escrita (ex.: `D:\Projects\nodeversionswitch`).
2. Navegue até o diretório:
   ```powershell
   cd D:\Projects\nodeversionswitch
   ```
3. Execute a configuração inicial:
   ```powershell
   .\nvs\nvs.ps1 setup
   ```
4. Carregue o alias:
   ```powershell
   . $PROFILE
   ```

*Nota*: As mensagens e a ajuda do script estão em inglês, mas este README fornece instruções completas em português.

### Comandos
```powershell
nvs setup                         # Configura pastas e alias
nvs list                          # Lista versões instaladas
nvs available [-LTS] [filtro]     # Lista versões disponíveis
nvs install <versão> [x86|x64]    # Instala uma versão (ex.: 20 ou 20.17.0; versões parciais instalam a LTS mais recente)
nvs use <versão>                  # Ativa uma versão
nvs uninstall <versão>            # Remove uma versão
nvs current                       # Mostra a versão ativa
nvs reset                         # Remove pastas e alias
nvs help                          # Exibe ajuda
```

### Exemplos
```powershell
nvs available -LTS                # Lista versões LTS
nvs install 20 x86                # Instala a versão LTS mais recente da série 20.x.x (x86)
nvs use 20.17.0                   # Ativa a versão 20.17.0
nvs uninstall 20.17.0             # Remove a versão 20.17.0
```

### Solução de Problemas
- **Erro de permissão**:
  - Mova o projeto para um diretório com permissão de escrita.
  - Certifique-se de que você tem acesso de escrita no diretório raiz do projeto.
- **Falha de rede**:
  - Verifique sua conexão com a internet ou configurações de proxy.
- **Conflitos com outras instalações do Node.js**:
  - Confirme que não há versões do Node.js no PATH do sistema.
  - Remova entradas conflitantes (pode exigir suporte técnico).
- **Alias não funciona**:
  - Execute `. $PROFILE` ou abra um novo terminal PowerShell.
  - Verifique o alias `nvs` em `notepad $PROFILE`.
- **Nenhuma versão LTS encontrada**:
  - Se `nvs install 20` falhar por falta de uma versão LTS, use `nvs available 20` para listar todas as versões da série.

### Como Contribuir
Contribuições são bem-vindas! Para contribuir:
1. Faça um fork do repositório.
2. Crie uma branch para sua funcionalidade (`git checkout -b feature/nova-funcionalidade`).
3. Faça commit das alterações (`git commit -m 'Adiciona nova funcionalidade'`).
4. Envie para seu fork (`git push origin feature/nova-funcionalidade`).
5. Abra um Pull Request.

Veja o [CONTRIBUTING.md](CONTRIBUTING.md) para detalhes, ou reporte issues em [GitHub Issues](https://github.com/eduardozaniboni/node-version-switch/issues). Contribuições em inglês também são bem-vindas!

### Contato
- **GitHub**: [Eduardo Zaniboni](https://github.com/eduardozaniboni)
- **LinkedIn**: [Eduardo Zaniboni](https://linkedin.com/in/eduardozaniboni)

Feedback e sugestões são sempre apreciados!

### Licença
Este projeto é licenciado sob a MIT License - veja o arquivo [LICENSE.txt](LICENSE.txt) (em inglês) para detalhes.