# appvolumes-expand-wv
Batch Expand Size of VMware App Volumes Writable Volumes

.INPUTS
  Parameters Below 

.OUTPUTS
  Log file stored in %temp%\expand-wv.log>

.NOTES
  Version:  2.0 <br />
  Author:   Chris Halstead - chalstead@vmware.com <br />
  Creation Date:  9/17/2020 <br />
  Purpose/Change: Added App Volumes 4.x script<br/>

  **This script and the App Volumes API are not supported by VMware**<br />

** New sizes won't be reflected until a user logs in and attaches the Writable Volume**

------

**Expand-WV-2x.ps1 is for App Volumes 2.x**

**Expand-WV-4x.ps1 is for App Volumes 4.x**

------

.EXAMPLE
 .\Expand-WV.ps1 
        -AppVolumesServerFQDN "avmanager.company.com"
        -AppVolumesDomain "mydomain" 
        -AppVolumesUser "Username" 
        -AppVolumesPassword "SecurePassword" 
        -New_Size_In_MB "40960" 
        -Update_WV_Size "yes" 

    .PARAMETER AppVolumesServerFQDN
    The FQDN of the App Volumes Manager where you want to view / change the Writable Volumes
    
    .PARAMETER AppVolumesDomain
    Active Directory Domain of the user with Administrative access
    
    .PARAMETER AppVolumesUser
    Active Directoty User with administrative access
    
    .PARAMETER AppVolumesPassword
    The password that is used by the user specified in the username parameter
    
    .PARAMETER New_Size_In_MB
    New size for the writable volumes in Megabytes. Take gigabytes and multiply by 1024.
    
    .PARAMETER Update_WV_Size
    Enter yes to update the sizes.  Type anything else for a list of writable volumes.
