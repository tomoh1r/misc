# cp932
#
# Init(Admin):
#   > Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
# Init:
#   > Install-Module -Name posh-git -Scope CurrentUser -Force -AllowClobber
#   > Install-Module -Name Pscx -Scope CurrentUser -Force -AllowClobber
#

foreach($_name in @('VIM', 'VIMRUNTIME')) {
    if ([Environment]::GetEnvironmentVariable($_name) -ne $null) {
        [Environment]::SetEnvironmentVariable($_name, $null, "User")
    }
}
Remove-Item -ErrorAction SilentlyContinue Alias:vi
Remove-Item -ErrorAction SilentlyContinue Alias:vim
Set-Alias -name vi -value vim.exe

# for cmder NoProfile
$_vimDir = "vim-kaoriya-develop"
if ([Environment]::GetEnvironmentVariable('ConEmuTask') -ne $null -And `
        $Env:ConEmuTask.ToLower().Contains('noprofile')) {
    $Env:Path = "$HOME\Documents\Program\$_vimDir;$Env:Path"

    [ScriptBlock]$Prompt = {
        $global:LASTEXITCODE = $LASTEXITCODE
        return "PS $(Get-Location)> "
    }

    Set-Item -Path Function:\Prompt -Value $Prompt -Options ReadOnly

    exit 0
}

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
    $global:LASTEXITCODE = $realLASTEXITCODE
    return "> "
}

Set-Item -Path Function:\Prompt -Value $Prompt
