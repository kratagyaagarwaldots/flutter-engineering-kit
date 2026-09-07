#!/usr/bin/env bash
set -euo pipefail

# Remote installer for the flutter-engineering-kit opencode mirror. No clone needed:
#
#   curl -fsSL https://raw.githubusercontent.com/kratagyaagarwaldots/flutter-engineering-kit/main/install.sh | bash -s -- /path/to/flutter-project
#
# Installs a pinned release tag by default. Flags:
#   --version vX.Y.Z   install that tag instead of the default pin
#   --version main     track trunk instead of a release (not reproducible)
#   --uninstall        remove a previously installed mirror instead of installing
#
# Env overrides: KIT_VERSION (same as --version), KIT_TARBALL_URL (full tarball URL,
# for local mirrors and testing; skips the tag/main fallback). KIT_VERSION and
# KIT_TARBALL_URL are only honoured from the environment, never from flags.
#
# What it does: downloads the kit tarball (~2 MB), extracts it to a temp dir, and runs
# that tree's own scripts/sync-opencode.sh against your project. This file carries no kit
# content itself, so it cannot drift from the skills, agents, or commands it installs.
# Prefer reading it first (pipe through less instead of bash) over trusting it blind.

REPO="kratagyaagarwaldots/flutter-engineering-kit"
DEFAULT_VERSION="v0.4.0"

VERSION="${KIT_VERSION:-$DEFAULT_VERSION}"
MODE="install"
TARGET=""

usage() {
  echo "usage: install.sh [--version vX.Y.Z|main] [--uninstall] /path/to/flutter-project" >&2
}

while [ $# -gt 0 ]; do
  case "$1" in
    --version) VERSION="${2:?error: --version needs a value}" ; shift 2 ;;
    --version=*) VERSION="${1#--version=}" ; shift ;;
    --uninstall) MODE="uninstall" ; shift ;;
    -h|--help) usage ; exit 0 ;;
    -*) echo "error: unknown flag $1" >&2 ; usage ; exit 2 ;;
    *) TARGET="$1" ; shift ;;
  esac
done

if [ -z "$TARGET" ]; then usage ; exit 2; fi
if [ ! -d "$TARGET" ]; then echo "error: $TARGET is not a directory" >&2; exit 1; fi
if [ ! -f "$TARGET/pubspec.yaml" ]; then
  echo "error: $TARGET has no pubspec.yaml; this does not look like a Flutter project" >&2
  exit 1
fi

for cmd in curl tar python3; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "error: $cmd is required but not on PATH" >&2; exit 1; }
done

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

tarball_url_for() {
  case "$1" in
    main|master) echo "https://codeload.github.com/$REPO/tar.gz/$1" ;;
    *) echo "https://codeload.github.com/$REPO/tar.gz/refs/tags/$1" ;;
  esac
}

if [ -n "${KIT_TARBALL_URL:-}" ]; then
  TARBALL="$KIT_TARBALL_URL"
else
  TARBALL="$(tarball_url_for "$VERSION")"
fi

echo "kit:     $REPO@$VERSION"
echo "target:  $TARGET ($MODE)"

if ! curl -fsSL -o "$WORK/kit.tgz" "$TARBALL"; then
  if [ -n "${KIT_TARBALL_URL:-}" ] || [ "$VERSION" = "main" ] || [ "$VERSION" = "master" ]; then
    echo "error: download failed: $TARBALL" >&2
    exit 1
  fi
  echo "warning: tag $VERSION not found; falling back to main" >&2
  VERSION="main"
  TARBALL="$(tarball_url_for main)"
  curl -fsSL -o "$WORK/kit.tgz" "$TARBALL" || { echo "error: download failed: $TARBALL" >&2; exit 1; }
fi

tar -xzf "$WORK/kit.tgz" -C "$WORK" --strip-components=1
SYNC="$WORK/scripts/sync-opencode.sh"
if [ ! -f "$SYNC" ]; then
  echo "error: kit archive has no scripts/sync-opencode.sh; refusing to continue" >&2
  exit 1
fi

if [ "$MODE" = "uninstall" ]; then
  bash "$SYNC" --uninstall "$TARGET"
else
  bash "$SYNC" "$TARGET"
fi
