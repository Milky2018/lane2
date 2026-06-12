# Lane2 Compiler Pipeline

This context names compiler identity, IR, and lowering concepts from parsing to
Buslane and ANF.

## Language

**Syntax AST**:
The source-shaped tree produced from Lane2 concrete syntax.
_Avoid_: typed tree, core IR

**Resolved AST**:
A source-shaped tree whose names, variants, and operator aliases have been resolved.
_Avoid_: parsed AST, Buslane Core Language

**Checked Source AST**:
The typed, symbol-resolved source tree produced by Source Elaboration before lowering to Buslane Core Language.
_Avoid_: ANF IR, resolved surface AST, environment-only check result

**Source-Level Structure**:
The expression structure of the source language, such as blocks, conditionals, matches, calls, literals, and function literals, preserved before ANF lowering.
_Avoid_: atomized core shape, source-only syntax, basic blocks

**Source Elaboration**:
The source-level checking phase that turns resolved surface syntax into checked source syntax by removing source-only forms and selecting concrete symbols.
_Avoid_: pure desugaring, Buslane lowering

**Semantic Lowering**:
The transformation from Checked Source AST into Buslane Core Language.
_Avoid_: source elaboration, parsing, bytecode generation

**Buslane Core Language**:
The typed expression-tree core language produced from Checked Source AST before ANF normalization.
_Avoid_: source AST, checked source AST, ANF IR, bytecode, VM instruction format

**Buslane Node**:
A Buslane expression or declaration whose type is explicitly available after type checking.
_Avoid_: ANF node, untyped expression, source syntax node

**ANF Lowering**:
The transformation from Buslane Core Language into ANF IR.
_Avoid_: semantic lowering, source elaboration, bytecode generation

**ANF IR**:
The typed Structured ANF representation produced from Buslane Core Language while preserving Lane2/Core semantics.
_Avoid_: source AST, checked source AST, bytecode, VM instruction format

**ANF Node**:
A typed ANF expression, binding, atom, or right-hand side whose type is explicitly available after type checking.
_Avoid_: Buslane node, re-inferred node, untyped expression

**Administrative Normal Form**:
An intermediate representation shape where non-trivial computations are named so that evaluation order is explicit.
_Avoid_: CPS, bytecode

**Structured ANF**:
An Administrative Normal Form that keeps structured conditionals and matches while requiring their inputs and calls to use atomic values.
_Avoid_: CFG, basic blocks, jump IR

**ANF Atom**:
A typed ANF value form that can be referenced without introducing additional evaluation order.
_Avoid_: arbitrary expression, computed RHS

**Nominal Core Data**:
Buslane or ANF data that retains its struct or enum constructor identity.
_Avoid_: anonymous tuple, raw tag

**Dedicated Data Constructor**:
A Buslane or ANF construction form for nominal struct or enum data that is not a first-class function value.
_Avoid_: constructor function, curried constructor

**Declaration-Order Struct Construction**:
A Buslane or ANF struct construction whose field values are ordered by the struct declaration.
_Avoid_: source-order field construction, string-key record

**Resolved Variant Construction**:
A Buslane or ANF enum construction that references a variant by variant symbol identity and stores payloads in declaration order.
_Avoid_: string variant lookup, raw tag only

**Resolved Field Access**:
A Buslane field access that references a field by field symbol identity.
_Avoid_: string field lookup, raw field index only

**First-Class Call**:
A Buslane call whose callee is any function-valued expression rather than only a known function symbol.
_Avoid_: direct-call-only core, method dispatch

**Symbol Identity**:
A stable compiler identity for a resolved type, value, constructor, or local binding.
_Avoid_: source spelling, de Bruijn-only identity

**Separated Symbol Identity**:
Distinct compiler identity types for different namespaces such as type, value, field, and variant symbols.
_Avoid_: kind-tagged universal symbol id, string namespace

**Nominal Type Symbol**:
A type-namespace symbol identity for a declared struct or enum type constructor.
_Avoid_: type parameter, source type name

**Type Parameter Identity**:
A compiler identity for a type parameter introduced by a generic binder.
_Avoid_: nominal type symbol, erased runtime type

**Value Symbol**:
A value-namespace symbol identity for top-level values, functions, parameters, local bindings, local functions, and pattern binders.
_Avoid_: function-only id, parameter-only id

**Owned Symbol Metadata**:
Compiler metadata that records the nominal owner of a globally unique field or variant symbol.
_Avoid_: locally indexed field only, ownerless constructor

**Separated Namespaces**:
The rule that type names and value names are resolved in distinct namespaces and may use the same spelling without conflict.
_Avoid_: single namespace, unrestricted shadowing

**Origin Span**:
A diagnostic annotation that links resolved or core IR back to source text.
_Avoid_: semantic location, runtime value

**IR Pretty Printer**:
A stable human-readable printer for an intermediate representation used in diagnostics and tests.
_Avoid_: debug dump, unstable snapshot

**Closure Conversion**:
A lowering step that makes captured lexical variables explicit in function values.
_Avoid_: type checking, name resolution

## Relationships

- A **Syntax AST** is resolved into a **Resolved AST** before type checking.
- A **Resolved AST** attaches **Symbol Identity** to resolved names while preserving source names for diagnostics.
- Lane2 compiler IR uses **Separated Symbol Identity** and **Separated Namespaces**.
- **Source Elaboration** consumes type checking information and produces a **Checked Source AST**.
- A **Checked Source AST** preserves **Source-Level Structure** while removing source-only syntax and unresolved or ambiguous references.
- **Semantic Lowering** transforms a **Checked Source AST** into **Buslane Core Language**.
- **Buslane Core Language** preserves expression-tree structure and does not introduce ANF temporaries.
- **ANF Lowering** transforms **Buslane Core Language** into **ANF IR**.
- **ANF IR** uses **Administrative Normal Form** and **Structured ANF**, not basic blocks.
- **Buslane Core Language** and **ANF IR** represent structs and enums as **Nominal Core Data**.
- **Nominal Core Data** is introduced through **Dedicated Data Constructors**.
- Struct values use **Declaration-Order Struct Construction**.
- Enum values use **Resolved Variant Construction**.
- Every compiler IR layer has an **IR Pretty Printer**.
- **Closure Conversion** happens after **Buslane Core Language**, usually after ANF lowering.

## Example dialogue

> **Dev:** "Can Buslane introduce temporaries for every call?"
> **Domain expert:** "No. That is **ANF Lowering**. **Buslane Core Language** keeps expression-tree structure."
