configuration AzSHciHost
{
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'

    node localhost
    {
        LocalConfigurationManager {
            RebootNodeIfNeeded = $true
            ActionAfterReboot  = 'ContinueConfiguration'
            ConfigurationMode = 'ApplyAndAutoCorrect'
            ConfigurationModeFrequencyMins = 1440
        }

        WindowsFeatureSet "AzsHci Required Roles"
        {
            Ensure = 'Present'
            Name = @("File-Services", "FS-FileServer", "FS-Data-Deduplication", "BitLocker", "Data-Center-Bridging", "EnhancedStorage", "Failover-Clustering", "RSAT", "RSAT-Feature-Tools", "RSAT-DataCenterBridging-LLDP-Tools", "RSAT-Clustering", "RSAT-Clustering-PowerShell", "RSAT-Role-Tools", "RSAT-AD-Tools", "RSAT-AD-PowerShell", "RSAT-Hyper-V-Tools", "Hyper-V-PowerShell")
        }
    }
}

$date = get-date -f yyyy-MM-dd
$logFile = Join-Path -Path "C:\temp" -ChildPath $('AzSHciHost-Transcipt-' + $date + '.log')
$DscConfigLocation = "c:\temp\AzSHciHost"

Start-Transcript -Path $logFile

Remove-DscConfigurationDocument -Stage Current, Previous, Pending -Force

AzSHciHost -OutputPath $DscConfigLocation 

Set-DscLocalConfigurationManager -Path $DscConfigLocation -Verbose

Start-DscConfiguration -Path $DscConfigLocation -Wait -Verbose

Stop-Transcript

Logoff
