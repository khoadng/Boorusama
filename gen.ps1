# Windows PowerShell script for generating boilerplate code

Write-Host "Generating boilerplate code..." -ForegroundColor Green

# Start all processes in parallel
$jobs = @()

# Run slang in i18n package
$jobs += Start-Job -ScriptBlock {
    Set-Location "$using:PWD\packages\i18n"
    dart run slang
}

# Run generate_language.dart in i18n package
$jobs += Start-Job -ScriptBlock {
    Set-Location "$using:PWD\packages\i18n"
    dart run tools/generate_language.dart
}

# Run generate_config.dart in booru_clients package
$jobs += Start-Job -ScriptBlock {
    Set-Location "$using:PWD\packages\booru_clients"
    dart run tools/generate_config.dart
}

# Wait for all jobs to complete
Write-Host "Waiting for all generation tasks to complete..." -ForegroundColor Yellow
$jobs | Wait-Job | Out-Null

# Check for errors
$failed = $false
foreach ($job in $jobs) {
    $result = Receive-Job -Job $job
    if ($job.State -eq 'Failed') {
        Write-Host "Error in job:" -ForegroundColor Red
        Write-Host $result -ForegroundColor Red
        $failed = $true
    } else {
        Write-Host $result
    }
    Remove-Job -Job $job
}

if ($failed) {
    Write-Host "Code generation failed!" -ForegroundColor Red
    exit 1
} else {
    Write-Host "Code generation completed successfully!" -ForegroundColor Green
}