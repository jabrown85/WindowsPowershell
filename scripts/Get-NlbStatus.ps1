Param(
	[Switch]$debugOutput
	)

try
{
	$output = nlb query
	$result = -not($output -match 'stopped')
	if ($result)
	{
		"active"
	}
	else
	{
		"inactive"
	}
}
catch
{
	$_.Exception.ToString()
}

if ($debugOutput)
{
    $output
}
