<#
.SYNOPSIS
    Simple IP Scanner With ICMP(Ping)
.DESCRIPTION
    Simple IP Scanner With ICMP(Ping),
    Simple To Use,
.EXAMPLE
    -StartIPV4Address 192.168.1.100 -EndIPV4Address 192.168.1.109
.OUTPUTS
   Source        Destination     IPV4Address      IPV6Address                              Bytes    Time(ms) 
   ------        -----------    -----------      -----------                              -----    --------
    DESKTOP-UD... 192.168.1.101                                                             32       614
    DESKTOP-UD... 192.168.1.102                                                             32       1        
    DESKTOP-UD... 192.168.1.106   192.168.1.106                                             32       58       
#>

function Main {
    [CmdletBinding()]
    param (
        # Start of Scan Address
        [Parameter(Mandatory=$true,
        HelpMessage="Enter IP Address Like: XXX.XXX.XXX.XXX")]
        [ipaddress]
        $StartIPV4Address,
        # End of Scan Address
        [Parameter(Mandatory=$true,
        HelpMessage="Enter IP Address Like: XXX.XXX.XXX.XXX")]
        [ipaddress]
        $EndIPV4Address
    )
    
    begin {
        rm '.\Data.txt'
        $StartIPV4AddressArray = $StartIPV4Address.ToString().Split('.')
        $EndIPV4AddressArray = $EndIPV4Address.ToString().Split('.')
    }
    
    process {
        $jobs = @()
        for ($i = ([int]::Parse($StartIPV4AddressArray[0])); $i -le ([int]::Parse($EndIPV4AddressArray[0])); $i++) {
            for ($j = ([int]::Parse($StartIPV4AddressArray[1])); $j -le ([int]::Parse($EndIPV4AddressArray[1])); $j++) {
                for ($k = ([int]::Parse($StartIPV4AddressArray[2])); $k -le ([int]::Parse($EndIPV4AddressArray[2])); $k++) {
                    for ($l = ([int]::Parse($StartIPV4AddressArray[3])); $l -le ([int]::Parse($EndIPV4AddressArray[3])); $l++) {
                        $IP_Address = ($i.ToString()+"."+$j.ToString()+"."+$k.ToString()+"."+$l.ToString())
                        Do
                            {
                                $Job = (Get-Job -State Running | measure).count
                            } Until ($Job -le 8)
                        $id = [System.Guid]::NewGuid()
                        $jobs += ($id)
                        Start-Job -Name $id -ScriptBlock {
                            param($IP_ADDRESS)
                            Test-Connection -ComputerName $IP_ADDRESS -Count 1 -ErrorAction SilentlyContinue
                        } -ArgumentList $IP_Address  
                    }
                }
            }
        }
        while (Get-Job -State Running) {
            cls
            Get-Job
            Start-Sleep 1
        }
        cls
        Get-Job
        foreach ($item in $jobs) {
            Receive-Job -Name $item | Out-File 'Data.txt' -Append
        }
    }
    
    end {
        Remove-Job * -Force
    }    
}

Main