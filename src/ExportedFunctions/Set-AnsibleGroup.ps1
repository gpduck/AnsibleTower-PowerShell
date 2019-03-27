<#
.DESCRIPTION
Update the name or description of a group in Ansible Tower.

.PARAMETER Id

.PARAMETER Name

.PARAMETER Description

#>
function Set-AnsibleGroup {
    [CmdletBinding(SupportsShouldProcess=$true)]
    [OutputType([AnsibleTower.Group])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:DefaultAnsibleTower")]
    param(
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName='ById')]
        [Int32]$Id,

        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ParameterSetName='ByObject')]
        [AnsibleTower.Group]$InputObject,

        [Parameter(Position=1)]
        [String]$Name,

        [Parameter(Position=2)]
        [String]$Description,

        [switch]$PassThru,

        $AnsibleTower = $Global:DefaultAnsibleTower
    )
    process {
        $UpdateProps = @{}

        if($Id) {
            $ThisObject = Get-AnsibleGroup -Id $Id -AnsibleTower $AnsibleTower
        } else {
            $AnsibleTower = $InputObject.AnsibleTower
            # Get a new instance to avoid modifing the passed in user object
            $ThisObject = Get-AnsibleGroup -Id $InputObject.Id -AnsibleTower $AnsibleTower
        }

        if($PSBoundParameters.ContainsKey("Name")) {
            $UpdateProps["name"] = $Name
        }

        if($PSBoundParameters.ContainsKey("Description")) {
            $UpdateProps["description"] = $Description
        }

        if($UpdateProps.Count -gt 0 -and $PSCmdlet.ShouldProcess($AnsibleTower, "Update properties on group $($ThisObject.Name)")) {
            $PatchJson = ConvertTo-Json $UpdateProps
            $AnsibleObject = Invoke-AnsibleRequest -FullPath $ThisObject.Url -Method PATCH -Body $PatchJson -AnsibleTower $AnsibleTower | ResultToGroup -AnsibleTower $AnsibleTower
            if($PassThru) {
                $AnsibleObject
            }
        }
    }
}