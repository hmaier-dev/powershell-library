# param (
#   [Parameter(ValueFromPipeline=$true)]
#   [string[]]$ComputerName = $env:COMPUTERNAME,
#   [string]$NameRegex = ''
# )

## This should be run directly on a machine
function main(){
	$java = Get-AllInstalledSoftware | Where-Object { $_.DisplayName -match "java" }

	if ($java -eq $null){
		Write-Output "No Java was found."
		exit 0
	}

	# Multiple Java Entries can occure
	foreach($j in $java){
		$id = $java.IdentifyingNumber
		uninstall "$id"
	}
}



## Standard Paths
$MDM_home = $(Join-Path $env:ProgramData MDM)
$MDM_logs = $(Join-Path $MDM_home logs)
$MDM_data = $(Join-Path $MDM_home data)

## App/Usage related
$pkg_name = "Java-Uninstaller"
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
main
Stop-Transcript
## End Point

## ----------------------------------------------------------------------------------------------------------------------------
## Helper Functions
function Get-AllInstalledSoftware
{
  param (
    [Parameter(ValueFromPipeline=$true)]
    [string[]]$ComputerName = $env:COMPUTERNAME,
    [string]$NameRegex = ''
  )

  foreach ($comp in $ComputerName)
  {
    $keys = '','\Wow6432Node'
    foreach ($key in $keys)
    {
      try
      {
        $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $comp)
        $apps = $reg.OpenSubKey("SOFTWARE$key\Microsoft\Windows\CurrentVersion\Uninstall").GetSubKeyNames()
      } catch
      {
        continue
      }

      foreach ($app in $apps)
      {
        $program = $reg.OpenSubKey("SOFTWARE$key\Microsoft\Windows\CurrentVersion\Uninstall\$app")
        $name = $program.GetValue('DisplayName')
        if ($name -and $name -match $NameRegex)
        {
          [pscustomobject]@{
            ComputerName = $comp
            DisplayName = $name
            DisplayVersion = $program.GetValue('DisplayVersion')
            Publisher = $program.GetValue('Publisher')
            InstallDate = $program.GetValue('InstallDate')
            UninstallString = $program.GetValue('UninstallString')
            IdentifyingNumber = $program | Split-Path -Leaf
            Bits = $(if ($key -eq '\Wow6432Node')
              {'64'
              } else
              {'32'
              })
            Path = $program.name
          }
        }
      }
    }
  }
}

function uninstall($id){
	try{
		Write-Output "Uninstalling $id..."
		Start-Process -FilePath "msiexec.exe" -ArgumentList "/x $id /quiet" -Wait -PassThru
		Write-Output "Successful uninstall!"
	}catch{
		Write-Output "Error: $_"
	}
}
