$installedModules = Get-InstalledModule
if($installedModules.name -notcontains "ExchangeOnlineManagement"){
    Start-Process Powershell -Verb runas -ArgumentList{ -command write-host "Installing Module ExchangeOnlineManagement"; Install-Module ExchangeOnlineManagement -Confirm:$false -AllowClobber -Force}
    $wait = $true
}Else{}

if ($wait -eq $true){
    write-host "Please wait until all modules have finished installing before continuing`n" -ForegroundColor Yellow
    Pause
}


Connect-ExchangeOnline

$SpamPolicies = Get-HostedContentFilterPolicy | ? {$_.isdefault -eq "$true"}

$ToBeBlocked = read-host "What is the email address that needs to be blocked"

$DefaultSpamPolicy = Get-HostedContentFilterPolicy -Identity $SpamPolicies.name

$currentlyBlocked = $DefaultSpamPolicy.blockedsenders.sender | select -ExpandProperty address

$UpdatedBlockList = $currentlyBlocked + $ToBeBlocked

Set-HostedContentFilterPolicy -Identity default -BlockedSenders $UpdatedBlockList

$NewBlockedList = (Get-HostedContentFilterPolicy -Identity $SpamPolicies.name).blockedsenders.sender | select -ExpandProperty address


if($NewBlockedList -contains $ToBeBlocked){
    "$ToBeBlocked has been added to the $SpamPolicies Policy"
}Else{
    "Something went wrong"
}


Pause

get-pssession | Remove-PSSession
Exit

[Microsoft.Online.Administration.Automation.ConnectMsolService]::ClearUserSessionState()