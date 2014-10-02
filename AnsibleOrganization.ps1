function Get-AnsibleOrganization
{
    [CmdletBinding()]
    Param (
        [String]$Name,
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [int]$id
    )

    if ($id)
    {
        $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "organizations" -Id $id
    }
    Else
    {
        $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "organizations"
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
        $org = $JsonParsers.ParseToOrganization($jsonorgstring)
        $returnobj += $org; $org = $null

    }
    #return the things
    $returnobj
}

Function New-AnsibleOrganization
{
    [CmdletBinding()]
    Param ($Name, $Description)
    $myobj = "" | Select name, description
    $myobj.name = $Name
    if ($Description)
    {
        $myobj.description = $Description
    }
    

    $result = Invoke-PostAnsibleInternalJsonResult -ItemType "organizations" -InputObject $myobj
    if ($result)
    {
        $resultString = $result | ConvertTo-Json
        $resultobj = $JsonParsers.ParseToOrganization($resultString)
        $resultobj
    }
    
}

