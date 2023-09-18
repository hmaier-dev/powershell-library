
## Standard Paths
$MDM_home = $(Join-Path $env:ProgramData MDM)
$MDM_logs = $(Join-Path $MDM_home logs)
$MDM_data = $(Join-Path $MDM_home data)

## App/Usage related
$pkg_name = "turn-off-autostart"
$current_log = "$MDM_logs\$pkg_name.log"

## Testing MDM directorys
if (!(Test-Path $MDM_logs))
{
  New-Item -Path $MDM_logs -ItemType Directory -Force -Confirm:$false
}
if (!(Test-Path $MDM_data))
{
  New-Item -Path $MDM_data -ItemType Directory -Force -Confirm:$false
}

## Starting point of the actual logic
Start-Transcript -Path $current_log -Force

# Define the path to the registry key for WebEx auto-start
$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
# Specify the name of the WebEx entry (change this to match your specific WebEx installation)
$webexEntryName = "CiscoSpark"
Remove-ItemProperty -Path $registryPath -Name $webexEntryName

# If this Get- fails the Removal was successful
Get-ItemProperty -Path $registryPath -Name $webexEntryName

Stop-Transcript
## End Point
