# File automatically created by SPS-PoshModuleHelper
#region Set Verbose preference
# $VerbosePreference = 'Continue'
#endregion Set Verbose preference
#region set strict mode
Set-StrictMode -Version Latest
#endregion set strict mode
#region reset the module
# as the Reset-PoshModule is part of the current module it cannot be used
# Try {Reset-PoshModule} Catch {if ($_.Exception.Message -like 'The term * is not recognized as the name *') {Write-Warning 'Reset-PoshModule function not found... module not reloaded'}Else{Write-Warning "Be aware that the module has not been reloaded using [Reset-PoshModule]: $($_.Exception.Message)"}}
Remove-Module -Name 'SPS-PoshModuleHelper' -Force -ErrorAction 'SilentlyContinue'
Import-Module -Name 'SPS-PoshModuleHelper' -MinimumVersion '2.0.0.0' -Force -PassThru | out-null
#endregion reset the module

#region Begin
$DebugStart = Get-Date -Verbose:$False
#endregion Begin
#region Process
Write-Host "============================= DEBUG START ==============================" -Foregroundcolor Magenta

###########################################
##### Test your commands in this zone #####
###########################################

# New-PoshModule -Name 'ContosoModule' -Version '2.0.0.0' -Functions "Say-HelloWorld","Set-HelloWorld" -PrivateFunctions 'This-istheway','Get-theWay' -Classes 'world','TheWay' -Enums 'WorldEnum'
# Update-PoshModule -Name 'ContosoModule' -AddFunctions "Why-HelloWorld" -AddEnums 'WayEnum' -AddClasses 'Empire','Jedi' -AddPrivateFunctions 'Set-MyWayIsYourWay'
$Function = @'
Function Get-Something {
    [CMDLetBinding(DefaultParameterSetName = 'Default',SupportsShouldProcess)]
    Param(
        [Parameter(
            Position = 1,
            Mandatory = $True
        )]
        [AllowNull()]
        [ValidateCount(3)]
        [String] ${Name},
        [Parameter(
            Position = 1,
            Mandatory = $False
        )]
        [ValidateCount(3,10)]
        [Version] ${Version} = '1.0.0.0',
        [Parameter(
            Position = 2,
            Mandatory = $False
        )]
        [String] ${Description},
        [Parameter(
            Position = 3,
            Mandatory = $true,
            ParameterSetName = 'ByToto'
        )]
        [Parameter(
            Position = 3,
            Mandatory = $false,
            ParameterSetName = 'default'
        )]
        ${NotTypedParam}
    )
    <#
        .SYNOPSIS
            Get-PMHReadMeContent Returns the content of the readme.md file

        .DESCRIPTION
            Get-PMHReadMeContent Returns the content of the readme.md file

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
            PS> Get-PMHReadMeContent -Name 'MyModule'

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

        Function Get-AnotherInput {
            <#
        .SYNOPSIS
            Get-PMHReadMeContent Returns the content of the readme.md file

        .DESCRIPTION
            Get-PMHReadMeContent Returns the content of the readme.md file

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
            PS> Get-PMHReadMeContent -Name 'MyModule'

            Will Generate a ReadMe.md content for the module MyModule

        .LINK
            Get-Content

        .NOTES
            Written by GirardetY
    #>
            Write-Host 'Toto'
        }
    }
}
'@

$Result = Get-PoshFunction -Function $Function
$Result

Write-Host "=============================  DEBUG END  ==============================" -Foregroundcolor Magenta
#endregion Process
#region end
$DebugTimeSpent = New-TimeSpan -Start $DebugStart -Verbose:$False
Write-Host "The debug took : $($DebugTimeSpent.TotalMilliseconds)ms to execute" -foregroundColor DarkYellow
#endregion end
