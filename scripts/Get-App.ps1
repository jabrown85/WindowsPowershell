param (
	[string] $filter,
	[switch] $uninstall
)

$apps = Get-ChildItem hklm:/software/microsoft/windows/currentversion/uninstall | 
	foreach { 
		get-itemproperty $_.pspath 
	} | 
	where { 
		$_.ParentDisplayName -eq $Null -and 
		$_.DisplayName -ne $Null -and
		$_.ReleaseType -ne 'HotFix' -and 
		$_.ReleaseType -ne 'Security Update' -and 
		$_.UninstallString -ne '' -and 
		$_.URLInfoAbout -ne 'http://support.microsoft.com' -and 
		$_.SystemComponent -ne 1 
	}

$foundApp = $apps | 
	where { $_.DisplayName -match $filter } 

if ($uninstall) {
	"Uninstalling $($foundApp.DisplayName)"

	if ($foundApp.WindowsInstaller -eq 1) {
		cmd /c msiexec.exe /uninstall $foundApp.PSChildName /quiet
	}
	else {
		"Install doesn't use MSI - the uninstall string is $($foundApp.UninstallString)"
	}
}
else {
	$foundApp | sort DisplayName | select DisplayName, DisplayVersion
}
