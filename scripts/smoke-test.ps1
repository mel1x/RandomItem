param([string[]]$Versions = @('1.21.1','1.21.6','1.21.11','26.3'))
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
New-Item -ItemType Directory -Force .release | Out-Null
foreach ($mc in $Versions) {
    $eula = "run/$mc/eula.txt"
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
'@ | Set-Content "run/$mc/server.properties"
    & ./gradlew.bat runServer "-Pminecraft_version=$mc" '-PsmokeTest' --console=plain *> ".release/smoke-$mc.log"
    if ($LASTEXITCODE -ne 0 -or (Get-Content ".release/smoke-$mc.log" -Raw) -notmatch 'RANDOMITEM_SMOKE_PASS') {
        Get-Content ".release/smoke-$mc.log" -Tail 60
        throw "Server smoke test failed: $mc"
    }
    Write-Output "Server smoke test passed: $mc"
}
