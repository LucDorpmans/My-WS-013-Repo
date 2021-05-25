# GetMy-WS013-Scripts.ps1
Function Get-MyScript { Param( [string]$AScript,[string]$SPath = "$env:USERPROFILE\Downloads\")
			Invoke-Webrequest -Uri "https://raw.githubusercontent.com/LucDorpmans/My-WS-013-Repo/main/$AScript"  -Outfile "$SPath$AScript" 
			PSEdit  ($SPath$MyScript")}

Get-MyScript "Chrome-Download+Run-Installer.ps1"
Get-MyScript "WAC-Download+Install.ps1"
Get-MyScript "EdgeMSI-Download-Only-Complete.ps1"
Get-MyScript "Edge-InstallOnly.ps1"