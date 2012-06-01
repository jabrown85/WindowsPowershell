cat c:/tools/console2/console.xml | 
  select-string '\<color\ id="(?<id>\d+)" r="(?<r>\d+)" g="(?<g>\d+)" b="(?<b>\d+)"' | 
  %{ 
    $grp = $_.matches[0].groups; 
    $color = new-object psobject; 
    $color | 
      add-member noteproperty Id $grp['id'].value -pass | 
      add-member noteproperty Red $grp['r'].value -pass | 
      add-member noteproperty Green $grp['g'].value -pass | 
      add-member noteproperty Blue $grp['b'].value -pass |
      add-member noteproperty Color `
        $([system.drawing.color]::fromargb(0, 
          $grp['r'].value, 
          $grp['g'].value, 
          $grp['b'].value).name); 
    $color 
  } |
  %{
    $id = '{0:00}' -f [int]$_.Id

	# the colors are stored as BGR instead of RBG...
    $color = [System.Drawing.Color]::FromArgb(0, $_.Blue, $_.Green, $_.Red).Name.PadLeft(6, '0')

    "`"ColorTable$id`"=dword:00$color"
  }
