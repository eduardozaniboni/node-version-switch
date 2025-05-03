<#
.SYNOPSIS
    Node Version Switch - Um gerenciador simples e leve de versões do Node.js para Windows.

.DESCRIPTION
    Permite instalar, usar, desinstalar e gerenciar múltiplas versões do Node.js no Windows.
    Configura um alias 'nvs' no perfil do PowerShell para uso fácil.

.COMMANDS
    setup                           Configura a infraestrutura inicial (pastas, alias, etc.).
    list                            Lista as versões do Node.js instaladas.
    available [-LTS] [filtro]       Lista as versões disponíveis para download (ex.: 'nvs available 20' para versões 20.x.x).
    install <versão> [x86|x64]      Instala uma versão específica do Node.js (ex.: 20.17.0 ou 20, padrão: x64).
    use <versão>                    Ativa uma versão específica do Node.js.
    uninstall <versão>              Remove uma versão específica do Node.js.
    current                         Mostra a versão do Node.js atualmente ativa.
    reset                           Redefine todas as configurações (remove pastas e alias).
    help                            Exibe a mensagem de ajuda.

.EXAMPLE
    .\nvs\nvs.ps1 setup
    nvs available -LTS
    nvs available 20
    nvs install 20 x86
    nvs use 20.17.0
    nvs uninstall 20.17.0
    nvs help

.NOTES
    Autor: Eduardo Walger Zaniboni
    Compatível com Windows PowerShell 5.1 e PowerShell Core 7+.
    Testado no Windows 10 e 11.
#>

param (
    [Parameter(Mandatory = $false)]
    [string]$Command,

    [Parameter(Mandatory = $false)]
    [string]$Version,

    [Parameter(Mandatory = $false)]
    [ValidateSet("x64", "x86")]
    [string]$Arch = "x64",

    [Parameter(Mandatory = $false)]
    [switch]$LTS
)

$scriptDir = Split-Path -Parent ([System.IO.Path]::GetFullPath($PSCommandPath))
$projectRoot = Split-Path -Parent $scriptDir
$baseDir = Join-Path $projectRoot "nodejs-versions"
$configDir = Join-Path $projectRoot "nodejs-configs"
$configFile = Join-Path $configDir "config.json"

$validCommands = @("list", "use", "install", "uninstall", "current", "setup", "reset", "available", "help")

function Show-Help {
    Write-Host "`n[!] Comando inválido ou não especificado." -ForegroundColor Red
    exit 1
}

function Test-Configuration {
    if (-not (Test-Path $baseDir) -or -not (Test-Path $configDir) -or -not (Test-Path $configFile)) {
        Write-Host "`n[!] configuração inicial não encontrada. Execute '.\nvs\nvs.ps1 setup' para criar a estrutura necessária." -ForegroundColor Red
        exit 1
    }
}

if (-not $Command -or $validCommands -notcontains $Command) {
    Show-Help
}

function Test-InternetConnection {
    try {
        $response = Test-Connection -ComputerName "google.com" -Count 1 -Quiet
        return $response
    }
    catch {
        return $false
    }
}

function Get-Config {
    if (Test-Path $configFile) {
        return Get-Content $configFile -Raw | ConvertFrom-Json
    }
    return $null
}

function Save-Config {
    param ($Config)
    if (-not (Test-Path $configDir)) {
        New-Item -Path $configDir -ItemType Directory | Out-Null
    }
    $Config | ConvertTo-Json | Set-Content $configFile -Encoding UTF8
}

function Set-ExecutionPolicy-IfNeeded {
    try {
        $currentPolicy = Get-ExecutionPolicy -Scope CurrentUser
        if ($currentPolicy -ne "RemoteSigned") {
            Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
            Write-Host "[+] Política de execução definida como 'RemoteSigned'." -ForegroundColor Green
        }
    }
    catch {
        Write-Host "[!] Falha ao alterar a política de execução. Verifique suas permissões." -ForegroundColor Red
    }
}

function Set-NodeVersionSwitchAlias {
    $scriptPath = [System.IO.Path]::GetFullPath($PSCommandPath)
    $aliasCommand = "Set-Alias -Name nvs -Value `"$scriptPath`""
    $completerCommand = @"
Register-ArgumentCompleter -CommandName nvs -ScriptBlock {
    param(`$wordToComplete, `$commandAst, `$cursorPosition)
    `$completions = @('list', 'use', 'install', 'uninstall', 'current', 'setup', 'reset', 'available', 'help')
    `$completions | Where-Object { `$_ -like "`${wordToComplete}*" } | ForEach-Object { [System.Management.Automation.CompletionResult]::new(`$_, `$_, 'ParameterValue', `$_) }
}
"@

    if (Get-Alias -Name nvs -ErrorAction SilentlyContinue) {
        Write-Host "[!] O alias 'nvs' já existe. Remova-o manualmente do perfil, escolha outro nome ou use 'nvs reset'." -ForegroundColor Red
        return
    }

    $profilePath = $PROFILE
    $fallbackPath = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
    if (-not $profilePath) {
        $profilePath = $fallbackPath
    }

    $isPowerShellCore = $PSVersionTable.PSEdition -eq "Core"
    if ($isPowerShellCore -and $profilePath -notmatch "PowerShell") {
        $profilePath = $profilePath -replace "WindowsPowerShell", "PowerShell"
        $fallbackPath = $fallbackPath -replace "WindowsPowerShell", "PowerShell"
    }

    $profilePaths = @($profilePath, $fallbackPath) | Select-Object -Unique

    $profileUpdated = $false
    foreach ($path in $profilePaths) {
        if (-not $path) { continue }

        $profileDir = Split-Path $path -Parent
        if (-not (Test-Path $profileDir)) {
            try {
                New-Item -Path $profileDir -ItemType Directory -Force | Out-Null
                Write-Host "[+] diretório de perfil criado em $profileDir." -ForegroundColor Green
            }
            catch {
                Write-Host "[!] Falha ao criar diretório $profileDir. Verifique as permissões." -ForegroundColor Red
                continue
            }
        }

        try {
            $tempFile = Join-Path $profileDir "test_$(Get-Random).tmp"
            New-Item -Path $tempFile -ItemType File -Force | Out-Null
            Remove-Item -Path $tempFile -Force
        }
        catch {
            Write-Host "[!] Sem permissão para gravar em $profileDir. Pulando este perfil." -ForegroundColor Red
            continue
        }

        if (-not (Test-Path $path)) {
            try {
                New-Item -Path $path -ItemType File -Force | Out-Null
                Write-Host "[+] Arquivo de perfil criado em $path." -ForegroundColor Green
            }
            catch {
                Write-Host "[!] Falha ao criar arquivo $path. Verifique as permissões." -ForegroundColor Red
                continue
            }
        }

        try {
            $profileContent = Get-Content $path -Raw -ErrorAction SilentlyContinue
            if (-not $profileContent) { $profileContent = "" }
        }
        catch {
            Write-Host "[!] Falha ao ler o perfil $path. Verifique as permissões." -ForegroundColor Red
            continue
        }

        if ($profileContent -notmatch [regex]::Escape($aliasCommand)) {
            try {
                Add-Content -Path $path -Value "`n$aliasCommand" -Encoding UTF8
                Write-Host "[+] Alias 'nvs' adicionado ao perfil em $path." -ForegroundColor Green
                $profileUpdated = $true
            }
            catch {
                Write-Host "[!] Falha ao gravar o alias em $path. Verifique as permissões." -ForegroundColor Red
                continue
            }
        }

        if ($profileContent -notmatch [regex]::Escape($completerCommand)) {
            try {
                Add-Content -Path $path -Value "`n$completerCommand" -Encoding UTF8
                Write-Host "[+] Autocomplete para 'nvs' adicionado ao perfil em $path." -ForegroundColor Green
                $profileUpdated = $true
            }
            catch {
                Write-Host "[!] Falha ao gravar o autocomplete em $path. Verifique as permissões." -ForegroundColor Red
                continue
            }
        }

        if ($profileUpdated) { break }
    }

    if (-not $profileUpdated) {
        Write-Host "[!] Não foi possível configurar o alias automaticamente." -ForegroundColor Red
        Write-Host "Adicione manualmente ao seu perfil (execute 'notepad `$PROFILE' para editar):" -ForegroundColor Yellow
        Write-Host $aliasCommand
        Write-Host $completerCommand
        Write-Host "Caminho do perfil esperado: $PROFILE" -ForegroundColor Yellow
    }
    else {
        Write-Host "Abra um novo terminal PowerShell." -ForegroundColor Yellow
    }
}

function Remove-NodeVersionSwitchAlias {
    $scriptPath = [System.IO.Path]::GetFullPath($PSCommandPath)
    $aliasCommand = "Set-Alias -Name nvs -Value `"$scriptPath`""
    $completerCommand = @"
Register-ArgumentCompleter -CommandName nvs -ScriptBlock {
    param(`$wordToComplete, `$commandAst, `$cursorPosition)
    `$completions = @('list', 'use', 'install', 'uninstall', 'current', 'setup', 'reset', 'available', 'help')
    `$completions | Where-Object { `$_ -like "`${wordToComplete}*" } | ForEach-Object { [System.Management.Automation.CompletionResult]::new(`$_, `$_, 'ParameterValue', `$_) }
}
"@

    $profilePath = $PROFILE
    $fallbackPath = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
    if (-not $profilePath) {
        $profilePath = $fallbackPath
    }

    $isPowerShellCore = $PSVersionTable.PSEdition -eq "Core"
    if ($isPowerShellCore -and $profilePath -notmatch "PowerShell") {
        $profilePath = $profilePath -replace "WindowsPowerShell", "PowerShell"
        $fallbackPath = $fallbackPath -replace "WindowsPowerShell", "PowerShell"
    }

    $profilePaths = @($profilePath, $fallbackPath) | Select-Object -Unique

    $profileUpdated = $false
    foreach ($path in $profilePaths) {
        if (-not $path) { continue }
        if (Test-Path $path) {
            try {
                $profileContent = Get-Content $path -Raw -ErrorAction SilentlyContinue
                if (-not $profileContent) { continue }

                $newContent = $profileContent -replace [regex]::Escape($aliasCommand), ""
                $newContent = $newContent -replace [regex]::Escape($completerCommand), ""
                $newContent = ($newContent -split "`n" | Where-Object { $_ -match '\S' }) -join "`n"

                Set-Content -Path $path -Value $newContent -Encoding UTF8
                Write-Host "[+] Alias e autocomplete 'nvs' removidos do perfil em $path." -ForegroundColor Green
                $profileUpdated = $true
            }
            catch {
                Write-Host "[!] Falha ao modificar o perfil $path. Verifique as permissões." -ForegroundColor Red
            }
        }
    }

    if ($profileUpdated) {
        Write-Host "Abra um novo terminal PowerShell para utilizar os comandos." -ForegroundColor Yellow
    }
    else {
        Write-Host "[!] Nenhum perfil foi modificado. Verifique se o alias 'nvs' está configurado." -ForegroundColor Yellow
    }
}

function List-AvailableVersions {
    param (
        [string]$Filter,
        [switch]$LTS
    )

    if (-not (Test-InternetConnection)) {
        Write-Host "`n[!] Não foi possível conectar a Internet. Verifique sua conexão." -ForegroundColor Red
        Write-Host "Tente novamente ou verifique suas configurações de rede/proxy." -ForegroundColor Yellow
        exit 1
    }

    Write-Host "`n[*] Buscando versões disponíveis no site do Node.js..." -ForegroundColor Cyan
    try {
        $url = "https://nodejs.org/dist/index.json"
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing
        $versions = $response.Content | ConvertFrom-Json

        $filteredVersions = $versions | Where-Object {
            $isMatch = $true
            if ($Filter) {
                $isMatch = $_.version -like "v${Filter}*"
            }
            if ($LTS) {
                $isMatch = $isMatch -and $_.lts -ne $false
            }
            $isMatch
        }

        if (-not $filteredVersions) {
            Write-Host "`n[!] Nenhuma versão encontrada com os filtros especificados." -ForegroundColor Yellow
            if ($Filter) { Write-Host "Filtro aplicado: $Filter" -ForegroundColor Yellow }
            if ($LTS) { Write-Host "Apenas versões LTS solicitadas." -ForegroundColor Yellow }
            return
        }

        $filteredVersions = $filteredVersions | Sort-Object { [Version]($_.version -replace '^v') } -Descending

        Write-Host "`nversões disponíveis:" -ForegroundColor Cyan
        foreach ($ver in $filteredVersions) {
            $ltsLabel = if ($ver.lts -ne $false) { " (LTS: $($ver.lts))" } else { "" }
            Write-Host " - $($ver.version)$ltsLabel - Lancada em: $($ver.date)"
        }
    }
    catch {
        Write-Host "`n[!] Erro ao buscar versões disponíveis. Verifique sua conexão ou tente novamente mais tarde." -ForegroundColor Red
        Write-Host "Detalhes do erro: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Tente novamente ou verifique suas configurações de rede/proxy." -ForegroundColor Yellow
        exit 1
    }
}

function Test-NodeVersion {
    param ($version)
    try {
        $url = "https://nodejs.org/dist/v$version/"
        $response = Invoke-WebRequest -Uri $url -Method Head -UseBasicParsing
        return $response.StatusCode -eq 200
    }
    catch {
        return $false
    }
}

function List-Versions {
    Test-Configuration
    $nodeDirs = Get-ChildItem -Path $baseDir -Directory | Where-Object { Test-Path "$($_.FullName)\node.exe" }
    if ($nodeDirs.Count -eq 0) {
        Write-Host "`n[!] Nenhuma versão do Node.js encontrada em $baseDir" -ForegroundColor Red
        return
    }

    Write-Host "`nversões instaladas:" -ForegroundColor Cyan
    foreach ($dir in $nodeDirs) {
        Write-Host " - $($dir.Name)"
    }

    $current = Get-Command node -ErrorAction SilentlyContinue
    if ($current) {
        Write-Host "`nversão ativa: $($current.Source)" -ForegroundColor Green
    }
    else {
        Write-Host "`nNenhuma versão do Node.js está ativa no terminal atual." -ForegroundColor Yellow
    }
}

function Use-Version {
    param ($Version)

    Test-Configuration
    $targetPath = Join-Path $baseDir "v$Version"
    $nodeExe = if (Test-Path "$targetPath\node.exe") {
        "$targetPath\node.exe"
    }
    elseif (Test-Path "$targetPath\bin\node.exe") {
        "$targetPath\bin\node.exe"
    }
    else {
        $null
    }

    if (-not $nodeExe) {
        Write-Host "`n[!] versão v$Version não encontrada em $targetPath" -ForegroundColor Red
        return
    }

    $pathParts = [System.Environment]::GetEnvironmentVariable("Path", "User") -split ';'
    if ($pathParts -contains ([System.IO.Path]::GetDirectoryName($nodeExe))) {
        Write-Host "`n[!] A versão v$Version já está no PATH. Nenhuma alteração necessária." -ForegroundColor Yellow
        return
    }

    $otherNodePaths = $pathParts | Where-Object { $_ -match 'node\.exe$' -and $_ -notmatch [regex]::Escape($baseDir) }
    if ($otherNodePaths) {
        Write-Host "`n[!] Outras instalações do Node.js foram encontradas no PATH:" -ForegroundColor Yellow
        $otherNodePaths | ForEach-Object { Write-Host " - $_" }
        Write-Host "Isso pode causar conflitos. Considere removê-las manualmente." -ForegroundColor Yellow
    }

    $oldPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $pathParts = $oldPath -split ';' | Where-Object { $_ -notmatch [regex]::Escape($baseDir) }
    $newPath = $pathParts -join ';'

    $nodeDir = [System.IO.Path]::GetDirectoryName($nodeExe)
    $newPath = "$nodeDir;$newPath"

    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")

    Write-Host "`nAgora usando Node.js v$Version" -ForegroundColor Green
    Write-Host "Abra um novo terminal para aplicar a mudança." -ForegroundColor Yellow
}

function Resolve-Version {
    param ($version)
    if ($version -notmatch '^\d+\.\d+\.\d+$') {
        if (-not (Test-InternetConnection)) {
            Write-Host "`n[!] Não foi possível conectar a Internet para resolver a versão $version." -ForegroundColor Red
            Write-Host "Tente novamente ou verifique suas configurações de rede/proxy." -ForegroundColor Yellow
            exit 1
        }
        try {
            $response = Invoke-WebRequest -Uri "https://nodejs.org/dist/index.json" -UseBasicParsing
            $versions = $response.Content | ConvertFrom-Json
            $latestLTS = $versions | Where-Object { 
                $_.version -like "v${version}.*" -and $_.lts -ne $false 
            } | Sort-Object { [Version]($_.version -replace '^v') } -Descending | Select-Object -First 1
            if ($latestLTS) {
                return $latestLTS.version -replace '^v'
            }
            else {
                Write-Host "`n[!] Nenhuma versão LTS encontrada para a série $version." -ForegroundColor Red
                Write-Host "Use 'nvs available $version' para listar todas versões disponíveis dessa série." -ForegroundColor Yellow
                exit 1
            }
        }
        catch {
            Write-Host "`n[!] Erro ao resolver a versão $version. Verifique sua conexão ou tente novamente mais tarde." -ForegroundColor Red
            Write-Host "Detalhes do erro: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "Tente novamente ou verifique suas configurações de rede/proxy." -ForegroundColor Yellow
            exit 1
        }
    }
    return $version
}

function Download-Version {
    param ($version, $arch)

    $archSuffix = if ($arch -eq "x86") { "win-x86" } else { "win-x64" }
    $url = "https://nodejs.org/dist/v$version/node-v$version-$archSuffix.zip"
    $destPath = Join-Path $baseDir "v$version"
    $zipFile = Join-Path $destPath "node-v$version-$archSuffix.zip"

    if (-not (Test-Path $destPath)) {
        New-Item -Path $destPath -ItemType Directory | Out-Null
    }

    Write-Host "`n[*] Baixando versão v$version ($arch) do Node.js..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $url -OutFile $zipFile

    Write-Host "`n[*] Extraindo arquivo ZIP..." -ForegroundColor Cyan
    Expand-Archive -Path $zipFile -DestinationPath $destPath -Force
    Move-Item -Path "$destPath\node-v$version-$archSuffix\*" -Destination $destPath -Force
    Remove-Item -Path "$destPath\node-v$version-$archSuffix" -Recurse -Force
    Remove-Item -Path $zipFile -Force

    Write-Host "`n[+] Download e extração da versão v$version ($arch) concluídos." -ForegroundColor Green
}

function Install-Version {
    param ($version, $arch)

    Test-Configuration
    if (-not (Test-InternetConnection)) {
        Write-Host "[!] Não foi possível conectar a Internet. O download não pode ser feito." -ForegroundColor Red
        Write-Host "Tente novamente ou verifique suas configurações de rede/proxy." -ForegroundColor Yellow
        exit 1
    }

    $resolvedVersion = Resolve-Version -version $version
    Write-Host "`n[*] versão resolvida: v$resolvedVersion" -ForegroundColor Cyan

    if (-not (Test-NodeVersion -version $resolvedVersion)) {
        Write-Host "`n[!] A versão v$resolvedVersion não existe no site do Node.js." -ForegroundColor Red
        exit 1
    }

    $targetPath = Join-Path $baseDir "v$resolvedVersion"
    if (Test-Path "$targetPath\node.exe") {
        Write-Host "`n[!] A versão v$resolvedVersion já está instalada em $targetPath" -ForegroundColor Red
        return
    }

    Download-Version -version $resolvedVersion -arch $arch
    Write-Host "`n[+] Instalação concluída." -ForegroundColor Green
}

function Uninstall-Version {
    param ($version)

    Test-Configuration
    $targetPath = Join-Path $baseDir "v$version"
    if (-not (Test-Path $targetPath)) {
        Write-Host "`n[!] A versão v$version não está instalada em $targetPath" -ForegroundColor Red
        return
    }

    Write-Host "`n[*] Removendo versão v$version..." -ForegroundColor Cyan
    Remove-Item -Path $targetPath -Recurse -Force
    Write-Host "[+] versão v$version removida com sucesso." -ForegroundColor Green
}

function Show-Current {
    Test-Configuration
    $current = Get-Command node -ErrorAction SilentlyContinue
    if ($current) {
        Write-Host "`nversão ativa: $($current.Source)" -ForegroundColor Green
    }
    else {
        Write-Host "`nNenhuma versão do Node.js está ativa no terminal atual." -ForegroundColor Yellow
    }
}

function Initialize {
    try {
        $testFile = Join-Path $scriptDir "test_$(Get-Random).tmp"
        New-Item -Path $testFile -ItemType File -Force | Out-Null
        Remove-Item -Path $testFile -Force
    }
    catch {
        Write-Host "`n[!] Sem permissão para gravar em $scriptDir. Mova o script para um diretório com permissão de escrita ou execute o PowerShell como administrador." -ForegroundColor Red
        exit 1
    }

    Write-Host "`n"
    Write-Host " _   _   __      __  _______" -ForegroundColor Cyan
    Write-Host "| \ | |  \ \    / /  |  ___|" -ForegroundColor Cyan
    Write-Host "|  \| |   \ \  / /   | |___ " -ForegroundColor Cyan
    Write-Host "| . `  |    \ \/ /    |___  |" -ForegroundColor Cyan
    Write-Host "| |\  |     \  /      ___| |" -ForegroundColor Cyan
    Write-Host "|_| |_|      \/      |_____/" -ForegroundColor Cyan
    Write-Host "    Node Version Switch     " -ForegroundColor Cyan
    Write-Host "`n"

    if (-not (Test-Path $baseDir)) {
        Write-Host "[*] Criando diretório base em $baseDir..." -ForegroundColor Cyan
        New-Item -Path $baseDir -ItemType Directory | Out-Null
    }

    if (-not (Test-Path $configDir)) {
        Write-Host "[*] Criando diretório de configurações em $configDir..." -ForegroundColor Cyan
        New-Item -Path $configDir -ItemType Directory | Out-Null
    }

    $config = Get-Config
    if (-not $config) {
        $config = [PSCustomObject]@{
            BasePath = $baseDir
            ScriptPath = [System.IO.Path]::GetFullPath($PSCommandPath)
        }
        Save-Config -Config $config
        Write-Host "[+] configurações salvas em $configFile." -ForegroundColor Green
    }

    Set-ExecutionPolicy-IfNeeded
    Set-NodeVersionSwitchAlias

    Write-Host "[+] configuração inicial concluída!" -ForegroundColor Green
}

function Reset-Configuration {
    Write-Host "`n[*] Redefinindo configurações..." -ForegroundColor Cyan

    if (Test-Path $baseDir) {
        Remove-Item -Path $baseDir -Recurse -Force
        Write-Host "[+] Pasta $baseDir removida." -ForegroundColor Green
    }

    if (Test-Path $configDir) {
        Remove-Item -Path $configDir -Recurse -Force
        Write-Host "[+] Pasta $configDir removida." -ForegroundColor Green
    }

    Remove-NodeVersionSwitchAlias

    Write-Host "[+] configurações redefinidas com sucesso. Execute '.\nvs\nvs.ps1 setup' para reconfigurar." -ForegroundColor Green
}

switch ($Command) {
    "list" { List-Versions }
    "available" { List-AvailableVersions -Filter $Version -LTS:$LTS }
    "use" {
        if (-not $Version) {
            Write-Host "`n[!] Você precisa passar a versão. Ex: nvs use 20.17.0" -ForegroundColor Red
            exit 1
        }
        Use-Version -Version $Version
    }
    "install" {
        if (-not $Version) {
            Write-Host "`n[!] Você precisa passar a versão. Ex: nvs install 20.17.0 ou nvs install 20" -ForegroundColor Red
            exit 1
        }
        Install-Version -version $Version -arch $Arch
    }
    "uninstall" {
        if (-not $Version) {
            Write-Host "`n[!] Você precisa passar a versão. Ex: nvs uninstall 20.17.0" -ForegroundColor Red
            exit 1
        }
        Uninstall-Version -version $Version
    }
    "current" { Show-Current }
    "setup" { Initialize }
    "reset" { Reset-Configuration }
    "help" { 
        Write-Host "`nUso: nvs <comando> [versão] [arquitetura]`n"
        Write-Host "Comandos disponíveis:" -ForegroundColor Cyan
        Write-Host "  available [-LTS] [filtro]     Lista as versões disponíveis para download (ex.: 'nvs available 20' para versões 20.x.x)."
        Write-Host "  current                       Mostra a versão do Node.js atualmente ativa."
        Write-Host "  help                          Exibe a listagem de comandos."
        Write-Host "  install <versão> [x86|x64]    Instala uma versão específica do Node.js (ex.: 20.17.0 ou 20, padrão: x64)."
        Write-Host "  list                          Lista as versões do Node.js instaladas."
        Write-Host "  reset                         Redefine todas as configurações (remove pastas e alias)."
        Write-Host "  setup                         Configura a infraestrutura inicial (pastas, alias, etc.)."
        Write-Host "  use <versão>                  Ativa uma versão específica do Node.js."
        Write-Host "  uninstall <versão>            Remove uma versão específica do Node.js."
        Write-Host "`nExemplos:" -ForegroundColor Yellow
        Write-Host "  nvs available -LTS"
        Write-Host "  nvs install 20 x86"
        Write-Host "  nvs uninstall 20.17.0`n"
    }
}