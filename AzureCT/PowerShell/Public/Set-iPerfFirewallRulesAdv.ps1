# Must be run as admin

# 1. Evaluate and Set input parameters
# 2. Initialize
# 3. Create Log File
# 4. Open Firewall rules
    #4.1 Turn On ICMPv4
    #4.2 Turn On iPerf3

# 1. Evaluate and Set input parameters  
Param($iPerfFWPort=5201)

# 2. Initialize
$ToolPath = "C:\ACTTools\"
$File = $ToolPath + "FW.log"
$Content = ""

# 3. Create log file if it doesn't exist
If (-Not (Test-Path $ToolPath"FW.log")){
$Content = "Firewall Rules Created: `r`n`r`n"
New-Item -Path $File -Force -ItemType "file" -Value $Content | Out-Null
} # End If

# 4. Open Firewall rules

    # 4.1 Turn On ICMPv4
    Try {Get-NetFirewallRule -Name Allow_ICMPv4_in -ErrorAction Stop | Out-Null}
    Catch {New-NetFirewallRule -DisplayName "Allow ICMPv4" -Name Allow_ICMPv4_in -Action Allow -Enabled True -Profile Any -Protocol ICMPv4 | Out-Null}
    $Content = "$(Get-Date) Allow_ICMPv4_in -Action Allow -Enabled True -Profile Any -Protocol ICMPv4"
    Add-Content -Path $File -Value $Content

    # 4.2 Turn On iPerf3
    Try {Get-NetFirewallRule -Name Allow_iPerf3_in -ErrorAction Stop | Out-Null}
    Catch {New-NetFirewallRule -DisplayName "Allow iPerf3" -Name Allow_iPerf3_in -Action Allow -Enabled True -Profile Any -Protocol TCP -LocalPort $iPerfFWPort | Out-Null}
    $Content = "$(Get-Date) Allow_iPerf3_in -Action Allow -Enabled True -Profile Any -Protocol TCP -LocalPort " + $iPerfFWPort
    Add-Content -Path $File -Value $Content