function Stop-iPerfServer{

# 1. Initialize
# 2. Stop the iPerf process if it's running
# 3. Delete the iPerf and ICMP firewall rules

    <#
    .SYNOPSIS
         Clean up utility for the Start-iPerfServer function. 

    .DESCRIPTION
        This function stops an iPerf3 server that was start with the Start-iPerfServer function. This function will also remove the
        Firewall Rules that were creared by the Start-iPerfServer function.

        When this command is executed it will perform the following:
        1. Look for a running iPerf process
        2. Stop the iPerf process
        3. Delete the ICMP and iPerf Firewall Rules if present

    .EXAMPLE
        Stop-iPerfServer

        This command stops the iperf process and removes the firewall rules created with the Start-iPerfServer command.

    .LINK
        https://github.com/ACTMod/ACTModified.git

    .NOTES
        This script modifies the system stae, specifically it removes Firewall Rules that were added from the Start-iPerfServer command
        and stops the iPerf process if running. 

    #>

[cmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
param()

    process{
    # 1. Initialize
    $ToolPath = "C:\ACTTools\"

    # 2. Stop the iPerf process if it's running
    $iPerf = Get-Process iperf3 -ErrorAction SilentlyContinue

    if ($iPerf) {
        If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
                {  
                $cmd = $ToolPath + "Stop-Process.ps1 iPerf3" 
                Start-Process powershell -Verb runAs -ArgumentList ($cmd)
                }
                else{Invoke-Expression -Command ($ToolPath + "Stop-Process.ps1 iPerf3 | Out-Null")
                } # End If
            

    } # End If
    Remove-Variable iPerf

    # 3. Delete the iPerf and ICMP firewall rules
    If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
                {$cmd = $ToolPath + "Set-iPerfFirewallRulesAdv.ps1 -Delete -FWRuleName Allow_ICMPv4_in,Allow_iPerf3_in" 
                 Start-Process powershell -PipelineVariable $iPerfPort -Verb runAs -ArgumentList ($cmd)
                }
                Else {
                    Invoke-Expression -Command ($ToolPath + "Set-iPerfFirewallRulesAdv.ps1 -Delete -FWRuleName Allow_ICMPv4_in,Allow_iPerf3_in | Out-Null")
                } # End If
    } # End Process
} # End Function


