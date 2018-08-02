#install SHiPS
Install-Module -Name SHiPS

#install PowerShellGet to be able to get azure cmdlets
Install-Module PowerShellGet -Force

# Install the Azure Resource Manager modules from the PowerShell Gallery
Install-Module -Name AzureRM -AllowClobber #can also be used to upgrade version

#import Azure module
Import-Module -Name AzureRM

# Authenticate to your Azure account
Login-AzureRMAccount

#install AzurePSDrive module
Install-Module -Name AzurePSDrive

# Create a drive for AzureRM
$driveName = 'Az'
Import-Module AzurePSDrive
New-PSDrive -Name $driveName -PSProvider SHiPS -Root AzurePSDrive#Azure

#start navigating
cd $driveName":"

#you can take actions via the pipeline (even search)
dir | Stop-AzureRmWebApp

# Mount to Azure file share so that you can add/delete/modify files and directories
net use z: \\myacc.file.core.windows.net\share1  /u:AZURE\myacc <AccountKey>

#remove the drive
cd C:\
Remove-PSDrive -Name $driveName
#--------------------------------------------------------------------------------
Find-Module -Tag SHIPS
#--------------------------------------------------------------------------------
