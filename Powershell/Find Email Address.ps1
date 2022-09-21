#Install Module Check
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


DO{
    
    $company = (Get-OrganizationConfig).displayname
    #Sign into exchange
    cls
    write-host "Currently connected to:        $($company)`n`nType Exit to Close`n`n" -ForegroundColor yellow

    $user = read-host "What is the email address you are trying to find`n"
    if($user -ne "exit"){
        get-recipient $user | select Name,recipienttypedetails,PrimarySmtpAddress,EmailAddresses | FL
        pause
    }Else{}
}While($user -ne "Exit")
Get-PSSession | Remove-PSSession
exit