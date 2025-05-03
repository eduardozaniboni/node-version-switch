<#
.SYNOPSIS
    Node Version Switch - A simple and lightweight Node.js version manager for Windows.

.DESCRIPTION
    Allows installing, using, uninstalling, and managing multiple Node.js versions on Windows.
    Configures an 'nvs' alias in the PowerShell profile for easy use.

.COMMANDS
    setup                           Sets up the initial infrastructure (folders, alias, etc.).
    list                            Lists installed Node.js versions.
    available [-LTS] [filter]       Lists available versions for download (e.g., 'nvs available 20' for 20.x.x versions).
    install <version> [x86|x64]     Installs a specific Node.js version (e.g., 20.17.0 or 20, default: x64). For partial versions (e.g., 20), installs the latest LTS version.
    use <version>                   Activates a specific Node.js version.
    uninstall <version>             Removes a specific Node.js version.
    current                         Shows the currently active Node.js version.
    reset                           Resets all configurations (removes folders and alias).
    help                            Displays the help message.

.EXAMPLE
    .\nvs\nvs.ps1 setup
    nvs available -LTS
    nvs available 20
    nvs install 20 x86
    nvs use 20.17.0
    nvs uninstall 20.17.0
    nvs help

.NOTES
    Author: Eduardo Walger Zaniboni
    Compatible with Windows PowerShell 5.1 and PowerShell Core 7+.
    Tested on Windows 10 and 11.
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
    Write-Host "`n[!] Invalid or unspecified command." -ForegroundColor Red
    exit 1
}

function Test-Configuration {
    if (-not (Test-Path $baseDir) -or -not (Test-Path $configDir) -or -not (Test-Path $configFile)) {
        Write-Host "`n[!] Initial configuration not found. Run '.\nvs\nvs.ps1 setup' to create the required structure." -ForegroundColor Red
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
            Write-Host "[+] Execution policy set to 'RemoteSigned'." -ForegroundColor Green
        }
    }
    catch {
        Write-Host "[!] Failed to change execution policy. Check your permissions." -ForegroundColor Red
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
        Write-Host "[!] The 'nvs' alias already exists. Remove it manually from the profile, choose another name or use 'nvs reset'." -ForegroundColor Red
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
                Write-Host "[+] Profile directory created at $profileDir." -ForegroundColor Green
            }
            catch {
                Write-Host "[!] Failed to create directory $profileDir. Check permissions." -ForegroundColor Red
                continue
            }
        }

        try {
            $tempFile = Join-Path $profileDir "test_$(Get-Random).tmp"
            New-Item -Path $tempFile -ItemType File -Force | Out-Null
            Remove-Item -Path $tempFile -Force
        }
        catch {
            Write-Host "[!] No write permission to $profileDir. Skipping this profile." -ForegroundColor Red
            continue
        }

        if (-not (Test-Path $path)) {
            try {
                New-Item -Path $path -ItemType File -Force | Out-Null
                Write-Host "[+] Profile file created at $path." -ForegroundColor Green
            }
            catch {
                Write-Host "[!] Failed to create file $path. Check permissions." -ForegroundColor Red
                continue
            }
        }

        try {
            $profileContent = Get-Content $path -Raw -ErrorAction SilentlyContinue
            if (-not $profileContent) { $profileContent = "" }
        }
        catch {
            Write-Host "[!] Failed to read profile $path. Check permissions." -ForegroundColor Red
            continue
        }

        if ($profileContent -notmatch [regex]::Escape($aliasCommand)) {
            try {
                Add-Content -Path $path -Value "`n$aliasCommand" -Encoding UTF8
                Write-Host "[+] 'nvs' alias added to profile at $path." -ForegroundColor Green
                $profileUpdated = $true
            }
            catch {
                Write-Host "[!] Failed to write alias to $path. Check permissions." -ForegroundColor Red
                continue
            }
        }

        if ($profileContent -notmatch [regex]::Escape($completerCommand)) {
            try {
                Add-Content -Path $path -Value "`n$completerCommand" -Encoding UTF8
                Write-Host "[+] Autocomplete for 'nvs' added to profile at $path." -ForegroundColor Green
                $profileUpdated = $true
            }
            catch {
                Write-Host "[!] Failed to write autocomplete to $path. Check permissions." -ForegroundColor Red
                continue
            }
        }

        if ($profileUpdated) { break }
    }

    if (-not $profileUpdated) {
        Write-Host "[!] Could not set up the alias automatically." -ForegroundColor Red
        Write-Host "Add the following to your profile manually (run 'notepad `$PROFILE' to edit):" -ForegroundColor Yellow
        Write-Host $aliasCommand
        Write-Host $completerCommand
        Write-Host "Expected profile path: $PROFILE" -ForegroundColor Yellow
    }
    else {
        Write-Host "Open a new PowerShell terminal to apply changes." -ForegroundColor Yellow
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
                Write-Host "[+] 'nvs' alias and autocomplete removed from profile at $path." -ForegroundColor Green
                $profileUpdated = $true
            }
            catch {
                Write-Host "[!] Failed to modify profile $path. Check permissions." -ForegroundColor Red
            }
        }
    }

    if ($profileUpdated) {
        Write-Host "Open a new PowerShell terminal to apply changes." -ForegroundColor Yellow
    }
    else {
        Write-Host "[!] No profiles were modified. Check if the 'nvs' alias is configured." -ForegroundColor Yellow
    }
}

function List-AvailableVersions {
    param (
        [string]$Filter,
        [switch]$LTS
    )

    if (-not (Test-InternetConnection)) {
        Write-Host "`n[!] Could not connect to the internet. Check your connection." -ForegroundColor Red
        Write-Host "Try again or verify your network/proxy settings." -ForegroundColor Yellow
        exit 1
    }

    Write-Host "`n[*] Fetching available versions from the Node.js website..." -ForegroundColor Cyan
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
            Write-Host "`n[!] No versions found with the specified filters." -ForegroundColor Yellow
            if ($Filter) { Write-Host "Filter applied: $Filter" -ForegroundColor Yellow }
            if ($LTS) { Write-Host "Only LTS versions requested." -ForegroundColor Yellow }
            return
        }

        $filteredVersions = $filteredVersions | Sort-Object { [Version]($_.version -replace '^v') } -Descending

        Write-Host "`nAvailable versions:" -ForegroundColor Cyan
        foreach ($ver in $filteredVersions) {
            $ltsLabel = if ($ver.lts -ne $false) { " (LTS: $($ver.lts))" } else { "" }
            Write-Host " - $($ver.version)$ltsLabel - Released: $($ver.date)"
        }
    }
    catch {
        Write-Host "`n[!] Error fetching available versions. Check your connection or try again later." -ForegroundColor Red
        Write-Host "Error details: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Try again or verify your network/proxy settings." -ForegroundColor Yellow
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
        Write-Host "`n[!] No Node.js versions found in $baseDir" -ForegroundColor Red
        return
    }

    Write-Host "`nInstalled versions:" -ForegroundColor Cyan
    foreach ($dir in $nodeDirs) {
        Write-Host " - $($dir.Name)"
    }

    $current = Get-Command node -ErrorAction SilentlyContinue
    if ($current) {
        Write-Host "`nActive version: $($current.Source)" -ForegroundColor Green
    }
    else {
        Write-Host "`nNo Node.js version is active in the current terminal." -ForegroundColor Yellow
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
        Write-Host "`n[!] Version v$Version not found in $targetPath" -ForegroundColor Red
        return
    }

    $pathParts = [System.Environment]::GetEnvironmentVariable("Path", "User") -split ';'
    if ($pathParts -contains ([System.IO.Path]::GetDirectoryName($nodeExe))) {
        Write-Host "`n[!] Version v$Version is already in the PATH. No changes needed." -ForegroundColor Yellow
        return
    }

    $otherNodePaths = $pathParts | Where-Object { $_ -match 'node\.exe$' -and $_ -notmatch [regex]::Escape($baseDir) }
    if ($otherNodePaths) {
        Write-Host "`n[!] Other Node.js installations found in the PATH:" -ForegroundColor Yellow
        $otherNodePaths | ForEach-Object { Write-Host " - $_" }
        Write-Host "This may cause conflicts. Consider removing them manually." -ForegroundColor Yellow
    }

    $oldPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $pathParts = $oldPath -split ';' | Where-Object { $_ -notmatch [regex]::Escape($baseDir) }
    $newPath = $pathParts -join ';'

    $nodeDir = [System.IO.Path]::GetDirectoryName($nodeExe)
    $newPath = "$nodeDir;$newPath"

    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")

    Write-Host "`nNow using Node.js v$Version" -ForegroundColor Green
    Write-Host "Open a new terminal to apply the change." -ForegroundColor Yellow
}

function Resolve-Version {
    param ($version)
    if ($version -notmatch '^\d+\.\d+\.\d+$') {
        if (-not (Test-InternetConnection)) {
            Write-Host "`n[!] Could not connect to the internet to resolve version $version." -ForegroundColor Red
            Write-Host "Try again or verify your network/proxy settings." -ForegroundColor Yellow
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
                Write-Host "`n[!] No LTS version found for the $version series." -ForegroundColor Red
                Write-Host "Use 'nvs available $version' to list all available versions in this series." -ForegroundColor Yellow
                exit 1
            }
        }
        catch {
            Write-Host "`n[!] Error resolving version $version. Check your connection or try again later." -ForegroundColor Red
            Write-Host "Error details: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "Try again or verify your network/proxy settings." -ForegroundColor Yellow
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

    Write-Host "`n[*] Downloading Node.js version v$version ($arch)..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $url -OutFile $zipFile

    Write-Host "`n[*] Extracting ZIP file..." -ForegroundColor Cyan
    Expand-Archive -Path $zipFile -DestinationPath $destPath -Force
    Move-Item -Path "$destPath\node-v$version-$archSuffix\*" -Destination $destPath -Force
    Remove-Item -Path "$destPath\node-v$version-$archSuffix" -Recurse -Force
    Remove-Item -Path $zipFile -Force

    Write-Host "`n[+] Download and extraction of version v$version ($arch) completed." -ForegroundColor Green
}

function Install-Version {
    param ($version, $arch)

    Test-Configuration
    if (-not (Test-InternetConnection)) {
        Write-Host "[!] Could not connect to the internet. Download cannot proceed." -ForegroundColor Red
        Write-Host "Try again or verify your network/proxy settings." -ForegroundColor Yellow
        exit 1
    }

    $resolvedVersion = Resolve-Version -version $version
    Write-Host "`n[*] Resolved version: v$resolvedVersion" -ForegroundColor Cyan

    if (-not (Test-NodeVersion -version $resolvedVersion)) {
        Write-Host "`n[!] Version v$resolvedVersion does not exist on the Node.js website." -ForegroundColor Red
        exit 1
    }

    $targetPath = Join-Path $baseDir "v$resolvedVersion"
    if (Test-Path "$targetPath\node.exe") {
        Write-Host "`n[!] Version v$resolvedVersion is already installed at $targetPath" -ForegroundColor Red
        return
    }

    Download-Version -version $resolvedVersion -arch $arch
    Write-Host "`n[+] Installation completed." -ForegroundColor Green
}

function Uninstall-Version {
    param ($version)

    Test-Configuration
    $targetPath = Join-Path $baseDir "v$version"
    if (-not (Test-Path $targetPath)) {
        Write-Host "`n[!] Version v$version is not installed at $targetPath" -ForegroundColor Red
        return
    }

    Write-Host "`n[*] Removing version v$version..." -ForegroundColor Cyan
    Remove-Item -Path $targetPath -Recurse -Force
    Write-Host "[+] Version v$version removed successfully." -ForegroundColor Green
}

function Show-Current {
    Test-Configuration
    $current = Get-Command node -ErrorAction SilentlyContinue
    if ($current) {
        Write-Host "`nActive version: $($current.Source)" -ForegroundColor Green
    }
    else {
        Write-Host "`nNo Node.js version is active in the current terminal." -ForegroundColor Yellow
    }
}

function Initialize {
    try {
        $testFile = Join-Path $projectRoot "test_$(Get-Random).tmp"
        New-Item -Path $testFile -ItemType File -Force | Out-Null
        Remove-Item -Path $testFile -Force
    }
    catch {
        Write-Host "`n[!] No write permission to $projectRoot. Move the project to a directory with write permissions or run PowerShell as administrator." -ForegroundColor Red
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
        Write-Host "[*] Creating base directory at $baseDir..." -ForegroundColor Cyan
        New-Item -Path $baseDir -ItemType Directory | Out-Null
    }

    if (-not (Test-Path $configDir)) {
        Write-Host "[*] Creating configuration directory at $configDir..." -ForegroundColor Cyan
        New-Item -Path $configDir -ItemType Directory | Out-Null
    }

    $config = Get-Config
    if (-not $config) {
        $config = [PSCustomObject]@{
            BasePath = $baseDir
            ScriptPath = [System.IO.Path]::GetFullPath($PSCommandPath)
        }
        Save-Config -Config $config
        Write-Host "[+] Configuration saved to $configFile." -ForegroundColor Green
    }

    Set-ExecutionPolicy-IfNeeded
    Set-NodeVersionSwitchAlias

    Write-Host "[+] Initial setup completed!" -ForegroundColor Green
}

function Reset-Configuration {
    Write-Host "`n[*] Resetting configurations..." -ForegroundColor Cyan

    if (Test-Path $baseDir) {
        Remove-Item -Path $baseDir -Recurse -Force
        Write-Host "[+] Folder $baseDir removed." -ForegroundColor Green
    }

    if (Test-Path $configDir) {
        Remove-Item -Path $configDir -Recurse -Force
        Write-Host "[+] Folder $configDir removed." -ForegroundColor Green
    }

    Remove-NodeVersionSwitchAlias

    Write-Host "[+] Configurations reset successfully. Run '.\nvs\nvs.ps1 setup' to reconfigure." -ForegroundColor Green
}

switch ($Command) {
    "list" { List-Versions }
    "available" { List-AvailableVersions -Filter $Version -LTS:$LTS }
    "use" {
        if (-not $Version) {
            Write-Host "`n[!] You must specify a version. Example: nvs use 20.17.0" -ForegroundColor Red
            exit 1
        }
        Use-Version -Version $Version
    }
    "install" {
        if (-not $Version) {
            Write-Host "`n[!] You must specify a version. Example: nvs install 20.17.0 or nvs install 20" -ForegroundColor Red
            exit 1
        }
        Install-Version -version $Version -arch $Arch
    }
    "uninstall" {
        if (-not $Version) {
            Write-Host "`n[!] You must specify a version. Example: nvs uninstall 20.17.0" -ForegroundColor Red
            exit 1
        }
        Uninstall-Version -version $Version
    }
    "current" { Show-Current }
    "setup" { Initialize }
    "reset" { Reset-Configuration }
    "help" { 
        Write-Host "`nUsage: nvs <command> [version] [architecture]`n"
        Write-Host "Available commands:" -ForegroundColor Cyan
        Write-Host "  available [-LTS] [filter]     Lists available versions for download (e.g., 'nvs available 20' for 20.x.x versions)."
        Write-Host "  current                       Shows the currently active Node.js version."
        Write-Host "  help                          Displays the command list."
        Write-Host "  install <version> [x86|x64]   Installs a specific Node.js version (e.g., 20.17.0 or 20, default: x64). For partial versions, installs the latest LTS."
        Write-Host "  list                          Lists installed Node.js versions."
        Write-Host "  reset                         Resets all configurations (removes folders and alias)."
        Write-Host "  setup                         Sets up the initial infrastructure (folders, alias, etc.)."
        Write-Host "  use <version>                 Activates a specific Node.js version."
        Write-Host "  uninstall <version>           Removes a specific Node.js version."
        Write-Host "`nExamples:" -ForegroundColor Yellow
        Write-Host "  nvs available -LTS"
        Write-Host "  nvs install 20 x86"
        Write-Host "  nvs uninstall 20.17.0`n"
    }
}