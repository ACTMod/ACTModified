    Function Get-AzureCT {

        <#

        .SYNOPSIS
        Downloads critial files required to run the Get-LinkPerformance command in the Azure Connectivity Toolkit.

        .DESCRIPTION
        The Install-LinkPerformance cmdlet did not have a local install function. To separate the local and GitHub 
        and local installation activities, the GitHub download ralated commands were moved here. 
        
        #>

        Param([switch]$iPerf=$false,
              [switch]$PSPing=$false,
              [switch]$OtherFiles
             )
    
        # 2. Initialize
        $ToolPath = "C:\ACTTools\"
        $GitHubURL = "https://raw.githubusercontent.com/tracsman/NetworkMonitoring/LinkPerf/AzureCT/PowerShell/AzureCT/Public/"
        $PSPingURL = "https://live.sysinternals.com/psping.exe"
        $iPerf3URL = "https://iperf.fr/download/windows/iperf-3.1.3-win64.zip"
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        # 3. Create C:\ACTTools dir
        If (-Not (Test-Path $ToolPath)){New-Item -ItemType Directory -Force -Path $ToolPath | Out-Null}

        # 4. Download and extract iPerf and Cygwin
        
        If ($iPerf) {
        
        $File = $ToolPath + "iperf-3.1.3-win64.zip"
        Try {
            $webClient = new-object System.Net.WebClient
            $webClient.DownloadFile($iPerf3URL, $File)
            }
        Catch {
            Write-Host
            Write-Warning "Something bad happened with the iPerf download. Most likely either files are missing at the source or this host doesn't have internet access."
            Write-Host
            Write-Host "You can manually add the files and rerun this Install script."
            Write-Host "To manually install iPerf3:"
            Write-Host "  1. Download the zip file from $iPerf3URL"
            Write-Host "  2. Extract zipped files (iPerf3.exe and cygwin1.dll) to $ToolPath"
            Write-Host "  3. With those files in place, rerun this install."
            Write-Host
            Return
            } # End Try

        Try {
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            [System.IO.Compression.ZipFile]::ExtractToDirectory($File, $ToolPath)
            move-item -path ($ToolPath + "iperf-3.1.3-win64\*.*") -destination $ToolPath -Force
            Remove-Item -Path ($ToolPath + "iperf-3.1.3-win64\") -Force
            Remove-Item -Path $File -Force
            }
        Catch {
            Write-Host
            Write-Warning "Something bad happened Unzipping and moving the iPerf files. Most likely .Net or other required subsystem files are not loaded."
            Write-Host
            Write-Host "You can manually add the files and rerun this Install script."
            Write-Host "To manually install iPerf3:"
            Write-Host "  1. Find $File"
            Write-Host "  2. Extract zipped files (iPerf3.exe and cygwin1.dll) to $ToolPath (not a subdirectory!)"
            Write-Host "  3. With those files in place, rerun this install."
            Write-Host
            Return
            } # End Try
        } # End If

        # 5. Check for PSPing
        If ($PSPing){
        $File = $ToolPath + "psping.exe"
        Try {
            $webClient = new-object System.Net.WebClient
            $webClient.DownloadFile($PSPingURL, $File)
            }
        Catch {
            Write-Host
            Write-Warning "Something bad happened with the PSPing download. Most likely either files are missing at the source or this host doesn't have internet access."
            Write-Host
            Write-Host "You can manually add the file and rerun this Install script."
            Write-Host "To manually install PSPing:"
            Write-Host "  1. Download the file from $PSPingURL"
            Write-Host "  2. Move the psping.exe file to the $ToolPath directory."
            Write-Host "  3. With psping.exe in place, rerun this install."
            Write-Host
            Return
            } # End Try
        } # End If

        # 7. Pull from GitHub if needed
        If ($OtherFiles) {
        Try {
            ForEach ($File in $FileName) {
                $webClient = new-object System.Net.WebClient
                $webClient.DownloadFile( $GitHubURL + $File, $ToolPath + $File )
                } #End ForEach
            }
        Catch {
            Write-Host
            Write-Warning "Something bad happened pulling files from GitHub. Most likely either files are missing at the source or this host doesn't have internet access."
            Write-Host
            Write-Host "You can manually add the four files and rerun this Install script."
            Write-Host "To manually install the files:"
            Write-Host "  1. Go to $GitHubURL"
            Write-Host "  2. Save the files 'Set-iPerfFirewallRules.ps1' and 'README.md' to the local $ToolPath directory."
            Write-Host "  3. With these files in place, rerun this install."
            Write-Host
            Return
            } # End Try
        } # End If

    } # End Function