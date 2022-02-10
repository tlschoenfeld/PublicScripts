$installedModules = Get-InstalledModule

if($installedModules.name -notcontains "msonline"){
    Start-Process Powershell -Verb runas -ArgumentList{ -command write-host "Installing Module msonline"; Install-Module MSOnline -Confirm:$false -AllowClobber -Force}
    $wait = $true
}Else{}
if($installedModules.name -notcontains "Exchangeonlinemanagement"){
    Start-Process Powershell -Verb runas -ArgumentList{ -command write-host "Installing Module ExchangeOnlineManagement"; Install-Module ExchangeOnlineManagement -Confirm:$false -AllowClobber -Force}
    $wait = $true
}Else{}


if ($wait -eq $true){
    write-host "Please wait until all modules have finished installing before continuing`n" -ForegroundColor Yellow
    Pause
}

    DO{
    $sessions = get-pssession
        if ($sessions.ConfigurationName -notcontains "Microsoft.Exchange"){
            connect-exchangeonline
        }else{}
    $MsolCheck = Get-MsolAccountSku
        if ($MsolCheck -eq $null){
            connect-msolservice
        }else{}
        DO{
        $message = "Currently Connected to " + (Get-MsolCompanyInformation).DisplayName
        write-host  "Type reconnect to change environments or exit to close" -ForegroundColor Yellow
        ""
        ""
        write-host $message -ForegroundColor Green
        ""
        $UPN = Read-Host "What is the users UPN"
            if ($UPN -eq "exit"){
                get-pssession | remove-pssession
                Exit
            }
            Elseif ($UPN -eq "reconnect"){
                get-pssession | remove-pssession
            }
            $mailboxCheck = Get-EXOMailbox $UPN -ErrorAction SilentlyContinue 
                if ($mailboxCheck){$continue = $true}Else{$continue = $false}
                }While($continue -eq $false)

        $mailboxInfo = Get-EXOMailbox $upn | Select UserPrincipalName,EmailAddresses
        $MSOLUserinfo = get-msoluser -SearchString $upn | Select FirstName,LastName,DisplayName,IsLicensed,Licenses,LastDirSyncTime
        $mailboxstats = Get-EXOMailboxStatistics -Identity $UPN -PropertySets All | Select TotalItemSize,ItemCount,@{n="LastUserActionTime";e={get-date $_.lastuseractiontime}}
        $InboxRules = Get-InboxRule -mailbox $upn | Select Name,Description,Enabled
        $InboxPermissions = Get-EXOMailboxFolderPermission ${upn}:\inbox | Select User,AccessRights
        $CalendarPermissions = Get-EXOMailboxFolderPermission ${upn}:\Calendar | Select User,AccessRights
        $members = get-group | ? {$_.members -contains $upn} | Select Name,GroupType
        $owners = get-group | ? {$_.owners -contains $upn} | Select Name,GroupType
        $PSObject = new-object -TypeName psobject
            Add-Member -InputObject $PSObject -MemberType NoteProperty -Name FirstName -value $msoluserinfo.FirstName
            Add-Member -InputObject $PSObject -MemberType NoteProperty -Name LastName -value $msoluserinfo.LastName
            Add-Member -InputObject $PSObject -MemberType NoteProperty -Name DisplayName -value $msoluserinfo.DisplayName
            Add-Member -InputObject $PSObject -MemberType NoteProperty -Name UPN -value $mailboxInfo.UserPrincipalName
            Add-Member -InputObject $PSObject -MemberType NoteProperty -Name LastDirSyncTime -value $MSOLUserinfo.LastDirSyncTime
            Add-Member -InputObject $PSObject -MemberType NoteProperty -Name EmailAddresses -value $mailboxInfo.EmailAddresses
            Add-Member -InputObject $PSObject -MemberType NoteProperty -Name IsLicensed -value $MSOLUserinfo.IsLicensed
            Add-Member -InputObject $PSObject -MemberType NoteProperty -Name Licenses -value $MSOLUserinfo.Licenses.accountskuid
            Add-Member -InputObject $PSObject -MemberType NoteProperty -Name MailboxStatistics -value $mailboxstats -force
            Add-Member -InputObject $PSObject -MemberType NoteProperty -Name InboxRules -value $InboxRules
            Add-Member -InputObject $PSObject -MemberType NoteProperty -Name InboxPermissions -value $InboxPermissions
            Add-Member -InputObject $PSObject -MemberType NoteProperty -Name CalendarPermissions -value $CalendarPermissions
            Add-Member -InputObject $PSObject -MemberType NoteProperty -Name GroupMembership -value $members
            Add-Member -InputObject $PSObject -MemberType NoteProperty -Name GroupOwnership -value $owners
        $PSObject | Convertto-json
        
        start-sleep 4
        pause
        
    }while ($UPN -ne "Exit")

get-pssession | Remove-PSSession

[Microsoft.Online.Administration.Automation.ConnectMsolService]::ClearUserSessionState()