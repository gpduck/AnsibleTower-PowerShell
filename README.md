AnsibleTower-PowerShell
=======================

Powershell cmdlets for interacting with Ansible Tower.

Example:
```
Connect-AnsibleTower -Credential (Get-Credential) -TowerUrl 'https://ansible.domain.local' -DisableCertificateVerification;
$JobTemplateName = 'Demo Job Template';
$job = Invoke-AnsibleJobTemplate $JobTemplateName | Wait-AnsibleJob -Interval 5 -Timeout 60
if ($job.failed -eq $true) {
    throw ("Ansible job template [{0}] failed." -f $JobTemplateName);
}
```

