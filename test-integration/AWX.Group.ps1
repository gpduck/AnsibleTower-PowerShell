param(
    [Parameter(Mandatory=$true)]
    $Url,

    [Parameter(Mandatory=$true)]
    $Password,

    $AnsibleTower
)

. "$PSScriptRoot/TestFunctions.ps1"

$Tower = @{}
if($PSBoundParameters.ContainsKey("AnsibleTower")) {
    $Tower["AnsibleTower"] = $AnsibleTower
}

Describe "Group Functions" {
    Context "Get-AnsibleGroup" {
        Reload-AWX -Url $Url -Password $Password
        $Group = Get-AnsibleGroup @Tower

        It "Gets the demo group" {
            $Group.Count | Should -Be 1
        }

        It "Gets the name" {
            $Group.Name | Should -Be "Demo Group"
        }

        It "Gets the description" {
            $Group.Description | Should -Be "Group Description"
        }

        It "Gets the inventory as an object" {
            $Group.Inventory.GetType() | Should -Be ([AnsibleTower.Inventory])
        }

        It "Gets the variables as a hashtable" {
            $Group.Variables.GetType() | Should -Be ([System.Collections.Hashtable])
        }

        It "Gets AnsibleTower" {
            $Group.AnsibleTower | Should -Not -Be $null
            $Group.AnsibleTower.GetType() | Should -Be ([AnsibleTower.Tower])
        }
    }

    Context "Set-AnsibleGroup" {
        Reload-AWX -Url $Url -Password $Password
        BeforeEach {
            $Group = Get-AnsibleGroup
        }

        It "Updates the group name by ID" {
            $Name = Get-RandomString
            Set-AnsibleGroup -Id $Group.id -name $name @Tower
            $UpdatedGroup = Get-AnsibleGroup -id $Group.id @Tower
            $UpdatedGroup.Name | Should -Be $Name
        }

        It "Updates the group description by ID" {
            $Description = Get-RandomString
            Set-AnsibleGroup -Id $Group.id -Description $Description @Tower
            $UpdatedGroup = Get-AnsibleGroup -id $Group.id @Tower
            $UpdatedGroup.Description | Should -Be $Description
        }

        It "Updates the group name by pipeline" {
            $Name = Get-RandomString
            $Group | Set-AnsibleGroup -name $Name
            $UpdatedGroup = Get-AnsibleGroup -Id $Group.Id @Tower
            $UpdatedGroup.name | Should -Be $Name
        }

        It "Updates the group description by pipeline" {
            $Description = Get-RandomString
            $Group | Set-AnsibleGroup -Description $Description
            $UpdatedGroup = Get-AnsibleGroup -Id $Group.Id @Tower
            $UpdatedGroup.Description | Should -Be $Description
        }
    }
}