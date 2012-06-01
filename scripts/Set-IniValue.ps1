<#
.Synopsis
	Set an entry from an INI file.
.Example
	PS>copy C:\winnt\system32\ntfrsrep.ini c:\temp\
	PS>Set-IniValue.ps1 C:\temp\ntfrsrep.ini text DEV_CTR_24_009_HELP "New Value"
	>>
	PS>Get-IniValue.ps1 C:\temp\ntfrsrep.ini text DEV_CTR_24_009_HELP
	New Value
	PS>Set-IniValue.ps1 C:\temp\ntfrsrep.ini NEW_SECTION NewItem "Entirely New Value"
	>>
	PS>Get-IniValue.ps1 C:\temp\ntfrsrep.ini NEW_SECTION NewItem
	Entirely New Value
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
    $key,
	[Parameter(Mandatory=$true)]
    $value)

$file = Resolve-Path $file

$signature = @'
[DllImport("kernel32.dll")]
public static extern UInt32 WritePrivateProfileString(
	string lpAppName,
	string lpKeyName, 
	string lpString, 
	string lpFileName);
'@

$type = Add-Type -MemberDefinition $signature `
	-Name Win32Utils -Namespace WritePrivateProfileString `
	-PassThru

$type::WritePrivateProfileString($category, $key, $value, $file)
