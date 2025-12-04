$Target="Test-NetConnection -CommonTCPPort HTTP " <#Test connection ++ ASCII Encoding#>
$Bytes=[System.Text.Encoding]::ASCII.GetBytes($Target)
Write-Host "ASCII: $($Bytes -join ', ')"
$DecodeCommand=[System.Text.Encoding]::ASCII.GetString($Bytes)
Invoke-Expression $DecodeCommand