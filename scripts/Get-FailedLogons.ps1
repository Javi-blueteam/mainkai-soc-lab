param([int]$Hours = 24)
$start = (Get-Date).AddHours(-$Hours)
$fails = Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4625; StartTime=$start} |
  ForEach-Object {
    [PSCustomObject]@{
      Time      = $_.TimeCreated
      User      = $_.Properties[5].Value
      LogonType = $_.Properties[10].Value
      SourceIP  = $_.Properties[19].Value
    }
  }
$fails | Format-Table
$fails | Group-Object User | Sort-Object Count -Descending | Select-Object Count, Name
$fails | Export-Csv C:\lab\failed-logons.csv -NoTypeInformation