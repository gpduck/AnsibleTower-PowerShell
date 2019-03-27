function ResultToProject {
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
        $AnsibleObject = [AnsibleTower.JsonFunctions]::ParseToProject($JsonString)
        $AnsibleObject.AnsibleTower = $AnsibleTower
        $CacheKey = "projects/$($AnsibleObject.Id)"
        Write-Debug "[$Command] Caching $($AnsibleObject.Url) as $CacheKey"
        $AnsibleTower.Cache.Add($CacheKey, $AnsibleObject, $Script:CachePolicy) > $null
        #Add to cache before filling in child objects to prevent recursive loop
        if($AnsibleObject.Organization) {
            $AnsibleObject.Organization = Get-AnsibleOrganization -Id $AnsibleObject.Organization -AnsibleTower $AnsibleTower -UseCache
        }
        Write-Debug "[$Command] Returning $($AnsibleObject.Url)"
        $AnsibleObject
    }
}