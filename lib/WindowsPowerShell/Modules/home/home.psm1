Function Set-Null-Env {
    Param ( $Name )
    Process {
        if ([Environment]::GetEnvironmentVariable($name) -ne $null) {
            [Environment]::SetEnvironmentVariable($name, $null, "User")
        }
    }
}

Function Get-Reverse-Check(){
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
            Get-Reverse-Check $_parent $dir_name
        }
    }
}

Function Get-Git-Branch(){
    Process
    {
        if(-not (Get-Reverse-Check $PWD.Path '.git')){
            return
        }

        git branch 2>$null |
            ?{-not [System.String]::IsNullOrEmpty($_.Split()[0])} |
            %{$bn = $_.Split()[1]
                Write-Output "(git:$bn) " }
    }
}

Function Get-Hg-Branch(){
    Process
    {
        if(-not (Get-Reverse-Check $PWD.Path '.hg')){
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

Remove-Item Alias:cd -ErrorAction SilentlyContinue
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
