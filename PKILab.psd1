@{
    AllNodes = @(
        @{
            NodeName                    = '*';
            InterfaceAlias              = 'Ethernet';
            DefaultGateway              = '10.0.0.254';
            PrefixLength                = 24;
            AddressFamily               = 'IPv4';
            DnsServerAddress            = '10.0.0.1';
            DomainName                  = 'corp.paddylab.net';
            PSDscAllowPlainTextPassword = $true;
            #CertificateFile            = "$env:AllUsersProfile\Lability\Certificates\LabClient.cer";
            #Thumbprint                 = 'AAC41ECDDB3B582B133527E4DE0D2F8FEB17AAB2';
            PSDscAllowDomainUser        = $true; # Removes 'It is not recommended to use domain credential for node X' messages
            Lability_SwitchName         = 'Corpnet';
            Lability_ProcessorCount     = 1;
            Lability_StartupMemory      = 2GB;
            Lability_Media              = '2016_x64_Standard_EN_Eval';
        }
        @{
            NodeName                = 'DC1';
            IPAddress               = '10.0.0.1';
            DnsServerAddress        = '127.0.0.1';
            Role                    = 'DC';
            Lability_ProcessorCount = 2;
        }
        
        @{
            NodeName  = 'ROOTCA01';
            IPAddress = '10.0.0.10';
            Role      = 'ROOTCA';
            Lability_Resource = 'Root_CAPolicy','Root_CASetup','Root_CAConfig'
            
        }

        @{
            NodeName  = 'SubCA01';
            IPAddress = '10.0.0.11';
            Role      = 'SubCA';
            Lability_Resource = 'Sub_CAPolicy','Sub_CASetup','Sub_CAConfig'

        }

#        @{
#            NodeName  = 'SubCA02';
#            IPAddress = '10.0.0.12';
#            Role      = 'SubCA';
#            Lability_Resource = 'Sub_CAPolicy','Sub_CASetup','Sub_CAConfig'
#
#        }


       @{
            NodeName  = 'WEB01';
            IPAddress = '10.0.0.13';
            Role      = 'WEB';
            Lability_Resource = 'PKI_IIS_Config'
        }
        
#        @{
#            NodeName       = 'CLIENT1';
#            Role           = 'CLIENT';
#            Lability_Media = 'WIN10_x64_Enterprise_EN_Eval';
#            Lability_Resource = 'RSAT_2016';
#            <# Lability_CustomBootStrap = 'Now implemented in the Media's CustomData.CustomBootstrap property #>
#        }
        
    );
    NonNodeData = @{
        OrganisationName = 'PKILab'
        Lability = @{
            EnvironmentPrefix = 'PKILab-';
            Media = @();
            Network = @(
                @{ Name = 'Corpnet'; Type = 'Internal'; }
                # @{ Name = 'Corpnet'; Type = 'External'; NetAdapterName = 'Ethernet'; AllowManagementOS = $true; }
                <#
                    IPAddress: The desired IP address.
                    InterfaceAlias: Alias of the network interface for which the IP address should be set. <- Use NetAdapterName
                    DefaultGateway: Specifies the IP address of the default gateway for the host. <- Not needed for internal switch
                    Subnet: Local subnet CIDR (used for cloud routing).
                    AddressFamily: IP address family: { IPv4 | IPv6 }
                #>
            );

           Resource = @(
                @{  
                    # Resource Identifier. If the resource is to be expanded (ISO or ZIP), it will be expanded into
                    # the \Resources\<Resource Id> folder on the target node.
                    Id = 'RSAT_2016';

                    # When the file is downloaded it will be placed into the Host resources folder with this filename
                    Filename = 'WindowsTH-RSAT_WS_1709-x64.msu';

                    # The source URI. Must be http, https or file URI.  If the path includes spaces they must be URL encoded.
                    # Uri = 'file://C:\Lability\Resources\WindowsTH-RSAT_WS_1709-x64.msu'

                    # If you want the module to check the downloaded file you can specify an MD5 Checksum.  Make sure this is
                    # correct or the module will continously try to download the file.
                    # Checksum = '';

                    # If the resource is a .zip or .iso file it can be expanded / decompressed when copied into the node's 
                    # \Resources\<Resource Id> folder. If no specified this value defaults to false.
                    # Expand = $True;

                    # The default Target path can be overridden by specifiying a destination path. This path is relative to
                    # the OS System drive.
                    # DestinationPath = '\Source'

                    }

                @{
                    Id = 'Root_CAPolicy'
                    Filename = 'CAPolicy.inf'
                    DestinationPath = '\Windows'
                    Uri = 'file://C:\Lability\Resources\PKI\RootCA\Root_CAPolicy.inf'

                    }

                @{
                    Id = 'Root_CASetup'
                    Filename = 'Root_CA_Setup.ps1'
                    Uri = 'file://C:\Lability\Resources\PKI\RootCA\Root_CA_Setup.ps1'

                    }

                 @{
                    Id = 'Root_CAConfig'
                    Filename = 'Root_CA_Config.ps1'
                    Uri = 'file://C:\Lability\Resources\PKI\RootCA\Root_CA_Config.ps1'

                    }

                @{
                    Id = 'Sub_CAPolicy'
                    Filename = 'Sub_CAPolicy.inf'
                    DestinationPath = '\Windows'
                    Uri = 'file://C:\Lability\Resources\PKI\SubCA\SubCA_CAPolicy.inf'

                    }

                @{
                    Id = 'Sub_CASetup'
                    Filename = 'Sub_CA_Setup.ps1'
                    Uri = 'file://C:\Lability\Resources\PKI\SubCA\Sub_CA_Setup.ps1'

                    }

                 @{
                    Id = 'Sub_CAConfig'
                    Filename = 'Sub_CA_Config.ps1'
                    Uri = 'file://C:\Lability\Resources\PKI\SubCA\Sub_CA_Config.ps1'

                    }

                
                @{
                    Id = 'PKI_IIS_Config'
                    Filename = 'PKI_IIS_Config.ps1'
                    Uri = 'file://C:\Lability\Resources\PKI\Web\PKI_IIS_Config.ps1'

                    }
                
            )

            <#
                If you are generating the .mof files on the host and/or you want Labilty to use the DSC
                resource versions/modules installed on the physical host, you should remove the 'DSCResource' key.
                Lability will then "just" copy all local DSC resources.
            #> 
            DSCResource = @(
                ## Download published version from the PowerShell Gallery
                @{ Name = 'xComputerManagement'; MinimumVersion = '1.9.0.0'; Provider = 'PSGallery'; }
                ## If not specified, the provider defaults to the PSGallery.
                @{ Name = 'xSmbShare'; MinimumVersion = '2.1.0.0'; }
                @{ Name = 'xNetworking'; MinimumVersion = '3.2.0.0'; }
                @{ Name = 'xActiveDirectory'; MinimumVersion = '2.16.0.0'; }
                @{ Name = 'xDnsServer'; MinimumVersion = '1.11.0.0'; }
                @{ Name = 'xDhcpServer'; MinimumVersion = '1.5.0.0'; }
                @{ Name = 'cNtfsAccessControl'; MinimumVersion = '1.3.1'; }
                ## The 'GitHub# provider can download modules directly from a GitHub repository, for example:
                ## @{ Name = 'Lability'; Provider = 'GitHub'; Owner = 'VirtualEngine'; Repository = 'Lability'; Branch = 'dev'; }
            );
        };
    };
};