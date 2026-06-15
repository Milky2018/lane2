# Lane2

Lane2 is a personal functional programming language designed around a small,
orthogonal pure core.

## Language

**Pure Core**:
The part of Lane2 where evaluating an expression depends only on its inputs and produces a value without observable side effects.
_Avoid_: mutation-free subset, functional mode

**Specification Project**:
The `spec/` directory containing the formal Typst language specification and language conformance fixtures.
_Avoid_: docs spec draft, compiler tests

**Compiler Project**:
The `lanec/` directory containing the MoonBit compiler implementation.
_Avoid_: toolchain, standard library

**Tools Project**:
The `lane-tools/` directory containing developer tools built around the compiler.
_Avoid_: compiler core, standard library

**Lane Command**:
The unified user-facing command line surface for checking, running, building, and future package workflows.
_Avoid_: separate compiler command, package-manager-only command

**Standard Library Project**:
The `lane-std/` directory containing Lane standard library source.
_Avoid_: MoonBit runtime helpers, compiler builtins

**Prelude**:
The initial language environment that provides primitive types, primitive functions, and default language support before user definitions are checked.
_Avoid_: module system, imports

**Prelude Loading**:
The tool/compiler entry behavior that checks the standard prelude before a single-file user program.
_Avoid_: source import, project module loading

**Algebraic Effect**:
A first-class description of an operation whose meaning is supplied outside the pure expression that invokes it.
_Avoid_: IO hook, builtin side effect

## Relationships

- The **Pure Core** excludes observable effects.
- **Algebraic Effects** are the planned boundary for effectful behavior outside the **Pure Core**.
- The **Specification Project** defines the language contract implemented by the **Compiler Project**.
- The **Tools Project** may depend on platform services; the **Compiler Project** should remain target-independent.
- The **Lane Command** belongs to the **Tools Project** and may delegate to compiler libraries or compiler processes behind one user-facing command.
- The **Standard Library Project** provides Lane source consumed through the **Prelude**.
- **Prelude Loading** is automatic for single-file **Lane Command** checks and runs.

## Example dialogue

> **Dev:** "Should file IO be part of the compiler core?"
> **Domain expert:** "No. The **Pure Core** stays effect-free; IO belongs behind future **Algebraic Effects** and tooling/runtime boundaries."

> **Dev:** "Should users call `lanec` for compilation and `lane` for package workflows?"
> **Domain expert:** "No. **Lane Command** is the unified user-facing command; internal compiler entrypoints are implementation details."
