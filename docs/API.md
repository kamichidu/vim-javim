# Java SE API Built-In Runtime Support Status

This document tracks the support status of the built-in runtime support for the **Java SE Standard API** inside the `javim` interpreter. These implementations are provided as native Vim script extensions under `autoload/javim/rt/`.

---

## 1. Status Definitions

- `supported`: Fully implemented and verified.
- `partial`: Partially implemented (e.g. missing overload methods or edge-case behaviors).
- `unsupported`: Not supported/unimplemented.
- `out-of-scope`: Intentionally out of scope (e.g. threading, native OS file channels, GUI).

---

## 2. API Support Matrix

### java.lang.Object

`java.lang.Object` is the root of the class hierarchy.

| Method / Field | Status | Test | Note |
| :--- | :--- | :---: | :--- |
| `<init>()V` (Constructor) | `supported` | `none` | Default constructor initialization, returns void |
| `toString()Ljava/lang/String;` | `supported` | `none` | Returns dynamic representation string `ClassName@ID` |
| `equals(Ljava/lang/Object;)Z` | `supported` | `none` | Performs pointer/identity reference equality comparison |
| `hashCode()I` | `unsupported` | `none` | Standard object hash code generation |
| `getClass()Ljava/lang/Class;` | `unsupported` | `none` | Runtime class retrieval |
| `clone()Ljava/lang/Object;` | `unsupported` | `none` | Native shallow copy |
| `notify()V` / `notifyAll()V` | `out-of-scope` | `n/a` | Thread synchronization (no multithreading support) |
| `wait(...)` | `out-of-scope` | `n/a` | Thread synchronization (no multithreading support) |

---

### java.lang.String

`java.lang.String` represents character strings inside the JVM.

| Method / Field | Status | Test | Note |
| :--- | :--- | :---: | :--- |
| `<init>()V` (Constructor) | `supported` | `none` | Initializes string with an empty value `""` |
| `length()I` | `supported` | `none` | Returns the length of the internal Vim string buffer |
| `charAt(I)C` | `unsupported` | `none` | Character extraction |
| `equals(Ljava/lang/Object;)Z` | `unsupported` | `none` | Semantic content-based string equality comparison |
| `concat(Ljava/lang/String;)Ljava/lang/String;` | `unsupported` | `none` | String concatenation |
| `substring(...)` | `unsupported` | `none` | String slicing |

---

### java.lang.StringBuilder

`java.lang.StringBuilder` represents a mutable sequence of characters.

| Method / Field | Status | Test | Note |
| :--- | :--- | :---: | :--- |
| `<init>()V` (Constructor) | `supported` | `none` | Initializes internal buffer `_buffer` with an empty value `""` |
| `append(Ljava/lang/String;)Ljava/lang/StringBuilder;` | `supported` | `none` | Concatenates given String object's text value to buffer |
| `append(I)Ljava/lang/StringBuilder;` | `supported` | `none` | Concatenates string representation of the integer value to buffer |
| `toString()Ljava/lang/String;` | `supported` | `none` | Instantiates and returns a new String object containing the buffer |
| Other `append(...)` overloads | `unsupported` | `none` | Overloads for float, double, char, etc. are unsupported |

---

### java.lang.System

`java.lang.System` provides access to system-wide resources.

| Method / Field | Status | Test | Note |
| :--- | :--- | :---: | :--- |
| `out` (Static Field) | `supported` | `pass` | Type `Ljava/io/PrintStream;`. Native static print output stream |
| `<clinit>()V` (Static Initializer) | `supported` | `pass` | Allocates built-in `PrintStream` and binds it to `System.out` |
| `currentTimeMillis()J` | `unsupported` | `none` | Returns 64-bit current system epoch time |
| `arraycopy(...)` | `unsupported` | `none` | Fast memory copying of array buffers |

---

### java.io.PrintStream

`java.io.PrintStream` adds print functionalities to an output stream.

| Method / Field | Status | Test | Note |
| :--- | :--- | :---: | :--- |
| `<init>()V` (Constructor) | `supported` | `pass` | Standard built-in constructor |
| `println(Ljava/lang/String;)V` | `supported` | `pass` | Outputs string representation to Vim and appends to `vm_state.stdout` |
| `println(I)V` | `supported` | `pass` | Outputs integer representation to Vim and appends to `vm_state.stdout` |
| `print(...)` overloads | `unsupported` | `none` | Print without newlines is unsupported |
| `println()` (empty) | `unsupported` | `none` | Blank newline print is unsupported |
