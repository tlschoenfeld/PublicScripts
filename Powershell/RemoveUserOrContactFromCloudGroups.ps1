$installedModules = Get-InstalledModule

if($installedModules.name -notcontains "msonline"){
    Start-Process Powershell -Verb runas -ArgumentList{ -command write-host "Installing Module msonline"; Install-Module MSOnline -Confirm:$false -AllowClobber -Force}
    $wait = $true
}Else{}

if ($wait -eq $true){
    write-host "Please wait until all modules have finished installing before continuing`n" -ForegroundColor Yellow
    Pause
}


DO{
    cls

    if($continue -eq $False){"Error $RemovingUserEmail not found"}Else{}
    $RemovingUserEmail = read-host "What is the email address of the user you are removing from all groups"


        if ((get-msoldomain).name -contains $domain){
            $info = get-msoluser -SearchString $RemovingUserEmail

        }
        Else{
            $info = Get-MsolContact -SearchString $RemovingUserEmail

        }

    if($info){$continue = $true}Else{$continue = $false}

}while ($continue -eq $false)

write-host "Please Wait.....`n`nRunning through all groups to find $RemovingUserEmail" -ForegroundColor Yellow


$GroupMembership = get-msolgroup | ? {(Get-msolgroupmember -GroupObjectId $_.ObjectId).emailaddress -contains $RemovingUserEmail}
cls
$GroupMembership | Select DisplayName,GroupType | FT

start-sleep 1

$confirm = read-host "Are you sure you want to remove $userinfo from the above groups (y/n)"

if ($confirm -eq "y"){

    foreach($group in $GroupMembership){
    Remove-MsolGroupMember -GroupObjectId $group.ObjectId -GroupMemberObjectId $USER.ObjectId
    pause

    }
}
Else{
    "No Actions Taken"
    pause
}

[Microsoft.Online.Administration.Automation.ConnectMsolService]::ClearUserSessionState()
Get-PSSession | Remove-PSSession