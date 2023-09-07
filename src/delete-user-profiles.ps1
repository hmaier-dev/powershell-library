param (
	[parameter(Mandatory=$False)]
	[ValidateNotNullOrEmpty()]$ComputerName
)


function choose_item($object)
{
	$i = 0
	$object | ForEach-Object {
	$i++
	$curr = $_.LocalPath
	Write-Host("[$i] $curr")
	}
	$user_input = Read-Host("Your choice")

	$intStrings = $user_input  -split ' '
	# Initialize an empty array to store the converted integers
	$integers = @()

	# Iterate through the integer strings and convert them to integers
	foreach ($intString in $intStrings) {
		$int = [int]$intString
		if (-not [string]::IsNullOrEmpty($intString) -and [int]::TryParse($intString, [ref]$null)) {
			$int--
			$integers += $int
		}
	}
	return $integers # array of ints
}

$v = $PSVersionTable.PSVersion.Major

if ($v -ge 7){
	$obj = Get-CimInstance -Class Win32_UserProfile | Where-Object{ $_.Special -eq $false } | Select-Object LocalPath, Special, Status
}else{
	$obj = Get-WmiObject -Class Win32_UserProfile | Where-Object{ $_.Special -eq $false } | Select-Object LocalPath, Special, Status
}

Write-Host "Which profile to delete? (You can give in multiple input sperated by SPACES) "

$remove = choose_item $obj

foreach($r in $remove){
	$r
	$prof = $obj[$r]
	$org_path = $prof.LocalPath
	$trans_path = $org_path.Replace('\','\\')
	try{
		Remove-CimInstance -Query "SELECT * FROM Win32_UserProfile WHERE LocalPath='$trans_path'"
	}catch{
		exit 1
	}
	Write-Host "Removed $path"
}
