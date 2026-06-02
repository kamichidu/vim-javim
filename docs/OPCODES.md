# JVM Opcode Compatibility Status

This document defines the implementation and test verification status of each byte-value under the entire **1-byte opcode space** (all 256 possible values from `0x00` to `0xff`), rather than limiting the table only to standard instructions, against the **Java Virtual Machine Specification, Java SE 8 Edition (JVMS SE 8)**.

---

## Opcode Table

| opcode | mnemonic | category | status | test | note |
| :---: | :--- | :--- | :--- | :---: | :--- |
| `0x00` | `nop` | Constants | `supported` | `none` | Do nothing |
| `0x01` | `aconst_null` | Constants | `supported` | `none` | Push null |
| `0x02` | `iconst_m1` | Constants | `supported` | `none` | Push int -1 |
| `0x03` | `iconst_0` | Constants | `supported` | `pass(MathTest)` | Push int 0 |
| `0x04` | `iconst_1` | Constants | `supported` | `pass(MathTest,Fibonacci)` | Push int 1 |
| `0x05` | `iconst_2` | Constants | `supported` | `pass(Fibonacci)` | Push int 2 |
| `0x06` | `iconst_3` | Constants | `supported` | `none` | Push int 3 |
| `0x07` | `iconst_4` | Constants | `supported` | `none` | Push int 4 |
| `0x08` | `iconst_5` | Constants | `supported` | `pass(MathTest)` | Push int 5 |
| `0x09` | `lconst_0` | Constants | `unsupported` | `none` | Push long 0 |
| `0x0a` | `lconst_1` | Constants | `unsupported` | `none` | Push long 1 |
| `0x0b` | `fconst_0` | Constants | `unsupported` | `none` | Push float 0.0 |
| `0x0c` | `fconst_1` | Constants | `unsupported` | `none` | Push float 1.0 |
| `0x0d` | `fconst_2` | Constants | `unsupported` | `none` | Push float 2.0 |
| `0x0e` | `dconst_0` | Constants | `unsupported` | `none` | Push double 0.0 |
| `0x0f` | `dconst_1` | Constants | `unsupported` | `none` | Push double 1.0 |
| `0x10` | `bipush` | Constants | `supported` | `pass(MathTest)` | Push byte |
| `0x11` | `sipush` | Constants | `supported` | `none` | Push short |
| `0x12` | `ldc` | Constants | `supported` | `pass(HelloWorld)` | Push item from constant pool |
| `0x13` | `ldc_w` | Constants | `unsupported` | `none` | Push item from constant pool (wide index) |
| `0x14` | `ldc2_w` | Constants | `unsupported` | `none` | Push long or double from constant pool (wide index) |
| `0x15` | `iload` | Loads | `supported` | `pass(MathTest)` | Load int from local variable |
| `0x16` | `lload` | Loads | `unsupported` | `none` | Load long from local variable |
| `0x17` | `fload` | Loads | `unsupported` | `none` | Load float from local variable |
| `0x18` | `dload` | Loads | `unsupported` | `none` | Load double from local variable |
| `0x19` | `aload` | Loads | `supported` | `none` | Load reference from local variable |
| `0x1a` | `iload_0` | Loads | `supported` | `pass(Fibonacci)` | Load int from local variable 0 |
| `0x1b` | `iload_1` | Loads | `supported` | `pass(MathTest)` | Load int from local variable 1 |
| `0x1c` | `iload_2` | Loads | `supported` | `pass(MathTest)` | Load int from local variable 2 |
| `0x1d` | `iload_3` | Loads | `supported` | `pass(MathTest)` | Load int from local variable 3 |
| `0x1e` | `lload_0` | Loads | `unsupported` | `none` | Load long from local variable 0 |
| `0x1f` | `lload_1` | Loads | `unsupported` | `none` | Load long from local variable 1 |
| `0x20` | `lload_2` | Loads | `unsupported` | `none` | Load long from local variable 2 |
| `0x21` | `lload_3` | Loads | `unsupported` | `none` | Load long from local variable 3 |
| `0x22` | `fload_0` | Loads | `unsupported` | `none` | Load float from local variable 0 |
| `0x23` | `fload_1` | Loads | `unsupported` | `none` | Load float from local variable 1 |
| `0x24` | `fload_2` | Loads | `unsupported` | `none` | Load float from local variable 2 |
| `0x25` | `fload_3` | Loads | `unsupported` | `none` | Load float from local variable 3 |
| `0x26` | `dload_0` | Loads | `unsupported` | `none` | Load double from local variable 0 |
| `0x27` | `dload_1` | Loads | `unsupported` | `none` | Load double from local variable 1 |
| `0x28` | `dload_2` | Loads | `unsupported` | `none` | Load double from local variable 2 |
| `0x29` | `dload_3` | Loads | `unsupported` | `none` | Load double from local variable 3 |
| `0x2a` | `aload_0` | Loads | `supported` | `none` | Load reference from local variable 0 |
| `0x2b` | `aload_1` | Loads | `supported` | `none` | Load reference from local variable 1 |
| `0x2c` | `aload_2` | Loads | `supported` | `none` | Load reference from local variable 2 |
| `0x2d` | `aload_3` | Loads | `supported` | `none` | Load reference from local variable 3 |
| `0x2e` | `iaload` | Loads | `unsupported` | `none` | Load int from array |
| `0x2f` | `laload` | Loads | `unsupported` | `none` | Load long from array |
| `0x30` | `faload` | Loads | `unsupported` | `none` | Load float from array |
| `0x31` | `daload` | Loads | `unsupported` | `none` | Load double from array |
| `0x32` | `aaload` | Loads | `unsupported` | `none` | Load reference from array |
| `0x33` | `baload` | Loads | `unsupported` | `none` | Load byte or boolean from array |
| `0x34` | `caload` | Loads | `unsupported` | `none` | Load char from array |
| `0x35` | `saload` | Loads | `unsupported` | `none` | Load short from array |
| `0x36` | `istore` | Stores | `supported` | `pass(MathTest)` | Store int into local variable |
| `0x37` | `lstore` | Stores | `unsupported` | `none` | Store long into local variable |
| `0x38` | `fstore` | Stores | `unsupported` | `none` | Store float into local variable |
| `0x39` | `dstore` | Stores | `unsupported` | `none` | Store double into local variable |
| `0x3a` | `astore` | Stores | `supported` | `none` | Store reference into local variable |
| `0x3b` | `istore_0` | Stores | `supported` | `none` | Store int into local variable 0 |
| `0x3c` | `istore_1` | Stores | `supported` | `pass(MathTest)` | Store int into local variable 1 |
| `0x3d` | `istore_2` | Stores | `supported` | `pass(MathTest)` | Store int into local variable 2 |
| `0x3e` | `istore_3` | Stores | `supported` | `pass(MathTest)` | Store int into local variable 3 |
| `0x3f` | `lstore_0` | Stores | `unsupported` | `none` | Store long into local variable 0 |
| `0x40` | `lstore_1` | Stores | `unsupported` | `none` | Store long into local variable 1 |
| `0x41` | `lstore_2` | Stores | `unsupported` | `none` | Store long into local variable 2 |
| `0x42` | `lstore_3` | Stores | `unsupported` | `none` | Store long into local variable 3 |
| `0x43` | `fstore_0` | Stores | `unsupported` | `none` | Store float into local variable 0 |
| `0x44` | `fstore_1` | Stores | `unsupported` | `none` | Store float into local variable 1 |
| `0x45` | `fstore_2` | Stores | `unsupported` | `none` | Store float into local variable 2 |
| `0x46` | `fstore_3` | Stores | `unsupported` | `none` | Store float into local variable 3 |
| `0x47` | `dstore_0` | Stores | `unsupported` | `none` | Store double into local variable 0 |
| `0x48` | `dstore_1` | Stores | `unsupported` | `none` | Store double into local variable 1 |
| `0x49` | `dstore_2` | Stores | `unsupported` | `none` | Store double into local variable 2 |
| `0x4a` | `dstore_3` | Stores | `unsupported` | `none` | Store double into local variable 3 |
| `0x4b` | `astore_0` | Stores | `supported` | `none` | Store reference into local variable 0 |
| `0x4c` | `astore_1` | Stores | `supported` | `none` | Store reference into local variable 1 |
| `0x4d` | `astore_2` | Stores | `supported` | `none` | Store reference into local variable 2 |
| `0x4e` | `astore_3` | Stores | `supported` | `none` | Store reference into local variable 3 |
| `0x4f` | `iastore` | Stores | `unsupported` | `none` | Store int into array |
| `0x50` | `lastore` | Stores | `unsupported` | `none` | Store long into array |
| `0x51` | `fastore` | Stores | `unsupported` | `none` | Store float into array |
| `0x52` | `dastore` | Stores | `unsupported` | `none` | Store double into array |
| `0x53` | `aastore` | Stores | `unsupported` | `none` | Store reference into array |
| `0x54` | `bastore` | Stores | `unsupported` | `none` | Store byte or boolean into array |
| `0x55` | `castore` | Stores | `unsupported` | `none` | Store char into array |
| `0x56` | `sastore` | Stores | `unsupported` | `none` | Store short into array |
| `0x57` | `pop` | Stack | `supported` | `none` | Pop the top operand stack value |
| `0x58` | `pop2` | Stack | `unsupported` | `none` | Pop the top one or two operand stack values |
| `0x59` | `dup` | Stack | `supported` | `none` | Duplicate the top operand stack value |
| `0x5a` | `dup_x1` | Stack | `unsupported` | `none` | Duplicate the top operand stack value and insert two values down |
| `0x5b` | `dup_x2` | Stack | `unsupported` | `none` | Duplicate the top operand stack value and insert three values down |
| `0x5c` | `dup2` | Stack | `unsupported` | `none` | Duplicate the top one or two operand stack values |
| `0x5d` | `dup2_x1` | Stack | `unsupported` | `none` | Duplicate the top one or two operand stack values and insert two values down |
| `0x5e` | `dup2_x2` | Stack | `unsupported` | `none` | Duplicate the top one or two operand stack values and insert three values down |
| `0x5f` | `swap` | Stack | `unsupported` | `none` | Swap the top two operand stack values |
| `0x60` | `iadd` | Math | `supported` | `pass(MathTest,Fibonacci)` | Add int |
| `0x61` | `ladd` | Math | `unsupported` | `none` | Add long |
| `0x62` | `fadd` | Math | `unsupported` | `none` | Add float |
| `0x63` | `dadd` | Math | `unsupported` | `none` | Add double |
| `0x64` | `isub` | Math | `supported` | `pass(MathTest,Fibonacci)` | Subtract int |
| `0x65` | `lsub` | Math | `unsupported` | `none` | Subtract long |
| `0x66` | `fsub` | Math | `unsupported` | `none` | Subtract float |
| `0x67` | `dsub` | Math | `unsupported` | `none` | Subtract double |
| `0x68` | `imul` | Math | `supported` | `pass(MathTest)` | Multiply int |
| `0x69` | `lmul` | Math | `unsupported` | `none` | Multiply long |
| `0x6a` | `fmul` | Math | `unsupported` | `none` | Multiply float |
| `0x6b` | `dmul` | Math | `unsupported` | `none` | Multiply double |
| `0x6c` | `idiv` | Math | `supported` | `pass(MathTest)` | Divide int |
| `0x6d` | `ldiv` | Math | `unsupported` | `none` | Divide long |
| `0x6e` | `fdiv` | Math | `unsupported` | `none` | Divide float |
| `0x6f` | `ddiv` | Math | `unsupported` | `none` | Divide double |
| `0x70` | `irem` | Math | `unsupported` | `none` | Remainder int |
| `0x71` | `lrem` | Math | `unsupported` | `none` | Remainder long |
| `0x72` | `frem` | Math | `unsupported` | `none` | Remainder float |
| `0x73` | `drem` | Math | `unsupported` | `none` | Remainder double |
| `0x74` | `ineg` | Math | `unsupported` | `none` | Negate int |
| `0x75` | `lneg` | Math | `unsupported` | `none` | Negate long |
| `0x76` | `fneg` | Math | `unsupported` | `none` | Negate float |
| `0x77` | `dneg` | Math | `unsupported` | `none` | Negate double |
| `0x78` | `ishl` | Math | `unsupported` | `none` | Shift left int |
| `0x79` | `lshl` | Math | `unsupported` | `none` | Shift left long |
| `0x7a` | `ishr` | Math | `unsupported` | `none` | Arithmetic shift right int |
| `0x7b` | `lshr` | Math | `unsupported` | `none` | Arithmetic shift right long |
| `0x7c` | `iushr` | Math | `unsupported` | `none` | Logical shift right int |
| `0x7d` | `lushr` | Math | `unsupported` | `none` | Logical shift right long |
| `0x7e` | `iand` | Math | `unsupported` | `none` | Boolean AND int |
| `0x7f` | `land` | Math | `unsupported` | `none` | Boolean AND long |
| `0x80` | `ior` | Math | `unsupported` | `none` | Boolean OR int |
| `0x81` | `lor` | Math | `unsupported` | `none` | Boolean OR long |
| `0x82` | `ixor` | Math | `unsupported` | `none` | Boolean XOR int |
| `0x83` | `lxor` | Math | `unsupported` | `none` | Boolean XOR long |
| `0x84` | `iinc` | Math | `supported` | `pass(MathTest)` | Increment local variable by constant |
| `0x85` | `i2l` | Conversions | `unsupported` | `none` | Convert int to long |
| `0x86` | `i2f` | Conversions | `unsupported` | `none` | Convert int to float |
| `0x87` | `i2d` | Conversions | `unsupported` | `none` | Convert int to double |
| `0x88` | `l2i` | Conversions | `unsupported` | `none` | Convert long to int |
| `0x89` | `l2f` | Conversions | `unsupported` | `none` | Convert long to float |
| `0x8a` | `l2d` | Conversions | `unsupported` | `none` | Convert long to double |
| `0x8b` | `f2i` | Conversions | `unsupported` | `none` | Convert float to int |
| `0x8c` | `f2l` | Conversions | `unsupported` | `none` | Convert float to long |
| `0x8d` | `f2d` | Conversions | `unsupported` | `none` | Convert float to double |
| `0x8e` | `d2i` | Conversions | `unsupported` | `none` | Convert double to int |
| `0x8f` | `d2l` | Conversions | `unsupported` | `none` | Convert double to long |
| `0x90` | `d2f` | Conversions | `unsupported` | `none` | Convert double to float |
| `0x91` | `i2b` | Conversions | `unsupported` | `none` | Convert int to byte |
| `0x92` | `i2c` | Conversions | `unsupported` | `none` | Convert int to char |
| `0x93` | `i2s` | Conversions | `unsupported` | `none` | Convert int to short |
| `0x94` | `lcmp` | Comparisons | `unsupported` | `none` | Compare long |
| `0x95` | `fcmpl` | Comparisons | `unsupported` | `none` | Compare float (less than on NaN) |
| `0x96` | `fcmpg` | Comparisons | `unsupported` | `none` | Compare float (greater than on NaN) |
| `0x97` | `dcmpl` | Comparisons | `unsupported` | `none` | Compare double (less than on NaN) |
| `0x98` | `dcmpg` | Comparisons | `unsupported` | `none` | Compare double (greater than on NaN) |
| `0x99` | `ifeq` | Comparisons | `supported` | `pass(MathTest)` | Branch if int comparison with zero succeeds (== 0) |
| `0x9a` | `ifne` | Comparisons | `supported` | `pass(MathTest)` | Branch if int comparison with zero succeeds (!= 0) |
| `0x9b` | `iflt` | Comparisons | `supported` | `pass(MathTest)` | Branch if int comparison with zero succeeds (< 0) |
| `0x9c` | `ifge` | Comparisons | `supported` | `pass(MathTest)` | Branch if int comparison with zero succeeds (>= 0) |
| `0x9d` | `ifgt` | Comparisons | `supported` | `pass(MathTest)` | Branch if int comparison with zero succeeds (> 0) |
| `0x9e` | `ifle` | Comparisons | `supported` | `pass(MathTest)` | Branch if int comparison with zero succeeds (<= 0) |
| `0x9f` | `if_icmpeq` | Comparisons | `supported` | `pass(MathTest)` | Branch if int comparison succeeds (==) |
| `0xa0` | `if_icmpne` | Comparisons | `supported` | `pass(MathTest)` | Branch if int comparison succeeds (!=) |
| `0xa1` | `if_icmplt` | Comparisons | `supported` | `pass(MathTest)` | Branch if int comparison succeeds (<) |
| `0xa2` | `if_icmpge` | Comparisons | `supported` | `pass(MathTest)` | Branch if int comparison succeeds (>=) |
| `0xa3` | `if_icmpgt` | Comparisons | `supported` | `pass(MathTest,Fibonacci)` | Branch if int comparison succeeds (>) |
| `0xa4` | `if_icmple` | Comparisons | `supported` | `pass(MathTest)` | Branch if int comparison succeeds (<=) |
| `0xa5` | `if_acmpeq` | Comparisons | `unsupported` | `none` | Branch if reference comparison succeeds (==) |
| `0xa6` | `if_acmpne` | Comparisons | `unsupported` | `none` | Branch if reference comparison succeeds (!=) |
| `0xa7` | `goto` | Control | `supported` | `pass(MathTest)` | Branch always |
| `0xa8` | `jsr` | Control | `unsupported` | `none` | Jump subroutine |
| `0xa9` | `ret` | Control | `unsupported` | `none` | Return from subroutine |
| `0xaa` | `tableswitch` | Control | `unsupported` | `none` | Access jump table by index and jump |
| `0xab` | `lookupswitch` | Control | `unsupported` | `none` | Access jump table by key match and jump |
| `0xac` | `ireturn` | Control | `supported` | `pass(Fibonacci)` | Return int from method |
| `0xad` | `lreturn` | Control | `unsupported` | `none` | Return long from method |
| `0xae` | `freturn` | Control | `unsupported` | `none` | Return float from method |
| `0xaf` | `dreturn` | Control | `unsupported` | `none` | Return double from method |
| `0xb0` | `areturn` | Control | `supported` | `none` | Return reference from method |
| `0xb1` | `return` | Control | `supported` | `pass(HelloWorld,MathTest)` | Return void from method |
| `0xb2` | `getstatic` | References | `supported` | `pass(HelloWorld,MathTest)` | Get static field from class |
| `0xb3` | `putstatic` | References | `supported` | `none` | Set static field in class |
| `0xb4` | `getfield` | References | `supported` | `none` | Fetch field from object |
| `0xb5` | `putfield` | References | `supported` | `none` | Set field in object |
| `0xb6` | `invokevirtual` | Invokes | `supported` | `pass(HelloWorld,MathTest)` | Invoke instance method; dispatch based on class |
| `0xb7` | `invokespecial` | Invokes | `supported` | `none` | Invoke instance method; direct invocation of superclass, private, or constructor |
| `0xb8` | `invokestatic` | Invokes | `supported` | `pass(Fibonacci)` | Invoke a class (static) method |
| `0xb9` | `invokeinterface` | Invokes | `unsupported` | `none` | Invoke interface method |
| `0xba` | `invokedynamic` | Invokes | `unsupported` | `none` | Invoke a dynamic call site |
| `0xbb` | `new` | References | `supported` | `none` | Create new object |
| `0xbc` | `newarray` | References | `unsupported` | `none` | Create new array of primitive type |
| `0xbd` | `anewarray` | References | `unsupported` | `none` | Create new array of reference type |
| `0xbe` | `arraylength` | Extended | `unsupported` | `none` | Get length of array |
| `0xbf` | `athrow` | Extended | `unsupported` | `none` | Throw exception or error |
| `0xc0` | `checkcast` | Extended | `unsupported` | `none` | Check whether object is of given type |
| `0xc1` | `instanceof` | Extended | `unsupported` | `none` | Determine if object is of given type |
| `0xc2` | `monitorenter` | Extended | `out-of-scope` | `n/a` | Enter monitor for object (no multithreading support) |
| `0xc3` | `monitorexit` | Extended | `out-of-scope` | `n/a` | Exit monitor for object (no multithreading support) |
| `0xc4` | `wide` | Extended | `unsupported` | `none` | Extend local variable index by additional bytes |
| `0xc5` | `multianewarray` | Extended | `unsupported` | `none` | Create new multidimensional array |
| `0xc6` | `ifnull` | Extended | `unsupported` | `none` | Branch if reference is null |
| `0xc7` | `ifnonnull` | Extended | `unsupported` | `none` | Branch if reference is not null |
| `0xc8` | `goto_w` | Control | `unsupported` | `none` | Branch always (wide index) |
| `0xc9` | `jsr_w` | Control | `unsupported` | `none` | Jump subroutine (wide index) |
| `0xca` | `breakpoint` | Extended | `reserved` | `n/a` | Reserved debugger breakpoint instruction |
| `0xcb` | `unused_cb` | Extended | `unsupported` | `none` | Unused byte value 0xcb |
| `0xcc` | `unused_cc` | Extended | `unsupported` | `none` | Unused byte value 0xcc |
| `0xcd` | `unused_cd` | Extended | `unsupported` | `none` | Unused byte value 0xcd |
| `0xce` | `unused_ce` | Extended | `unsupported` | `none` | Unused byte value 0xce |
| `0xcf` | `unused_cf` | Extended | `unsupported` | `none` | Unused byte value 0xcf |
| `0xd0` | `unused_d0` | Extended | `unsupported` | `none` | Unused byte value 0xd0 |
| `0xd1` | `unused_d1` | Extended | `unsupported` | `none` | Unused byte value 0xd1 |
| `0xd2` | `unused_d2` | Extended | `unsupported` | `none` | Unused byte value 0xd2 |
| `0xd3` | `unused_d3` | Extended | `unsupported` | `none` | Unused byte value 0xd3 |
| `0xd4` | `unused_d4` | Extended | `unsupported` | `none` | Unused byte value 0xd4 |
| `0xd5` | `unused_d5` | Extended | `unsupported` | `none` | Unused byte value 0xd5 |
| `0xd6` | `unused_d6` | Extended | `unsupported` | `none` | Unused byte value 0xd6 |
| `0xd7` | `unused_d7` | Extended | `unsupported` | `none` | Unused byte value 0xd7 |
| `0xd8` | `unused_d8` | Extended | `unsupported` | `none` | Unused byte value 0xd8 |
| `0xd9` | `unused_d9` | Extended | `unsupported` | `none` | Unused byte value 0xd9 |
| `0xda` | `unused_da` | Extended | `unsupported` | `none` | Unused byte value 0xda |
| `0xdb` | `unused_db` | Extended | `unsupported` | `none` | Unused byte value 0xdb |
| `0xdc` | `unused_dc` | Extended | `unsupported` | `none` | Unused byte value 0xdc |
| `0xdd` | `unused_dd` | Extended | `unsupported` | `none` | Unused byte value 0xdd |
| `0xde` | `unused_de` | Extended | `unsupported` | `none` | Unused byte value 0xde |
| `0xdf` | `unused_df` | Extended | `unsupported` | `none` | Unused byte value 0xdf |
| `0xe0` | `unused_e0` | Extended | `unsupported` | `none` | Unused byte value 0xe0 |
| `0xe1` | `unused_e1` | Extended | `unsupported` | `none` | Unused byte value 0xe1 |
| `0xe2` | `unused_e2` | Extended | `unsupported` | `none` | Unused byte value 0xe2 |
| `0xe3` | `unused_e3` | Extended | `unsupported` | `none` | Unused byte value 0xe3 |
| `0xe4` | `unused_e4` | Extended | `unsupported` | `none` | Unused byte value 0xe4 |
| `0xe5` | `unused_e5` | Extended | `unsupported` | `none` | Unused byte value 0xe5 |
| `0xe6` | `unused_e6` | Extended | `unsupported` | `none` | Unused byte value 0xe6 |
| `0xe7` | `unused_e7` | Extended | `unsupported` | `none` | Unused byte value 0xe7 |
| `0xe8` | `unused_e8` | Extended | `unsupported` | `none` | Unused byte value 0xe8 |
| `0xe9` | `unused_e9` | Extended | `unsupported` | `none` | Unused byte value 0xe9 |
| `0xea` | `unused_ea` | Extended | `unsupported` | `none` | Unused byte value 0xea |
| `0xeb` | `unused_eb` | Extended | `unsupported` | `none` | Unused byte value 0xeb |
| `0xec` | `unused_ec` | Extended | `unsupported` | `none` | Unused byte value 0xec |
| `0xed` | `unused_ed` | Extended | `unsupported` | `none` | Unused byte value 0xed |
| `0xee` | `unused_ee` | Extended | `unsupported` | `none` | Unused byte value 0xee |
| `0xef` | `unused_ef` | Extended | `unsupported` | `none` | Unused byte value 0xef |
| `0xf0` | `unused_f0` | Extended | `unsupported` | `none` | Unused byte value 0xf0 |
| `0xf1` | `unused_f1` | Extended | `unsupported` | `none` | Unused byte value 0xf1 |
| `0xf2` | `unused_f2` | Extended | `unsupported` | `none` | Unused byte value 0xf2 |
| `0xf3` | `unused_f3` | Extended | `unsupported` | `none` | Unused byte value 0xf3 |
| `0xf4` | `unused_f4` | Extended | `unsupported` | `none` | Unused byte value 0xf4 |
| `0xf5` | `unused_f5` | Extended | `unsupported` | `none` | Unused byte value 0xf5 |
| `0xf6` | `unused_f6` | Extended | `unsupported` | `none` | Unused byte value 0xf6 |
| `0xf7` | `unused_f7` | Extended | `unsupported` | `none` | Unused byte value 0xf7 |
| `0xf8` | `unused_f8` | Extended | `unsupported` | `none` | Unused byte value 0xf8 |
| `0xf9` | `unused_f9` | Extended | `unsupported` | `none` | Unused byte value 0xf9 |
| `0xfa` | `unused_fa` | Extended | `unsupported` | `none` | Unused byte value 0xfa |
| `0xfb` | `unused_fb` | Extended | `unsupported` | `none` | Unused byte value 0xfb |
| `0xfc` | `unused_fc` | Extended | `unsupported` | `none` | Unused byte value 0xfc |
| `0xfd` | `unused_fd` | Extended | `unsupported` | `none` | Unused byte value 0xfd |
| `0xfe` | `impdep1` | Extended | `reserved` | `n/a` | Reserved implementation-dependent instruction 1 |
| `0xff` | `impdep2` | Extended | `reserved` | `n/a` | Reserved implementation-dependent instruction 2 |
