# -- vars --

$script:IsWindows = $null
if ($IsWindows -eq $null)
{
    $script:IsWindows = $false
    if ($PSVersionTable.Platform -eq "Win32NT")
    {
        $script:IsWindows = $true
    }
    elseif ($Env:OS -eq "Windows_NT")
    {
        $script:IsWindows = $true
    }
}

$script:pathsep = ":"
if ($IsWindows) { $script:pathsep = ";"; }
$script:dirsep = [IO.Path]::DirectorySeparatorChar

function Test-Windows { return $IsWindows; }
function Get-PathSep { return $pathsep; }
function Get-DirSep { return $dirsep; }

# -- Env or Env:PATH --

# ユーザースコープの環境変数があれば削除する。
Function Set-NullEnv {
    Param ( $Name )
    Process {
        if ([Environment]::GetEnvironmentVariable($name) -ne $null) {
            [Environment]::SetEnvironmentVariable($name, $null, "User")
        }
    }
}

function Get-ShortPath
{
    param([string]$name)
    begin {
        $private:fso = New-Object -ComObject Scripting.FileSystemObject
        $private:dirsep = Get-DirSep
    }
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

            $private:joined = Join-Path $result $path
            try {
                $private:fsi = Get-Item $joined -ErrorAction Stop
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

function Resolve-HomePath
{
    param ([string]$path)
    process
    {
        # 末尾 ; とかで空白文字列が渡ってきた場合返す
        if([System.String]::IsNullOrEmpty($path.Trim())) {
          return $path
        }

        $splitted = ($path.Trim()) -replace '^~', $HOME
        return Split-Path -Path (Join-Path -Path $splitted -Child dmy) -Parent
    }
}

function Join-EnvPath
{
    param ([string]$first, [string]$second)
    begin { $private:pathsep = Get-PathSep }
    process
    {
        if ($first -ne "" -and $second -ne "") {
            $private:result = "$($first)${pathsep}$($second)"
        } elseif ($first -ne "") {
            $private:result = $first
        } elseif ($second -ne "") {
            $private:result = $second
        }
        return (Remove-EnvPathDuplicates $result)
    }
}

function Push-EnvPath
{
    param([Array]$Paths)
    begin { $private:pathsep = Get-PathSep }
    process
    {
        $private:dstPath = [System.Collections.ArrayList]::new()
        $paths -split $pathsep | `
            % { Resolve-HomePath $_ } | `
            ? { -not $Env:PATH.Contains($settled) } | `
            % { [void]$dstPath.Add($(Get-ShortPath $_)) }
        $Env:PATH -split $pathsep | ` 
            % { Resolve-HomePath $_ } | `
            % { [void]$dstPath.Add($(Get-ShortPath $_)) }
        $Env:Path = Remove-EnvPathDuplicates ($dstPath.ToArray() -join $pathsep)
    }
}

function Remove-EnvPathDuplicates
{
    param([string]$value = $Env:PATH)
    begin { $private:pathsep = Get-PathSep }
    process
    {
        $private:dstPath = [System.Collections.ArrayList]::new()
        $private:seen = @{}
        foreach ($raw in ($value -split $pathsep))
        {
            $settled = Resolve-HomePath $raw
            if ([System.String]::IsNullOrEmpty($settled)) { continue }
            $short = Get-ShortPath $settled
            $keyLong = $settled.ToLowerInvariant()
            $keyShort = $short.ToLowerInvariant()
            if ($seen.ContainsKey($keyLong) -or $seen.ContainsKey($keyShort)) { continue }
            $seen[$keyLong] = $true
            $seen[$keyShort] = $true
            [void]$dstPath.Add($raw.Trim())
        }
        return $dstPath.ToArray() -join $pathsep
    }
}

# -- misc --

# 指定パスから親を辿り、対象ディレクトリの有無を確認する。
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

# Git リポジトリ内なら現在のブランチ名を返す。
Function Get-GitBranch(){
    Process
    {
        if(-not (Test-ExistsParentPath $PWD.Path '.git')){
            return
        }

        git branch 2>$null |
            ? {-not [System.String]::IsNullOrEmpty($_.Split()[0])} |
            % {$bn = $_.Split()[1]
                Write-Output "(git:$bn) " }
    }
}

# Mercurial リポジトリ内なら現在のブランチ名を返す。
Function Get-HgBranch(){
    Process
    {
        if(-not (Test-ExistsParentPath $PWD.Path '.hg')){
            return
        }

        hg branch 2>$null | %{Write-Output "(hg:$_) "}
    }
}

# 現在のディレクトリを返し、HOME 配下は ~ に短縮する。
Function Get-Pwd(){
    $path = $(Get-Location).Path
    if($path.IndexOf($ENV:HOME) -eq 0){
        $path = Join-Path '~' ($PWD.ProviderPath.Remove(0, ($ENV:HOME).Length))
    }
    return $path
}

# コマンド一覧をソース/種別/名前で整列して返す。
Function Get-SortedCommand() {
    Process
    {
        Return Get-Command | sort { $_.Source, $_.CommandType, $_.Name} | select Source, Name, CommandType, Version
    }
}

# 引数なしなら HOME へ移動する cd の拡張。
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

# 環境変数一覧を表示する簡易ラッパー。
Function Get-ChildItemEnv(){ Get-ChildItem ENV: }

# コマンドの実体パスまたはエイリアス先を表示する。
function Get-CommandPath() {
    param([string]$private:name)
    $private:cmd = $(Get-Command $name)
    if ($cmd.CommandType -eq 'Alias') {
        return "(Alias) $($cmd.Definition)"
    } else {
        return "$($cmd.Definition)"
    }
}

# ファイル作成または更新日時の変更を行う。
Function New-SimpleItem(){
    Param([string]$filename)

    Process {
        if(Test-Path $filename){
            Set-FileTime -Path $filename
        }else{
            New-Item $filename -itemType File
        }
    }
}
