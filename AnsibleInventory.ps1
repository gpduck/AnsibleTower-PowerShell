function Get-AnsibleInventory
{
    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [int]$id
    )

    if ($id)
    {
        $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "inventory" -Id $id
    }
    Else
    {
        $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "inventory"
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
        $inventory = $JsonParsers.ParseToInventory($jsonorgstring)

        $Groups = Invoke-GetAnsibleInternalJsonResult -ItemType "inventory" -Id $inventory.id -ItemSubItem "groups"
        
        foreach ($group in $groups)
        {
            $GroupObj = Get-AnsibleGroup -id $group.id
            if (!($thishost.groups)) 
            {
                $inventory.groups = $GroupObj
            }
            Else
            {
                $inventory.groups.add($GroupObj)
            }
        }

        $returnobj += $inventory; $inventory = $null

    }
    #return the things
    $returnobj
}
