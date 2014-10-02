$AnsibleUrl = $null
$AnsibleCredential = $null


#Load Json
$NewtonSoftJsonPath = join-path $PSScriptRoot "AnsibleTower (c# project)\AnsibleTower\AnsibleTower\bin\Debug\Newtonsoft.Json.dll"
add-type -Path $NewtonSoftJsonPath

#Compile the .net classes
$ClassPath = Join-Path $PSScriptRoot "AnsibleTower (c# project)\AnsibleTower\AnsibleTower\DataTypes.cs"
#$ClassPath2 = Join-Path $PSScriptRoot "AnsibleTower (c# project)\AnsibleTower\AnsibleTower\JsonParsers.cs"
$Code = Get-Content -Path $ClassPath -Raw
#$Code2 = Get-Content -Path $ClassPath2 -Raw

if (!(get-type -type "AnsibleTower.Organization" -ErrorAction 0))
{
    add-type -TypeDefinition $Code -ReferencedAssemblies $NewtonSoftJsonPath
}


#Load the json parsers to have it handy whenever.
$JsonParsers = New-Object AnsibleTower.JsonParsers


Function Get-AnsibleInternalJsonResult
{
    Param ($AnsibleUrl=$AnsibleUrl,[System.Management.Automation.PSCredential]$Credential=$AnsibleCredential,$ItemType,$Id)
    $Result = Invoke-RestMethod -Uri ($AnsibleUrl + "/api/v1/") -Credential $Credential
    $ItemApiUrl = $result.$ItemType
    if ($id)
    {
        $ItemApiUrl += "$id/"
    }

    $InvokeResult = @()
    $invokeresult += Invoke-RestMethod -Uri ($ansibleurl + $ItemApiUrl) -Credential $Credential 

    if ($InvokeResult.count -gt 0)
    {
        return $InvokeResult
    }

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
    
    }
    
    #Code for error-handling goes here

    #If we got this far, we could connect. Go ahead and get a session ticket
    
    #Set the global connection var
    #$MDwebapiurl = $WebApiUrl
    set-variable -Name AnsibleUrl -Value $TowerUrl -Scope 1
    
    set-variable -Name AnsibleCredential -Value $Credential -Scope 1

}


function Get-AnsibleOrganization
{
    Param (
        [String]$Name,
        [int]$id
    )

    $Return = Get-AnsibleInternalJsonResult -ItemType "organizations" -Id $id

    if (!($Return))
    {
        #Nothing returned from the call
        Return
    }
    $returnobj = @()
    foreach ($jsonorg in $return.results)
    {
        #Shift back to json and let newtonsoft parse it to a strongly named object instead
        $jsonorgstring = $jsonorg | ConvertTo-Json
        $org = $JsonParsers.ParseToOrganization($jsonorgstring)
        $returnobj += $org; $org = $null

    }
    #return the things
    $returnobj
}

