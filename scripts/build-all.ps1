param([string[]]$Versions)
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
$targets = Get-Content versions.json -Raw | ConvertFrom-Json
if ($Versions) { $targets = @($targets | Where-Object minecraft -In $Versions) }
New-Item -ItemType Directory -Force dist,.release | Out-Null
foreach ($target in $targets) {
    $mc = $target.minecraft
    $success = $false
    for ($attempt = 1; $attempt -le 3; $attempt++) {
        Write-Output "Building Minecraft $mc, attempt $attempt"
        & ./gradlew.bat build "-Pminecraft_version=$mc" --console=plain *> ".release/build-$mc.log"
        if ($LASTEXITCODE -eq 0) { $success = $true; break }
        $log = Get-Content ".release/build-$mc.log" -Raw
        if ($log -notmatch 'timed out|Connection reset|Could not (GET|HEAD)|Premature EOF') { break }
    }
    if (!$success) { Get-Content ".release/build-$mc.log" -Tail 60; throw "Build failed: $mc" }
    Copy-Item "build/$mc/libs/randomitem-1.1-forge-$mc.jar" dist/
    Write-Output "Built Minecraft $mc"
}
