param(
	$csvToImport
)

Import-Assembly 'C:\dtcdev\NIN2005\Shell\Keywords\RemoteService\bin\Debug\NIN.Shell.Keywords.RemoteService.dll'

"Importing from $csvToImport"
$keywords = Import-Csv $csvToImport

if ($keywords -eq $null) { 
	'No keywords found...'
	return
}

$keywords | 
	%{ 
		$key = new-object DTC.NIN.Shell.Keywords.RemoteService.DataLayer.Entities.Keyword
		$key.Keyword = $_.Keyword
		$key.Title = $_.Title

		if ($_.Url -eq '') {
			$key.Url = $_.Keyword
		}
		else {
			$key.Url = $_.Url
		}

		$key.Description = $_.Description

		if ($_.'Viewable By' -ne $null) {
			$security = $_.'Viewable By'.Split(',') | %{ 
				$_.Trim()
			} | ?{ $_ -ne '' }
		}

		foreach ($sec in $security) {
			$key.AddViewSecurity($sec)
		}

		$key
	} |
	%{ 
		$cfg = [DTC.NIN.Shell.Keywords.RemoteService.KeywordService]::Configure()
		try {
			$controller = $cfg.BuildController()
			$controller.AddNewKeyword($_)
		}
		finally {
			$cfg.Dispose()
		}
	}