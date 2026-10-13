#!/usr/bin/env bash
# Compile-checks VocabKit and the app's non-UI files on Linux (Docker image swift:6.2) and runs
# the package's unit tests. Works without a Mac (Windows Git Bash, Linux, macOS).
#
# NOT a replacement for an Xcode build: SwiftUI/WidgetKit views, App Intents and the GRDB-backed
# ContentStore are not compiled here (ContentStore is replaced by a stub with the same API).
#
# Usage: ios/Tools/linux_check.sh        (Docker must be running; WORK=<dir> to pick the work folder)
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
IOS="$(cd "$HERE/.." && pwd)"
WORK="${WORK:-$(mktemp -d)}"
PY="$(command -v python3 || command -v python)"

rm -rf "$WORK/VocabKit"
mkdir -p "$WORK"
cp -r "$IOS/Packages/VocabKit" "$WORK/VocabKit"
rm -rf "$WORK/VocabKit/.build"
"$PY" "$HERE/linux_check_prepare.py" "$WORK/VocabKit" "$IOS/App" "$HERE/linux-stubs"

MOUNT="$WORK/VocabKit"
if command -v cygpath >/dev/null 2>&1; then
    MOUNT="$(cygpath -w "$MOUNT")"  # Docker Desktop on Windows needs a Windows path
fi
MSYS_NO_PATHCONV=1 docker run --rm -v "$MOUNT:/pkg" -w /pkg swift:6.2 \
    bash -c "swift build --build-tests && swift test"
