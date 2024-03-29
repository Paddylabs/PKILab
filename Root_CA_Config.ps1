﻿# Bypass Execution Policy
Set-ExecutionPolicy -ExecutionPolicy Bypass -Force

# Function: Wait for Services
function WaitUntilServices($searchString, $status)
{
    # Get all services where Name matches $searchString and loop through each of them.
    foreach($service in (Get-Service -Name $searchString))
    {
        # Wait for the service to reach the $status or a maximum of 60 seconds
        $service.WaitForStatus($status, '00:01:00')
    }
}

# Removes all default CRL Distribution Points and deletes them.
Write-Host "Removing all default CDPs" -ForegroundColor Green
$crllist = Get-CACrlDistributionPoint; foreach ($crl in $crllist) {Remove-CACrlDistributionPoint $crl.uri -Force};

# Adding back the Windows system required CDP with better name
Write-Host "Adding required Windws system CDP with name of Root CA" -ForegroundColor Green
Add-CACRLDistributionPoint -Uri C:\Windows\System32\CertSrv\CertEnroll\TESTLAB-ROOT%8%9.crl -PublishToServer -PublishDeltaToServer -Force

# Adding the URL of the CRL that will be on all issued certificates.  This needs to be a highly-available publicly accessible URL.  Typing in this URL should prompt your internet browser to download the .crl.
Write-Host "dding the URL of the CRL that will be on all issued certificates" -ForegroundColor Green
Add-CACRLDistributionPoint -Uri http://pki.testlab.net/pki/TESTLAB-ROOT%8%9.crl -AddToCertificateCDP -AddToFreshestCrl -Force

#  Gets all of the AIA paths (but not the default Windows system path) and deletes them.  They are also no good.
Write-Host "Deleting all the AIA paths except the default Windows system path." -ForegroundColor Green
Get-CAAuthorityInformationAccess | where {$_.Uri -like '*ldap*' -or $_.Uri -like '*http*' -or $_.Uri -like '*file*'} | Remove-CAAuthorityInformationAccess -Force

# Adding the URL of the AIA file that is on all issued certificates.  This also needs to be a highly-available publicly accessible URL.
Write-Host "Adding the URL of the AIA file that is on all issued certificates." -ForegroundColor Green
Add-CAAuthorityInformationAccess -AddToCertificateAia http://pki.testlab.net/pki/TESTLAB-ROOT%3%4.crt -Force

# Set additional Settings. These are settings that effect Certificates issued by this CA.

Write-Host "Setting additional CA Settings" -ForegroundColor Green

certutil.exe –setreg CA\ValidityPeriodUnits 10
certutil.exe –setreg CA\ValidityPeriod “Years”

certutil.exe –setreg CA\CRLPeriodUnits 26
certutil.exe –setreg CA\CRLPeriod “Weeks”
certutil.exe –setreg CA\CRLOverlapPeriodUnits 24
certutil.exe –setreg CA\CRLOverlapPeriod “Hours”
certutil.exe -setreg CA\AuditFilter 127

# Restart Certificate Services Service
Write-Host "Restarting Certificate Services Service" -ForegroundColor Green
Restart-Service certsvc

# Waiting for Certificate Service to restart
Write-Host "Waiting for Certificate Service to restart." -ForegroundColor Green
WaitUntilServices "certsvc" "Running"
sleep -Seconds 30

# Publishing new CRLs now that the above settings have been made
Write-Host "Publishing new CRLs with the settings we have made."
CertUtil -crl