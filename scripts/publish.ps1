param(
    [Parameter(Mandatory)][string]$EnvFile,
    [ValidateSet('Modrinth','CurseForge')][string[]]$Platforms = @('Modrinth','CurseForge')
)
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
& ./scripts/verify-jars.ps1
$tokens = @{}
foreach ($line in Get-Content -LiteralPath $EnvFile) {
    if ($line -match '^\s*(MODRINTH_TOKEN|CURSEFORGE_TOKEN)\s*=\s*(.*)$') {
        $tokens[$Matches[1]] = $Matches[2].Trim().Trim('"').Trim("'")
    }
}
$targets = Get-Content versions.json -Raw | ConvertFrom-Json
$changelog = Get-Content CHANGELOG.md -Raw
$receiptsFile = '.release/publication-receipts.json'
$receipts = @()
if (Test-Path $receiptsFile) { $receipts = @(Get-Content $receiptsFile -Raw | ConvertFrom-Json) }
if ('Modrinth' -in $Platforms) {
    $mrHeaders = @{Authorization=$tokens.MODRINTH_TOKEN}
    $existing = Invoke-RestMethod 'https://api.modrinth.com/v2/project/BmBsXMuV/version' -Headers $mrHeaders -UserAgent 'RandomItem/1.1 (mel1x)'
    $mrGameVersions = @(Invoke-RestMethod 'https://api.modrinth.com/v2/tag/game_version').version
    foreach ($target in $targets) { if ($target.minecraft -notin $mrGameVersions) { throw "Unknown Modrinth version: $($target.minecraft)" } }
}
if ('CurseForge' -in $Platforms) {
    $cfHeaders = @{'X-Api-Token'=$tokens.CURSEFORGE_TOKEN}
    $cfGameVersions = Invoke-RestMethod 'https://minecraft.curseforge.com/api/game/versions' -Headers $cfHeaders
}
foreach ($target in $targets) {
    $mc = $target.minecraft
    $file = Get-Item "dist/randomitem-1.1-forge-$mc.jar"
    $sha256 = (Get-FileHash $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    $displayName = "Random Items Command 1.1 (Forge $mc)"
    foreach ($platform in $Platforms) {
        $previous = @($receipts | Where-Object { $_.platform -eq $platform -and $_.minecraft -eq $mc })
        if ($previous) {
            if ($previous[0].sha256 -ne $sha256) { throw "Published JAR changed: $platform / $mc" }
            Write-Output "Already uploaded: $platform / $mc / $($previous[0].id)"
            continue
        }
        if ($platform -eq 'Modrinth') {
            $versionNumber = "1.1-forge-$mc"
            $match = @($existing | Where-Object version_number -EQ $versionNumber)
            if ($match) {
                $sha512 = (Get-FileHash $file.FullName -Algorithm SHA512).Hash.ToLowerInvariant()
                if ($match[0].files.hashes.sha512 -notcontains $sha512) { throw "Modrinth version already exists with different contents: $mc" }
                $response = $match[0]
            } else {
                $data = @{
                    project_id='BmBsXMuV'; name=$displayName; version_number=$versionNumber;
                    changelog=$changelog; dependencies=@(); game_versions=@($mc); version_type='release';
                    loaders=@('forge'); featured=$true; file_parts=@('file'); primary_file='file';
                    status='listed'; environment='server_only_client_optional'
                } | ConvertTo-Json -Depth 8 -Compress
                $response = Invoke-RestMethod 'https://api.modrinth.com/v2/version' -Method Post -Headers $mrHeaders `
                    -UserAgent 'RandomItem/1.1 (mel1x)' -Form ([ordered]@{data=$data; file=$file})
            }
            $id = $response.id
            $url = "https://modrinth.com/mod/random-items-cmd/version/$id"
        } else {
            $mcVersion = @($cfGameVersions | Where-Object { $_.name -eq $mc -and $_.gameVersionTypeID -notin @(1,615) })
            if ($mcVersion.Count -ne 1) { throw "Ambiguous CurseForge game version: $mc" }
            $forgeId = ($cfGameVersions | Where-Object name -EQ 'Forge').id
            $javaId = ($cfGameVersions | Where-Object name -EQ "Java $($target.java)").id
            $serverId = ($cfGameVersions | Where-Object name -EQ 'Server').id
            $clientId = ($cfGameVersions | Where-Object name -EQ 'Client').id
            $data = @{
                changelog=$changelog; changelogType='markdown'; displayName=$displayName;
                gameVersions=@($mcVersion[0].id,$forgeId,$javaId,$serverId,$clientId);
                releaseType='release'; isMarkedForManualRelease=$false
            } | ConvertTo-Json -Depth 8 -Compress
            $response = Invoke-RestMethod 'https://minecraft.curseforge.com/api/projects/1232884/upload-file' `
                -Method Post -Headers $cfHeaders -Form ([ordered]@{metadata=$data; file=$file})
            $id = $response.id
            $url = "https://www.curseforge.com/minecraft/mc-mods/random-items-command/files/$id"
        }
        if (!$id) { throw "Upload returned no file/version ID: $platform / $mc" }
        $receipts += [pscustomobject]@{platform=$platform; minecraft=$mc; id=$id; url=$url; sha256=$sha256}
        $receipts | ConvertTo-Json -Depth 8 | Set-Content $receiptsFile
        Write-Output "Uploaded: $platform / $mc / $url"
    }
}
