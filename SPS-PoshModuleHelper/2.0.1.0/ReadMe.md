# SPS-PoshModuleHelper - 2.0.0.0
Module to help creating modules

* Reset-PoshModule [Link](#Reset-PoshModule)
* New-PoshModule [Link](#New-PoshModule)
  * To Do Create a FeatureRequest.md
* Update-PoshModule [Link](#Update-PoshModule)
  * To Do Update the Readme.md
  * To Do Create a ReleaseNotes.md
* New-PoshFunction [Link](#New-PoshFunction)


## Reset-PoshModule
An helper to reset a module (Remove-module / Import-Module)

### Examples
  `PS> Reset-PoshModule`
  * Function Description

### Parameters
  * **-Name**
  * **-Version**
  * **-Path**
  * **-Silent**
  * \<CommonParameters\>
    * Handle all the Common Parameters like **-ErrorAction**, **-Verbose**, **-Debug** etc...

## New-PoshModule
An helper to create powershell module

### Examples
  `PS> New-Poshmodule -Name 'MyNewPoshModule'`
  * Create a powershell module under user module directory
    * **Windows Powershell** : C:\\Users\\*USER*\\Documents\\WindowsPowerShell\\Modules\\MyNewPoshModule\\1.0.0.0\\
    * **Powershell Core** : C:\\Users\\*USER*\\Documents\\PowerShell\\Modules\\MyNewPoshModule\\1.0.0.0\\

### Examples
  `PS> New-Poshmodule -Name 'MyNewPoshModule' -Global`
  * Create a powershell module under Global module directory
    * **Windows Powershell** : C:\\Program Files\\WindowsPowerShell\\Modules\\MyNewPoshModule\\1.0.0.0\\
    * **Powershell Core** : C:\\Program Files\\PowerShell\\7\\Modules\\MyNewPoshModule\\1.0.0.0\\

### Parameters

  * **-Name** \<String\>
    * **Mandatory** : True
    * **Type** : String
    * **DefaultValue** :

    Will define the module Name
    * Create the directory structure for module \\*Name*\\
    * Write decription file (*Name*.psd1)
    * Write module file (*Name*.psm1)

  * **-Version** \<Version\>
    * **Mandatory** : False
    * **Type** : Version
    * **DefaultValue** : 1.0.0.0

    Will define the module version
      * Write the version in the decription file (*Name*.psd1)
      * Create a subfolder in the module directory to host the files \\*Name*\\*Version*\\

  * **-Description** \<String\>
    * **Mandatory** : False
    * **Type** : String
    * **DefaultValue** :

    Will define module description
    * Write the module description in the decription file (*Name*.psd1)

  * **-Guid** \<Guid\>
    * **Mandatory** : False
    * **Type** : Guid
    * **DefaultValue** : `[GUID]::newguid()`

    Will define the module guid
      * Write the guid in the decription file (*Name*.psd1)

  * **-Author** \<String\>
    * **Mandatory** : False
    * **Type** : String
    * **DefaultValue** : `"$($Env:Username)"`

    Will define the module Author
      * Write the author in the decription file (*Name*.psd1)
      * Write the author in all the functions within the module file (*Name*.psm1)

  * **-CompanyName** \<String\>
    * **Mandatory** : False
    * **Type** : String
    * **DefaultValue** : `"$($Author)'s Company"`

    Will define the module Author
      * Write the author in the decription file (*Name*.psd1)
      * Write the author in all the functions within the module file (*Name*.psm1)

  * **-Copyright** \<String\>
    * **Mandatory** : False
    * **Type** : String
    * **DefaultValue** : `"(c) $([DateTime]::Now | Select-Object -ExpandProperty Year) $($CompanyName). All rights reserved."`

    Will define the module Copyright
      * Write the Copyright in the decription file (*Name*.psd1)

  * **-Functions** \<String[]\>
    * **Mandatory** : False
    * **Type** : Array of String
    * **DefaultValue** : `@()`

    Will add Functions in the module
      * Add each function as exposed in the description file (*Name*.psd1)
      * Create function section for each function *\<string\>* in the module file (*Name*.psm1)
         * Function is named after the given *\<string\>*

  * **-PrivateFunctions** \<String[]\>
    * **Mandatory** : False
    * **Type** : Array of String
    * **DefaultValue** : `@()`

    Will add Functions in the module
      * Create function section for each function *\<string\>* in the module file (*Name*.psm1)
         * Function is named after the given *\<string\>*

  * **-Enums** \<String[]\>
    * **Mandatory** : False
    * **Type** : Array of String
    * **DefaultValue** : `@()`

    Will add Enums in the module
      * Create Enum section for each Enum *\<string\>* in the module file (*Name*.psm1)
         * Enum is named after the given *\<string\>*

  * **-Classes** \<String[]\>
    * **Mandatory** : False
    * **Type** : Array of String
    * **DefaultValue** : `@()`

    Will add Classes in the module
      * Create Class section for each Class *\<string\>* in the module file (*Name*.psm1)
         * Class is named after the given *\<string\>*

  * **-Global**
    * **Mandatory** : False
    * **Type** : Switch
    * **DefaultValue** : `$False`

    Will define if the module is stored in User or Machine directory
      * User Powershell Core : *C:\\Users\\**%USERNAME%**\\Documents\\PowerShell\\Modules\\*
      * User Windows Powershell : *C:\\Users\\**%USERNAME%**\\Documents\\WindowsPowerShell\\Modules\\*
      * Machine Powershell Core : *C:\\**%ProgramFiles%**\\PowerShell\\7\\Modules\\*
      * Machine Windows Powershell : *C:\\**%ProgramFiles%**\\WindowsPowerShell\\Modules\\*

  * **-VerboseDebug**
    * **Mandatory** : False
    * **Type** : Switch
    * **DefaultValue** : `$False`

    Will define the default VerbosePreference in the *Debug.ps1* file

  * **-Strict**
    * **Mandatory** : False
    * **Type** : Switch
    * **DefaultValue** : `$False`

    Will define the default StrictMode `(Set-StrictMode -Version 'Latest')` in the *Debug.ps1* file

  * **-Minimal**
    * **Mandatory** : False
    * **Type** : Switch
    * **DefaultValue** : `$False`

    Will create minimal function content in the module file (*Name*.psm1)
      * No Function *Help*
      * No *Begin*,*Process*,*End* scriptblocks
      * No verbose helper inside the function

  * \<CommonParameters\>
    * Handle all the Common Parameters like **-ErrorAction**, **-Verbose**, **-Debug** etc...

## Update-PoshModule
## New-PoshFunction
