#Create resource group
New-AzResourceGroup -Name 'myResourceGroup' -Location 'eastus'

#Create virtual machine
New-AzVm -ResourceGroupName 'myResourceGroup' -Name 'myVM' -Location 'eastus' -Image 'MicrosoftWindowsServer:WindowsServer:2022-datacenter-azure-edition:latest' -VirtualNetworkName 'myVnet' -SubnetName 'mySubnet' -SecurityGroupName 'myNetworkSecurityGroup' -PublicIpAddressName 'myPublicIpAddress' -OpenPorts 80,3389

# Install web server
Invoke-AzVMRunCommand -ResourceGroupName 'myResourceGroup' -VMName 'myVM' -CommandId 'RunPowerShellScript' -ScriptString 'Install-WindowsFeature -Name Web-Server -IncludeManagementTools'

#Clean up resources
#Remove-AzResourceGroup -Name 'myResourceGroup'