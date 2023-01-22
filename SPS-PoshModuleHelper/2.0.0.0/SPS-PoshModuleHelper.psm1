#region Enums Declarations (DO NOT REMOVE)
enum PMHPSEditions {
    Desktop
    Core
}
enum PMHProcessArchitecture {
    None
    MSIL
    X86
    X64
    IA64
    Amd64
    Arm
}
enum PMHConfirmImpact {
    None = 0
    Low = 1
    Medium = 2
    High = 3
}
#endregion Enums Declarations (DO NOT REMOVE)
#region Classes Declarations (DO NOT REMOVE)
Class PMHPSData {
    [String[]] ${Tags}
    [URI] ${LicenseUri}
    [URI] ${ProjectUri}
    [URI] ${IconUri}
    [String] ${ReleaseNotes}
    PMHPSData() {}
    PMHPSData([String[]] ${Tags},[URI] ${LicenseUri},[URI] ${ProjectUri},[URI] ${IconUri}, [String] ${ReleaseNotes}) {
        $This.Tags = $Tags
        $This.LicenseUri = $LicenseUri
        $This.ProjectUri = $ProjectUri
        $This.IconUri = $IconUri
        $This.ReleaseNotes = $ReleaseNotes
    }
    [String] ParamToString ([String] ${Name}) {
        $Value = $This.$Name
        If ($Null -like $Value) {
            $RetVal = ''
        }Else{
            If ($Value -is [String[]]) {
                if ($Value.Count -gt 0){
                    $RetVal = "$($Name) = $(($Value | ForEach-Object {"'$($_)'"}) -join ',')"
                }Else{
                    $RetVal = ''
                }
            }Elseif ($Value -is [URI]) {
                $RetVal = "$($Name) = $(($Value | Select-Object -ExpandProperty 'AbsoluteUri'))"
            }Else {
                $RetVal = "$($Name) = '$($Value)'"
            }
        }
        Return $RetVal
    }
    [String] ToString() {
        Return "{PSData}"
    }
}
Class PMHCmdLetBinding {
    [String] ${DefaultParameterSetName}
    [PMHConfirmImpact] ${ConfirmImpact} = 'None'
    [Boolean] ${SupportsPaging}
    [Boolean] ${SupportsShouldProcess}
    [Boolean] ${PositionalBinding}
    [String] ${HelpURI}
    PoshCmdLetBinding() {}
    PoshCmdLetBinding([String] ${DefaultParameterSetName}) {
        $This.DefaultParameterSetName = $DefaultParameterSetName
    }
    [String] ToString () { #Standard "To String" will return a one line result
        $RetVal = $This.ToString('')
        Return $RetVal
    }
    [String] ToString([String] ${Tab}) {
        $Content = @()
        if ($This.DefaultParameterSetName -notlike '') {$Content += "DefaultParameterSetName = '$($This.DefaultParameterSetName)'"}
        if ($This.ConfirmImpact -ne 'None') {$Content += "ConfirmImpact($($This.ConfirmImpact))"}
        if ($This.SupportsPaging -eq $True) {$Content += 'SupportsPaging'}
        if ($This.SupportsShouldProcess -eq $True) {$Content += 'SupportsShouldProcess'}
        if ($This.PositionalBinding -eq $True) {$Content += 'PositionalBinding'}
        if ($This.HelpUri) {$Content += "HelpUri = '$($This.HelpUri)'"}
        $ContentStr = $Content -join ', '
        $RetVal = "$($Tab)[CMDLetBinding($($ContentStr))]"
        Return $RetVal
    }
    [void] ParseAST([Object] ${Attributes}) {
        $NamedArguments = $Attributes.NamedArguments
        ForEach ($Argument in $NamedArguments) {
            $ArgumentName = $Argument.ArgumentName
            Try {
                $This.$ArgumentName = $Argument.Argument.Value
            }Catch {
            }
        }
    }
}
Class PMHParamAttribute {
    [Boolean] ${Mandatory}
    [Nullable[Uint32]] ${Position} = $Null
    [String] ${ParameterSetName}
    [Boolean] ${ValueFromPipeline}
    [Boolean] ${ValueFromPipelineByPropertyName}
    [Boolean] ${ValueFromRemainingArguments}
    [String] ${HelpMessage}
    PMHParamAttribute(){}
    PMHParamAttribute([String] ${ParameterSetName}){
        $This.ParameterSetName = $ParameterSetName
    }
    [String] ToString() {
        $Content = $This.ToArray()
        $ContentStr = "$($Content[0])`r`n$(($Content[1..$($Content.Count -2)]) -join ",`r`n")`r`n$($Content[$Content.Count -1])"
        Return $ContentStr
    }
    [String] ToString(${Tab}) {
        $Content = $This.ToArray()
        $ContentStr = "$($Tab)$($Content[0])`r`n$(($Content[1..$($Content.Count - 2)]| ForEach-Object {"$($Tab)$($_)"}) -join ",`r`n")`r`n$($Tab)$($Content[$($Content.Count - 1)])"
        Return $ContentStr
    }
    [String[]] ToArray() {
        $Content = @()
        $Content += "[Parameter("
        $Content += "`tMandatory = `$$($this.Mandatory.ToString())"
        if ($Null -ne $This.Position) {
            $Content += "`tPosition = $($This.Position)"
        }
        if ($This.ParameterSetName -notlike '') {
            $Content += "`tParameterSetName = '$($This.ParameterSetName)'"
        }
        if ($This.ValueFromPipeline -eq $True) {
            $Content += "`tValueFromPipeline = `$True"
        }
        if ($This.ValueFromPipelineByPropertyName -eq $True) {
            $Content += "`tValueFromPipelineByPropertyName = `$True"
        }
        if ($This.ValueFromRemainingArguments -eq $True) {
            $Content += "`tValueFromRemainingArguments = `$True"
        }
        if ($This.HelpMessage -notlike '') {
            if ($This.HelpMessage -match "'") {
                $Content += "`tHelpMessage = `"$($This.HelpMessage)`""
            }Else{
                $Content += "`tHelpMessage = '$($This.HelpMessage)'"
            }
        }
        $Content += ")]"
        Return $Content
    }
    [void] ParseAST(${ParamParameters}) {
        $NamedArguments = $ParamParameters.NamedArguments
        ForEach ($Argument in $NamedArguments) {
            $ArgumentName = $Argument.ArgumentName
            Try {
                if ($This.$ArgumentName -is [Boolean]) {
                    $This.$ArgumentName = [Boolean]::Parse($Argument.Argument.VariablePath.UserPath)
                }Else{
                    $This.$ArgumentName = $Argument.Argument.Value
                }
            }Catch {
            }
        }
    }
}
Class PMHFunctionHelp {
    [String] ${Name}
    [String] ${Author} = "$($Env:UserName.Substring(0,1).ToUpper())$($Env:UserName.SubString(1))"
    [String] ${Synopsis}
    [String] ${Description}
    [PMHParam[]] ${Parameters}
    [String] ${Inputs}
    [String] ${Outputs}
    [String[]]  ${Examples}
    [String] ${Link}
    [String] ${Notes}
    PMHFunctionHelp([String] ${Name}){
        $This.Name = $Name
    }
    PMHFunctionHelp([String] ${Name},[String] ${Author}){
        $This.Name = $Name
        $This.Author = $Author
    }
    PMHFunctionHelp([String] ${Name},[String] ${Author},[PMHParam[]] ${Parameters}){
        $This.Name = $Name
        $This.Author = $Author
        $This.Parameters = $Parameters
    }
    [String[]] ToArray() {
        $Content = @()
        $Content += "<#"
        $Content += "`t.SYNOPSIS"
        if ($This.Synopsis) {$Content += "`t`t$($This.Synopsis)"}Else{$Content += "`t`t$($This.Name) A brief description of the function."}
        $Content += "`t.DESCRIPTION"
        if ($This.Description) {$Content += "`t`t$($This.Description)"}Else{$Content += "`t`t$($This.Name) A detailed description of the function."}
        ForEach ($Param in $This.Parameters) {
            $ParameterHelps = $Param.GetHelp()
            ForEach ($Help in $ParameterHelps) {
                $Content += "`t$($Help)"
            }
        }
        $Content += "`t.INPUTS"
        if ($This.Inputs) {$Content += "`t`t$($This.Inputs)"}Else{$Content += "`t`tThe .NET types of objects that can be piped to the function."}
        $Content += "`t.OUTPUTS"
        if ($This.Outputs) {$Content += "`t`t$($This.Outputs)"}Else{$Content += "`t`tThe .NET type of the objects that the function returns."}

        if ($This.Examples){
            forEach ($Example in $This.Examples) {
                $Content += "`t.EXAMPLE"
                ForEach ($ExampleLine in $($Example -split "`n")) {$Content += "`t`T$($ExampleLine)"}
            }
        }Else{
            $Content += "`t.EXAMPLE"
            $Content += "`t`tPS> $($This.Name)"
            $Content += "`t`tSample output and a description."
        }
        $Content += "`t.LINKS"
        if ($This.Link) {$Content += "`t`t$($This.Link)"}Else{$Content += "`t`tThe name of a related topic."}
        $Content += "`t.NOTES"
        if ($This.Notes) {$Content += "`t`t$($This.Notes)"}Else{$Content += "`t`tWritten by $($This.Author)."}
        $Content += "#>"
        Return $Content
    }

}
Class PMHParam {
    [String] ${TypeName}
    [String] ${Name}
    [Object] ${Value}
    [PMHParamAttribute[]] $Parameters
    [String[]] ${Alias}
    [Boolean] ${AllowNull}
    [Boolean] ${AllowEmptyString}
    [Boolean] ${AllowEmptyCollection}
    [String[]] ${ValidateSet}
    [Uint32[]] ${ValidateCount}
    [Uint32[]] ${ValidateLength}
    [String] ${ValidatePattern}
    [String[]] ${ValidateRange}
    [String] ${ValidateScript}
    [Boolean] ${ValidateNotNull}
    [Boolean] ${ValidateNotNullOrEmpty}
    [String[]] ${ValidateDrive}
    [String[]] ${ValidateUserDrive}
    #[String[]] ${ArgumentCompletions}
    #[String[]] ${SupportsWildcards}
    PMHParam([String] ${Name}) {
        $This.Name = $Name
    }
    PMHParam([String] ${Name}, [Object] ${Value}) {
        $This.Name = $Name
        $This.Value = $Value
    }
    PMHParam([String] ${TypeName}, [String] ${Name}, [Object] ${Value}) {
        $This.TypeName = $TypeName
        $This.Name = $Name
        $This.Value = $Value
    }
    [String] ToString() {
        $ParametersStr = ($This.Parameters | ForEach-Object {$_.ToString()}) -join "`r`n"
        $ContentStr = $This.ToArray() -join "`r`n"
        $RetVal = "$($ParametersStr)`r`n$($ContentStr)"
        Return $RetVal
    }
    [String] ToString([String] ${Tab}) {
        $ParametersStr = ($This.Parameters | ForEach-Object {$_.ToString($Tab)}) -join "`r`n"
        $ContentStr = ($This.ToArray() | ForEach-Object {"$($Tab)$($_)"}) -join "`r`n"
        $RetVal = "$($ParametersStr)`r`n$($ContentStr)"
        Return $RetVal
    }
    [String[]] ToArray () {
        $Content = @()
        if ($This.Alias.count -gt 0) {$Content += "[Alias($(($This.Alias | ForEach-Object {"'$($_)'"}) -join ','))]"}
        if ($This.AllowNull -eq $True) {$Content += "[AllowNull()]"}
        if ($This.AllowEmptyString -eq $True) {$Content += "[AllowEmptyString()]"}
        if ($This.AllowEmptyCollection -eq $True) {$Content += "[AllowEmptyCollection()]"}
        if ($This.ValidateSet.count -gt 0) {$Content += "[ValidateSet($(($This.ValidateSet | ForEach-Object {"'$($_)'"}) -join ','))]"}
        if ($This.ValidateCount.count -gt 0) {
            if ($This.ValidateCount.count -le 2) {
                $Content += "[ValidateCount($($This.ValidateCount -join ','))]"
            }Else{
                Throw 'ValidatedCount does not accept more than 2 values'
                BREAK
            }
        }
        if ($This.ValidateLength.count -gt 0) {
            if ($This.ValidateLength.count -le 2) {
                $Content += "[ValidateLength($($This.ValidateCount -join ','))]"
            }Else{
                Throw 'ValidateLength does not accept more than 2 values'
                BREAK
            }
        }
        if ($This.ValidatePattern -notlike '') {$Content += "[ValidatePattern(`"$($This.ValidatePattern)`")]"}
        if ($This.ValidateRange.count -gt 0) {
            if ($This.ValidateRange.count -eq 1) {
                $ValidateRangeEnum = @('Positive','Negative','NonPositive','NonNegative')
                if ($This.ValidateRange[0] -in $ValidateRangeEnum) {
                    $Content += "[ValidateRange('$($This.ValidateRange[0])')]"
                }Else{
                    Throw "ValidateRange does not accept 1 value when this value in not in : $($ValidateRangeEnum -join ',')"
                    BREAK
                }
            }Elseif ($This.ValidateRange.count -eq 2) {
                $Content += "[ValidateRange($($This.ValidateRange -join ','))]"
            }Else{
                Throw 'ValidateRange does not accept more than 2 values'
                BREAK
            }
        }
        if ($This.ValidateScript -notlike $Null) {$Content += "[ValidateScript({$($This.ValidateScript)})]"}
        if ($This.ValidateNotNull -eq $True) {$Content += "[ValidateNotNull()]"}
        if ($This.ValidateNotNullOrEmpty -eq $True) {$Content += "[ValidateNotNullOrEmpty()]"}
        if ($This.ValidateDrive.count -gt 0) {$Content += "[ValidateDrive($(($This.ValidateDrive | ForEach-Object {"'$($_)'"}) -join ','))]"}
        if ($This.ValidateUserDrive.count -gt 0) {$Content += "[ValidateUserDrive($(($This.ValidateUserDrive | ForEach-Object {"'$($_)'"}) -join ','))]"}
        $NameValueLine = ''
        if ($This.TypeName -notlike '') {
            $NameValueLine = "[$($This.TypeName)] "
        }
        $NameValueLine = "$($NameValueLine)`${$($This.Name)}"
        if ($This.Value -notlike $Null) {
            if ($This.Value -is [String]) {
                $NameValueLine = "$($NameValueLine) = '$($This.Value)'"
            }Elseif ($This.Value -is [Array]) {
                $ValueContent = @()
                ForEach ($Valuestr in $This.Value) {
                    if ($ValueStr -is [String]) {
                        $ValueContent += "'$($ValueStr)'"
                    }Elseif ($ValueStr -is [Int32]) {
                        $ValueContent += "$($ValueStr)"
                    }
                }
                $ValueContentStr = $ValueContent -join ','
                $NameValueLine = "$($NameValueLine) = @($($ValueContentStr))"
            }
        }
        $Content += $NameValueLine
        Return $Content
    }
    [String[]] GetHelp() {
        $Content = @()
        $Content += ".PARAMETER $($This.Name)"
        if ($This.TypeName) {$Content += "`tType: $($This.TypeName)"}
        if ($This.Value) {$Content += "`tDefaultValue: $($This.Value)"}
        if ($This.Alias.count -gt 0) {$Content += "`tAlias : $($This.Alias -join ', ')"}
        if ($This.AllowNull -eq $True) {$Content += "`tAllow Null: True"}
        if ($This.AllowEmptyString -eq $True)  {$Content += "`tAllow Empty String: True"}
        if ($This.AllowEmptyCollection -eq $True) {$Content += "`tAllow Empty Collection: True"}
        if ($This.ValidateCount.count -gt 0) {$Content += "`tValidate Count: $($This.ValidateCount -join ', ')"}
        if ($This.ValidateLength.count -gt 0) {$Content += "`tValidate Length: $($This.ValidateLength -join ', ')"}
        if ($This.ValidatePattern) {$Content += "`tValidate Pattern: $($This.ValidatePattern)"}
        if ($This.ValidateRange.count -gt 0) {$Content += "`tValidate Range: $($This.ValidateRange -join ', ')"}
        if ($This.ValidateScript) {$Content += "`tValidate Script: $($This.ValidateScript)"}
        if ($This.ValidateNotNull -eq $True) {$Content += "`tValidate Not Null: True"}
        if ($This.ValidateNotNullOrEmpty -eq $True) {$Content += "`tValidate Not Null or Empty: True"}
        if ($This.ValidateDrive.count -gt 0) {$Content += "`tValidate Drive: $($This.ValidateDrive -join ', ')"}
        if ($This.ValidateUserDrive.count -gt 0) {$Content += "`tValidate User Drive: $($This.ValidateUserDrive -join ', ')"}
        ForEach ($Param in $This.Parameters) {
            if ($Param.ParameterSetName) {$ParamSet = " ($($Param.ParameterSetName))"}Else{$ParamSet = ''}
            $Content += "`tMandatory: $($Param.Mandatory.ToString())$($ParamSet)"
            if ($Param.Position) {$Content += "`tPosition: $($Param.Position.ToString())$($ParamSet)"}
            if ($Param.ValueFromPipeline -eq $True) {$Content += "`tValue From Pipeline: True$($ParamSet)"}
            if ($Param.ValueFromPipelineByPropertyName -eq $True) {$Content += "`tValue From Pipeline By Name: True$($ParamSet)"}
            if ($Param.ValueFromRemainingArguments -eq $True) {$Content += "`tValue From Remaining Arguments: True$($ParamSet)"}
        }
        Return $Content
    }
    [void] ParseAST(${Attributes},${Params}) {
        ForEach ($Attribute in $Attributes) {
            $AttributeName = $Attribute.TypeName.Name
            Try {
                if ($This.$AttributeName -is [Boolean]) {
                    $This.$AttributeName = $True
                }Else{
                    $This.$AttributeName = $Attribute.PositionalArguments.Value
                }
            }Catch {
                Write-Warning "Unable to handle $($AttributeName),please review your input"
            }
        }
        $AllParameters = @()
        ForEach ($ParamAttribute in $Params) {
            $ParamObj = [PMHParamAttribute]::new()
            $ParamObj.ParseAST($ParamAttribute)
            $AllParameters += $ParamObj
        }
        $This.Parameters = $AllParameters
    }
}
Class PoshEnum {
    [String] ${Name}
    [Hashtable] ${EnumValues} = @{}
    [Boolean] ${IsFlag} = $False
    PoshEnum ([String] ${Name}) {
        $This.Name = $Name
    }
    [String] ToString() {
        $Content = $This.ToArray()
        $RetVal = $Content -join "`r`n"
        Return $RetVal
    }
    [String[]] ToArray() {
        $Content = @()
        if ($this.IsFlag -eq $True) {
            $Content += "[Flags()] Enum $($This.Name) {"
        }Else{
            $Content += "Enum $($This.Name) {"
        }
        ForEach($Key in $This.EnumValues.Keys) {
            if ($This.EnumValues.$Key -notlike $Null) {
                $Content += "`t$($Key) = $($This.EnumValues.$Key)"
            }Else{
                $Content += "`t$($Key)"
            }
        }
        $Content += "}"
        Return $Content
    }
    [void] AddValue ([String] ${Name}) {
        if ($This.IsFlag -eq $True) {
            Throw 'You cannot add a null enum name for flagged enum, please user .AddValue([String] $Name, [Int32] $Value)'
        }Else{
            $This.EnumValues.add($Name,$Null)
        }
    }
    [void] AddValue ([String] ${Name},[Int32] ${Value}) {
        $This.EnumValues.add($Name,$Value)
    }

}
Class PoshClass {
    [String] ${Name}
    PoshClass() {}
    PoshClass([String] ${Name}) {
        $This.Name = $Name
    }
}
Class PoshFunction {
    [String] ${Name}
    [String] ${Author} = "$($Env:UserName.Substring(0,1).ToUpper())$($Env:UserName.SubString(1))"
    [PMHCmdLetBinding] ${CmdletBinding} = [PMHCmdLetBinding]::New()
    [PMHParam[]] ${Parameters}
    [String[]] ${HelpMessage}
    [String] ${BeginBlock}
    [String] ${ProcessBlock}
    [String] ${EndBlock}
    Hidden [String] ${DefaultBeginBlock} = @'
            #region Function initialisation DO NOT REMOVE
            [DateTime] ${FunctionEnterTime} = [DateTime]::Now ; Write-Verbose "Entering : $($MyInvocation.MyCommand)"
            #endregion Function initialisation DO NOT REMOVE
'@
    Hidden [String] ${DefaultProcessBlock} = @'
            #region Function Processing DO NOT REMOVE
            Write-Verbose "Processing : $($MyInvocation.MyCommand)"
            #endregion Function Processing DO NOT REMOVE
'@
    Hidden [String] ${DefaultEndBlock} = @'
            $TimeSpentinFunc = New-TimeSpan -Start $FunctionEnterTime -Verbose:$False -ErrorAction SilentlyContinue;$TimeUnits = @{Days = "$($_.TotalDays) D.";Hours = "$($_.TotalHours) h.";Minutes = "$($_.TotalMinutes) min.";Seconds = "$($_.TotalSeconds) s.";Milliseconds = "$($_.TotalMilliseconds) ms."}
            ForEach ($Unit in $TimeUnits.GetEnumerator()) {if ($TimeSpentinFunc.($Unit.Key) -gt 1) {$TimeSpentString = $Unit.Value;break}};if (-not $TimeSpentString) {$TimeSpentString = "$($TimeSpentinFunc.Ticks) Ticks"}
            Write-Verbose "Ending : $($MyInvocation.MyCommand) - TimeSpent : $($TimeSpentString)"
            #endregion Function closing DO NOT REMOVE
            #region outputing
            ### PUT YOUR OUTPUTING HERE Using Either Write-output or Return (https://www.techtarget.com/searchwindowsserver/tutorial/Cut-coding-corners-with-return-values-in-PowerShell-functions#:~:text=The%20difference%20between%20returning%20values,value%20and%20exit%20the%20function.)
            #endregion outputing
'@

    PoshFunction() {}
    PoshFunction([String] ${Name}) {
        $This.Name = $Name
        $This.BeginBlock = $This.DefaultBeginBlock
        $This.ProcessBlock = $This.DefaultProcessBlock
        $This.EndBlock = $This.DefaultEndBlock
        #$This.HelpMessage = New-PMHFunctionInlineHelpContent -Name $Name
    }
    [String] ToString() {
        $Content = $This.ToArray()
        $RetVal = $Content -join "`r`n"
        Return $RetVal
    }
    [String[]] ToArray() {
        $Content = @()
        $Content += "Function $($This.Name) {"
        $Content += $This.CmdletBinding.ToString("`t")
        if ($This.Parameters) {
            $Content += "`tParam("
            $Content += ($This.Parameters | ForEach-Object {$_.ToString("`t`t")}) -join ",`r`n"
            $Content += "`t)"
        }Else{
            $Content += "`tParam()"
        }
        if ($This.HelpMessage.count -gt 0) {
            ForEach ($HelpLine in $This.HelpMessage) {$Content += "`t$($HelpLine)"}
        }Else{
            $Help = [PMHFunctionHelp]::New($This.Name,$This.Author,$This.Parameters)
            $HelpLines = $Help.ToArray()
            ForEach ($Line in $HelpLines) {$Content += "`t$($Line)"}
        }
        $Content += "`tBEGIN {"
        $Content += ($This.BeginBlock -split "`n") | ForEach-Object {if (($_ -eq '"@')-or($_ -eq "'@")) {"$($_)"}else{"`t$($_)"}}
        $Content += "`t}"
        $Content += "`tPROCESS {"
        $Content += ($This.ProcessBlock -split "`n") | ForEach-Object {if (($_ -eq '"@')-or($_ -eq "'@")) {"$($_)"}else{"`t$($_)"}}
        $Content += "`t}"
        $Content += "`tEND {"
        $Content += ($This.EndBlock -split "`n") | ForEach-Object {if (($_ -eq '"@')-or($_ -eq "'@")) {"$($_)"}else{"`t$($_)"}}
        $Content += "`t}"
        $Content += "}"
        Return $Content
    }
    static [PoshFunction] Parse([String] ${Content}) {
        $RetVal = [PoshFunction]::New()
        $Content = $Content.Trim()
        #Validate it's in form of Function
        if ($Content -notlike 'Function *') {
            Throw 'Given text did not start with the "Function" keyword'
            BREAK
        }
        #Read the function as AST
        $Tokens = [ref] $null
        $ParseErrors = [ref] $Null
        $FunctionAST = [System.Management.Automation.Language.Parser]::ParseInput($Content,$Tokens,$ParseErrors)
        $Statements = $FunctionAST.EndBlock.Statements
        if ($Statements.count -ne 1) {
            Throw "Given text should have only 1 function and contains [$($Statements.count)]"
            BREAK
        }
        # retrieve the function name
        $RetVal.Name = $Statements[0] | Select-Object -ExpandProperty 'Name'
        # retrieve the function body
        $Body = $Statements[0] | Select-Object -ExpandProperty 'Body'
        $BeginText = $Body | Select-Object -ExpandProperty 'BeginBlock' | Select-Object -ExpandProperty 'Extent' | Select-Object -ExpandProperty 'Text'
        $ProcessText = $Body | Select-Object -ExpandProperty 'ProcessBlock' | Select-Object -ExpandProperty 'Extent' | Select-Object -ExpandProperty 'Text'
        $EndText = $Body | Select-Object -ExpandProperty 'EndBlock' | Select-Object -ExpandProperty 'Extent' | Select-Object -ExpandProperty 'Text'
        # retrieve begin block
        if (($BeginText.StartsWith('begin','CurrentCultureIgnoreCase')) -and $BeginText.EndsWith('}')) {
            $Clean = $BeginText.Substring(5).Trim().Substring(1) # .Trim() #remove statement and first {
            $Clean = $Clean.Substring(0,$Clean.Length -1) # .Trim() #remove last }
            #remove firsts emptyline
            $List = $Clean -split "`r`n"
            $IsEmpty = $False
            Do {
                Try {
                    $Line = $List[0]
                    if ($Line.Trim() -like '') {
                        $List = $List[1..$($List.Count - 1)]
                        $IsEmpty = $True
                    }Else{
                        $IsEmpty = $False
                    }
                }Catch {
                    $IsEmpty = $False
                }
            } until ($IsEmpty -eq $False)
            #remove lasts emptyline
            $IsEmpty = $False
            Do {
                Try {
                    $Line = $List[$($List.Count -1)]
                    if ($Line.Trim() -like '') {
                        $List = $List[0..$($List.Count - 2)]
                        $IsEmpty = $True
                    }Else{
                        $IsEmpty = $False
                    }
                }Catch {
                    $IsEmpty = $False
                }
            } until ($IsEmpty -eq $False)
            $Clean = $List -join "`r`n"
            # $Clean = (($Clean -split "`r`n") | ForEach-Object {$_.Trim()}) -join "`r`n" #remove tab
            $RetVal.BeginBlock = $Clean
        }Else{
            Throw 'Problem while trying to parse begin scriptblock the script block is not in form "begin {}"'
        }
        # retrieve Process block
        if (($ProcessText.StartsWith('process','CurrentCultureIgnoreCase')) -and $ProcessText.EndsWith('}')) {
            $Clean = $ProcessText.Substring(7).Trim().Substring(1) # .Trim() #remove statement and first {
            $Clean = $Clean.Substring(0,$Clean.Length -1) # .Trim() #remove last }
            #remove firsts emptyline
            $List = $Clean -split "`r`n"
            $IsEmpty = $False
            Do {
                Try {
                    $Line = $List[0]
                    if ($Line.Trim() -like '') {
                        $List = $List[1..$($List.Count - 1)]
                        $IsEmpty = $True
                    }Else{
                        $IsEmpty = $False
                    }
                }Catch {
                    $IsEmpty = $False
                }
            } until ($IsEmpty -eq $False)
            #remove lasts emptyline
            $IsEmpty = $False
            Do {
                Try {
                    $Line = $List[$($List.Count -1)]
                    if ($Line.Trim() -like '') {
                        $List = $List[0..$($List.Count - 2)]
                        $IsEmpty = $True
                    }Else{
                        $IsEmpty = $False
                    }
                }Catch {
                    $IsEmpty = $False
                }
            } until ($IsEmpty -eq $False)
            $Clean = $List -join "`r`n"
            # $Clean = (($Clean -split "`r`n") | ForEach-Object {$_.Trim()}) -join "`r`n" #remove tab
            $RetVal.ProcessBlock = $Clean
        }Else{
            Throw 'Problem while trying to parse process scriptblock the script block is not in form "process {}"'
        }
        # retrieve end block
        if (($EndText.StartsWith('end','CurrentCultureIgnoreCase')) -and $EndText.EndsWith('}')) {
            $Clean = $EndText.Substring(3).Trim().Substring(1) # .Trim() #remove statement and first {
            $Clean = $Clean.Substring(0,$Clean.Length -1) # .Trim() #remove last }
            #remove firsts emptyline
            $List = $Clean -split "`r`n"
            $IsEmpty = $False
            Do {
                Try {
                    $Line = $List[0]
                    if ($Line.Trim() -like '') {
                        $List = $List[1..$($List.Count - 1)]
                        $IsEmpty = $True
                    }Else{
                        $IsEmpty = $False
                    }
                }Catch {
                    $IsEmpty = $False
                }
            } until ($IsEmpty -eq $False)
            #remove lasts emptyline
            $IsEmpty = $False
            Do {
                Try {
                    $Line = $List[$($List.Count -1)]
                    if ($Line.Trim() -like '') {
                        $List = $List[0..$($List.Count - 2)]
                        $IsEmpty = $True
                    }Else{
                        $IsEmpty = $False
                    }
                }Catch {
                    $IsEmpty = $False
                }
            } until ($IsEmpty -eq $False)
            $Clean = $List -join "`r`n"
            # $Clean = (($Clean -split "`r`n") | ForEach-Object {$_.Trim()}) -join "`r`n" #remove tab
            $RetVal.EndBlock = $Clean
        }Else{
            Throw 'Problem while trying to parse end scriptblock the script block is not in form "end {}"'
        }
        $ParamBlock = $Body | Select-Object -ExpandProperty 'ParamBlock'
        # retrieve the function attributes
        $Attributes = $ParamBlock | Select-Object -ExpandProperty 'Attributes'
        $RetVal.CmdletBinding.ParseAST($Attributes)
        # retrieve the function parameters
        $AllParams = $ParamBlock | Select-Object -ExpandProperty 'Parameters'
        $AllParameters = @()
        ForEach ($Param in $AllParams) {
            # get name
            $ParamName = $Param.Name.VariablePath.UserPath
            # get Value if set
            if ($Null -ne $Param.DefaultValue) {
                $ParamValue = $Param.DefaultValue.Value
                $ParamObj = [PMHParam]::new($ParamName,$ParamValue)
            }Else{
                $ParamObj = [PMHParam]::new($ParamName)
            }
            # get typename if set
            $TypeName = $Param.StaticType -replace 'System.',''
            if ($TypeName -notlike 'Object') {
                $ParamObj.TypeName = $TypeName
            }
            $ParamAttributesEnum = @('Alias','AllowNull','AllowEmptyString','AllowEmptyCollection','ValidateSet','ValidateCount','ValidateLength','ValidatePattern','ValidateRange','ValidateScript','ValidateNotNull','ValidateNotNullOrEmpty','ValidateDrive','ValidateUserDrive')
            $ParamAttributes = $Param.Attributes | Where-Object {$_.TypeName.Name -in $ParamAttributesEnum}
            $ParamParameters = $Param.Attributes | Where-Object {$_.TypeName.Name -eq 'Parameter'}

            $ParamObj.ParseAST($ParamAttributes,$ParamParameters)
            $AllParameters += $ParamObj
        }
        $RetVal.Parameters = $AllParameters
        # retrieve help
        $HelpText = $Tokens.Value | Where-Object {$_.Text -like '*Synopsis*'} | Select-Object -First 1 | Select-Object -ExpandProperty 'text'
        if ($HelpText) {
            $RetVal.HelpMessage = $HelpText -split "`r`n"
        }
        Return $RetVal
    }
}
Class PoshModule {
    [String] ${Name}
    [Object[]] ${Enums}
    [Object[]] ${Classes}
    [PoshFunction[]] ${PrivateFunctions}
    [PoshFunction[]] ${Functions}
    PoshModule (){}
}
Class PoshManifest {
    # [String] ${Path}
    [String] ${Name}
    [String] ${RootModule}
    [Version] ${ModuleVersion} = [Version]::New('1.0.0.0')
    [GUID] ${Guid} = "$([GUID]::NewGuid())"
    [String] ${Author} = "$($($Env:UserName.Substring(0,1)).ToUpper())$($Env:UserName.Substring(1))"
    [String] ${CompanyName} = "$($($Env:UserName.Substring(0,1)).ToUpper())$($Env:UserName.Substring(1))''s Company"
    [String] ${Copyright} = "(c) $(Get-Date -Format yyyy) $($($Env:UserName.Substring(0,1)).ToUpper())$($Env:UserName.Substring(1))''s Company"
    [String] ${Description}
    [Version] ${PowerShellVersion}
    [Version] ${PowerShellHostVersion}
    [String] ${PowerShellHostName}
    [Version] ${DotNetFrameworkVersion}
    [String] ${CLrVersion}
    [Nullable[PMHProcessArchitecture]] ${ProcessorArchitecture}
    [Object] ${RequiredModules}
    [String[]] ${RequiredAssemblies}
    [String[]] ${ScriptsToProcess}
    [String[]] ${TypeToProcess}
    [String[]] ${FormatToProcess}
    [Object[]] ${NestedModules}
    [String[]] ${FunctionsToExport}
    [String[]] ${CmdletsToExport}
    [String[]] ${VariablesToExport}
    [String[]] ${AliasesToExport}
    [String[]] ${DscRessourcesToExport}
    [Object[]] ${ModuleList}
    [String[]] ${FileList}
    [PMHPSData] ${PrivateData} = [PMHPSData]::New()
    [String] ${HelpInfoUri}
    [String] ${DefaultCommandPrefix}
    [Nullable[PMHPSEditions]] ${CompatiblePSEditions}
    PoshManifest () {}
    PoshManifest ([String] ${Name}) {
        $This.Name = $Name
        $This.RootModule = "$($Name).psm1"
    }
    [String] ToString() {
        $RetVal = @"
# Module manifest for module: '$($This.Name)'
# Generated with: SPS-PoshModuleHelper
# Generated by: $($This.Author)
# Generated on: $(Get-Date -Format 'dd.MM.yyyy')
#
@{
"@
        $AllProperties = @('RootModule','ModuleVersion','Guid','Author','CompanyName','Copyright','Description','PowerShellVersion','PowerShellHostVersion','PowerShellHostName','DotNetFrameworkVersion','CLrVersion','ProcessorArchitecture','RequiredModules','RequiredAssemblies','ScriptsToProcess','TypeToProcess','FormatToProcess','NestedModules','FunctionsToExport','CmdletsToExport','VariablesToExport','AliasesToExport','DscRessourcesToExport','ModuleList','FileList','PrivateData','HelpInfoUri','DefaultCommandPrefix','CompatiblePSEditions')
        ForEach ($Property in $AllProperties) {
            if ($Property -eq 'PrivateData') {
                $AllPrivateDataProperties = @('Tags','LicenseUri','ProjectUri','IconUri','ReleaseNotes')
                $PrivateDataStr = @"
    PrivateData = @{
        PSData = @{
"@
                ForEach($PrivateDataProperty in $AllPrivateDataProperties) {
                    if ($This.PrivateData.$PrivateDataProperty -Notlike $Null) {$PrivateDataStr = "$($PrivateDataStr)`r`n            $($PrivateDataProperty) = $(($This.PrivateData.$PrivateDataProperty | ForEach-Object {"'$_'"}) -join ',')"}
                }
                $PrivateDataStr = "$($PrivateDataStr)`r`n        }`r`n    }"
                $RetVal = "$($RetVal)`r`n$($PrivateDataStr)"
            }Else{
                if ($This.$Property -Notlike $Null) {$RetVal = "$($RetVal)`r`n    $($Property) = $(($This.$Property | ForEach-Object {"'$_'"}) -join ',')"}
            }
        }
        $RetVal = "$($RetVal)`r`n}"
        Return $RetVal
    }
    [System.Management.Automation.PSModuleInfo] Save([String] ${FilePath}) {
        $Path = Split-Path -LiteralPath $FilePath
        if ($FilePath -notlike '*.psd1') {
            Throw 'Filename not allowed, file extension should be .psd1'
        }
        if ($(Test-Path -LiteralPath $Path) -ne $True) {
            Try {
                New-Item -Path $Path -ItemType Directory -Force -ErrorAction 'Stop'
            }Catch {
                Throw "Unable to create path $($Path): $($_.Exception.Message)"
            }
        }
        Try {
            Set-Content -Value $This.ToString() -Path $FilePath -Force -ErrorAction 'Stop'
        }Catch {
            Throw "Unable to create gfle $($FilePath): $($_.Exception.Message)"
        }
        Try {
            $TestManifest = Test-ModuleManifest -Path $FilePath -Verbose:$False -ErrorAction 'Stop'
            Return $TestManifest
        }Catch {
            Throw $_
        }
    }
    Hidden [void] ParseFromFile([String] ${FilePath}) {
        #To Do
        Try {
            $Manifest = Test-ModuleManifest -Path $FilePath -ErrorAction 'Stop' -Verbose:$False
        }
        Catch {
            Throw "Unable to parse manifest: $($_.Exception.Message)"
        }
        $AllProperties = $This | Get-Member -MemberType 'Property' | Select-Object -ExpandProperty 'Name' | Where-Object {$_ -Notin @('CompatiblePSEditions','Name')}
        ForEach ($Property in $AllProperties) {
            if ($Property -ne 'PrivateData') {
                if ($Manifest.$Property -notlike $null) {
                    $This.$Property = $Manifest.$Property
                }
            }Else{
                $This.PrivateData.Tags = $Manifest.Tags
                $This.PrivateData.LicenseUri = $Manifest.LicenseUri
                $This.PrivateData.ProjectUri = $Manifest.ProjectUri
                $This.PrivateData.IconUri = $Manifest.IconUri
                $This.PrivateData.ReleaseNotes = $Manifest.ReleaseNotes
            }
        }
        $This.Name = $This.RootModule.Replace('.psm1','')
    }
    Static [PoshManifest] Parse([String] ${FilePath}) {
        $ManifestObject = [PoshManifest]::new()
        $ManifestObject.ParseFromFile($FilePath)
        Return $ManifestObject
    }
}
#endregion Classes Declarations (DO NOT REMOVE)
#region private Functions Declarations (DO NOT REMOVE)
Function New-PMHDebugContent {
    [CMDLetBinding()]
    Param(
        [Switch] ${VerboseDebug},
        [Switch] ${Strict}
    )
    <#
        .SYNOPSIS
            New-PMHDebugContent will retrieve the content of the debug.ps1 file

        .DESCRIPTION
            New-PMHDebugContent will retrieve the content of the debug.ps1 file

        .PARAMETER IsVerbose
            Type : Switch

            The debug will be done verbosely

        .PARAMETER IsStrict
            Type : Switch

            The debug will be done under strict mode

        .INPUTS
            None

        .OUTPUTS
            None

        .EXAMPLE
            PS> New-PMHDebugContent

            Will return a default debug.ps1 content

        .EXAMPLE
            PS> New-PMHDebugContent -IsVerbose

            Will return a default debug.ps1 content that activate verbosepreference

        .EXAMPLE
            PS> New-PMHDebugContent -IsVerbose -IsStrict

            Will return a default debug.ps1 content that activate verbosepreference and strict mode

        .LINK
            Get-Content

        .NOTES
            Written by Swiss Powershell
    #>
    BEGIN {
        #region Function initialisation DO NOT REMOVE
        [String] ${FunctionName} = $MyInvocation.MyCommand
        [DateTime] ${FunctionEnterTime} = [DateTime]::Now
        Write-Verbose "Entering : $($FunctionName)"
        #endregion Function initialisation DO NOT REMOVE
        $DebugContent = ''
        $TitleStr = '# File automatically created by SPS-PoshModuleHelper'
        $ScriptStr = @'
#region reset the module
Try {Reset-PoshModule} Catch {if ($_.Exception.Message -like 'The term * is not recognized as the name *') {Write-Warning 'Reset-PoshModule function not found... module not reloaded'}Else{Write-Warning "Be aware that the module has not been reloaded using [Reset-PoshModule]: $($_.Exception.Message)"}}
#endregion reset the module

#region Begin
$DebugStart = Get-Date -Verbose:$False
#endregion Begin
#region Process
Write-Host "============================= DEBUG START ==============================" -Foregroundcolor Magenta

###########################################
##### Test your commands in this zone #####
###########################################

Write-Host "=============================  DEBUG END  ==============================" -Foregroundcolor Magenta
#endregion Process
#region end
$DebugTimeSpent = New-TimeSpan -Start $DebugStart -Verbose:$False
Write-Host "The debug took : $($DebugTimeSpent.TotalMilliseconds)ms to execute" -foregroundColor DarkYellow
#endregion end
'@
        if ($VerboseDebug -eq $True) {
            $VerboseStartStr = @'
$OriginalVP = $VerbosePreference
$VerbosePreference = 'Continue'
'@
            $VerboseStopStr = '$VerbosePreference = $OriginalVP'
        }Else{
            $VerboseStartStr = ''
            $VerboseStopStr = ''
        }
        if ($Strict -eq $True) {
            $StrictModeStr = 'Set-StrictMode -Version Latest'
        }Else{
            $StrictModeStr = ''
        }
    }
    PROCESS {
        #region Function Processing DO NOT REMOVE
        Write-Verbose "Processing : $($FunctionName)"
        #region Function Processing DO NOT REMOVE
        $DebugContent = @"
$($TitleStr)
#region Set Verbose preference
$($VerboseStartStr)
#endregion Set Verbose preference
#region set strict mode
$($StrictModeStr)
#endregion set strict mode

$($ScriptStr)

#region Reset Verbose preference
$($VerboseStopStr)
#endregion Reset Verbose preference
"@
    }
    END {
        #region Function closing  DO NOT REMOVE
        $TimeSpentinFunc = New-TimeSpan -Start $FunctionEnterTime -Verbose:$False -ErrorAction SilentlyContinue
        [String] ${TimeSpentString} = ''
        Switch ($TimeSpentinFunc) {
            {$_.TotalDays -gt 1} {$TimeSpentString = "$($_.TotalDays) D.";BREAK}
            {$_.TotalHours -gt 1} {$TimeSpentString = "$($_.TotalHours) h.";BREAK}
            {$_.TotalMinutes -gt 1} {$TimeSpentString = "$($_.TotalMinutes) min.";BREAK}
            {$_.TotalSeconds -gt 1} {$TimeSpentString = "$($_.TotalSeconds) s.";BREAK}
            {$_.TotalMilliseconds -gt 1} {$TimeSpentString = "$($_.TotalMilliseconds) ms.";BREAK}
            Default {$TimeSpentString = "$($_.Ticks) Ticks";BREAK}
        }
        Write-Verbose "Ending : $($FunctionName) - TimeSpent : $($TimeSpentString)"
        #endregion Function closing  DO NOT REMOVE
        Write-Output $DebugContent
    }
}
Function New-PMHFunctionInlineHelpContent {
    [CMDLetBinding()]
    Param(
        [Parameter(
            Position = 0,
            Mandatory = $True
        )]
        [Alias('FunctionName')]
        [String] ${Name},
        [Parameter(
            Position = 1,
            Mandatory = $False
        )]
        [String] ${Author} = "$($Env:UserName.substring(0,1).toupper())$($Env:UserName.substring(1))"
    )
    BEGIN {
        #region Function initialisation DO NOT REMOVE
        [String] ${FunctionName} = $MyInvocation.MyCommand
        [DateTime] ${FunctionEnterTime} = [DateTime]::Now
        Write-Verbose "Entering : $($FunctionName)"
        #endregion Function initialisation DO NOT REMOVE
        $InlineHelpContent = ''
    }
    PROCESS {
        #region Function Processing DO NOT REMOVE
        Write-Verbose "Processing : $($FunctionName)"
        #region Function Processing DO NOT REMOVE
        $InlineHelpContent = @"
    <#
        .SYNOPSIS
            $($Name) Synopsis of the function

        .DESCRIPTION
            $($Name) a short description of what the function do

        .PARAMETER ParameterName
            Type      : the type of the parameter
            Position  : the position of the parameter
            Mandatory : if the parameter is mandatory

            a short description of the parameter

        .INPUTS
            type of the input

        .OUTPUTS
            type of the output

        .EXAMPLE
            PS> $($Name)

            Short Description of what will be done if the command is ran

        .EXAMPLE
            PS> $($Name) -ParameterName

            Short Description of what will be done if the command is ran with ParameterName

        .LINK
            a lookalike ps function

        .NOTES
            Written by $($Author)
    #>
"@
    }
    END {
        #region Function closing  DO NOT REMOVE
        $TimeSpentinFunc = New-TimeSpan -Start $FunctionEnterTime -Verbose:$False -ErrorAction SilentlyContinue
        [String] ${TimeSpentString} = ''
        Switch ($TimeSpentinFunc) {
            {$_.TotalDays -gt 1} {$TimeSpentString = "$($_.TotalDays) D.";BREAK}
            {$_.TotalHours -gt 1} {$TimeSpentString = "$($_.TotalHours) h.";BREAK}
            {$_.TotalMinutes -gt 1} {$TimeSpentString = "$($_.TotalMinutes) min.";BREAK}
            {$_.TotalSeconds -gt 1} {$TimeSpentString = "$($_.TotalSeconds) s.";BREAK}
            {$_.TotalMilliseconds -gt 1} {$TimeSpentString = "$($_.TotalMilliseconds) ms.";BREAK}
            Default {$TimeSpentString = "$($_.Ticks) Ticks";BREAK}
        }
        Write-Verbose "Ending : $($FunctionName) - TimeSpent : $($TimeSpentString)"
        #endregion Function closing  DO NOT REMOVE
        Write-Output $InlineHelpContent
    }
}
Function New-PMHFunctionContent {
    [CMDLetBinding()]
    Param(
        [Parameter(
            Position = 0,
            Mandatory = $True
        )]
        [Alias('FunctionName')]
        [String] ${Name},
        [Parameter(
            Position = 1,
            Mandatory = $False
        )]
        [String] ${Author} = "$($Env:UserName.substring(0,1).toupper())$($Env:UserName.substring(1))",
        [Parameter(
            Position = 2,
            Mandatory = $False
        )]
        [Switch] ${Strict},
        [Parameter(
            Position = 3,
            Mandatory = $False
        )]
        [Switch] ${NoHelp},
        [Parameter(
            Position = 4,
            Mandatory = $False
        )]
        [Switch] ${Minimal}
    )
    <#
        .SYNOPSIS
            New-PMHFunctionContent will create the minimum content of a function

        .DESCRIPTION
            New-PMHFunctionContent will create the minimum content of a function

        .PARAMETER Name
            Type      : String
            Position  : 0
            Mandatory : True

            The name of the function to create

        .PARAMETER Author
            Type      : String
            Position  : 1
            Mandatory : False

            The Author of the function

        .PARAMETER Strict
            Type      : Switch

            Perform advanced test and throw exception if it did not follow standards

        .PARAMETER NoHelp
            Type      : Switch

            do not append help to the function

        .PARAMETER Minimal
            Type      : Switch

            do not append help and 'Begin' 'Process' 'end' scriptblocks to the function

        .INPUTS
            String

        .OUTPUTS
            String

         .EXAMPLE
            PS> New-PMHFunctionContent -Name 'AClass'

            Will return the content of a class named 'AClass'

        .LINK
            Get-Content

        .NOTES
            Written by GirardetY
    #>
    BEGIN {
        #region Function initialisation DO NOT REMOVE
        [String] ${FunctionName} = $MyInvocation.MyCommand
        [DateTime] ${FunctionEnterTime} = [DateTime]::Now
        Write-Verbose "Entering : $($FunctionName)"
        #endregion Function initialisation DO NOT REMOVE
        #region Re-edit name put a major string in the begining
        $Name = "$($Name.Substring(0,1).ToUpper())$($Name.Substring(1))"
        #endregion Re-edit name put a major string in the begining
        #region check that the function name format is correct
        $Pattern = '^(?<verb>\w+?)-(?<noun>\w+?)$'
        $RegexMatch = Select-String -InputObject $Name -Pattern $Pattern -Verbose:$False
        if ($Null -ne $RegexMatch) {
            # the function name match the verb-noun format
            $Verb = $RegexMatch | Select-Object -ExpandProperty 'Matches' | Select-Object -ExpandProperty 'Groups' | Where-Object {$_.Name -eq 'verb'} | Select-Object -ExpandProperty 'Value'
            $Noun = $RegexMatch | Select-Object -ExpandProperty 'Matches' | Select-Object -ExpandProperty 'Groups' | Where-Object {$_.Name -eq 'Noun'} | Select-Object -ExpandProperty 'Value'
            $Verb = "$($Verb.Substring(0,1).ToUpper())$($Verb.Substring(1))"
            $Noun = "$($Noun.Substring(0,1).ToUpper())$($Noun.Substring(1))"
            $IsNotAllowedVerb = $Null -eq $(Get-Verb -Verb $Verb -Verbose:$False -ErrorAction 'SilentlyContinue')
            if ($IsNotAllowedVerb -eq $True) {
                $ErrorMessage = "the function [$($Name)] uses an unapproved verb. [$($Verb)], please use approved verb, type 'get-verb' for a list of approved verbs"
                if ($Strict -eq $True) {
                    Throw "STRICT : $($ErrorMessage)"
                    BREAK
                }Else{
                    Write-Warning $ErrorMessage
                }
            }
            $Name = "$($Verb)-$($Noun)"
        }Else{
            $ErrorMessage = "the function [$($Name)] does not match the verb-noun format, please prefer a standard format"
            if ($Strict -eq $True) {
                Throw "STRICT : $($ErrorMessage)"
                BREAK
            }Else{
                Write-Warning $ErrorMessage
            }
        }

        #endregion check that the function name format is correct
        $FunctionTitleStr = @"
Function $($Name) {
"@
        $FunctionEndStr = @'
}
'@
        $CMDLetBindingStr = @"
    [CMDLetBinding()]
"@
        $ParamStr = @'
    Param()
'@
        $BeginStr = @'
    BEGIN {
        #region Function initialisation DO NOT REMOVE
        [String] ${FunctionName} = $MyInvocation.MyCommand
        [DateTime] ${FunctionEnterTime} = [DateTime]::Now
        Write-Verbose "Entering : $($FunctionName)"
        #endregion Function initialisation DO NOT REMOVE
    }
'@
        $ProcessStr = @'
    PROCESS {
        #region Function Processing DO NOT REMOVE
        Write-Verbose "Processing : $($FunctionName)"
        #endregion Function Processing DO NOT REMOVE
    }
'@
        $EndStr = @'
    END {
        #region Function closing DO NOT REMOVE
        $TimeSpentinFunc = New-TimeSpan -Start $FunctionEnterTime -Verbose:$False -ErrorAction SilentlyContinue
        [String] ${TimeSpentString} = ''
        Switch ($TimeSpentinFunc) {
            {$_.TotalDays -gt 1} {$TimeSpentString = "$($_.TotalDays) D.";BREAK}
            {$_.TotalHours -gt 1} {$TimeSpentString = "$($_.TotalHours) h.";BREAK}
            {$_.TotalMinutes -gt 1} {$TimeSpentString = "$($_.TotalMinutes) min.";BREAK}
            {$_.TotalSeconds -gt 1} {$TimeSpentString = "$($_.TotalSeconds) s.";BREAK}
            {$_.TotalMilliseconds -gt 1} {$TimeSpentString = "$($_.TotalMilliseconds) ms.";BREAK}
            Default {$TimeSpentString = "$($_.Ticks) Ticks";BREAK}
        }
        Write-Verbose "Ending : $($FunctionName) - TimeSpent : $($TimeSpentString)"
        #endregion Function closing DO NOT REMOVE
        #region outputing
        ### PUT YOUR OUTPUTING HERE Using Either Write-output or Return (https://www.techtarget.com/searchwindowsserver/tutorial/Cut-coding-corners-with-return-values-in-PowerShell-functions#:~:text=The%20difference%20between%20returning%20values,value%20and%20exit%20the%20function.)
        #endregion outputing
    }
'@
        $FunctionContent = ''
    }
    PROCESS {
        #region Function Processing DO NOT REMOVE
        Write-Verbose "Processing : $($FunctionName)"
        #region Function Processing DO NOT REMOVE
        #region build the string
        $FunctionContent = @"
$($FunctionTitleStr)
"@
        #region minimal => No CMDLetBinding
        if ($Minimal -eq $False) {
            $FunctionContent = @"
$($FunctionContent)
$($CMDLetBindingStr)
$($ParamStr)
"@
        }Else{
            $FunctionContent = @"
$($FunctionContent)
$($ParamStr)
"@
        }
        #endregion minimal => No CMDLetBinding
        #region nohelp => No Help Message
        if (($NoHelp -eq $False) -and ($Minimal -ne $True)) {
            $HelpStr = New-PMHFunctionInlineHelpContent -Name $Name
            $FunctionContent = @"
$($FunctionContent)
$($HelpStr)
"@
        }
        #endregion nohelp => No Help Message
        #region minimal => No BEGIN PROCESS END
        if ($Minimal -eq $False) {
            $FunctionContent = @"
$($FunctionContent)
$($BeginStr)
$($ProcessStr)
$($EndStr)
"@
        }
        #endregion minimal => No BEGIN PROCESS END
        #region close the function str
        $FunctionContent = @"
$($FunctionContent)
$($FunctionEndStr)
"@
        #endregion close the function str
    }
    END {
        #region Function closing  DO NOT REMOVE
        $TimeSpentinFunc = New-TimeSpan -Start $FunctionEnterTime -Verbose:$False -ErrorAction SilentlyContinue
        [String] ${TimeSpentString} = ''
        Switch ($TimeSpentinFunc) {
            {$_.TotalDays -gt 1} {$TimeSpentString = "$($_.TotalDays) D.";BREAK}
            {$_.TotalHours -gt 1} {$TimeSpentString = "$($_.TotalHours) h.";BREAK}
            {$_.TotalMinutes -gt 1} {$TimeSpentString = "$($_.TotalMinutes) min.";BREAK}
            {$_.TotalSeconds -gt 1} {$TimeSpentString = "$($_.TotalSeconds) s.";BREAK}
            {$_.TotalMilliseconds -gt 1} {$TimeSpentString = "$($_.TotalMilliseconds) ms.";BREAK}
            Default {$TimeSpentString = "$($_.Ticks) Ticks";BREAK}
        }
        Write-Verbose "Ending : $($FunctionName) - TimeSpent : $($TimeSpentString)"
        #endregion Function closing  DO NOT REMOVE
        Write-Output $FunctionContent
    }
}
Function New-PMHClassContent {
    [CMDLetBinding()]
    Param(
        [Parameter(
            Position = 0,
            Mandatory = $True
        )]
        [Alias('ClassName')]
        [String] ${Name}
    )
    <#
        .SYNOPSIS
            New-PMHClassContent Synopsis of the function

        .DESCRIPTION
            New-PMHClassContent a short description of what the function do

        .PARAMETER Name
            Type      : String
            Position  : 0
            Mandatory : True

            The name of the class to create

        .INPUTS
            String

        .OUTPUTS
            String

         .EXAMPLE
            PS> New-PMHClassContent -Name 'AClass'

            Will return the content of a class named 'AClass'

        .LINK
            Get-Content

        .NOTES
            Written by GirardetY
    #>
    BEGIN {
        #region Function initialisation DO NOT REMOVE
        [String] ${FunctionName} = $MyInvocation.MyCommand
        [DateTime] ${FunctionEnterTime} = [DateTime]::Now
        Write-Verbose "Entering : $($FunctionName)"
        #endregion Function initialisation DO NOT REMOVE
        #region Re-edit name put a major string in the begining
        $Name = "$($Name.Substring(0,1).ToUpper())$($Name.Substring(1))"
        #endregion Re-edit name put a major string in the begining
        #region check that the class name format is correct
        $Pattern = '^[\w]+$'
        $RegexMatch = Select-String -InputObject $Name -Pattern $Pattern -Verbose:$False
        if ($Null -eq $RegexMatch) {
            $ErrorMessage = "the class [$($Name)] is not in the right format, please use a standard format"
            Throw $ErrorMessage
            BREAK
        }
        #endregion check that the class name format is correct
        $ClassContent = ''
    }
    PROCESS {
        #region Function Processing DO NOT REMOVE
        Write-Verbose "Processing : $($FunctionName)"
        #region Function Processing DO NOT REMOVE
        $ClassContent = @"
Class $($Name) {
    $($Name)() {}
    [String] ToString() {
        Return '$($Name)'
    }
}
"@
    }
    END {
        #region Function closing  DO NOT REMOVE
        $TimeSpentinFunc = New-TimeSpan -Start $FunctionEnterTime -Verbose:$False -ErrorAction SilentlyContinue
        [String] ${TimeSpentString} = ''
        Switch ($TimeSpentinFunc) {
            {$_.TotalDays -gt 1} {$TimeSpentString = "$($_.TotalDays) D.";BREAK}
            {$_.TotalHours -gt 1} {$TimeSpentString = "$($_.TotalHours) h.";BREAK}
            {$_.TotalMinutes -gt 1} {$TimeSpentString = "$($_.TotalMinutes) min.";BREAK}
            {$_.TotalSeconds -gt 1} {$TimeSpentString = "$($_.TotalSeconds) s.";BREAK}
            {$_.TotalMilliseconds -gt 1} {$TimeSpentString = "$($_.TotalMilliseconds) ms.";BREAK}
            Default {$TimeSpentString = "$($_.Ticks) Ticks";BREAK}
        }
        Write-Verbose "Ending : $($FunctionName) - TimeSpent : $($TimeSpentString)"
        #endregion Function closing  DO NOT REMOVE
        #region outputing
        Write-output $ClassContent
        #endregion outputing
    }
}
Function New-PMHEnumContent {
    [CMDLetBinding()]
    Param(
        [Parameter(
            Position = 0,
            Mandatory = $True
        )]
        [Alias('EnumName')]
        [String] ${Name}
    )
    <#
        .SYNOPSIS
            New-PMHEnumContent Synopsis of the function

        .DESCRIPTION
            New-PMHEnumContent a short description of what the function do

        .PARAMETER Name
            Type      : the type of the parameter
            Position  : the position of the parameter
            Mandatory : if the parameter is mandatory

            a short description of the parameter

        .INPUTS
            type of the input

        .OUTPUTS
            type of the output

        .EXAMPLE
            PS> New-PMHEnumContent -Name

            Short Description of what will be done if the command is ran with ParameterName

        .LINK
            a lookalike ps function

        .NOTES
            Written by GirardetY
    #>
    BEGIN {
        #region Function initialisation DO NOT REMOVE
        [String] ${FunctionName} = $MyInvocation.MyCommand
        [DateTime] ${FunctionEnterTime} = [DateTime]::Now
        Write-Verbose "Entering : $($FunctionName)"
        #endregion Function initialisation DO NOT REMOVE
        #region Re-edit name put a major string in the begining
        $Name = "$($Name.Substring(0,1).ToUpper())$($Name.Substring(1))"
        #endregion Re-edit name put a major string in the begining
        #region check that the class name format is correct
        $Pattern = '^[\w]+$'
        $RegexMatch = Select-String -InputObject $Name -Pattern $Pattern -Verbose:$False
        if ($Null -eq $RegexMatch) {
            $ErrorMessage = "the class [$($Name)] is not in the right format, please use a standard format"
            Throw $ErrorMessage
            BREAK
        }
        #endregion check that the class name format is correct
        $EnumContent = ''
    }
    PROCESS {
        #region Function Processing DO NOT REMOVE
        Write-Verbose "Processing : $($FunctionName)"
        #region Function Processing DO NOT REMOVE
        $EnumContent = @"
Enum $($Name) {
}
"@
    }
    END {
        #region Function closing  DO NOT REMOVE
        $TimeSpentinFunc = New-TimeSpan -Start $FunctionEnterTime -Verbose:$False -ErrorAction SilentlyContinue
        [String] ${TimeSpentString} = ''
        Switch ($TimeSpentinFunc) {
            {$_.TotalDays -gt 1} {$TimeSpentString = "$($_.TotalDays) D.";BREAK}
            {$_.TotalHours -gt 1} {$TimeSpentString = "$($_.TotalHours) h.";BREAK}
            {$_.TotalMinutes -gt 1} {$TimeSpentString = "$($_.TotalMinutes) min.";BREAK}
            {$_.TotalSeconds -gt 1} {$TimeSpentString = "$($_.TotalSeconds) s.";BREAK}
            {$_.TotalMilliseconds -gt 1} {$TimeSpentString = "$($_.TotalMilliseconds) ms.";BREAK}
            Default {$TimeSpentString = "$($_.Ticks) Ticks";BREAK}
        }
        Write-Verbose "Ending : $($FunctionName) - TimeSpent : $($TimeSpentString)"
        #endregion Function closing  DO NOT REMOVE
        #region outputing
        Write-output $EnumContent
        #endregion outputing
    }
}
Function New-PMHReadMeContent {
    [CMDLetBinding()]
    Param(
        [Parameter(
            Position = 1,
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
        [String] ${Description}
    )
    <#
        .SYNOPSIS
            New-PMHReadMeContent Returns the content of the readme.md file

        .DESCRIPTION
            New-PMHReadMeContent Returns the content of the readme.md file

        .PARAMETER Name
            Type      : String
            Position  : 0
            Mandatory : True

            The name of the module

        .PARAMETER Description
            Type      : String
            Position  : 1
            Mandatory : False

            The Description of the module

        .PARAMETER Functions
            Type      : Array of String
            Position  : 2
            Mandatory : False

            The list of Public functions

        .INPUTS
            String and ArrayOfStrings

        .OUTPUTS
            String

        .EXAMPLE
            PS> New-PMHReadMeContent -Name 'MyModule'

            Will Generate a ReadMe.md content for the module MyModule

        .LINK
            Get-Content

        .NOTES
            Written by GirardetY
    #>
    BEGIN {
        #region Function initialisation DO NOT REMOVE
        [String] ${FunctionName} = $MyInvocation.MyCommand
        [DateTime] ${FunctionEnterTime} = [DateTime]::Now
        Write-Verbose "Entering : $($FunctionName)"
        #endregion Function initialisation DO NOT REMOVE
        $ReadMeContent = ''
    }
    PROCESS {
        #region Function Processing DO NOT REMOVE
        Write-Verbose "Processing : $($FunctionName)"
        #region Function Processing DO NOT REMOVE
        #region Title
        $ReadMeTitle = "# $($Name) - $($Version)"
        #endregion Title
        #region Description
        if ($Description -like '') {
            $Description = 'A Short description of the module'
        }
        #endregion Description
        #region functions
        $FunctionsList = ''
        $FunctionsDescription = ''
        ForEach ($Function in $Functions) {
            $FunctionsList = @"
$($FunctionsList)
* $($Function) [Link](#$($Function))
"@
            $FunctionsDescription = @"
$($FunctionsDescription)
## $($Function)
A Short description of the function

### Examples
  `PS> $($Function)`
  * Result Description

### Parameters
  * **-ParameterName** \<TypeName\>
    * **Type** : TypeName
    * **Mandatory** : Mandatory Bool (True or False)
    * **DefaultValue** : Default Value or *None*

    Short Description of what the parameter do

"@
        }
        #endregion functions
        #region build the content
        $ReadMeContent = @"
$($ReadMeTitle)
$($Description)
$($FunctionsList)
$($FunctionsDescription)

<sub>This file has been autogenerated by SPS-PoshModuleHelper</sub>
"@
        #endregion build the content
    }
    END {
        #region Function closing  DO NOT REMOVE
        $TimeSpentinFunc = New-TimeSpan -Start $FunctionEnterTime -Verbose:$False -ErrorAction SilentlyContinue
        [String] ${TimeSpentString} = ''
        Switch ($TimeSpentinFunc) {
            {$_.TotalDays -gt 1} {$TimeSpentString = "$($_.TotalDays) D.";BREAK}
            {$_.TotalHours -gt 1} {$TimeSpentString = "$($_.TotalHours) h.";BREAK}
            {$_.TotalMinutes -gt 1} {$TimeSpentString = "$($_.TotalMinutes) min.";BREAK}
            {$_.TotalSeconds -gt 1} {$TimeSpentString = "$($_.TotalSeconds) s.";BREAK}
            {$_.TotalMilliseconds -gt 1} {$TimeSpentString = "$($_.TotalMilliseconds) ms.";BREAK}
            Default {$TimeSpentString = "$($_.Ticks) Ticks";BREAK}
        }
        Write-Verbose "Ending : $($FunctionName) - TimeSpent : $($TimeSpentString)"
        #endregion Function closing  DO NOT REMOVE
        #region outputing
        Return $ReadMeContent
        #endregion outputing
    }
}
Function Update-PMHModuleManifest {
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
#endregion private Functions Declarations(DO NOT REMOVE)
#region public Functions Declarations (DO NOT REMOVE)
Function Reset-PoshModule {
    [CMDLetBinding(DefaultParameterSetName='_default')]
    Param(
        [Parameter(
            Position = 0,
            Mandatory = $True,
            ParameterSetName = 'ByName'
        )]
        [Alias('ModuleName','Module')]
        [String] ${Name},
        [Parameter(
            Position = 1,
            Mandatory = $False,
            ParameterSetName = 'ByName'
        )]
        [Alias('ModuleVersion')]
        [Version] ${Version},
        [Parameter(
            Position = 0,
            Mandatory = $True,
            ParameterSetName = 'ByPath'
        )]
        [Alias('ModulePath')]
        [String] ${Path},
        [Switch] ${Silent}
    )
    <#
        .SYNOPSIS
            Reset-PoshModule will force reload the module

        .DESCRIPTION
            Reset-PoshModule will force reload the module that call it (Remove-module, Import-module) be aware that the enums and classes will not be reloaded
            this function should be called within a module folder or with a given name and version

        .PARAMETER Name
            Type : String
            Position : 0
            Mandatory : True (ByName)

            Name of the module to reload if no name is given it will try to identify the module trough the location of the caller

        .PARAMETER Version
            Type : Version
            Position : 1
            Mandatory : False

            Version of the module to reload if no version is given it will try to identify the module trough the location of the caller

        .PARAMETER Path
            Type : String
            Position : 0
            Mandatory : True (ByPath)

            Path of the module to reload

        .PARAMETER Silent
            Type : Switch
            Mandatory : False

            Do not show the details

        .INPUTS
            None

        .OUTPUTS
            None

        .EXAMPLE
            PS> Reset-PoshModule

            Will reload the module related to the caller

        .EXAMPLE
            PS> Reset-PoshModule -Name 'MyModule

            Will reload the module named MyModule in it's last version

        .EXAMPLE
            PS> Reset-PoshModule -Name 'MyModule -Version '1.0.0.0'

            Will reload the module named MyModule in version 1.0.0.0

        .LINK
            Remove-Module, Import-Module

        .NOTES
            Written by Swiss Powershell
    #>
    BEGIN {
        #region Function initialisation DO NOT REMOVE
        [String] ${FunctionName} = $MyInvocation.MyCommand
        [DateTime] ${FunctionEnterTime} = [DateTime]::Now
        Write-Verbose "Entering : $($FunctionName)"
        #endregion Function initialisation DO NOT REMOVE
        #region override progress preference
        $OriginalPP = $ProgressPreference
        $ProgressPreference = 'SilentlyContinue'
        #endregion override progress preference
        #region internal function
        Function Write-PoshModuleInfo {
            [CMDLetBinding()]
            Param(
                [Parameter(
                    Position = 0,
                    Mandatory = $True
                )]
                [String] ${Name},
                [Parameter(
                    Position = 1,
                    Mandatory = $True
                )]
                [Version] ${Version},
                [Parameter(
                    Position = 2,
                    Mandatory = $True
                )]
                [String] ${Caller},
                [Parameter(
                    Position = 3,
                    Mandatory = $False
                )]
                [UInt32] ${BorderSize} = 4,
                [Parameter(
                    Position = 4,
                    Mandatory = $False
                )]
                [UInt32] ${MarginSize} = 3,
                [Parameter(
                    Position = 5,
                    Mandatory = $False
                )]
                [Char] ${BorderChar} = '#',
                [Parameter(
                    Position = 6,
                    Mandatory = $False
                )]
                [ConsoleColor] ${Color} = 'DarkYellow'
            )
            BEGIN {
                $ModuleNameLength = $Name.Length
                $ModuleVersionLength = $Version.ToString().Length
                $ScriptNameLength = $Caller.Length

                $MaxLength = @($ModuleNameLength,$ModuleVersionLength,$ScriptNameLength) | Measure-Object -Maximum | Select-Object -ExpandProperty 'Maximum'

                $BorderString = $BorderChar.ToString() * $BorderSize
                $MarginString = ' ' * $MarginSize

                $ModuleNameMargin = $MaxLength - $ModuleNameLength
                $ModuleVersionMargin = $MaxLength - $ModuleVersionLength
                $ScriptNameMargin = $MaxLength - $ScriptNameLength

                $ModuleNameMarginLeft = [MATH]::Floor(($ModuleNameMargin / 2))
                $ModuleNameMarginRight = [MATH]::Ceiling(($ModuleNameMargin / 2))
                $ModuleNameString = "$($BorderString)$($MarginString)$(' ' * $ModuleNameMarginLeft)$($Name)$(' ' * $ModuleNameMarginRight)$($MarginString)$($BorderString)"

                $ModuleVersionMarginLeft =  [MATH]::Floor(($ModuleVersionMargin / 2))
                $ModuleVersionMarginRight = [MATH]::Ceiling(($ModuleVersionMargin / 2))
                $ModuleVersionString = "$($BorderString)$($MarginString)$(' ' * $ModuleVersionMarginLeft)$($Version.ToString())$(' ' * $ModuleVersionMarginRight)$($MarginString)$($BorderString)"

                $ScriptNameMarginLeft =  [MATH]::Floor(($ScriptNameMargin / 2))
                $ScriptNameMarginRight = [MATH]::Ceiling(($ScriptNameMargin / 2))
                $ScriptNameString = "$($BorderString)$($MarginString)$(' ' * $ScriptNameMarginLeft)$($Caller)$(' ' * $ScriptNameMarginRight)$($MarginString)$($BorderString)"

                $TopAndBottomLine = $BorderChar.ToString() * ($BorderSize + $MarginSize + $MaxLength + $MarginSize + $BorderSize )
                $SpacerLine = "{0}{1,$($MaxLength + (2 * $MarginSize))}{0}" -f $BorderString,' '
            }
            PROCESS {
                Write-Host $TopAndBottomLine -ForegroundColor $Color
                Write-Host $SpacerLine -ForegroundColor $Color
                Write-Host $ModuleNameString -ForegroundColor $Color
                Write-Host $ModuleVersionString -ForegroundColor $Color
                Write-Host $ScriptNameString -ForegroundColor $Color
                Write-Host $SpacerLine -ForegroundColor $Color
                Write-Host $TopAndBottomLine -ForegroundColor $Color
            }
            END {}
        }
        #endregion internal function
        #region identify the module
        [String] $ParameterSetName = $PsCmdlet.ParameterSetName
        [System.Management.Automation.InvocationInfo] ${InvocationInfo} = $MyInvocation
        [String] $Caller = Split-Path -path $InvocationInfo.ScriptName -leaf

        Write-Verbose "ParameterSetName detected : $($ParameterSetName)"
        switch ($ParameterSetName) {
            '_default' {
                $Path = Split-Path -path $InvocationInfo.ScriptName
                [String] $ModuleName = Split-Path -Path $(Split-Path -Path $Path) -leaf
                [Version] $ModuleVersion = Split-Path -Path $Path -leaf
                BREAK
            }
            'ByName' {
                [String] $ModuleName = $Name
                if ($Null -ne $Version) {
                    [Version] $ModuleVersion = $Version
                }
                BREAK
            }
            'ByPath' {
                [String] $ModuleName = Split-Path -Path $(Split-Path -Path $Path) -leaf
                [Version] $ModuleVersion = Split-Path -Path $Path -leaf
                BREAK
            }
            default {
                Throw 'Unexpected error unable to define the parametersetname please review your call'
                BREAK
            }
        }
        if ($Null -eq $ModuleVersion) {
            # identify the last version of the given module
            [Version] $ModuleVersion = Get-Module -ListAvailable -Name $ModuleName -Verbose:$False -ErrorAction 'SilentlyContinue' | Sort-Object -Property 'Version' | Select-Object -ExpandProperty 'Version' -Last 1
        }
        if (($Null -like $ModuleVersion) -or ($Null -like $ModuleName)) {
            Throw 'Unexpected error unable to determine the module please run this command from a module folder or give at least a name or a path'
        }Else{
            Write-Verbose "Identified Module [$($ModuleName)] in version [$($ModuleVersion)]"
        }
        #endregion identify the module

    }
    PROCESS {
        #region Function Processing DO NOT REMOVE
        Write-Verbose "Processing : $($FunctionName)"
        #region Function Processing DO NOT REMOVE
        if ($Silent -eq $False) {
            Write-PoshModuleInfo -Name $ModuleName -Version $ModuleVersion -Caller $Caller
        }
        #region remove / import module
        Write-Verbose "Removing module [$($ModuleName)]"
        Remove-Module $ModuleName -ErrorAction Ignore -Verbose:$False
        Write-Verbose "Importing module [$($ModuleName)] in version [$($ModuleVersion)]"
        Import-Module -Name $ModuleName -RequiredVersion $ModuleVersion -Force
        #endregion remove / import module

    }
    END {
        #region Function closing  DO NOT REMOVE
        $TimeSpentinFunc = New-TimeSpan -Start $FunctionEnterTime -Verbose:$False -ErrorAction SilentlyContinue
        [String] ${TimeSpentString} = ''
        Switch ($TimeSpentinFunc) {
            {$_.TotalDays -gt 1} {$TimeSpentString = "$($_.TotalDays) D.";BREAK}
            {$_.TotalHours -gt 1} {$TimeSpentString = "$($_.TotalHours) h.";BREAK}
            {$_.TotalMinutes -gt 1} {$TimeSpentString = "$($_.TotalMinutes) min.";BREAK}
            {$_.TotalSeconds -gt 1} {$TimeSpentString = "$($_.TotalSeconds) s.";BREAK}
            {$_.TotalMilliseconds -gt 1} {$TimeSpentString = "$($_.TotalMilliseconds) ms.";BREAK}
            Default {$TimeSpentString = "$($_.Ticks) Ticks";BREAK}
        }
        Write-Verbose "Ending : $($FunctionName) - TimeSpent : $($TimeSpentString)"
        #endregion Function closing  DO NOT REMOVE
        $ProgressPreference = $OriginalPP
    }
}
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
        [Switch] ${NoHelp},
        [Parameter(
            Position = 15,
            Mandatory = $False
        )]
        [Switch] ${Minimal}
    )
    <#
        .SYNOPSIS
            New-PoshModule Synopsis of the function

        .DESCRIPTION
            New-PoshModule a short description of what the function do

        .PARAMETER ParameterName
            Type      : the type of the parameter
            Position  : the position of the parameter
            Mandatory : if the parameter is mandatory

            a short description of the parameter

        .INPUTS
            type of the input

        .OUTPUTS
            type of the output

        .EXAMPLE
            PS> New-PoshModule

            Short Description of what will be done if the command is ran

        .EXAMPLE
            PS> New-PoshModule -ParameterName

            Short Description of what will be done if the command is ran with ParameterName

        .LINK
            a lookalike ps function

        .NOTES
            Written by GirardetY
    #>
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
            BREAK
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
        # [Boolean] ${ExistAsAvailable} = $False
        # Write-Verbose "Getting all available modules..."
        # $AllModules = Get-Module -ListAvailable:$True -Verbose:$False
        Write-Verbose "Searching if '$($Name)' exist as a child of any of the module path"
        ForEach ($Path in $AllModulesPath) {
            [Boolean] ${Exist} = $(Get-ChildItem -LiteralPath $Path -Directory -Verbose:$False -ErrorAction Ignore | Select-Object -ExpandProperty 'Name') -contains $Name
            if ($Exist -eq $True) {
                Write-Verbose "The module '$($Name)' exist in $($Path)"
                $ExistAsSub = $True
            }
        }
        # if ($ExistAsSub -eq $False) {
        #     Write-Verbose "Searching if $($Name) exist in available module"
        #     $ExistAsAvailable = $($AllModules | Select-Object -ExpandProperty 'Name') -contains $Name
        # }

        if ($ExistAsSub -eq $True) {
            Throw "A module named '$($Name)' has been found in modules subdir, please use Update-PSModule to update the module"
        }
        # }Elseif ($ExistAsAvailable -eq $True) {
        #     Throw "A module named '$($Name)' allready exist as an available module, please use Update-PSModule to update the module"
        # }
        #endregion validate that a module with the same name does not allready exist
        #region validate that the guid is not allready used
        # [Boolean] ${ExitLoop} = $False
        # Do {
        #     [PSModuleInfo] ${SameGuidModule} = $AllModules | Where-Object {$_.Guid -eq $Guid}
        #     if ($SameGuidModule) {
        #         #Throw "A module with guid $($Guid) allready exist ($($SameGuidModule)), please use a different GUID"
        #         Write-Warning "The GUID '$($Guid)' is allready used by $($SameGuidModule) a different guid will be used"
        #         $Guid = $([GUID]::NewGUID() | Select-Object -ExpandProperty 'Guid')
        #         Write-Verbose "Guid is now '$($Guid)'"
        #     }else {
        #         $ExitLoop = $True
        #     }
        # }Until ($ExitLoop -eq $True)
        #endregion validate that the guid is not allready used
        #endregion validate parameters
        #region define constants
        [String] ${DebugFileName} = 'Debug'
        [String] ${RadMeFileName} = 'Readme'
        [String] ${ModulePath} = "$($ModuleRootPath)\$($Name)"
        [String] ${ModuleFilesPath} = "$($ModulePath)\$($Version.ToString())"
        [String] ${ModuleManifestFileFullName} = "$($ModuleFilesPath)\$($Name).psd1"
        [String] ${ModuleFileFullName} = "$($ModuleFilesPath)\$($Name).psm1"
        [String] ${DebugFileFullName} = "$($ModuleFilesPath)\$($DebugFileName).ps1"
        [String] ${ReadMeFileFullName} = "$($ModuleFilesPath)\$($RadMeFileName).md"
        #endregion define constants
    }
    PROCESS {
        #region Function Processing DO NOT REMOVE
        Write-Verbose "Processing : $($FunctionName)"
        #region Function Processing DO NOT REMOVE
        #region create module content
        $ModuleTitle = @"
# File automatically created by SPS-PoshModuleHelper
# Module Name        : $($Name)
# Module Version     : $($Version)
# Module Created on  : $(Get-Date -format "hh.MM.yyyy HH:mm")
# Module Created by  : $($Author)
# Module Modified on :
# Module Modified by :

"@
        #region create enum content
        $EnumsContent = @'
#region Enums Declarations (DO NOT REMOVE)
'@
        if ($Enums.count -gt 0) {
            ForEach ($Enum in $Enums) {
                $EnumContent = New-PMHEnumContent -Name $Enum
                $EnumsContent = @"
$($EnumsContent)
$($EnumContent)
"@
            }
        }
        $EnumsContent = @"
$($EnumsContent)
#endregion Enums Declarations (DO NOT REMOVE)
"@
        #endregion create enum content
        #region create class content
        $ClassesContent = @'
#region Classes Declarations (DO NOT REMOVE)
'@
        if ($Classes.count -gt 0) {
            ForEach ($Class in $Classes) {
                $ClassContent = New-PMHClassContent -Name $Class
                $ClassesContent = @"
$($ClassesContent)
$($ClassContent)
"@
            }
        }
        $ClassesContent = @"
$($ClassesContent)
#endregion Classes Declarations (DO NOT REMOVE)
"@
        #endregion create class content
        #region create private function content
        $PrivateFunctionsContent = @'
#region Private Functions Declarations (DO NOT REMOVE)
'@
        if ($PrivateFunctions.count -gt 0) {
            ForEach ($Function in $PrivateFunctions) {
                $FunctionContent = New-PMHFunctionContent -Name $Function -Author $Author -Strict:$Strict -NoHelp:$NoHelp -Minimal:$Minimal
                $PrivateFunctionsContent = @"
$($PrivateFunctionsContent)
$($FunctionContent)
"@
            }
        }
        $PrivateFunctionsContent = @"
$($PrivateFunctionsContent)
#endregion Private Functions Declarations (DO NOT REMOVE)
"@
        #endregion create private function content
        #region create public function content
        $PublicFunctionsContent = @'
#region Public Functions Declarations (DO NOT REMOVE)
'@
        if ($Functions.count -gt 0) {
            ForEach ($Function in $Functions) {
                $FunctionContent = New-PMHFunctionContent -Name $Function -Author $Author -Strict:$Strict -NoHelp:$NoHelp -Minimal:$Minimal
                $PublicFunctionsContent = @"
$($PublicFunctionsContent)
$($FunctionContent)
"@
            }
        }
        $PublicFunctionsContent = @"
$($PublicFunctionsContent)
#endregion Public Functions Declarations (DO NOT REMOVE)
"@
        #endregion create public function content
        #region append all the content to the module content
        $PSModuleContent = @"
$($ModuleTitle)
$($EnumsContent)
$($ClassesContent)
$($PrivateFunctionsContent)
$($PublicFunctionsContent)
"@
        #endregion append all the content to the module content
        #endregion create module content
        #region create files / folder
        #region create folder
        Try {
            $Null = New-Item -Path $ModuleFilesPath -ItemType Directory -Force -Verbose:$False -ErrorAction 'Stop'
        }Catch {
            Throw "An unexpected error occurs while creating module path [$($ModuleFilesPath)]: $($_.Exception.Message)"
            BREAK
        }
        #endregion create folder
        #region create module file
        Try {
            $Null = Set-Content -Path $ModuleFileFullName -Value $PSModuleContent -Force -Verbose:$False -ErrorAction 'Stop'
        }Catch{
            Throw "An unexpected error occurs while creating module file [$($ModuleFileFullName)]: $($_.Exception.Message)"
            BREAK
        }
        #endregion create module file
        #region create module definition file
        $Splat = @{
            Path = $ModuleManifestFileFullName
            Guid = $Guid
            Author = $Author
            CompanyName = $CompanyName
            Copyright = $Copyright
            RootModule = Split-path -Path $ModuleFileFullName -leaf -Verbose:$False -ErrorAction 'Stop'
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
        #endregion create module definition file
        #region create debug file
        $DebugContent = New-PMHDebugContent -VerboseDebug:$VerboseDebug -Strict:$Strict
        Try {
            $Null = Set-Content -Path $DebugFileFullName -Value $DebugContent -Force -Verbose:$False -ErrorAction 'Stop'
        }Catch{
            Throw "An unexpected error occurs while creating debug file [$($DebugFileFullName)]: $($_.Exception.Message)"
            BREAK
        }
        #endregion create debug file
        #region create readme file
        if ($NoHelp -eq $False) {
            $ReadMeContent = New-PMHReadMeContent -Name $Name -Version $Version -Description $Description
            Try {
                $Null = Set-Content -Path $ReadMeFileFullName -Value $ReadMeContent -Force -Verbose:$False -ErrorAction 'Stop'
            }Catch{
                Throw "An unexpected error occurs while creating Readme file [$($ReadMeFileFullName)]: $($_.Exception.Message)"
                BREAK
            }
        }
        #endregion create readme file
        #endregion create files
    }
    END {
        #region Function closing  DO NOT REMOVE
        $TimeSpentinFunc = New-TimeSpan -Start $FunctionEnterTime -Verbose:$False -ErrorAction SilentlyContinue
        [String] ${TimeSpentString} = ''
        Switch ($TimeSpentinFunc) {
            {$_.TotalDays -gt 1} {$TimeSpentString = "$($_.TotalDays) D.";BREAK}
            {$_.TotalHours -gt 1} {$TimeSpentString = "$($_.TotalHours) h.";BREAK}
            {$_.TotalMinutes -gt 1} {$TimeSpentString = "$($_.TotalMinutes) min.";BREAK}
            {$_.TotalSeconds -gt 1} {$TimeSpentString = "$($_.TotalSeconds) s.";BREAK}
            {$_.TotalMilliseconds -gt 1} {$TimeSpentString = "$($_.TotalMilliseconds) ms.";BREAK}
            Default {$TimeSpentString = "$($_.Ticks) Ticks";BREAK}
        }
        Write-Verbose "Ending : $($FunctionName) - TimeSpent : $($TimeSpentString)"
        #endregion Function closing  DO NOT REMOVE
        #region outputing
        Write-Host "The module [$($Name)] version [$($Version.ToString())] has been created under in: $($ModuleFilesPath)" -ForegroundColor 'DarkCyan'
        $Items = Get-Item -path "$($ModuleFilesPath)\*"
        Return $Items
        #endregion outputing
    }
}
Function Update-PoshModule {
    [CMDLetBinding()]
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
        [String[]] ${AddEnums},
        [Parameter(
            Position = 7,
            Mandatory = $False
        )]
        [String[]] ${AddClasses},
        [Parameter(
            Position = 9,
            Mandatory = $False
        )]
        [Switch] ${Clear},
        [Parameter(
            Position = 10,
            Mandatory = $False
        )]
        [Switch] ${Global},
        [Parameter(
            Position = 11,
            Mandatory = $False
        )]
        [Switch] ${Strict},
        [Parameter(
            Position = 12,
            Mandatory = $False
        )]
        [Switch] ${NoHelp},
        [Parameter(
            Position = 13,
            Mandatory = $False
        )]
        [Switch] ${Minimal}
    )
    <#
        .SYNOPSIS
            Update-PoshModule Synopsis of the function

        .DESCRIPTION
            Update-PoshModule a short description of what the function do

        .PARAMETER ParameterName
            Type      : the type of the parameter
            Position  : the position of the parameter
            Mandatory : if the parameter is mandatory

            a short description of the parameter

        .INPUTS
            type of the input

        .OUTPUTS
            type of the output

        .EXAMPLE
            PS> Update-PoshModule

            Short Description of what will be done if the command is ran

        .EXAMPLE
            PS> Update-PoshModule -ParameterName

            Short Description of what will be done if the command is ran with ParameterName

        .LINK
            a lookalike ps function

        .NOTES
            Written by GirardetY
    #>
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
            [String] ${Author} = $SourceModule | Select-Object -ExpandProperty 'Author'
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
        #endregion validate enum are unique
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
                if (($Major -eq $False) -and ($Minor -eq $False) -and ($Build -eq $False) -and ($Revision -eq $False)) {
                    if (($AddFunctions.count -gt 0) -or ($AddPrivateFunctions.count -gt 0) -or ($AddClasses.count -gt 0) -or ($AddEnums.count -gt 0)) {
                        # adding a function or a class is a minor update
                        $MinorStr = $Version.Minor + 1
                        $RevisionStr = $Version.Revision + 1
                        $NewVersion = New-Object System.Version -ArgumentList $Version.Major,$MinorStr, $Version.Build, $RevisionStr
                        $Version = $NewVersion
                    }Else{
                        # just updating the version is a revision
                        $RevisionStr = $Version.Revision + 1
                        $NewVersion = New-Object System.Version -ArgumentList $Version.Major,$Version.Minor, $Version.Build, $RevisionStr
                        $Version = $NewVersion
                    }
                }
                BREAK
            }
        }
        Write-Verbose "The new module version will be '$($Version)'"
        #endregion define the version
    }
    PROCESS {
        #region Function Processing DO NOT REMOVE
        Write-Verbose "Processing : $($FunctionName)"
        #endregion Function Processing DO NOT REMOVE

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
        #region create the new contents
        #region create the new enum content
        $NewEnumContent = ''
        if ($AddEnums.Count -gt 0) {
            ForEach ($Enum in $AddEnums) {
                $EnumContent = New-PMHEnumContent -Name $Enum
                $NewEnumContent = @"
$($NewEnumContent)
$($EnumContent)
"@
            }
        }
        #endregion create the new enum content
        #region create the new Class content
        $NewClassContent = ''
        if ($AddClasses.Count -gt 0) {
            ForEach ($Class in $AddClasses) {
                $ClassContent = New-PMHClassContent -Name $Class
                $NewClassContent = @"
$($NewClassContent)
$($ClassContent)
"@
            }
        }
        #endregion create the new enum content
        #region create the new Private Function content
        $NewPrivateFunctionContent = ''
        if ($AddPrivateFunctions.Count -gt 0) {
            ForEach ($Function in $AddPrivateFunctions) {
                $FunctionContent = New-PMHFunctionContent -Name $Function -Author $Author -Strict:$Strict -NoHelp:$NoHelp -Minimal:$Minimal
                $NewPrivateFunctionContent = @"
$($NewPrivateFunctionContent)
$($FunctionContent)
"@
            }
        }
        #endregion create the Private Function content
        #region create the new Public Function content
        $NewPublicFunctionContent = ''
        if ($AddFunctions.Count -gt 0) {
            ForEach ($Function in $AddFunctions) {
                $FunctionContent = New-PMHFunctionContent -Name $Function -Author $Author -Strict:$Strict -NoHelp:$NoHelp -Minimal:$Minimal
                $NewPublicFunctionContent = @"
$($NewPublicFunctionContent)
$($FunctionContent)
"@
            }
        }
        #endregion create the Public Function content
        #endregion create the new contents
        #region place content in original psm1 file
        $PSM1FileFullName = "$($TargetPath)\$($Name).psm1"
        $RawModuleContent = Get-Content -Path $PSM1FileFullName -Raw
        #region place Enums
        if ($AddEnums.Count -gt 0) {
            $EnumLastLine = '#endregion Enums Declarations (DO NOT REMOVE)'
            if ($RawModuleContent -like "*$($EnumLastLine)*") {
                $RawModuleContent = $RawModuleContent.Replace($EnumLastLine,@"
$($NewEnumContent)
$($EnumLastLine)
"@)
            }Else{
                #Unable to identify the position add in the end of the file
                $RawModuleContent = @"
$($RawModuleContent)
$($NewEnumContent)
"@
            }
        }
        #endregion place Enums
        #region place classes
        if ($AddClasses.Count -gt 0) {
            $ClassLastLine = '#endregion Classes Declarations (DO NOT REMOVE)'
            if ($RawModuleContent -like "*$($ClassLastLine)*") {
                $RawModuleContent = $RawModuleContent.Replace($ClassLastLine,@"
$($NewClassContent)
$($ClassLastLine)
"@)
            }Else{
                #Unable to identify the position add in the end of the file
                $RawModuleContent = @"
$($RawModuleContent)
$($NewClassContent)
"@
            }
        }
        #endregion place classes
        #region place private functions
        if ($AddPrivateFunctions.Count -gt 0) {
            $RegionPrivateFunctionLastLine = '#endregion Private Functions Declarations (DO NOT REMOVE)'
            if ($RawModuleContent -like "*$($RegionPrivateFunctionLastLine)*") {
                $RawModuleContent = $RawModuleContent.Replace($RegionPrivateFunctionLastLine,@"
$($NewPrivateFunctionContent)
$($RegionPrivateFunctionLastLine)
"@)
            }Else{
                #Unable to identify the position add in the end of the file
                $RawModuleContent = @"
$($RawModuleContent)
$($NewPrivateFunctionContent)
"@
            }
        }
        #endregion place private functions
        #region place Public functions
        if ($AddFunctions.Count -gt 0) {
            $RegionPublicFunctionLastLine = '#endregion Public Functions Declarations (DO NOT REMOVE)'
            if ($RawModuleContent -like "*$($RegionPublicFunctionLastLine)*") {
                $RawModuleContent = $RawModuleContent.Replace($RegionPublicFunctionLastLine,@"
$($NewPublicFunctionContent)
$($RegionPublicFunctionLastLine)
"@)
            }Else{
                #Unable to identify the position add in the end of the file
                $RawModuleContent = @"
$($RawModuleContent)
$($NewPublicFunctionContent)
"@
            }
        }

        #endregion place Public functions
        #region save the module content
        Try {
            Set-Content -Path $PSM1FileFullName -Value $RawModuleContent -Force -ErrorAction 'Stop' | out-null
        }Catch {
            Throw "Unexpected error while trying to save content in [$($PSM1FileFullName)]: $($_.Exception.Message)"
            BREAK
        }
        #endregion save the module content
        #endregion place content in original psm1 file

        #region update the Manifest file
        $ManifestFileFullName = Get-Item -Path "$($TargetPath)\$($Name).psd1"
        Write-Verbose "Updating manifest in '$($ManifestFileFullName)'"
        Update-PMHModuleManifest -Manifest $ManifestFileFullName -Version $Version -AddFunctions $AddFunctions | out-null
        #endregion update the Manifest file

    }
    END {
        #region Function closing DO NOT REMOVE
        $TimeSpentinFunc = New-TimeSpan -Start $FunctionEnterTime -Verbose:$False -ErrorAction SilentlyContinue
        [String] ${TimeSpentString} = ''
        Switch ($TimeSpentinFunc) {
            {$_.TotalDays -gt 1} {$TimeSpentString = "$($_.TotalDays) D.";BREAK}
            {$_.TotalHours -gt 1} {$TimeSpentString = "$($_.TotalHours) h.";BREAK}
            {$_.TotalMinutes -gt 1} {$TimeSpentString = "$($_.TotalMinutes) min.";BREAK}
            {$_.TotalSeconds -gt 1} {$TimeSpentString = "$($_.TotalSeconds) s.";BREAK}
            {$_.TotalMilliseconds -gt 1} {$TimeSpentString = "$($_.TotalMilliseconds) ms.";BREAK}
            Default {$TimeSpentString = "$($_.Ticks) Ticks";BREAK}
        }
        Write-Verbose "Ending : $($FunctionName) - TimeSpent : $($TimeSpentString)"
        #endregion Function closing DO NOT REMOVE
        #region outputing
        #endregion outputing
    }
}
Function New-PoshModuleManifest {
    [CMDLetBinding()]
    Param(
        [Parameter(Position = 0, Mandatory = $True)]
        [String] ${Name},
        [Parameter(Position = 1, Mandatory = $False)]
        [String] ${RootModule},
        [Parameter(Position = 2, Mandatory = $False)]
        [Version] ${ModuleVersion} = [Version]::New('1.0.0.0'),
        [Parameter(Position = 3, Mandatory = $False)]
        [GUID] ${Guid} = "$([GUID]::NewGuid())",
        [Parameter(Position = 4, Mandatory = $False)]
        [String] ${Author} = "$($($Env:UserName.Substring(0,1)).ToUpper())$($Env:UserName.Substring(1))",
        [Parameter(Position = 5, Mandatory = $False)]
        [String] ${CompanyName} = "$($($Env:UserName.Substring(0,1)).ToUpper())$($Env:UserName.Substring(1))''s Company",
        [Parameter(Position = 6, Mandatory = $False)]
        [String] ${Copyright} = "(c) $(Get-Date -Format yyyy) $($($Env:UserName.Substring(0,1)).ToUpper())$($Env:UserName.Substring(1))''s Company",
        [Parameter(Position = 7, Mandatory = $False)]
        [String] ${Description},
        [Parameter(Position = 8, Mandatory = $False)]
        [Version] ${PowerShellVersion},
        [Parameter(Position = 9, Mandatory = $False)]
        [Version] ${PowerShellHostVersion},
        [Parameter(Position = 10, Mandatory = $False)]
        [String] ${PowerShellHostName},
        [Parameter(Position = 11, Mandatory = $False)]
        [Version] ${DotNetFrameworkVersion},
        [Parameter(Position = 12, Mandatory = $False)]
        [String] ${CLrVersion},
        [Parameter(Position = 13, Mandatory = $False)]
        [Nullable[PMHProcessArchitecture]] ${ProcessorArchitecture},
        [Parameter(Position = 14, Mandatory = $False)]
        [Object] ${RequiredModules},
        [Parameter(Position = 15, Mandatory = $False)]
        [String[]] ${RequiredAssemblies},
        [Parameter(Position = 16, Mandatory = $False)]
        [String[]] ${ScriptsToProcess},
        [Parameter(Position = 17, Mandatory = $False)]
        [String[]] ${TypeToProcess},
        [Parameter(Position = 18, Mandatory = $False)]
        [String[]] ${FormatToProcess},
        [Parameter(Position = 19, Mandatory = $False)]
        [Object[]] ${NestedModules},
        [Parameter(Position = 20, Mandatory = $False)]
        [String[]] ${FunctionsToExport},
        [Parameter(Position = 21, Mandatory = $False)]
        [String[]] ${CmdletsToExport},
        [Parameter(Position = 22, Mandatory = $False)]
        [String[]] ${VariablesToExport},
        [Parameter(Position = 23, Mandatory = $False)]
        [String[]] ${AliasesToExport},
        [Parameter(Position = 24, Mandatory = $False)]
        [String[]] ${DscRessourcesToExport},
        [Parameter(Position = 25, Mandatory = $False)]
        [Object[]] ${ModuleList},
        [Parameter(Position = 26, Mandatory = $False)]
        [String[]] ${FileList},
        [Parameter(Position = 27, Mandatory = $False)]
        [PMHPSData] ${PrivateData} = [PMHPSData]::New(),
        [Parameter(Position = 28, Mandatory = $False)]
        [String] ${HelpInfoUri},
        [Parameter(Position = 29, Mandatory = $False)]
        [String] ${DefaultCommandPrefix},
        [Parameter(Position = 30, Mandatory = $False)]
        [Nullable[PMHPSEditions]] ${CompatiblePSEditions},
        [Parameter(Position = 31, Mandatory = $False)]
        [String[]] ${Tags},
        [Parameter(Position = 32, Mandatory = $False)]
        [URI] ${LicenseUri},
        [Parameter(Position = 33, Mandatory = $False)]
        [URI] ${ProjectUri},
        [Parameter(Position = 34, Mandatory = $False)]
        [URI] ${IconUri},
        [Parameter(Position = 35, Mandatory = $False)]
        [String] ${ReleaseNotes}

    )
    BEGIN {
        #region Function initialisation DO NOT REMOVE
        [String] ${FunctionName} = $MyInvocation.MyCommand
        [DateTime] ${FunctionEnterTime} = [DateTime]::Now
        Write-Verbose "Entering : $($FunctionName)"
        #endregion Function initialisation DO NOT REMOVE
    }
    PROCESS {
        #region Function Processing DO NOT REMOVE
        Write-Verbose "Processing : $($FunctionName)"
        #region Function Processing DO NOT REMOVE
        $Object = [PoshManifest]::New()
        $Object.Name = $Name
        $Object.RootModule = $RootModule
        $Object.ModuleVersion = $ModuleVersion
        $Object.Guid = $Guid
        $Object.Author = $Author
        $Object.CompanyName = $CompanyName
        $Object.Copyright = $Copyright
        $Object.Description = $Description
        $Object.PowerShellVersion = $PowerShellVersion
        $Object.PowerShellHostVersion = $PowerShellHostVersion
        $Object.PowerShellHostName = $PowerShellHostName
        $Object.DotNetFrameworkVersion = $DotNetFrameworkVersion
        $Object.CLrVersion = $CLrVersion
        $Object.ProcessorArchitecture = $ProcessorArchitecture
        $Object.RequiredModules = $RequiredModules
        $Object.RequiredAssemblies = $RequiredAssemblies
        $Object.ScriptsToProcess = $ScriptsToProcess
        $Object.TypeToProcess = $TypeToProcess
        $Object.FormatToProcess = $FormatToProcess
        $Object.NestedModules = $NestedModules
        $Object.FunctionsToExport = $FunctionsToExport
        $Object.CmdletsToExport = $CmdletsToExport
        $Object.VariablesToExport = $VariablesToExport
        $Object.AliasesToExport = $AliasesToExport
        $Object.DscRessourcesToExport = $DscRessourcesToExport
        $Object.ModuleList = $ModuleList
        $Object.FileList = $FileList
        $Object.PrivateData = $PrivateData
        $Object.HelpInfoUri = $HelpInfoUri
        $Object.DefaultCommandPrefix = $DefaultCommandPrefix
        $Object.CompatiblePSEditions = $CompatiblePSEditions

        $Object.PrivateData.Tags = $Tags
        $Object.PrivateData.IconUri = $IconUri
        $Object.PrivateData.LicenseUri = $LicenseUri
        $Object.PrivateData.ProjectUri = $ProjectUri
        $Object.PrivateData.ReleaseNotes = $ReleaseNotes
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
        Return $Object
    }
}
Function Get-PoshModuleManifest {
    [CMDLetBinding(DefaultParameterSetName = 'ByName')]
    Param(
        [Parameter(
            Position = 0,
            Mandatory = $True,
            ParameterSetName = 'ByName'

        )]
        [String] ${Name},
        [Parameter(
            Position = 1,
            Mandatory = $False,
            ParameterSetName = 'ByName'

        )]
        [Version] ${Version},
        [Parameter(
            Position = 0,
            Mandatory = $True,
            ParameterSetName = 'ByFile'

        )]
        [String] ${Path}
    )
    BEGIN {
        #region Function initialisation DO NOT REMOVE
        [String] ${FunctionName} = $MyInvocation.MyCommand
        [DateTime] ${FunctionEnterTime} = [DateTime]::Now
        Write-Verbose "Entering : $($FunctionName)"
        #endregion Function initialisation DO NOT REMOVE
        $Module = $Null
        [String] $ParameterSetName = $PsCmdlet.ParameterSetName
        if ($ParameterSetName -eq 'ByName') {
            Try {
                $ModuleInfo = Get-Module -Name $Name -Verbose:$False -ErrorAction 'Stop'
            }Catch {
                Throw "Error while retrieving module named $($Name): $($_.Exception.Message)"
                BREAK
            }
            if ($ModuleInfo) {
                if ($Version) {
                    $ModuleToGet = $ModuleInfo | Where-Object {$_.Version -eq $Version}
                }Else{
                    $ModuleToGet = $ModuleInfo | Sort-Object -Property 'Version' | Select-Object -Last 1
                }
                if ($ModuleToGet) {
                    $ModulePath = $ModuleToGet | Select-Object -ExpandProperty 'ModuleBase'
                    $ModuleManifestItem = @(Get-ChildItem -Path $ModulePath -Filter '*.psd1')
                    $ModuleName = $ModuleToGet | Select-Object -ExpandProperty 'Name'
                    if ($ModuleManifestItem.count -gt 1) {
                        $ModuleManifestItem = $ModuleManifest | Where-Object {$_.BaseName -eq $ModuleName}
                    }
                    $ManifestPath = $ModuleManifestItem | Select-Object -ExpandProperty 'FullName'
                }Else{
                    Throw "No module named $($Name) found in your PSModulePath"
                    BREAK
                }
            }Else{
                Throw "No module named $($Name) found in your PSModulePath"
                BREAK
            }
        }Else{
            Try {
                $Item = Get-Item -Path $Path
            }Catch {
                Throw "Error while getting path $($Path): $($_.Exception.Message)"
                BREAK
            }
            if ($Item.PSIsContainer) {
                $ModuleManifestItem = @(Get-ChildItem -Path $Path -Filter '*.psd1')
                if ($ModuleManifestItem.count -gt 1) {
                    $ModuleManifestItem = $ModuleManifest | Where-Object {$_.BaseName -eq $Name}
                }
                $ManifestPath = $ModuleManifestItem | Select-Object -ExpandProperty 'FullName'
            }Elseif ($Item.Extension -eq '.psd1'){
                $ManifestPath = $Path
            }Else{
                Throw "Path should be either path of a module or a psd1 file unable to identify the module using path [$($Path)]"
                BREAK
            }
        }
    }
    PROCESS {
        #region Function Processing DO NOT REMOVE
        Write-Verbose "Processing : $($FunctionName)"
        #region Function Processing DO NOT REMOVE
        $Module = [PoshManifest]::Parse($ManifestPath)
    }
    END {
        #region Function closing DO NOT REMOVE
        $TimeSpent = New-TimeSpan -Start $FunctionEnterTime -Verbose:$False -ErrorAction SilentlyContinue
        [String] ${TimeSpentString} = ''
        Switch ($TimeSpent) {
            {$_.TotalDays -gt 1} {$TimeSpentString = "$($_.TotalDays) D.";BREAK}
            {$_.TotalHours -gt 1} {$TimeSpentString = "$($_.TotalHours) h.";BREAK}
            {$_.TotalMinutes -gt 1} {$TimeSpentString = "$($_.TotalMinutes) min.";BREAK}
            {$_.TotalSeconds -gt 1} {$TimeSpentString = "$($_.TotalSeconds) s.";BREAK}
            {$_.TotalMilliseconds -gt 1} {$TimeSpentString = "$($_.TotalMilliseconds) ms.";BREAK}
            Default {$TimeSpentString = "$($_.Ticks) Ticks";BREAK}
        }
        Write-Verbose "Ending : $($FunctionName) - TimeSpent : $($TimeSpentString)"
        #endregion Function closing DO NOT REMOVE
        Return $Module
    }

}
Function New-PoshFunction {
    [CMDLetBinding()]
    Param(
        [Parameter(
            Position = 0,
            Mandatory = $True
        )]
        [Alias('FunctionName')]
        [String] ${Name},
        [Parameter(
            Position = 1,
            Mandatory = $False
        )]
        [String] ${Author} = "$($Env:UserName.substring(0,1).toupper())$($Env:UserName.substring(1))",
        [Parameter(
            Position = 2,
            Mandatory = $False
        )]
        [Switch] ${NoHelp},
        [Parameter(
            Position = 3,
            Mandatory = $False
        )]
        [Switch] ${Minimal}
    )
    <#
        .SYNOPSIS
            New-PoshFunction Synopsis of the function

        .DESCRIPTION
            New-PoshFunction a short description of what the function do

        .PARAMETER ParameterName
            Type      : the type of the parameter
            Position  : the position of the parameter
            Mandatory : if the parameter is mandatory

            a short description of the parameter

        .INPUTS
            type of the input

        .OUTPUTS
            type of the output

        .EXAMPLE
            PS> New-PoshFunction

            Short Description of what will be done if the command is ran

        .EXAMPLE
            PS> New-PoshFunction -ParameterName

            Short Description of what will be done if the command is ran with ParameterName

        .LINK
            a lookalike ps function

        .NOTES
            Written by GirardetY
    #>
    BEGIN {
        #region Function initialisation DO NOT REMOVE
        [String] ${FunctionName} = $MyInvocation.MyCommand
        [DateTime] ${FunctionEnterTime} = [DateTime]::Now
        Write-Verbose "Entering : $($FunctionName)"
        #endregion Function initialisation DO NOT REMOVE
    }
    PROCESS {
        #region Function Processing DO NOT REMOVE
        Write-Verbose "Processing : $($FunctionName)"
        #region Function Processing DO NOT REMOVE
        $FunctionContent = New-PMHFunctionContent -Name $Name -Author $Author -Strict:$False -NoHelp:$NoHelp -Minimal:$Minimal
    }
    END {
        #region Function closing  DO NOT REMOVE
        $TimeSpentinFunc = New-TimeSpan -Start $FunctionEnterTime -Verbose:$False -ErrorAction SilentlyContinue
        [String] ${TimeSpentString} = ''
        Switch ($TimeSpentinFunc) {
            {$_.TotalDays -gt 1} {$TimeSpentString = "$($_.TotalDays) D.";BREAK}
            {$_.TotalHours -gt 1} {$TimeSpentString = "$($_.TotalHours) h.";BREAK}
            {$_.TotalMinutes -gt 1} {$TimeSpentString = "$($_.TotalMinutes) min.";BREAK}
            {$_.TotalSeconds -gt 1} {$TimeSpentString = "$($_.TotalSeconds) s.";BREAK}
            {$_.TotalMilliseconds -gt 1} {$TimeSpentString = "$($_.TotalMilliseconds) ms.";BREAK}
            Default {$TimeSpentString = "$($_.Ticks) Ticks";BREAK}
        }
        Write-Verbose "Ending : $($FunctionName) - TimeSpent : $($TimeSpentString)"
        #endregion Function closing  DO NOT REMOVE
        #region outputing
        Return $FunctionContent
        #endregion outputing
    }
}
Function Get-PoshFunction {
    [CMDLetBinding()]
    Param(
        [Parameter(
            Position = 0,
            Mandatory = $True
        )]
        [String] ${FunctionText}
    )
    BEGIN {
        #region Function initialisation DO NOT REMOVE
        [DateTime] ${FunctionEnterTime} = [DateTime]::Now ; Write-Verbose "Entering : $($MyInvocation.MyCommand)"
        #endregion Function initialisation DO NOT REMOVE
    }
    PROCESS {
        #region Function Processing DO NOT REMOVE
        Write-Verbose "Processing : $($MyInvocation.MyCommand)"
        #endregion Function Processing DO NOT REMOVE
        $RetVal = [PoshFunction]::Parse($FunctionText)
    }
    END {
        $TimeSpentinFunc = New-TimeSpan -Start $FunctionEnterTime -Verbose:$False -ErrorAction SilentlyContinue;$TimeUnits = @{Days = "$($_.TotalDays) D.";Hours = "$($_.TotalHours) h.";Minutes = "$($_.TotalMinutes) min.";Seconds = "$($_.TotalSeconds) s.";Milliseconds = "$($_.TotalMilliseconds) ms."}
        ForEach ($Unit in $TimeUnits.GetEnumerator()) {if ($TimeSpentinFunc.($Unit.Key) -gt 1) {$TimeSpentString = $Unit.Value;break}};if (-not $TimeSpentString) {$TimeSpentString = "$($TimeSpentinFunc.Ticks) Ticks"}
        Write-Verbose "Ending : $($MyInvocation.MyCommand) - TimeSpent : $($TimeSpentString)"
        #endregion Function closing DO NOT REMOVE
        #region outputing
        Return $RetVal
        #endregion outputing
    }
}
#endregion public Functions Declarations (DO NOT REMOVE)
