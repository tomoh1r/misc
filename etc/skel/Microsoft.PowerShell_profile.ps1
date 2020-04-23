$script:miscPath = $(Join-Path "$HOME/.local" "misc")
. $(Join-Path $miscPath "etc/Microsoft.PowerShell_profile.ps1")

# ### noprofile ###
$_vimDir = "vim-kaoriya-develop"
if ([Environment]::GetEnvironmentVariable('ConEmuTask') -ne $null -And `
        $Env:ConEmuTask.ToLower().Contains('noprofile')) {
    Push-EnvPath $(Join-Path "$HOME/Documents/Program" $_vimDir)

    [ScriptBlock]$Prompt = {
        $global:LASTEXITCODE = $LASTEXITCODE
        return "PS $(Get-Location)> "
    }

    Set-Item -Path Function:\Prompt -Value $Prompt -Options ReadOnly

    exit 0
}

# plink
#Set-Alias -name plink -value "<plink path>"

# $Env:JAVA_HOME = "C:\Program Files\Java\jdk1.8.0_121"
# $Env:JRE_HOME = "C:\Program Files\Java\jre1.8.0_121"
# $Env:PATH = "$Env:JRE_HOME\bin;$Env:JAVA_HOME\bin;$Env:PATH"

# $_vimDir = "nvim-win64\Neovim\bin"
# $ENV:PATH = "$HOME\Documents\Program\$_vimDir;$Env:PATH"

# $ENV:GIT_EDITOR = "~/Documents/Program/$_vimDir/vim.exe"
# $Env:GIT_SSH = "C:\Program Files\PuTTY\plink.exe"
# $Env:APPENGINE_HOME = ""

#Import-VisualStudioVars -VisualStudioVersion 2015 -Architecture amd64

[ScriptBlock]$Prompt = {
    $global:LASTEXITCODE = $LASTEXITCODE

    $local:prefix = $(Get-GitBranch)
    if ($prefix -ne $null)
    {
        $local:prefix = "(${prefix}) "
    }
    #Write-Host "$(Get-GitBranch)[$(Get-Date -Format 'yyyy/mm/dd hh:mm:ss')] PS $(Get-Pwd)"
    Write-Host "$prefix[$(Get-Date -Format 'yyyy/mm/dd hh:mm:ss')] PS $(Get-Pwd)"

    $global:LASTEXITCODE = $realLASTEXITCODE
    return "> "
}

Set-Item -Path Function:\Prompt -Value $Prompt
