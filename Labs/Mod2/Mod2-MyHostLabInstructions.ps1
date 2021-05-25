# Task 1
Get-ChildItem -Path F:\WSLab-master\ -File -Recurse | Unblock-File

Set-Location -Path F:\WSLab-master\Scripts

Move-Item -Path '.\LabConfig.ps1' -Destination '.\LabConfig.m2l0.ps1' -Force -ErrorAction SilentlyContinue
Move-Item -Path '.\Scenario.ps1' -Destination '.\Scenario.m2l0.ps1' -Force -ErrorAction SilentlyContinue

Copy-Item -Path 'F:\WSLab-master\Scenarios\S2D and Cloud Services Onboarding\Scenario.ps1' -Destination '.\'
Copy-Item -Path 'F:\WSLab-master\Scenarios\S2D and Cloud Services Onboarding\Labconfig.ps1' -Destination '.\'


Get-VM | Where-Object Name -ne 'WSLabOnboard-DC' | Start-VM

CORP\LabAdmin
LS1setup!

# Task 2
$VMs = @('WSLabOnboard-S2D1','WSLabOnboard-S2D2','WSLabOnboard-S2D3','WSLabOnboard-S2D4')
Stop-VM -VMName $VMs -Force

Set-VMProcessor -VMName $VMs -ExposeVirtualizationExtensions $true
Set-VM $VMs -ProcessorCount 2 -StaticMemory -MemoryStartupBytes 4GB
Start-VM -VMName $VMs

