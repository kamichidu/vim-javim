# `javim` Project Instructions & Conventions

This document contains repo-wide architectural guidelines, development workflows, and coding conventions for maintaining the pure Vim Script JVM implementation.

## Core Architectural Design

The JVM is designed as a modular interpreter running entirely inside Vim 8 (excluding Neovim support).

1. **Bytecode Decoder (`autoload/javim/classfile.vim`):** Reads Java bytecode `.class` files as a binary `Blob` using Vim 8 `readfile(..., 'B')` and parses constant pools, interfaces, fields, methods, and the `Code` attribute.
2. **Interpreter & Predecoder (`autoload/javim/interpreter.vim`):** Manages stack frames, JVM heap allocation, static fields, and method invocations. To ensure maximum execution speed, methods are **predecoded** once prior to execution. The original bytecode is converted into a non-destructive `instructions` stream object array, with jump targets pre-resolved via a `pc_to_ip` map. It also dynamically injects Superinstructions using an internal extended opcode space (`>= 0x10000`).
3. **Instruction Set (`autoload/javim/instructions.vim`):** Implements standard JVMS opcodes (`0x00` to `0xff`). The execution loop operates over the predecoded instruction index (`ip`) rather than sequential byte-reading.
4. **Vim-Native Standard Library (`autoload/javim/rt/`):** Bypasses the need for real compiled `rt.jar` class files. Standard Java runtime classes (like `java.lang.Object`, `java.lang.String`, `java.lang.System`, and `java.io.PrintStream`) are implemented directly in Vim Script as built-in runtime support, exposing pre-configured `ClassDict` structures with native Vim callback mappings.
5. **Execution Entry Point (`autoload/javim.vim`):** Exposes the public `javim#run(...)` API, which parses runtime parameters (such as classpath override `-cp`), configures an isolated VM state dictionary, maps execution arguments to native JVM String array references, and executes the target class `main` method. The `:JavimRun` command defined in `plugin/javim.vim` acts as a lightweight wrapper delegating directly to this function.

---

## Coding Conventions & Best Practices

All new and modified Vim Script files in this repository must strictly adhere to the following standards:

### 1. File Header and Compatibility Guard
Every single `.vim` file under `plugin/`, `autoload/`, and `test/` must place its file path comment at the absolute top (line 1), followed immediately by the standard `'cpoptions'` (`cpo`) save and restore block. This ensures a clean, unified, and professional file structure while preventing line continuation (`\`) syntax errors:
```vim
" autoload/javim/example.vim

let s:save_cpo = &cpo
set cpo&vim

" ... script logic ...

let &cpo = s:save_cpo
unlet s:save_cpo
```

### 2. Script-Local Scope Prefix
Never use underscores for script-local function names (such as `s_my_helper()`). Always use the proper colon-prefixed local script syntax:
```vim
" Correct (script-local function prefix)
function! s:my_helper() abort
  " ...
endfunction

" Incorrect (throws E128 syntax error)
function! s_my_helper() abort
  " ...
endfunction
```

### 3. Vim 8 Exclusivity
Do not employ Neovim-specific namespaces, APIs, or Lua wrappers. Always program to Vim 8+ specifications (Blob types, standard test assertions like `assert_equal()`).

---

## Development Workflows

### 1. Launching for Debugging & Tab-Completion
Use the bundled debug script to launch Vim with `-u NONE` (no vimrc), forcing `nocompatible` mode with our plugin added to the `'runtimepath'`:
```bash
./vim-debug.sh
```
* Once inside Vim, type `:Ja<Tab>` to auto-complete to `:JavimRun`.
* Execute classfiles by passing their package path: `:JavimRun test.classes.HelloWorld`.

### 2. Sourcing and Compiling Java Test Targets
If you write new test targets inside `test/classes/`:
```bash
javac -d . test/classes/MyNewTest.java
```
Always use `-d .` to output classfiles in packages mapped exactly to their directory structure, allowing the JVM ClassLoader to resolve them.

### 3. Running Automated Tests
The headless testing framework runs via:
```bash
vim -u NONE -S test/run_tests.vim
```
This script appends `.` (repository root) to the `'runtimepath'` to resolve autoload dependencies and runs all test suites non-interactively, returning an exit code of `0` on success, or logging test failures to standard output/logs and exiting with `cquit!` (non-zero) on error.

---

## Documentation & Specification Maintenance Policy

To maintain a clear and accurate understanding of the interpreter's compliance status, we maintain three hand-managed specification and compatibility documents under the `docs/` folder:

1. **`docs/JVMS.md`**: Tracks compatibility against the *Java Virtual Machine Specification, Java SE 8 Edition (JVMS SE 8)*, covering binary class formats, constant pool tags, attributes, descriptors, runtime areas, stacks, and method invocation boundaries.
2. **`docs/OPCODES.md`**: A manually updated listing of the entire 1-byte opcode space (`0x00` to `0xff`).
3. **`docs/API.md`**: A compatibility matrix tracking the built-in runtime support for the standard library (`java.lang.Object`, `java.lang.String`, `java.lang.System`, `java.io.PrintStream`).

### Guidelines for Document Updates (Hand-Managed)

Every time an opcode, classfile parsing feature, or Java SE API built-in runtime method is implemented, modified, or verified, the corresponding document must be updated by hand according to these rules:

#### 1. Ground Truth
* **Implementation Ground Truth**: The actual code in the interpreter (`autoload/javim/interpreter.vim` and `autoload/javim/instructions.vim`) is the absolute source of truth for support status.
* **Test Verification Ground Truth**: The test suites in the `test/` directory are the absolute source of truth for verification status.

#### 2. Status Definitions
When updating status fields, always use one of these six unified terms:
* `supported`: Fully implemented and verified.
* `partial`: Partially implemented (e.g., missing specific method overloads or edge-case constraints).
* `unsupported`: Not supported/unimplemented.
* `out-of-scope`: Intentionally excluded from the project scope (e.g., JIT compilation, GC strategies, native thread scheduling, or multi-threading monitor instructions like `monitorenter` and `monitorexit`).
* `reserved`: Reserved by the JVMS SE 8 specification (e.g., `0xca` for `breakpoint` and `0xfe` / `0xff` for `impdep`).
* `unknown`: Unverified/status unknown.

#### 3. Test Column Verification
In `docs/OPCODES.md` and `docs/API.md`, the `test` column must specify precisely which test suite class verifies the item (e.g., `pass(HelloWorld)`, `pass(MathTest)`, `pass(Fibonacci)`). If no specific automated test executes the path, it must be marked as `none` (or `n/a` for reserved/out-of-scope items). Avoid vague or generic `pass` claims.

### Guidelines for README and Help File Updates

To maintain consistency and high-signal quality across user-facing documentation, strictly adhere to the following rules when modifying `README.adoc` or `doc/javim.txt`:

#### 1. Factual and Objective Tone
* All descriptions must be completely dispassionate and state pure technical facts. Avoid marketing or buzzword adjectives (e.g., use "minimal implementation" instead of "lightweight").
* No conversational justifications or notes are allowed in the benchmark results section. Only present raw data, the execution environment specifications, and factual comparison tables.

#### 2. Documentation Partitioning
* **`README.adoc` (Web / Entrypoint)**: Contains general setup guides, installation instructions, user configuration, troubleshooting, and compatibility/platform exclusions (e.g., explicitly stating that Neovim is unsupported).
* **`doc/javim.txt` (Vim Help)**: Remains purely focused on native Vim usage and command details. Exclude mentions of non-Vim compatibility details (such as Neovim exclusions) to keep the native help clean and focused for Vim users.
* **Deep-Dive Specifications**: Keep detailed compliance specs strictly inside the `docs/` folder, and link to them directly from both `README.adoc` and `doc/javim.txt` rather than duplicating lists of features or API methods.

#### 3. Structured Page Layout
* Promoted sections (top of `README.adoc`): `Features`, `Installation`, `Usage`, `Troubleshooting`, `Configuration`, and `Benchmark Results`.
* Developer sections (bottom of `README.adoc`): `Specifications & Compatibility`, `Internal Architecture & Implementation`, `Limitations`, and `Development & Automated Testing`.
* The `Directory Structure` diagram inside `README.adoc` must strictly stop at the folder level. Do not list individual files or deep file trees in the README's structure block.
