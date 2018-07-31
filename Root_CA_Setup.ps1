﻿# Creates an Offline Root CA, run this AFTER installing the role and making sure the CAPolicy.inf is correct but BEFORE Root_CA_Config.ps1
Install-AdcsCertificationAuthority -CAType StandaloneRootCA -CACommonName "Paddylab Root Certificate Authority" -KeyLength 4096 -HashAlgorithm SHA256 -CryptoProviderName "RSA#Microsoft Software Key Storage Provider" -ValidityPeriod Years -ValidityPeriodUnits 10 -Force