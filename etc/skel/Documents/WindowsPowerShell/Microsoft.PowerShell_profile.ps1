# cp932
#
# Init(Admin):
#   > Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
# Init:
#   > Install-Module -Name posh-git -Scope CurrentUser -Force -AllowClobber
#   > Install-Module -Name Pscx -Scope CurrentUser -Force -AllowClobber
#

#. "$HOME\Documents\WindowsPowerShell\Modules\posh-git\profile.example.ps1"
. "$HOME\misc\etc\Microsoft.PowerShell_profile.ps1"

# vim ‚ÌÝ’è
#$ENV:Path = "$HOME\Documents\Application\vim80-kaoriya-win64-8.0.0039-20161016;$Env:Path"
Remove-Item -ErrorAction SilentlyContinue Alias:vim

Set-Alias -Name grep -Value Select-String

#Import-VisualStudioVars -VisualStudioVersion 2015 -Architecture amd64

[ScriptBlock]$Prompt = {
    $realLASTEXITCODE = $LASTEXITCODE
    $Host.UI.RawUI.ForegroundColor = "White"
    Write-Host "$(git_branch)$(hg_branch)[$(Get-Date -Format 'yyyy/mm/dd hh:mm:ss')] PS $(_get_pwd)"
    $global:LASTEXITCODE = $realLASTEXITCODE
    return "> "
}

Set-Item -Path function:\prompt -Value $Prompt -Options ReadOnly
