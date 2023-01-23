Class PMHNamedArgument {
    [String] ${Name}
    [Object] ${Value}
    [Boolean] ${ExpressionOmitted}
    PMHNamedArgument() {}
    Static [PMHNamedArgument] FromAst($AST){
        $Object = [PMHNamedArgument]::New()
        $Object.Name = $AST.ArgumentName
        $Object.ExpressionOmitted = $AST.ExpressionOmitted
        if ($AST.ExpressionOmitted -eq $True) {
            $Object.Value = $True
        }Else{
            $Object.Value = $AST.Argument
        }
        Return $Object
    }
    [String] ToString() {
        $RetVal = ''
        if ($This.ExpressionOmitted -eq $True) {
            $RetVal = "$($This.Name)"
        }Else{
            Switch ($This.Value.StaticType.Name) {
                {$_ -eq 'String'} {
                    if ($This.Value.StringConstantType -eq 'SingleQuoted') {
                        $RetVal = "$($This.Name) = '$($This.Value.Value)'"
                    }Else{
                        $RetVal = "$($This.Name) = `"$($This.Value.Value)`""
                    }
                    BREAK
                }
                {($_ -eq 'Int32') -or ($_ -eq 'UInt32') -or ($_ -eq 'Int64')} {
                    $RetVal = "$($This.Name) = $($This.Value.Value)"
                    BREAK
                }
                {$_ -eq 'Array'}  {
                    $ValueContent = @()
                    ForEach ($Valuestr in $This.Value.Value) {
                        if ($ValueStr -is [String]) {
                            if ($ValueStr -like '*"*') {
                                $ValueContent += "'$($ValueStr)'"
                            }Else{
                                $ValueContent += "`"$($ValueStr)`""
                            }
                        }Elseif ($ValueStr -is [Int32]) {
                            $ValueContent += "$($ValueStr)"
                        }
                    }
                    $ValueContentStr = $ValueContent -join ','
                    $RetVal = "$($This.Name) = @($($ValueContentStr))"
                    BREAK
                }
                {$_ -eq 'Boolean'} {
                    $RetVal = "$($This.Name) = `$$($This.Value.Value.ToString())"
                    BREAK
                }
                Default {
                    $RetVal = "$($This.Name) = $($This.Value.ToString())"
                    BREAK
                }
            }
        }
        Return $RetVal
    }
}
Class PMHAttribute {
    [String] ${Name}
    [PMHNamedArgument[]] ${Arguments}
    PMHAttribute() {}
    Static [PMHAttribute] FromAST($AST) {
        $Object = [PMHAttribute]::New()
        $Object.Name = $AST.TypeName
        $Object.Arguments = $AST.NamedArguments | ForEach-Object {[PMHNamedArgument]::FromAST($_)}
        Return $Object
    }
    [String] ToString() {
        $RetVal = ''
        if ($This.Arguments.count -eq 1){
            $NamedArgumentString = ($This.Arguments[0].ToString())
            $RetVal = "[$($This.Name)($($NamedArgumentString))]"
        }Elseif ($This.Arguments.count -gt 1){
            $Array = @("[$($This.Name)(")
            $ArrayArg = @()
            ForEach ($Argument in $This.Arguments) {
                $ArrayArg += "`t$($Argument.ToString())"
            }
            $ArrayStr = $ArrayArg -join ",`r`n"
            $Array += $ArrayStr
            $Array += ")]"
            $RetVal = $Array -join "`r`n"
        }Else{
            $RetVal = "[$($This.Name)()]"
        }
        Return $RetVal
    }
}
Class PMHParamParameter {
    [PMHNamedArgument[]] ${Arguments}
    PMHParamParameter() {}
    Static [PMHParamParameter] FromAST($AST) {
        $Object = [PMHParamParameter]::New()
        if ($AST -is [System.Management.Automation.Language.AttributeAst]){
            $Object.Arguments = $AST.NamedArguments | ForEach-Object {[PMHNamedArgument]::FromAST($_)}
        }
        Return $Object
    }
    [String] ToString() {
        $RetVal = ''
        if ($This.Arguments.Count -eq 1) {
            $RetVal = "[Parameter($($This.Arguments[0].ToString()))]"
        }ElseIf($This.Arguments.count -gt 1) {
            $Array = @("[Parameter(")
            $ArgumentArray = @()
            ForEach ($Argument in $This.Arguments) {
                $ArgumentArray += "`t$($ARgument.ToString())"
            }
            $ArgumentStr = $ArgumentArray -join ",`r`n"
            $Array += $ArgumentStr
            $Array += ")]"
            $RetVal = $Array -join "`r`n"
        }
        Return $RetVal
    }
}
Class PMHParamAttribute {
    [String] ${Name}
    [Object[]] ${PositionalArguments}
    [PMHNamedArgument[]] ${NamedArguments}
    [Boolean] ${IsTypeContraint}
    PMHParamAttribute() {}
    Static [PMHParamAttribute] FromAST($AST) {
        $Object = [PMHParamAttribute]::New()
        $Object.Name = $AST.TypeName.Name
        if ($AST -is [System.Management.Automation.Language.AttributeAst]) {
            ForEach ($Argument in $AST.PositionalArguments) {
                $Object.PositionalArguments += $Argument
            }
            $Object.NamedArguments = $AST.NamedArguments | ForEach-Object {[PMHNamedArgument]::FromAST($_)}
        }Elseif ($AST -is [System.Management.Automation.Language.TypeConstraintAst]){
            $Object.IsTypeContraint = $True
        }
        Return $Object
    }
    [String] ToString() {
        $RetVal = ''
        if ($This.IsTypeContraint -eq $False) {
            if (($This.PositionalArguments.Count -eq 0) -and ($This.NamedArguments.Count -eq 0)) {
                $RetVal = "[$($This.Name)()]"
            }
            if ($This.PositionalArguments.Count -gt 0) {
                $ValueStr = ($This.PositionalArguments | Select-Object -ExpandProperty 'Value') -Join ','
                $RetVal = "[$($This.Name)($($ValueStr))]"
            }
            if ($This.NamedArguments.Count -gt 0) {
                Write-Warning 'NamedArguments not handled ! in [PMHParamAttribute]'
            }

        }Else{
            $RetVal = "[$($This.Name)]"
        }
        Return $RetVal
    }
}
Class PMHParameter {
    [String] ${Name}
    [String] ${TypeName}
    [Object] ${DefaultValue}
    [PMHParamParameter[]] ${Parameters}
    [PMHParamAttribute[]] ${Attributes}
    PMHParameter() {}
    Static [PMHParameter] FromAST($AST) {
        $Object = [PMHParameter]::New()
        $Object.Name = $Ast.Name.VariablePath
        $Object.TypeName = $Ast.StaticType.Name
        $Object.DefaultValue = $Ast.DefaultValue
        $Object.Parameters = $AST.Attributes | Where-Object {$_.TypeName.Name -eq 'Parameter'} | ForEach-Object {[PMHParamParameter]::FromAST($_)}
        $Object.Attributes = $AST.Attributes | Where-Object {$_.TypeName.Name -ne 'Parameter'} | ForEach-Object {[PMHParamAttribute]::FromAST($_)}
        Return $Object
    }
    [String] ToString() {
        $RetVal = ''
        $ParamArray = @()
        $NotTypedAttributes = @($This.Attributes | Where-Object {$_.IsTypeContraint -eq $False})
        $TypedAttributes = @($This.Attributes | Where-Object {$_.IsTypeContraint -eq $True})
        if ($This.Parameters.count -gt 0) {
            $ParamArray += $This.Parameters | ForEach-Object {$_.ToString()}
        }
        if ($NotTypedAttributes.count -gt 0){
            $ParamArray += $NotTypedAttributes | ForEach-Object {$_.ToString()}
        }
        if ($TypedAttributes.Count -gt 0) {
            $TypeArray = $TypedAttributes | ForEach-Object {"[$($_.Name)]"}
            $ParamArray += "$($TypeArray -join ' ') `${$($This.Name)}"
        }Else{
            $ParamArray += "`${$($This.Name)}"
        }
        $RetVal = "$($ParamArray -join "`r`n")"
        Return $RetVal
    }
}
Class PMHDynamicParamBlock {
    PMHDynamicParamBlock() {}
    Static [PMHDynamicParamBlock] FromAST($AST) {
        $Object = [PMHDynamicParamBlock]::New()
        Write-Warning 'PMHDynamicParamBlock is not handled yet'
        Return $Object
    }
}
Class PMHParamBlock {
    [PMHAttribute[]] ${Attributes}
    [PMHParameter[]] ${Parameters}
    PMHParamBlock() {}
    Static [PMHParamBlock] FromAST($AST) {
        $Object = [PMHParamBlock]::New()
        $Object.Attributes = $AST.Attributes | ForEach-Object {[PMHAttribute]::FromAST($_)}
        $Object.Parameters = $AST.Parameters | ForEach-Object {[PMHParameter]::FromAST($_)}
        Return $Object
    }
    [String] ToString() {
        Return $This.ToString('')
    }
    [String] ToString($String) {
        $Lines = @()
        ForEach($Attribute in $This.Attributes) {
            $AttributeArray = $Attribute.ToString() -split "`r`n"
            ForEach ($AttributeLine in $AttributeArray) {
                $Lines += "$($String)$($AttributeLine)"
            }
        }
        if ($This.Parameters.count -eq 0) {
            $Lines += "$($String)Param()"
        }Else{
            $Lines += "$($String)Param("
            $ParamStrings = @()
            ForEach($Parameter in $This.Parameters) {
                $ParamArray = $Parameter.ToString() -split "`r`n"
                $ParamArray2 = @()
                ForEach($Param in $ParamArray) {
                    $ParamArray2 += "$($String)`t$($Param)"
                }
                $ParamStr = $ParamArray2 -join "`r`n"
                $ParamStrings += $ParamStr
            }
            $ParamLine = $ParamStrings -join ",`r`n"
            $Lines += $ParamLine
            $Lines += "$($String))"
        }
        $RetVal = $Lines -join "`r`n"
        Return $RetVal
    }
}
Class PMHNamedBlock {
    [String] ${BlockKind}
    [String] ${Content}
    PMHNamedBlock(){}
    Static [PMHNamedBlock] FromAST($AST) {
        $Object = [PMHNamedBlock]::New()
        $Object.BlockKind = $AST.BlockKind
        $Object.Content = $AST.Extent.Text
        Return $Object
    }
    [String] ToString() {
        Return $This.ToString('')
    }
    [String] ToString($String) {
        $Lines = $This.Content -split "`n"
        $NewLines = @("$($String)$($Lines[0])")
        $NextLines = $Lines[1..$($Lines.count -2)]
        ForEach ($Line in $NextLines) {
            if ($Line.StartsWith("        ")) {
                #The Line is an allready Tabbed Line
                $NewLines += "$($String)$($Line)"
            }Else{
                #The line is not tabbed (probably a here string line)
                $NewLines += "$($Line)"
            }
        }
        $NewLines += "$($String)$($Lines[$Lines.Count - 1].Trim())"
        $RetVal = $NewLines -join "`r`n"
        Return $RetVal
    }
}
Class PMHInLineHelpBlock {
    PMHInLineHelpBlock() {}
    Static [PMHInLineHelpBlock] FromAST($AST) {
        $Object = [PMHInLineHelpBlock]::New()
        Return $Object
    }
}
Class PMHFunction {
    [String] ${Name}
    [PMHParamBlock] ${ParamBlock}
    [PMHDynamicParamBlock] ${DynamicParamBlock}
    [PMHInLineHelpBlock] ${HelpBlock}
    [PMHNamedBlock] ${BeginBlock}
    [PMHNamedBlock] ${ProcessBlock}
    [PMHNamedBlock] ${EndBlock}
    PMHFunction() {}
    Static [PMHFunction] FromAST($AST) {
        $Object = [PMHFunction]::new()
        $Object.Name = $AST.Name
        $Object.ParamBlock = [PMHParamBlock]::FromAST($AST.Body.ParamBlock)
        $Object.DynamicParamBlock = [PMHDynamicParamBlock]::FromAST($AST.Body.DynamicParamBlock)
        $Object.BeginBlock = [PMHNamedBlock]::FromAST($AST.Body.BeginBlock)
        $Object.ProcessBlock = [PMHNamedBlock]::FromAST($AST.Body.ProcessBlock)
        $Object.EndBlock = [PMHNamedBlock]::FromAST($AST.Body.EndBlock)
        Return $Object
    }
    [String] ToString() {
        $RetVal = @"
Function $($This.Name) {
$($This.ParamBlock.ToString("`t"))
$($This.BeginBlock.ToString("`t"))
$($This.ProcessBlock.ToString("`t"))
$($This.EndBlock.ToString("`t"))
}
"@
        Return $RetVal
    }
}
Class PMHEnum {
    PMHEnum() {}
    Static [PMHEnum] FromAST($AST) {
        $Object = [PMHEnum]::new()
        Return $Object
    }
}
Class PMHClass {
    PMHClass() {}
    Static [PMHClass] FromAST($AST) {
        $Object = [PMHClass]::new()
        Return $Object
    }
}
Class PMHInterface {
    PMHInterface() {}
    Static [PMHInterface] FromAST($AST) {
        $Object = [PMHInterface]::new()
        Return $Object
    }
}


Function ConvertTo-PoshObject {
    [CMDLetBinding(DefaultParameterSetName = 'FromPath')]
    Param(
        [Parameter(
            Position = 0,
            Mandatory = $True,
            ParameterSetName = 'FromText'
        )]
        [String] ${Content},
        [Parameter(
            Position = 0,
            Mandatory = $True,
            ParameterSetName = 'FromPath'
        )]
        [String] ${Path}
    )
    BEGIN {
        #region Function initialisation DO NOT REMOVE
        [DateTime] ${FunctionEnterTime} = [DateTime]::Now ; Write-Verbose "Entering : $($MyInvocation.MyCommand)"
        #endregion Function initialisation DO NOT REMOVE
        $Tokens = [ref] $null
        $ParseErrors = [ref] $Null
        if ($PsCmdlet.ParameterSetName -eq 'FromPath') {
            $Content = Get-Content -Path $Path -Raw
        }
        Try {
            $ScriptBlockAst = [System.Management.Automation.Language.Parser]::ParseInput($Content,$Tokens,$ParseErrors)
        }Catch {
            $ErrorMessage = @"

Message : $($_.Exception.Message)
Line : $($_.InvocationInfo.ScriptLineNumber)
"@
            Write-Error -Message $ErrorMessage
            BREAK
        }

        $AllUnFilteredTypeDefinitionAST = @(($ScriptBlockAST.FindAll({$Args[0].GetType().Name -eq 'TypeDefinitionAst'}, $true)))
        $AllUnFilteredFunctionDefinitionAST = @(($ScriptBlockAST.FindAll({$Args[0].GetType().Name -eq 'FunctionDefinitionAst'}, $true)) | Where-Object {($_.Extent.Text.StartsWith('Function'))}) # -and ($_.Parent.Extent.Text -eq $Content)})

        #Search the higher parent to filter what is in first level
        Try {
            $FunctionsParentHigherLine = $AllUnFilteredFunctionDefinitionAST.Parent.Extent.StartLineNumber | Sort-Object | Select-Object -First 1
            $AllFunctionDefinitionAST = @($AllUnFilteredFunctionDefinitionAST | Where-Object {$_.Parent.Extent.StartLineNumber -eq $FunctionsParentHigherLine})
        }Catch {
            $AllFunctionDefinitionAST = @()
        }

        #Search the higher parent to filter what is in first level
        Try {
            $TypeDefinitionsParentHigherLine = $AllUnFilteredTypeDefinitionAST.Parent.Extent.StartLineNumber | Sort-Object | Select-Object -First 1
            $AllTypeDefinitionAST = @($AllUnFilteredTypeDefinitionAST | Where-Object {$_.Parent.Extent.StartLineNumber -eq $TypeDefinitionsParentHigherLine})
        }Catch {
            $AllTypeDefinitionAST = @()
        }

        $AllEnumTypeDefinitions = @($AllTypeDefinitionAST | Where-Object {$_.IsEnum})
        $AllClassTypeDefinitions = @($AllTypeDefinitionAST | Where-Object {$_.IsClass})
        $AllInterfaceDefinitions = @($AllTypeDefinitionAST | Where-Object {$_.IsInterface})

        Write-Verbose "Found [$($AllFunctionDefinitionAST.count)] Functions"
        Write-Verbose "Found [$($AllEnumTypeDefinitions.count)] Enums"
        Write-Verbose "Found [$($AllClassTypeDefinitions.count)] Classes"
        Write-Verbose "Found [$($AllInterfaceDefinitions.count)] Interfaces"
    }
    PROCESS {
        #region Function Processing DO NOT REMOVE
        Write-Verbose "Processing : $($MyInvocation.MyCommand)"
        #endregion Function Processing DO NOT REMOVE
        [System.Collections.ArrayList] $Functions = [System.Collections.ArrayList]@()
        [System.Collections.ArrayList] $Enums = [System.Collections.ArrayList]@()
        [System.Collections.ArrayList] $Classes = [System.Collections.ArrayList]@()
        [System.Collections.ArrayList] $Interfaces = [System.Collections.ArrayList]@()

        if ($AllFunctionDefinitionAST.count -gt 0){
            Write-Verbose "Creating function objects..."
            ForEach ($AST in $AllFunctionDefinitionAST) {
                Write-Verbose "`t Creating Object for: $($AST.Name)"
                $Null = $Functions.Add([PMHFunction]::FromAST($AST))
            }
        }
        if ($AllEnumTypeDefinitions.count -gt 0){
            Write-Verbose "Creating enum objects..."
            ForEach ($AST in $AllEnumTypeDefinitions) {
                Write-Verbose "`t Creating Object for: $($AST.Name)"
                $Null = $Enums.Add([PMHEnum]::FromAST($AST))
            }
        }
        if ($AllClassTypeDefinitions.count -gt 0){
            Write-Verbose "Creating Class objects..."
            ForEach ($AST in $AllClassTypeDefinitions) {
                Write-Verbose "`t Creating Object for: $($AST.Name)"
                $Null = $Classes.Add([PMHClass]::FromAST($AST))
            }
        }
        if ($AllInterfaceDefinitions.count -gt 0){
            Write-Verbose "Creating Interface objects..."
            ForEach ($AST in $AllInterfaceDefinitions) {
                Write-Verbose "`t Creating Object for: $($AST.Name)"
                $Null = $Interfaces.Add([PMHInterface]::FromAST($AST))
            }
        }

        $HashObject = [ORDERED] @{
            Functions = $Functions
            Enums = $Enums
            Classes = $Classes
            Interfaces = $Interfaces
        }
        $RetObject = New-Object -TypeName 'PsObject' -Property $HashObject
    }
    END {
        $TimeSpentinFunc = New-TimeSpan -Start $FunctionEnterTime -Verbose:$False -ErrorAction SilentlyContinue;$TimeUnits = [ORDERED] @{TotalDays = "$($TimeSpentinFunc.TotalDays) D.";TotalHours = "$($TimeSpentinFunc.TotalHours) h.";TotalMinutes = "$($TimeSpentinFunc.TotalMinutes) min.";TotalSeconds = "$($TimeSpentinFunc.TotalSeconds) s.";TotalMilliseconds = "$($TimeSpentinFunc.TotalMilliseconds) ms."}
        ForEach ($Unit in $TimeUnits.GetEnumerator()) {if ($TimeSpentinFunc.($Unit.Key) -gt 1) {$TimeSpentString = $Unit.Value;break}};if (-not $TimeSpentString) {$TimeSpentString = "$($TimeSpentinFunc.Ticks) Ticks"}
        Write-Verbose "Ending : $($MyInvocation.MyCommand) - TimeSpent : $($TimeSpentString)"
        #endregion Function closing DO NOT REMOVE
        #region outputing
        Return $RetObject
        #endregion outputing
    }
}
