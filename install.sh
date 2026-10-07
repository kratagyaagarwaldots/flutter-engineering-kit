#!/usr/bin/env bash
set -euo pipefail

# Install the flutter-engineering-kit for your user, for the harnesses you use. No clone needed:
#
#   curl -fsSL https://raw.githubusercontent.com/kratagyaagarwaldots/flutter-engineering-kit/main/install.sh | bash -s -- --for codex,opencode
#   curl -fsSL .../install.sh | bash -s -- --detect        # every harness found on this machine
#   curl -fsSL .../install.sh | bash -s -- uninstall       # remove it again
#
# Flags it handles itself:
#   --version vX.Y.Z   install that tag instead of the default pin (main tracks trunk)
# Everything else is passed to `kit` (scripts/kit.py): install --for/--detect, uninstall,
# doctor, clean-project. With no command, `install` is assumed.
#
# What it does: downloads the kit tarball into ~/.flutter-kit/versions/<version>, points
# ~/.flutter-kit/current at it, writes a `kit` launcher to ~/.flutter-kit/bin, then runs
# that version's own scripts/kit.py. This file carries no kit content, so it cannot drift
# from what it installs. Pipe it through `less` instead of `bash` to read it first.
#
# Env: KIT_VERSION (same as --version), KIT_TARBALL_URL (full tarball URL, for mirrors and
# tests), FLUTTER_KIT_HOME (default ~/.flutter-kit).

REPO="kratagyaagarwaldots/flutter-engineering-kit"
DEFAULT_VERSION="v0.9.1"

VERSION="${KIT_VERSION:-$DEFAULT_VERSION}"
STATE="${FLUTTER_KIT_HOME:-$HOME/.flutter-kit}"
ARGS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --version) VERSION="${2:?error: --version needs a value}" ; shift 2 ;;
    --version=*) VERSION="${1#--version=}" ; shift ;;
    *) ARGS+=("$1") ; shift ;;
  esac
done

case "${ARGS[0]:-}" in
  install|uninstall|doctor|list|clean-project|models|loop) ;;
  *) ARGS=(install "${ARGS[@]+"${ARGS[@]}"}") ;;
esac

for cmd in curl tar python3; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "error: $cmd is required but not on PATH" >&2; exit 1; }
done

tarball_url_for() {
  case "$1" in
    main|master) echo "https://codeload.github.com/$REPO/tar.gz/$1" ;;
    *) echo "https://codeload.github.com/$REPO/tar.gz/refs/tags/$1" ;;
  esac
}

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
TARBALL="${KIT_TARBALL_URL:-$(tarball_url_for "$VERSION")}"

echo "kit: $REPO@$VERSION"
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

DEST="$STATE/versions/$VERSION"
rm -rf "$DEST"
mkdir -p "$DEST"
tar -xzf "$WORK/kit.tgz" -C "$DEST" --strip-components=1
if [ ! -f "$DEST/scripts/kit.py" ]; then
  echo "error: kit archive has no scripts/kit.py; refusing to continue" >&2
  exit 1
fi
ln -sfn "$DEST" "$STATE/current"

mkdir -p "$STATE/bin"
cat > "$STATE/bin/kit" <<LAUNCHER
#!/usr/bin/env bash
exec python3 "$STATE/current/scripts/kit.py" "\$@"
LAUNCHER
chmod +x "$STATE/bin/kit"

python3 "$STATE/current/scripts/kit.py" "${ARGS[@]}"

case ":$PATH:" in
  *":$STATE/bin:"*) ;;
  *) echo "tip: add $STATE/bin to your PATH to run \`kit doctor\` and \`kit uninstall\` directly." ;;
esac
