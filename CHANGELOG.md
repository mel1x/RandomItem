# 1.1

- Add separate NeoForge builds for Minecraft 26.1, 26.1.1, 26.1.2, 26.2 and 26.3 with the same command behavior.

- Add separate Forge builds for Minecraft 1.21.1, 1.21.3–1.21.11, 26.1, 26.1.1, 26.1.2, 26.2 and 26.3.
- Update command registration and operator permission checks for newer Minecraft and Forge APIs.
- Preserve `/getRandomItem [count] [maxStack]`, including vanilla, hidden and modded items.
- Exclude air from random selection.
- Drop remaining items at the player when their inventory is full.
- Respect each item's maximum stack size.

Forge does not provide a build for Minecraft 1.21.2. Each JAR supports only its named Minecraft version.
