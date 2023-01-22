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
        if ($This.ExpressionOmitted) {
            $RetVal = "$($This.Name)"
        }Else{
            if ($This.Argument.StaticType.Name -eq 'String'){
                if ($This.Argument.StringConstantType -eq 'SingleQuoted') {
                    $RetVal = "$($This.Name) = '$($This.Argument.Value)'"
                }Else{
                    $RetVal = "$($This.Name) = `"$($This.Argument.Value)`""
                }
            }Elseif ($This.Argument.StaticType.Name -eq 'Boolean'){
                $RetVal = "$($This.Name) = `$$($This.Argument.Value.ToString())"
            }Elseif ($This.Argument.StaticType.Name -eq 'Array'){
                $ValueContent = @()
                ForEach ($Valuestr in $This.Argument.Value) {
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
        $Object.Arguments = $AST.NamedArguments | ForEach-OBject {[PMHNamedArgument]::FromAST($_)}
        Return $Object
    }
    [String] ToString() {
        $NamedArgumentString = $This.Arguments.ToString() -join ", "
        $RetVal = "[$($This.Name)($($NamedArgumentString))]"
        Return $RetVal
    }
}
Class PMHParamParameter {
    PMHParamParameter() {}
    Static [PMHParamParameter] FromAST($AST) {
        $Object = [PMHParamParameter]::New()
        Return $Object
    }
}
Class PMHParamAttribute {
    PMHParamAttribute() {}
    Static [PMHParamAttribute] FromAST($AST) {
        $Object = [PMHParamAttribute]::New()
        Return $Object
    }
}
Class PMHParameter {
    [String] ${Name}
    [String] ${TypeName}
    [Object] ${DefaultValue}
    [PMHAttribute] ${Parameter}
    [PMHAttribute[]] ${Attributes}
    PMHParameter() {}
    Static [PMHParameter] FromAST($AST) {
        $Object = [PMHParameter]::New()
        $Object.Name = $Ast.Name
        $Object.TypeName = $Ast.StaticType.Name
        $Object.DefaultValue = $Ast.DefaultValue
        $Object.Parameter = $AST.Parameter.Attributes | Where-Object {$_.TypeName.Name -eq 'Parameter'} | ForEach-Object {[PMHAttribute]::FromAST($_)}
        $Object.Attributes = $AST.Parameter.Attributes | Where-Object {$_.TypeName.Name -ne 'Parameter'} | ForEach-Object {[PMHAttribute]::FromAST($_)}
        Return $Object
    }
}
Class PMHDynamicParamBlock {
    PMHDynamicParamBlock() {}
    Static [PMHDynamicParamBlock] FromAST($AST) {
        $Object = [PMHDynamicParamBlock]::New()
        Return $Object
    }
}
Class PMHParamBlock {
    [PMHAttribute[]] ${Attributes}
    [PMHParameter[]] ${Parameters}
    PMHParamBlock() {}
    Static [PMHParamBlock] FromAST($AST) {
        $Object = [PMHParamBlock]::New()
        $Object.Attributes = $Ast | ForEach-Object {[PMHAttribute]::FromAST($_)}
        $Object.Parameters = $Ast | ForEach-Object {[PMHParameter]::FromAST($_)}
        Return $Object
    }
}
Class PMHFunction {
    [String] ${Name}
    [PMHParamBlock] ${ParamBlock}
    [PMHDynamicParamBlock] ${DynamicParamBlock}
    ${StartBlock}
    ${ProcessBlock}
    ${EndBlock}
    PMHFunction() {}
    Static [PMHFunction] FromAST($AST) {
        $Object = [PMHFunction]::new()
        $Object.Name = $AST.Name
        $Object.ParamBlock = [PMHParamBlock]::FromAST($AST.ParamBlock)
        Return $Object
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
