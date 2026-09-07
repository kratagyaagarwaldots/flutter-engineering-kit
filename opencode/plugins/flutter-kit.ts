import type { Plugin } from "@opencode-ai/plugin";
import * as fs from "node:fs";
import * as path from "node:path";

/**
 * flutter-engineering-kit hooks for opencode.
 *
 * Source of truth: this file. `scripts/sync-opencode.sh` copies it into a
 * Flutter project's `.opencode/plugins/`; never hand-edit the copy.
 *
 * Parity with the kit's Claude hooks (`hooks/`):
 * - `dart-format.sh` (PostToolUse on Edit|Write) → NOT reimplemented here.
 *   opencode's built-in `dart` formatter covers it; the sync script merges
 *   `"formatter": true` into the project's `opencode.json`, which runs
 *   `dart format` on edited `.dart` files when `dart` is on PATH.
 * - `scan-fixtures.sh` (PreToolUse on Bash) → below: before a `git commit`
 *   or `git push`, scan `lib/` for fixture-mode artefacts and surface a
 *   heads-up in the tool output. Never blocks, never fails closed.
 *   The hook matches `input.tool === "bash"`: that is opencode's shell tool id
 *   (`packages/opencode/src/tool/shell/id.ts` keeps `ToolID = "bash"` for
 *   compatibility; the `shell.ts` filename and the registry's local variable
 *   name are not the id).
 * - `scan-secrets.sh` (UserPromptSubmit) → below, moved to the file-write
 *   boundary: opencode has no prompt-submit hook, so `edit` / `write` /
 *   `apply_patch` calls whose *new* content looks like an API key, token,
 *   or JWT are refused with an error. That third id is literal too
 *   (`Tool.define("apply_patch", ...)` in `apply_patch.ts`, and the tools doc
 *   says to check `apply_patch`, not `patch`). This enforces the kit's hard rule
 *   (no hard-coded secrets; use `--dart-define` or `flutter_secure_storage`)
 *   at the point the secret would enter source.
 *
 * Everything here fails open except the secrets refusal: any unexpected
 * error in the fixture scan is swallowed so the tool still runs.
 */

// Same shapes as hooks/scan-secrets.sh: Stripe keys, AWS access keys,
// GitHub PATs, JWTs, and bearer tokens.
const SECRET_RE =
  /sk_(live|test)_[A-Za-z0-9]{16,}|AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{20,}|eyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}|Bearer\s+[A-Za-z0-9_\-.=]{20,}/;

// Walk up from the session directory to the Flutter project root.
function findProjectRoot(startDir: string): string {
  let dir = path.resolve(startDir);
  for (;;) {
    try {
      if (fs.existsSync(path.join(dir, "pubspec.yaml"))) return dir;
    } catch {
      return startDir;
    }
    const parent = path.dirname(dir);
    if (parent === dir) return startDir;
    dir = parent;
  }
}

function listDartFiles(root: string, out: string[], budget: { n: number }): void {
  if (budget.n <= 0) return;
  let entries: fs.Dirent[];
  try {
    entries = fs.readdirSync(root, { withFileTypes: true });
  } catch {
    return;
  }
  for (const e of entries) {
    if (budget.n <= 0) return;
    if (e.name.startsWith(".")) continue;
    const full = path.join(root, e.name);
    if (e.isDirectory()) {
      if (e.name === "build" || e.name === ".dart_tool") continue;
      listDartFiles(full, out, budget);
    } else if (e.isFile() && e.name.endsWith(".dart")) {
      out.push(full);
      budget.n -= 1;
    }
  }
}

// Mirror of scan-fixtures.sh: features whose README still says
// "fixture mode", plus dangling FIXTURE_START / FIXTURE_END markers.
function fixtureHeadsUp(projectRoot: string): string | null {
  const featuresDir = path.join(projectRoot, "lib", "features");
  const libDir = path.join(projectRoot, "lib");
  if (!fs.existsSync(libDir)) return null;

  const fixtureFeatures: string[] = [];
  try {
    for (const feature of fs.readdirSync(featuresDir)) {
      const readme = path.join(featuresDir, feature, "README.md");
      try {
        if (fs.readFileSync(readme, "utf8").includes("fixture mode")) {
          fixtureFeatures.push(feature);
        }
      } catch {
        // No README for this feature; nothing to report.
      }
    }
  } catch {
    // No lib/features yet (greenfield); fall through to the marker count.
  }

  let markerCount = 0;
  const dartFiles: string[] = [];
  listDartFiles(libDir, dartFiles, { n: 2000 });
  for (const f of dartFiles) {
    try {
      const text = fs.readFileSync(f, "utf8");
      const m = text.match(/FIXTURE_(START|END)/g);
      if (m) markerCount += m.length;
    } catch {
      // Unreadable file; skip it.
    }
  }

  if (fixtureFeatures.length === 0 && markerCount === 0) return null;

  let message = "Heads up: this repo still has fixture-mode artefacts.";
  if (fixtureFeatures.length > 0) {
    message += ` Features in fixture mode: ${fixtureFeatures.join(",")}.`;
  }
  if (markerCount > 0) {
    message += ` ${markerCount} FIXTURE_START/FIXTURE_END marker(s) remain in lib/.`;
  }
  message +=
    " If shipping fixtures is intentional, proceed - otherwise upgrade via flutter-create-feature-e2e first.";
  return message;
}

// What the tool call is about to write. For `edit`, only the *new* text is
// checked, so removing a secret is never blocked by the secret it removes.
// For `apply_patch`, only added (`+`) lines are checked for the same reason.
function newContent(args: Record<string, unknown>): string {
  const texts: string[] = [];
  for (const key of ["content", "text", "newString", "newText", "input"]) {
    const v = args[key];
    if (typeof v === "string") texts.push(v);
  }
  const patch = args["patchText"];
  if (typeof patch === "string") {
    texts.push(
      patch
        .split("\n")
        .filter((line) => line.startsWith("+") && !line.startsWith("+++"))
        .join("\n"),
    );
  }
  const diff = args["patch"];
  if (typeof diff === "string") texts.push(diff);
  if (texts.length > 0) return texts.join("\n");
  // Unknown shape: fall back to the whole args blob, minus the old text an
  // edit is replacing, so a removal cannot trip the check.
  const rest: Record<string, unknown> = { ...args };
  delete rest["oldString"];
  delete rest["oldText"];
  try {
    return JSON.stringify(rest);
  } catch {
    return "";
  }
}

export default (async ({ client, directory }) => {
  return {
    "tool.execute.before": async (input: any, output: any) => {
      const tool = input?.tool as string | undefined;
      const args = (output?.args ?? {}) as Record<string, unknown>;

      // The shell tool's registry id is `bash` (see the header comment);
      // `shell` is only its filename. Match the id.
      if (tool === "bash") {
        const command = String(args["command"] ?? "");
        // Only act on commit / push, not status / log / diff.
        if (/git\s+(commit|push)/.test(command)) {
          try {
            const message = fixtureHeadsUp(findProjectRoot(directory));
            if (message) {
              try {
                await client.app.log({
                  body: {
                    service: "flutter-kit",
                    level: "warn",
                    message,
                  },
                });
              } catch {
                // Logging must never break the tool call.
              }
              // Surface the heads-up where the agent will see it: stderr of
              // this same invocation. The git command itself runs unchanged.
              const escaped = message.replace(/'/g, `'\\''`);
              output.args["command"] = `echo '${escaped}' >&2; ${command}`;
            }
          } catch {
            // Fail open: a broken scan never blocks a commit.
          }
        }
        return;
      }

      // File-write tools: `edit`, `write`, `apply_patch`. All three ids are
      // literal (see the header comment); there is no `patch` tool.
      if (tool === "edit" || tool === "write" || tool === "apply_patch") {
        if (SECRET_RE.test(newContent(args))) {
          throw new Error(
            "Refusing to write a likely secret (API key / token / JWT). " +
              "Strip secrets out of source and use --dart-define or " +
              "flutter_secure_storage instead.",
          );
        }
      }
    },
  };
}) satisfies Plugin;
