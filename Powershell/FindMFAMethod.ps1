$installedModules = Get-InstalledModule

if($installedModules.name -notcontains "msonline"){
    Start-Process Powershell -Verb runas -ArgumentList{ -command write-host "Installing Module msonline"; Install-Module MSOnline -Confirm:$false -AllowClobber -Force}
    $wait = $true
}Else{}

if ($wait -eq $true){
    write-host "Please wait until all modules have finished installing before continuing`n" -ForegroundColor Yellow
    Pause
}

Connect-msolservice

$users = get-msoluser -All:$true



$Table = $users | select userprincipalname,@{n="MFA_Method";e={$_.StrongAuthenticationMethods.methodtype}},@{n="Device_Name";e={$_.StrongAuthenticationPhoneAppDetails.DeviceName}}

$Table | Out-GridView 

pause

exit

[Microsoft.Online.Administration.Automation.ConnectMsolService]::ClearUserSessionState()