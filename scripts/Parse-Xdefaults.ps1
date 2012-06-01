cat ~/.Xdefaults |   
  ?{ $_ -match 'color(\d+).+?(#.+)' } |     
  %{ 
    $id = [int]($matches[1]);
    $hexColor = $matches[2];
    $color = [System.Drawing.ColorTranslator]::FromHtml($matches[2]);
    
    $obj = new-object PSObject;
    $obj |         
      Add-Member NoteProperty Id $id -pass |
      Add-Member NoteProperty Hex $hexColor -pass |
      Add-Member NoteProperty Color $color;
    $obj;
  } | sort Id
