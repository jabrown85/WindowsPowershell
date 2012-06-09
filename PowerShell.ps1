$NTIdentity = ([Security.Principal.WindowsIdentity]::GetCurrent())
$NTPrincipal = (new-object Security.Principal.WindowsPrincipal $NTIdentity)
$IsAdmin = ($NTPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))	

$global:shortenPathLength = 3

New-PSDrive -Name Modules -PSProvider FileSystem -root $ProfileDir/Modules | Out-Null

$promptCalls = new-object System.Collections.ArrayList

function prompt {
	$chost = [ConsoleColor]::Green
	$cdelim = [ConsoleColor]::DarkCyan
	$cloc = [ConsoleColor]::Cyan
	$cbranch = [ConsoleColor]::Green
	$cnotstaged = [ConsoleColor]::Yellow

	write-host ' '

	write-host ([Environment]::MachineName) -n -f $chost
	write-host ' {' -n -f $cdelim
	write-host ($pwd) -n -f $cloc
	write-host '} ' -n -f $cdelim

    $promptCalls | foreach { $_.Invoke() }

	write-host "»" -n -f $cloc
	' '

    $host.UI.RawUI.ForegroundColor = [ConsoleColor]::White
} 

function Add-CallToPrompt([scriptblock] $call) {
    [void]$promptCalls.Add($call)
}

function Add-ToPath {
	$args | foreach {
		# the double foreach's are to handle calls like 'add-topath @(path1, path2) path3
		$_ | foreach { $env:Path += ";$_" }
	}
}

function Start-IisExpressHere {
   & 'C:\Program Files (x86)\IIS Express\iisexpress.exe' /port:1234 /path:"$($pwd.Path)"
}
Import-Module find-string
Import-Module Pscx -DisableNameChecking
$Pscx:Preferences['TextEditor'] = "gvim.exe"
$Pscx:Preferences['FileSizeInUnits'] = $true

$vcargs = ?: {$Pscx:Is64BitProcess} {'amd64'} {''}
$VS100VCVarsBatchFile = "${env:VS100COMNTOOLS}..\..\VC\vcvarsall.bat"
Invoke-BatchFile $VS100VCVarsBatchFile $vcargs

# override the PSCX cmdlets with the default cmdlet
Set-Alias Select-Xml Microsoft.PowerShell.Utility\Select-Xml

Push-Location $ProfileDir
	# Bring in env-specific functionality (i.e. work-specific dev stuff, etc.)
	If (Test-Path ./EnvSpecificProfile.ps1) { . ./EnvSpecificProfile.ps1 }

	# Bring in prompt and other UI niceties
	. ./EyeCandy.ps1

    #Import-Module "PowerTab" -ArgumentList "C:\Users\dmohundro\Documents\WindowsPowerShell\PowerTabConfig.xml"

	#$PowerTabConfig.DefaultHandler = 'default'
	#$PowerTabConfig.TabActivityIndicator = $false

	Update-TypeData ./TypeData/System.Type.ps1xml
    Update-TypeData ./TypeData/System.Diagnostics.Process.ps1xml

    . ./scripts/aliases.ps1
    . ./scripts/utils.ps1
Pop-Location
