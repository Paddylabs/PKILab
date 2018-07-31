# Bypassing Execution Policy
Set-ExecutionPolicy -ExecutionPolicy Bypass -Force

# Importing Web Administration Module
Write-Host "Importing Web Admin PS Module" -ForegroundColor Green
Import-Module WebAdministration

#Create Virtual Directory under Default Website
Write-Host "Creating virtual directory under the default website for the C:\PKI folder" -ForegroundColor Green
$SiteName = "Default Web Site"
$VirtualDirectoryName = "PKI"
$PhysicalPath = "C:\PKI"
New-WebVirtualDirectory -Site $SiteName -Name $VirtualDirectoryName -PhysicalPath $PhysicalPath

# Enable Directory Browsing
Write-Host "Enabling Directory Browsing" -ForegroundColor Green
$folder = New-Object System.DirectoryServices.DirectoryEntry("IIS://localHost/w3svc/1/root/pki")
$folder.Put("AccessRead",$True)
$folder.Put("EnableDirBrowsing",$True)
$folder.psbase.commitchanges()

# Enable double escaping (as Delta CRLs end with a + )
Write-Host "Enabling Double Escaping as delta CRLs end with a +" -ForegroundColor Green
C:\windows\System32\inetsrv\appcmd.exe set config /section:requestfiltering /allowdoubleescaping:true 
