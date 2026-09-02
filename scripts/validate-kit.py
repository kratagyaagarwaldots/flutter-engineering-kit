#!/usr/bin/env python3
"""Check the kit's invariants. Run from the repo root; exits non-zero on any failure.

These are the rules CLAUDE.md states, encoded so they fail a check instead of relying on
memory. Add a rule here whenever you catch yourself writing one down twice.
"""

import json
import pathlib
import re
import sys

FAIL: list[str] = []
ROOT = pathlib.Path(__file__).resolve().parent.parent


def check(label: str, ok_msg: str) -> None:
    print(f"{label:<4} {ok_msg}")


def main() -> int:
    skills: dict[str, bool] = {}  # name -> is_user_invoked
    descs: dict[str, str] = {}  # name -> frontmatter description

    # 1. Frontmatter is valid and name matches the directory.
    for p in sorted((ROOT / "skills").glob("*/SKILL.md")):
        m = re.match(r"^---\n(.*?)\n---\n", p.read_text(), re.S)
        if not m:
            FAIL.append(f"no frontmatter: {p.relative_to(ROOT)}")
            continue
        block = m.group(1)
        name_m = re.search(r"^name:\s*(.+)$", block, re.M)
        desc_m = re.search(r"^description:\s*(.+)$", block, re.M)
        if not name_m:
            FAIL.append(f"no name: {p.relative_to(ROOT)}")
            continue
        if not desc_m:
            FAIL.append(f"no description: {p.relative_to(ROOT)}")
        name = name_m.group(1).strip()
        if name != p.parent.name:
            FAIL.append(f"name/dir mismatch: '{name}' in {p.parent.name}/")
        skills[name] = "disable-model-invocation: true" in block
        if desc_m:
            descs[name] = desc_m.group(1).strip()
    check("1.", f"{len(skills)} skills, frontmatter valid, names match directories")

    # 2. plugin.json registers exactly the skills that exist.
    manifest = json.loads((ROOT / ".claude-plugin/plugin.json").read_text())
    registered = {r.rsplit("/", 1)[-1] for r in manifest["skills"]}
    for orphan in sorted(registered - set(skills)):
        FAIL.append(f"registered but missing on disk: {orphan}")
    for unreg in sorted(set(skills) - registered):
        FAIL.append(f"on disk but not in plugin.json: {unreg}")
    check("2.", f"plugin.json registers all {len(registered)} skills, no orphans")

    # 3. Every Skill-tool call resolves, and never targets a user-invoked skill.
    #    Only backticked names count as call sites; prose like "with its name" does not.
    calls = 0
    for p in (ROOT / "skills").glob("*/SKILL.md"):
        for m in re.finditer(r"Skill tool with\s*`([a-z][a-z0-9-]+)`", p.read_text()):
            target, calls = m.group(1), calls + 1
            if target not in skills:
                FAIL.append(f"{p.parent.name} calls unknown skill '{target}'")
            elif skills[target]:
                FAIL.append(f"{p.parent.name} calls user-invoked '{target}' (unreachable)")
    check("3.", f"{calls} Skill-tool call sites, all resolve to model-invoked skills")

    # 4. A cross-skill file link is allowed only when the owner is user-invoked,
    #    since nothing can call one. See CLAUDE.md.
    for p in (ROOT / "skills").glob("*/*.md"):
        for m in re.finditer(r"\]\(\.\./([a-z][a-z0-9-]+)/", p.read_text()):
            owner = m.group(1)
            if owner not in skills:
                FAIL.append(f"{p.parent.name} links to unknown skill dir '{owner}'")
            elif not skills[owner]:
                FAIL.append(
                    f"{p.parent.name} links across to model-invoked '{owner}' — call it instead"
                )
    check("4.", "cross-skill links only target user-invoked (uncallable) skills")

    # 5. The router names every user-invoked skill, or it lies.
    router = (ROOT / "skills/ask-kit/SKILL.md").read_text()
    for name, is_user in skills.items():
        if is_user and name != "ask-kit" and name not in router:
            FAIL.append(f"ask-kit omits user-invoked skill '{name}'")
    check("5.", f"router covers all {sum(skills.values())} user-invoked skills")

    # 6. No unresolved lowercase template tokens leaked out of template/ into skills.
    #    {{API_KEY}} style uppercase tokens are a deliberate convention, not a leak.
    for p in (ROOT / "skills").rglob("*.md"):
        for m in re.finditer(r"\{\{([a-z][a-z0-9_]*)\}\}", p.read_text()):
            FAIL.append(f"unresolved template token {{{{{m.group(1)}}}}} in {p.relative_to(ROOT)}")
    check("6.", "no unresolved lowercase template tokens in skills")

    # 7. Every agent referenced by a skill actually exists.
    agents = {p.stem for p in (ROOT / "agents").glob("*.md")} - {"README"}
    for p in (ROOT / "skills").glob("*/SKILL.md"):
        for m in re.finditer(r"`(flutter-(?:explore|architect|[a-z]+-engineer))`", p.read_text()):
            if m.group(1) not in agents:
                FAIL.append(f"{p.parent.name} references missing agent '{m.group(1)}'")
    check("7.", f"{len(agents)} agents, all skill references resolve")

    # 8. No client or project name leaks into a portable skill. The kit is written *from*
    #    real projects but must never refer to one.
    #    The terms are themselves client data, so they live in .kit-private/, which is
    #    gitignored and never published. A checkout without that directory configures zero
    #    terms and the check passes: this guards a private working copy on its way out, and
    #    the public repo has nothing to guard.
    PRIVATE = ROOT / ".kit-private"

    def private_terms(filename):
        f = PRIVATE / filename
        if not f.exists():
            return []
        return [ln.strip() for ln in f.read_text().splitlines()
                if ln.strip() and not ln.lstrip().startswith("#")]

    CLIENT_NAMES = [t.lower() for t in private_terms("client-names.txt")]
    for p in list((ROOT / "skills").rglob("*.md")) + list((ROOT / "agents").glob("*.md")) + \
             list((ROOT / "rules").glob("*.md")) + list((ROOT / "template").rglob("*.md")):
        low = p.read_text().lower()
        for nm in CLIENT_NAMES:
            if nm in low:
                FAIL.append(f"client name '{nm}' leaked into {p.relative_to(ROOT)}")
    # Project-specific symbols leak more quietly than the name: a component or feature class
    # that exists in one app but is not part of what the kit scaffolds. Same storage, same
    # reason, matched case-sensitively because these are Dart identifiers.
    PROJECT_SYMBOLS = private_terms("project-symbols.txt")
    for p in list((ROOT / "skills").rglob("*.md")) + list((ROOT / "rules").glob("*.md")) + \
             list((ROOT / "template").rglob("*.md")):
        text = p.read_text()
        for sym in PROJECT_SYMBOLS:
            if sym in text:
                FAIL.append(f"project-specific symbol '{sym}' in {p.relative_to(ROOT)}")
    configured = f"{len(CLIENT_NAMES)} names, {len(PROJECT_SYMBOLS)} symbols" \
        if (CLIENT_NAMES or PROJECT_SYMBOLS) else "no terms configured; see .kit-private/"
    check("8.", f"no client name or project-symbol leakage ({configured})")

    # 9. The README Reference lists every skill, links to its SKILL.md, and describes it in the
    #    skill's own words. The description is the frontmatter one with the trailing model-trigger
    #    sentence ("Use when ...", "Read before ...") cut, so a human reads prose and there is
    #    still one source of truth. Bullets may wrap, so compare on normalised whitespace.
    readme = (ROOT / "README.md").read_text()
    bullets: dict[str, tuple[str, str]] = {}  # name -> (link target, description)
    for m in re.finditer(
        r"^- \*\*\[([a-z][a-z0-9-]+)\]\(([^)]+)\)\*\*:\s*(.+?)(?=\n- |\n\n|\n#|\Z)",
        readme, re.S | re.M,
    ):
        bullets[m.group(1)] = (m.group(2), " ".join(m.group(3).split()))

    for stray in sorted(set(bullets) - set(skills)):
        FAIL.append(f"README references unknown skill '{stray}'")
    for name in sorted(skills):
        if name not in bullets:
            FAIL.append(f"README Reference omits skill '{name}'")
            continue
        link, desc = bullets[name]
        want_link = f"./skills/{name}/SKILL.md"
        if link != want_link: 
            FAIL.append(f"README links '{name}' to '{link}', expected '{want_link}'")
        want = re.split(r"\s+(?:Use|Read)\s+(?:when|before|after)\b", descs.get(name, ""))[0]
        want = " ".join(want.split()).rstrip()
        if desc.rstrip() != want:
            FAIL.append(
                f"README description for '{name}' does not match its frontmatter\n"
                f"      README: {desc}\n"
                f"      SKILL:  {want}"
            )
    check("9.", f"README Reference links and describes all {len(skills)} skills, matching frontmatter")

    # 10. Stack purity. A skill that names a state-management library generates code in that
    #     library's shape, which is wrong on a project using another one. The kit resolves the
    #     stack through `project-conventions` instead, and per-stack code lives in a skill's
    #     templates/ directory where naming a library is the whole point.
    #
    #     STACK_OPINIONATED is the set that predates that rule. It is a ratchet: remove a name
    #     when that skill is restructured, never add one. A new skill needing per-stack code gets
    #     a templates/ directory.
    STACK_TOKENS = re.compile(
        r"flutter_bloc|BlocProvider|BlocBuilder|BlocListener|BlocConsumer|blocTest|bloc_test"
    )
    STACK_OPINIONATED = {
        "flutter-create-feature-e2e", "flutter-create-screen-e2e",
        "setup-flutter-project",
    }
    # A detector has to name what it detects, which is the opposite of generating in its shape.
    STACK_DETECTORS = {"project-conventions"}
    exempt = STACK_OPINIONATED | STACK_DETECTORS
    for stale in sorted(exempt - set(skills)):
        FAIL.append(f"stack exemption names missing skill '{stale}' — drop it from the list")
    for p in sorted((ROOT / "skills").rglob("*.md")):
        if p.parent.name == "templates":
            continue
        owner = p.relative_to(ROOT / "skills").parts[0]
        if owner in exempt:
            continue
        for lineno, line in enumerate(p.read_text().splitlines(), 1):
            # A row routing to a per-stack template may name the stack it routes to;
            # that is the resolver pattern working, not a leak.
            if "templates/" in line:
                continue
            if STACK_TOKENS.search(line):
                FAIL.append(
                    f"{p.relative_to(ROOT)}:{lineno} names a state library — resolve it "
                    f"through `project-conventions`, or move the code into {owner}/templates/"
                )
    check("10.", f"stack-neutral skills name no state library "
                 f"({len(STACK_OPINIONATED)} legacy skills exempt)")

    print()
    if FAIL:
        print(f"{len(FAIL)} FAILURE(S):")
        for f in FAIL:
            print(f"  - {f}")
        return 1
    print("All invariants hold.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
