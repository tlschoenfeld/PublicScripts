Connect-MsolService

write-host "Enabling Modern Authenticaion for client connections" -ForegroundColor Yellow
Set-OrganizationConfig -OAuth2ClientProfileEnabled $true
start-sleep 20

$csvpath = read-host "Please drag and drop the CSV into the Powershell window" 

Import-Csv -Path ($csvpath.Replace('"',''))

$successcount = 0
$failedCount = 0
$failedUsers = @()



foreach ($object in $csv){

$UserMFAVerification  = get-msoluser -UserPrincipalName $object.UserPrincpalName

    if ($UserMFAVerification.StrongAuthenticationRequirement -eq ""){


        $mf= New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement
        $mf.RelyingParty = "*"
        $mfa = @($mf)

        Set-MsolUser -UserPrincipalName $object.UserPrincpalName -StrongAuthenticationRequirements $mfa   

        if ((Get-Msoluser -UserPrincipalName $object.UserPrincpalName).state -eq "Enabled"){
            Write-Host $object.UserprincipalName -ForegroundColor Green
            $successcount ++
        }Else{
            Write-Host $object.UserPrincipalName -ForegroundColor Red
            $failedCount ++
            $faileduser += $object.userprincipalname
        }

    }Else{}

    $failedUser | Out-GridView
}