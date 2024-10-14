# Check .NET Framework 4.8 Installation
$keyPath = "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full"
if (Test-Path $keyPath) {
    $releaseKey = (Get-ItemProperty -Path $keyPath).Release
    if ($releaseKey -ge 528040) {
        Write-Output ".NET Framework 4.8 is already installed."
    } else {
        Write-Output ".NET Framework 4.8 is not installed."
        exit 1
    }
} else {
    Write-Output ".NET Framework 4.8 is not installed."
    exit 1
}

# Download .NET Framework 4.8 Installer (only if not installed)
$installDir = "C:\agent\_work"
if (-Not (Test-Path $installDir)) {
    New-Item -Path $installDir -ItemType Directory
}

$downloadUrl = "https://download.visualstudio.microsoft.com/download/pr/2d6bb6b2-226a-4baa-bdec-798822606ff1/9b7b8746971ed51a1770ae4293618187/ndp48-web.exe"
$installerPath = "$installDir\ndp48-web.exe"
Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath

# Install .NET Framework 4.8 Silently (only if needed)
Start-Process -FilePath $installerPath -ArgumentList "/q /norestart" -Wait

# Verify .NET Framework 4.8 Installation (again for confirmation)
if (Test-Path $keyPath) {
    $releaseKey = (Get-ItemProperty -Path $keyPath).Release
    if ($releaseKey -ge 528040) {
        Write-Output ".NET Framework 4.8 or later is successfully installed."
        
        # Add .NET Framework path to system environment variables
        $dotNetPath = "C:\Windows\Microsoft.NET\Framework\v4.0.30319"
        if (-Not ($env:Path -contains $dotNetPath)) {
            [System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";$dotNetPath", [System.EnvironmentVariableTarget]::Machine)
            Write-Output "Added .NET Framework path to system environment variables."
        } else {
            Write-Output ".NET Framework path is already in the system environment variables."
        }
    } else {
        Write-Error ".NET Framework 4.8 installation failed."
        exit 1
    }
} else {
    Write-Error ".NET Framework 4.8 installation failed."
    exit 1
}

# Define paths
$solutionPath = "C:\Path\To\YourSolution.sln"  # Update with the actual path
$buildOutputPath = "C:\Path\To\Build\Output"   # Update with the actual path
$unifiedAgentUrl = "https://unified-agent-download-url/whitesource-unified-agent.jar" # Get this from WhiteSource
$unifiedAgentJar = "C:\Path\To\whitesource-unified-agent.jar"  # Update with the actual path
$configFilePath = "C:\Path\To\whitesource-config.properties"   # Update with the actual path

# API Key for WhiteSource
$apiKey = "YOUR_WHITESOURCE_API_KEY"  # Replace with your actual API key
$projectName = "YourProjectName"        # Replace with your project name

# 1. Build the Solution
Write-Host "Building the solution..."
& "msbuild.exe" $solutionPath /p:Configuration=Release /p:OutputPath=$buildOutputPath

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
} else {
    Write-Host "Build succeeded!" -ForegroundColor Green
}

# 2. Download WhiteSource Unified Agent
if (-Not (Test-Path $unifiedAgentJar)) {
    Write-Host "Downloading WhiteSource Unified Agent..."
    Invoke-WebRequest -Uri $unifiedAgentUrl -OutFile $unifiedAgentJar
} else {
    Write-Host "WhiteSource Unified Agent already downloaded."
}

# 3. Configure WhiteSource (whitesource-config.properties)
$configContent = @"
# WhiteSource Unified Agent Configuration
apiKey=$apiKey
projectName=$projectName
productName=$projectName
projectToken=
checkPolicies=true
forceUpdate=true
forceCheckAllDependencies=true
includes=**/*.dll,**/*.exe,**/*.csproj,**/*.cs
# Exclude patterns
excludes=**/bin/**,**/obj/**,**/*.spec.cs,**/*.test.cs,**/*.tests.dll
excludeTestModules=true
failErrorLevel=ALL
offline=false
logLevel=info
buildArtifactsFolder=$buildOutputPath
"@

# Write the configuration file
Set-Content -Path $configFilePath -Value $configContent

# 4. Run the WhiteSource Unified Agent
Write-Host "Running WhiteSource scan..."
& "java" -jar $unifiedAgentJar -c $configFilePath

if ($LASTEXITCODE -ne 0) {
    Write-Host "WhiteSource scan failed!" -ForegroundColor Red
} else {
    Write-Host "WhiteSource scan succeeded!" -ForegroundColor Green
}
