$installedModules = Get-InstalledModule
if($installedModules.name -notcontains "ExchangeOnlineManagement"){
    Start-Process Powershell -Verb runas -ArgumentList{ -command write-host "Installing Module ExchangeOnlineManagement"; Install-Module ExchangeOnlineManagement -Confirm:$false -AllowClobber -Force}
    $wait = $true
}Else{}

if ($wait -eq $true){
    write-host "Please wait until all modules have finished installing before continuing`n" -ForegroundColor Yellow
    Pause
}

connect-msolservice


$array = @()
$licenses = Get-MsolAccountSku
$users = get-msoluser | Where {$_.islicensed -eq $true}
foreach ($user in $users){
    $object = New-Object -TypeName psobject
        Add-Member -InputObject $object -MemberType NoteProperty -Name UPN -Value $user.UserPrincipalName
        foreach($license in $licenses){
        if ($user.Licenses.accountskuid -contains $license.AccountSkuId){
            Add-Member -InputObject $object -MemberType NoteProperty -Name $license.SkuPartNumber -Value $true
            }Else{
            Add-Member -InputObject $object -MemberType NoteProperty -Name $license.SkuPartNumber -Value $false
            }
        }
   $array += $object
}

$object = New-Object -TypeName psobject
 Add-Member -InputObject $object -MemberType NoteProperty -Name UPN -Value "Total"
foreach ($license in $licenses)
    {
    Add-Member -InputObject $object -MemberType NoteProperty -Name $license.SkuPartNumber -Value $license.ConsumedUnits
    }
$array += $object

$filename = "C:\temp\" + (Get-MsolDomain | ? {$_.isdefault -eq $true}).name.replace(".","-") + "_LicenseAudit_" + (get-date -format "MM-dd-yyyy") + ".csv"
mkdir temp -ErrorAction SilentlyContinue
$array | export-csv $filename -nti
write-host "File Saved $filename"
start C:\temp