# ### cmder noprofile ###
if ([Environment]::GetEnvironmentVariable('ConEmuTask') -ne $null -And `
        $Env:ConEmuTask.ToLower().Contains('noprofile')) {
    return
}

# ### module ###
$private:pathsep = ":"
if (($PSVersionTable.Platform -eq "Win32NT") -or ($Env:OS -eq "Windows_NT"))
{
    $private:pathsep = ";"
}

function private:Import-ModuleEx
{
    param([string]$name)
    if (-not (Get-Module -Name $name -ErrorAction Ignore)) {
        Import-Module -Name $name
    }
}

$private:parent = Split-Path $PSScriptRoot -Parent
$private:mymodpath = Join-Path (Join-Path (Join-Path $parent "lib") "WindowsPowerShell") "Modules"
$Env:PSModulePath = "$mymodpath${pathsep}$Env:PSModulePath"
Import-ModuleEx -Name home
$Env:PSModulePath = home\Remove-EnvPathDuplicates $Env:PSModulePath

$OutputEncoding = [Text.Encoding]::Default
$Env:LANG = "ja_JP.UTF-8"
#if (home\Test-Windows) { $Env:LANG = "ja_JP.CP932"; }

# PSReadLine 設定を初回入力まで遅延
function script:Initialize-PSReadLineOnce {
    if ($script:PSReadLineInitialized) { return }
    $script:PSReadLineInitialized = $true

    #Import-ModuleEx -Name posh-git
    #Import-ModuleEx -Name PSReadLine

    if (-not (Get-Module -Name PSReadLine -ErrorAction Ignore)) {
        Import-Module PSReadLine -ErrorAction SilentlyContinue | Out-Null
    }

    if (Get-Module -Name PSReadLine -ErrorAction Ignore) {
        Set-PSReadLineOption -EditMode Emacs
        Set-PSReadLineOption -BellStyle None
    }
}

# ### init env ###

& {
    if ($Env:PATH -eq $null -and $Env:Path -ne $null)
    {
        $Env:PATH = home\Resolve-HomePath $Env:Path
    }

    $fpath = Join-Path $HOME ".env"
    if (-not $(Test-Path $fpath)) {
        return
    }

    $fenc = [System.Text.Encoding]::GetEncoding(65001)
    if (home\Test-Windows) { $fenc = [System.Text.Encoding]::GetEncoding(932); }
    $fp = New-Object System.IO.StreamReader($fpath, $fenc)
    $private:pathsep = Get-PathSep
    while (($line = $fp.ReadLine()) -ne $null)
    {
        $splitted = $line.Trim().Split("=")
        if ($splitted.Length -eq 2) {
            $key, $value = $splitted[0].Trim(), $splitted[1].Trim()
            if ($key -eq "" -or $value -eq "") { continue; }

            if ($key -eq "PATH") { home\Push-EnvPath $value; }
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

Remove-Item Alias:touch -ErrorAction SilentlyContinue
Remove-Item Alias:vi -ErrorAction SilentlyContinue
Remove-Item Alias:vim -ErrorAction SilentlyContinue
#Set-Alias cd home\Set-LocationExHome -Force -Scope Global -Option AllScope -Description "home alias"
Set-Alias env home\Get-ChildItemEnv -Force -Scope Global -Option AllScope -Description "home alias"
Set-Alias which home\Get-CommandPath -Force -Scope Global -Option AllScope -Description "home alias"
Set-Alias touch home\New-SimpleItem -Force -Scope Global -Option AllScope -Description "home alias"

#if (home\Test-Windows)
#{
    #Import-ModuleEx -Name Pscx
    #Import-ModuleEx -Name PSWindowsUpdate
#}

# ### common ###

#$private:binSuffix = ""
#if (home\Test-Windows) { $private:binSuffix = ".exe"; }
#Set-Alias -name vi -value "nvim${binSuffix}"
#Set-Alias -name vim -value "nvim${binSuffix}"
#Set-Alias -Name grep -Value Select-String
