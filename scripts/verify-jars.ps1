$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
Add-Type -AssemblyName System.IO.Compression.FileSystem
$targets = Get-Content versions.json -Raw | ConvertFrom-Json
$hashes = foreach ($target in $targets) {
    $mc = $target.minecraft
    $file = Get-Item "dist/randomitem-1.1-forge-$mc.jar"
    $zip = [IO.Compression.ZipFile]::OpenRead($file.FullName)
    try {
        $entry = $zip.GetEntry('META-INF/mods.toml')
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
        $hash = (Get-FileHash $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
        "$hash  $($file.Name)"
        Write-Host "Verified Minecraft $mc (Java $($target.java))"
    } finally { $zip.Dispose() }
}
$hashes | Set-Content dist/SHA256SUMS.txt
