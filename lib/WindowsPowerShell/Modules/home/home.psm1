# ユーザースコープの環境変数があれば削除する。
Function Set-NullEnv {
    Param ( $Name )
    Process {
        if ([Environment]::GetEnvironmentVariable($name) -ne $null) {
            [Environment]::SetEnvironmentVariable($name, $null, "User")
        }
    }
}

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
Function env(){
    Process {Get-ChildItem ENV:}
}

# コマンドの実体パスまたはエイリアス先を表示する。
function which() {
    param([string]$private:name)
    $private:cmd = $(Get-Command $name)
    if ($cmd.CommandType -eq 'Alias') {
        return "(Alias) $($cmd.Definition)"
    } else {
        return "$($cmd.Definition)"
    }
}

Remove-Item Alias:touch -ErrorAction SilentlyContinue
# ファイル作成または更新日時の変更を行う。
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


