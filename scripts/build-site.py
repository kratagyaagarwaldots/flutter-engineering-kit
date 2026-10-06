#!/usr/bin/env python3
"""Build the GitHub Pages site from the kit itself.

Every fact on the page is read from its source, so the site cannot drift from the kit:
skills from their frontmatter, groups and the two workflow tracks from README.md, agents from
their frontmatter and agents/README.md, version and repo from .claude-plugin/plugin.json, and
per-harness install steps and support from install/harnesses.json (the registry the installer
reads too).

    python3 scripts/build-site.py            # writes _site/index.html
    python3 scripts/build-site.py --check    # builds in memory, fails on any missing source
"""

import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
OUT = ROOT / "_site"


def frontmatter(path: pathlib.Path) -> dict[str, str]:
    m = re.match(r"^---\n(.*?)\n---\n", path.read_text(), re.S)
    if not m:
        raise SystemExit(f"no frontmatter: {path.relative_to(ROOT)}")
    fields = {}
    for line in m.group(1).splitlines():
        k, sep, v = line.partition(":")
        if sep and not line.startswith(" "):
            fields[k.strip()] = v.strip().strip('"')
    return fields


def summary(description: str) -> str:
    """The description minus its trailing trigger sentence: the same cut check 9 makes."""
    return re.split(r"\s+(?:Use|Read)\s+(?:when|before|after)\b", description)[0].strip()


def readme_groups(readme: str) -> tuple[list[dict], dict[str, str]]:
    ref = readme.split("## Reference", 1)[1].split("\n## ", 1)[0]
    groups, owner = [], {}
    for block in re.split(r"\n### ", ref)[1:]:
        name, _, body = block.partition("\n")
        blurb = next((p.strip() for p in body.split("\n\n")
                      if p.strip() and not p.strip().startswith(("**", "- "))), "")
        # The page renders text, not Markdown: drop the code ticks and emphasis marks.
        blurb = re.sub(r"[`*]", "", " ".join(blurb.split()))
        groups.append({"name": name.strip(), "blurb": blurb})
        for m in re.finditer(r"^- \*\*\[([a-z][a-z0-9-]+)\]", body, re.M):
            owner[m.group(1)] = name.strip()
    return groups, owner


def readme_tracks(readme: str) -> dict[str, list[dict]]:
    def table(heading: str) -> list[dict]:
        section = readme.split(heading, 1)[1].split("\n### ", 1)[0].split("\n## ", 1)[0]
        rows = []
        for line in section.splitlines():
            cells = [c.strip() for c in line.strip().strip("|").split("|")]
            if len(cells) == 3 and cells[0].isdigit():
                rows.append({"step": cells[1], "skills": cells[2].replace("`", "")})
        if not rows:
            raise SystemExit(f"README section '{heading}' has no step table")
        return rows

    return {"eng": table("### The engineering loop"), "delivery": table("### Project delivery")}


def agents() -> list[dict]:
    owns = {}
    for line in (ROOT / "agents/README.md").read_text().splitlines():
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if len(cells) >= 2 and cells[0].startswith("`"):
            owns[cells[0].strip("`")] = cells[1].replace("`", "")
    out = []
    for p in sorted((ROOT / "agents").glob("*.md")):
        if p.stem == "README":
            continue
        fm = frontmatter(p)
        out.append({
            "name": fm["name"],
            "model": fm.get("model", "inherit"),
            "owns": owns.get(fm["name"]) or summary(fm["description"]).split(". ")[0],
        })
    return out


def build() -> str:
    readme = (ROOT / "README.md").read_text()
    plugin = json.loads((ROOT / ".claude-plugin/plugin.json").read_text())
    registry = json.loads((ROOT / "install/harnesses.json").read_text())
    groups, owner = readme_groups(readme)

    skills = []
    for p in sorted((ROOT / "skills").glob("*/SKILL.md")):
        fm = frontmatter(p)
        name = fm["name"]
        if name not in owner:
            raise SystemExit(f"skill '{name}' has no group in README's Reference")
        block = p.read_text().split("\n---\n", 1)[0]
        skills.append({
            "name": name,
            "user": "disable-model-invocation: true" in block,
            "group": owner[name],
            "description": fm["description"],
            "summary": summary(fm["description"]),
        })

    repo = plugin["repository"].removesuffix(".git")
    data = {
        "repo": repo,
        "skills": skills,
        "groups": groups,
        "tracks": readme_tracks(readme),
        "agents": agents(),
        "harnesses": registry["harnesses"],
        "tabs": [{
            "id": "agent", "name": "Ask your agent",
            "install": "# paste into Claude Code, Codex, opencode, Antigravity or Cursor\n"
                       "Install the Flutter Engineering Kit for me by following\n"
                       f"https://raw.githubusercontent.com/{registry['repo']}/main/INSTALL.md",
            "note": "Your agent detects which harnesses you have, asks which to install for, "
                    "installs, and runs kit doctor to check the result.",
        }] + [{k: h[k] for k in ("id", "name", "install", "note")} for h in registry["harnesses"]],
    }
    # `</` inside an inline script would end it early; JSON allows the escaped form.
    payload = json.dumps(data, ensure_ascii=False).replace("</", "<\\/")
    html = (ROOT / "site/template.html").read_text()
    html = (html.replace("{{DATA}}", payload)
                .replace("{{VERSION}}", plugin["version"])
                .replace("{{REPO_URL}}", repo)
                .replace("{{AUTHOR}}", plugin["author"]["name"]))
    leftover = re.findall(r"\{\{[A-Z_]+\}\}", html)
    if leftover:
        raise SystemExit(f"unfilled template tokens: {sorted(set(leftover))}")
    return html


def main() -> int:
    html = build()
    if "--check" in sys.argv:
        print("site builds")
        return 0
    OUT.mkdir(exist_ok=True)
    (OUT / "index.html").write_text(html)
    (OUT / ".nojekyll").write_text("")
    print(f"wrote {(OUT / 'index.html').relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
