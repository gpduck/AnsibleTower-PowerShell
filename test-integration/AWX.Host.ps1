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

$Credential = Get-AnsibleCredential -Password $Password

Describe "Host Functions" {
    Context "Get-AnsibleHost" {
        Reload-AWX -Url $Url -Password $Password
        Connect-AnsibleTower -TowerUrl $Url -Credential $Credential
        $Object = Get-AnsibleHost @Tower

        It "Gets the localhost" {
            $Object.Count | Should -Be 1
        }

        It "Gets the name" {
            $Object.Name | Should -Be "localhost"
        }

        It "Gets the description" {
            $Object.Description | Should -Be "Host Description"
        }

        It "Gets the inventory as an object" {
            $Object.Inventory.GetType() | Should -Be ([AnsibleTower.Inventory])
        }

        It "Gets the variables as a hashtable" {
            $Object.Variables.GetType() | Should -Be ([System.Collections.Hashtable])
        }

        It "Gets AnsibleTower" {
            $Object.AnsibleTower | Should -Not -Be $null
            $Object.AnsibleTower.GetType() | Should -Be ([AnsibleTower.Tower])
        }
    }

    Context "Random Group Test" {
        it "Does a group work here?" {
            $Group = Get-AnsibleGroup @Tower
            $Group | Should -Not -Be $null
        }
    }

    Context "Set-AnsibleHost" {
        Reload-AWX -Url $Url -Password $Password
        BeforeEach {
            $Object = Get-AnsibleHost @Tower
        }

        It "Updates the host name by ID" {
            $Name = Get-RandomString
            Set-AnsibleHost -Id $Object.id -name $name @Tower
            $UpdatedObject = Get-AnsibleHost -id $Object.id @Tower
            $UpdatedObject.Name | Should -Be $Name
        }

        It "Updates the host description by ID" {
            $Description = Get-RandomString
            Set-AnsibleHost -Id $Object.id -Description $Description @Tower
            $UpdatedObject = Get-AnsibleHost -id $Object.id @Tower
            $UpdatedObject.Description | Should -Be $Description
        }

        It "Updates the host name by pipeline" {
            $Name = Get-RandomString
            $Object | Set-AnsibleHost -name $Name
            $UpdatedObject = Get-AnsibleHost -Id $Object.Id @Tower
            $UpdatedObject.name | Should -Be $Name
        }

        It "Updates the host description by pipeline" {
            $Description = Get-RandomString
            $Object | Set-AnsibleHost -Description $Description
            $UpdatedObject = Get-AnsibleHost -Id $Group.Id @Tower
            $UpdatedObject.Description | Should -Be $Description
        }
    }
}