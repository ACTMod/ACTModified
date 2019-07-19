     [cmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    Param(
          [string[]]$Procs
          )

    Begin {
        
        Function Get-RegistryValue($key, $value) {  
        # Gets the registry settings for UAC prompts
        (Get-ItemProperty $key $value).$value
        } # End Function  

        # Location of UAC prompt registry settings
        $Key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" 
        $ConsentPromptBehaviorAdmin_Name = "ConsentPromptBehaviorAdmin" 
        $PromptOnSecureDesktop_Name = "PromptOnSecureDesktop" 

        if (-not $PSBoundParameters.ContainsKey('Verbose')) {
            $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference')
        }
        if (-not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
        }
        if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
            $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference')
        }
        Write-Verbose ('[{0}] Confirm={1} ConfirmPreference={2} WhatIf={3} WhatIfPreference={4}' -f $MyInvocation.MyCommand, $Confirm, $ConfirmPreference, $WhatIf, $WhatIfPreference)
    } # End Begin
    
    Process{
        
        # Check for UAC prompt settings
        $AdminPrompt = Get-RegistryValue $Key $ConsentPromptBehaviorAdmin_Name 
        $DesktopPrompt = Get-RegistryValue $Key $PromptOnSecureDesktop_Name
        
        # If set to not prompt warn and ask to continue
        if ($AdminPrompt -eq 0 -and $DesktopPrompt -eq 0){
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
        Write-Host "  Your security settings are set to not prompt about dangerous activities" -ForegroundColor Cyan
        Write-Host
        $foo = Read-Host -Prompt "Are you sure you wish to continue? [y]"
        If ($foo -ne "y" -and $foo -ne "") {Return}
        } # End If

        foreach($Proc in $Procs){
        $Proccess = Get-Process $Proc -ErrorAction SilentlyContinue
        # try gracefully first
            $Proccess.CloseMainWindow() | Out-Null
        # kill after five seconds
        Sleep 5
        if (!$Proccess.HasExited) {
            $Proccess | Stop-Process -Force
            } # End If
        } # End For
        
    } # End Process

    End{}
