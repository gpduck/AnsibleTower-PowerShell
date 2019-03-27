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

Describe "Project Functions" {
    Context "Get-AnsibleProject" {
        Reload-AWX -Url $Url -Password $Password
        $Object = Get-AnsibleProject @Tower

        It "Gets the demo project" {
            $Object.Count | Should -Be 1
        }

        It "Gets the name" {
            $Object.Name | Should -Be "Demo Project"
        }

        It "Gets the description" {
            $Object.Description | Should -Be "Project Description"
        }

        It "Gets the organization as an object" {
            $Object.Organization.GetType() | Should -Be ([AnsibleTower.Organization])
        }

        It "Gets AnsibleTower" {
            $Object.AnsibleTower | Should -Not -Be $null
            $Object.AnsibleTower.GetType() | Should -Be ([AnsibleTower.Tower])
        }
    }

    Context "Set-AnsibleProject" {
        Reload-AWX -Url $Url -Password $Password
        BeforeEach {
            $Object = Get-AnsibleProject @Tower
        }

        It "Updates the project name by ID" {
            $Name = Get-RandomString
            Set-AnsibleProject -Id $Object.id -name $name @Tower
            $UpdatedObject = Get-AnsibleProject -id $Object.id @Tower
            $UpdatedObject.Name | Should -Be $Name
        }

        It "Updates the project description by ID" {
            $Description = Get-RandomString
            Set-AnsibleProject -Id $Object.id -Description $Description @Tower
            $UpdatedObject = Get-AnsibleProject -id $Object.id @Tower
            $UpdatedObject.Description | Should -Be $Description
        }

        It "Updates the project name by pipeline" {
            $Name = Get-RandomString
            $Object | Set-AnsibleProject -name $Name
            $UpdatedObject = Get-AnsibleProject -Id $Object.Id @Tower
            $UpdatedObject.name | Should -Be $Name
        }

        It "Updates the project description by pipeline" {
            $Description = Get-RandomString
            $Object | Set-AnsibleProject -Description $Description
            $UpdatedObject = Get-AnsibleProject -Id $Group.Id @Tower
            $UpdatedObject.Description | Should -Be $Description
        }
    }
}