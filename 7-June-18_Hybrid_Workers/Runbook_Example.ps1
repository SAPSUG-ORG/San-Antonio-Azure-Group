param(
    # Parameter help description
    [Parameter(Mandatory = $true)]
    [string]$user
)
try {
    $dCreds = Get-AutomationPSCredential -Name 'Hybrid-SA'
    Import-Module ActiveDirectory -ErrorAction Stop
    $adUserEval = Get-ADUser -Credential $dCreds -Filter "Name -eq ""$user""" -ErrorAction SilentlyContinue
    if ($adUserEval) {
        $result = @"
{
"Status": FAILED,
"Code": UserExists"
}
"@

    }#if_userExists
    else{
        New-ADUser -Credential $dCreds -Name "$user" -OtherAttributes @{'title'="director";}
        $result = @"
{
"Status": SUCCESS,
"Code": COMPLETED"
}
"@
    }#else_userExists
    
}
catch {
    $result = @"
{
"Status": FAILED,
"Code": ERROR"
}
"@      
}
return $result