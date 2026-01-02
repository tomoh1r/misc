# -- vars --

# Windows 判定結果のキャッシュ（モジュール内共有）。
$script:IsWindows = $null
if ($IsWindows -eq $null)
{
    # プラットフォーム情報から Windows か判定する。
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

# OS 依存の PATH 区切り文字。
$script:pathsep = ":"
if ($IsWindows) { $script:pathsep = ";"; }
# OS 依存のディレクトリ区切り文字。
$script:dirsep = [IO.Path]::DirectorySeparatorChar

# 実行ファイル拡張子の OS 依存サフィックス。
$script:binSuffix = ""
if ($IsWindows) { $script:binSuffix = ".exe"; }

# Windows 判定を返す。
function Test-Windows {
    # 初期化済みの判定結果を返す。
    return $IsWindows
}
# パス区切り文字を返す。
function Get-PathSep {
    # 環境に応じた区切り文字を返す。
    return $pathsep
}
# ディレクトリ区切り文字を返す。
function Get-DirSep {
    # 環境に応じた区切り文字を返す。
    return $dirsep
}

# 実行ファイルの拡張子サフィックスを返す。
function Get-BinSuffix {
    return $binSuffix
}

# -- Env or Env:PATH --

# ユーザースコープの環境変数があれば削除する。
Function Set-NullEnv {
    Param ( $Name )
    Process {
        # 既に設定されている場合のみ削除する。
        if ([Environment]::GetEnvironmentVariable($name) -ne $null) {
            [Environment]::SetEnvironmentVariable($name, $null, "User")
        }
    }
}

# 8.3 形式取得のため COM を使用する。
# FileSystemObject のインスタンスをキャッシュする。
$script:fso = $null

# パス文字列を短縮パスに変換する。
function Get-ShortPath
{
    param([string]$name)
    process
    {
        # COM オブジェクトは初回のみ生成して使い回す。
        if ($script:fso -eq $null) {
            $script:fso = New-Object -ComObject Scripting.FileSystemObject
        }
        # 逐次的に短縮パスを組み立てるための作業変数。
        $private:result = $null
        # 区切りごとに存在確認しながら短縮化する。
        foreach ($path in $name.Split($dirsep))
        {
            if ($result -eq $null)
            {
                $private:result = $path
                continue
            }

            $private:joined = Join-Path $result $path
            try {
                # 存在しないパスはそのまま連結だけ行う。
                $private:fsi = Get-Item $joined -ErrorAction Stop
            }
            catch
            {
                $private:result = $joined
                continue
            }

            # ファイル/ディレクトリに応じて短縮パスを取得する。
            if ($fsi.FullName -match "NeoVim")
            {
                # NeoVim は 8.3形式のパスに対応していない
                $private:result = $fsi.FullName
            }
            elseif ($fsi.psiscontainer)
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

# ~ を含むパスを展開して正規化する。
function Resolve-HomePath
{
    param ([string]$path)
    process
    {
        # 末尾 ; とかで空白文字列が渡ってきた場合返す
        if([System.String]::IsNullOrEmpty($path.Trim())) {
          return $path
        }

        # 先頭の ~ を HOME に置換する。
        $splitted = ($path.Trim()) -replace '^~', $HOME
        # 余計な末尾を付けて Join-Path で正規化する。
        return Split-Path -Path (Join-Path -Path $splitted -Child dmy) -Parent
    }
}

# 2つの PATH 断片を結合し重複を除去する。
function Join-EnvPath
{
    param ([string]$first, [string]$second)
    process
    {
        # どちらかが空の場合は片方だけを採用する。
        if ($first -ne "" -and $second -ne "") {
            $private:result = "$($first)${pathsep}$($second)"
        } elseif ($first -ne "") {
            $private:result = $first
        } elseif ($second -ne "") {
            $private:result = $second
        }
        # 結合後に重複を除去して返す。
        return (Remove-EnvPathDuplicates $result)
    }
}

# PATH 先頭に指定パス群を追加する。
function Push-EnvPath
{
    param([Array]$Paths)
    process
    {
        # 先頭追加分 + 既存分の順序を維持する入れ物。
        $private:dstPath = [System.Collections.ArrayList]::new()
        # 追加分を先頭に解決・短縮して並べる。
        $paths -split $pathsep | `
            % { Resolve-HomePath $_ } | `
            ? { -not $Env:PATH.Contains($settled) } | `
            % { [void]$dstPath.Add($(Get-ShortPath $_)) }
        # 既存 PATH を後ろに連結する。
        $Env:PATH -split $pathsep | ` 
            % { Resolve-HomePath $_ } | `
            % { [void]$dstPath.Add($(Get-ShortPath $_)) }
        # 重複除去後の PATH を反映する。
        $Env:Path = Remove-EnvPathDuplicates ($dstPath.ToArray() -join $pathsep)
    }
}

# PATH から重複する項目を除去する。
function Remove-EnvPathDuplicates
{
    param([string]$value = $Env:PATH)
    process
    {
        # PATH の出力順を保ったまま重複を排除する。
        $private:dstPath = [System.Collections.ArrayList]::new()
        # 長短パスの両方で重複管理するための集合。
        $private:seen = @{}
        # 長短パスの両方で重複チェックする。
        foreach ($raw in ($value -split $pathsep))
        {
            $settled = Resolve-HomePath $raw
            if ([System.String]::IsNullOrEmpty($settled)) { continue }
            # 短縮パスも算出して大小文字を無視した比較を行う。
            $short = Get-ShortPath $settled
            $keyLong = $settled.ToLowerInvariant()
            $keyShort = $short.ToLowerInvariant()
            if ($seen.ContainsKey($keyLong) -or $seen.ContainsKey($keyShort)) { continue }
            $seen[$keyLong] = $true
            $seen[$keyShort] = $true
            [void]$dstPath.Add($raw.Trim())
        }
        # 項目順は維持して結合する。
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
        # ルートまで遡って対象ディレクトリを探す。
        $_path = $(Convert-Path -Path $path)
        # 判定の打ち切りに使うルートパス。
        $_root = $(Join-Path (Split-Path -Path $_path -Qualifier) '\')
        if(Test-Path (Join-Path $_path $dir_name)){
            return $TRUE;
        }elseif($_root -eq $_path){
            # ルートまで到達して未検出なら false。
            return $FALSE;
        }else{
            # 親ディレクトリへ遡って再帰的に判定する。
            $_parent = Split-Path -Path $_path -Parent
            Test-ExistsParentPath $_parent $dir_name
        }
    }
}

# Git リポジトリ内なら現在のブランチ名を返す。
Function Get-GitBranch(){
    Process
    {
        # .git が見つからない場合は何もしない。
        if(-not (Test-ExistsParentPath $PWD.Path '.git')){
            return
        }

        # 現在ブランチに印を付けて出力する。
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
        # .hg が見つからない場合は何もしない。
        if(-not (Test-ExistsParentPath $PWD.Path '.hg')){
            return
        }

        # ブランチ名を整形して出力する。
        hg branch 2>$null | %{Write-Output "(hg:$_) "}
    }
}

# 現在のディレクトリを返し、HOME 配下は ~ に短縮する。
Function Get-Pwd(){
    # 現在パスを取得して HOME を ~ に置換する。
    $path = $(Get-Location).Path
    if($path.IndexOf($ENV:HOME) -eq 0){
        # HOME 配下のときだけ ~ へ短縮する。
        $path = Join-Path '~' ($PWD.ProviderPath.Remove(0, ($ENV:HOME).Length))
    }
    return $path
}

# コマンド一覧をソース/種別/名前で整列して返す。
Function Get-SortedCommand() {
    Process
    {
        # 見やすい順序でコマンド一覧を返す。
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
        # 引数が空なら HOME へ移動する。
        if([string]::IsNullOrEmpty("$Path")){
            Set-Location -Path $HOME
        }else{
            # 指定パスがあればそのまま移動する。
            Set-Location -Path $Path
        }
    }
}

# 環境変数一覧を表示する簡易ラッパー。
Function Get-ChildItemEnv(){
    # ENV ドライブの一覧を返す。
    Get-ChildItem ENV:
}

# コマンドの実体パスまたはエイリアス先を表示する。
function Get-CommandPath() {
    param([string]$private:name)
    # Get-Command の結果から実体またはエイリアス先を返す。
    $private:cmd = $(Get-Command $name)
    if ($cmd.CommandType -eq 'Alias') {
        # エイリアスなら定義先を表示する。
        return "(Alias) $($cmd.Definition)"
    } else {
        # コマンド実体のパスを返す。
        return "$($cmd.Definition)"
    }
}

# ファイル作成または更新日時の変更を行う。
Function New-SimpleItem(){
    Param([string]$filename)

    Process {
        # 既存ならタイムスタンプ更新、なければ新規作成する。
        if(Test-Path $filename){
            Set-FileTime -Path $filename
        }else{
            # 空ファイルとして作成する。
            New-Item $filename -itemType File
        }
    }
}
