<#
.Description
This is a sample script for creating a sensitive information type based on a document fingerprint.
Please use caution with this script, there are no guarantees provided with this script. Perform testing and validation as needed before using this.
.PARAMETER TemplateName 
Name of the file template that will be used

.PARAMETER FileName
Path to the file to create a template of

.PARAMETER FingerprintName
Name of the fingerprint that will be used

.PARAMETER FingerprintDescription
Description for the fingerprint

.PARAMETER SITNAME
Name of the Sensitive Information Type, this will be used in Purview for creating DLP policies. This will need to be unique from all other SITs that you have.

.PARAMETER SITDescription
Description of the Sensitive Information Type
#>

param([Parameter(Position=0,mandatory=$true)][string]$TemplateName, [Parameter(Position=1,mandatory=$true)][string]$FileName, 
[Parameter(Position=2,mandatory=$true)][string]$FingerprintName, [Parameter(Position=3,mandatory=$true)][string]$FingerprintDescription, 
[Parameter(Position=4,mandatory=$true)][string]$SITName, [Parameter(Position=5,mandatory=$true)][string]$SITDescription) 


Write-Output "Connecting to Security & Compliance PowerShell"
try{
    Connect-IPPSSession
}
catch{
    "Unable to connect to Security and compliance PS"
}

Write-Output "Creating template from file"
try{
    New-Variable -Name $TemplateName -Value ([System.IO.File]::ReadAllBytes($FileName))
    $tempt = Get-Variable -name $TemplateName -ValueOnly
}
catch{
    "Unable to create Template, check file and naming"
}

Write-Output "Creating fingerprint from template"
try{
    $tempf = New-DlpFingerprint -FileData $tempt -Description $FingerprintDescription
    New-Variable -Name $FingerprintName -Value $tempf
}
catch{
    "Unable to create fingerprint"
}

Write-Output "Creating Sensitive Information Type"
try{
    $sname = $SITName
    $fingerprint = Get-Variable -name $FingerprintName -ValueOnly
    New-DlpSensitiveInformationType -Name $sname -Fingerprints $fingerprint -Description $SITDescription
}
catch{
    "Unable to create information type"
}

Write-Output "Disconnecting from Security & Compliance PowerShell"
Disconnect-ExchangeOnline
