function Get-AnsibleGroup
{
    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [int]$id,
        [String]$Name
    )

    if ($id)
    {
        $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "groups" -Id $id
    }
    Else
    {
        $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "groups"
    }
    

    if (!($Return))
    {
        #Nothing returned from the call
        Return
    }
    $returnobj = @()
    foreach ($jsongroup in $return)
    {
        #Shift back to json and let newtonsoft parse it to a strongly named object instead
        $jsongroupstring = $jsongroup | ConvertTo-Json
        $group = $JsonParsers.ParseToGroup($jsongroupstring)
        $returnobj += $group; $group = $null

    }

    if ($Name)
    {
        $returnobj = $returnobj | where {$_.Name -like $name}
    }
    #return the things
    if ($returnobj)
    {
        $returnobj
    }
    
}
