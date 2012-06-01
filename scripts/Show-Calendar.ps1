##############################################################################
## 
## .Synopsis
##  Displays a visual representation of a calendar.
##
## .Description
##  Displays a visual representation of a calendar. Supports multiple months,

##  as well as the ability to highlight specific date ranges or days.
##
## .Parameter Start
##  The first month to display
##
## .Parameter End
##  The last month to display
##
## .Parameter FirstDayOfWeek

##  The day that begins the week
##
## .Parameter HighlightDay
##  Specific days (numbered) to highlight. Used for date ranges such as (25..31)
##  Date ranges are specified using PowerShell's range syntax. These dates are

##  surrounded by square brackets.
##
## .Parameter HighlightDate
##  Specific days (named) to highlight. These dates are surrounded by asterisk
##  characters.
##
## .Example
##   # Show a default display of this month

##   Show-Calendar
##
## .Example
##   # Display a date range
##   Show-Calendar -Start "March, 2010" -End "May, 2010"
##
## .Example
##   # Highlight a range of days
##   Show-Calendar -HighlightDay (1..10 + 22) -HighlightDate "December 25, 2008"

##
################################################################################

param(
    [DateTime] $start = [DateTime]::Today,
    [DateTime] $end = $start,
    $firstDayOfWeek,
    [int[]] $highlightDay,

    [string[]] $highlightDate = [DateTime]::Today.ToString()
    )

## Figure out the first day of the start and end months
$start = New-Object DateTime $start.Year,$start.Month,1
$end = New-Object DateTime $end.Year,$end.Month,1


## Convert the highlight dates into real dates
[DateTime[]] $highlightDate = [DateTime[]] $highlightDate

## Retrieve the DateTimeFormat information so that we can
## manipulate the calendar
$dateTimeFormat  = (Get-Culture).DateTimeFormat

if($firstDayOfWeek)
{
    $dateTimeFormat.FirstDayOfWeek = $firstDayOfWeek
}

$currentDay = $start

## Go through the requested months
while($start -le $end)
{
    ## We may need to back-pedal a bit if the first day of the month

    ## falls in the middle of the week
    while($currentDay.DayOfWeek -ne $dateTimeFormat.FirstDayOfWeek)
    {
        $currentDay = $currentDay.AddDays(-1)
    }

    ## Prepare to store information about this date range

    $currentWeek = New-Object PsObject
    $dayNames = @()
    $weeks = @()

    ## Go until we've hit the end of the month. Even once
    ## we've done that, continue until we fill up the week
    ## with days from the next month.

    while(($currentDay -lt $start.AddMonths(1)) -or
        ($currentDay.DayOfWeek -ne $dateTimeFormat.FirstDayOfWeek))
    {
        ## Figure out the day names we'll be using to label the columns
        $dayName = "{0:ddd}" -f $currentDay

        if($dayNames -notcontains $dayName)
        {
            $dayNames += $dayName
        }

        ## Pad the day number for display, highlighting if necessary
        $displayDay = " {0,2} " -f $currentDay.Day


        ## See if we should highlight a specific date
        if($highlightDate)
        {
            $compareDate = New-Object DateTime $currentDay.Year,
                $currentDay.Month,$currentDay.Day

            if($highlightDate -contains $compareDate)
            {
                $displayDay = "*" + ("{0,2}" -f $currentDay.Day) + "*"
            }
        }

        ## Otherwise, highlight as part of a date range

        if($highlightDay -and ($highlightDay[0] -eq $currentDay.Day))
        {
            $displayDay = "[" + ("{0,2}" -f $currentDay.Day) + "]"
            $null,$highlightDay = $highlightDay

        }

        ## Add in the day of week and day number as note properties.
        $currentWeek | Add-Member NoteProperty $dayName $displayDay

        ## Move to the next day in the month
        $currentDay = $currentDay.AddDays(1)


        ## If we've reached the next week, store the current week
        ## in the week list and continue on.
        if($currentDay.DayOfWeek -eq $dateTimeFormat.FirstDayOfWeek)
        {
            $weeks += $currentWeek

            $currentWeek = New-Object PsObject
        }
    }

    ## Now, format our weeks into a table
    $calendar = $weeks | Format-Table $dayNames -auto | Out-String

    ## Add a centred header

    $width = ($calendar.Split("`n") | Measure-Object -Max Length).Maximum
    $header = "{0:MMMM yyyy}" -f $start
    $padding = " " * (($width - $header.Length) / 2)
    $displayCalendar = " `n" + $padding + $header + "`n " + $calendar

    $displayCalendar.TrimEnd()

    ## And now move onto the next month
    $start = $start.AddMonths(1)
}
