#Requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('apk', 'aab', 'windows')]
    [string]$Format,
    
    [Parameter()]
    [ValidateSet('dev', 'prod')]
    [string]$Flavor,
    
    [Parameter()]
    [ValidateSet('release', 'debug', 'profile')]
    [string]$BuildMode = 'release',
    
    [Parameter()]
    [switch]$Foss,
    
    [Parameter()]
    [string]$OutputDir = 'artifacts',
    
    [Parameter()]
    [switch]$DryRun,
    
    [Parameter()]
    [string]$TargetFile,
    
    [Parameter()]
    [switch]$NoCodesign
)

# Configuration
$ErrorActionPreference = 'Stop'
$DefaultTargetFile = 'lib/main.dart'
$FossTargetFile = 'lib/main_foss.dart'
$BuildBaseDir = 'build'
$AppOutputsDir = "$BuildBaseDir/app/outputs"

$FossExcludedDeps = @(
    'purchases_flutter:',
    'rate_my_app:',
    'google_api_availability:'
)

$AllowedFlavors = @('dev', 'prod')
$FlavorRequiredFormats = @('apk', 'aab')

# Get app info from pubspec.yaml
function Get-AppInfo {
    if (-not (Test-Path 'pubspec.yaml')) {
        throw "pubspec.yaml not found. Please run this script from the Flutter project root."
    }
    
    $pubspec = Get-Content 'pubspec.yaml' -First 5
    $script:AppName = ($pubspec[0] -split ' ')[1]
    $script:Version = ($pubspec | Where-Object { $_ -match '^version:' }) -replace 'version:\s*', ''
}

# Utility functions
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Write-Debug {
    param([string]$Message)
    if ($VerbosePreference -eq 'Continue') {
        Write-Host "[DEBUG] $Message" -ForegroundColor Blue
    }
}

# Load secret environment variables
function Load-SecretEnv {
    $secretEnvFile = '.env'
    if (Test-Path $secretEnvFile) {
        Get-Content $secretEnvFile | ForEach-Object {
            if ($_ -match '^([^=]+)=(.*)$') {
                [Environment]::SetEnvironmentVariable($matches[1], $matches[2], 'Process')
            }
        }
        Write-Status "Loaded secrets from $secretEnvFile"
    } else {
        Write-Status "$secretEnvFile not found, skipping secret env loading"
    }
}

# Validate flavor
function Test-FlavorRequired {
    if ($Format -in $FlavorRequiredFormats) {
        if (-not $Flavor) {
            throw "Flavor is required for $Format. Use -Flavor <flavor>."
        }
        if ($Flavor -notin $AllowedFlavors) {
            throw "Invalid flavor: $Flavor. Allowed flavors: $($AllowedFlavors -join ', ')"
        }
    }
}

# Prepare Flutter arguments
function Get-FlutterArgs {
    $args = @()
    
    # Add build mode
    $args += "--$BuildMode"
    
    # Add flavor if required
    if ($Flavor -and $Format -in $FlavorRequiredFormats) {
        $args += '--flavor', $Flavor
    }
    
    # Add target file
    if ($TargetFile) {
        $args += '-t', $TargetFile
    } elseif ($Foss) {
        $args += '-t', $FossTargetFile
    } else {
        $args += '-t', $DefaultTargetFile
    }
    
    # Add environment file if flavor is specified
    if ($Flavor) {
        $envFile = "env/$Flavor.json"
        if (Test-Path $envFile) {
            $args += '--dart-define-from-file', $envFile
        }
    }
    
    # Add dart defines
    if (Get-Command git -ErrorAction SilentlyContinue) {
        $gitCommit = git rev-parse --short HEAD 2>$null
        $gitBranch = git rev-parse --abbrev-ref HEAD 2>$null
        if ($gitCommit) { $args += "--dart-define=GIT_COMMIT=$gitCommit" }
        if ($gitBranch) { $args += "--dart-define=GIT_BRANCH=$gitBranch" }
    }
    
    $buildTimestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ'
    $args += "--dart-define=BUILD_TIMESTAMP=$buildTimestamp"
    $args += "--dart-define=IS_FOSS_BUILD=$($Foss.IsPresent)"
    
    if ($Foss -and $Format -in @('apk', 'aab')) {
        $args += "--dart-define=cronetHttpNoPlay=true"
    }
    
    # Add RevenueCat keys for prod builds
    if ($Flavor -eq 'prod') {
        if ($Format -in @('apk', 'aab')) {
            $googleKey = [Environment]::GetEnvironmentVariable('REVENUECAT_GOOGLE_API_KEY', 'Process')
            if (-not $googleKey) {
                throw "REVENUECAT_GOOGLE_API_KEY is required for prod Android builds. Set it in .env"
            }
            $args += "--dart-define=REVENUECAT_GOOGLE_API_KEY=$googleKey"
        }
    }
    
    if ($NoCodesign) {
        $args += '--no-codesign'
    }
    
    return $args
}

# Prepare FOSS build
function Prepare-FossBuild {
    if (-not $Foss) { return }
    
    Write-Status "Preparing FOSS build - removing non-FOSS dependencies..."
    
    # Backup pubspec.yaml
    $script:BackupFile = "pubspec.yaml.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
    Copy-Item 'pubspec.yaml' $BackupFile
    
    $content = Get-Content 'pubspec.yaml'
    $newContent = @()
    
    foreach ($line in $content) {
        $exclude = $false
        foreach ($dep in $FossExcludedDeps) {
            if ($line -match $dep) {
                Write-Debug "Removing dependency: $dep"
                $exclude = $true
                break
            }
        }
        if (-not $exclude) {
            $newContent += $line
        }
    }
    
    $newContent | Set-Content 'pubspec.yaml'
    
    Write-Status "Getting FOSS dependencies..."
    flutter pub get
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to get FOSS dependencies"
    }
}

# Restore pubspec.yaml
function Restore-Pubspec {
    if ($script:BackupFile -and (Test-Path $script:BackupFile)) {
        Move-Item $script:BackupFile 'pubspec.yaml' -Force
        Write-Status "Restored original pubspec.yaml"
        flutter pub get | Out-Null
    }
}

# Build APK
function Build-Apk {
    Write-Status "Building Android APK..."
    
    $flutterArgs = Get-FlutterArgs
    if ($DryRun) {
        Write-Status "Would run: flutter build apk $($flutterArgs -join ' ')"
        return
    }
    
    flutter build apk @flutterArgs
    if ($LASTEXITCODE -ne 0) {
        throw "Flutter build failed for APK"
    }
    
    # Determine source path
    if ($Flavor) {
        $apkSource = "$AppOutputsDir/flutter-apk/app-$Flavor-$BuildMode.apk"
    } else {
        $apkSource = "$AppOutputsDir/flutter-apk/app-$BuildMode.apk"
    }
    
    # Determine target name
    if ($Foss) {
        $apkName = "$AppName-$Version-$(if($Flavor){$Flavor}else{'universal'})-foss.apk"
    } else {
        $apkName = "$AppName-$Version-$(if($Flavor){$Flavor}else{'universal'}).apk"
    }
    
    # Copy to output directory
    if (Test-Path $apkSource) {
        if (-not (Test-Path $OutputDir)) {
            New-Item -ItemType Directory -Path $OutputDir | Out-Null
        }
        Copy-Item $apkSource "$OutputDir/$apkName"
        Write-Status "APK created: $OutputDir/$apkName"
    } else {
        throw "APK not found at: $apkSource"
    }
}

# Build AAB
function Build-Aab {
    Write-Status "Building Android App Bundle..."
    
    $flutterArgs = Get-FlutterArgs
    if ($DryRun) {
        Write-Status "Would run: flutter build appbundle $($flutterArgs -join ' ')"
        return
    }
    
    flutter build appbundle @flutterArgs
    if ($LASTEXITCODE -ne 0) {
        throw "Flutter build failed for AAB"
    }
    
    # Determine source path and name based on flavor
    switch ($Flavor) {
        'dev' {
            $aabSource = "$AppOutputsDir/bundle/devRelease/app-dev-release.aab"
            $aabName = "$AppName-$Version-dev.aab"
        }
        'prod' {
            $aabSource = "$AppOutputsDir/bundle/prodRelease/app-prod-release.aab"
            $aabName = "$AppName-$Version.aab"
        }
        default {
            Write-Warning "No specific flavor handling for app bundle"
            return
        }
    }
    
    # Copy to output directory
    if (Test-Path $aabSource) {
        if (-not (Test-Path $OutputDir)) {
            New-Item -ItemType Directory -Path $OutputDir | Out-Null
        }
        Copy-Item $aabSource "$OutputDir/$aabName"
        Write-Status "AAB created: $OutputDir/$aabName"
    } else {
        throw "AAB not found at: $aabSource"
    }
}

# Build Windows
function Build-Windows {
    Write-Status "Building Windows Executable..."
    
    $flutterArgs = Get-FlutterArgs
    if ($DryRun) {
        Write-Status "Would run: flutter build windows $($flutterArgs -join ' ')"
        return
    }
    
    flutter build windows @flutterArgs
    if ($LASTEXITCODE -ne 0) {
        throw "Flutter build failed for Windows"
    }
    
    # Determine names
    if ($Foss) {
        $zipName = "$AppName-$Version-foss.zip"
    } else {
        $zipName = "$AppName-$Version.zip"
    }
    
    $releaseDir = "$BuildBaseDir\windows\x64\runner\Release"
    
    # Create output directory if needed
    if (-not (Test-Path $OutputDir)) {
        New-Item -ItemType Directory -Path $OutputDir | Out-Null
    }
    
    # Zip the Release folder
    if (Test-Path $releaseDir) {
        $zipPath = "$OutputDir\$zipName"
        
        # Use Compress-Archive for creating zip
        Compress-Archive -Path "$releaseDir\*" -DestinationPath $zipPath -Force
        Write-Status "Windows build zipped to: $zipPath"
    } else {
        throw "Release directory not found: $releaseDir"
    }
}

# Main execution
function Main {
    $startTime = Get-Date
    
    try {
        # Initialize
        Get-AppInfo
        Test-FlavorRequired
        Load-SecretEnv
        
        Write-Status "Building $AppName version $Version as $Format ($BuildMode)"
        Write-Debug "Target file: $(if($TargetFile){$TargetFile}elseif($Foss){$FossTargetFile}else{$DefaultTargetFile})"
        Write-Debug "Flavor: $(if($Flavor){$Flavor}else{'none'})"
        Write-Debug "FOSS build: $($Foss.IsPresent)"
        
        # Prepare FOSS build if needed
        Prepare-FossBuild
        
        # Execute build
        switch ($Format) {
            'apk' { Build-Apk }
            'aab' { Build-Aab }
            'windows' { Build-Windows }
        }
        
        # Show summary
        $duration = (Get-Date) - $startTime
        Write-Host "`n=== BUILD SUMMARY ===" -ForegroundColor Green
        Write-Host "App: $AppName v$Version"
        Write-Host "Format: $Format ($BuildMode)"
        Write-Host "Flavor: $(if($Flavor){$Flavor}else{'none'})"
        Write-Host "FOSS: $($Foss.IsPresent)"
        Write-Host "Duration: $($duration.ToString('mm\:ss'))"
        Write-Host "`nBuild completed successfully!" -ForegroundColor Green
    }
    catch {
        Write-Error $_.Exception.Message
        exit 1
    }
    finally {
        Restore-Pubspec
    }
}

# Run main
Main