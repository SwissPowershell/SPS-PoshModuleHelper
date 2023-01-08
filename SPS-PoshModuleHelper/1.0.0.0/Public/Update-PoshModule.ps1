Write-Verbose "Processing : $($MyInvocation.MyCommand)"
Function Update-PoshModule {
    [CMDLetBinding(DefaultParameterSetName = '_Default')]
    Param(
        [Parameter(
            Position = 0,
            Mandatory = $True
        )]
        [String] ${Name},
        [Parameter(
            Position = 1,
            Mandatory = $True,
            ParameterSetName = 'ByVersion'
        )]
        [Version] ${Version},
        [Parameter(
            Position = 1,
            Mandatory = $False,
            ParameterSetName = 'ByType'
        )]
        [Switch] ${Major},
        [Parameter(
            Position = 2,
            Mandatory = $False,
            ParameterSetName = 'ByType'
        )]
        [Switch] ${Minor},
        [Parameter(
            Position = 3,
            Mandatory = $False,
            ParameterSetName = 'ByType'
        )]
        [Switch] ${Build},
        [Parameter(
            Position = 4,
            Mandatory = $False,
            ParameterSetName = 'ByType'
        )]
        [Switch] ${Revision},
        [Parameter(
            Position = 5,
            Mandatory = $False
        )]
        [String[]] ${AddFunctions},
        [Parameter(
            Position = 6,
            Mandatory = $False
        )]
        [String[]] ${AddPrivateFunctions},
        [Parameter(
            Position = 7,
            Mandatory = $False
        )]
        [String[]] ${AddClasses},
        [Parameter(
            Position = 8,
            Mandatory = $False
        )]
        [String[]] ${AddEnums},
        [Parameter(
            Position = 9,
            Mandatory = $False
        )]
        [Switch] ${Keep},
        [Parameter(
            Position = 10,
            Mandatory = $False
        )]
        [Switch] ${Global},
        [Parameter(
            Position = 11,
            Mandatory = $False
        )]
        [Switch] ${Minimal}
    )
    BEGIN {
        #region Function initialisation DO NOT REMOVE
        [String] ${FunctionName} = $MyInvocation.MyCommand
        [DateTime] ${FunctionEnterTime} = [DateTime]::Now
        Write-Verbose "Entering : $($FunctionName)"
        #endregion Function initialisation DO NOT REMOVE
        #region identify source module
        Write-Verbose 'Getting all modules...'
        $AllModules = Get-Module -ListAvailable -Verbose:$False -ErrorAction SilentlyContinue
        Write-Verbose "Searching for module with name '$($Name)'..."
        $SourceModule = $AllModules | Where-Object {$_.Name -eq $Name} | Sort-Object 'Version' | Select-Object -Last 1
        if ($Null -eq $SourceModule){
            Throw "Unable to identify module '$($Name)' in available module list"
        }Else{
            Write-Verbose "Module identified in version '$($SourceModule.Version.ToString())'"
        }
        #endregion identify source module
        #region find module path
        Write-Verbose 'Searching module path...'
        [String[]] ${AllModulesPath} = $Env:PSModulePath -split ';'
        if ($Global -eq $True) {
            # To Write a Global module you need admin rights
            $IsAdmin = $(New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
            if ($IsAdmin -ne $True) {
                Throw "In order to create a 'Global' module you need admin rights !"
            }Else{
                # Module is stored in program files
                Write-Verbose "The user is admin and can create a Global module"
                $ModulePattern = [regex]::escape("$($Env:ProgramFiles)\$($PowershellPath)\")
            }
        }Else{
            # Module will be stored in my document
            $ModulePattern = [Regex]::escape("$([Environment]::GetFolderPath("MyDocuments"))\$($PowershellPath)")
        }
        [String] ${ModuleRootPath} = $AllModulesPath | Where-Object {$_ -match $ModulePattern} | Select-Object -First 1
        if ($ModuleRootPath -eq '') {
            Throw 'Unexpected error : unable to find a valid module path using standards'
        }Else {
            Write-Verbose "The module will be created in $($ModuleRootPath)"
        }
        #endregion find module path
        #region validate that the public functions are valid and unique
        Write-Verbose "Validating that function are unique and valid..."
        ${AllFunctions} = $AllModules | Select-Object -ExpandProperty ExportedCommands | Select-Object -ExpandProperty 'Values'
        [String[]] ${AllowedVerbs} = Get-Verb | Select-Object -ExpandProperty 'Verb'
        $FunctionPattern = '^(?<verb>\w+?)-(?<noun>\w+?)$'
        if ($AddFunctions.Count -gt 0) {
            $NewFunctionList = @()
            ForEach ($Function in $AddFunctions){
                # The function name should not allready exist in the available modules
                $ExistingFunction = $AllFunctions | Where-Object {$_.Name -eq $Function} | Sort-Object 'Version' | Select-Object -last 1
                if ($ExistingFunction) {
                    Throw "The public function '$($Function)' allready exist in module '$($ExistingFunction | Select-Object -ExpandProperty 'Source')', please use a different function name"
                }Else{
                    Write-Verbose "Function named '$($Function)' is not yet used"
                }
                # The function should match the Verb-noun format
                $RegexMatch = Select-String -InputObject $Function -Pattern $FunctionPattern
                if ($RegexMatch) {
                    # it match the verb-noun format check if the verb is allowed
                    $Verb = $RegexMatch | Select-Object -ExpandProperty 'Matches' | Select-Object -ExpandProperty 'Groups' | Where-Object {$_.Name -eq 'verb'} | Select-Object -ExpandProperty 'Value'
                    if ($Verb -notin $AllowedVerbs) {
                        Write-Warning "The public function '$($Function)' verb '$($verb)' is not an allowed verb, to get allowed verb use command Get-Verb"
                    }
                    $Verb = "$($Verb.substring(0,1).toupper())$($Verb.substring(1).tolower())"
                    $Noun = $RegexMatch | Select-Object -ExpandProperty 'Matches' | Select-Object -ExpandProperty 'Groups' | Where-Object {$_.Name -eq 'noun'} | Select-Object -ExpandProperty 'Value'
                    $Noun = "$($Noun.substring(0,1).toupper())$($Noun.substring(1))"
                    $NewFunctionList += "$($Verb)-$($Noun)"
                }Else{
                    Write-Warning "The public function '$($Function)' does not respect the verb-noun format"
                    $Function = "$($Function.substring(0,1).toupper())$($Function.substring(1).tolower())"
                    $NewFunctionList += "$($Function)"
                }
            }
            $AddFunctions = $NewFunctionList
        }
        #endregion validate that the public functions are valid and unique
        #region validate that the private functions are valid and unique
        if ($AddPrivateFunctions.count -gt 0) {
            $NewPrivateFunctionList = @()
            ForEach ($Function in $AddPrivateFunctions){
                if ($AddFunctions -contains $Function) {
                    Throw "You cannot add a function to both public and private"
                }
                # The function name should not allready exist in the available modules
                $ExistingFunction = $AllFunctions | Where-Object {$_.Name -eq $Function} | Sort-Object 'Version' | Select-Object -last 1
                if ($ExistingFunction) {
                    Throw "The private function '$($Function)' allready exist in module '$($ExistingFunction | Select-Object -ExpandProperty 'Source')', please use a different function name"
                }Else{
                    Write-Verbose "Function named '$($Function)' is not yet used"
                }
                # The function should match the Verb-noun format
                $RegexMatch = Select-String -InputObject $Function -Pattern $FunctionPattern
                if ($RegexMatch) {
                    # it match the verb-noun format check if the verb is allowed
                    $Verb = $RegexMatch | Select-Object -ExpandProperty 'Matches' | Select-Object -ExpandProperty 'Groups' | Where-Object {$_.Name -eq 'verb'} | Select-Object -ExpandProperty 'Value'
                    if ($Verb -notin $AllowedVerbs) {
                        Write-Warning "The private function $($Function) verb $($verb) is not an allowed verb, to get allowed verb use command Get-Verb"
                    }
                    $Verb = "$($Verb.substring(0,1).toupper())$($Verb.substring(1).tolower())"
                    $Noun = $RegexMatch | Select-Object -ExpandProperty 'Matches' | Select-Object -ExpandProperty 'Groups' | Where-Object {$_.Name -eq 'noun'} | Select-Object -ExpandProperty 'Value'
                    $Noun = "$($Noun.substring(0,1).toupper())$($Noun.substring(1))"
                    $NewPrivateFunctionList += "$($Verb)-$($Noun)"
                }Else{
                    Write-Warning "The private function $($Function) does not respect the verb-noun format"
                    $Function = "$($Function.substring(0,1).toupper())$($Function.substring(1))"
                    $NewPrivateFunctionList += "$($Function)"
                }
            }
            $AddPrivateFunctions = $NewPrivateFunctionList
        }
        #endregion validate that the private functions are valid and unique
        #region validate classes are unique
        if ($AddClasses.Count -gt 0) {
            Write-Verbose "Validating that class are unique and valid..."
            $ClassPattern = '^[\w]+$'
            ForEach($Class in $AddClasses) {
                if ($Class -match $ClassPattern) {
                    # class is valid name check if it allready exist
                    Try {
                        New-Object -TypeName $Class -ErrorAction Stop -Verbose:$False | out-null
                    }Catch {
                        if ($_.Exception.Message -notmatch "Cannot find type") {
                            Throw "The class '$($Class)' allready exist, please use a different class name"
                        }else{
                            # no class with that name exist
                        }
                    }
                    Write-Verbose "Class '$($Class)' is not yet used"
                }Else{
                    Throw "Class '$($Class)' contains not allowed characters, please use a different class name"
                }
            }
        }
        #endregion validate classes are unique
        #region validate enum are unique
        if ($AddEnums.Count -gt 0) {
            Write-Verbose "Validating that Enum are unique and valid..."
            $EnumPattern = '^[\w]+$'
            ForEach($Enum in $AddEnums) {
                if ($Enum -match $EnumPattern) {
                    # class is valid name check if it allready exist
                    Try {
                        New-Object -TypeName $Enum -ErrorAction Stop -Verbose:$False | out-null
                    }Catch {
                        if ($_.Exception.Message -notmatch "Cannot find type") {
                            Throw "The Enum '$($Enum)' allready exist, please use a different Enum name"
                        }else{
                            # no class with that name exist
                        }
                    }
                    Write-Verbose "Enum '$($Enum)' is not yet used"
                }Else{
                    Throw "Enum '$($Enum)' contains not allowed characters, please use a different class name"
                }
            }
        }
        #region define the version
        switch ($PsCmdlet.ParameterSetName) {
            '_default' {
                #region define if it's a minor or a revision update
                if (($AddFunctions.count -gt 0) -or ($AddPrivateFunctions.count -gt 0) -or ($AddClasses.count -gt 0) -or ($AddEnums.count -gt 0)) {
                    # adding a function or a class is a minor update
                    $Version = $SourceModule.Version
                    $MinorStr = $Version.Minor + 1
                    $RevisionStr = $Version.Revision + 1
                    $NewVersion = New-Object System.Version -ArgumentList $Version.Major,$MinorStr, $Version.Build, $RevisionStr
                    $Version = $NewVersion
                }Else{
                    # just updating the version is a revision
                    $Version = $SourceModule.Version
                    $RevisionStr = $Version.Revision + 1
                    $NewVersion = New-Object System.Version -ArgumentList $Version.Major,$Version.Minor, $Version.Build, $RevisionStr
                    $Version = $NewVersion
                }
                #endregion define if it's a minor or a revision update
                BREAK
            }
            'ByVersion' {
                # check that the version is greater than the higher version of this module
                if ($Version -le $SourceModule.Version) {
                    Throw "The new version cannot be smaller or equal to the highest version of this module ($($SourceModule.Version.ToString()))"
                }
                BREAK
            }
            'ByType' {
                $Version = $SourceModule.Version
                if ($Major -eq $True) {
                    $MajorStr = $Version.Major + 1
                    $RevisionStr = $Version.Revision + 1
                    $NewVersion = New-Object System.Version -ArgumentList $MajorStr,$Version.Minor, $Version.Build, $RevisionStr
                    $Version = $NewVersion
                }
                if ($Minor -eq $True) {
                    $MinorStr = $Version.Minor + 1
                    $RevisionStr = $Version.Revision + 1
                    $NewVersion = New-Object System.Version -ArgumentList $Version.Major,$MinorStr, $Version.Build, $RevisionStr
                    $Version = $NewVersion
                }
                if ($Build -eq $True) {
                    $BuildStr = $Version.Build + 1
                    $RevisionStr = $Version.Revision + 1
                    $NewVersion = New-Object System.Version -ArgumentList $Version.Major,$Version.Minor, $BuildStr, $RevisionStr
                    $Version = $NewVersion
                }
                if ($Revision -eq $True) {
                    $RevisionStr = $Version.Revision + 1
                    $NewVersion = New-Object System.Version -ArgumentList $Version.Major,$Version.Minor, $Version.Build, $RevisionStr
                    $Version = $NewVersion
                }
                BREAK
            }
        }
        Write-Verbose "The new module version will be '$($Version)'"
        #endregion define the version
        #region define the constant
        [String] ${PublicSubName} = 'Public'
        [String] ${PrivateSubName} = 'Private'
        [String] ${EnumSubName} = 'Enum'
        [String] ${ClassSubName} = 'Class'
        #endregion define the constant
    }
    PROCESS {
        #region Function Processing DO NOT REMOVE
        Write-Verbose "Processing : $($FunctionName)"
        #region Function Processing DO NOT REMOVE

        #region copy the original module content
        $SourcePath = $SourceModule | Select-Object -ExpandProperty 'ModuleBase'
        $TargetPath = "$($ModuleRootPath)\$($Name)\$($Version)"
        Write-Verbose "Copying file from '$($SourcePath)' to '$($TargetPath)'"
        Try {
            Copy-Item -Path $SourcePath -Destination $TargetPath -Container -Recurse -Verbose:$False -ErrorAction 'Stop'
        }Catch {
            Throw "Unexpected error while copying from '$($SourcePath)' to '$($TargetPath)': $($_.Exception.Message)"
        }
        #endregion copy the original module content
        #region add public function file
        ForEach ($Function in $AddFunctions) {
            $FunctionPath = "$($TargetPath)\$($PublicSubName)\$($Function).ps1"
            New-PoshModuleFunctionFile -Path $FunctionPath -Name $Function -Public -Minimal:$Minimal
        }
        #endregion add public function file
        #region add private function file
        ForEach ($Function in $AddPrivateFunctions) {
            $FunctionPath = "$($TargetPath)\$($PrivateSubName)\$($Function).ps1"
            New-PoshModuleFunctionFile -Path $FunctionPath -Name $Function -Minimal:$Minimal
        }
        #endregion add private function file
        #region add Enum file
        ForEach ($Enum in $AddEnums) {
            $EnumPath = "$($TargetPath)\$($EnumSubName)\$($Enum).ps1"
            New-PoshModuleEnumFile -Path $EnumPath -Name $Enum
        }
        #endregion add Enum file
        #region add class file
        ForEach ($Class in $AddClasses) {
            $ClassPath = "$($TargetPath)\$($ClassSubName)\$($Class).ps1"
            New-PoshModuleClassFile -Path $ClassPath -Name $Class
        }
        #endregion add class file
        #region update manifest file
        $ManifestFileFullName = Get-Item -Path "$($TargetPath)\$($Name).psd1"
        Write-Verbose "Updating manifest in '$($ManifestFileFullName)'"
        Update-PoshModuleManifest -Manifest $ManifestFileFullName -Version $Version -AddFunctions $AddFunctions
        #endregion update manifest file
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

Export-ModuleMember -Function 'Update-PoshModule'