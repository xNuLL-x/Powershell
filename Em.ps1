$ScriptBlock='cmd.exe /C calc'
$Bytes=[System.Text.Encoding]::Unicode.GetBytes($ScriptBlock)
$Encoded=[Convert]::ToBase64String($Bytes)
Write-Host "Your encoded payload: $Encoded"