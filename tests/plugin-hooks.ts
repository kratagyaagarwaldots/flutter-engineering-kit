// Functional test for opencode/plugins/flutter-kit.ts. Run directly, or through
// `scripts/validate-kit.py` check 17:
//
//   node --experimental-strip-types tests/plugin-hooks.ts
//
// Why this exists: check 13 greps the plugin for the right tool ids, which cannot
// tell whether the hooks actually fire. The ids are the whole game here, and they
// are easy to get wrong from a distance:
//
//   - The shell tool's id is `bash`. Its source file is `tool/shell.ts` and the
//     registry binds it as `tool.shell`, but `tool/shell/id.ts` says
//     `export const ToolID = "bash"`, with a comment keeping it that way for
//     plugin compatibility until opencode 2.0. The filename is not the id.
//   - The patch tool's id is `apply_patch`. The registry binds it as `tool.patch`,
//     but `tool/apply_patch.ts` says `Tool.define("apply_patch", ...)`, and the
//     tools doc says to check `apply_patch`, not `patch`.
//
// So this asserts the hooks fire on the ids opencode really sends, AND that they do
// not fire on the plausible-looking wrong ones. If opencode 2.0 does the rename,
// the wrong-id assertions below are what should fail first and tell you to update
// the plugin deliberately, rather than the hooks going quiet in production.

import plugin from "../opencode/plugins/flutter-kit.ts";
import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";

const SECRET = "const k = 'sk_live_0123456789abcdefghij';";

let pass = 0;
const failures: string[] = [];

function check(name: string, ok: boolean, detail = ""): void {
  if (ok) {
    pass++;
    console.log(`  PASS  ${name}`);
  } else {
    failures.push(name + (detail ? ` — ${detail}` : ""));
    console.log(`  FAIL  ${name}${detail ? ` — ${detail}` : ""}`);
  }
}

// A throwaway Flutter project carrying fixture-mode artefacts: one feature whose
// README says so, and two dangling markers in a dart file.
function makeProject(withFixtures: boolean): string {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "kit-plugin-"));
  fs.writeFileSync(path.join(root, "pubspec.yaml"), "name: fixture_app\n");
  const feature = path.join(root, "lib", "features", "cart");
  fs.mkdirSync(feature, { recursive: true });
  if (withFixtures) {
    fs.writeFileSync(
      path.join(feature, "cart_repo.dart"),
      "// FIXTURE_START\nclass CartRepo {}\n// FIXTURE_END\n",
    );
    fs.writeFileSync(path.join(feature, "README.md"), "This feature is in fixture mode.\n");
  } else {
    fs.writeFileSync(path.join(feature, "cart_repo.dart"), "class CartRepo {}\n");
    fs.writeFileSync(path.join(feature, "README.md"), "A normal feature.\n");
  }
  return root;
}

async function hooksFor(directory: string) {
  const client = { app: { log: async () => {} } };
  const mod: any = await (plugin as any)({ client, directory });
  const before = mod["tool.execute.before"];
  if (typeof before !== "function") throw new Error("plugin exposes no tool.execute.before hook");
  return before;
}

// Returns the error thrown by the hook, or null when it allowed the call.
async function attempt(
  before: any,
  tool: string,
  args: Record<string, unknown>,
): Promise<Error | null> {
  try {
    await before({ tool }, { args });
    return null;
  } catch (e) {
    return e as Error;
  }
}

const dirty = makeProject(true);
const clean = makeProject(false);

try {
  const before = await hooksFor(dirty);

  // --- Fixture heads-up, on the id opencode actually sends -------------------
  {
    const output = { args: { command: "git commit -m 'wip'" } };
    await before({ tool: "bash" }, output);
    const cmd = output.args.command;
    check("bash + git commit gets a fixture heads-up", cmd !== "git commit -m 'wip'");
    check("heads-up names the fixture feature", cmd.includes("cart"));
    check("heads-up counts the dangling markers", /2 FIXTURE_START\/FIXTURE_END marker/.test(cmd));
    check("original git command still runs", cmd.includes("git commit -m 'wip'"));
  }
  {
    const output = { args: { command: "git push origin main" } };
    await before({ tool: "bash" }, output);
    check("bash + git push gets a heads-up", output.args.command !== "git push origin main");
  }

  // --- The hook stays out of the way ----------------------------------------
  for (const cmd of ["git status", "git log --oneline", "git diff", "flutter test"]) {
    const output = { args: { command: cmd } };
    await before({ tool: "bash" }, output);
    check(`non-committing command untouched: ${cmd}`, output.args.command === cmd);
  }

  // --- Wrong-but-plausible tool id: must NOT be treated as the shell tool ----
  // `shell` is the filename and the registry variable, never the id (shell/id.ts).
  {
    const output = { args: { command: "git commit -m 'wip'" } };
    await before({ tool: "shell" }, output);
    check(
      'the non-id "shell" is not matched (shell/id.ts keeps ToolID = "bash")',
      output.args.command === "git commit -m 'wip'",
    );
  }

  // --- Secret refusal, across every real write id ---------------------------
  check("write refuses a secret", (await attempt(before, "write", { content: SECRET })) !== null);
  check("edit refuses a secret", (await attempt(before, "edit", { newString: SECRET })) !== null);
  check(
    "apply_patch refuses a secret on an added line",
    (await attempt(before, "apply_patch", { patchText: "+" + SECRET })) !== null,
  );
  {
    const err = await attempt(before, "write", { content: SECRET });
    check(
      "refusal explains the alternative",
      !!err && /dart-define|flutter_secure_storage/.test(err.message),
    );
  }

  // --- Wrong-but-plausible tool id: `patch` is the registry variable, not the
  // id (`Tool.define("apply_patch", ...)`), so the plugin spends no match on it.
  check(
    'the non-id "patch" is not matched (apply_patch.ts defines "apply_patch")',
    (await attempt(before, "patch", { patchText: "+" + SECRET })) === null,
  );

  // --- Removing a secret is never blocked by the secret it removes ----------
  check(
    "removing a secret is allowed",
    (await attempt(before, "edit", { oldString: SECRET, newString: "const k = env;" })) === null,
  );
  check(
    "a patch that only deletes a secret is allowed",
    (await attempt(before, "apply_patch", { patchText: "-" + SECRET })) === null,
  );

  // --- Clean writes pass -----------------------------------------------------
  check(
    "clean write allowed",
    (await attempt(before, "write", { content: "class Foo {}" })) === null,
  );
  check(
    "unrelated tool untouched",
    (await attempt(before, "read", { filePath: "lib/main.dart" })) === null,
  );

  // --- Fails open: a repo with nothing to report, and a non-project dir ------
  {
    const cleanHook = await hooksFor(clean);
    const output = { args: { command: "git commit -m 'ok'" } };
    await cleanHook({ tool: "bash" }, output);
    check("no heads-up when there are no fixtures", output.args.command === "git commit -m 'ok'");
  }
  {
    const nowhere = fs.mkdtempSync(path.join(os.tmpdir(), "kit-nolib-"));
    const strayHook = await hooksFor(nowhere);
    const output = { args: { command: "git commit -m 'ok'" } };
    await strayHook({ tool: "bash" }, output);
    check("fixture scan fails open outside a Flutter project", output.args.command === "git commit -m 'ok'");
    fs.rmSync(nowhere, { recursive: true, force: true });
  }
} finally {
  fs.rmSync(dirty, { recursive: true, force: true });
  fs.rmSync(clean, { recursive: true, force: true });
}

console.log(`\n${pass} passed, ${failures.length} failed`);
process.exit(failures.length ? 1 : 0);
