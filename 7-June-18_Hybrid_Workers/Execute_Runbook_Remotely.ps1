#-----------------------------
$Script:subscriptionID = "yoursubid"
$Script:runbook = "RunbookName"
$Script:resourceGroup = "ResourceGroup"
$Script:automationAccount = "AAAName"
$Script:hybridWorker = "hybridworkname"
#-----------------------------

$results = Start-AzureRmAutomationRunbook `
                -Name $Script:runbook `
                -ResourceGroupName $Script:resourceGroup `
                -AutomationAccountName $Script:automationAccount `
                -Parameters @{"User" = "$userName"} `
                -RunOn $Script:hybridWorker `
                -Wait `
                -Verbose `
                -ErrorAction Stop