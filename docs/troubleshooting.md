# Troubleshooting

## Check Host State

Run:

```bash
./setup.sh doctor
```

`doctor` checks core host tools, Brewfile package state, common harness tools, and whether core dotfiles are linked into `$HOME`.

## Validate the Repository

Run:

```bash
./setup.sh check
```

This is safe to run repeatedly. It does not install packages or modify user config.

## Preview Setup Changes

Use dry-run mode before applying setup commands:

```bash
./setup.sh --dry-run
./setup.sh --dry-run --skip keyboard
./setup.sh --dry-run languages tool-packages
```

## Avoid Keyboard or macOS Defaults

Keyboard defaults and broader macOS defaults are separate commands:

```bash
./setup.sh --skip keyboard --yes
./setup.sh --skip macos --yes
```

## Recreate Symlinks

Run:

```bash
./setup.sh links
```

Existing files are backed up only when their content differs from the tracked dotfiles version.
