﻿# Creates an Enterprise SubCA, run this AFTER installing the role and making sure the CAPolicy.inf is correct but BEFORE Sub_CA_Config.ps1
Install-AdcsCertificationAuthority -CAType EnterpriseSubordinateCA -CACommonName "Paddylab Enterprise Certificate Authority" -KeyLength 4096 -HashAlgorithm SHA256 -CryptoProviderName "RSA#Microsoft Software Key Storage Provider" -Force