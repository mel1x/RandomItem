# Release 1.1 verification

- All 15 Minecraft/Forge targets passed GitHub Actions run 37908237085 (commit c5ff7b2e11d0e1c15e51d47b7a74d06605b41bef).
- Release JARs were downloaded from that successful run and validated against versions.json.
- Checked mod ID, release version, exact Minecraft dependency, required implementation classes, Java class-file version and exclusion of smoke-test fixtures for all 15 JARs.
- Server command smoke tests passed on 1.21.1, 1.21.6, 1.21.11 and 26.3: default command, 27 selections, stack caps, invalid argument rejection, console rejection and full-inventory item tosses.
- The production 1.21.1 JAR was loaded in a separately installed Forge 52.1.16 dedicated server; its command registered and enforced the player requirement.
- A fresh local build after the development-run configuration adjustment contained byte-for-byte identical entries to the corresponding CI 1.21.1 JAR.
- SHA-256 checksums for the exact published artifacts are included in SHA256SUMS.txt.

Minecraft 1.21.2 has no Forge release and is not claimed as compatible.

## NeoForge addition to 1.1

- All five NeoForge targets (26.1, 26.1.1, 26.1.2, 26.2, 26.3) passed GitHub Actions run 37911631757 at commit 85d7c1cad0d14c5fc1c033ddbe231dbbe884b969.
- Release NeoForge JARs are the artifacts from that run. Their NeoForge descriptors, exact Minecraft dependencies, loader dependency, implementation classes and Java 25 bytecode were checked; Forge descriptors and smoke fixtures are absent.
- NeoForge dedicated-server smoke tests passed on 26.1 and 26.3: command registration, default selection, 27 selections, stack limits, invalid argument rejection, console rejection and 27 item tosses with a full inventory.
- SHA256SUMS.txt covers all 20 published JARs (15 Forge and five NeoForge).
- The original 1.1 tag identifies the Forge release source. NeoForge source is linked separately in the release notes to preserve that tag.
