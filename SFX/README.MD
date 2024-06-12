# SFX Folder

This folder contains resources and scripts for creating self-extracting (SFX) archives using WinRAR. 

## Contents

- **sfxoptions.txt**: Configuration file for SFX creation.
- **sfxexclude.txt**: File patterns to exclude from the SFX archive.
- **Builds/**: Directory where the generated SFX packages are stored.

## sfxoptions.txt

The `sfxoptions.txt` file specifies options for creating the SFX archive. 

### Example Contents

```plaintext
; The path to extract files to
Path=C:\Temp\APPLICATIONFOLDER

; Command to run after extraction
Setup=Deploy-Application.exe Install Silent

; Command to run after the previous setup command completes
Setup=C:\Windows\System32\cmd.exe /Q /C rmdir C:\Temp\APPLICATIONFOLDER /s /q

; Exit code that signifies successful setup
SetupCode=0

; Silent mode (do not show progress dialog)
Silent=1

; Overwrite existing files
Overwrite=1
```

#### Options Explained
Path: The directory where the files will be extracted.
Setup: Command to run after extraction. Multiple setup commands can be included.
SetupCode: Exit code that signifies successful setup.
Silent: Runs the extraction process in silent mode.
Overwrite: Overwrites existing files without prompting.

#### sfxexclude.txt
The sfxexclude.txt file contains patterns for files and directories to exclude from the SFX archive.

#### Example Contents
```plaintext
# Backup files
*.bak

# Temporary files
*.tmp

# Log files
*.log

# System files
Thumbs.db
Desktop.ini
.DS_Store

# Cache directories
.cache

# Version control directories
*.git
*.svn
*.hg

# Other
*.md 

# Custom exclusion patterns
# path\to\excluded\directory\*
# specificfiletoexclude.txt
```

#### Usage
Ensure that the paths and commands in sfxoptions.txt are correctly configured for your environment. Place any files to be included in the SFX package in the Source directory.

Run the main script to create the SFX package:

```sh
Copy code
.\Create-Package.ps1 -PackageName "MyApp" -SFXPackage $true
The generated SFX package will be stored in the Builds directory.
```

### License
This project is licensed under the MIT License - see the LICENSE file for details.