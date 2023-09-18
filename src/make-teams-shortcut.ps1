## Standard Paths
$MDM_home = $(Join-Path $env:ProgramData MDM)
$MDM_logs = $(Join-Path $MDM_home logs)
$MDM_data = $(Join-Path $MDM_home data)

## App/Usage related
$pkg_name = "make-teams-shortcut"
$current_log = "$MDM_logs\$pkg_name.log"

## Testing winget directorys
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


$exe = "$env:USERPROFILE\AppData\Local\Microsoft\Teams\current\Teams.exe"
Write-Host "Path to executable: $exe"
$WshShell = New-Object -comObject WScript.Shell
$desktop = $(Join-Path $env:USERPROFILE "Desktop")
$link = $(Join-Path $desktop Teams.lnk)
Write-Host "Shortcut path: $link"
Write-Host "Making a shortcut to the desktop..."
$Shortcut = $WshShell.CreateShortcut($link)
$Shortcut.TargetPath = $exe
$Shortcut.Save()
Write-Output "Finishing the Script!"
Stop-Transcript

