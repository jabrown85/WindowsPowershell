# pulled together from both http://tiredblogger.wordpress.com/ and http://tasteofpowershell.blogspot.com/

$fore = $Host.UI.RawUI.ForegroundColor

$compressed = '\.(zip|tar|gz|rar)$'
$executable = '\.(exe|bat|cmd|py|pl|ps1|psm1|vbs|rb|reg)$'
$code = '\.(cs|vb)$'
$projects = '\.(sln|csproj|vbproj)$'
$text = '\.(txt|cfg|conf|ini|csv|sql|xml|config|log)$'

Invoke-Expression ("Get-ChildItem $args") |
%{
	if ($_.GetType().Name -eq 'DirectoryInfo') {
		$Host.UI.RawUI.ForegroundColor = 'White'
		echo $_
		$Host.UI.RawUI.ForegroundColor = $fore
	} 
	elseif ($_.Name -match $compressed) {
		$Host.UI.RawUI.ForegroundColor = 'Blue'
		echo $_
		$Host.UI.RawUI.ForegroundColor = $fore
	} 
	elseif ($_.Name -match $executable) {
		$Host.UI.RawUI.ForegroundColor = 'Green'
		echo $_
		$Host.UI.RawUI.ForegroundColor = $fore
	} 
	elseif ($_.Name -match $text) {
		$Host.UI.RawUI.ForegroundColor = 'Cyan'
		echo $_
		$Host.UI.RawUI.ForegroundColor = $fore
	} 
	elseif ($_.Name -match $code) {
		$Host.UI.RawUI.ForegroundColor = 'Yellow'
		echo $_
		$Host.UI.RawUI.ForegroundColor = $fore
	} 
	elseif ($_.Name -match $projects) {
		$Host.UI.RawUI.ForegroundColor = 'Magenta'
		echo $_
		$Host.UI.RawUI.ForegroundColor = $fore
	}
	else {
		$Host.UI.RawUI.ForegroundColor = $fore
		echo $_
	}
}
