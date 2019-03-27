<#
.DESCRIPTION
Updates an existing inventory in Ansible Tower.

.PARAMETER Id
The ID of the inventories to update

.PARAMETER InputObject
The object to update

.PARAMETER Description
Optional description of this inventory.

.PARAMETER HostFilter
Filter that will be applied to the hosts of this inventory.

.PARAMETER InsightsCredential
Credentials to be used by hosts belonging to this inventory when accessing Red Hat Insights API.

.PARAMETER Kind
Kind of inventory being represented.

.PARAMETER Name
Name of this inventory.

.PARAMETER Organization
Organization containing this inventory.

.PARAMETER Variables
Inventory variables in JSON or YAML format.

.PARAMETER PassThru
Outputs the updated objects to the pipeline.

.PARAMETER AnsibleTower
The Ansible Tower instance to run against.  If no value is passed the command will run against $Global:DefaultAnsibleTower.
#>
function Set-AnsibleInventory {
    [CmdletBinding(SupportsShouldProcess=$True)]
    [OutputType([AnsibleTower.Inventory])]
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingPlainTextForPassword', 'InsightsCredential')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:DefaultAnsibleTower")]
    param(
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName='ById')]
        [Int32]$Id,

        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ParameterSetName='ByObject')]
        [AnsibleTower.Inventory]$InputObject,

        [Parameter(Position=2)]
        [String]$Description,

        [String]$HostFilter,

        [Object]$InsightsCredential,

        [string]$Kind,

        [Parameter(Position=1)]
        [String]$Name,

        [Parameter(Position=3)]
        [Object]$Organization,

        [String]$Variables,

        [switch]$PassThru,

        $AnsibleTower = $Global:DefaultAnsibleTower
    )
    Process {
        $UpdateProps = @{}

        if($Id) {
            $ThisObject = Get-AnsibleInventory -Id $Id -AnsibleTower $AnsibleTower
        } else {
            $AnsibleTower = $InputObject.AnsibleTower
            $ThisObject = Get-AnsibleInventory -Id $InputObject.Id -AnsibleTower $AnsibleTower
        }

        if($PSBoundParameters.ContainsKey('Description')) {
            $UpdateProps["description"] = $Description
        }

        if($PSBoundParameters.ContainsKey('HostFilter')) {
            $UpdateProps["host_filter"] = $HostFilter
        }

        if($PSBoundParameters.ContainsKey('InsightsCredential')) {
            switch($InsightsCredential.GetType().Fullname) {
                "System.Int32" {
                    $InsightsCredentialId = $InsightsCredential
                }
                "System.String" {
                    $InsightsCredentialId = (Get-AnsibleInsightsCredential -Name $InsightsCredential -AnsibleTower $AnsibleTower).Id
                }
                "AnsibleTower.InsightsCredential" {
                    $InsightsCredentialId = $InsightsCredential.id
                }
                default {
                    Write-Error "Unknown type passed as -InsightsCredential ($_).  Supported values are String, Int32, and AnsibleTower.InsightsCredential."
                    return
                }
            }
            $UpdateProps["insights_credential"] = $InsightsCredentialId
        }

        if($PSBoundParameters.ContainsKey('Kind')) {
            $UpdateProps["kind"] = $Kind
        }

        if($PSBoundParameters.ContainsKey('Name')) {
            $UpdateProps["name"] = $Name
        }

        if($PSBoundParameters.ContainsKey('Organization')) {
            switch($Organization.GetType().Fullname) {
                "System.Int32" {
                    $OrganizationId = $Organization
                }
                "System.String" {
                    $OrganizationId = (Get-AnsibleOrganization -Name $Organization -AnsibleTower $AnsibleTower).Id
                }
                "AnsibleTower.Organization" {
                    $OrganizationId = $Organization.id
                }
                default {
                    Write-Error "Unknown type passed as -Organization ($_).  Supported values are String, Int32, and AnsibleTower.Organization."
                    return
                }
            }
            $UpdateProps["organization"] = $OrganizationId
        }

        if($PSBoundParameters.ContainsKey('Variables')) {
            $UpdateProps["variables"] = $Variables
        }

        if($UpdateProps.Count -gt 0 -and $PSCmdlet.ShouldProcess($AnsibleTower, "Update inventories $($ThisObject.Id)")) {
            $PatchJson = ConvertTo-Json $UpdateProps
            $AnsibleObject = Invoke-AnsibleRequest -FullPath $ThisObject.Url -Method PATCH -Body $PatchJson -AnsibleTower $AnsibleTower | ResultToInventory -AnsibleTower $AnsibleTower
            if($PassThru) {
                $AnsibleObject
            }
        }
    }
}
