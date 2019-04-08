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
 .\Tag-SCCM-Collections.ps1 `
        -SCCMCollectionName "All"
        -AirwatchServer "https://airwatch.company.com" `
        -AirwatchUser "Username" `
        -AirwatchPW "SecurePassword" `
        -AirwatchAPIKey "iVvHQnSXpX5elicaZPaIlQ8hCe5C/kw21K3glhZ+g/g=" `
        -AWOrganizationGroupName "myogname" `

    .PARAMETER SCCMCollectionName
    The name of the SCCM Collection which you want to create a tag for.  Devices in the colelctions which exist in Airwatch will be tagged with the collection name. 
    Input All for all Device collections in SCCM.

    .PARAMETER AirwatchServer
    Server URL for the AirWatch API Server

    .PARAMETER AirwatchUser
    An AirWatch account in the tenant is being queried.  This user must have the API role at a minimum.

    .PARAMETER AirwatchPW
    The password that is used by the user specified in the username parameter

    .PARAMETER AirwatchAPIKey
    This is the REST API key that is generated in the AirWatch Console.  You locate this key at All Settings -> Advanced -> API -> REST,
    and you will find the key in the API Key field.  If it is not there you may need override the settings and Enable API Access

    .PARAMETER AWOrganizationGroupName
    The name of the Organization Group where the device will be registered. 
#>

[CmdletBinding()]
    Param(

        [Parameter(Mandatory=$True)]
        [string]$AppVolumesServerFQDN,
           
        [Parameter(Mandatory=$True)]
        [string]$AppVolumesDomain,

        [Parameter(Mandatory=$True)]
        [string]$AppVolumesUser,

        [Parameter(Mandatory=$True)]
        [securestring]$AppVolumesPassword,
       
        [Parameter(Mandatory=$true)]
        [string]$New_Size_In_MB,

        [Parameter(Mandatory=$true)]
        [string]$Update_WV_Size

)

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

$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($AppVolumesPassword)
$UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

$Credentials = @{
  username = "$AppVolumesDomain\$appvolumesuser"
  password = $UnsecurePassword
}

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

Write-Host "Logging on to App Volumes Manager"
try{$sresult = Invoke-RestMethod -Method Post -Uri "https://$AppVolumesServerFQDN/cv_api/sessions" -Body $Credentials -SessionVariable avsession}
catch {
  Write-Host "An error occurred when logging on $_"
  Add-Content $sLogFile -Value "Error when logging on to AppVolumes Manager: $_"
  Add-Content $sLogFile -Value "Finishing Script******************************************************"
  exit 
}

Add-Content $sLogFile -Value "Logging on to AppVolumes Manager: $sresult"
$sgetwv = Invoke-RestMethod -WebSession $avsession -Method Get -Uri "https://$AppVolumesServerFQDN/cv_api/writables" -ContentType 'application/json'

$json = $sgetwv.datastores.writable_volumes

    foreach ($item in $json)
    {

    Write-Host $item.id $item.name $item.total_mb $item.attached

    If ($Update_WV_Size -eq "YES") {
          
      $avid = $item.id
      Write-Host "Update Sizes"
      try{$supdatesize = Invoke-RestMethod -WebSession $avsession -Method Post -Uri "https://$AppVolumesServerFQDN/cv_api/writables/grow?bg=0&size_mb=$New_Size_In_MB&volumes%5B%5D=$avid" -ContentType 'application/json'}
      catch {
        Write-Host "An error occurred when increasing size $_"
      }
      write-host $supdatesize

      }  
    }


  } 


#-----------------------------------------------------------[Execution]------------------------------------------------------------
#Logon to App Volumes
Connect_AV

Add-Content $sLogFile -Value "Finishing Script******************************************************"