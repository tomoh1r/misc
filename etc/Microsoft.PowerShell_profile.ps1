# cp932
#
# Install:
#   Install-Module -Scope CurrentUser -Name Pscx -RequiredVersion 3.2.1.0 -AllowClobber
#
$OutputEncoding = [Text.Encoding]::Default
$ENV:LANG = "ja_JP.CP932"

# vim
[Environment]::SetEnvironmentVariable("VIM", $null, "User")
[Environment]::SetEnvironmentVariable("VIMRUNTIME", $null, "User")
Set-Alias -name vi -value vim.exe

# git diffw
Set-Item -Path ENV:\MY_GIT_DIFF_ENC -Value CP932

# plink
#Set-Alias -name plink -value "<plink path>"

# Python
#$ENV:DISTUTILS_USE_SDK = 1
$ENV:PATHEXT += ";.PY"
# & "~\.local\venv\Scripts\activate.ps1"
#
# ### SetUp PATH ###

# something else
$ENV:PATH = [String]::Join(';', ($ENV:PATH -split ';' | ? {$_ -ne ''} | % {$_.Trim() -replace '/', '\'}))
$ENV:PATHEXT = [String]::Join(';', ($ENV:PATHEXT -split ';' | ? {$_ -ne ''} | % { $_.Trim().ToUpper() }))

# PowerShell ReadLine
# see https://github.com/lzybkr/PSReadLine#installation
if($host.Name -eq 'ConsoleHost')
{
    Import-Module Pscx
    Import-Module PSReadline
    Set-PSReadlineOption -EditMode Emacs

    Function _reverse_check(){
        Param(
            $path,
            $dir_name
        )

        Process
        {
            $_path = $(Convert-Path -Path $path)
            $_root = $(Join-Path (Split-Path -Path $_path -Qualifier) '\')
            if(Test-Path (Join-Path $_path $dir_name)){
                return $TRUE;
            }elseif($_root -eq $_path){
                return $FALSE;
            }else{
                $_parent = Split-Path -Path $_path -Parent
                _reverse_check $_parent $dir_name
            }
        }
    }

    Function git_branch(){
        Process
        {
            if(-not (_reverse_check $PWD.Path '.git')){
                return
            }

            git branch 2>$null |
                ?{-not [System.String]::IsNullOrEmpty($_.Split()[0])} |
                %{$bn = $_.Split()[1]
                    Write-Output "(git:$bn) " }
        }
    }

    Function hg_branch(){
        Process
        {
            if(-not (_reverse_check $PWD.Path '.hg')){
                return
            }

            hg branch 2>$null | %{Write-Output "(hg:$_) "}
        }
    }

    # return current directory
    # with $ENV:HOME to ~
    Function _get_pwd(){
        $path = $(Get-Location).Path
        if($path.IndexOf($ENV:HOME) -eq 0){
            $path = Join-Path '~' ($PWD.ProviderPath.Remove(0, ($ENV:HOME).Length))
        }
        return $path
    }

    Function Get-SortedCommand() {
        Process
        {
            Return Get-Command | sort { $_.Source, $_.CommandType, $_.Name} | select Source, Name, CommandType, Version
        }
    }

    Remove-Item Alias:cd
    Function cd() {
        Param(
            [Parameter(Mandatory = $false, Position = 0)]
            [string]$Path
            )

        Process {
            if([string]::IsNullOrEmpty("$Path")){
                Pscx\Set-LocationEx -Path $HOME
            }else{
                Pscx\Set-LocationEx -Path $Path
            }
        }
    }

    Function env(){
        Process {Get-ChildItem ENV:}
    }

    Function which(){
        Param([string]$name)

        Process
        {
            $cmd = Get-Command $name
            $def = $cmd.Definition
            if($cmd.CommandType -ne 'Alias'){
                Write-Host $def
            }else{
                Write-Host "(Alias) $def"
            }
        }
    }

    Remove-Item Alias:touch
    Function touch(){
        Param([string]$filename)

        Process {
            if(Test-Path $filename){
                Set-FileTime -Path $filename
            }else{
                New-Item $filename -itemType File
            }
        }
    }
}

Set-Alias -Name ngen -Value (Join-Path ([System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()) ngen.exe)
[AppDomain]::CurrentDomain.GetAssemblies() |
    where { ( $_.Location ) `
            -and -not $_.Location.Contains("blahblahblah") `
            -and -not $_.Location.Contains("PSReadLine.dll") `
            -and -not $_.Location.Contains("Pscx.Core.dll") `
            -and -not $_.Location.Contains("Pscx.dll") `
            -and -not $_.Location.Contains("SevenZipSharp.dll") `
            } |
    sort {Split-path $_.location -leaf} |
    % {
        $Name = (Split-Path $_.location -leaf)
        if ([System.Runtime.InteropServices.RuntimeEnvironment]::FromGlobalAccessCache($_))
        {
            #Write-Host "Already GACed: $Name"
        }
        else
        {
            Write-Host -ForegroundColor Yellow "NGENing      : $Name"
            ngen $_.location | %{"`t$_"}
        }
      }
