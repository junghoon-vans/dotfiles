.DEFAULT_GOAL := help

SETUP := ./setup.sh

.PHONY: help show-targets setup setup-all dry-run doctor check clean clean-backups codex-mcp bootstrap brew-packages brew-bundle languages blockchain links apps codex codex-agents codex-skills karabiner macos-shortcuts macos go node bun java kotlin xml rust python typescript solana gno sui

help:
	@printf '%s\n' 'Usage: make <target> [ARGS="..."]'
	@printf '%s\n' ''
	@printf '%s\n' 'Common targets:'
	@printf '  %-18s %s\n' 'setup' 'Run full interactive setup'
	@printf '  %-18s %s\n' 'setup-all' 'Run full non-interactive setup'
	@printf '  %-18s %s\n' 'dry-run' 'Preview selected setup commands'
	@printf '  %-18s %s\n' 'doctor' 'Inspect host prerequisites'
	@printf '  %-18s %s\n' 'clean' 'Remove managed dotfile backups'
	@printf '  %-18s %s\n' 'show-targets' 'List every make target'
	@printf '%s\n' ''
	@printf '%s\n' 'Examples:'
	@printf '%s\n' '  make setup-all'
	@printf '%s\n' '  make setup-all ARGS="--skip karabiner"'
	@printf '%s\n' '  make dry-run ARGS="--skip macos"'

show-targets:
	@printf '%s\n' 'Core targets:'
	@printf '%s\n' '  help setup setup-all dry-run doctor check clean'
	@printf '%s\n' ''
	@printf '%s\n' 'Setup phase targets:'
	@printf '%s\n' '  bootstrap brew-packages languages blockchain links apps codex codex-agents codex-skills karabiner macos-shortcuts macos'
	@printf '%s\n' ''
	@printf '%s\n' 'Language targets:'
	@printf '%s\n' '  go node bun java kotlin xml rust python typescript'
	@printf '%s\n' ''
	@printf '%s\n' 'Blockchain targets:'
	@printf '%s\n' '  solana gno sui'
	@printf '%s\n' ''
	@printf '%s\n' 'Utility targets:'
	@printf '%s\n' '  codex-mcp clean-backups brew-bundle'

setup:
	$(SETUP) $(ARGS)

setup-all:
	$(SETUP) --yes $(ARGS)

dry-run:
	$(SETUP) --dry-run $(ARGS)

doctor:
	$(SETUP) $(ARGS) doctor

check:
	$(SETUP) --yes $(ARGS) check

clean-backups:
	$(SETUP) $(ARGS) clean-backups

clean: clean-backups

codex-mcp:
	$(SETUP) $(ARGS) codex-mcp

bootstrap:
	$(SETUP) $(ARGS) bootstrap

brew-packages:
	$(SETUP) $(ARGS) brew-packages

brew-bundle:
	brew bundle --file Brewfile

languages:
	$(SETUP) $(ARGS) languages

blockchain:
	$(SETUP) $(ARGS) blockchain

links:
	$(SETUP) $(ARGS) links

apps:
	$(SETUP) $(ARGS) apps

codex:
	$(SETUP) $(ARGS) codex

codex-agents:
	$(SETUP) $(ARGS) codex-agents

codex-skills:
	$(SETUP) $(ARGS) codex-skills

karabiner:
	$(SETUP) $(ARGS) karabiner

macos-shortcuts:
	$(SETUP) $(ARGS) macos-shortcuts

macos:
	$(SETUP) $(ARGS) macos

go:
	$(SETUP) $(ARGS) go

node:
	$(SETUP) $(ARGS) node

bun:
	$(SETUP) $(ARGS) bun

java:
	$(SETUP) $(ARGS) java

kotlin:
	$(SETUP) $(ARGS) kotlin

xml:
	$(SETUP) $(ARGS) xml

rust:
	$(SETUP) $(ARGS) rust

python:
	$(SETUP) $(ARGS) python

typescript:
	$(SETUP) $(ARGS) typescript

solana:
	$(SETUP) $(ARGS) solana

gno:
	$(SETUP) $(ARGS) gno

sui:
	$(SETUP) $(ARGS) sui
