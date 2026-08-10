# Hermes Agent 2026.8.3 daemon-pool workaround

`home/run_after_hermes-agent-patch.sh` runs on every `chezmoi apply`. For an
installed `hermes-agent` exactly at `2026.8.3`, it verifies these canonical
sources, safely replaces only the known original `daemon_pool.py`, preserves a
validated original backup at `~/.hermes/patches/`, and pins the formula after
verification. It never installs, upgrades, or restarts Hermes.

| File | SHA-256 |
| --- | --- |
| `daemon_pool.py.original.py` | `148a18c801a28f4fb5a96eb20399052245599413a349d7df2fd0b4643ae910dc` |
| `daemon_pool.py.patched.py` | `b48912a01f0696db165fc1bcb68e6bf055b1f32a67dd601c8bb857aca8b20f42` |

Remove this directory and the run script when an upstream Hermes release
contains the Python 3.14 `_create_worker_context()` fix.
