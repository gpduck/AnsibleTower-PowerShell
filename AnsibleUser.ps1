function Get-AnsibleUser
{
    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [int]$id
    )

    if ($id)
    {
        $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "users" -Id $id
    }
    Else
    {
        $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "users"
    }
    

    if (!($Return))
    {
        #Nothing returned from the call
        Return
    }
    $returnobj = @()
    foreach ($jsonorg in $return)
    {
        #Shift back to json and let newtonsoft parse it to a strongly named object instead
        $jsonorgstring = $jsonorg | ConvertTo-Json
        $org = $JsonParsers.ParseToUser($jsonorgstring)
        $returnobj += $org; $org = $null

    }
    #return the things
    $returnobj
}

Function New-AnsibleUser
{
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        $UserName,
        [Parameter(Mandatory=$true)] 
        $FirstName, 
        [Parameter(Mandatory=$true)]
        $LastName, 
        [Parameter(Mandatory=$true)]
        $Email, 
        [Parameter(Mandatory=$true)]
        [bool]$SuperUser, 
        [Parameter(Mandatory=$true)]
        $Password
    )
    $myobj = "" | Select username, first_name, last_name, email, is_superuser, password
    $myobj.username = $UserName
    if ($FirstName){$myobj.first_name = $FirstName}
    if ($LastName){$myobj.last_name = $LastName}
    if ($Email){$myobj.email = $Email}
    if ($SuperUser) {$myobj.is_superuser = $SuperUser}
    if ($Password) {$myobj.password = $Password}
    
    $result = Invoke-PostAnsibleInternalJsonResult -ItemType "users" -InputObject $myobj
    if ($result)
    {
        $resultString = $result | ConvertTo-Json
        $resultobj = $JsonParsers.ParseToUser($resultString)
        $resultobj
    }
    
}