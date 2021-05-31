# C:\Library\Github\LabsMod4\Mod4A-Mgmt-Instructions.ps1

$servers = @('HV1','HV2','HV3','HV4')
Invoke-Command -ComputerName $servers -ScriptBlock {
  $size = Get-PartitionSupportedSize -DriveLetter C
  Resize-Partition -DriveLetter C -Size $size.SizeMax
}

New-Item F:\Allfiles -itemtype directory -Force
Invoke-Webrequest -Uri "https://raw.githubusercontent.com/MicrosoftLearning/WS-013T00-Azure-Stack-HCI/master/Allfiles/SDNExpressModule.psm1" -Outfile "F:\Allfiles\SDNExpressModule.psm1"

Expand-Archive -Path C:\SDN-Master.zip -DestinationPath C:\Library
Copy-Item C:\Library\SDNExpressModule.psm1 C:\Library\SDN-master\SDNExpress\scripts -Force

