$ErrorActionPreference = 'Stop'

# Uses your local PostgreSQL defaults. Override any value before running if needed.
$env:DB_HOST = if ($env:DB_HOST) { $env:DB_HOST } else { 'localhost' }
$env:DB_PORT = if ($env:DB_PORT) { $env:DB_PORT } else { '5432' }
$env:DB_NAME = if ($env:DB_NAME) { $env:DB_NAME } else { 'skill2' }
$env:DB_USERNAME = if ($env:DB_USERNAME) { $env:DB_USERNAME } else { 'postgres' }
$env:DB_PASSWORD = if ($env:DB_PASSWORD) { $env:DB_PASSWORD } else { 'root' }

if (-not $env:JAVA_HOME -or -not (Test-Path (Join-Path $env:JAVA_HOME 'bin\java.exe'))) {
    $jdk = 'C:\Program Files\Java\jdk-25.0.2'
    if (-not (Test-Path (Join-Path $jdk 'bin\java.exe'))) {
        throw "JAVA_HOME is not set and Java 25 was not found at $jdk. Set JAVA_HOME to your JDK directory and rerun."
    }
    $env:JAVA_HOME = $jdk
}

$javaCommand = Join-Path $env:JAVA_HOME 'bin\java.exe'

# These standard Spring environment variables also support older packaged WAR files.
$env:SPRING_DATASOURCE_URL = "jdbc:postgresql://$($env:DB_HOST):$($env:DB_PORT)/$($env:DB_NAME)"
$env:SPRING_DATASOURCE_USERNAME = $env:DB_USERNAME
$env:SPRING_DATASOURCE_PASSWORD = $env:DB_PASSWORD

$services = @(
    'eureka-server',
    'auth-service',
    'user-service',
    'course-service',
    'payment-service',
    'enrollment-service',
    'api-gateway'
)

foreach ($service in $services) {
    Write-Host "Starting $service..."
    $war = Join-Path $PSScriptRoot "$service\target\$service-0.0.1-SNAPSHOT.war"
    if (-not (Test-Path $war)) {
        throw "Packaged application was not found: $war. Build the service before running it."
    }
    Start-Process -FilePath $javaCommand -ArgumentList '-jar', $war -WorkingDirectory (Join-Path $PSScriptRoot $service)
    Start-Sleep -Seconds 2
}

Write-Host 'All services were launched in separate windows. Gateway: http://localhost:8080'
