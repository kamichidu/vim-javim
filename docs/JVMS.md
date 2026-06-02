# JVMS SE 8 Compatibility Status

This document defines the compatibility status of the `javim` JVM interpreter against the official **Java Virtual Machine Specification, Java SE 8 Edition (JVMS SE 8)**.

---

## 1. Specification Baseline & Scope

### Non-JVMS Implementation Details (Out of Scope)
The following JVM execution mechanisms are implementation-dependent and are **not** defined as mandatory requirements in JVMS SE 8. Therefore, they are classified as `out-of-scope` for this project:
- **JIT Compilation**: The interpreter runs purely on interpreted bytecode (no Just-In-Time compilation).
- **GC (Garbage Collection)**: Heap layout and garbage collection strategies are left to the underlying Vim memory manager.
- **Heap Layout**: Physical arrangement of objects and references is out of scope.
- **Thread Scheduler**: Multithreading and native OS thread scheduling are out of scope (single-threaded execution only).
- **HotSpot-specific features**: Optimization tactics, intrinsic compilation, and serviceability agents are out of scope.

### Standard Class Library (Java SE API)
Java SE Standard API classes (such as `java.lang.String`, `java.lang.System`, `java.io.PrintStream`) are part of the Java SE Platform API Specification rather than the JVMS SE 8 Specification. Consequently, their stubs and support statuses are managed separately in `docs/API.md`.

---

## 2. Class File Format & Major Versions

The parser parses the binary Java class file structure.

- **Status**: `supported`
- **Supported Classfile Major Version**: The classfile parser accepts major versions `52` (JDK 8) through `69` (JDK 25). However, supported classfile features follow the separate tables below.
- **Verification**: `unsupported`. Type safety, bytecode validation, and structure verification of the class file at class-load time are bypassed for simplicity.

---

## 3. Constant Pool Tags

The constant pool maps dictionary keys to symbols, references, and constant values.

| Tag | Constant Type | Status | Note / Handling |
| :---: | :--- | :--- | :--- |
| `1` | `CONSTANT_Utf8` | `supported` | Read and converted directly to Vim strings |
| `3` | `CONSTANT_Integer` | `supported` | Read and treated as standard Vim numbers |
| `4` | `CONSTANT_Float` | `unsupported` | Floating-point arithmetic is unimplemented |
| `5` | `CONSTANT_Long` | `supported` | Read and represented as `[high_32, low_32]` list |
| `6` | `CONSTANT_Double` | `unsupported` | Floating-point arithmetic is unimplemented |
| `7` | `CONSTANT_Class` | `supported` | Resolved dynamically to the class dictionary |
| `8` | `CONSTANT_String` | `supported` | Instantiated as an internal String object |
| `9` | `CONSTANT_Fieldref` | `supported` | Resolved dynamically to the field owner class and name |
| `10` | `CONSTANT_Methodref` | `supported` | Resolved dynamically to the method owner class and signature |
| `11` | `CONSTANT_InterfaceMethodref` | `unsupported` | - |
| `12` | `CONSTANT_NameAndType` | `supported` | Read and stored |
| `15` | `CONSTANT_MethodHandle` | `out-of-scope` | Dynamic method handles are out of scope |
| `16` | `CONSTANT_MethodType` | `out-of-scope` | Dynamic method types are out of scope |
| `17` | `CONSTANT_Dynamic` | `out-of-scope` | Dynamic constants are out of scope |
| `18` | `CONSTANT_InvokeDynamic` | `unsupported` | Dynamic call site resolution is unsupported (Out of initial scope) |

---

## 4. Attributes

Attributes store metadata for classes, fields, and methods.

| Attribute Name | Scope | Status | Note / Handling |
| :--- | :--- | :--- | :--- |
| `Code` | Method | `supported` | Reads instruction sequence, `max_stack`, `max_locals`, and `exception_table` |
| `LineNumberTable` | Code | `supported` | Safely skipped during main parsing |
| `SourceFile` | Class | `unsupported` | Safely skipped |
| `BootstrapMethods` | Class | `unsupported` | Unsupported as `invokedynamic` is unsupported |
| `StackMapTable` | Code | `unsupported` | Bypassed; bytecode verification is skipped |

---

## 5. Method Type Descriptors

Descriptors represent arguments and return types.

- **Status**: `supported`
- **Descriptor Parsing**: Fully supported. Under `javim#instructions#parse_descriptor()`, string descriptors are successfully parsed into structured type arrays (e.g. `['Ljava/lang/String;', 'I']`).

---

## 6. Access Flags

Access flags dictate resolution permissions.

- **Class Access Flags**: `partial`. `ACC_PUBLIC` and `ACC_SUPER` are parsed and respected during loading/resolution; `ACC_FINAL`, `ACC_INTERFACE`, and `ACC_ABSTRACT` constraints are parsed but not strictly enforced.
- **Field Access Flags**: `partial`. `ACC_PUBLIC` and `ACC_STATIC` are parsed and respected; read-only `ACC_FINAL` enforcement is unsupported.
- **Method Access Flags**: `partial`. `ACC_PUBLIC`, `ACC_STATIC`, and `ACC_NATIVE` are parsed and respected.

---

## 7. Runtime Data Areas

Runtime data structures manage execution state inside the interpreter.

- **Heap**: `supported`. A centralized dictionary `vm_state.heap` maps integer IDs to object dictionaries containing metadata (`__id__`, `__class__`) and field definitions (`__fields__`).
- **Method Area**: `supported`. Managed as loaded class dictionaries stored under `vm_state.classes`.
- **Static Fields Area**: `supported`. Stored under `vm_state.static_fields` with class prefix keys.
- **PC Registers**: `supported`. Managed via `frame.pc` inside the frame representation.
- **JVM Stacks & Frames**: `supported`. Stored as local variables array list and operand stack list within individual frames.

---

## 8. Frames

Frames represent local scope during method execution.

- **Local Variables**: `supported`. Stored as a flat list under `frame.local_variables` padded with `0` up to `max_locals`.
- **Operand Stack**: `supported`. Stored as a flat list under `frame.operand_stack`.

---

## 9. Method Invocation

Method execution routing based on bytecode instructions.

- **`invokestatic`**: `supported`. Spawns a new frame and executes the specified static class method.
- **`invokevirtual`**: `supported`. Performs dynamic dispatch based on the actual class type of the object instance on the heap.
- **`invokespecial`**: `supported`. Directly calls constructor (`<init>`), private, or superclass methods without dynamic dispatch.
- **`invokeinterface`**: `unsupported`.
- **`invokedynamic` / `BootstrapMethods`**: `unsupported`. Bypassed and unimplemented.

---

## 10. Class Loading, Linking, and Initialization

The lifecycle of class definitions inside the virtual machine.

- **Class Loading**: `supported`. Dynamically created array types (`[L...;`), native runtime stubs from `autoload/javim/rt/`, or physical class files from search classpath directories are successfully loaded.
- **Linking**: `partial`. Bypasses formal binary verification. Initializes static fields with their default JVM representation (e.g. `0` for `I`, `{'null': 1}` for objects) during loading.
- **Initialization**: `supported`. Automatically runs class initializers (`<clinit>()V`) in isolation upon class loading.

### Classpath & Loader Support Matrix

We support classloading from classic classpaths. Below is the detailed support matrix for different classpath entry types:

| Entry Type | Status | Detailed Support Scope & Behavior |
| :--- | :--- | :--- |
| **directory** | `supported` | Looks up `.class` files sequentially under specified directory structures. Multiple directories can be separated by system-specific delimiters (`:` on Unix/macOS, `;` on Windows). |
| **jar file classpath entry** | `supported via extraction cache` | Direct `.jar` file paths can be specified. It extracts the JAR archive into cache directories using the external `unzip` command, and loads classes from the extracted directory. Requires the external `unzip` executable to be installed. |
| **wildcard** | `supported` | Wildcard patterns (e.g. `lib/*`) are expanded at startup using Vim's built-in `glob()` function. Unlike standard JREs (which strictly match only `.jar`/`.JAR` files under the folder), `javim` delegates to Vim's native globbing engine. Any resulting matches are then filtered to keep only valid directories and `.jar` files for classloading. |
| **manifest Class-Path** | `unsupported` | Automatic resolution and dependent loading of paths listed in the `Class-Path` header inside a JAR's `MANIFEST.MF` is explicitly unsupported. Only direct contents of the specified JAR are loaded. |
| **module-path** (Jigsaw) | `unsupported` | Java 9+ modular directories and module-path command-line flags (`--module-path` or `-p`) are explicitly unsupported. |

- **Classpath Specification (`-cp` / `-classpath`)**: `supported`. You can configure physical classpaths for `:JavimRun` using `-cp` or `-classpath` arguments. When omitted, it defaults to `['.']` (the current working directory).

### System & External Command Requirements

- **External `unzip` command**: A standard `unzip` utility is **required** to support `jar file classpath entry` classloading. It must be accessible in your system `PATH`.

---

## 11. Instruction Categories

Categorized status of the JVMS SE 8 instruction set.

- **Constants**: `partial` (Integer constants supported; float/double constants unsupported)
- **Loads**: `partial` (Integer and Reference loading supported; long/float/double load unsupported)
- **Stores**: `partial` (Integer and Reference storing supported; long/float/double store unsupported)
- **Stack**: `partial` (Common `pop` and `dup` supported; `dup2`, `swap`, and variations unsupported)
- **Math**: `partial` (Integer basic arithmetic `iadd`, `isub`, `imul`, `idiv`, `iinc` supported; float/double arithmetic and logical shift/bitwise operations unsupported)
- **Conversions**: `unsupported`
- **Comparisons**: `partial` (Integer comparisons with zero and integer-to-integer comparisons supported; float/double/long comparisons unsupported)
- **Control**: `partial` (Basic `goto`, method return `ireturn`, `areturn`, `return` supported; `jsr`, `tableswitch`, `lookupswitch` unsupported)
- **References**: `partial` (Static/instance field reads/writes and object creation supported; array creation and multidimensional arrays unsupported)
- **Extended**: `unsupported` (Exception throw `athrow` and type checks `instanceof`, `checkcast` unsupported)
