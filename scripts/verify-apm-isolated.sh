#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
apm_bin="${APM_BIN:-apm}"
sandbox="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-apm.XXXXXX")"
trap 'rm -rf "$sandbox"' EXIT

skill_digest() {
  (cd "$1" && find . -type f -print0 | sort -z | xargs -0 sha256sum | sha256sum | cut -d' ' -f1)
}

restore_skills() {
  local home="$1"
  mkdir -p "$home/.apm"
  cp "$root/apm-skills.yml" "$home/.apm/apm.yml"
  cp "$root/apm-skills.lock.yaml" "$home/.apm/apm.lock.yaml"
  HOME="$home" "$apm_bin" install --global --target agent-skills --only apm --frozen >/dev/null
  skill_digest "$home/.agents/skills"
}

render_mcp() {
  local project="$1/project"
  local output="$1/output"
  mkdir -p "$project" "$output"
  cp "$root/apm.yml" "$project/apm.yml"
  (cd "$project" && "$apm_bin" install --target codex --only mcp --root "$output" >/dev/null)
  sha256sum "$output/.codex/config.toml" | cut -d' ' -f1
}

skills_one="$(restore_skills "$sandbox/home-one")"
skills_two="$(restore_skills "$sandbox/home-two")"
test "$skills_one" = "$skills_two"

mcp_one="$(render_mcp "$sandbox/mcp-one")"
mcp_two="$(render_mcp "$sandbox/mcp-two")"
test "$mcp_one" = "$mcp_two"

printf 'isolated APM verification passed: skills=%s mcp=%s\n' "$skills_one" "$mcp_one"
