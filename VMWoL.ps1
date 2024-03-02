function Format-MAC {
  param([string]$stringMAC)
	
	if ($stringMAC.Length -ne 12) { throw "Invalid MAC address" }

  $stringMAC = $stringMAC.Insert(10, ":")
  $stringMAC = $stringMAC.Insert(8, ":")
  $stringMAC = $stringMAC.Insert(6, ":")
  $stringMAC = $stringMAC.Insert(4, ":")
  $stringMAC = $stringMAC.Insert(2, ":")

  return $stringMAC
}

function Read-MagicPacket {
	param($packet)
	
	if ($packet.Length -lt 102)	{
		Write-Host "                    ¤ Message received is not a Magic Packet"
		return 0
	}
	
	for ($offset = 0; $offset -lt 6; $offset++)	{
		if ($packet[$offset] -ne [byte]0xFF) {
			Write-Host "                    ¤ Message received is not a Magic Packet"
			return 0
		}
	}
	
	[byte[]]$mac = [byte[]]::new(6)
	for ($offset = 6; $offset -lt 12; $offset++) {
		$mac[$offset - 6] = $packet[$offset]
	}
	
	$stringMAC = ($mac|ForEach-Object ToString X2) -join ''
	$formatedMAC = Format-MAC -stringMAC $stringMAC
	Write-Host "                    ¤ Message received is Magic Packet for $($FormatedMAC)"
	
	return $stringMAC
}

function Listen-MagicPacket
{
	param([int]$port)
	
	if ($port -eq 0) { 
		$port = 99 
	}
	
	try {
		Write-Host
		$Endpoint = new-Object System.Net.IPEndPoint ([IPAddress]::Any,$port)
		$Client = new-Object System.Net.Sockets.UdpClient $port
		
		while ($True)
		{
			Write-Host "---------------------------------------------------------------------------------"
			Write-Host (Get-Date).ToString("yyyy/MM/dd HH:MM:ss") "Waiting for message on UDP port $port ..."
			
			$content = $Client.Receive([ref]$Endpoint)

			Write-Host (Get-Date).ToString("yyyy/MM/dd HH:MM:ss") "Message received from: $($Endpoint.Address.toString()):$($Endpoint.Port)"
			
			$stringMAC = Read-MagicPacket -packet $content
			Wake-VM -stringMAC $stringMAC
		}
	}
  catch [System.Exception] {
        throw $Error[0]
  }
  finally {
      Write-Host (Get-Date).ToString("yyyy/MM/dd HH:MM:ss") "Closing connection."
      $Client.Close()
  }
}

function Wake-VM
{
  param([String]$stringMAC)
	
	$VMs = Get-VM
	if ($VMs.Count -lt 1)	{
		throw "No virtual machines found on host"
	}
	
	Write-Host "                    ¤ Checking for Virtual Machine with specified MAC address ..."
	
	$MatchCount = 0
  foreach ($VM in $VMs)
  {
		foreach ($adapter in $VM.NetworkAdapters)
		{
			if ($adapter.MacAddress -eq $stringMAC)
			{
				Write-Host "                    ¤ Virtual Machine found : ""$($VM.Name)"""
				Write-Host "                    ¤ Starting VM ..."
				Write-Host
				Start-VM -Name $VM.Name
				$MatchCount++
				Write-Host
			}
		}
  }

	if ($MatchCount -eq 0) {
		Write-Host "No virtual machines found with specified MAC address on host"
	}
}

Listen-MagicPacket -port $args[0]

Exit(0)
