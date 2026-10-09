param([string[]]$Versions, [ValidateSet('forge','neoforge')][string]$Loader = 'forge')
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
New-Item -ItemType Directory -Force .release | Out-Null
if (!$Versions) { $Versions = if ($Loader -eq 'neoforge') { @('26.1','26.3') } else { @('1.21.1','1.21.6','1.21.11','26.3') } }
foreach ($mc in $Versions) {
    $runPath = if ($Loader -eq 'neoforge') { "run/neoforge/$mc" } else { "run/$mc" }
    $eula = "$runPath/eula.txt"
    if (!(Test-Path $eula) -or (Get-Content $eula -Raw) -notmatch '(?m)^eula=true\s*$') {
        throw "Accept the Minecraft server EULA in $eula before running this test."
    }
    @'
server-ip=127.0.0.1
server-port=0
online-mode=false
level-type=minecraft:flat
view-distance=2
simulation-distance=2
'@ | Set-Content "$runPath/server.properties"
    & ./gradlew.bat runServer "-Ploader=$Loader" "-Pminecraft_version=$mc" '-PsmokeTest' --console=plain *> ".release/smoke-$Loader-$mc.log"
    if ($LASTEXITCODE -ne 0 -or (Get-Content ".release/smoke-$Loader-$mc.log" -Raw) -notmatch 'RANDOMITEM_SMOKE_PASS') {
        Get-Content ".release/smoke-$Loader-$mc.log" -Tail 60
        throw "Server smoke test failed: $mc"
    }
    Write-Output "Server smoke test passed: $mc"
}
