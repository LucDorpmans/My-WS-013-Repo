# Download and install Windows Admin Center
Write-Verbose "Download WindowsAdminCenter.msi" 
$progressPreference='SilentlyContinue'
Invoke-WebRequest -UseBasicParsing -Uri https://aka.ms/WACDownload -OutFile "$env:USERPROFILE\Downloads\WindowsAdminCenter.msi"
Write-Verbose "Starting Installation of WindowsAdminCenter.msi" 
Start-Process msiexec.exe -Wait -ArgumentList "/i $env:USERPROFILE\Downloads\WindowsAdminCenter.msi /qn /L*v waclog.txt REGISTRY_REDIRECT_PORT_80=1 SME_PORT=443 SSL_CERTIFICATE_OPTION=generate"
Write-Verbose "Finished Installation of WindowsAdminCenter.msi" 
