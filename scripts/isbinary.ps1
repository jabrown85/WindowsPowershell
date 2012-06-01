param ([System.IO.FileInfo]$item)

process {
    try {
        $reader = $item.OpenRead()
        $bytes = new-object byte[] 1024
        $numRead = $reader.Read($bytes, 0, $bytes.Count)

        for ($i=0; $i -lt $numRead; ++$i) {
            if ($bytes[$i] -eq '\0') { return $true }
        }
        $false
    }
    finally {
        if ($reader) { $reader.Dispose() }
    }
}
