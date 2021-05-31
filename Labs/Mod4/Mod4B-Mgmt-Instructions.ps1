# C:\Library\Github\LabsMod4\Mod4B-Mgmt-Instructions.ps1


<#
Get-WindowsFeature *controller*
Get-WindowsFeature RSAT*
#>

<# ClusterName:
sddc01.corp.contoso.com
#>

<# In the Windows Admin Center interface, add a connection to the sddc01.corp.contoso.com cluster 
# and the Network Controller REST URI at https://NCCLUSTER.corp.contoso.com. If prompted, authenticate by using the CORP\LabAdmin and LS1setup! credentials.
https://NCCLUSTER.corp.contoso.com.
#>


<#
Table 1: vnet-000 settings

Setting	Value
Name	vnet-000
Address Prefix	192.168.0.0/20
Table 2: vnet-000 subnet-0 settings

Setting	Value
Name	subnet-0
Address Prefix	192.168.0.0/24
Table 3: vnet-000 subnet-1 settings

Setting	Value
Name	subnet-1
Address Prefix	192.168.1.0/24
Table 4: vnet-100 settings

Setting	Value
Name	vnet-100
Address Prefix	192.168.96.0/20
Table 5: vnet-100 subnet-0 settings

Setting	Value
Name	subnet-0
Address Prefix	192.168.100.0/24
#>