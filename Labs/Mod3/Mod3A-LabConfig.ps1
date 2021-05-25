$LabConfig = @{ DomainAdminName = 'LabAdmin'; AdminPassword = 'LS1setup!'; Prefix = 'WSLab-'; SwitchName = 'LabSwitch'; DCEdition = '4'; Internet = $true; AdditionalNetworksConfig = @(); VMs = @() }
1..4 | ForEach-Object {
    $VMNames = "S2D";
    $LABConfig.VMs += @{
        VMName             = "$VMNames$_";
        Configuration      = 'S2D';
        ParentVHD          = 'Win2019Core_G2.vhdx';
        HDDNumber          = 8;
        HDDSize            = 4TB;
        MemoryStartupBytes = 4GB;
        StaticMemory       = $True;
        NestedVirt         = $True;
        VMProcessorCount   = 2
    }
}
$LabConfig.VMs += @{
    VMName             = 'Management' ;
    Configuration      = 'Simple';
    ParentVHD          = 'Win2019_G2.vhdx';
    StaticMemory       = $true;
    MemoryStartupBytes = 8GB;
    AddToolsVHD        = $True;
    DisableWCF         = $True;
    VMProcessorCount   = 4
}