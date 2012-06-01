param (
    [string]$file,
    [string]$outputDir = ''
)

if (-not (Test-Path $file)) {
    $file = Resolve-Path $file
}

if ($outputDir -eq '') {
    $outputDir = [System.IO.Path]::GetFileNameWithoutExtension($file)
}

zip e "-o$outputDir" $file 
