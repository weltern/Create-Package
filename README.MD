# Deployment Package Creator

This PowerShell script automates the creation of deployment packages. Depending on the specified parameters, it can create a self-extracting (SFX) archive using WinRAR or a Win32 package for Intune.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Parameters](#parameters)
- [Examples](#examples)
- [Notes](#notes)
- [Contributing](#contributing)
- [License](#license)

## Features

- Create self-extracting (SFX) archives using WinRAR
- Create Win32 packages for Intune deployment
- Automatically download and install required tools if not found
- Detailed logging of operations

## Installation

1. **Clone the repository**:
    ```sh
    git clone https://github.com/yourusername/deployment-package-creator.git
    cd deployment-package-creator
    ```

2. **Ensure PowerShell 5.0 or later is installed**:
    - [Windows Management Framework 5.1](https://www.microsoft.com/en-us/download/details.aspx?id=54616)

3. **Required Tools**:
    - WinRAR: [Download Link](https://www.win-rar.com/start.html?&L=0)
    - Intune Win32 Content Prep Tool: [GitHub Repository](https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool)

## Usage

Run the script with the required parameters to create the desired package. Below are examples and descriptions of the parameters.

### Parameters

- **PackageName**: The name of the package to be created (mandatory).
- **PackageSource**: The source directory containing the files to be included in the package (optional, defaults to `"$PSScriptRoot\Source"`).
- **SFXPackage**: Boolean flag indicating whether to create a self-extracting (SFX) package (optional, defaults to `true`).
- **winRARPath**: The path to the WinRAR executable (optional, defaults to `"$env:ProgramFiles\WinRAR\WinRAR.exe"`).
- **destinationSFXPackagePath**: The destination directory for the created SFX package (optional, defaults to `"$PSScriptRoot\SFX\Builds"`).
- **winRARWebPath**: The URL to download WinRAR if it is not found on the system (optional, defaults to `https://www.win-rar.com/fileadmin/winrar-versions/winrar-x64-701.exe`).
- **winRARSFXPath**: The path to the SFX module for WinRAR (optional, defaults to `"$env:ProgramFiles\WinRAR\Zip.sfx"`).
- **winRarSFXOptions**: The path to the options file for the SFX package (optional, defaults to `"$PSScriptRoot\SFX\sfxoptions.txt"`).
- **icon**: The path to the icon file to be used for the SFX package (optional, defaults to `"$PSScriptRoot\Configuration\RJ-32x32.ico"`).
- **win32Package**: Boolean flag indicating whether to create a Win32 package for Intune (optional, defaults to `true`).
- **intuneWinAppUtil**: The path to the Intune Win32 Content Prep Tool executable (optional, defaults to `"$env:ProgramFiles\Intune\IntuneWinAppUtil.exe"`).
- **intuneWinAppUtilWebPath**: The URL to download the Intune Win32 Content Prep Tool if it is not found on the system (optional, defaults to `https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/archive/refs/tags/v1.8.6.zip`).
- **destinationWin32Package**: The destination directory for the created Win32 package (optional, defaults to `"$PSScriptRoot\Intune\Builds"`).
- **intuneWinAppSetupFile**: The setup file to be used by the Intune Win32 Content Prep Tool (optional, defaults to `Deploy-Application.exe`).

### Examples

#### Creating an SFX Package

```sh
.\Create-Package.ps1 -PackageName "MyApp" -SFXPackage $true
Creates a self-extracting package named MyApp.exe using the files from the default source directory.
```
#### Creating a Win32 Package for Intune

```sh
.\Create-Package.ps1 -PackageName "MyApp" -win32Package $true
Creates a Win32 package for Intune deployment named MyApp.intunewin using the files from the default source directory.
```
### Folder Structure
- **Source/**: Contains the source files to be included in the package.
- **SFX/**: Contains resources and scripts for creating self-extracting (SFX) archives using WinRAR.
  - **sfxoptions.txt**: Configuration file for SFX creation.
  - **sfxexclude.txt**: File patterns to exclude from the SFX archive.
  - **Builds/**: Directory where the generated SFX packages are stored.
- **Intune/**: Contains resources and scripts for creating Win32 packages for Intune deployment.
  - **Builds/**: Directory where the generated Win32 packages are stored.
- **Logs/**: Directory where the logs of operations are stored.
- **Configuration/**: Contains additional configuration files such as icons.


### Notes
- Ensure that the WinRAR executable and the Intune Win32 Content Prep Tool are accessible or provide valid download URLs.
- The script logs all operations to the Logs directory under the script root.
- Customize the `sfxoptions.txt` and `sfxexclude.txt` files as needed for your specific deployment requirements.

### Contributing
1. Fork the repository.
2. Create a new feature branch (`git checkout -b feature/AmazingFeature`).
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.

### License
This project is licensed under the MIT License - see the [LICENSE](https://chatgpt.com/g/g-2DQzU5UZl-code-copilot/c/LICENSE) file for details.

### Explanation of Sections:

- **Features**: Highlights the main capabilities of the script.
- **Installation**: Provides instructions on how to set up the script and its dependencies.
- **Usage**: Explains how to run the script and describes the parameters.
- **Examples**: Gives practical examples of how to use the script.
- **Notes**: Additional information and tips for using the script.
- **Contributing**: Guidelines for contributing to the project.
- **License**: Information about the project's license.