<#
.Synopsis
	Get an entry from an INI file.
.Example
	Get-IniValue.ps1 C:\winnt\system32\ntfrsrep.ini text DEV_CTR_24_009_HELP
.Notes
NAME: 		Get-IniValue
AUTHOR: 	Lee Holmes
URL: 		http://www.leeholmes.com/blog/ManagingINIFilesWithPowerShell.aspx
ADDITIONS:
	- Added Resolve-Path on $file
#>
#requires -version 2
param(
	[Parameter(Mandatory=$true)]
	$file,
	[Parameter(Mandatory=$true)]
	$category,
	[Parameter(Mandatory=$true)]
	$key)

$file = Resolve-Path $file

$signature = @'
[DllImport("kernel32.dll")]
public static extern uint GetPrivateProfileString(
	string lpAppName,
	string lpKeyName,
	string lpDefault,
	StringBuilder lpReturnedString,
	uint nSize,
	string lpFileName);
'@

$type = Add-Type -MemberDefinition $signature `
	-Name Win32Utils -Namespace GetPrivateProfileString `
	-Using System.Text -PassThru
   
$builder = New-Object System.Text.StringBuilder 1024
$type::GetPrivateProfileString($category, $key, "", $builder, $builder.Capacity, $file)
   
$builder.ToString()
