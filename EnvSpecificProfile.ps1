Add-ToPath "$profileDir\scripts"

function Check-SueStatus() {
    (Get-Service SUE | Select -ExpandProperty Status) -eq 'Running'
}

#Add-CallToPrompt { if (-not (Check-SueStatus)) { write-host '!SUE NOT RUNNING! ' -n -f 'Red' }}
#Add-CallToPrompt { write-host "[$(get-weather 38018 | select temp, condition | %{ $_.temp + ' ' + $_.condition })] " -n -f 'Green' }

function comp($left, $right) {
    $left = Resolve-Path $left
    $right = Resolve-Path $right
    & 'C:/Program Files/SourceGear/Common/DiffMerge/sgdm.exe' $left, $right
}
