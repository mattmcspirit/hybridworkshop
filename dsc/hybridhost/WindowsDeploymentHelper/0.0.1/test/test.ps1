Clear-Host
#New-BasicUnattendXML -ComputerName 'wac' -LocalAdministratorPassword '123' -OutputPath .\ -Force -TimeZone 'Turkey Standard Time'

#notepad .\Unattend.xml

#Pause
#New-BasicUnattendXML -ComputerName 'wac' -LocalAdministratorPassword 'ClearTextLocalAdminPassword123' -Domain 'corp.msft.fun' -Username 'adm01' -Password 'ClearTextDomainJoinerPassword123' -JoinDomain 'corp.msft.fun' -AutoLogonCount 1 -OutputPath .\ -Force `
#    -IpCidr '192.168.0.155/24' -DnsServer '192.168.0.1' -NicNameForIPandDNSAssignments 'Ethernet'

New-BasicUnattendXML -ComputerName 'wac' -LocalAdministratorPassword 'ClearTextLocalAdminPassword123' -Domain 'corp.msft.fun' -Username 'adm' -Password 'ClearTextDomainJoinerPassword123' -JoinDomain 'corp.msft.fun' -AutoLogonCount 1 -OutputPath .\ -Force `
    -IpCidr '192.168.0.155/24' -DnsServer '192.168.0.1' -NicNameForIPandDNSAssignments 'Ethernet' -InputLocale 'tr-tr' -PowerShellScriptFullPath 'c:\temp\Install-WacUsingChoco.ps1' -PrintScreenOnly

#New-BasicUnattendXML -ComputerName 'wac' -LocalAdministratorPassword 'ClearTextLocalAdminPassword123' -OutputPath .\ -Force -TimeZone 'Turkey Standard Time' -AutoLogonCount 1 -IpCidr '192.168.0.155/24' -DnsServer '192.168.0.1' -NicNameForIPandDNSAssignments 'Ethernet'

Stop-VM wac -TurnOff -Force
Start-Sleep -Seconds 4
remove-vm wac  -Force
remove-item V:\VMs\wac -Recurse

Start-DscConfiguration -UseExisting -Wait -Verbose

Stop-VM wac -TurnOff -Force
Get-vm wac | Get-VMNetworkAdapter -Name "Network Adapter" |    Connect-VMNetworkAdapter -SwitchName default
Get-vm wac | Get-VMNetworkAdapter -Name "wac-Management"  | Disconnect-VMNetworkAdapter
mount-vhd V:\VMs\wac\wac-OSDisk.vhdx
Copy-Item V:\source\Unattend.xml h:\windows\system32\sysprep -Force
mkdir h:\temp
Copy-Item V:\source\Install-WacUsingChoco.ps1 h:\Temp -Force
Remove-Item h:\windows\system32\configuration\pending.mof
pause
Dismount-vhd V:\VMs\wac\wac-OSDisk.vhdx

Start-VM wac