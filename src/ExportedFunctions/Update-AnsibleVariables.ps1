function Update-AnsibleVariables {
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        $InputObject,

        [Hashtable]$Add = @{},

        [string[]]$Clear = @(),

        [switch]$PassThru
    )
    process {
        $Variables = [Newtonsoft.Json.JsonConvert]::SerializeObject($InputObject.Variables)
        $MergedJson = [AnsibleTower.JsonFunctions]::MergeJson($Variables, $Add)
        $NewJson = [AnsibleTower.JsonFunctions]::ClearJson($MergedJson, $Clear)
        $Variables = Invoke-AnsibleRequest -FullPath $InputObject.Related["variable_data"] -Method PUT -Body $NewJson -AnsibleTower $InputObject.AnsibleTower
        $VariablesJson = $Variables | ConvertTo-Json
        $InputObject.Variables = [Newtonsoft.Json.JsonConvert]::DeserializeObject($VariablesJson, [Hashtable], (New-Object AnsibleTower.HashtableConverter))
        if($PassThru) {
            $InputObject
        }
    }
}