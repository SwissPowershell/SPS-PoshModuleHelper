Write-Verbose "Processing : $($MyInvocation.MyCommand)"
Function New-PoshModuleClassFile {
    [CMDLetBinding()]
    Param(
        [Parameter(
            Position = 0,
            Mandatory = $True
        )]
        [Alias('ClassName')]
        [String] ${Name},
        [Parameter(
            Position = 1,
            Mandatory = $True
        )]
        [String] ${Path}
    )
    BEGIN {
        #region Function initialisation DO NOT REMOVE
        [String] ${FunctionName} = $MyInvocation.MyCommand
        [DateTime] ${FunctionEnterTime} = [DateTime]::Now
        Write-Verbose "Entering : $($FunctionName)"
        #endregion Function initialisation DO NOT REMOVE
        $CommonHeader = 'Write-Verbose "Processing : $($MyInvocation.MyCommand)"'
        $ClassContent = @"
$($CommonHeader)

Class $($Name) {
    $($Name)() {}
    [String] ToString() {
        Return ''
    }
}
"@
    }
    PROCESS {
        #region Function Processing DO NOT REMOVE
        Write-Verbose "Processing : $($FunctionName)"
        #region Function Processing DO NOT REMOVE
        Write-Verbose "Creating Class '$($Name)' file "
        Try {
            $Null = Set-Content -Path $Path -Value $ClassContent -Force
        }Catch {
            Throw "Unable to create class '$($Name)' file : $($_.Exception.Message)"
        }
    }
    END {
        #region Function closing  DO NOT REMOVE
        $TimeSpent = New-TimeSpan -Start $FunctionEnterTime -Verbose:$False -ErrorAction SilentlyContinue
        [String] ${TimeSpentString} = ''
        Switch ($TimeSpent) {
            {$_.TotalDays -gt 1} {
                $TimeSpentString = "$($_.TotalDays) D."
                BREAK
            }
            {$_.TotalHours -gt 1} {
                $TimeSpentString = "$($_.TotalHours) h."
                BREAK
            }
            {$_.TotalMinutes -gt 1} {
                $TimeSpentString = "$($_.TotalMinutes) min."
                BREAK
            }
            {$_.TotalSeconds -gt 1} {
                $TimeSpentString = "$($_.TotalSeconds) s."
                BREAK
            }
            {$_.TotalMilliseconds -gt 1} {
                $TimeSpentString = "$($_.TotalMilliseconds) ms."
                BREAK
            }
            Default {
                $TimeSpentString = "$($_.Ticks) Ticks"
                BREAK
            }
        }
        Write-Verbose "Ending : $($FunctionName) - TimeSpent : $($TimeSpentString)"
        #endregion Function closing  DO NOT REMOVE
    }
}