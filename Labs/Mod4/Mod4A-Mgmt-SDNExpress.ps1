$servers = @('HV1','HV2','HV3','HV4')
Invoke-Command -ComputerName $servers -ScriptBlock {
 $size = Get-PartitionSupportedSize -DriveLetter C
  Resize-Partition -DriveLetter C -Size $size.SizeMax
}


<# Within the console session to the SDNExpress2019-Management VM, 
in the Administrator: Windows PowerShell ISE window, 
open the C:\Library\Scenario.ps1 script, 
and comment out line 375 so it looks like so:
 # Expand-Archive -Path C:\SDN-Master.zip -DestinationPath C:\Library

#>
 PSEdit C:\Library\Scenario.ps1

# Step 9
 Expand-Archive -Path C:\SDN-Master.zip -DestinationPath C:\Library
 Copy-Item -Path C:\Library\SDNExpressModule.psm1 -Destination C:\Library\SDN-master\SDNExpress\scripts -Force


