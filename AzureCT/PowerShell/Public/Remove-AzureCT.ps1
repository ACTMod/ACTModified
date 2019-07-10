# Remove-AzureCT
function Remove-AzureCT {
    
    Clear-AzureCTHistory -ErrorAction SilentlyContinue

    $ToolPath = "C:\ACTTools\"
    If (Test-Path $ToolPath){
        Remove-Item -Force -Path $ToolPath -Recurse -ErrorAction Stop | Out-Null
        Write-Host "AzureCT tools directory removed" -ForegroundColor Green
    } # End If

    # $Destination = Join-Path -Path ([Environment]::GetFolderPath('MyDocuments')) -ChildPath 'WindowsPowerShell\Modules\AzureCT'
    $Destination = 'C:\Program Files\WindowsPowerShell\Modules\AzureCT\'
    If (Test-Path $Destination) {
        Try {
            Remove-Item $Destination -Recurse
            Write-Host "AzureCT PowerShell Module removed" -ForegroundColor Green
        }
        Catch {
            Write-Warning "The AzureCT PowerShell Module was not removed."
            Write-Warning "You should manually delete the AzureCT directory at:"
            Write-Warning $Destination
        } #End Try
    }
    Else {
        Write-Host "AzureCT PowerShell Module was not found on this machine."
    } # End If
    
    Remove-Module -Name AzureCT -ErrorAction SilentlyContinue
    Write-Host "AzureCT module unloaded from memory" -ForegroundColor Green

    Write-Host "AzureCT removed" -ForegroundColor Green
} # End Function