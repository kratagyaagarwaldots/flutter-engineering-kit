# Installing the Flutter Engineering Kit

You are an agent installing this kit for the user. It installs once per user, never into a
project folder, and works with Claude Code, Codex, opencode, Antigravity and Cursor in any
combination.

## 1. Find out which harnesses to install for

Run the detector first, so the question you ask is about this machine rather than a guess:

```bash
curl -fsSL https://raw.githubusercontent.com/kratagyaagarwaldots/flutter-engineering-kit/main/install.sh | bash -s -- list
```

It prints each supported harness and marks the ones found. Ask the user which of them they want
the kit in, recommending the detected ones. The choice is theirs: a harness can be installed but
unused, and installing for it only adds files.

The step is done when you have a list of harness ids from `claude`, `codex`, `opencode`,
`antigravity`, `cursor`.

## 2. Install

```bash
curl -fsSL https://raw.githubusercontent.com/kratagyaagarwaldots/flutter-engineering-kit/main/install.sh | bash -s -- --for <ids, comma-separated>
```

For **Claude Code**, the kit is a managed plugin. When the `claude` command is on PATH the
installer adds it; otherwise it prints two `/plugin` commands. Tell the user to type those inside
Claude Code, since only they can run a slash command there.

The step is done when the installer's summary lists every chosen harness with no `failed` line.

## 3. Check it

```bash
~/.flutter-kit/bin/kit doctor
```

Report its result to the user as it stands. `all good` means every chosen harness sees all the
kit's skills once. A line starting with `!` is a problem to report, with the fix it names.

## 4. Tell the user what changed and what is next

- Restart each harness so it loads the new skills.
- In each Flutter project, run `/fk-setup` once. It records that project's stack, so
  every skill writes code the way the project already does.
- If a project still has a `.opencode/`, `.cursor/` or `.claude/` copy of the kit from an older
  version, `~/.flutter-kit/bin/kit clean-project <path>` removes the kit's files from it and keeps
  the project's own.

## Removing it

```bash
~/.flutter-kit/bin/kit uninstall              # every harness
~/.flutter-kit/bin/kit uninstall --for codex  # one harness
```

Uninstall removes exactly the files and config entries the install recorded. Settings the user
changed themselves stay.
