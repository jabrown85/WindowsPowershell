function Write-ScmStatus {
    if ((Get-Location | Select -expand Provider | Select -expand Name) -eq 'FileSystem') {
        if (has-anyofparentpath @('.svn', '.git')) {
            if (((Get-Command python) -ne $null) -and ((Get-Command vcprompt.py) -ne $null)) {
                $vc = python "$((Get-Command vcprompt.py).Definition)"
                write-host $vc -f Gray
            }
            else {
                write-host ''
            }
        }
        elseif (has-parentpath '.hg') {
            write-host "[hg:$(cat $(join-path (get-parentpath '.hg') 'branch'))]" -f 'Gray'
        }
        else {
            write-host ' '
        }
    }
    else {
        write-host ' '
    }
}

Add-CallToPrompt { Write-ScmStatus }

function Get-AliasShortcut([string]$commandName) {
	ls Alias: | ?{ $_.Definition -match $commandName }
}

function ack {
	cmd /c ack.pl $args
}

function git {
    # msysgit options - see http://code.google.com/p/msysgit/issues/detail?id=326&q=color&colspec=ID%20Type%20Status%20Priority%20Component%20Owner%20Summary#c5
    $env:LESS = 'FRSX'
    $env:TERM = 'cygwin'

    & git.exe $args

    $env:LESS = $null
    $env:TERM = $null
}

function Start-VisualStudio([string]$path) {
	& devenv /edit $path
}

function Elevate-Process {
	$file, [string]$arguments = $args
	$psi = new-object System.Diagnostics.ProcessStartInfo $file
	$psi.Arguments = $arguments
	$psi.Verb = "runas"
	$psi.WorkingDirectory = Get-Location
	[System.Diagnostics.Process]::Start($psi)
}

function Get-LatestErrors([int] $newest = 5) {
    Get-EventLog -LogName Application -Newest $newest -EntryType Error -After $([DateTime]::Today)
}

function has-anyofparentpath([string[]]$paths) {
    $hasPath = $false
    foreach ($path in $paths) {
        $hasPath = has-parentpath $path
        if ($hasPath) { return $true }
    }
}

function has-parentpath([string]$path) {
    if (test-path $path) {
        return $true;
    }

    $path = "/$path"

    # Test within parent dirs
    $checkIn = (Get-Item .).parent
    while ($checkIn -ne $NULL) {
        $pathToTest = $checkIn.fullname + $path
        if ((Test-Path $pathToTest) -eq $TRUE) {
            return $true
        } else {
            $checkIn = $checkIn.parent
        }
    }

    return $false
}

function get-parentpath([string]$path) {
    if (test-path $path) {
        return $path
    }

    # Test within parent dirs
    $checkIn = (Get-Item .).parent
    while ($checkIn -ne $NULL) {
        $pathToTest = $checkIn.fullname + '/.hg'
        if ((Test-Path $pathToTest) -eq $TRUE) {
            return $pathToTest
        } else {
            $checkIn = $checkIn.parent
        }
    }

    return $null
}

function find {
    param ([switch] $ExactMatch)

    if ($ExactMatch) {
        ls -inc $args -rec
    }
    else {
        ls -inc "*$args*" -rec
    }
}

function To-Binary {
    param (
        [Parameter(ValueFromPipeline=$true)]
        [int]$num
    )
    [Convert]::ToString($num, 2)
}

function To-Hex {
    param (
        [Parameter(ValueFromPipeline=$true)]
        [int]$num
    )
    [Convert]::ToString($num, 16)
}
