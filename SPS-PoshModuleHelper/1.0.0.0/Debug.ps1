#$VerbosePreference = 'Continue'
# Correcting verbose color
$Host.PrivateData.VerboseForegroundColor = 'Cyan'

$CurrPath = $PSScriptRoot
$ModuleVersion = Split-Path -Path $CurrPath -leaf
$ModuleName = Split-Path -Path $(Split-Path -Path $CurrPath) -leaf
Remove-Module -Name $ModuleName -Verbose:$False -ErrorAction SilentlyContinue
Import-Module -Name $ModuleName -MinimumVersion $ModuleVersion -Verbose:$False

New-PoshModule -Name 'SPS-Host' -Guid 'a39181c5-aa25-4466-9b14-cfbe4dc09ea8' -Version '2.0.0.0' -Functions @('Write-Line','Add-ChoiceItem','Write-ChoiceMenu','Read-Line') -VerboseDebug -Strict -Verbose
BREAK

New-PoshModule -Name 'NewModule' -Functions @('get-toto','New-ToTo') -PrivateFunctions 'Import-toto' -Classes 'NewClass' -Enums 'NewEnum' -VerboseDebug -Strict -Verbose
Update-PoshModule -Name 'NewModule' -AddFunctions 'get-toto2' -AddPrivateFunction 'Import-Toto2' -AddClasses 'NewClass2' -AddEnums 'NewEnum2' -Revision -Verbose
