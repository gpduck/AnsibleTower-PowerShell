function Reload-AWX {
    param(
        $Url,
        $Password
    )
    tower-cli config host $Url
    tower-cli config verify_ssl false
    tower-cli login --password $Password admin
    "YES" | tower-cli empty --all
    tower-cli send $PSScriptRoot/States/Initial.json
}

function Get-RandomString {
    [Guid]::NewGuid().ToString().Substring(0, 25)
}

function Get-AnsibleCredential {
    param(
        $Password
    )
    $PasswordSS = ConvertTo-SecureString -ASPlainText $Password -Force
    New-Object System.Management.Automation.PSCredential("admin", $PasswordSS)
}