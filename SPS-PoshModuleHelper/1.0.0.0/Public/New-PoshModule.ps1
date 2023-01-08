Write-Verbose "Processing : $($MyInvocation.MyCommand)"
Function New-PoshModule {
    [CMDLetBinding()]
    Param(
        [Parameter(
            Position = 0,
            Mandatory = $True
        )]
        [String] ${Name},
        [Parameter(
            Position = 1,
            Mandatory = $False
        )]
        [Version] ${Version} = '1.0.0.0',
        [Parameter(
            Position = 2,
            Mandatory = $False
        )]
        [String] ${Description},
        [Parameter(
            Position = 3,
            Mandatory = $False
        )]
        [String] ${Guid} = $([GUID]::NewGUID() | Select-Object -ExpandProperty 'Guid'),
        [Parameter(
            Position = 4,
            Mandatory = $False
        )]
        # [String] ${Author} = 'Swiss Powershell',
        [String] ${Author} = "$($Env:UserName)",
        [Parameter(
            Position = 5,
            Mandatory = $False
        )]
        # [String] ${CompanyName} = 'SwissPowershell',
        [String] ${CompanyName} = "$($Author)'s Company",
        [Parameter(
            Position = 6,
            Mandatory = $False
        )]
        [String] ${Copyright} = "(c) $([DateTime]::Now | Select-Object -ExpandProperty Year) $($CompanyName). All rights reserved.",        
        [Parameter(
            Position = 7,
            Mandatory = $False
        )]
        [Alias('PublicFunctions')]
        [String[]] ${Functions},
        [Parameter(
            Position = 8,
            Mandatory = $False
        )]
        [String[]] ${PrivateFunctions},
        [Parameter(
            Position = 9,
            Mandatory = $False
        )]
        [String[]] ${Enums},
        [Parameter(
            Position = 10,
            Mandatory = $False
        )]
        [String[]] ${Classes},
        [Parameter(
            Position = 11,
            Mandatory = $False
        )]
        [Switch] ${Global},
        [Parameter(
            Position = 12,
            Mandatory = $False
        )]
        [Switch] ${VerboseDebug},
        [Parameter(
            Position = 13,
            Mandatory = $False
        )]
        [Switch] ${Strict},
        [Parameter(
            Position = 14,
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
        #region validate parameters
        #region validate the module name
        $Name = "$($Name.substring(0,1).toupper())$($Name.substring(1))"
        [String] $NamePattern = '^[^<\s*?"\\>:|]+$'
        if ($Name -NotMatch $NamePattern) {
            Throw "The module name '$($Name)' contains illegal character, please use a name that not contains (^< *?`"\>: or |)"
        }
        #endregion validate the module name
        #region validate Scope and define module path
        Write-Verbose 'Validating scope and defining module path...'
        [Version] ${CurrentPSVersion} = $PSVersionTable.PSVersion
        [String[]] ${AllModulesPath} = $Env:PSModulePath -split ';'
        if ($CurrentPSVersion -lt '5.2') {
            # Current PS Version is 5.1.x => Module is stored in WindowsPowershell Subdir
            [String] ${PowershellPath} = 'WindowsPowershell'
        }Else {
            # Current PS Version is core =>  => Module is stored in Powershell Subdir
            [String] ${PowershellPath} = 'Powershell'
        }
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
        #endregion validate Scope and define module path
        #region validate that a module with the same name does not allready exist
        [Boolean] ${ExistAsSub} = $False
        [Boolean] ${ExistAsAvailable} = $False
        Write-Verbose "Getting all available modules..."
        $AllModules = Get-Module -ListAvailable:$True -Verbose:$False
        Write-Verbose "Searching if '$($Name)' exist as a child of any of the module path"
        ForEach ($Path in $AllModulesPath) {
            [Boolean] ${Exist} = $(Get-ChildItem -LiteralPath $Path -Directory -Verbose:$False -ErrorAction Ignore | Select-Object -ExpandProperty 'Name') -contains $Name
            if ($Exist -eq $True) {
                Write-Verbose "The module '$($Name)' exist in $($Path)"
                $ExistAsSub = $True
            }
        }
        if ($ExistAsSub -eq $False) {
            Write-Verbose "Searching if $($Name) exist in available module"
            $ExistAsAvailable = $($AllModules | Select-Object -ExpandProperty 'Name') -contains $Name
        }
        
        if ($ExistAsSub -eq $True) {
            Throw "A module named '$($Name)' has been found in modules subdir, please use Update-PSModule to update the module"
        }Elseif ($ExistAsAvailable -eq $True) {
            Throw "A module named '$($Name)' allready exist as an available module, please use Update-PSModule to update the module"
        }
        #endregion validate that a module with the same name does not allready exist
        #region validate that the guid is not allready used
        [Boolean] ${ExitLoop} = $False
        Do {
            [PSModuleInfo] ${SameGuidModule} = $AllModules | Where-Object {$_.Guid -eq $Guid}
            if ($SameGuidModule) {
                #Throw "A module with guid $($Guid) allready exist ($($SameGuidModule)), please use a different GUID"
                Write-Warning "The GUID '$($Guid)' is allready used by $($SameGuidModule) a different guid will be used"
                $Guid = $([GUID]::NewGUID() | Select-Object -ExpandProperty 'Guid')
                Write-Verbose "Guid is now '$($Guid)'"
            }else {
                $ExitLoop = $True
            }
        }Until ($ExitLoop -eq $True)
        #endregion validate that the guid is not allready used
        #region validate that the public functions are valid and unique
        Write-Verbose "Validating that function are unique and valid..."
        ${AllFunctions} = $AllModules | Select-Object -ExpandProperty ExportedCommands | Select-Object -ExpandProperty 'Values'
        [String[]] ${AllowedVerbs} = Get-Verb | Select-Object -ExpandProperty 'Verb'
        $FunctionPattern = '^(?<verb>\w+?)-(?<noun>\w+?)$'
        if ($Functions.Count -gt 0) {
            $NewFunctionList = @()
            ForEach ($Function in $Functions){
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
            $Functions = $NewFunctionList
        }
        #endregion validate that the public functions are valid and unique
        #region validate that the private functions are valid and unique
        if ($PrivateFunctions.count -gt 0) {
            $NewPrivateFunctionList = @()
            ForEach ($Function in $PrivateFunctions){
                if ($Functions -contains $Function) {
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
            $PrivateFunctions = $NewPrivateFunctionList
        }
        
        #endregion validate that the private functions are valid and unique
        #region validate Enums are unique
        if ($AddEnums.Count -gt 0) {
            Write-Verbose "Validating that Enum are unique and valid..."
            $EnumPattern = '^[\w]+$'
            ForEach($Enum in $AddEnums) {
                if ($Enum -match $EnumPattern) {
                    # Enum is valid name check if it allready exist
                    Try {
                        New-Object -TypeName $Enum -ErrorAction Stop -Verbose:$False | out-null
                    }Catch {
                        if ($_.Exception.Message -notmatch "Cannot find type") {
                            Throw "The Enum '$($Enum)' allready exist, please use a different Enum name"
                        }else{
                            # no enum with that name exist
                        }
                    }
                    Write-Verbose "Enum '$($Enum)' is not yet used"
                }Else{
                    Throw "Enum '$($Enum)' contains not allowed characters, please use a different Enum name"
                }
            }
        }
        #endregion validate Enums are unique
        #region validate classes are unique
        if ($AddClasses.Count -gt 0) {
            Write-Verbose "Validating that class are unique and valid..."
            $ClassPattern = '^[\w]+$'
            ForEach($Class in $Classes) {
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
        #endregion validate parameters
        #region define constant
        [String] ${PublicSubName} = 'Public'
        [String] ${PrivateSubName} = 'Private'
        [String] ${EnumSubName} = 'Enum'
        [String] ${ClassSubName} = 'Class'
        [String] ${DebugFileName} = 'Debug'
        [String] ${ExampleFileName} = '_Example'

        [String] ${ModulePath} = "$($ModuleRootPath)\$($Name)"
        [String] ${ModuleFilesPath} = "$($ModulePath)\$($Version.ToString())"
        [String] ${ModuleManifestFileFullName} = "$($ModuleFilesPath)\$($Name).psd1"
        [String] ${ModuleFileFullName} = "$($ModuleFilesPath)\$($Name).psm1"
        [String] ${DebugFileFullName} = "$($ModuleFilesPath)\$($DebugFileName).ps1"
        [String] ${PublicSubFullName} = "$($ModuleFilesPath)\$($PublicSubName)"
        [String] ${PublicExampleFileFullName} = "$($PublicSubFullName)\$($ExampleFileName).ps1"
        [String] ${PrivateSubFullName} = "$($ModuleFilesPath)\$($PrivateSubName)"
        [String] ${PrivateExampleFileFullName} = "$($PrivateSubFullName)\$($ExampleFileName).ps1"
        [String] ${EnumSubFullName} = "$($ModuleFilesPath)\$($EnumSubName)"
        [String] ${EnumExampleFileFullName} = "$($EnumSubFullName)\$($ExampleFileName).ps1"
        [String] ${ClassSubFullName} = "$($ModuleFilesPath)\$($ClassSubName)"
        [String] ${ClassExampleFileFullName} = "$($ClassSubFullName)\$($ExampleFileName).ps1"
        #endregion define constant
        #region define file content
        #region manifest psd1 file content
        # Manifest => Will use the New-ModuleManifest function
        # $ModuleManifestFileContent = ''
        #endregion manifest psd1 file content
        #region Module psm1 file content
        $ModuleFileContent = @'
Write-Verbose "Importing Module : $($MyInvocation.MyCommand)"

$FileToExclude = '_Example.ps1'
$PublicPS1 = Get-ChildItem -Path "$($PSScriptRoot)\Public\*.ps1" -ErrorAction SilentlyContinue -Exclude $FileToExclude
$PrivatePS1 = Get-ChildItem -Path "$($PSScriptRoot)\Private\*.ps1" -ErrorAction SilentlyContinue -Exclude $FileToExclude
$ClassPS1 = Get-ChildItem -Path "$($PSScriptRoot)\Class\*.ps1" -ErrorAction SilentlyContinue -Exclude $FileToExclude

ForEach ($PS1 in $PublicPS1) {
    Write-Verbose "Importing Public PS1 : $($PS1.BaseName)"
    . $PS1.Fullname
}

ForEach ($PS1 in $PrivatePS1) {
    Write-Verbose "Importing Private PS1 : $($PS1.BaseName)"
    . $PS1.Fullname
}

ForEach ($PS1 in $ClassPS1) {
    Write-Verbose "Importing Class PS1 : $($PS1.BaseName)"
    . $PS1.Fullname
}
'@
        #endregion Module psm1 file content
        #region debug file content
        
        $DebugFileContent = @'
# Correcting verbose color
$Host.PrivateData.VerboseForegroundColor = 'Cyan'

$CurrPath = $PSScriptRoot
$ModuleVersion = Split-Path -Path $CurrPath -leaf
$ModuleName = Split-Path -Path $(Split-Path -Path $CurrPath) -leaf
Remove-Module -Name $ModuleName -Verbose:$False -ErrorAction SilentlyContinue
Import-Module -Name $ModuleName -MinimumVersion $ModuleVersion -Verbose:$False
'@
        if ($VerboseDebug -eq $True) {
            $DebugFileContent = @"
`$VerbosePreference = 'Continue'
$($DebugFileContent)
"@
        }
        if ($Strict -eq $True) {
            $DebugFileContent = @"
$($DebugFileContent)
Set-StrictMode -Version 'Latest'
"@            
        }
        #endregion debug file content
        #endregion define file content
    }
    PROCESS {
        #region Function Processing DO NOT REMOVE
        Write-Verbose "Processing : $($FunctionName)"
        #region Function Processing DO NOT REMOVE
        #region create files and folders
        #region create Folders
        Write-Verbose 'Create Module Root folder...'
        Try {
            $Null = New-Item -Path $ModulePath -ItemType Directory -Force -ErrorAction Stop -Verbose:$False
        }Catch {
            Throw "Unable to create '$($ModulePath)' : $($_.Exception.Message)"
        }
        Write-Verbose 'Create Module Version folder...'
        Try {
            $Null = New-Item -Path $ModuleFilesPath -ItemType Directory -Force -ErrorAction Stop -Verbose:$False
        }Catch {
            Throw "Unable to create '$($ModuleFilesPath)' : $($_.Exception.Message)"
        }
        Write-Verbose 'Create Module Public folder...'
        Try {
            $Null = New-Item -Path $PublicSubFullName -ItemType Directory -Force -ErrorAction Stop -Verbose:$False
        }Catch {
            Throw "Unable to create '$($PublicSubFullName)' : $($_.Exception.Message)"
        }
        Write-Verbose 'Create Module Private folder...'
        Try {
            $Null = New-Item -Path $PrivateSubFullName -ItemType Directory -Force -ErrorAction Stop -Verbose:$False
        }Catch {
            Throw "Unable to create '$($PrivateSubFullName)' : $($_.Exception.Message)"
        }
        Write-Verbose 'Create Module Enum folder...'
        Try {
            $Null = New-Item -Path $EnumSubFullName -ItemType Directory -Force -ErrorAction Stop -Verbose:$False
        }Catch {
            Throw "Unable to create '$($EnumSubFullName)' : $($_.Exception.Message)"
        }
        Write-Verbose 'Create Module Class folder...'
        Try {
            $Null = New-Item -Path $ClassSubFullName -ItemType Directory -Force -ErrorAction Stop -Verbose:$False
        }Catch {
            Throw "Unable to create '$($ClassSubFullName)' : $($_.Exception.Message)"
        }
        #endregion create Folders
        #region create files
        #region create module file
        Write-Verbose 'Create Module file...'
        Try {
            $Null = Set-Content -Path $ModuleFileFullName -Value $ModuleFileContent -Force -Verbose:$False -ErrorAction 'Stop'
        }Catch {
            Throw "Unexpected error while creating module file : $($_.Exception.Message)"
        }
        #endregion create module file
        #region create debug file
        Write-Verbose 'Create Module debug file...'
        Try {
            $Null = Set-Content -Path $DebugFileFullName -Value $DebugFileContent -Force -Verbose:$False -ErrorAction 'Stop'
        }Catch {
            Throw "Unexpected error while creating debug file : $($_.Exception.Message)"
        }
        #endregion create debug file
        #region create public example file
        Write-Verbose 'Create Module public example file...'
        New-PoshModuleFunctionFile -Name 'New-Example' -Path $PublicExampleFileFullName -Public -Minimal:$Minimal -Author $Author
        #endregion create public example file
        #region create private example file
        Write-Verbose 'Create Module private example file...'
        New-PoshModuleFunctionFile -Name 'New-Example' -Path $PrivateExampleFileFullName -Minimal:$Minimal -Author $Author
        #endregion create private example file
        #region create Enum example file
        Write-Verbose 'Create Module Enum example file...'
        New-PoshModuleEnumFile -Name 'ExampleEnum' -path $EnumExampleFileFullName
        #endregion create Class example file
        #region create Class example file
        Write-Verbose 'Create Module Class example file...'
        New-PoshModuleClassFile -Name 'ExampleClass' -path $ClassExampleFileFullName
        #endregion create Class example file
        #region reate the public functions
        ForEach($Function in $Functions) {
            $PublicFunctionFileFullName = "$($PublicSubFullName)\$($Function).ps1"
            Write-Verbose "Create public '$($Function)' function file..."
            New-PoshModuleFunctionFile -Path $PublicFunctionFileFullName -Name $Function -Public -Minimal:$Minimal -Author $Author
        }
        #endregion create the public functions
        #region create the private functions
        ForEach($Function in $PrivateFunctions) {
            $PrivateFunctionFileFullName = "$($PrivateSubFullName)\$($Function).ps1"
            Write-Verbose "Create private '$($Function)' function file..."
            New-PoshModuleFunctionFile -Path $PrivateFunctionFileFullName -Name $Function -Minimal:$Minimal -Author $Author
        }
        #endregion create the private functions
        #region create the Enums
        ForEach ($Enum in $Enums) {
            $EnumFullFileName = "$($EnumSubFullName)\$($Enum).ps1"
            Write-Verbose "Create Enum '$($Enum)' file..."
            New-PoshModuleEnumFile -Path $EnumFullFileName -Name $Enum
        }
        #endregion create the Enums
        #region create the classes
        ForEach ($Class in $Classes) {
            $ClassFullFileName = "$($ClassSubFullName)\$($Class).ps1"
            Write-Verbose "Create Class '$($Class)' file..."
            New-PoshModuleClassFile -Path $ClassFullFileName -Name $Class
        }
        #endregion create the classes
        #region create module manifest
        Write-Verbose 'Create Module Manifest file...'
        $Splat = @{
            Path = $ModuleManifestFileFullName
            Guid = $Guid
            Author = $Author
            CompanyName = $CompanyName
            Copyright = $Copyright
            RootModule = "$($Name).psm1"
            ModuleVersion = $Version
            CmdletsToExport = @()
            Description = $Description
            FunctionsToExport = $Functions
            VariablesToExport = @()
            AliasesToExport = @()
            Verbose = $False
            ErrorAction = 'Stop'
        }
        Try {
            $Null = New-ModuleManifest @splat
        }Catch {
            Throw "Unexpected error while creating module manifest : $($_.Exception.Message)"
        }
        #endregion create module manifest
        #endregion create files
        #endregion create files and folders
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
Export-ModuleMember -Function 'New-PoshModule'