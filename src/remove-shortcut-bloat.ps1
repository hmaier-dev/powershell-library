## Standard Paths
$MDM_home = $(Join-Path $env:ProgramData MDM)
$MDM_logs = $(Join-Path $MDM_home logs)
$MDM_data = $(Join-Path $MDM_home data)

## App/Usage related
$pkg_name = "remove-unnecessary-shortcuts"
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

$public = "C:\Users\Public\Desktop"
$bloat = @("Webex.lnk" , "Zoom.lnk", "Firefox.lnk")

foreach ($link in $bloat){
	Write-Output "Build path..."
	$path = $(Join-Path $public $link)
	if(Test-Path _Path $path -PathType Leaf)
	{
		Write-Output "Remove item..."
		Remove-Item -Path $path
	}else{
		Write-Output "$path does not exist..."
	}
}

Write-Output "Finishing the Script!"

Stop-Transcript
