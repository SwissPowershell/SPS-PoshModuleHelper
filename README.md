# SPS-PoshModuleHelper
 Module to help creating modules
 * New-PoshModule
 * Update-PoshModule

 ## New-PoshModule
  An helper to create powershell module
  
    * Create the module skeleton

    ├── *ModuleName*            # Name of the module
      ├── *Version*             # Version of the module
        ├── Debug.ps1           # A debug file usefull to test the module
        ├── *ModuleName*.psd1   # A module definition file
        ├── *ModuleName*.psm1   # A module file
          ├── Public            # Folder hosting *public* functions
            ├── _Example.ps1    # Example ps1 to help you build your own
          ├── Private           # Folder hosting *private* functions
            ├── _Example.ps1    # Example ps1 to help you build your own
          ├── Enum              # Folder hosting *enum* functions
            ├── _Example.ps1    # Example ps1 to help you build your own
          ├── Class             # Folder hosting *class* functions
            ├── _Example.ps1    # Example ps1 to help you build your own

    * Add given Public functions under \\Public\\*FunctionName*.ps1 and register them
    * Add given Private functions under \\Private\\*FunctionName*.ps1
    * Add given Enum under \\Enum\\*EnumName*.ps1
    * Add given Class under \\Class\\*ClassName*.ps1

### Examples
  `PS> New-Poshmodule -Name 'MyNewPoshModule'`
  * Create a powershell module under user module directory 
    * **Windows Powershell** : C:\\Users\\*USER*\\Documents\\WindowsPowerShell\\Modules\\
    * **Powershell Core** : C:\\Users\\*USER*\\Documents\\PowerShell\\Modules\\

### Examples
  `PS> New-Poshmodule -Name 'MyNewPoshModule' -Global`
  * Create a powershell module under Global module directory 
    * **Windows Powershell** : C:\\Program Files\\WindowsPowerShell\\Modules\\
    * **Powershell Core** : C:\\Program Files\\PowerShell\\7\\Modules\\
    
### Parameters

  * **-Name** \<String\>
    * **Mandatory** : True
    * **Type** : String
    * **DefaultValue** :

    Will define the module Name
      * Create the directory structure for module \\*Name*\\
      * Write decription file (*Name*.psd1)
      * Write module file (*Name*.psm1)
      * Create a subfolder in the module directory to host the files

  * **-Version** \<Version\>
    * **Mandatory** : False
    * **Type** : Version
    * **DefaultValue** : 1.0.0.0

    Will define the module version
      * Write the version in the decription file (.psd1)
      * Create a subfolder in the module directory to host the files

  * **-Description** \<String\>
    * **Mandatory** : False
    * **Type** : String
    * **DefaultValue** :

    Will define module description
    * Write the module description in the decription file (.psd1)
  
  * **-Guid** \<Guid\>
    * **Mandatory** : False
    * **Type** : Guid
    * **DefaultValue** : `[GUID]::newguid()`

    Will define the module guid
      * Write the guid in the decription file (.psd1)

  * **-Author** \<String\>
    * **Mandatory** : False
    * **Type** : String
    * **DefaultValue** : `"$($Env:Username)"`

    Will define the module Author
      * Write the author in the decription file (.psd1)
      * Write the author in all the functions files (.ps1)

  * **-CompanyName** \<String\>
    * **Mandatory** : False
    * **Type** : String
    * **DefaultValue** : `"$($Author)'s Company"`

    Will define the module Author
      * Write the author in the decription file (.psd1)
      * Write the author in all the functions files (.ps1)

  * **-Copyright** \<String\>
    * **Mandatory** : False
    * **Type** : String
    * **DefaultValue** : `"(c) $([DateTime]::Now | Select-Object -ExpandProperty Year) $($CompanyName). All rights reserved."`

    Will define the module Copyright
      * Write the Copyright in the decription file (.psd1)

  * **-Functions** \<String[]\>
    * **Mandatory** : False
    * **Type** : Array of String
    * **DefaultValue** : `@()`

    Will add Functions in the module
      * Add each function as exposed in the description file (.psd1)
      * Create script file (.ps1) for each function *\<string\>* under \\public\\ folder
         * Script file contains a function named after the given *\<string\>*
         * Script file add the Add-ModuleMember 'FunctionName'

  * **-PrivateFunctions** \<String[]\>
    * **Mandatory** : False
    * **Type** : Array of String
    * **DefaultValue** : `@()`

    Will add Functions in the module
      * Create script file (.ps1) for each function *\<string\>* under \\private\\ folder
         * Script file contains a function named after the given *\<string\>*

  * **-Enums** \<String[]\>
    * **Mandatory** : False
    * **Type** : Array of String
    * **DefaultValue** : `@()`

    Will add Enums in the module
      * Create script file (.ps1) for each Enum *\<string\>* under \\Enum\\ folder
         * Script file contains a enum named after the given Enum *\<string\>*

  * **-Classes** \<String[]\>
    * **Mandatory** : False
    * **Type** : Array of String
    * **DefaultValue** : `@()`

    Will add Classes in the module
      * Create script file (.ps1) for each Class *\<string\>* under \\Class\\ folder
         * Script file contains a Class named after the given Class *\<string\>*

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

    Will create minimal function file (.ps1) under \\public\\ and \\private\\ folders
      * No Function *Help*
      * No *Begin*,*Process*,*End* scriptblocks
      * No verbose helper inside the function

  * \<CommonParameters\>
    * Handle all the Common Parameters like **-ErrorAction**, **-Verbose**, **-Debug** etc...


## Update-PoshModule
  An helper to update powershell module

    * Duplicate the module and upgrade the version
    * Add given Public functions under \\Public\\*FunctionName*.ps1 and register them
    * Add given Private functions under \\Private\\*FunctionName*.ps1
    * Add given Enum under \\Enum\\*EnumName*.ps1
    * Add given Class under \\Class\\*ClassName*.ps1

### Examples

  `PS> Update-Poshmodule -Name 'MyNewPoshModule'`

  * Update the MyNewPoshModule version (New Revision) under User directory
    * Copy last version of *MyNewPoshModule to \\MyNewPoshModule\\*Version*\\
      * **Windows Powershell** : C:\\Users\\*USER*\\Documents\\WindowsPowerShell\\Modules\\MyNewPoshModule\\*Version*\\
      * **Powershell Core** : C:\\Users\\*USER*\\Documents\\PowerShell\\Modules\\MyNewPoshModule\\*Version*\\
    * Update version in the module definition file (.psd1)

### Examples

  `PS> Update-Poshmodule -Name 'MyNewPoshModule' -Global`

  * Update the MyNewPoshModule version (New Revision) under Global module directory 
    * **Windows Powershell** : C:\\Program Files\\WindowsPowerShell\\Modules\\
    * **Powershell Core** : C:\\Program Files\\PowerShell\\7\\Modules\\

### Parameters

  * **-Name** \<String\>
    * **Mandatory** : True
    * **Type** : String
    * **DefaultValue** :

    Will define the module to copy and update

  * **-Version** \<Version\>
    * **Mandatory** : True (ByVersion), False (other parameter set)
    * **Type** : Version
    * **ParameterSetName** : ByVersion
    * **DefaultValue** :

    Will define the new module version 
      * Write the version in the updated decription file (.psd1)

  * **-Major**
    * **Mandatory** : True (ByType), False (other parameter set)
    * **Type** : Switch
    * **ParameterSetName** : ByType
    * **DefaultValue** : `$False`

    Will upgrade module by 1 Major version

  * **-Minor**
    * **Mandatory** : True (ByType), False (other parameter set)
    * **Type** : Switch
    * **ParameterSetName** : ByType
    * **DefaultValue** : `$False`

    Will upgrade module by 1 Minor version

  * **-Build**
    * **Mandatory** : True (ByType), False (other parameter set)
    * **Type** : Switch
    * **ParameterSetName** : ByType
    * **DefaultValue** : `$False`

    Will upgrade module by 1 Build version
  
  * **-Revision**
    * **Mandatory** : True (ByType), False (other parameter set)
    * **Type** : Switch
    * **ParameterSetName** : ByType
    * **DefaultValue** : `$False`

    Will upgrade module by 1 Revision version

  * **-AddFunctions** \<String[]\>
    * **Mandatory** : False
    * **Type** : Array of String
    * **DefaultValue** : `@()`
    Will add Functions in the module
      * Add each function as exposed in the description file (.psd1)
      * Create script file (.ps1) for each function *\<string\>* under \\public\\ folder
         * Script file contains a function named after the given *\<string\>*
         * Script file add the Add-ModuleMember 'FunctionName'

  * **-AddPrivateFunctions** \<String[]\>
    * **Mandatory** : False
    * **Type** : Array of String
    * **DefaultValue** : `@()`
    Will add Functions in the module
      * Create script file (.ps1) for each function *\<string\>* under \\private\\ folder
         * Script file contains a function named after the given *\<string\>*

  * **-AddEnums** \<String[]\>
    * **Mandatory** : False
    * **Type** : Array of String
    * **DefaultValue** : `@()`
    Will add Enums in the module
      * Create script file (.ps1) for each Enum *\<string\>* under \\Enum\\ folder
         * Script file contains a enum named after the given Enum *\<string\>*

  * **-AddClasses** \<String[]\>
    * **Mandatory** : False
    * **Type** : Array of String
    * **DefaultValue** : `@()`
    Will add Classes in the module
      * Create script file (.ps1) for each Class *\<string\>* under \\Class\\ folder
         * Script file contains a Class named after the given Class *\<string\>*
  
  * **-Keep**
    * **Mandatory** : False
    * **Type** : Switch
    * **DefaultValue** : `$False`
    Define if the previous module has to be kept or not

  * **-Global**
    * **Mandatory** : False
    * **Type** : Switch
    * **DefaultValue** : `$False`
    Will define if the module is stored in User or Machine directory
      * User Powershell Core : *C:\\Users\\**%USERNAME%**\\Documents\\PowerShell\\Modules\\*
      * User Windows Powershell : *C:\\Users\\**%USERNAME%**\\Documents\\WindowsPowerShell\\Modules\\*
      * Machine Powershell Core : *C:\\**%ProgramFiles%**\\PowerShell\\7\\Modules\\*
      * Machine Windows Powershell : *C:\\**%ProgramFiles%**\\WindowsPowerShell\\Modules\\*
  

  * **-Minimal**
    * **Mandatory** : False
    * **Type** : Switch
    * **DefaultValue** : `$False`
    Will create minimal function file (.ps1) under \\public\\ and \\private\\ folders
      * No Function *Help*
      * No *Begin*,*Process*,*End* scriptblocks
      * No verbose helper inside the function

  * \<CommonParameters\>
    * Handle all the Common Parameters like **-ErrorAction**, **-Verbose**, **-Debug** etc...



