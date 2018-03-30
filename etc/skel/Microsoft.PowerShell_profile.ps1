# cp932
#
# Init(Admin):
#   > Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
# Init:
#   > Install-Module -Name posh-git -Scope CurrentUser -Force -AllowClobber
#   > Install-Module -Name Pscx -Scope CurrentUser -Force -AllowClobber
#

# $Env:JAVA_HOME = "C:\Program Files\Java\jdk1.8.0_121"
# $Env:JRE_HOME = "C:\Program Files\Java\jre1.8.0_121"
# $Env:Path = "$Env:JRE_HOME\bin;$Env:JAVA_HOME\bin;$Env:Path"
# $_vimDir = "vim-kaoriya-develop"
# $ENV:Path = "$HOME\Documents\Program\$_vimDir;$Env:Path"
$Env:Path = "$HOME\misc\cmd;$Env:Path"

. "$HOME\misc\etc\Microsoft.PowerShell_profile.ps1"

# $ENV:GIT_EDITOR = "~/Documents/Program/$_vimDir/vim.exe"
# $Env:GIT_SSH = "C:\Program Files\PuTTY\plink.exe"
# $Env:APPENGINE_HOME = ""

#Import-VisualStudioVars -VisualStudioVersion 2015 -Architecture amd64

[ScriptBlock]$Prompt = {
    $global:LASTEXITCODE = $LASTEXITCODE
    Write-Host "$(Get-Git-Branch)$(Get-Hg-Branch)[$(Get-Date -Format 'yyyy/mm/dd hh:mm:ss')] PS $(Get-Pwd)"
    return "> "
}

Set-Item -Path Function:\Prompt -Value $Prompt -Options ReadOnly
