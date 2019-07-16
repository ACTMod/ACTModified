function Start-iPerfServer{

    # 1. Warning check
    # 2. Initialize
    # 3. Check for iPerf files
    # 4. Open firewall rules
    # 5. Run iPerf as a server

    <#
    .SYNOPSIS
        Start an iPerf3 server to support a client running a Get-LinkPerformance module

    .DESCRIPTION
        To perform iPerf tests, an iPerf server must be running for the client to connect to. The 
        Start-iPerfServer command will start an iPerf server and create the firewall rules required.
        The port used to start the iPerf server should match the port used on the client, 5201 is the defaault.

        The Install-LinkPerformance command should be executed first to ensure the iPerf exxecutable
        has been installed to the ACTTools directory. if the iPeerf executable is not present the command will end. 

        When called, this cmdlet will perform the following steps:
        1. Check for ncessary files
        2. Open the local host firewall for ICMP and iPerf traffic (defaults to 5201)
        3. Execute iPerf.exe with the port specified (defaults to 5201)

    .PARAMETER Force
        This optional parameter will bypass the "Are you sure" prompt and enable a silent or scripted iPerf server start up.
        
    .PARAMETER iPerfPort
        This optional parameter will start the iPerf server with a specified port.

    .EXAMPLE
        Start-iPerfServer

        This command will prompt the user to ensure they want to start an iPerf server with the default port (5201). If 
        conditions are accepted, the command continues, if not accepted, the command ends with no changes make to the host.

    .EXAMPLE
        Start-iPerfServer -Force

        This command will bypass the user prompt and start an iPerf server with the default port (5201).

    .EXAMPLE
        Start-iPerfServer -iPerfPort 443

        This command will prompt the user to ensure they want to start an iPerf server using port 443. If conditions are accepted, 
        the command continues, if not accepted, the command ends with no changes make to the host.

    .EXAMPLE
        Start-iPerfServer -Force -iPerfPort 443

        This command will bypass the user prompt and start an iPerf server using port 443.

    .LINK
        https://github.com/ACTMod/ACTModified

    #>

    Param([switch]$Force=$false,
          [int]$iPerfPort=5201)
    
    # 1. Warning check
    If (-not $Force) {
        Write-Host
        Write-Host "                               " -BackgroundColor Black
        Write-Host "  ***************************  " -ForegroundColor Red -BackgroundColor Black
        Write-Host "  ***                     ***  " -ForegroundColor Red -BackgroundColor Black
        Write-Host "  ***" -ForegroundColor Red -BackgroundColor Black -NoNewline
        Write-Host "    !!!Warning!!!    " -ForegroundColor Yellow -BackgroundColor Black -NoNewline
        Write-host "***  "  -ForegroundColor Red -BackgroundColor Black
        Write-Host "  ***                     ***  " -ForegroundColor Red -BackgroundColor Black
        Write-Host "  ***************************  " -ForegroundColor Red -BackgroundColor Black
        Write-Host "                               " -BackgroundColor Black
        Write-Host 
        Write-Host "  This script will start an iPerf server on this host" -ForegroundColor Cyan
        Write-Host "  As well as open a firewall port specified for iPerf and allow ICMPv4" -ForegroundColor Cyan
        Write-Host
        $foo = Read-Host -Prompt "Are you sure you wish to continue? [y]"
        If ($foo -ne "y" -and $foo -ne "") {Return}
    
        } # End If

    # 2. Initialize
    $ToolPath = "C:\ACTTools\"
    $File = $ToolPath + "FW.log"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # 3. Check for iPerf files
    If (-Not (Test-Path $ToolPath"iperf3.exe") -or -Not (Test-Path $ToolPath"cygwin1.dll")){
        Write-Host "iPerf files are missing."
        Write-Host "You can manually add the files and rerun this command or run Install-LinkPerformance."
        Write-Host "To manually install iPerf3:"
        Write-Host "  1. Download the zip file from $iPerf3URL"
        Write-Host "  2. Extract zipped files (iPerf3.exe and cygwin1.dll) to $ToolPath"
        Write-Host "  3. With those files in place, rerun this command."
        return
        } # End If 

    # 4. Open Firewall Rules

        # 4.1 Check for the tools path. Exit if it's not there since iPerf files would be missing too.
            
        If (-Not (Test-Path $ToolPath)){
            Write-Host "$ToolPath is missing."
            return}

        # 4.2 Call Set-iPerfFirewallRulesAdv
        If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
            {$cmd = $ToolPath + "Set-iPerfFirewallRulesAdv.ps1 -iPerfFWPort " + $iPerfPort
            Start-Process powershell -PipelineVariable $iPerfPort -Verb runAs -ArgumentList ($cmd)}
            Else {Invoke-Expression -Command ($ToolPath + "Set-iPerfFirewallRulesAdv.ps1 iPerfFWPort " + $iPerfPort + "| Out-Null")
            } # End If

    # 5. Run iPerf as a server
    If ( (Test-Path $ToolPath"iperf3.exe") -and (Test-Path $ToolPath"cygwin1.dll")){
        $ExePath = $ToolPath+"iperf3.exe"
        $Args = "-s -p" + $iPerfPort
        Start-Process $ExePath -ArgumentList ($Args)
        } # End If



} # End Function