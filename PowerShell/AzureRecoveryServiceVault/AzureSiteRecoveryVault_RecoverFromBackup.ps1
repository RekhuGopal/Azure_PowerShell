# Retrieve the Recovery Services Vault
$targetVault = Get-AzRecoveryServicesVault -ResourceGroupName "myResourceGroup" -Name "testvault"

# Set the vault context
$targetVault | Set-AzRecoveryServicesVaultContext

# Find the backup item
$container = Get-AzRecoveryServicesBackupContainer -ContainerType "AzureVM" -FriendlyName "myVM" -VaultId $targetVault.ID
$item = Get-AzRecoveryServicesBackupItem -Container $container -WorkloadType "AzureVM" -VaultId $targetVault.ID

# Get the recovery points for the backup item
$recoveryPoints = Get-AzRecoveryServicesBackupRecoveryPoint -Item $item -VaultId $targetVault.ID

# Select the most recent recovery point
$latestRecoveryPoint = $recoveryPoints | Sort-Object -Property RecoveryPointTime -Descending | Select-Object -First 1

# Start the restore process
Restore-AzRecoveryServicesBackupItem  `
-VaultId $targetVault.ID `
-RecoveryPoint $latestRecoveryPoint `
-TargetResourceGroupName "myResourceGroup" `
-StorageAccountName "cloudquicklabssabackup" `
-TargetVmName "restoredVM" `
-TargetVNetName "myVnet" `
-TargetVNetResourceGroup "myResourceGroup" `
-TargetSubnetName "mySubnet" `
-StorageAccountResourceGroupName "myResourceGroup"