# GetMy-WS013-Scripts-Short.ps1
Function Get-MyScript { Param( [string]$AFile,[switch]$EditFile = $False, 
							   [string]$SPath = "$env:USERPROFILE\Downloads\")
			Invoke-Webrequest -Uri "https://raw.githubusercontent.com/LucDorpmans/My-WS-013-Repo/main/$AFile"  -Outfile "$SPath$AFile" }

Get-MyScript "Chrome-Download+Run-Installer.ps1" -EditFile
Get-MyScript "WAC-Download+Install.ps1" -EditFile
Get-MyScript "EdgeMSI-DownloadComplete.ps1"
Get-MyScript "Edge-InstallOnly.ps1"
