function Get-AnsibleJob
{
    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [int]$id
    )

    if ($id)
    {
        $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "jobs" -Id $id
    }
    Else
    {
        $Return = Invoke-GetAnsibleInternalJsonResult -ItemType "jobs"
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
        $org = $JsonParsers.ParseToJob($jsonorgstring)
        $returnobj += $org; $org = $null

    }
    #return the things
    $returnobj
}

function Invoke-AnsibleJob
{
    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipelineByPropertyName=$true,Mandatory=$true,ParameterSetName='ByObj')]
        [AnsibleTower.JobTemplate]$JobTemplate,

        [Parameter(ValueFromPipelineByPropertyName=$true,Mandatory=$true,ParameterSetName='ById')]
        [int]$id
    )

    if ($JobTemplate)
    {
        $ThisJobTemplate = $JobTemplate
        $id = $ThisJobTemplate.id
    }
    Else
    {
        $ThisJobTemplate = Get-AnsibleJobTemplate -id $id
    }
    

    if (!$ThisJobTemplate) {Write-Error "No Job template with id $id"; return}

    Write-Verbose "Submitting job from template $id"
    $result = Invoke-PostAnsibleInternalJsonResult -ItemType "job_templates" -itemId $id -ItemSubItem "jobs"
    $JobId = $result.id
    Write-Verbose "Starting job with jobid $jobid"
    $result = Invoke-PostAnsibleInternalJsonResult -ItemType "jobs" -itemId $JobId -ItemSubItem "start"
    $job = get-ansibleJob -id $JobId
    $job
}

