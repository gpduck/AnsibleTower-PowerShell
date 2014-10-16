function Get-AnsibleJobTemplate
{
    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [int]$id
    )

    if ($id)
    {
        $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "job_templates" -Id $id
    }
    Else
    {
        $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "job_templates"
    }
    

    if (!($Return))
    {
        #Nothing returned from the call
        Return
    }
    $returnobj = @()
    foreach ($jsonorg in $return)
    {
        #Shift back to json and let newtonsoft parse it to a strongly named object instead
        $jsonorgstring = $jsonorg | ConvertTo-Json
        $org = $JsonParsers.ParseToJobTemplate($jsonorgstring)
        $returnobj += $org; $org = $null

    }
    #return the things
    $returnobj
}


function Invoke-AnsibleJobTemplate
{
    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
        [int]$id
    )

    $ThisJobTemplate = Get-AnsibleJobTemplate -id $id

    if (!$ThisJobTemplate) {Write-Error "No Job template with id $id"; return}

    $result = Invoke-PostAnsibleInternalJsonResult -ItemType "job_templates" -itemId $id -ItemSubItem "jobs"
    $JobId = $result.id
    $job = get-ansibleJob -id $JobId
    $job
}


