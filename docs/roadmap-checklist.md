# Lane2 Compiler Roadmap Checklist

This checklist tracks the main implementation phases after the lexer, parser,
syntax AST, and syntax pretty printer. It is intentionally high-level; detailed
module tasks should live in issues or implementation notes.

## Baseline

- [x] Workspace layout for `spec`, `lanec`, `lane-tools`, and `lane-std`.
- [x] Lexer and parser.
- [x] Syntax AST and syntax pretty printer.
- [x] Parser tests based on pretty-printed output.

## 1. Compiler Identity And Types

- [x] Introduce stable compiler identities for types, values, fields, variants,
  and type parameters.
- [x] Introduce checked type objects shared by semantic analysis, typed core,
  builtin dispatch, and the interpreter.
- [x] Support primitive type constants, nominal type applications, function
  types, forall types, kind metadata, substitution, and alpha-equivalence.
- [x] Provide pretty printers and tests for symbols and checked types.

## 2. Name Resolution

- [ ] Resolve source names into separated symbol identities while preserving
  display names and origin spans for diagnostics.
- [ ] Resolve type names, value names, variants, field access, `open`, preopen,
  struct field forwarding, and operator aliases.
- [ ] Reject ambiguous unqualified variants and conflicting open/preopen
  exposure.
- [ ] Provide a resolved IR pretty printer and tests based on resolved output.

## 3. Typed Core ANF

- [ ] Define the typed core program representation.
- [ ] Lower resolved syntax into structured ANF with typed nodes and origin
  spans.
- [ ] Preserve nominal data, first-class functions, type lambdas, type
  applications, checked patterns, and typed unsafe builtins.
- [ ] Remove source-only constructs such as pipeline, open/preopen lookup, and
  ordinary operator aliases.
- [ ] Provide a typed core pretty printer and tests based on typed core output.

## 4. Semantic Checking

- [ ] Implement bidirectional local type checking and direct context inference.
- [ ] Check top-level recursive groups, ordered top-level values, local
  sequential bindings, and local generic functions.
- [ ] Check generic instantiation, forall introduction/elimination, primitive
  operations, nominal construction, and field access.
- [ ] Elaborate builtin expressions into typed unsafe builtins without
  interpreting intrinsic names.
- [ ] Produce stable diagnostics with origin spans.

## 5. Pattern Analysis

- [ ] Use a pattern matrix model for exhaustiveness and usefulness checking.
- [ ] Check primitive literal patterns, enum patterns, struct patterns, binder
  uniqueness, binder scope, and unreachable arms.
- [ ] Keep checked patterns in typed core.
- [ ] Defer decision tree generation to later lowered IR or VM work.

## 6. Reference Interpreter

- [ ] Evaluate whole typed core programs without hard-coding `main`.
- [ ] Use uniform interpreter values, global environments, call frames, and
  closure environments.
- [ ] Evaluate first-class calls, type lambdas/applications with runtime type
  erasure, nominal data, checked patterns, conditionals, and matches.
- [ ] Define the builtin runtime plugin contract and runtime error reports.
- [ ] Use the interpreter as the semantic oracle for later execution targets.

## 7. Prelude And Conformance

- [ ] Encode and check the v1 prelude as Lane2 source.
- [ ] Populate the initial preopen namespace from anonymous top-level values.
- [ ] Provide required intrinsic implementations through builtin runtime
  plugins.
- [ ] Expand valid and invalid conformance fixtures under `spec/examples`.
- [ ] Run parser, semantic checker, and interpreter tests over shared fixtures
  where practical.

## Later Execution Work

- [ ] Lowered IR for closure conversion, decision trees, and execution layout.
- [ ] Portable bytecode VM.
- [ ] Linker entrypoint selection.
- [ ] Algebraic effects and handlers.
- [ ] Direct native, WebAssembly, or JavaScript execution targets.
- [ ] Optional monomorphization and specialized runtime layouts.
