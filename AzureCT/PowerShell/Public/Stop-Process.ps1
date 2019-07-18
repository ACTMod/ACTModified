     [cmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    Param(
          [string[]]$Procs
          )

    Begin {
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
    }
    
    Process{
        foreach($Proc in $Procs){
        $Proccess = Get-Process iperf3 -ErrorAction SilentlyContinue
        # try gracefully first
            $Proccess.CloseMainWindow() | Out-Null
        # kill after five seconds
        Sleep 5
        if (!$Proccess.HasExited) {
            $Proccess | Stop-Process -Force
            } # End If
        } # End For
        
    } # End Function

    End{}