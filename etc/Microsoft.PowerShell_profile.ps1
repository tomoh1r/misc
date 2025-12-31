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

function Get-ShortPath
{
    param([string]$name)
    begin { $private:fso = New-Object -ComObject Scripting.FileSystemObject }
    process
    {
        $private:result = $null
        foreach ($path in $name.Split($dirsep))
        {
            if ($result -eq $null)
            {
                $private:result = $path
                continue
            }

            $private:joined = $(Join-Path $result $path)
            try {
                $private:fsi = $(Get-Item $joined -ErrorAction Stop)
            }
            catch
            {
                $private:result = $joined
                continue
            }

            if ($fsi.psiscontainer)
            {
                $private:result = $fso.GetFolder($fsi.FullName).ShortPath
            }
            else
            {
                $private:result = $fso.GetFile($fsi.FullName).ShortPath
            }
        }
        return $result
    }
}

function Settle-Path
{
    param ([string]$path)
    # 末尾 ; とかで空白文字列が渡ってきた場合返す
    if([System.String]::IsNullOrEmpty($path.Trim())) {
      return $path
    }

    $splitted = ($path.Trim()) -replace '^~', $HOME
    return Split-Path -Path $(Join-Path -Path $splitted -Child dmy) -Parent
}

function Join-EnvPath
{
    param ([string]$first, [string]$second)
    if ($first -ne "" -and $second -ne "") {
        return "$($first)${pathsep}$($second)"
    } elseif ($first -ne "") {
        return $($first)
    } elseif ($second -ne "") {
        return $($second)
    }
}

function Push-EnvPath
{
    param([Array]$Paths)
    $private:dstPath = [System.Collections.ArrayList]::new()
    $paths -split $pathsep | `
        % { Settle-Path $_ } | `
        ? { -not $Env:PATH.Contains($settled) } | `
        % { [void]$dstPath.Add($(Get-ShortPath $_)) }
    $Env:PATH -split $pathsep | ` 
        % { Settle-Path $_ } | `
        % { [void]$dstPath.Add($(Get-ShortPath $_)) }
    $Env:Path = $($dstPath.ToArray() -join $pathsep)
}

Remove-Item -ErrorAction SilentlyContinue Alias:vi
Remove-Item -ErrorAction SilentlyContinue Alias:vim

# ### noprofile ###
if ([Environment]::GetEnvironmentVariable('ConEmuTask') -ne $null -And `
        $Env:ConEmuTask.ToLower().Contains('noprofile')) {
    return
}

function Import-ModuleEx
{
    param([string]$name)
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
    si -Path "Env:PATH" -Value (gi -Path Env:PATH).Value.Trim(";")
}

# ### module ###

$private:parent = Split-Path $PSScriptRoot -Parent
$private:mymodpath = $(Join-Path $(Join-Path $(Join-Path $parent "lib") "WindowsPowerShell") "Modules")
$Env:PSModulePath = Join-EnvPath $mymodpath $Env:PSModulePath

Import-ModuleEx -Name home
#Import-ModuleEx -Name posh-git
#Import-ModuleEx -Name PSReadLine
Set-PSReadlineOption -EditMode Emacs
Set-PSReadlineOption -BellStyle None
Set-Alias cd home\Set-LocationExHome -Force -Scope Global -Option AllScope -Description "home alias"

#if ($IsWindows)
#{
    #Import-ModuleEx -Name Pscx
    #Import-ModuleEx -Name PSWindowsUpdate
#}

# ### common ###

#$private:binSuffix = ""
#if ($IsWindows) { $private:binSuffix = ".exe"; }
#Set-Alias -name vi -value "nvim${binSuffix}"
#Set-Alias -name vim -value "nvim${binSuffix}"

#Set-Alias -Name grep -Value Select-String

#ri -Path Function:Get-ShortPath
ri -Path Function:Settle-Path
ri -Path Function:Join-EnvPath
ri -Path Function:Push-EnvPath
ri -Path Function:Import-ModuleEx
