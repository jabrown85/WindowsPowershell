# $Id: httpd.ps1 152 2007-01-24 12:03:59Z adrian $

param($prefix="http://+:8888/")

# create an httplistener listening on the specified prefix url
$listener = new-object Net.HttpListener
$listener.Prefixes.Add($prefix)
$listener.Start()

# loop, accepting synchronous requests until we're told to quit
$shouldProcess = $true
while ($shouldProcess) {
  write-debug "Listening"
  # block, waiting for a connection
  $ctx = $listener.GetContext() 
  write-debug "Got a request"
  $response = $ctx.Response
  # we'll write out a simple text response
  $response.Headers.Add("Content-Type","text/plain")
  $writer = new-object IO.StreamWriter($response.OutputStream,[Text.Encoding]::UTF8)
  # see if there is a cmd query string..
  $request = $ctx.Request
  $cmd = $request.QueryString["cmd"]
  switch ($cmd) {
    "quit" { 
      # we're asked to quit, so respond and set flag
      $writer.WriteLine("Quitting, bye bye")
      $shouldProcess=$false
      break 
    }
    $null {
      # nothing supplied, so send back a help message
      $writer.WriteLine(@"
No command supplied.

Syntax is: http://server/?cmd=xxxx

Where xxxx is 'quit' to tell the server to quit
or any PowerShell command.

Eg:  http://server/?cmd=get-process

"@)
      break
    }
    default { 
      # got a real command so invoke it and use out-string to
      # get a textual representation to send back to client.
      write-debug "Invoking $cmd"
      $count=0
      invoke-expression $cmd | out-string -stream | foreach {
        $writer.WriteLine($_.TrimEnd()) 
        $count++
      }
      if ($count -eq 0) {
        # no output - maybe should use get-bufferhtml ?
        $writer.WriteLine(@"
There was no output from this command.
Either the command did not produce any output, or it wrote its output
directly to the host with 'write-host'.

If there were errors, you can see them with:
http://server/?cmd=`$Error

"@);
      }
    }
  }
  $writer.Close()
  write-debug "Closed response"
}
write-debug "Stopping"
$listener.Stop()



