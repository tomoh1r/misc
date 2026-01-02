if (-not $(chcp).Contains(' 65001')) { chcp 65001; }

$private:miscPath = $(Join-Path (Join-Path $HOME ".local") "misc")
. $(Join-Path (Join-Path $miscPath "etc") "Microsoft.PowerShell_profile.ps1")

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
# Set-Location HOME if pwsh.exe
if ($(Get-Location).Path -eq "C:\Windows\System32") { Set-Location $HOME; }
