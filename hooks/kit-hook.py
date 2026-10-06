#!/usr/bin/env python3
"""The kit's hooks, for every harness that runs command hooks.

    kit-hook.py <harness> <check>

harness: claude | codex | cursor | antigravity
check:   secrets  — block a prompt that pastes a likely API key, token or JWT
         fixtures — before `git commit` / `git push`, warn if fixture-mode code remains
         format   — run `dart format` on an edited .dart file

Each harness sends a different stdin payload and reads a different reply, so this file
normalises the input, runs the check once, and answers in that harness's own shape.
opencode runs plugins instead of command hooks: its equivalent is
opencode/plugins/flutter-kit.ts.

Every check fails open: a missing tool, an unreadable payload or any error lets the action
through, because a broken guard must never stop work.
"""

import json
import os
import pathlib
import re
import shutil
import subprocess
import sys

SECRET_RE = re.compile(
    r"sk_(live|test)_[A-Za-z0-9]{16,}|AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{20,}"
    r"|eyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}"
    r"|Bearer\s+[A-Za-z0-9_\-.=]{20,}"
)
SECRET_REASON = (
    "Prompt appears to contain a secret (API key / token / JWT). Strip secrets out of "
    "source and use --dart-define or flutter_secure_storage instead."
)
# Codex's apply_patch names each touched file on a header line.
PATCH_FILE_RE = re.compile(r"^\*\*\* (?:Add|Update) File: (.+)$", re.M)


def payload() -> dict:
    try:
        data = json.loads(sys.stdin.read() or "{}")
        return data if isinstance(data, dict) else {}
    except (json.JSONDecodeError, OSError):
        return {}


def prompt_text(harness: str, p: dict) -> str:
    return str(p.get("prompt") or "")


def shell_command(harness: str, p: dict) -> str:
    if harness == "cursor":
        return str(p.get("command") or "")
    if harness == "antigravity":
        return str(((p.get("toolCall") or {}).get("args") or {}).get("CommandLine") or "")
    return str((p.get("tool_input") or {}).get("command") or "")


def edited_files(harness: str, p: dict) -> list[str]:
    if harness == "cursor":
        return [str(p["file_path"])] if p.get("file_path") else []
    if harness == "antigravity":
        target = ((p.get("toolCall") or {}).get("args") or {}).get("TargetFile")
        return [str(target)] if target else []
    tool_input = p.get("tool_input") or {}
    if tool_input.get("file_path"):
        return [str(tool_input["file_path"])]
    # Codex apply_patch carries the patch text, not a path.
    return PATCH_FILE_RE.findall(str(tool_input.get("command") or tool_input.get("input") or ""))


def project_dir(p: dict) -> pathlib.Path:
    cwd = p.get("cwd") or ((p.get("toolCall") or {}).get("args") or {}).get("Cwd")
    start = pathlib.Path(cwd or os.getcwd()).resolve()
    for d in (start, *start.parents):
        if (d / "pubspec.yaml").is_file():
            return d
    return start


def fixture_heads_up(root: pathlib.Path) -> str:
    lib = root / "lib"
    if not lib.is_dir():
        return ""
    features = []
    for readme in sorted((lib / "features").glob("*/README.md")):
        try:
            if "fixture mode" in readme.read_text(errors="ignore"):
                features.append(readme.parent.name)
        except OSError:
            pass
    markers = 0
    for i, dart in enumerate(lib.rglob("*.dart")):
        if i >= 2000:
            break
        try:
            markers += len(re.findall(r"FIXTURE_(?:START|END)", dart.read_text(errors="ignore")))
        except OSError:
            pass
    if not features and not markers:
        return ""
    msg = "Heads up: this repo still has fixture-mode artefacts."
    if features:
        msg += f" Features in fixture mode: {','.join(features)}."
    if markers:
        msg += f" {markers} FIXTURE_START/FIXTURE_END marker(s) remain in lib/."
    return msg + (" If shipping fixtures is intentional, proceed - otherwise upgrade via "
                  "flutter-create-feature-e2e first.")


def reply(obj: dict) -> None:
    print(json.dumps(obj))


def check_secrets(harness: str, p: dict) -> None:
    if not SECRET_RE.search(prompt_text(harness, p)):
        return
    if harness == "cursor":
        reply({"continue": False, "user_message": SECRET_REASON})
    else:  # claude, codex
        reply({"decision": "block", "reason": SECRET_REASON})


def check_fixtures(harness: str, p: dict) -> None:
    if not re.search(r"git\s+(commit|push)", shell_command(harness, p)):
        return
    msg = fixture_heads_up(project_dir(p))
    if not msg:
        return
    if harness == "cursor":
        reply({"permission": "allow", "agent_message": msg})
    elif harness == "antigravity":
        reply({"decision": "allow", "reason": msg})
    else:  # claude, codex
        reply({"hookSpecificOutput": {"hookEventName": "PreToolUse", "additionalContext": msg}})


def check_format(harness: str, p: dict) -> None:
    dart = shutil.which("dart")
    if not dart:
        return
    root = project_dir(p)
    for f in edited_files(harness, p):
        path = pathlib.Path(f)
        if not path.is_absolute():
            path = root / path
        if path.suffix == ".dart" and path.is_file():
            subprocess.run([dart, "format", str(path)], capture_output=True, timeout=60)
    if harness == "antigravity":
        reply({})


CHECKS = {"secrets": check_secrets, "fixtures": check_fixtures, "format": check_format}


def main() -> int:
    if len(sys.argv) != 3 or sys.argv[2] not in CHECKS:
        return 0
    try:
        CHECKS[sys.argv[2]](sys.argv[1], payload())
    except Exception:  # noqa: BLE001 — fail open, always
        pass
    return 0


if __name__ == "__main__":
    sys.exit(main())
