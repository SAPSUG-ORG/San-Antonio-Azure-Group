$prodURI = "automationURI"
$pKey = "automationKey"

cd "C:\Program Files\Microsoft Monitoring Agent\Agent\AzureAutomation\7.2.14544.0\HybridRegistration"
Import-Module .\HybridRegistration.psd1
Add-HybridRunbookWorker -Url $prodURI -Key $pKey -GroupName "Demo"