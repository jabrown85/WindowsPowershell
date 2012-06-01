
    param ([System.IO.FileInfo]$item)

    begin 
    { 
        $validList = New-Object System.Collections.ArrayList
        $validList.AddRange([byte[]] (10,13) )
        $validList.AddRange([byte[]] (31..127) )
    }

    process {
        try {
            $reader = $item.OpenRead()
            $bytes = new-object byte[] 1024
            $numRead = $reader.Read($bytes, 0, $bytes.Count)

            for ($i=0; $i -lt $numRead; ++$i) {
                if (!$validList.Contains($bytes[$i])) { return $false }
            }
            $true
        }
        finally {
            if ($reader) { $reader.Dispose() }
        }
    }
