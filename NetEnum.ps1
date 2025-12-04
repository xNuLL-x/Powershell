$N=Get-NetAdapterStatistics | Select-Object Name, ReceivedBytes, SentBytes
$N2=Get-NetTCPConnection | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State
$outputPATH=""
$Output=@"
Network Bandwidth:
$($N | Format-Table -AutoSize | Out-String)
Running Network Tasks:
$($N2 | Format-Table -AutoSize | Out-String)
"@
$Output | Out-File -FilePath $outputPATH