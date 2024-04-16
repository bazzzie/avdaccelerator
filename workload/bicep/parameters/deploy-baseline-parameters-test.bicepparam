using '../deploy-baseline.bicep'

param avdWorkloadSubsId = 'xxxxx-xx-xxxx-xxxx-xxxxxxx' // value needs to be provided
param deploymentEnvironment = 'Prod'
param deploymentPrefix = 'SJ'
param avdSessionHostLocation = 'swedencentral'
param avdManagementPlaneLocation = 'westeurope'

// ADDS 
param identityDomainName = 'company.local' // value needs to be provided when using ADDS or EntraDS as identity service provider
param avdIdentityServiceProvider = 'ADDS'
param avdDomainJoinUserName = 'admin@company.local'
param avdDomainJoinUserPassword = 'AHAHAAxxxxx'
param avdOuPath = 'OU=AVD,OU=Container,DC=company,DC=local'

// Local Admin ON VMs
param avdVmLocalUserName = 'avdadmin' // value needs to be provided
param avdVmLocalUserPassword = 'aUNXHSSSS' // value needs to be provided

//Intune Enrollment
param createIntuneEnrollment = false

// Security Group for FSLogix
param securityPrincipalId = 'xxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx' //objectID
param securityPrincipalName = 'sec-avd-users'

param avdDeployMonitoring = false
param avdEnterpriseAppObjectId = 'd3e0f160-5e91-406f-ba72-eb71f51aa430' // Value needs to be provided when enabling start VM on connect or scaling plans.

// Host Pool Settings 
param avdHostPoolType = 'Pooled'
param hostPoolPreferredAppGroupType = 'Desktop'
param avdPersonalAssignType = 'Automatic'
param avdHostPoolLoadBalancerType = 'BreadthFirst'
param hostPoolMaxSessions = 8
param avdStartVmOnConnect = true
param avdHostPoolRdpProperties = 'audiocapturemode:i:1;audiomode:i:0;drivestoredirect:s:;redirectclipboard:i:1;redirectcomports:i:1;redirectprinters:i:1;redirectsmartcards:i:1;screen mode id:i:2'
param avdDeployScalingPlan = true

// Networking
param createAvdVnet = false
param existingVnetAvdSubnetResourceId = '/subscriptions/327a389e-9f6e-4238-ad13-6a0c0cd94cb5/resourceGroups/rg-avd-hp1-p-network/providers/Microsoft.Network/virtualNetworks/vnet-avd-p-weu-01/subnets/snet-avd-hp1-p-weu-01'
param existingVnetPrivateEndpointSubnetResourceId = '/subscriptions/327a389e-9f6e-4238-ad13-6a0c0cd94cb5/resourceGroups/rg-avd-hp1-p-network/providers/Microsoft.Network/virtualNetworks/vnet-avd-p-weu-01/subnets/snet-avd-pe-p-weu-01'
param existingHubVnetResourceId = '/subscriptions/327a389e-9f6e-4238-ad13-6a0c0cd94cb5/resourcegroups/rg-networks-weu-01/providers/microsoft.network/virtualnetworks/lab-vnet'
param avdVnetworkAddressPrefixes = '10.10.0.0/23'
param vNetworkAvdSubnetAddressPrefix = '10.10.0.0/24'
param vNetworkPrivateEndpointSubnetAddressPrefix = '10.10.1.0/27'
param customDnsIps = '10.20.2.5' // value needs to be provided when creating new AVD vNet and using ADDS or EntraDS identity service providers
param createPrivateDnsZones = true
param avdVnetPrivateDnsZoneFilesId = '' // Not a mandatory parameter
param avdVnetPrivateDnsZoneKeyvaultId = '' // Not a mandatory parameter
param vNetworkGatewayOnHub = false


//Session hosts
param avdDeploySessionHosts = false
param avdDeploySessionHostsCount = 1
param avdSessionHostCountIndex = 1
param availabilityZonesCompute = true
param avdSessionHostsSize = 'Standard_D2s_v3'
param avdSessionHostDiskType = 'Premium_LRS'
param zoneRedundantStorage = false
param enableAcceleratedNetworking = true
param securityType = 'TrustedLaunch'
param secureBootEnabled = true
param vTpmEnabled = true

//Availability Sets
param avsetFaultDomainCount = 2
param avsetUpdateDomainCount = 5

//Storage
param createAvdFslogixDeployment = true
param fslogixStoragePerformance = 'Premium'
param msixStoragePerformance = 'Premium'
param storageOuPath = 'OU=StorageAccounts,OU=DiCecca,DC=dicecca,DC=local'
param createMsixDeployment = false
param fslogixFileShareQuotaSize = 1
param msixFileShareQuotaSize = 1

//Images
param useSharedImage = false
param avdOsImage = 'win11_23h2_office'
param avdImageTemplateDefinitionId = ''
param managementVmOsImage = 'winServer_2022_Datacenter_smalldisk_g2'


//Tags
param createResourceTags = false

param deployAlaWorkspace = true
param alaExistingWorkspaceResourceId = ''
param avdAlaWorkspaceDataRetention = 90

param diskEncryptionKeyExpirationInDays = 60
param diskZeroTrust = false
param deployGpuPolicies = false

// Custom Naming

param avdUseCustomNaming = true

//AVD service resources resource group custom name. (Default: rg-avd-app1-dev-use2-service-objects) @maxLength(90)
param avdServiceObjectsRgCustomName = 'rg-avd-hp1-p-service-objects'

//'AVD network resources resource group custom name. (Default: rg-avd-app1-dev-use2-network)') @maxLength(90)
param avdNetworkObjectsRgCustomName = 'rg-avd-hp1-p-network'

//'AVD network resources resource group custom name. (Default: rg-avd-app1-dev-use2-pool-compute)') @maxLength(90)
param avdComputeObjectsRgCustomName = 'rg-avd-hp1-p-compute'

//'AVD network resources resource group custom name. (Default: rg-avd-app1-dev-use2-storage)') @maxLength(90)
param avdStorageObjectsRgCustomName = 'rg-avd-hp1-p-storage'

//'AVD monitoring resource group custom name. (Default: rg-avd-dev-use2-monitoring)') @maxLength(90)
param avdMonitoringRgCustomName = 'rg-avd-p-monitoring'

//'AVD virtual network custom name. (Default: vnet-app1-dev-use2-001)') @maxLength(64)
param avdVnetworkCustomName = 'vnet-avd-p-weu-01'

//'AVD Azure log analytics workspace custom name. (Default: log-avd-app1-dev-use2)') @maxLength(64)
param avdAlaWorkspaceCustomName = 'log-avd-p-01'

//'AVD virtual network subnet custom name. (Default: snet-avd-app1-dev-use2-001)') @maxLength(80)
param avdVnetworkSubnetCustomName = 'snet-avd-hp1-p-weu-01'

//'private endpoints virtual network subnet custom name. (Default: snet-pe-app1-dev-use2-001)') @maxLength(80)
param privateEndpointVnetworkSubnetCustomName = 'snet-avd-pe-p-weu-01'

//'AVD network security group custom name. (Default: nsg-avd-app1-dev-use2-001)') @maxLength(80)
param avdNetworksecurityGroupCustomName = 'nsg-snet-avd-hp1-p-weu-01'

//'Private endpoint network security group custom name. (Default: nsg-pe-app1-dev-use2-001)') @maxLength(80)
param privateEndpointNetworksecurityGroupCustomName = 'nsg-snet-avd-pe-p-weu-01'

//'AVD route table custom name. (Default: route-avd-app1-dev-use2-001)') @maxLength(80)
param avdRouteTableCustomName = 'route-avd-hp1-p-weu-01'

//'Private endpoint route table custom name. (Default: route-avd-app1-dev-use2-001)') @maxLength(80)
param privateEndpointRouteTableCustomName = 'route-avd-pe-p-weu-01'

//AVD application security custom name. (Default: asg-app1-dev-use2-001)') @maxLength(80)
param avdApplicationSecurityGroupCustomName = 'asg-avd-hp1-p-weu-01'

//'AVD workspace custom name. (Default: vdws-app1-dev-use2-001)') @maxLength(64)
param avdWorkSpaceCustomName = 'ws-avd-hp1-p-weu-01'

//'AVD workspace custom friendly (Display) name. (Default: App1 - Dev - East US 2 - 001)') @maxLength(64)
param avdWorkSpaceCustomFriendlyName = 'SJ Virtuellt Skrivbord'

//'AVD host pool custom name. (Default: vdpool-app1-dev-use2-001)') @maxLength(64)
param avdHostPoolCustomName = 'avd-hp1-p-weu-01'

//'AVD host pool custom friendly (Display) name. (Default: App1 - East US - Dev - 001)') @maxLength(64)
param avdHostPoolCustomFriendlyName = 'HostPool - Prod - West Europe - 01'

//'AVD scaling plan custom name. (Default: vdscaling-app1-dev-use2-001)') @maxLength(64)
param avdScalingPlanCustomName = 'sp-avd-hp1-p-weu-01'

//'AVD desktop application group custom name. (Default: vdag-desktop-app1-dev-use2-001)') @maxLength(64)
param avdApplicationGroupCustomName = 'ag-avd-hp1-p-weu-01'

//'AVD desktop application group custom friendly (Display) name. (Default: Desktops - App1 - East US - Dev - 001)') @maxLength(64)
param avdApplicationGroupCustomFriendlyName = 'Desktop - HP1 - Prod - West Europe - 01'

//'AVD session host prefix custom name. (Default: vmapp1duse2)') @maxLength(11)
param avdSessionHostCustomNamePrefix = 'vmavdhp1p'

//'AVD availability set custom name. (Default: avail)') @maxLength(9)
param avsetCustomNamePrefix = 'avail'

//'AVD FSLogix and MSIX app attach storage account prefix custom name. (Default: st)') @maxLength(2)
param storageAccountPrefixCustomName = 'st'

//'FSLogix file share name. (Default: fslogix-pc-app1-dev-001)')
param fslogixFileShareCustomName = 'hp1fslogixcontainers'

//'MSIX file share name. (Default: msix-app1-dev-001)')
param msixFileShareCustomName = 'hp1msixappattach'

//'AVD keyvault prefix custom name (with Zero Trust to store credentials to domain join and local admin). (Default: kv-sec)') @maxLength(6)
param avdWrklKvPrefixCustomName = 'kv-sec'

//'AVD disk encryption set custom name. (Default: des-zt)') @maxLength(6)
param ztDiskEncryptionSetCustomNamePrefix = 'des-zt'

//'AVD managed identity for zero trust to encrypt managed disks using a customer managed key.  (Default: id-zt)') @maxLength(5)
param ztManagedIdentityCustomName = 'id-zt'

//'AVD key vault custom name for zero trust and store store disk encryption key (Default: kv-key)') @maxLength(6)
param ztKvPrefixCustomName = 'kv-key'
