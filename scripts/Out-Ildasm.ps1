# Script to spit the IL of all DLLs in a directory out
# Author: David Mohundro
param (
	[string]$Directory = "."
)

Begin {
	if (-not (Test-Path $Directory)) {
		mkdir $Directory | Out-Null
	}

	function RunIldasm($dll){ 
		$outPath = Join-Path $Directory "$($dll.Name).ildasm"
		ildasm /text /out="$outPath" $dll
	}
}

Process {
	if ($_) {
		RunIldasm $_
	}
	else
	{
		Get-ChildItem *.dll |
			ForEach {
				RunIldasm $_
			}
	}
}

End {
}
