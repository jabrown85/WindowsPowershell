$hgTemplatesPath = 'd:\dev\oss\mercurial-cli-templates'

switch ($args[0]) {
    'dlog' {
        hg.exe log "--style=$hgTemplatesPath\map-cmdline.dlog" $args[1..5]
    }
    'nlog' {
        hg.exe log "--style=$hgTemplatesPath\map-cmdline.nlog" $args[1..5]
    }
    'sglog' {
        hg.exe glog "--style=$hgTemplatesPath\map-cmdline.sglog" $args[1..5]
    }
    'slog' {
        hg.exe log "--style=$hgTemplatesPath\map-cmdline.slog" $args[1..5]
    }
    'branches' {
        hg.exe branches $args[1..5] | foreach { 
            $branch, $revision = $_ -split '\s{2,}'
            
            $row = New-Object PSObject
            $row |
                Add-Member NoteProperty 'Branch' $branch -pass |
                Add-Member NoteProperty 'Revision' $revision                
            $row
        }
    }
    default {
        hg.exe @args
    }
}
