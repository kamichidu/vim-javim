# `javim` (vim-jre) Project Instructions & Conventions

This document contains repo-wide architectural guidelines, development workflows, and coding conventions for maintaining the pure Vim Script JVM implementation.

## Core Architectural Design

The JVM is designed as a modular interpreter running entirely inside Vim 8 (excluding Neovim support).

1. **Bytecode Decoder (`autoload/javim/classfile.vim`):** Reads Java bytecode `.class` files as a binary `Blob` using Vim 8 `readfile(..., 'B')` and parses constant pools, interfaces, fields, methods, and the `Code` attribute.
2. **Interpreter (`autoload/javim/interpreter.vim`):** Manages stack frames, JVM heap allocation, static fields, and method invocations.
3. **Instruction Set (`autoload/javim/instructions.vim`):** Implements JVM opcodes (arithmetic, object instantiations, loops, branch jumps, static/dynamic method dispatch).
4. **Vim-Native Standard Library (`autoload/javim/rt/`):** Bypasses the need for real compiled `rt.jar` class files. Standard Java runtime classes (like `java.lang.Object`, `java.lang.String`, `java.lang.System`, and `java.io.PrintStream`) are mocked directly in Vim Script, exposing pre-configured `ClassDict` structures with native Vim callback mappings.

---

## Coding Conventions & Best Practices

All new and modified Vim Script files in this repository must strictly adhere to the following standards:

### 1. Compatibility Guard (cpoptions)
Every single `.vim` file under both `plugin/`, `autoload/`, and `test/` must be wrapped with the standard `'cpoptions'` (`cpo`) save and restore block to prevent line continuation (`\`) syntax errors in strict or unconfigured environments:
```vim
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
