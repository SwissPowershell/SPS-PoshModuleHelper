Write-Verbose "Processing : $($MyInvocation.MyCommand)"
Function Update-PoshModuleManifest {
    [CMDLetBinding()]
    Param(
        [Parameter(
            Position = 0,
            Mandatory = $True
        )]
        [String] ${Manifest},
        [Parameter(
            Position = 1,
            Mandatory = $True
        )]
        [Version] ${Version},
        [Parameter(
            Position = 2,
            Mandatory = $False
        )]
        [String[]] ${AddFunctions}
    )
    BEGIN {
        #region Function initialisation DO NOT REMOVE
        [String] ${FunctionName} = $MyInvocation.MyCommand
        [DateTime] ${FunctionEnterTime} = [DateTime]::Now
        Write-Verbose "Entering : $($FunctionName)"
        #endregion Function initialisation DO NOT REMOVE
        #region define constant
        $VersionLinePattern = "(?<versionline>ModuleVersion\s*=\s*'(?<Version>.*?)')"
        $FunctionsToExportPattern = "(?<FunctionsToExport>FunctionsToExport\s*=\s*(?:@\(\s*(?:(?<listInsideParenthesis>'[^']+'(?:\s*,\s*'[^']+')*)?\s*\))|(?:(?<ListOutsideParenthesis>'[^']+'(?:\s*,\s*'[^']+')*))))"
        # thank you chat GPT (after 5 back and forth)
        #endregion define constant
    }
    PROCESS {
        #region Function Processing DO NOT REMOVE
        Write-Verbose "Processing : $($FunctionName)"
        #region Function Processing DO NOT REMOVE
        #region reading manifest content
        Write-Verbose "Reading manifest content '$($Manifest)'..."
        Try {
            $ManifestContent = Get-Content -Path $Manifest -Raw:$True -Verbose:$false -ErrorAction 'Stop'
        }Catch {
            Throw "Unexpected error while trying to read manifest content from file '$($Manifest)' : $($_.Exception.Message)"
        }
        #endregion reading manifest content
        #region update version
        Write-Verbose 'Updating version...'
        # search for the line containing the version (ModuleVersion = '')
        $VersionRegexMatch = Select-String -InputObject $ManifestContent -Pattern $VersionLinePattern -AllMatches
        if ($VersionRegexMatch) {
            $VersionGroups = $VersionRegexMatch | Select-Object -ExpandProperty 'Matches' | Select-Object -ExpandProperty 'Groups'
            $TextToUpdate =  $VersionGroups | Where-Object {$_.Name -eq 'VersionLine'} | Select-Object -ExpandProperty 'Value'
            $VersionToUpdate = $VersionGroups | Where-Object {$_.Name -eq 'Version'} | Select-Object -ExpandProperty 'Value'
            $NewText = $TextToUpdate.replace($VersionToUpdate,$Version)
            $ManifestContent = $ManifestContent -replace $TextToUpdate,$NewText
        }Else{
            Throw "Unable to identify version, please update manually manifest file '$($Manifest)'"
        }
        #endregion update version
        #region update function list
        if ($AddFunctions.Count -gt 0) {
            Write-Verbose 'Updating function list...'
            # Search for function list
            $NewFunctions = $AddFunctions | ForEach-Object {"`'$($_)`'"}
            $FunctionsRegexMatch = Select-String -InputObject $ManifestContent -Pattern $FunctionsToExportPattern -AllMatches
            if ($FunctionsRegexMatch) {
                $FunctionsToExportGroups = $FunctionsRegexMatch | Select-Object -ExpandProperty 'Matches' | Select-Object -ExpandProperty 'Groups'
                $TextToUpdate = $FunctionsToExportGroups | Where-Object {$_.Name -eq 'FunctionsToExport'} | Select-Object -ExpandProperty 'Value'
                $FunctionsListInParenthesis = $FunctionsToExportGroups | Where-Object {$_.Name -eq 'listInsideParenthesis'} | Select-Object -ExpandProperty 'Value'
                $FunctionsListOutsideParenthesis = $FunctionsToExportGroups | Where-Object {$_.Name -eq 'ListOutsideParenthesis'} | Select-Object -ExpandProperty 'Value'
                if ($Null -notlike $FunctionsListInParenthesis) {
                    # the list is in format @()
                    $List = $FunctionsListInParenthesis -split ',' | ForEach-Object {$_.Trim()}
                    $NewList = $list + $NewFunctions
                    $IsMultiLine = $FunctionsListInParenthesis -like "*`r`n*"
                    if ($IsMultiLine -eq $True) {
                        $NewFunctionsString = $NewList -join ", `r`n"
                    }Else{
                        $NewFunctionsString = $NewList -join ', '
                    }
                    $NewText = $TextToUpdate.replace($FunctionsListInParenthesis,$NewFunctionsString)
                    $ManifestContent = $ManifestContent.replace($TextToUpdate,$NewText)
                }Elseif ($Null -notlike $FunctionsListOutsideParenthesis) {
                    $List = $FunctionsListOutsideParenthesis -split ',' | ForEach-Object {$_.Trim()}
                    if ($List -eq "'*'") {
                        # List is '*' => do nothing
                    }Else{
                        $NewList = $list + $NewFunctions
                        $NewFunctionsString = $NewList -join ', '
                        $NewText = $TextToUpdate.replace($FunctionsListOutsideParenthesis,$NewFunctionsString)
                        $ManifestContent = $ManifestContent.replace($TextToUpdate,$NewText)
                    }
                }Else{
                    # List is @() => add the functions
                    $NewFunctionsString = $NewFunctions -join ', '
                    $ManifestContent = $ManifestContent.replace($TextToUpdate,"FunctionsToExport = @($($NewFunctionsString))")
                }
            }Else{
                Throw "Unable to identify FunctionsToExport, please update manually manifest file '$($Manifest)'"
            }
            
        }
        #endregion update function list
        #region write manifest
        Try {
            Set-Content -Path $Manifest -Value $ManifestContent -Force -Verbose:$False -ErrorAction 'Stop'
        }Catch {
            Throw "Unexpected error while set content of '$($Manifest)' : $($_.Exception.Message)"
        }
        #endregion
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