<div align="center">

  <img src="logo.svg" alt="Camelot Logo" width="200" />

  <br />

  <h1>Camelot</h1>
   
  **A general-purpose C framework.**

  <br />
  <br />

  <img src="https://img.shields.io/badge/License-MPL_2.0-brightgreen?style=for-the-badge&logo=opensourceinitiative&logoColor=white" alt="License" />
  <img src="https://img.shields.io/badge/Standard-C23-purple?style=for-the-badge&logo=c&logoColor=white" alt="Standard" />

</div>

<br />

## <img src="https://cdn.simpleicons.org/blueprint/ffffff" width="24" style="vertical-align: bottom;" /> Scope
Camelot is a general-purpose C framework. It is not a utility library. It provides structural alternatives to libc subsystems that expose implicit allocation behavior or hidden state transitions. It requires explicit allocator pointers instead of unmanaged malloc calls and enforces a tri-state error model. It intentionally provides no API compatibility with standard libc. It is not freestanding and relies on underlying libc components. Safety relies on explicit conventions, custom allocators and strict compiler flags.

## <img src="https://cdn.simpleicons.org/target/ffffff" width="24" style="vertical-align: bottom;" /> Capabilities
Camelot provides a unified architecture for application development.

*   **Memory Management**: Requires explicit arena allocators or VTable dispatch interfaces.
*   **Concurrency & Parallelism**: Abstracts thread lifecycles and mutex boundaries for parallel execution.
*   **Networking**: Wraps socket interfaces into state-machine-driven connections.
*   **Data Structures**: Implements bounds-tracked slices, hash maps with open addressing and vector growth structures.
*   **String Handling**: Provides built-in UTF-8 parsing and tracked `OwnedString` structures.
*   **Data Serialization**: Parses and emits structured data formats.
*   **Random Generation**: Exposes modular PRNG algorithms via parameter selection with a predefined default algorithm.
*   **Ecosystem Integration**: Interfaces with external C libraries (Raylib or GTK) through explicit memory boundaries.

## <img src="https://cdn.simpleicons.org/sentry/ffffff" width="24" style="vertical-align: bottom;" /> Guarantee Model
*   **Compiler-Enforced**: Type warnings, unhandled `[[nodiscard]]` returns and poisoned function bans.
*   **Library-Enforced**: VTable allocator boundaries, tri-state `Result` structures and slice capacity limits.
*   **Test-Enforced**: Memory leaks, out-of-bounds access (ASan) and undefined behavior validation (UBSan).
*   **Convention-Only**: Explicit `goto defer;` cleanup paths and manual deallocation function calls.

## <img src="https://cdn.simpleicons.org/polywork/ffffff" width="24" style="vertical-align: bottom;" /> Architecture
Camelot is split into modular domains mapping `include/camelot/` to `src/`.

| Component | Enforced By | Responsibility |
| :--- | :--- | :--- |
| **Core & Safety** | Attributes | Explicit `[[nodiscard]]` error handling. |
| **Memory Model** | Architecture | VTable-based allocators requiring manual teardown. |
| **Data Layout** | Architecture | Bounds-tracked slices instead of null-terminated strings. |
| **Build System** | Merlin | Interactive D-based build orchestration. |

## <img src="https://cdn.simpleicons.org/linux/ffffff" width="24" style="vertical-align: bottom;" /> Error Handling
*   **Result**: Fallible functions return a `[[nodiscard]]` union (`OK`, `NIL`, `ERR`).
*   **Explicit Deferral**: Cleanup uses a single `goto defer;` block.
*   **Poisoning**: Unsafe libc functions are statically blocked unless explicitly bypassed via a `#define ALLOW_UNSAFE` macro. 

## <img src="https://cdn.simpleicons.org/gnu/ffffff" width="24" style="vertical-align: bottom;" /> Compilation
*   **All Builds**: ASLR (`-fPIE`, `-pie`), non-executable stack, stack protection and fortified source.
*   **Release**: Force two's complement integer wrap (`-fwrapv`), disable optimizations assuming non-null pointers (`-fno-delete-null-pointer-checks`) and disable strict overflow optimizations (`-fno-strict-overflow`).

## <img src="https://cdn.simpleicons.org/github/ffffff" width="24" style="vertical-align: bottom;" /> Integration
Download the latest source release, compile the static library via **Merlin** and link it to your project.

## <img src="https://cdn.simpleicons.org/markdown/ffffff" width="24" style="vertical-align: bottom;" /> Limitations
*   **No RAII**: Resource management is entirely manual.
*   **No Absolute Safety**: Safety depends on following conventions. Misuse causes memory errors.
*   **Overhead**: Hash maps require parallel metadata arrays and tracked strings use an extra pointer.
