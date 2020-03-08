if ($IsWindows -eq $null)
{
    $global:IsWindows = $false
    if ($PSVersionTable.Platform -eq "Win32NT")
    {
        $global:IsWindows = $true
    }
    elseif ($Env:OS -eq "Windows_NT")
    {
        $global:IsWindows = $true
    }
}

$OutputEncoding = [Text.Encoding]::Default
$Env:LANG = "ja_JP.UTF-8"
if ($IsWindows) { $Env:LANG = "ja_JP.CP932"; }

$script:pathsep = ":"
if ($IsWindows) { $script:pathsep = ";"; }
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

function Push-EnvPath ($paths)
{
    foreach ($path in $paths.Split($pathsep))
    {
        if (-not $Env:PATH.Contains($path))
        {
            $Env:PATH = $(Join-EnvPath $path $Env:PATH)
        }
    }
}

Remove-Item -ErrorAction SilentlyContinue Alias:vi
Remove-Item -ErrorAction SilentlyContinue Alias:vim

# ### noprofile ###
if ([Environment]::GetEnvironmentVariable('ConEmuTask') -ne $null -And `
        $Env:ConEmuTask.ToLower().Contains('noprofile')) {
    return
}

function Import-ModuleEx ($name)
{
    if ($(Get-Module -ErrorAction Ignore $name) -eq $null)
    {
        Import-Module -Name $name
    }
}

# ### init env ###

& {
    if ($Env:PATH -eq $null -and $Env:Path -ne $null)
    {
        $Env:PATH = Settle-Path $Env:Path
    }

    $fpath = Join-Path $HOME ".env"
    if (-not $(Test-Path $fpath)) {
        return
    }

    $fenc = [System.Text.Encoding]::GetEncoding(65001)
    if ($IsWindows) { $fenc = [System.Text.Encoding]::GetEncoding(932); }
    $fp = New-Object System.IO.StreamReader($fpath, $fenc)
    while (($line = $fp.ReadLine()) -ne $null)
    {
        $splitted = $line.Trim().Split("=")
        if ($splitted.Length -eq 2) {
            $key, $value = $splitted[0].Trim(), $splitted[1].Trim()
            if ($key -eq "" -or $value -eq "") { continue; }

            if ($key -eq "PATH") { Push-EnvPath $value; }
            if ($key -eq "PATHEXT")
            {
                foreach ($path in $value.Split($pathsep))
                {
                    if ($Env:PATHEXT -eq $null)
                    {
                        Set-Item -Path "Env:PATHEXT" -value $path
                    }
                    elseif (-not $Env:PATHEXT.Contains($path))
                    {
                        Set-Item -Path "Env:PATHEXT" -value $(Join-EnvPath $Env:PATHEXT $path)
                    }
                }
            }
            elseif ($(Get-Item -Path "Env:$key" -ErrorAction Ignore) -eq $null -and `
                    (-not $key.StartsWith("#")))
            {
                Set-Item -Path "Env:$key" -Value $value
            }
        }
    }
    $fp.Close()
}

# ### module ###

$Env:PSModulePath = Join-EnvPath `
    $(Join-Path $miscPath "lib/WindowsPowerShell/Modules") `
    $Env:PSModulePath

Import-ModuleEx -Name home
Import-ModuleEx -Name posh-git
Set-PSReadlineOption -EditMode Emacs
Set-Alias cd home\Set-LocationExHome -Force -Scope Global -Option AllScope -Description "home alias"

if ($IsWindows)
{
    Import-ModuleEx -Name Pscx
    Import-ModuleEx -Name PSWindowsUpdate
}

# ### common ###

$local:binSuffix = ""
if ($IsWindows) { $local:binSuffix = ".exe"; }
Set-Alias -name vi -value "nvim${binSuffix}"
Set-Alias -name vim -value "nvim${binSuffix}"

Set-Alias -Name grep -Value Select-String

# ### finalize ###
# optimize
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
