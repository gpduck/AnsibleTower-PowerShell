function Get-AnsibleHost
{
    [CmdletBinding()]
    [OutputType([AnsibleTower.Host])]
    Param (
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [int]$id, 

        [string]$Name
    )

    if ($id)
    {
        $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "hosts" -Id $id
    }
    Else
    {
        $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "hosts"
    }
    

    if (!($Return))
    {
        #Nothing returned from the call
        Return
    }
    $returnobj = @()
    foreach ($jsonhost in $return)
    {
        #Shift back to json and let newtonsoft parse it to a strongly named object instead
        $jsonhoststring = $jsonhost | ConvertTo-Json
        $thishost = $JsonParsers.ParseToHost($jsonhoststring)

        Write-verbose "Found host id $($thishost.id)"

        #Get the related groups
        $Groups = Invoke-GetAnsibleInternalJsonResult -ItemType "hosts" -Id $thishost.id -ItemSubItem "groups"
        
        foreach ($group in $groups)
        {
            $GroupObj = Get-AnsibleGroup -id $group.id
            if (!($thishost.groups)) 
            {
                $thishost.groups = $GroupObj
            }
            Else
            {
                $thishost.groups.add($GroupObj)
            }
        }

        $returnobj += $thishost; $thishost = $null

    }

    if ($name)
    {
        $returnobj = $Return | where {$_.Name -eq $name}
    }


    #return the things
    if ($returnobj)
    {
        $returnobj
    }
    
}


Function New-AnsibleHost
{
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [string]$Name,

        [Parameter(Mandatory=$false)]
        [string]$Description,

        [Parameter(Mandatory=$true)]
        [AnsibleTower.Inventory]$Inventory, 

        [Parameter(Mandatory=$true)]
        [AnsibleTower.Group]$group, 

        [String]$Variables = "---",

        [bool]$Enabled = $true
    )
    
    $Group = Get-AnsibleGroup -id ($group.id)
    if (!($group)) {
        write-error "Could not find group $($group.name)"
        return
    }

    $myobj = "" | Select name, description, inventory, variables, enabled
    $myobj.Name = $Name
    $myobj.Description = $Description
    $myobj.Inventory = $Inventory.id
    $myobj.variables = $Variables
    $myobj.enabled = $Enabled

    $result = Invoke-PostAnsibleInternalJsonResult -ItemType "groups" -InputObject $myobj -itemId ($group.id) -ItemSubItem "hosts"
    
}
