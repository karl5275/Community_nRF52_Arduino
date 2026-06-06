#!/usr/bin/env bash
# Build a personal Arduino Boards Manager package for this fork.
#
# Produces, under dist/:
#   - community_nrf52_karl5275-<version>.tar.bz2   (the platform archive)
#   - package_karl5275_boards_index.json           (the Boards Manager index)
#
# The index points Boards Manager at the archive (via the GitHub release asset
# URL) and includes the Holyiot 18010 board. It depends on Adafruit's toolchain
# tools, so users still install "Adafruit nrf52" first.
#
# Usage:  tools/build_package_index.sh [version]
set -euo pipefail

VERSION="${1:-0.2.1}"
PACKAGER="community_nrf52_karl5275"
REPO="karl5275/Community_nRF52_Arduino"
ARCHIVE="community_nrf52_karl5275-${VERSION}.tar.bz2"
TOPDIR="Community_nRF52_Arduino-${VERSION}"
INDEX="package_karl5275_boards_index.json"
# Fixed (tag-pinned) URL for the archive asset:
ARCHIVE_URL="https://github.com/${REPO}/releases/download/v${VERSION}/${ARCHIVE}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
mkdir -p dist

echo ">> Listing tracked files (including submodules)..."
git ls-files --recurse-submodules > dist/filelist.txt
echo "   $(wc -l < dist/filelist.txt) files"

echo ">> Creating archive: dist/${ARCHIVE}"
tar -cjf "dist/${ARCHIVE}" --transform "s,^,${TOPDIR}/," -T dist/filelist.txt

SIZE=$(wc -c < "dist/${ARCHIVE}" | tr -d ' ')
SHA=$(sha256sum "dist/${ARCHIVE}" | cut -d' ' -f1)
echo "   size=${SIZE}  sha256=${SHA}"

echo ">> Writing index: dist/${INDEX}"
cat > "dist/${INDEX}" <<JSON
{
  "packages": [
    {
      "name": "${PACKAGER}",
      "maintainer": "karl5275",
      "websiteURL": "https://github.com/${REPO}",
      "email": "karlocta2594@gmail.com",
      "help": { "online": "https://github.com/${REPO}" },
      "platforms": [
        {
          "name": "Community Add on to Adafruit nRF52 (karl5275 fork + Holyiot 18010)",
          "architecture": "nrf52",
          "version": "${VERSION}",
          "category": "Contributed",
          "url": "${ARCHIVE_URL}",
          "archiveFileName": "${ARCHIVE}",
          "checksum": "SHA-256:${SHA}",
          "size": "${SIZE}",
          "help": { "online": "https://github.com/${REPO}" },
          "boards": [
            { "name": "Holyiot 18010 (nRF52840)" },
            { "name": "Nordic PCA10056" },
            { "name": "Nordic PCA10059" },
            { "name": "BlueMicro nrf52840" }
          ],
          "toolsDependencies": [
            { "packager": "adafruit", "name": "arm-none-eabi-gcc", "version": "9-2019q4" },
            { "packager": "adafruit", "name": "nrfjprog", "version": "9.4.0" }
          ]
        }
      ],
      "tools": []
    }
  ]
}
JSON

echo ">> Done."
echo "   Archive: dist/${ARCHIVE}"
echo "   Index:   dist/${INDEX}"
echo "   Publish both as assets on release tag v${VERSION}, then add this URL in the IDE:"
echo "   https://github.com/${REPO}/releases/latest/download/${INDEX}"
