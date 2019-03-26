$ModulePath = Join-Path $PSScriptRoot "..\Release\AnsibleTower"

Import-Module $ModulePath

function TestValue {
    param(
        $Value,
        $ExpectedValue,
        $ExpectedType
    )
    $Value | Should -Be $ExpectedValue
    if($null -ne $ExpectedType) {
        $Value.GetType() | Should -Be $ExpectedType
    } else {
        {$Value.GetType()} | Should -Throw
    }

}

Describe "HashtableConverter" {
    BeforeEach {
        $Converter = New-Object AnsibleTower.HashtableConverter
    }

    It "loads the type" {
        [AnsibleTower.HashtableConverter] | Should -Not -Be $null
    }

    It "Returns an empty hashtable" {
        $Json = '{ }'
        $Ht = [Newtonsoft.Json.JsonConvert]::DeserializeObject($Json, [hashtable], $Converter)
        $Ht.GetType() | Should -Be ([System.Collections.Hashtable])
        $Ht.Count | Should -Be 0
    }

    context "Primitives" {
        BeforeEach {
            $DTValue = [DateTime]::parse("2019-03-25T20:40:14.6814502-05:00")
            $Json = ConvertTo-Json @{
                "string" = "string value"
                "int" = 5
                "float" = 3.14
                "bool" = $false
                "null" = $null
                "datetime" = $DTValue
                "int_list" = @(1,2,3)
                "string_list" = @("one", "two", "three")
            }
            $Ht = [Newtonsoft.Json.JsonConvert]::DeserializeObject($Json, [hashtable], $Converter)
        }

        It "Parses a string property" {
            TestValue -Value $Ht["string"] -ExpectedValue "string value" -ExpectedType ([System.String])
        }

        It "Parses an int property" {
            TestValue -Value $Ht["int"] -ExpectedValue 5 -Expectedtype ([System.Int64])
        }

        It "Parses a float property" {
            TestValue -Value $Ht["float"] -ExpectedValue 3.14 -Expectedtype ([System.Double])
        }

        It "Parses a bool property" {
            TestValue -Value $Ht["bool"] -ExpectedValue $false -Expectedtype ([System.Boolean])
        }

        It "Parses a null property" {
            TestValue -Value $Ht["null"] -ExpectedValue $null -Expectedtype $null
        }

        It "Parses a datetime property" {
            TestValue -Value $Ht["datetime"] -ExpectedValue $DTValue -Expectedtype ([System.DateTime])
        }

        It "Parses a list of ints" {
            TestValue -Value $Ht["int_list"] -ExpectedValue @(1,2,3) -Expectedtype ([System.Collections.Generic.List[System.Object]])
        }

        It "Parses a list of strings" {
            TestValue -Value $Ht["string_list"] -ExpectedValue @("one", "two", "three") -Expectedtype ([System.Collections.Generic.List[System.Object]])
        }
    }

    context "Nested objects" {
        BeforeEach {
            $DTValue = [DateTime]::parse("2019-03-25T20:40:14.6814502-05:00")
            $Json = ConvertTo-Json @{
                "hashtable" = @{
                    "string" = "string value"
                    "int" = 5
                    "float" = 3.14
                    "bool" = $false
                    "null" = $null
                    "datetime" = $DTValue
                    "int_list" = @(1,2,3)
                    "string_list" = @("one", "two", "three")
                }
            }
            $Ht = [Newtonsoft.Json.JsonConvert]::DeserializeObject($Json, [hashtable], $Converter)
        }

        It "Returns a nested object as a hashtable" {
            $Ht["hashtable"].GetType() | Should -Be ([System.Collections.Hashtable])
        }

        It "Parses a nested string property" {
            TestValue -Value $Ht["hashtable"]["string"] -ExpectedValue "string value" -ExpectedType ([System.String])
        }

        It "Parses a nested int property" {
            TestValue -Value $Ht["hashtable"]["int"] -ExpectedValue 5 -Expectedtype ([System.Int64])
        }

        It "Parses a nested float property" {
            TestValue -Value $Ht["hashtable"]["float"] -ExpectedValue 3.14 -Expectedtype ([System.Double])
        }

        It "Parses a nested bool property" {
            TestValue -Value $Ht["hashtable"]["bool"] -ExpectedValue $false -Expectedtype ([System.Boolean])
        }

        It "Parses a nested null property" {
            TestValue -Value $Ht["hashtable"]["null"] -ExpectedValue $null -Expectedtype $null
        }

        It "Parses a nested DateTime property" {
            TestValue -Value $Ht["hashtable"]["datetime"] -ExpectedValue $DTValue -Expectedtype ([System.DateTime])
        }

        It "Parses a nested list of ints" {
            TestValue -Value $Ht["hashtable"]["int_list"] -ExpectedValue @(1,2,3) -Expectedtype ([System.Collections.Generic.List[System.Object]])
        }

        It "Parses a nested list of strings" {
            TestValue -Value $Ht["hashtable"]["string_list"] -ExpectedValue @("one", "two", "three") -Expectedtype ([System.Collections.Generic.List[System.Object]])
        }
    }
}