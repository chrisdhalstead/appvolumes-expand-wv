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

$Credentials = @{
  username = 'vmweuc\chalstead'
  password = 'Sp**dR@cer19'
}
$json = $Credentials | ConvertTo-Json

$sAVSession = ""
$sAppVolumesServer = "s1-avm1.vmweuc.com"

#-----------------------------------------------------------[Functions]------------------------------------------------------------

<

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


>

Function AV_Logon {

$response = Invoke-RestMethod -uri 'https://s1-avm1.vmweuc.com/cv_api/sessions' -Method Post -Body $json -ContentType 'application/json'

Write-Log -Message "Logging on to AppVolumes" $response

}





#-----------------------------------------------------------[Execution]------------------------------------------------------------

$response = Invoke-RestMethod -uri 'https://s1-avm1.vmweuc.com/cv_api/sessions' -SessionVariable $ssession -Method Post -Body $json -ContentType 'application/json'


Add-Content $sLogFile -Value "Finishing Script******************************************************"