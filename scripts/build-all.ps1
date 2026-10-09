param([string[]]$Versions, [ValidateSet('forge','neoforge')][string]$Loader = 'forge')
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
$matrixFile = if ($Loader -eq 'neoforge') { 'versions-neoforge.json' } else { 'versions.json' }
$targets = Get-Content $matrixFile -Raw | ConvertFrom-Json
if ($Versions) { $targets = @($targets | Where-Object minecraft -In $Versions) }
New-Item -ItemType Directory -Force dist,.release | Out-Null
foreach ($target in $targets) {
    $mc = $target.minecraft
    $success = $false
    for ($attempt = 1; $attempt -le 3; $attempt++) {
        Write-Output "Building Minecraft $mc, attempt $attempt"
        & ./gradlew.bat build "-Ploader=$Loader" "-Pminecraft_version=$mc" --console=plain *> ".release/build-$Loader-$mc.log"
        if ($LASTEXITCODE -eq 0) { $success = $true; break }
        $log = Get-Content ".release/build-$Loader-$mc.log" -Raw
        if ($log -notmatch 'timed out|Connection reset|Could not (GET|HEAD)|Premature EOF') { break }
    }
    if (!$success) { Get-Content ".release/build-$Loader-$mc.log" -Tail 60; throw "Build failed: $Loader / $mc" }
    $buildPath = if ($Loader -eq 'neoforge') { "build/neoforge/$mc" } else { "build/$mc" }
    Copy-Item "$buildPath/libs/randomitem-1.1-$Loader-$mc.jar" dist/
    Write-Output "Built Minecraft $mc"
}
