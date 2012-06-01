##################################################################
# Get-SysInternalsSuite.ps1 - John Robbins - john@wintellect.com
#
# Note that this script requires the excellent 7Z.EXE in the
# PATH environment variable. You can get 7Z.EXE, which is free,
# at http://www.7-zip.org/.
#################################################################
param ( [string] $Extract ,
        [string] $Save )

# Always make sure all variables are defined.
Set-PSDebug -Strict
function Usage
{
    ""
    "Downloads and extracts all the tools from Sysinternals" 
    "" 
    "Usage: Get-SysInternalsSuite -extract <directory>" 
    "                             [-save <directory>]" 
    "Required Parameter :"
    " -extract <directory> : The directory where the SysinternalsSuite.zip"
    "                        tools are extracted."
    "Optional Parameters :"
    " -save <directory> : Saves SysinternalsSuite.zip to the specified"
    "                     directory. If not specified, the .ZIP file "
    "                     is not saved."
    " -? : Display this usage information"
    ""
    ""
    exit 
}

function CreateDirectoryIfNeeded ( [string] $directory )
{
    if ( ! ( Test-Path $directory -type "Container" ) ) 
    { 
        New-Item -type directory -Path $directory > $null
    }
}

##################################################################
# Main execution starts here.

# Check for the help request.
if ( ( $Args -eq '-?') -or ( ! $Extract ) )
{ 
    Usage
} 

$paramLog = @"
Param Extract   = $Extract
Param Save      = $Save
"@
Write-Debug $paramLog

[string]$sevenZName = "7Z.EXE"
# Verify I can find UNZIP.EXE in the path.
[string]$sevenZPath = $(Get-Command $sevenZName).Definition
if ( $sevenZPath.Length -eq 0 )
{
    Write-Error "Unable to find $sevenZName in the path."
    exit
}

# If the extract directory does not exist, create it.
CreateDirectoryIfNeeded ( $Extract )
# If there's a save directory set, us that otherwise, use the %TEMP% directory.
[Boolean]$deleteZipFile = $TRUE
[String]$downloadFile = ""
if ( $Save.Length -gt 0 )
{ 
    CreateDirectoryIfNeeded ( $Save )
    $downloadFile = $Save
    $deleteZipFile = $FALSE
}
else
{ 
    # Use the %TEMP% path for the user.
    $downloadFile = $env:temp
}

# Build up the full location and filename.
$downloadFile = $(Get-item $downloadFile).FullName
$downloadFile = Join-Path -path $downloadFile -childpath "SysinternalsSuite.zip" 
 
# Let the download begin!
Write-Output "Starting download of the Sysinternals Suite"
$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile("http://download.sysinternals.com/Files/SysinternalsSuite.zip" ,
                        $downloadFile)
Write-Output "Sysinternals suite downloaded to $downloadFile"

# I don't like to see all the output from 7z unless there's a problem so I'll
# redirect to a temporary file and if there's any problems, I'll show it.
$temp7zOutput = [System.IO.Path]::GetTempFileName() 

# Since the -o option to 7Z.EXE cannot have a space between it and the
# directory there's a bit of a problem. PowerShell does not expand the
# line -o$Extract if passed directly on the command line.
$outputOption = "-o$Extract"
Write-Output "Extracting files into $Extract"
&$sevenZPath x -y $outputOption $downloadFile > $temp7zOutput
if ( $LASTEXITCODE -ne 0 )
{ 
    # There was a problem extracting. 
    Get-Content $temp7zOutput 
    # Don't delete the download file. 
    $deleteZipFile = $FALSE 
    Write-Error "Error extracting the .ZIP file" 
    Write-Error "The downloaded .ZIP file is at $downloadFile and will not be deleted."
}
# Delete the file that held the extraction output.
del $temp7zOutput
# Delete the downloaded .ZIP file if I'm supposed to.
if ( $deleteZipFile -eq $TRUE )
{
    Remove-Item $downloadFile
} 

