$ngenCmd = Join-Path ([System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()) ngen.exe
if (-Not (Test-Path -Path $ngenCmd)) { return; }

[AppDomain]::CurrentDomain.GetAssemblies() |
    ? { $_.Location -ne $null } |
    % { if(-Not ([System.Runtime.InteropServices.RuntimeEnvironment]::FromGlobalAccessCache($_))) {
        Write-Host -ForegroundColor Yellow "NGENing : $(Split-Path -Path $_.Location -Leaf)"
        iex "$ngenCmd install $($_.Location) /silent" | %{ "`t$_" }
        }}
