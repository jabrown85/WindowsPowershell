param([string]$name=$(throw "loader name required"),[string]$file=$(throw "VHD filename required"))

$local:windowsIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$local:windowsPrincipal = new-object 'System.Security.Principal.WindowsPrincipal' $local:windowsIdentity
if ($local:windowsPrincipal.IsInRole("Administrators") -ne 1)
{
  throw "add-bcd-vhd must be run from an administrator account"
}

$f= resolve-path $file
$vhdvalue = "[$($f.Drive.Name):]$($f.Path.Substring(2))"

$rx = [regex] "\{\w{8}-\w{4}-\w{4}-\w{4}-\w{12}\}"

$r = bcdedit /copy '{current}' /d $name
$m = $rx.match($r)

if ($m.success)
{
  $guid = $m.value

  $ret = bcdedit /set $guid device vhd=$vhdvalue
  if ($ret -ne "the operation completed successfully.")
  {
      throw $ret
  }
  $ret = bcdedit /set $guid osdevice vhd=$vhdvalue 
  if ($ret -ne "the operation completed successfully.")
  {
      throw $ret
  }
  $ret = bcdedit /set $guid detecthal on 
  if ($ret -ne "the operation completed successfully.")
  {
      throw $ret
  }

  echo "$name ($(split-path -leaf $file)) VHD Boot Configured"
}
