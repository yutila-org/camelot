<div align="center">

  <img src="logo.svg" alt="Camelot Logo" width="200" />

  <br />

  <h1>Camelot</h1>
   
  **A modern, safe and ergonomic C framework.**

  <br />
  <br />

  <img src="https://img.shields.io/badge/License-MPL_2.0-brightgreen?style=for-the-badge&logo=opensourceinitiative&logoColor=white" alt="License" />
  <img src="https://img.shields.io/badge/Standard-C23-purple?style=for-the-badge&logo=c&logoColor=white" alt="Standard" />

</div>

<br />

## <img src="https://cdn.simpleicons.org/blueprint/ffffff" width="24" style="vertical-align: bottom;" /> Overview
Camelot is a modern, safe and ergonomic C framework. It provides structural alternatives to libc subsystems that expose implicit allocation behavior or hidden state transitions. It requires explicit allocator pointers instead of unmanaged malloc and enforces a tri-state error model. It intentionally provides no API compatibility with standard libc. It is not freestanding and relies on underlying libc components. Safety relies on explicit conventions, custom allocators and strict compiler flags rather than language features.

## <img src="https://cdn.simpleicons.org/target/ffffff" width="24" style="vertical-align: bottom;" /> Core Design Goals
*   **Explicit Control**: Manual and traceable resource, memory and error management.
*   **Cross-Platform Portability**: Fully portable across GCC, Clang and MSVC. No runtime-altering compiler extensions (e.g., no GCC `__attribute__((cleanup))`).
*   **Predictability**: Strict compiler flags constrain undefined behavior and pragmas block unsafe functions.

## <img src="https://cdn.simpleicons.org/sentry/ffffff" width="24" style="vertical-align: bottom;" /> Guarantee Model
*   **Compiler-Enforced**: Type warnings, unhandled `[[nodiscard]]` returns and poisoned function bans.
*   **Library-Enforced**: VTable allocator boundaries, tri-state `Result` structures and slice capacity limits.
*   **Test-Enforced**: Memory leaks, out-of-bounds access (ASan) and undefined behavior validation (UBSan).
*   **Convention-Only**: Explicit `goto defer;` cleanup paths and manual deallocation function calls.

## <img src="https://cdn.simpleicons.org/polywork/ffffff" width="24" style="vertical-align: bottom;" /> Architecture
Camelot is split into modular domains mapping `include/camelot/` to `src/`.

| Component | Implementation | Enforced By | Responsibility |
| :--- | :--- | :--- | :--- |
| **Core & Safety** | <img src="https://img.shields.io/badge/Result_Types-dea584?style=flat&logo=c&logoColor=white&labelColor=dea584" height="20" /> | Attributes | Explicit `[[nodiscard]]` error handling. |
| **Memory Model** | <img src="https://img.shields.io/badge/VTable_Allocators-96bf48?style=flat&logo=c&logoColor=white&labelColor=96bf48" height="20" /> | Architecture | VTable-based allocators requiring manual teardown. |
| **Data Layout** | <img src="https://img.shields.io/badge/Fat_Pointers-e5a50a?style=flat&logo=buffer&logoColor=white&labelColor=e5a50a" height="20" /> | Architecture | Bounds-tracked slices instead of null-terminated strings. |
| **Build System** | <img src="https://img.shields.io/badge/Merlin_TUI-0082fc?style=flat&logo=d&logoColor=white&labelColor=0082fc" height="20" /> | Merlin | Interactive D-based build orchestration. |

## <img src="https://cdn.simpleicons.org/c/ffffff" width="24" style="vertical-align: bottom;" /> Memory Model
No implicit allocation or garbage collection.
*   **Allocator VTable**: All dynamic structures take an explicit `Allocator` pointer. *(Code)*
*   **Arenas**: Bulk deallocation by resetting an offset pointer. *(Code)*
*   **Fat Pointers**: Pointer + length slices for bounds tracking (structural, not compiler-enforced). *(Code)*
*   **Vector Growth**: Arrays scale at 1.5x (`cap = cap + (cap >> 1)`) to permit block recycling by the host allocator. *(Code)*

## <img src="https://cdn.simpleicons.org/linux/ffffff" width="24" style="vertical-align: bottom;" /> Error Handling
Explicit propagation only.
*   **Result**: Fallible functions return a `[[nodiscard]]` union (`OK`, `NIL`, `ERR`). *(Attributes)*
*   **Explicit Deferral**: Cleanup uses a single `goto defer;` block. *(Convention)*
*   **Explicit Deinit**: Manual teardown calls (e.g., `VECTOR_deinit`). *(Convention)*
*   **Poisoning**: Unsafe libc functions (`strcpy`) are statically blocked unless explicitly bypassed per translation unit via a `#define ALLOW_UNSAFE` macro. 
    *   *GCC/Clang*: Enforced via `#pragma GCC poison`.
    *   *MSVC*: Enforced via `/W4` with SAL annotations.

## <img src="https://cdn.simpleicons.org/d/ffffff" width="24" style="vertical-align: bottom;" /> Build System (Merlin)
**Merlin** is a standalone D-based tool providing an interactive TUI for executing builds.

## <img src="https://cdn.simpleicons.org/llvm/ffffff" width="24" style="vertical-align: bottom;" /> Testing
*   **Sanitizers**: ASan and UBSan enabled (`-fsanitize=address,undefined,signed-overflow`). *(Debug only)*
*   **Traps**: Signed integer overflow aborts (`-ftrapv`). *(Debug only)*

## <img src="https://cdn.simpleicons.org/gnu/ffffff" width="24" style="vertical-align: bottom;" /> Compilation
*   **All Builds**: ASLR (`-fPIE`, `-pie`), non-executable stack, stack protection and fortified source. *(Compiler flags)*
*   **Release**: Force two's complement integer wrap (`-fwrapv`), disable optimizations assuming non-null pointers (`-fno-delete-null-pointer-checks`) and disable strict overflow optimizations (`-fno-strict-overflow`). *(Compiler flags)*

## <img src="https://cdn.simpleicons.org/github/ffffff" width="24" style="vertical-align: bottom;" /> Integration
Download the latest source release, compile the static library via **Merlin** and link it to your project.

## <img src="https://cdn.simpleicons.org/markdown/ffffff" width="24" style="vertical-align: bottom;" /> Limitations
*   **No RAII**: Resource management is entirely manual.
*   **No Absolute Safety**: Safety depends on following conventions. Misuse can still cause memory errors.
*   **Overhead**: Hash maps with open addressing require parallel metadata arrays and tracked strings (`OwnedString`) use an extra pointer.
