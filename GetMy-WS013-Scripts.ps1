# GetMy-WS013-Scripts.ps1
Function Get-MyScript 
{    [CmdletBinding()]
    Param    ( 
        [Parameter(Mandatory=$true,Position=0)]
        [string]$AScript,
        [string]$SaveLocation = "$env:USERPROFILE\Downloads\"     )
        Invoke-Webrequest -Uri "https://raw.githubusercontent.com/LucDorpmans/My-WS-013-Repo/main/$AScript"  -Outfile "$SaveLocation$AScript" 
		PSEdit  ("$env:USERPROFILE\Downloads\$MyScript") }

Get-MyScript "Chrome-Download+Run-Installer.ps1"
Get-MyScript "WAC-Download+Install.ps1"
Get-MyScript "EdgeMSI-Download-Only-Complete.ps1"
Get-MyScript "Edge-InstallOnly.ps1"

<#
# Module 2:

# Module 3:

# Module 4:
Get-MyScript Mod4A-LabVM-Instructions.ps1
Get-MyScript Mod4A-LabVM-LabConfig.ps1
Get-MyScript Mod4A-LabVM-Scenario_Part1.ps1

Get-MyScript Mod4A-Mgmt-MultiNodeConfig.psd1
Get-MyScript Mod4A-Mgmt-SDNExpress.ps1
Get-MyScript Mod4A-Mgmt-Scenario_Part2.ps1

#>
