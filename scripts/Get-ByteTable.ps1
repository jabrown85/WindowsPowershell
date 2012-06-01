param (
    [Parameter(ValueFromPipeline=$true)]
    [byte]
    $bytes
)

begin {
    $results = new-object System.Collections.ArrayList
    $byteCount = 0
}

process {
    $byteTable = $bytes | To-Binary

    if ($byteTable.Length -lt 8) {
        $byteTable = $byteTable.PadLeft(8, '0')
    }

    $hexValue = "0x{0:X2}" -f $bytes

    $table = New-Object PSObject
    $table |
        Add-Member NoteProperty 'Index' "Byte $byteCount" -pass |
        Add-Member NoteProperty 'Hex' $hexValue -pass |
        Add-Member NoteProperty '7' $byteTable.Substring(0, 1) -pass |
        Add-Member NoteProperty '6' $byteTable.Substring(1, 1) -pass |
        Add-Member NoteProperty '5' $byteTable.Substring(2, 1) -pass |
        Add-Member NoteProperty '4' $byteTable.Substring(3, 1) -pass |
        Add-Member NoteProperty '3' $byteTable.Substring(4, 1) -pass |
        Add-Member NoteProperty '2' $byteTable.Substring(5, 1) -pass |
        Add-Member NoteProperty '1' $byteTable.Substring(6, 1) -pass |
        Add-Member NoteProperty '0' $byteTable.Substring(7, 1)

    $table

    $byteCount += 1
}

end {
    $results
}
