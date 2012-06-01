Param($zip=$(Throw("You need to specify a zip code!")))

if(Test-Connection -computer www.google.com -count 1 -quiet){
    $Unit = "F" #or use C for Celsius
    [string]$urlbase = "http://weather.yahooapis.com/forecastrss"
    [string]$url = $urlbase + "?p=" + $zip + "&u=" + $Unit

    #Create .NET Webclient object
    $webclient = new-object system.net.webclient

    [xml]$data = $webclient.DownloadString($url)

    # $data.rss.channel.item.condition
    if ($data.rss.channel.item.Title -eq "City not found") {
        Write-Error "Could not find a location for $zip"
    }
    else {
        $Title = $data.rss.channel.item.Title
        $Condition = $data.rss.channel.item.condition.text
        $temp = $data.rss.channel.item.condition.temp+($Unit)

        #get forecast
        $forecastDate = $data.rss.channel.item.forecast[0].date
        $forecastCondition = $data.rss.channel.item.forecast[0].text 
        $forecastLow = $data.rss.channel.item.forecast[0].low + $Unit
        $forecastHigh = $data.rss.channel.item.forecast[0].high + $Unit
    }
      
    #create new object to hold values
    $obj = New-Object System.Object
    Add-Member -inputobject $obj -membertype NoteProperty -Name Title -value $Title
    Add-Member -inputobject $obj -membertype NoteProperty -Name Condition -value $Condition
    Add-Member -inputobject $obj -membertype NoteProperty -Name Temp -value $temp
    Add-Member -inputobject $obj -membertype NoteProperty -Name ForecastDate -value $forecastDate
    Add-Member -inputobject $obj -membertype NoteProperty -Name ForecastCondition -value $forecastCondition
    Add-Member -inputobject $obj -membertype NoteProperty -Name ForecastLow -value $forecastLow 
    Add-Member -inputobject $obj -membertype NoteProperty -Name ForecastHigh -value $forecastHigh

    Write-Output $obj   
}


