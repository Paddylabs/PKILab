# Stop the script if a fatal error occurs
$ErrorActionPreference = 'Stop'

Configuration BasicServerClient {
<#
    Requires the following custom DSC resources:
        xComputerManagement: https://github.com/PowerShell/xComputerManagement
        xNetworking:         https://github.com/PowerShell/xNetworking
        xActiveDirectory:    https://github.com/PowerShell/xActiveDirectory
        xSmbShare:           https://github.com/PowerShell/xSmbShare
        xDhcpServer:         https://github.com/PowerShell/xDhcpServer
        xDnsServer:          https://github.com/PowerShell/xDnsServer
#>
    param (
        [Parameter()] [ValidateNotNull()] [PSCredential] $Credential = (Get-Credential -Credential 'Administrator')
    )
    Import-DscResource -Module xComputerManagement, xNetworking, xActiveDirectory;
    Import-DscResource -Module xSmbShare, PSDesiredStateConfiguration;
    Import-DscResource -Module xDHCPServer, xDnsServer;
    Import-DscResource -Module cNTFSAccessControl;

    node $AllNodes.Where({$true}).NodeName {

        LocalConfigurationManager {

            RebootNodeIfNeeded   = $true;
            AllowModuleOverwrite = $true;
            ConfigurationMode    = 'ApplyOnly';
            # CertificateID        = $node.Thumbprint;
        }

        if (-not [System.String]::IsNullOrEmpty($node.IPAddress)) {

            xIPAddress 'PrimaryIPAddress' {

                IPAddress      = $node.IPAddress;
                InterfaceAlias = $node.InterfaceAlias;
                AddressFamily  = $node.AddressFamily;
            }

            if (-not [System.String]::IsNullOrEmpty($node.DefaultGateway)) {

                xDefaultGatewayAddress 'PrimaryDefaultGateway' {

                    InterfaceAlias = $node.InterfaceAlias;
                    Address        = $node.DefaultGateway;
                    AddressFamily  = $node.AddressFamily;
                }
            }

            if (-not [System.String]::IsNullOrEmpty($node.DnsServerAddress)) {

                xDnsServerAddress 'PrimaryDNSClient' {

                    Address        = $node.DnsServerAddress;
                    InterfaceAlias = $node.InterfaceAlias;
                    AddressFamily  = $node.AddressFamily;
                }
            }

            if (-not [System.String]::IsNullOrEmpty($node.DnsConnectionSuffix)) {

                xDnsConnectionSuffix 'PrimaryConnectionSuffix' {

                    InterfaceAlias           = $node.InterfaceAlias;
                    ConnectionSpecificSuffix = $node.DnsConnectionSuffix;
                }
            }

        } #end if IPAddress


    } #end nodes ALL

    node $AllNodes.Where({$_.Role -in 'DC'}).NodeName {

        ## Flip credential into username@domain.com
        $domainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ("$($Credential.UserName)@$($node.DomainName)", $Credential.Password);

        xComputer 'Hostname' {

            Name = $node.NodeName;
        }

        ## Hack to fix DependsOn with hypens "bug" :(
        foreach ($feature in @(
                'AD-Domain-Services',
                'GPMC',
                'RSAT-AD-Tools',
                'DHCP',
                'RSAT-DHCP'
            )) {
            WindowsFeature $feature.Replace('-','') {

                Ensure               = 'Present';
                Name                 = $feature;
                IncludeAllSubFeature = $true;
            }
        }

        xADDomain 'ADDomain' {

            DomainName                    = $node.DomainName;
            SafemodeAdministratorPassword = $Credential;
            DomainAdministratorCredential = $Credential;
            DependsOn                     = '[WindowsFeature]ADDomainServices';
        }

        # Convert the domain name to the distinguished name
        $DomainDN = ('DC=' + $($node.DomainName).Replace('.',',DC='))
        $BaseOU   = "OU=$($ConfigurationData.NonNodeData.OrganisationName),$($DomainDN)"

        # Create an OU called 'PKILAB'
        xADOrganizationalUnit 'OU_BaseOU' {
            Name = $ConfigurationData.NonNodeData.OrganisationName
            Path = $DomainDN

            }

        # Create a 'Lab Users' OU under the base OU
        xADOrganizationalUnit 'OU_LabUsers' {
            Name = 'Lab Users'
            Path = $BaseOU
        }

        # Create OUs for each Role under the base OU
        xADOrganizationalUnit 'OU_LabComputers' {
            Name = 'Lab Computers'
            Path = $BaseOU
        }

        xADOrganizationalUnit 'OU_PKI' {
            Name = 'PKI Servers'
            Path = $BaseOU
        }

        xDhcpServerAuthorization 'DhcpServerAuthorization' {

            Ensure    = 'Present';
            DependsOn = '[WindowsFeature]DHCP','[xADDomain]ADDomain';
        }

        xDhcpServerScope 'DhcpScope10_0_0_0' {

            Name          = 'Corpnet';
            IPStartRange  = '10.0.0.100';
            IPEndRange    = '10.0.0.200';
            SubnetMask    = '255.255.255.0';
            LeaseDuration = '00:08:00';
            State         = 'Active';
            AddressFamily = 'IPv4';
            DependsOn     = '[WindowsFeature]DHCP';
        }

        xDnsServerADZone 'PaddylabZone' {

            Name             = 'paddylab.net';
            ReplicationScope = 'Forest';
            Ensure           = 'Present';
            DependsOn        = '[xADDomain]ADDomain';


        }

        xDnsRecord 'PKI' {

            Name = 'PKI'
            Zone = 'paddylab.net'
            Type = 'CName'
            Target = 'web01.corp.paddylab.net'
            Ensure = 'present'
            DependsOn = '[xDnsServerADZone]PaddylabZone'

        }

        xDhcpServerOption 'DhcpScope10_0_0_0_Option' {

            ScopeID            = '10.0.0.0';
            DnsDomain          = 'corp.contoso.com';
            DnsServerIPAddress = '10.0.0.1';
            Router             = '10.0.0.2';
            AddressFamily      = 'IPv4';
            DependsOn          = '[xDhcpServerScope]DhcpScope10_0_0_0';
        }

        xADUser User1 {

            DomainName  = $node.DomainName;
            UserName    = 'User1';
            Description = 'PKI Test Lab user';
            Path        = "OU=Lab Users,$BaseOU"
            Password    = $Credential;
            Ensure      = 'Present';
            DependsOn   = '[xADDomain]ADDomain';
        }

        xADGroup DomainAdmins {

            GroupName        = 'Domain Admins';
            MembersToInclude = 'User1';
            DependsOn        = '[xADUser]User1';
        }

        xADGroup EnterpriseAdmins {

            GroupName        = 'Enterprise Admins';
            GroupScope       = 'Universal';
            MembersToInclude = 'User1';
            DependsOn        = '[xADUser]User1';
        }

    } #end nodes DC

    node $AllNodes.Where({$_.Role -in 'CLIENT','WEB','SubCA'}).NodeName {

        ## Flip credential into username@domain.com
        $upn = '{0}@{1}' -f $Credential.UserName, $node.DomainName;
        $domainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ($upn, $Credential.Password);

        xComputer 'DomainMembership' {

            Name       = $node.NodeName;
            DomainName = $node.DomainName;
            Credential = $domainCredential;
        }
    } #end nodes DomainJoined


    node $AllNodes.Where({$_.Role -in 'ROOTCA','SubCA'}).NodeName {

        foreach ($feature in @(
                'Adcs-cert-Authority',
                'RSAT-ADCS-Mgmt'
                )) {
            WindowsFeature $feature.Replace('-','') {

                Ensure               = 'Present';
                Name                 = $feature;
                IncludeAllSubFeature = $true;
            }


    } #end nodes ROOTCA



}

   node $AllNodes.Where({$_.Role -eq 'WEB'}).NodeName {

        foreach ($feature in @(
                'WEB-SERVER'
                )) {
            WindowsFeature $feature.Replace('-','') {

                Ensure               = 'Present';
                Name                 = $feature;
                IncludeAllSubFeature = $true;
            }

            File 'FilesFolder' {

            DestinationPath = 'C:\PKI';
            Type            = 'Directory';
        }

            xSmbShare 'FilesShare' {

            Name         = 'PKI';
            Path         = 'C:\PKI';
            ChangeAccess = 'CORP\User1',"corp\cert publishers";
            DependsOn    = '[File]FilesFolder';
            Ensure       = 'Present'
        }

        cNtfsPermissionEntry PermissionSet1 {

            Ensure = 'Present'
            Path = 'C:\PKI'
            Principal = "corp\cert publishers"
            AccessControlInformation = @(
                cNtfsAccessControlInformation
                {
                    AccessControlType = 'Allow'
                    FileSystemRights = 'Modify'
                    Inheritance = 'ThisFolderSubfoldersAndFiles'
                    NoPropagateInherit = $false
                }
            )
            DependsOn = '[File]FilesFolder'

            }

#            cNtfsPermissionEntry PermissionSet2 {

#            Ensure = 'Present'
#            Path = 'C:\PKI'
#            Principal = "corp\cert publishers"
#            AccessControlInformation = @(
#                cNtfsAccessControlInformation
#                {
#                    AccessControlType = 'Allow'
#                    FileSystemRights = 'Modify'
#                    Inheritance = 'ThisFolderSubfoldersAndFiles'
#                    NoPropagateInherit = $false
#                }
#            )
#            DependsOn = '[File]FilesFolder'
#
#            }


    } #end nodes WEB



}


} #end Configuration Example

# Use the psd1 in the same folder as this script
$ConfigData = "$(Split-Path $MyInvocation.MyCommand.Path)\PKILab.psd1"

# Create a new credential that we'll pass to BasicServerClient (Required when creating the domain & joining the domain) and to Start-LabConfiguration
$AdministratorCredential = [pscredential]::new('Administrator', ('Password1' | ConvertTo-SecureString -AsPlainText -Force))

# Generate the .MOF files that will be injected into our VMs and used to set them up
Write-Host 'Generating MOFs' -ForegroundColor Green
BasicServerClient -ConfigurationData $ConfigData -OutputPath 'C:\Lability\Configurations' -Credential $AdministratorCredential -Verbose

# Verify lab configuration & see what parts of it already exist (if any)
Write-Host 'Verifying lab configuration' -ForegroundColor Green
Test-LabConfiguration -ConfigurationData $ConfigData  -Verbose

# Create the lab from our config
Write-Host 'Creating lab' -ForegroundColor Green
Start-LabConfiguration -ConfigurationData $ConfigData -Verbose -IgnorePendingReboot -Credential $AdministratorCredential

# And once it's created, start the lab environment
Write-Host 'Starting PKI Test Lab' -ForegroundColor Green
Start-Lab -ConfigurationData $ConfigData -Verbose