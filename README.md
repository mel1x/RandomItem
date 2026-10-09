# Random Items Command

Forge mod that adds `/getRandomItem [count] [maxStack]`.

- Requires operator permission level 2 and a player command source.
- `count`: 1–27 random selections, defaults to 1.
- `maxStack`: 1–64 items per selection, defaults to 1. Each item's own stack limit is respected.
- Includes vanilla, hidden and modded items, except air.
- Items that do not fit in the inventory are dropped at the player.

Download from [Modrinth](https://modrinth.com/mod/random-items-cmd), [CurseForge](https://www.curseforge.com/minecraft/mc-mods/random-items-command), or [GitHub Releases](https://github.com/mel1x/RandomItem/releases).

## Version 1.1

Separate Forge JARs for Minecraft 1.21.1, 1.21.3–1.21.11, 26.1, 26.1.1, 26.1.2, 26.2 and 26.3. Forge has no release for 1.21.2. Install the JAR for your exact Minecraft version.

Minecraft 1.21.x requires Java 21; Minecraft 26.x requires Java 25. The pinned Forge and Java versions are in `versions.json`.

## Build

Use a JDK 25 to run Gradle. Gradle selects the target JDK through toolchains.

```powershell
./gradlew.bat build '-Pminecraft_version=1.21.1'
./scripts/build-all.ps1
./scripts/verify-jars.ps1
```

The individual build is in `build/<minecraft>/libs`. The full release and SHA-256 checksums are collected in `dist`.

The original 1.20.x source remains available at tag `1.20.x`.
