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

#ri -ErrorAction SilentlyContinue Alias:ls
#$script:shimsRoot = Join-Path (Join-Path $Env:LOCALAPPDATA "mise") "shims"
#Set-Alias bat (Join-Path $shimsRoot "bat.cmd") -Force -Scope Global -Option AllScope
#Set-Alias eza (Join-Path $shimsRoot "eza.cmd") -Force -Scope Global -Option AllScope
#Set-Alias ls (Join-Path $shimsRoot "eza.cmd") -Force -Scope Global -Option AllScope
#Set-Alias fd (Join-Path $shimsRoot "fd.cmd") -Force -Scope Global -Option AllScope
#Set-Alias rg (Join-Path $shimsRoot "rg.cmd") -Force -Scope Global -Option AllScope
#Set-Alias zoxide (Join-Path $shimsRoot "zoxide.cmd") -Force -Scope Global -Option AllScope
#Set-Alias fzf (Join-Path $shimsRoot "fzf.cmd") -Force -Scope Global -Option AllScope
#function ll { process { eza -l $Args; } }
#if (Test-Path (Join-Path $shimsRoot "zoxide.cmd")) {
#    iex (&{(zoxide init powershell|Out-String)});
#}

[ScriptBlock]$Prompt = {
    Initialize-PSReadLineOnce

    $global:LASTEXITCODE = $LASTEXITCODE

    $private:prefix = Get-GitBranch
    if ($prefix -ne $null)
    {
        $private:prefix = "(${prefix}) "
    }
    Write-Host "${prefix}[$(Get-Date -Format 'yyyy/mm/dd hh:mm:ss')] PS $(Get-Pwd)"

    $global:LASTEXITCODE = $realLASTEXITCODE
    return "PS> "
}

Set-Item -Path Function:\Prompt -Value $Prompt
# Set-Location HOME if pwsh.exe
#if ($(Get-Location).Path -eq "C:\Windows\System32") { Set-Location $HOME; }
