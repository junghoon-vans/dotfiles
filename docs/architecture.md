# Architecture Notes

This repository is a personal macOS development environment specification, not only a dotfiles collection.

## Responsibilities

| Layer | Owner | Purpose |
| --- | --- | --- |
| Dotfiles payload | Root dotfiles and `.config/**` | Shell, Git, editor, app, and agent configuration that is linked into `$HOME`. |
| Package inventory | `Brewfile` | Homebrew formulae, casks, fonts, and brew-owned setup inputs. |
| Runtime provisioning | `mise.toml`, `Brewfile`, and `setup/commands/20-brew-packages` | Desired language runtime versions and the setup step that installs them with mise. |
| Host bootstrap | `setup.sh` and `setup/` | First-run orchestration, language-specific tools, app setup, macOS defaults, and validation. |
| Verification | `./setup.sh doctor` and `./setup.sh check` | Host health checks and repository regression checks. |

## Design Direction

The repository keeps a monorepo layout because the environment is personal and the layers change together. Splitting dotfiles into a separate repository can wait until the dotfiles payload needs an independent release cycle or needs to be reused without the macOS workstation bootstrap.

The long-term direction is to keep using proven tools instead of replacing them:

- Homebrew owns macOS package and app installation.
- mise owns language runtime version intent and provisioning where practical.
- Shell scripts remain the pragmatic layer for macOS defaults, mise orchestration, and ecosystem-specific installers.
- The setup harness coordinates these tools and exposes predictable `dry-run`, `doctor`, and `check` commands.

## Runtime Model

Dotfiles are linked from this repository into `$HOME`. If the setup harness eventually becomes a Go binary, the binary should still materialize a real dotfiles store on disk before linking because symlinks must target filesystem paths, not embedded binary assets.

## Non-Goals

- Replacing Homebrew, mise, or dedicated dotfiles managers.
- Building a generic public dotfiles installer platform.
- Fully abstracting macOS defaults into a cross-platform configuration framework.
- Moving to Nix/nix-darwin before there is a clear payoff for the extra complexity.
