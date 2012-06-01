# Out-ColorDiff.ps1
Process {
    if ($_) {
        foreach ($line in $_) {
            switch -regex ($line) {
                '^[<|-]' {
                    Write-Host -ForegroundColor red $line
                }
                '^[>|+]' {
                    Write-Host -ForegroundColor green $line
                }
                '^@@' {
                    Write-Host -ForegroundColor cyan $line
                }
                default {
                    Write-Host $line
                }
            }
        }
    }
} 
