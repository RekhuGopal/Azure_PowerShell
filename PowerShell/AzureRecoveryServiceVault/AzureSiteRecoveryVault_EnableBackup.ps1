# create the Recovery Services vault
New-AzRecoveryServicesVault -Name "testvault" -ResourceGroupName "myResourceGroup" -Location "eastus"

#Set vault context
Get-AzRecoveryServicesVault -Name "testvault" -ResourceGroupName "myResourceGroup" | Set-AzRecoveryServicesVaultContext

#Fetch the vault ID
$targetVault = Get-AzRecoveryServicesVault -ResourceGroupName "myResourceGroup" -Name "testvault"
$targetVault.ID

# Modifying storage replication settings
Set-AzRecoveryServicesBackupProperty -Vault $targetVault -BackupStorageRedundancy "GeoRedundant"

# Create a protection policy
$schPol = Get-AzRecoveryServicesBackupSchedulePolicyObject -WorkloadType "AzureVM"
$UtcTime = Get-Date -Date "2024-03-2 01:00:00Z"
$UtcTime = $UtcTime.ToUniversalTime()
$schpol.ScheduleRunTimes[0] = $UtcTime

$retPol = Get-AzRecoveryServicesBackupRetentionPolicyObject -WorkloadType "AzureVM"
New-AzRecoveryServicesBackupProtectionPolicy -Name "NewPolicy" -WorkloadType "AzureVM" -RetentionPolicy $retPol -SchedulePolicy $schPol -VaultId $targetVault.ID

# Enable protection by VM name and RG
$pol = Get-AzRecoveryServicesBackupProtectionPolicy -Name "NewPolicy" -VaultId $targetVault.ID
Enable-AzRecoveryServicesBackupProtection -Policy $pol -Name "myVM" -ResourceGroupName "myResourceGroup" -VaultId $targetVault.ID

#Trigger a backup
$namedContainer = Get-AzRecoveryServicesBackupContainer -ContainerType "AzureVM" -FriendlyName "myVM" -VaultId $targetVault.ID
$item = Get-AzRecoveryServicesBackupItem -Container $namedContainer -WorkloadType "AzureVM" -VaultId $targetVault.ID
$endDate = (Get-Date).AddDays(60).ToUniversalTime()
$job = Backup-AzRecoveryServicesBackupItem -Item $item -VaultId $targetVault.ID -ExpiryDateTimeUTC $endDate

# Monitoring a backup job
$joblist = Get-AzRecoveryservicesBackupJob -Status "InProgress" -VaultId $targetVault.ID