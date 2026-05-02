# Local Overrides

Keep machine-specific or sensitive values outside tracked files.

## Git Identity

The tracked `.gitconfig` supports a local override file:

```bash
cp ~/workspace/dotfiles/.gitconfig.override.example ~/.gitconfig.override
```

Then edit `~/.gitconfig.override`:

```ini
[user]
    name = Your Name
    email = your.email@example.com
```

## Shell Overrides

Create `~/.zshrc.local` for work proxies, machine-specific paths, or private environment variables:

```bash
export SOME_WORK_VAR=value
```

`.zshrc` sources this file automatically when it exists.

## Secrets and OAuth Files

Do not track OAuth tokens or generated app secrets. In particular:

- `.config/gh/hosts.yml` is intentionally untracked.
- GitHub Copilot app tokens are intentionally ignored.
- Context7 can use `CONTEXT7_API_KEY` from the environment instead of committed config.
