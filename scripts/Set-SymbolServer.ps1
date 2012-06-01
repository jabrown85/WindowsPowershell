#requires -version 2.0

#Wintellect .NET Debugging Code
#(c) 2009-2010 by John Robbins\Wintellect - Do whatever you want to do with it
# aslong as you give credit. 

<#.SYNOPSIS
Setsup a computer with symbol server values in both the environment and in 
VS 2010.
.DESCRIPTION
Sets up both the _NT_SYMBOL_PATH environment variable and Visual Studio 2010
to use a common symbol cache directory as well as common symbol servers.
.PARAMETER Internal
Sets the symbol server to use to \\SYMBOLS\SYMBOLS. Visual Studio will not use 
the public symbol servers. This will turn off the .NET Framework SourceStepping
You must specify either -Internal or -Public to the script.
.PARAMETER Public
Sets the symbol server to use as the two public symbol servers from Microsoft. 
All the appropriate settings are configured to properly have .NET Reference 
Source stepping working.
.PARAMETER CacheDirectory
Defaults to C:\SYMBOLS\PUBLIC\MicrosoftPublicSymbols for -Public and 
C:\SYMBOLS\INTERNAL for -Internal. If you specify a different cache directory
with -Public, MicrosoftPublicSymbols will always be appended. This is to 
avoid issues with Visual Studio downloading the symbols to a differentlocation.
.PARAMETER SymbolServers
A string array of additional symbol servers to use. If -Internal is set, these 
additional symbol servers will appear after \\SYMBOLS\SYMBOLS. If -Public is 
set, these symbol servers will appear after the public symbol servers so both
the environment variable and Visual Studio have the same search order
#>
[CmdLetBinding(SupportsShouldProcess=$true)]
param ( [switch]   $Internal      ,
              [switch]   $Public         ,
              [string]   $CacheDirectory ,
              [string[]] $SymbolServers   )
        
#Always make sure all variables are defined.
Set-PSDebug -Strict         

#Creates the cache directory if it does not exist.
function CreateCacheDirectory ( [string] $cacheDirectory )
{
       if ( ! $(Test-path $cacheDirectory -type "Container" ))
       {
              if ($PSCmdLet.ShouldProcess("Destination:$cacheDirectory" , 
                                    "CreateDirectory"))
              {
                     New-Item -type directory -Path $cacheDirectory > $null
              }
       }
}

function Set-ItemPropertyScript ( $path , $name , $value , $type )
{
    if ( $path -eq $null )
    {
        Write-Error "Set-ItemPropertyScriptpath param cannot be null!"
        exit
    }
    if ( $name -eq $null )
    {
        Write-Error "Set-ItemPropertyScriptname param cannot be null!"
        exit
    }
       $propString = "Item: " + $path.ToString() + " Property:" + $name
       if ($PSCmdLet.ShouldProcess($propString ,"SetProperty"))
       {
        if ($type -eq $null)
        {
               Set-ItemProperty -Path $path -Name $name -Value $value
        }
        else
        {
               Set-ItemProperty -Path $path -Name $name -Value $value -Type $type
        }
       }
}

# Dothe parameter checking.
if ( $Internal -eq $Public )
{
    Write-Error "You must specify either -Internal or-Public"
    exit
}

#Check if VS is running. 
if (Get-Process 'devenv' -ErrorAction SilentlyContinue)
{
    Write-Error "Visual Studio is running. Pleaseclose all instances before running this script"
    exit
}

$dbgRegKey = "HKCU:\Software\Microsoft\VisualStudio\10.0\Debugger"

if ( $Internal )
{
       if ( $CacheDirectory.Length -eq 0 )
       {
       $CacheDirectory = "C:\SYMBOLS\INTERNAL" 
       }

    CreateCacheDirectory $CacheDirectory
    
    # Default to \\SYMBOLS\SYMBOLS and addany additional symbol servers to 
    # the end of the string.
    $symPath = "SRV*$CacheDirectory*\\SYMBOLS\SYMBOLS"
    $vsPaths = ""
    $pathState = ""

       for ( $i = 0 ; $i -lt $SymbolServers.Length ; $i++ )
       {
        $symPath += "*"
        $symPath += $SymbolServers[$i]
        
        $vsPaths += $SymbolServers[$i]
        $vsPaths += ";"
        $pathState += "1"
       }
    $symPath += ";"
    
    Set-ItemPropertyScript HKCU:\Environment _NT_SYMBOL_PATH $symPath
    
    # Turn off .NET Framework Sourcestepping.
    Set-ItemPropertyScript $dbgRegKey FrameworkSourceStepping 0 DWORD
    # Turn off using the Microsoft symbolservers.
    Set-ItemPropertyScript $dbgRegKey SymbolUseMSSymbolServers 0 DWORD
    # Set the symbol cache dir to the samevalue as used in the environment
    # variable.
    Set-ItemPropertyScript $dbgRegKey SymbolCacheDir $CacheDirectory
    # Set the VS symbol path to anyadditional values
    Set-ItemPropertyScript $dbgRegKey SymbolPath $vsPaths
    # Tell VS that to the additional serversspecified.
    Set-ItemPropertyScript $dbgRegKey SymbolPathState $pathState
    
}
else
{
       if ( $CacheDirectory.Length -eq 0 )
       {
       $CacheDirectory = "C:\SYMBOLS\PUBLIC" 
       }
       
       # For -Public, we have to putMicrosoftPublicSymbols on the end because 
       # Visual Studio hard codes that on forsome reason. I have no idea why.
       if ( $CacheDirectory.EndsWith("\") -eq $false )
       {
              $CacheDirectory += "\"
       }
       $CacheDirectory += "MicrosoftPublicSymbols"

    CreateCacheDirectory $CacheDirectory
    
    # It's public so we have a littledifferent processing to do. I have to 
    # add the MicrosoftPublicSymbols as VShardcodes that onto the path.
    # This way both WinDBG and VS are usingthe same paths for public
    # symbols.
    $refSrcPath = "$CacheDirectory*http://referencesource.microsoft.com/symbols"
    $msdlPath = "$CacheDirectory*http://msdl.microsoft.com/download/symbols"
    $extraPaths = ""
    $enabledPDBLocations ="11"
    
    # Poke on any additional symbol servers.I've keeping everything the
    # same between VS as WinDBG.
       for ( $i = 0 ; $i -lt $SymbolServers.Length ; $i++ )
       {
        $extraPaths += ";"
        $extraPaths += $SymbolServers[$i]
        $enabledPDBLocations += "1"
       }

    $envPath = "SRV*$refSrcPath;SRV*$msdlPath$extraPaths"
    
    Set-ItemPropertyScript HKCU:\Environment _NT_SYMBOL_PATH $envPath
    
    # Turn off Just My Code.
    Set-ItemPropertyScript $dbgRegKey JustMyCode 0 DWORD
    
    # Turn on .NET Framework Source stepping.
    Set-ItemPropertyScript $dbgRegKey FrameworkSourceStepping 1 DWORD
    
    # Turn on Source Server Support.
    Set-ItemPropertyScript $dbgRegKey UseSourceServer 1 DWORD
    
    # Turn on Source Server Diagnostics asthat's a good thing. :)
    Set-ItemPropertyScript $dbgRegKey ShowSourceServerDiagnostics 1 DWORD
    
    # It's very important to turn offrequiring the source to match exactly.
    # With this flag on, .NET ReferenceSource Stepping doesn't work.
    Set-ItemPropertyScript $dbgRegKey UseDocumentChecksum 0 DWORD
    
    # Turn on using the Microsoft symbolservers.
    Set-ItemPropertyScript $dbgRegKey SymbolUseMSSymbolServers 1 DWORD
    
    # Set the VS SymbolPath setting.
    $vsSymPath ="$refSrcPath;$msdlPath$extraPaths"
    Set-ItemPropertyScript $dbgRegKey SymbolPath $vsSymPath
    
    # Tell VS that all paths set are active(you see those as check boxes in 
    # the Options dialog, Debugging\Symbolspage).
    Set-ItemPropertyScript $dbgRegKey SymbolPathState $enabledPDBLocations
    
    # Set the symbol cache dir to the samevalue as used in the environment
    # variable.
    Set-ItemPropertyScript $dbgRegKey SymbolCacheDir $CacheDirectory
    
}
""
"Pleaselog out to activate the new symbol server settings"
""
