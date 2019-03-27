function ResultToGroup {
    param(
        [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
        $InputObject,

        [Parameter(Mandatory=$true)]
        $AnsibleTower
    )
    begin {
        $Command = (Get-PSCallStack)[1].Command
    }
    process {
        $JsonString = ConvertTo-Json $InputObject
        $AnsibleObject = [AnsibleTower.JsonFunctions]::ParseTogroup($JsonString)
        $AnsibleObject.AnsibleTower = $AnsibleTower
        $CacheKey = "groups/$($AnsibleObject.Id)"
        Write-Debug "[$Command] Caching $($AnsibleObject.Url) as $CacheKey"
        $AnsibleTower.Cache.Add($CacheKey, $AnsibleObject, $Script:CachePolicy) > $null
        #Add to cache before filling in child objects to prevent recursive loop
        if($AnsibleObject.Inventory) {
            $AnsibleObject.Inventory = Get-AnsibleInventory -Id $AnsibleObject.Inventory -AnsibleTower $AnsibleTower -UseCache
        }
        $VariableData = Invoke-AnsibleRequest -Fullpath $AnsibleObject.Related["variable_data"] -AnsibleTower $AnsibleTower
        $VariableJson = ConvertTo-Json $VariableData -Depth 32
        $AnsibleObject.Variables = [Newtonsoft.Json.JsonConvert]::DeserializeObject($VariableJson, [hashtable], (New-Object AnsibleTower.HashtableConverter))
        Write-Debug "[$Command] Returning $($AnsibleObject.Url)"
        $AnsibleObject
    }
}