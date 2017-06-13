# Install:
#   Install-Module -Scope CurrentUser -Name Pscx -RequiredVersion 3.2.1.0 -AllowClobber
#

$OutputEncoding = [Text.Encoding]::Default
$ENV:LANG = "ja_JP.CP932"

# ### Module ###

$Env:PSModulePath = "$Env:UserProfile\misc\lib\WindowsPowerShell\Modules;" + $Env:PSModulePath

# PowerShell ReadLine
# see https://github.com/lzybkr/PSReadLine#installation
if($host.Name -eq 'ConsoleHost')
{
    Import-Module -Name posh-git
    Import-Module -Name Pscx
    Import-Module -Name PSWindowsUpdate
    Set-Alias -Name cd -Value home\Set-LocationExHome -Option AllScope
    Set-PSReadlineOption -EditMode Emacs
}

# ### some ###

# vim
Set-Null-Env -Name "VIM"
Set-Null-Env -Name "VIMRUNTIME"
Set-Alias -name vi -value vim.exe
Remove-Item -ErrorAction SilentlyContinue Alias:vim

# git diffw
Set-Item -Path ENV:\MY_GIT_DIFF_ENC -Value CP932

# grep
Set-Alias -Name grep -Value Select-String

# plink
#Set-Alias -name plink -value "<plink path>"

# Python
#$ENV:DISTUTILS_USE_SDK = 1
$ENV:PATHEXT += ";.PY"
# & "~\.local\venv\Scripts\activate.ps1"
#
# ### CleanUp & Common ###

# something else
$ENV:PATH = [String]::Join(';', ($ENV:PATH -split ';' | ? {$_ -ne ''} | % {$_.Trim() -replace '/', '\'}))
$ENV:PATHEXT = [String]::Join(';', ($ENV:PATHEXT -split ';' | ? {$_ -ne ''} | % { $_.Trim().ToUpper() }))

Set-Alias -Name ngen -Value (Join-Path ([System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()) ngen.exe)
[AppDomain]::CurrentDomain.GetAssemblies() |
    where { ( $_.Location ) } |
    where {      -not $_.Location.Contains("PSReadLine.dll") `
            -and -not $_.Location.Contains("Pscx.Core.dll") `
            -and -not $_.Location.Contains("Pscx.dll") `
            -and -not $_.Location.Contains("SevenZipSharp.dll") `
            } |
    sort { Split-path $_.location -leaf } |
    % {
        if (-not [System.Runtime.InteropServices.RuntimeEnvironment]::FromGlobalAccessCache($_))
        {
            Write-Host -ForegroundColor Yellow "NGENing : $(Split-Path $_.location -leaf)"
            ngen install $_.location /silent | %{"`t$_"}
        }
      }
