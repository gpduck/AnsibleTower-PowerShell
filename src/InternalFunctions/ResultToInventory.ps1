function ResultToInventory {
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
        $AnsibleObject = [AnsibleTower.JsonFunctions]::ParseToinventory($JsonString)
        $AnsibleObject.AnsibleTower = $AnsibleTower
        $CacheKey = "inventory/$($AnsibleObject.Id)"
        Write-Debug "[$Command] Caching $($AnsibleObject.Url) as $CacheKey"
        $AnsibleTower.Cache.Add($CacheKey, $AnsibleObject, $Script:CachePolicy) > $null
        #Add to cache before filling in child objects to prevent recursive loop
        $Groups = Invoke-GetAnsibleInternalJsonResult -ItemType "inventory" -Id $AnsibleObject.Id -ItemSubItem "groups" -AnsibleTower $AnsibleTower
        $AnsibleObject.Groups = New-Object "System.Collections.Generic.List[AnsibleTower.Group]"
        foreach($Group in $Groups) {
            $GroupObj = Get-AnsibleGroup -Id $Group.Id -AnsibleTower $AnsibleTower -UseCache
            $AnsibleObject.Groups.Add($GroupObj)
        }
        if($AnsibleObject.Organization) {
            $AnsibleObject.Organization = Get-AnsibleOrganization -Id $AnsibleObject.Organization -AnsibleTower $AnsibleTower -UseCache
        }
        $VariableData = Invoke-AnsibleRequest -Fullpath $AnsibleObject.Related["variable_data"] -AnsibleTower $AnsibleTower
        $VariableJson = ConvertTo-Json $VariableData -Depth 32
        $AnsibleObject.Variables = [Newtonsoft.Json.JsonConvert]::DeserializeObject($VariableJson, [hashtable], (New-Object AnsibleTower.HashtableConverter))
        Write-Debug "[$Command] Returning $($AnsibleObject.Url)"
        $AnsibleObject
    }
}
