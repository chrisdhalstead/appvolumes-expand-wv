<#
.SYNOPSIS
  <Overview of script>

.DESCRIPTION
  <Brief description of script>

.PARAMETER <Parameter_Name>
    <Brief description of parameter input required. Repeat this attribute if required>

.INPUTS
  <Inputs if any, otherwise state None>

.OUTPUTS
  <Outputs if any, otherwise state None - example: Log file stored in C:\Windows\Temp\<name>.log>

.NOTES
  Version:        1.0
  Author:         Chris Halstead - chalstead@vmware.com
  Creation Date:  4/8/2019
  Purpose/Change: Initial script development
  
.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>
#>

#---------------------------------------------------------[Initialize]--------------------------------------------------------

#Set Error Action to Silently Continue
#$ErrorActionPreference = "SilentlyContinue"

#----------------------------------------------------------[Declarations]----------------------------------------------------------
#Log File Info
$sLogPath = $env:TEMP 
$sDomain = $env:USERDOMAIN
$sUser = $env:USERNAME
$sComputer = $env:COMPUTERNAME
$sLogName = "expand-wv.log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName
$sLogTitle = "Starting Script as $sdomain\$sUser from $scomputer***************"
Add-Content $sLogFile -Value $sLogTitle
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$cookiejar = New-Object System.Net.CookieContainer 


$Credentials = @{
  username = 'vmweuc\chalstead'
  password = 'Sp**dR@cer19'
}
$sAppVolumesServer = "s1-avm1.vmweuc.com"

#-----------------------------------------------------------[Functions]------------------------------------------------------------
Function Write-Log {
    [CmdletBinding()]
    Param(
    
    [Parameter(Mandatory=$False)]
    [ValidateSet("INFO","WARN","ERROR","FATAL","DEBUG")]
    [String]
    $Level = "INFO",

    [Parameter(Mandatory=$True)]
    [string]
    $Message

    )
    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $Line = "$Stamp $Level $Message"
    Add-Content $sLogFile -Value $Line
   
    }

Function Connect_AV {

try{$sresult = Invoke-RestMethod -Method Post -Uri "https://s1-avm.vmweuc.com/cv_api/sessions" -Body $Credentials -SessionVariable avsession}
catch {
  Write-Host "An error occurred when logging on"
  Add-Content $sLogFile -Value "Error when logging on to AppVolumes Manager: $_"
  Add-Content $sLogFile -Value "Finishing Script******************************************************"
  exit 
}

Add-Content $sLogFile -Value "Logging on to AppVolumes Manager: $sresult"
$sgetwv = Invoke-RestMethod -WebSession $avsession -Method Get -Uri "https://s1-avm.vmweuc.com/cv_api/writables" -ContentType 'application/json' 

$json = $sgetwv.datastores.writable_volumes

foreach ($name in $json.name)
{
  Write-Host $name
}



}

#-----------------------------------------------------------[Execution]------------------------------------------------------------
#Logon to App Volumes
Connect_AV

Add-Content $sLogFile -Value "Finishing Script******************************************************"