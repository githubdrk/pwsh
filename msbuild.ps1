# Script to build a Visual Studio solution file (.sln) using MSBuild

# Function to check if MSBuild is available
function Check-MSBuild {
    Write-Host "Checking for MSBuild installation..."

    # Try to locate MSBuild in common locations (adjust the path if needed)
    $msbuildPath = "$env:ProgramFiles(x86)\Microsoft Visual Studio\2019\BuildTools\MSBuild\Current\Bin\MSBuild.exe"

    if (-not (Test-Path $msbuildPath)) {
        Write-Host "MSBuild is not installed in the default location."
        $msbuildPath = Get-Command msbuild -ErrorAction SilentlyContinue

        if (-not $msbuildPath) {
            Write-Host "MSBuild is not installed. Please install the Build Tools for Visual Studio."
            Exit
        }
    } else {
        Write-Host "MSBuild found at: $msbuildPath"
    }
    return $msbuildPath
}

# Function to build the Visual Studio solution file
function Build-Solution {
    param (
        [string]$solutionFilePath,
        [string]$configuration = "Release"
    )

    # Check if solution file exists
    if (-not (Test-Path $solutionFilePath)) {
        Write-Host "The specified solution file does not exist: $solutionFilePath"
        Exit
    }

    # Get MSBuild path
    $msbuildPath = Check-MSBuild

    # Execute MSBuild to build the solution
    Write-Host "Building the solution..."
    & "$msbuildPath" $solutionFilePath /p:Configuration=$configuration /m

    # Check for errors
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Build failed!" -ForegroundColor Red
    } else {
        Write-Host "Build succeeded!" -ForegroundColor Green
    }
}

# Prompt user to input the solution file path
$solutionFilePath = Read-Host "Enter the full path to the solution file (.sln)"

# Prompt user to choose the build configuration (Release or Debug)
$configuration = Read-Host "Enter the build configuration (Release/Debug, default is Release)"

# Run the build process with default or user-provided configuration
if ($configuration -eq "") {
    $configuration = "Release"
}
Build-Solution -solutionFilePath $solutionFilePath -configuration $configuration
