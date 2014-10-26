$AnsibleUrl = $null
$AnsibleCredential = $null


#Load Json
$NewtonSoftJsonPath = join-path $PSScriptRoot "AnsibleTowerClasses\AnsibleTower\AnsibleTower\bin\Debug\Newtonsoft.Json.dll"
add-type -Path $NewtonSoftJsonPath

#Compile the .net classes
$ClassPath = Join-Path $PSScriptRoot "AnsibleTowerClasses\AnsibleTower\AnsibleTower\DataTypes.cs"
#$ClassPath2 = Join-Path $PSScriptRoot "AnsibleTower (c# project)\AnsibleTower\AnsibleTower\JsonParsers.cs"
$Code = Get-Content -Path $ClassPath -Raw
#$Code2 = Get-Content -Path $ClassPath2 -Raw

add-type -TypeDefinition $Code -ReferencedAssemblies $NewtonSoftJsonPath

#Load the json parsers to have it handy whenever.
$JsonParsers = New-Object AnsibleTower.JsonFunctions


#Dot-source/Load the other powershell scripts
Get-ChildItem "*.ps1" -path $PSScriptRoot | where {$_.Name -notmatch "test"} |  ForEach-Object { . $_.FullName }

Function Invoke-GetAnsibleInternalJsonResult
{
    Param ($AnsibleUrl=$AnsibleUrl,
    [System.Management.Automation.PSCredential]$Credential=$AnsibleCredential,
    $ItemType,
    $Id,
    $ItemSubItem)

    if ((!$AnsibleUrl) -or (!$Credential))
    {
        throw "You need to connect first, use Connect-AnsibleTower"
    }
    $Result = Invoke-RestMethod -Uri ($AnsibleUrl + "/api/v1/") -Credential $Credential
    $ItemApiUrl = $result.$ItemType
    if ($id)
    {
        $ItemApiUrl += "$id/"
    }

    if ($ItemSubItem)
    {
        $ItemApiUrl = $ItemApiUrl + "/$ItemSubItem/"
    }

    $ItemApiUrl = $ItemApiUrl.Replace("//","/")

    $invokeresult = Invoke-RestMethod -Uri ($ansibleurl + $ItemApiUrl) -Credential $Credential 

    if ($InvokeResult.id)
    {
        return $InvokeResult
    }
    Elseif ($InvokeResult.results)
    {
        return $InvokeResult.results
    }

}

Function Invoke-PostAnsibleInternalJsonResult
{
    Param (
        $AnsibleUrl=$AnsibleUrl,
        [System.Management.Automation.PSCredential]$Credential=$AnsibleCredential,
        $ItemType,
        $itemId,
        $ItemSubItem,
        $InputObject)

    if ((!$AnsibleUrl) -or (!$Credential))
    {
        throw "You need to connect first, use Connect-AnsibleTower"
    }
    $Result = Invoke-RestMethod -Uri ($AnsibleUrl + "/api/v1/") -Credential $Credential
    $ItemApiUrl = $result.$ItemType
    
    if ($itemId)
    {
        $ItemApiUrl = $ItemApiUrl + "$itemId"
    }

    if ($ItemSubItem)
    {
        $ItemApiUrl = $ItemApiUrl + "/$ItemSubItem/"
    }
    $Params = @{
        "uri"=($ansibleurl + $ItemApiUrl);
        "Credential"=$Credential;
        }
    if ($InputObject)
    {
        $params.Add("Body",($InputObject | ConvertTo-Json -Depth 99))
    }
    
    Write-Debug "Credentials are: $($credential.UserName)"
    Write-Debug "Invoking call with body: $($InputObject | ConvertTo-Json -Depth 99)"
    $invokeresult += Invoke-RestMethod -Method Post -ContentType "application/json" @params
    $invokeresult

}

Function Invoke-PutAnsibleInternalJsonResult
{
    Param (
        $AnsibleUrl=$AnsibleUrl,
        [System.Management.Automation.PSCredential]$Credential=$AnsibleCredential,
        $ItemType,$InputObject
    )

    if ((!$AnsibleUrl) -or (!$Credential))
    {
        throw "You need to connect first, use Connect-AnsibleTower"
    }
    $Result = Invoke-RestMethod -Uri ($AnsibleUrl + "/api/v1/") -Credential $Credential
    $ItemApiUrl = $result.$ItemType
    if (!($id))
    {
        Write-Error "I couldnt find the id of that object"
        return
    }
    $id = $InputObject.id

    $ItemApiUrl += "$id/"
    

    $invokeresult += Invoke-RestMethod -Uri ($ansibleurl + $ItemApiUrl) -Credential $Credential -Method Put -Body ($InputObject | ConvertTo-Json -Depth 99) -ContentType "application/json"
    $invokeresult

}

Function Connect-AnsibleTower
{
    Param (
        [System.Management.Automation.PSCredential]$Credential,
        [string]$TowerUrl,
        [Switch]$DisableCertificateVerification
    )

    if ($DisableCertificateVerification)
    {
        #Danm you, here-strings for messing up my indendation!!
        add-type @" 
    using System.Net; 
    using System.Security.Cryptography.X509Certificates; 
     
    public class NoSSLCheckPolicy : ICertificatePolicy { 
        public NoSSLCheckPolicy() {} 
        public bool CheckValidationResult( 
            ServicePoint sPoint, X509Certificate cert, 
            WebRequest wRequest, int certProb) { 
            return true; 
        } 
    } 
"@ 
        [System.Net.ServicePointManager]::CertificatePolicy = new-object NoSSLCheckPolicy 
    }

    #Try and figure out what address we were given

    if ($TowerUrl -match "/api/")
    {
        throw "Specify the URL without the /api part"    
    }
    Else
    {
        $TestUrl = $TowerUrl + "/api/"
    }

    #$towerurl = $TowerUrl.Replace("//","/")

    try
    {
        $result = Invoke-RestMethod -Uri $TestUrl -ErrorAction Stop
    }
    catch
    {
       Throw "That didn't work at all"
    }
    
    #Get the version
    $TowerVersion = $result.current_version
    $TowerApiUrl = $TowerUrl + $TowerVersion

    #Try to log on
    $MeUri = $TowerApiUrl + "me/"
    try
    {
        $MeResult = Invoke-RestMethod -Uri $MeUri -Credential $Credential -ErrorAction Stop
    }
    Catch
    {
        throw "Could not authenticate"
    }
    
    #Code for error-handling goes here

    #If we got this far, we could connect. Go ahead and get a session ticket
    
    #Set the global connection var
    #$MDwebapiurl = $WebApiUrl
    set-variable -Name AnsibleUrl -Value $TowerUrl -Scope 1
    
    set-variable -Name AnsibleCredential -Value $Credential -Scope 1

}


