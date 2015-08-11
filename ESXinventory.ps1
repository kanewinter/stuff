$head = @"
<style>
body { background-color:#dddddd;
       font-family:Tahoma;
       font-size:12pt; }
td, th { border:1px solid black;
         border-collapse:collapse; }
th { background-color: #39516B;
color: white;
font-size: x-small;
font-variant: small-caps;
font-family: arial;
text-align: center; }
table, tr, td, th { padding: 2px; margin: 0px }
table { margin-left:50px; }
</style>
"@

$body = Get-VMHost |
Sort-Object -Property Name |
Select * |
ConvertTo-Html -Fragment -PreContent "<h2>VMHosts</h2>" |
Out-String

$body += Get-VM |
Sort-Object -Property Name |
Select * |
ConvertTo-Html -Fragment -PreContent "<h2>VMs</h2>" | Out-String
ConvertTo-Html -Head $head -PostContent $body -Title "vCenter Inventory" - | Out-File "C:\report.html"
