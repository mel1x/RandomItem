$loaders = @('forge','neoforge')
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
Add-Type -AssemblyName System.IO.Compression.FileSystem
foreach ($loader in $loaders) {
$matrixFile = if ($loader -eq 'neoforge') { 'versions-neoforge.json' } else { 'versions.json' }
$targets = Get-Content $matrixFile -Raw | ConvertFrom-Json
foreach ($target in $targets) {
    $mc = $target.minecraft
    $file = Get-Item "dist/randomitem-1.1-$loader-$mc.jar"
    $zip = [IO.Compression.ZipFile]::OpenRead($file.FullName)
    try {
        $descriptor = if ($loader -eq 'neoforge') { 'META-INF/neoforge.mods.toml' } else { 'META-INF/mods.toml' }
        $otherDescriptor = if ($loader -eq 'neoforge') { 'META-INF/mods.toml' } else { 'META-INF/neoforge.mods.toml' }
        if ($zip.GetEntry($otherDescriptor)) { throw "Wrong loader descriptor: $loader / $mc" }
        $entry = $zip.GetEntry($descriptor)
        if (!$entry) { throw "Missing mods.toml: $mc" }
        $reader = [IO.StreamReader]::new($entry.Open())
        try { $toml = $reader.ReadToEnd() } finally { $reader.Dispose() }
        if ($toml -notmatch 'modId="randomitem"' -or $toml -notmatch 'version="1.1"' -or
            $toml -notmatch ('versionRange="\[' + [regex]::Escape($mc) + '\]"') -or $toml -match '\$\{') {
            throw "Incorrect metadata: $mc"
        }
        if (@($zip.Entries | Where-Object FullName -Match '/Smoke').Count) { throw "Test fixture leaked into $mc" }
        foreach ($name in @('RandomItemMod','RandomItemCommand','CommandPermissions','OverflowItems')) {
            $class = $zip.GetEntry("com/example/randomitem/$name.class")
            if (!$class) { throw "Missing $name in $mc" }
            $stream = $class.Open()
            try { $header = New-Object byte[] 8; [void]$stream.Read($header,0,8) } finally { $stream.Dispose() }
            $major = $header[6] * 256 + $header[7]
            if ($major -ne $target.java + 44) { throw "Wrong Java bytecode: $mc / $major" }
        }
        if ($toml -notmatch ('modId="' + $loader + '"')) { throw "Missing loader dependency: $loader / $mc" }
        Write-Host "Verified $loader / Minecraft $mc (Java $($target.java))"
    } finally { $zip.Dispose() }
}
}
$hashes = Get-ChildItem dist/randomitem-1.1-*.jar | Sort-Object Name | ForEach-Object {
    "$((Get-FileHash $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant())  $($_.Name)"
}
$hashes | Set-Content dist/SHA256SUMS.txt
