<div align="center">

  <img src="logo.svg" alt="Camelot Logo" width="200" />

  <br />

  <h1>Camelot</h1>
   
  **A general-purpose C framework.**

  [![C](https://img.shields.io/badge/C23-A8B9CC?style=for-the-badge&logo=c&logoColor=white)](https://en.cppreference.com/w/c/23)
  [![Make](https://img.shields.io/badge/Make-A42E2B?style=for-the-badge&logo=gnu&logoColor=white)](https://www.gnu.org/software/make/)
  [![MPL-2.0](https://img.shields.io/badge/MPL_2.0-FF0000?style=for-the-badge&logo=mozilla&logoColor=white)](https://www.mozilla.org/en-US/MPL/2.0/)
  [![Merlin](https://img.shields.io/badge/Merlin-1E1E1E?style=for-the-badge&logo=data:image/svg%2Bxml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxMDAgMTAwIiB3aWR0aD0iMTAwIiBoZWlnaHQ9IjEwMCI+PHBhdGggZD0iTTIwIDgwIEwyMCA0MCBMNTAgNzAgTDgwIDQwIEw4MCA4MCIgZmlsbD0ibm9uZSIgc3Ryb2tlPSIjZmYwMGZmIiBzdHJva2Utd2lkdGg9IjEyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiLz48Y2lyY2xlIGN4PSI1MCIgY3k9IjMwIiByPSI4IiBmaWxsPSIjMDBmZmZmIi8+PC9zdmc+)](https://github.com/yutila-org/merlin)

</div>

<br />

## <img src="https://cdn.simpleicons.org/blueprint/137CBD" width="24" style="vertical-align: bottom;" /> Scope
Camelot is a general-purpose C framework. It is not a utility library. It provides structural alternatives to libc subsystems that expose implicit allocation behavior or hidden state transitions. It requires explicit allocator pointers instead of unmanaged malloc calls and enforces a tri-state error model. It intentionally provides no API compatibility with standard libc. It is not freestanding and relies on underlying libc components. Safety relies on explicit conventions, custom allocators and strict compiler flags.


## <img src="https://cdn.simpleicons.org/sentry/FB4226" width="24" style="vertical-align: bottom;" /> Guarantee Model
*   **Compiler-Enforced**: Type warnings, unhandled `[[nodiscard]]` returns and poisoned function bans.
*   **Library-Enforced**: VTable allocator boundaries, tri-state `Result` structures and slice capacity limits.
*   **Test-Enforced**: Memory leaks, out-of-bounds access (ASan) and undefined behavior validation (UBSan).
*   **Convention-Only**: Explicit `goto defer;` cleanup paths and manual deallocation function calls.

## <img src="https://cdn.simpleicons.org/polywork/543DE0" width="24" style="vertical-align: bottom;" /> Architecture
Camelot is split into modular domains mapping `include/camelot/` to `src/`.

| Component | Enforced By | Responsibility |
| :--- | :--- | :--- |
| **Core & Safety** | Attributes | Explicit `[[nodiscard]]` error handling. |
| **Memory Model** | Architecture | VTable-based allocators requiring manual teardown. |
| **Data Layout** | Architecture | Bounds-tracked slices instead of null-terminated strings. |
| **Build System** | Merlin | Interactive D-based build orchestration. |

## <img src="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='%23ff0000'%3E%3Cpath d='M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z'/%3E%3C/svg%3E" width="24" style="vertical-align: bottom;" /> Error Handling
*   **Result**: Fallible functions return a `[[nodiscard]]` union (`OK`, `NIL`, `ERR`).
*   **Explicit Deferral**: Cleanup uses a single `goto defer;` block.
*   **Poisoning**: Unsafe libc functions are statically blocked unless explicitly bypassed via a `#define ALLOW_UNSAFE` macro. 

## <img src="https://cdn.simpleicons.org/gnu/A42E2B" width="24" style="vertical-align: bottom;" /> Compilation
*   **All Builds**: ASLR (`-fPIE`, `-pie`), non-executable stack, stack protection and fortified source.
*   **Release**: Force two's complement integer wrap (`-fwrapv`), disable optimizations assuming non-null pointers (`-fno-delete-null-pointer-checks`) and disable strict overflow optimizations (`-fno-strict-overflow`).

## <img src="https://cdn.simpleicons.org/github/888888" width="24" style="vertical-align: bottom;" /> Integration
Download the latest source release, compile the static library via **Merlin** and link it to your project.

## <img src="https://cdn.simpleicons.org/markdown/42A5F5" width="24" style="vertical-align: bottom;" /> Limitations
Camelot is not designed to be the savior of C. It is simply built to solve the tedious situations I personally encounter as a C developer, like wrestling with file I/O or hidden memory allocations. Because of this practical focus, it accepts inherent architectural trade-offs. For example, RAII cannot be implemented due to cross-platform compiler incompatibilities, meaning resource teardown remains entirely manual. Absolute safety is impossible without a borrow checker, so protection relies strictly on developer conventions. Finally, structural features like tracked strings or open-addressed hash maps introduce minor overhead via extra pointers and parallel metadata arrays.
