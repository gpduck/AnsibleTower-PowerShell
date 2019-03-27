<#
.DESCRIPTION
Gets groups defined in Ansible Tower.

.PARAMETER Description
Optional description of this group.

.PARAMETER HasActiveFailures
Flag indicating whether this group has any hosts with active failures.

.PARAMETER HasInventorySources
Flag indicating whether this group was created/updated from any external inventory sources.

.PARAMETER Name
Name of this group.

.PARAMETER Variables
Group variables in JSON or YAML format.

.PARAMETER Id
The ID of a specific AnsibleGroup to get

.PARAMETER AnsibleTower
The Ansible Tower instance to run against.  If no value is passed the command will run against $Global:DefaultAnsibleTower.
#>
function Get-AnsibleGroup
{
    [CmdletBinding(DefaultParameterSetname='PropertyFilter')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:DefaultAnsibleTower")]
    Param (
        [Parameter(ParameterSetName='PropertyFilter')]
        [String]$Description,

        [Parameter(ParameterSetName='PropertyFilter')]
        [switch]$HasActiveFailures,

        [Parameter(ParameterSetName='PropertyFilter')]
        [switch]$HasInventorySources,

        [Parameter(Position=2,ParameterSetName='PropertyFilter')]
        [Object]$Inventory,

        [Parameter(Position=1,ParameterSetName='PropertyFilter')]
        [String]$Name,

        [Parameter(ParameterSetName='PropertyFilter')]
        [String]$Variables,

        [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName='ById')]
        [Int32]$Id,

        [Parameter(ParameterSetName='ById')]
        [Switch]$UseCache,

        $AnsibleTower = $Global:DefaultAnsibleTower
    )
    process {
        $Filter = @{}
        if($PSBoundParameters.ContainsKey("Description")) {
            if($Description.Contains("*")) {
                $Filter["description__iregex"] = $Description.Replace("*", ".*")
            } else {
                $Filter["description"] = $Description
            }
        }

        if($PSBoundParameters.ContainsKey("HasActiveFailures")) {
            $Filter["has_active_failures"] = $HasActiveFailures
        }

        if($PSBoundParameters.ContainsKey("HasInventorySources")) {
            $Filter["has_inventory_sources"] = $HasInventorySources
        }

        if($PSBoundParameters.ContainsKey("Inventory")) {
            switch($Inventory.GetType().Fullname) {
                "AnsibleTower.Inventory" {
                    $Filter["inventory"] = $Inventory.Id
                }
                "System.Int32" {
                    $Filter["inventory"] = $Inventory
                }
                "System.String" {
                    $Filter["inventory__name"] = $Inventory
                }
                default {
                    Write-Error "Unknown type passed as -Inventory ($_).  Supported values are String, Int32, and AnsibleTower.Inventory." -ErrorAction Stop
                    return
                }
            }
        }

        if($PSBoundParameters.ContainsKey("Name")) {
            if($Name.Contains("*")) {
                $Filter["name__iregex"] = $Name.Replace("*", ".*")
            } else {
                $Filter["name"] = $Name
            }
        }

        if($PSBoundParameters.ContainsKey("Variables")) {
            if($Variables.Contains("*")) {
                $Filter["variables__iregex"] = $Variables.Replace("*", ".*")
            } else {
                $Filter["variables"] = $Variables
            }
        }

        if ($id) {
            $CacheKey = "groups/$id"
            $AnsibleObject = $AnsibleTower.Cache.Get($CacheKey)
            if($UseCache -and $AnsibleObject) {
                Write-Debug "[Get-AnsibleGroup] Returning $($AnsibleObject.Url) from cache"
                $AnsibleObject
            } else {
                Invoke-GetAnsibleInternalJsonResult -ItemType "groups" -Id $id -AnsibleTower $AnsibleTower | ResultToGroup -AnsibleTower $AnsibleTower
            }
        } else {
            Invoke-GetAnsibleInternalJsonResult -ItemType "groups" -AnsibleTower $AnsibleTower -Filter $Filter | ResultToGroup -AnsibleTower $AnsibleTower
        }
    }
}
