# Local Overrides

Keep machine-specific or sensitive values outside tracked files.

## Git Identity

The tracked `home/dot_gitconfig` source applies `~/.gitconfig`, which supports a local override file:

```bash
cp docs/gitconfig.override.example ~/.gitconfig.override
```

Then edit `~/.gitconfig.override`:

```ini
[user]
    name = Your Name
    email = your.email@example.com
```

## Git Ignore Overrides

Keep project-specific, client-specific, or sensitive ignore patterns out of the tracked `~/.gitignore_global`.

Git supports one effective `core.excludesfile`, so use the local gitconfig override to point Git at a private ignore file:

```bash
cp ~/.gitignore_global ~/.gitignore_global.local
git config --file ~/.gitconfig.override core.excludesfile ~/.gitignore_global.local
```

Then add private ignore patterns only to `~/.gitignore_global.local`.

## Shell Overrides

Create `~/.zshrc.local` for work proxies, machine-specific paths, or private environment variables:

```bash
export SOME_WORK_VAR=value
```

`.zshrc` sources this file automatically when it exists.

`./setup.sh codex` also configures Firecrawl MCP to source `~/.zshrc.local` before launching, so keep the API key there instead of tracked Codex config:

```bash
export FIRECRAWL_API_KEY=your-api-key
```

`./setup.sh bootstrap` preserves existing `~/.zprofile` content and maintains only the marked `dotfiles runtime environment` block used for login-shell Homebrew and mise activation.

## macOS Shortcut Scripts

Put machine-specific macOS shortcut behavior in ignored project-local files:

```text
local/macos-shortcuts/1.sh
local/macos-shortcuts/2.sh
local/macos-shortcuts/5.sh
local/macos-shortcuts/6.sh
local/macos-shortcuts/7.sh
```

Run `./setup.sh macos-shortcuts` once. Setup symlinks those paths into
`~/.local/share/dotfiles/macos-shortcuts/`, so editing an ignored script changes
the next matching shortcut run.

## Secrets and OAuth Files

Do not track OAuth tokens or generated app secrets. In particular:

- `.config/gh/hosts.yml` is intentionally untracked.
- GitHub Copilot app tokens are intentionally ignored.
- Context7 can use `CONTEXT7_API_KEY` from the environment instead of committed config.
