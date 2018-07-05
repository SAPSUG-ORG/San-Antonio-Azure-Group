#https://docs.microsoft.com/en-us/azure/automation/automation-dsc-getting-started
#https://docs.microsoft.com/en-us/azure/automation/automation-dsc-onboarding

#--------------------------------------------------------------------------
Configuration AzureDemo1 {
	Param ()
	Import-DscResource -ModuleName PSDesiredStateConfiguration
	
	node localhost {
		#------------------------------------
		WindowsFeature 'Telnet-Client' {
			#DependsOn = "[WindowsFeature]Failover-Clustering"
			Ensure = "Absent"
			Name = "Telnet-Client"
        } #clusterPowerShell
        #------------------------------------
		File RequiredDirectory {
			Ensure = 'Present'
			Type = 'Directory'
			DestinationPath = "C:\RequiredDirectory"
		} #VMsFile
		#------------------------------------
    }#localhost
} #close configuration
#--------------------------------------------------------------------------
Configuration OnPremDemo1 {
    node localhost {
        #------------------------------------
        WindowsFeature 'RSAT-DNS-Server' {
            Ensure='Present'
            Name='RSAT-DNS-Server'
        } #RSAT-Clustering
        #------------------------------------
		File RequiredDirectory {
			Ensure = 'Present'
			Type = 'Directory'
			DestinationPath = "C:\RequiredDirectory"
		} #VMsFile
		#------------------------------------
    } #node
} #close configuration
#--------------------------------------------------------------------------
Configuration OnPremDemo2 {
    Import-DscResource -ModuleName ComputerManagementDsc
    $joinCred = Get-AutomationPSCredential -Name 'DemoCred'
    node 2019Demo {
        #------------------------------------
        WindowsFeature 'RSAT-DNS-Server' {
            Ensure='Present'
            Name='RSAT-DNS-Server'
        } #RSAT-Clustering
        #------------------------------------
		File RequiredDirectory {
			Ensure = 'Present'
			Type = 'Directory'
			DestinationPath = "C:\RequiredDirectory"
		} #VMsFile
		#------------------------------------
        Computer JoinDomain {
            Name = "2019Demo"
            DomainName = "ark.local"
            Credential = $joinCred
        }
        #------------------------------------
    } #node
} #close configuration
#--------------------------------------------------------------------------
#Remove all mof files (pending,current,backup,MetaConfig.mof,caches,etc)
rm C:\windows\system32\Configuration\*.mof*
#Kill the LCM/DSC processes
gps wmi* | ? {$_.modules.ModuleName -like "*DSC*"} | stop-process -force
#not really needed but go the extra mile and remove all stages as well
Remove-DscConfigurationDocument -Stage Current, Pending, Previous -Verbose
#--------------------------------------------------------------------------
# The DSC configuration that will generate metaconfigurations
[DscLocalConfigurationManager()]
Configuration DscMetaConfigs
{

    param
    (
        [Parameter(Mandatory=$True)]
        [String]$RegistrationUrl,

        [Parameter(Mandatory=$True)]
        [String]$RegistrationKey,

        [Parameter(Mandatory=$True)]
        [String[]]$ComputerName,

        [Int]$RefreshFrequencyMins = 30,

        [Int]$ConfigurationModeFrequencyMins = 15,

        [String]$ConfigurationMode = "ApplyAndMonitor",

        [String]$NodeConfigurationName,

        [Boolean]$RebootNodeIfNeeded= $False,

        [String]$ActionAfterReboot = "ContinueConfiguration",

        [Boolean]$AllowModuleOverwrite = $False,

        [Boolean]$ReportOnly
    )

    if(!$NodeConfigurationName -or $NodeConfigurationName -eq "")
    {
        $ConfigurationNames = $null
    }
    else
    {
        $ConfigurationNames = @($NodeConfigurationName)
    }

    if($ReportOnly)
    {
    $RefreshMode = "PUSH"
    }
    else
    {
    $RefreshMode = "PULL"
    }

    Node $ComputerName
    {

        Settings
        {
            RefreshFrequencyMins = $RefreshFrequencyMins
            RefreshMode = $RefreshMode
            ConfigurationMode = $ConfigurationMode
            AllowModuleOverwrite = $AllowModuleOverwrite
            RebootNodeIfNeeded = $RebootNodeIfNeeded
            ActionAfterReboot = $ActionAfterReboot
            ConfigurationModeFrequencyMins = $ConfigurationModeFrequencyMins
        }

        if(!$ReportOnly)
        {
        ConfigurationRepositoryWeb AzureAutomationDSC
            {
                ServerUrl = $RegistrationUrl
                RegistrationKey = $RegistrationKey
                ConfigurationNames = $ConfigurationNames
            }

            ResourceRepositoryWeb AzureAutomationDSC
            {
            ServerUrl = $RegistrationUrl
            RegistrationKey = $RegistrationKey
            }
        }

        ReportServerWeb AzureAutomationDSC
        {
            ServerUrl = $RegistrationUrl
            RegistrationKey = $RegistrationKey
        }
    }
}

# Create the metaconfigurations
# NOTE: DSC Node Configuration names are case sensitive in the portal.
# TODO: edit the below as needed for your use case
$Params = @{
    RegistrationUrl = '<fill me in>';
    RegistrationKey = '<fill me in>';
    ComputerName = @('<some VM to onboard>', '<some other VM to onboard>');
    NodeConfigurationName = 'SimpleConfig.webserver';
    RefreshFrequencyMins = 30;
    ConfigurationModeFrequencyMins = 15;
    RebootNodeIfNeeded = $False;
    AllowModuleOverwrite = $False;
    ConfigurationMode = 'ApplyAndMonitor';
    ActionAfterReboot = 'ContinueConfiguration';
    ReportOnly = $False;  # Set to $True to have machines only report to AA DSC but not pull from it
}

# Use PowerShell splatting to pass parameters to the DSC configuration being invoked
# For more info about splatting, run: Get-Help -Name about_Splatting
DscMetaConfigs @Params