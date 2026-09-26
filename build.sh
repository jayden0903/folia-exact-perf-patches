#!/usr/bin/env bash
# Build a Folia 26.2 paperclip with the patches in ./patches applied.
# Usage: ./build.sh /absolute/path/to/NEW-empty-directory   (needs git, network, JDK 25)
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
TARGET="${1:?Usage: build.sh /absolute/path/to/NEW-empty-directory}"
[[ "$TARGET" = /* && ! -e "$TARGET" ]] || { echo 'A new, absolute, not-yet-existing path is required' >&2; exit 1; }
BASE_COMMIT="${FOLIA_COMMIT:-68b2af1}"
git clone --filter=blob:none --no-checkout https://github.com/PaperMC/Folia.git "$TARGET"
git -C "$TARGET" checkout --detach "$BASE_COMMIT"
cd "$TARGET"
./gradlew applyAllPatches --no-daemon
for patch in "$ROOT"/patches/*.patch; do
  git -C folia-server/src/minecraft/java apply --check "$patch"
  git -C folia-server/src/minecraft/java apply "$patch"
  echo "applied $(basename "$patch")"
done
./gradlew :folia-server:createPaperclipJar --no-daemon
ls folia-server/build/libs/*paperclip*.jar
