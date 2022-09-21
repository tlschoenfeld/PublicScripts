
$array = @()

do{
    $object = New-Object -TypeName psobject
    cls
    write-host $array.count "canidates in the running`n" -ForegroundColor Green
    write-host "Leave blank to break a tie between prior entered canidates`n" -ForegroundColor yellow
    $option = read-host "Enter in a canidate for running"
    if ($option -ne ""){
        Add-Member -InputObject $object -MemberType NoteProperty -Name Name -Value $option
        $array += $object
    }Else {}
}while ($option -ne "")


$random = 1..($array.count * 1000) |  foreach {Get-Random $array}


foreach ($canidate in $array){
    
    add-member -InputObject $canidate -MemberType NoteProperty -Name votes -Value ($random | ? {$_ -eq $canidate}).count
    }

cls
$winner = $array | Sort votes -Descending | select -First 1

write-host "Winner is "$winner.name "!"
write-host ""
write-host ""
$array | Sort-Object votes -Descending | Out-GridView
write-host ""
write-host ""


pause