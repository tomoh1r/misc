Function Set-NullEnv {
    Param ( $Name )
    Process {
        if ([Environment]::GetEnvironmentVariable($name) -ne $null) {
            [Environment]::SetEnvironmentVariable($name, $null, "User")
        }
    }
}

Function Test-ExistsParentPath(){
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
            Test-ExistsParentPath $_parent $dir_name
        }
    }
}

Function Get-GitBranch(){
    Process
    {
        if(-not (Test-ExistsParentPath $PWD.Path '.git')){
            return
        }

        git branch 2>$null |
            ?{-not [System.String]::IsNullOrEmpty($_.Split()[0])} |
            %{$bn = $_.Split()[1]
                Write-Output "(git:$bn) " }
    }
}

Function Get-HgBranch(){
    Process
    {
        if(-not (Test-ExistsParentPath $PWD.Path '.hg')){
            return
        }

        hg branch 2>$null | %{Write-Output "(hg:$_) "}
    }
}

# return current directory
# with $ENV:HOME to ~
Function Get-Pwd(){
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

Function Set-LocationExHome() {
    Param(
        [Parameter(Mandatory = $false, Position = 0)]
        [string]$Path
        )

    Process {
        if([string]::IsNullOrEmpty("$Path")){
            Set-Location -Path $HOME
        }else{
            Set-Location -Path $Path
        }
    }
}

Function env(){
    Process {Get-ChildItem ENV:}
}

function which() {
    param([string]$private:name)
    $private:cmd = $(Get-Command $name)
    $private:prefix = $($cmd.CommandType -eq 'Alias' ? "(Alias) " : "")
    return "${prefix}$($cmd.Definition)"
}

Remove-Item Alias:touch -ErrorAction SilentlyContinue
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

Export-ModuleMember -Function *
