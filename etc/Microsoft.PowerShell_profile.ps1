# Install:
#   Install-Module -Scope CurrentUser -Name Pscx -RequiredVersion 3.2.1.0 -AllowClobber
#

$global:_isWin = $false
if ($IsWindows)
{
    $global:_isWin = $true
}
elseif ($PSVersionTable.Platform -eq "Win32NT")
{
    $global:_isWin = $true
}
elseif ($Env:OS -eq "Windows_NT")
{
    $global:_isWin = $true
}

$OutputEncoding = [Text.Encoding]::Default
$Env:LANG = "ja_JP.UTF-8"
if ($_isWin) { $Env:LANG = "ja_JP.CP932"; }

$script:pathsep = ":"
if ($_isWin) { $script:pathsep = ";"; }
$script:dirsep = [IO.Path]::DirectorySeparatorChar

function Settle-Path ($param)
{
    return $(Split-Path $(Join-Path $param "aaa"))
}

function Join-EnvPath ($first, $second)
{
    if ($first -ne $null -and $second -ne $null) {
        return "$(Settle-Path $first)${pathsep}$(Settle-Path $second)"
    } elseif ($first -ne $null) {
        return $(Settle-Path $first)
    } elseif ($second -ne $null) {
        return $(Settle-Path $second)
    }
}

function Push-EnvPath ($path)
{
    $Env:PATH = $(Join-EnvPath $path $Env:PATH)
}

function Import-DotEnv ()
{
    $fpath = Join-Path $HOME ".env"
    if (-not $(Test-Path $fpath)) {
        return
    }

    $fenc = [System.Text.Encoding]::GetEncoding(65001)
    if ($_isWin) { $fenc = [System.Text.Encoding]::GetEncoding(932); }
    $fp = New-Object System.IO.StreamReader($fpath, $fenc)
    while (($line = $fp.ReadLine()) -ne $null)
    {
        $splitted = $line.Trim().Split("=")
        if ($splitted.Length -eq 2) {
            $key, $value = $splitted
            if ($(Get-Item -Path "Env:$key" -ErrorAction Ignore).Length -eq 0 -and `
                    (-not $key.StartsWith("#")))
            {
                Set-Item -Path "Env:$key" -Value $value
            }
        }
    }
    $fp.Close()
}
Import-DotEnv

if ($Env:PATH -eq $null)
{
    $Env:PATH = Settle-Path $Env:Path
}

Remove-Item -ErrorAction SilentlyContinue Alias:vi
Remove-Item -ErrorAction SilentlyContinue Alias:vim

# ### noprofile ###
if ([Environment]::GetEnvironmentVariable('ConEmuTask') -ne $null -And `
        $Env:ConEmuTask.ToLower().Contains('noprofile')) {
    return
}

# ### Module ###

$Env:PSModulePath = Join-EnvPath `
    $(Join-Path $miscPath "lib/WindowsPowerShell/Modules") `
    $Env:PSModulePath

Import-Module -Name posh-git
Set-PSReadlineOption -EditMode Emacs

# PowerShell ReadLine
# see https://github.com/lzybkr/PSReadLine#installation
if ($_isWin)
{
    Import-Module -Name Pscx
    Import-Module -Name PSWindowsUpdate
    Set-Alias -Name cd -Value home\Set-LocationExHome -Option AllScope
}

# ### some ###

# git diffw
$script:myGitDiffEnc = "UTF8"
if ($_isWin) { $script:myGitDiffEnc = "CP932"; }
Set-Item -Path ENV:\MY_GIT_DIFF_ENC -Value $script:myGitDiffEnc

# grep
Set-Alias -Name grep -Value Select-String

# plink
#Set-Alias -name plink -value "<plink path>"

# Python
#$ENV:DISTUTILS_USE_SDK = 1
$Env:PATHEXT = $(Join-EnvPath $ENV:PATHEXT ".PY")
# & "~\.local\venv\Scripts\activate.ps1"

Set-Alias -Name grep -Value Select-String

$Env:PIPSI_HOME = $(Join-Path $miscPath "var/pyvenv/pipsi")
$Env:PIPSI_BIN_DIR = $(Join-Path $miscPath "cmd")

# ### CleanUp & Common ###

# something else
#$ENV:PATH = [String]::Join(';', ($ENV:PATH -split ';' | ? {$_ -ne ''} | % {$_.Trim() -replace '/', '\'}))
#$ENV:PATHEXT = [String]::Join(';', ($ENV:PATHEXT -split ';' | ? {$_ -ne ''} | % { $_.Trim().ToUpper() }))

if ($PSVersionTable.PSVersion.Major -lt 6)
{
    Set-Alias -Name ngen -Value (Join-Path ([System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()) ngen.exe)
    [AppDomain]::CurrentDomain.GetAssemblies() |
        where { ( $_.Location ) } |
        where {      -not $_.Location.Contains("PSReadLine.dll") `
                -and -not $_.Location.Contains("Pscx.Core.dll") `
                -and -not $_.Location.Contains("Pscx.dll") `
                -and -not $_.Location.Contains("SevenZipSharp.dll") `
                -and -not $_.Location.Contains("Microsoft.PackageManagement.dll") `
                -and -not $_.Location.Contains("Microsoft.PowerShell.PackageManagement.dll") `
                -and -not $_.Location.Contains("PSWindowsUpdate.dll") `
                } |
        sort { Split-path $_.location -leaf } |
        % {
            if (-not [System.Runtime.InteropServices.RuntimeEnvironment]::FromGlobalAccessCache($_))
            {
                Write-Host -ForegroundColor Yellow "NGENing : $(Split-Path $_.location -leaf)"
                ngen install $_.location /silent | %{"`t$_"}
            }
          }
}
