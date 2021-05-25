Get-ChildItem -Path F:\WSLab-master\ -File -Recurse | Unblock-File

Set-Location -Path F:\WSLab-master\Scripts

Move-Item -Path '.\LabConfig.ps1' -Destination '.\LabConfig.m3l1.ps1' -Force -ErrorAction SilentlyContinue

