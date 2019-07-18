# Must be run as admin
# Default iPerf port is set to 5201 unless $iPerfFWPort is set to something else
# AddFWRule function assumes ICMP and iPerf rules only
# Pass the Firewall rule Name to the DeleteFWRule function, not the display name

# 1. Evaluate and Set input parameters
# 2. Initialize
# 3. Create log file if it doesn't exist
# 4. Open Firewall rules
    #4.1 Turn On ICMPv4
    #4.2 Turn On iPerf3

# 1. Evaluate and Set input parameters for main code block  
Param($iPerfFWPort=5201,
      [string[]]$FWRuleName="",
     [switch]$Add=$false,
     [switch]$Delete=$false
     )

function AddFWRule{
    
    param($iPerfFWPort)

    # 1 Turn On ICMPv4
    Try {Get-NetFirewallRule -Name Allow_ICMPv4_in -ErrorAction Stop | Out-Null}
    Catch {New-NetFirewallRule -DisplayName "Allow ICMPv4" -Name Allow_ICMPv4_in -Action Allow -Enabled True -Profile Any -Protocol ICMPv4 | Out-Null}
    $Content = "$(Get-Date) Created a Rule: -DisplayName Allow_ICMPv4_in -Action Allow -Enabled True -Profile Any -Protocol ICMPv4"
    Add-Content -Path $File -Value $Content

    # 2 Turn On iPerf3
    Try {Get-NetFirewallRule -Name Allow_iPerf3_in -ErrorAction Stop | Out-Null}
    Catch {New-NetFirewallRule -DisplayName "Allow iPerf3" -Name Allow_iPerf3_in -Action Allow -Enabled True -Profile Any -Protocol TCP -LocalPort $iPerfFWPort | Out-Null}
    $Content = "$(Get-Date) Created a Rule: -DisplayName  Allow_iPerf3_in -Action Allow -Enabled True -Profile Any -Protocol TCP -LocalPort " + $iPerfFWPort
    Add-Content -Path $File -Value $Content
} # End Function

function DeleteFWRule{
    
    param($RuleName)

    # 1 Delete a Firewall Rule
    Try {Get-NetFirewallRule -Name $RuleName -ErrorAction Stop | Out-Null}
    Catch {
    $err = $_.Exception.Message
    $Content = "$(Get-Date) Something went wrong trying to delete the rule ""$RuleName"""
    Add-Content -Path $File -Value $Content
    $Content = "$(Get-Date) $err"
    Add-Content -Path $File -Value $Content
          } # End Catch
    Finally {
                if(-not $err){
                Remove-NetFirewallRule -Name $RuleName  | Out-Null
                $Content = "$(Get-Date) Deleted a Rule: " + $RuleName
                Add-Content -Path $File -Value $Content
                } # End If
            } # End Finally
    
    
} # End Function

# 2. Initialize
$ToolPath = "C:\ACTTools\"
$File = $ToolPath + "FW.log"
$Content = ""

# 3. Create log file if it doesn't exist
If (-Not (Test-Path $ToolPath"FW.log")){
$Content = "Firewall Rules Activity: `r`n`r`n"
New-Item -Path $File -Force -ItemType "file" -Value $Content | Out-Null
} # End If

# 4. Perform add or delete actions for Firewall rules   
if($Add){(AddFWRule $iPerfFWPort)}
if($Delete){
    foreach($Rule in $FWRuleName){
        DeleteFWRule $Rule
    }
}
