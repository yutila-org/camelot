<p align="center">
  <img src="logo.svg" alt="Camelot Logo" width="280">
</p>

<p align="center">
  <code><b>( •⩊• )</b> "Did someone say... MAGIC?!"</code>
</p>

<p align="center">
  <a href="https://img.shields.io/badge/Language-C23-38;5;81?style=for-the-badge&logo=c&logoColor=white"><img src="https://img.shields.io/badge/Language-C23-00599C?style=for-the-badge&logo=c&logoColor=white" alt="C23"></a>
  <a href="https://img.shields.io/badge/Orchestrator-Merlin%20(D)-magenta?style=for-the-badge&logo=d&logoColor=white"><img src="https://img.shields.io/badge/Orchestrator-Merlin%20(D)-F24E1E?style=for-the-badge&logo=d&logoColor=white" alt="D"></a>
  <a href="https://img.shields.io/badge/Security-Hardened-red?style=for-the-badge&logo=securityscorecard&logoColor=white"><img src="https://img.shields.io/badge/Security-Hardened-red?style=for-the-badge&logo=securityscorecard&logoColor=white" alt="Hardened"></a>
  <a href="https://img.shields.io/badge/License-MPL_2.0-orange?style=for-the-badge"><img src="https://img.shields.io/badge/License-MPL_2.0-orange?style=for-the-badge" alt="MPL 2.0"></a>
</p>

---

**Camelot** is a lightweight, zero-latency C framework engineered for strict memory safety, predictability, and secure execution. It compiles under **C23** and is fully driven by **Merlin**, a compiled, standalone build orchestrator written in the **D Programming Language** that features interactive TUI animations.

---

## 🔮 Merlin Build Dashboard

Simply invoke `make` (which bootstraps `merlin.d` to `bin/merlin`) to launch the interactive, animated build dashboard:

```bash
make
```

### Build Command Recipes

| Command | Action / Verification |
| :--- | :--- |
| `make` | Summons the animated TUI dashboard and scans directory stats |
| `make all` | Compiles the framework target using the secure compilation standard |
| `make test` | Runs the test suite under strict **Address, Undefined, and Leak Sanitizers** |
| `make run` | Builds and launches the C framework executable |
| `make clean` | Poof! Prunes all compiled caches, object files, and binaries |

---

## 🏗️ Repository Architecture

```text
camelot/
├── include/camelot/      # Unified framework API
│   ├── core/             # Tri-state Result monad & safety poisoning guards
│   ├── memory/           # Monotonic Arena & Allocator dispatch interfaces
│   └── types/            # Fixed-width primitive specifications
├── src/                  # Implementation Source Code
├── tests/                # Verification Suite
├── merlin.d              # Standalone Merlin build orchestrator in D
└── Makefile              # Transparent bootstrap Makefile wrapper
```

---

## 🛡️ Security Policy Guarantees

All compiles automatically inherit the following enterprise-grade exploit mitigations:
- **ASLR Compatibility:** Complies via `-fPIE` / `-pie` (Position Independent Executable).
- **Stack Protection:** Hardened via `-fstack-protector-strong` stack canaries.
- **Memory Sandboxing:** Traps runtime errors, memory leaks, and bounds overflow via `-fsanitize=address,undefined,leak`.
- **Undefined Behavior Mitigation:** Relies on defined two's-complement integer wrapping (`-fwrapv`), traps integer overflows (`-ftrapv`), and disables unsafe standard functions (`strcpy`, `strcat`) via static compile-time poisoning.
