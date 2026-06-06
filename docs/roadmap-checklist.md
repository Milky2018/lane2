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
- [x] Keep compiler identity and substitution internals behind public APIs
  instead of exposing raw indices or backing arrays.

## 2. Name Resolution

- [x] Collect top-level declarations, nominal members, parameters, and type
  parameters into separated symbol identities while preserving display names
  and origin spans.
- [x] Provide an initial resolved IR pretty printer and tests based on resolved
  declaration output.
- [x] Resolve source type references, value references, qualified variants,
  patterns, function bodies, and expression-local binders into resolved IR.
- [x] Resolve unqualified variant calls when exactly one visible variant
  matches, and preserve ambiguous candidates in resolved IR.
- [x] Resolve direct `open` and named open bindings for values with explicit
  nominal struct type annotations.
- [x] Resolve field access into field symbol identities after enough type
  information is available.
- [x] Resolve struct field forwarding after checked field types are available.
- [x] Resolve operator aliases through ordinary operation names and open
  candidate sets.
- [x] Report diagnostics for unresolved types, unresolved values, unresolved
  qualified variants, ambiguous unqualified variants, and invalid `open`
  targets.
- [x] Preserve repeated open and preopen exposures as candidate sets for
  use-site disambiguation.
- [x] Extend resolved IR pretty tests to cover expression and pattern
  resolution once those nodes carry symbols.

## 3. Semantic Checking

- [x] Build the checked declaration environment for custom types, including
  struct field types and enum variant payload types.
- [x] Introduce the first source-level semantic checker slice for annotated
  values, direct calls, blocks, struct literals, and opened fields.
- [x] Introduce type-directed candidate selection as an internal checker
  package for expected-type and call-argument disambiguation.
- [ ] Implement bidirectional local type checking and direct context inference.
- [ ] Ensure candidate sets are eliminated by checking: every resolved value
  candidate use must either select one concrete reference or produce a stable
  ambiguity diagnostic.
- [ ] Check top-level recursive groups, ordered top-level values, local
  sequential bindings, and local generic functions.
- [ ] Check generic instantiation, forall introduction/elimination, generic
  candidate instantiation, primitive operations, nominal construction, and
  field access.
- [ ] Check enum variant construction and unqualified variant calls after type
  information is available.
- [ ] Check `if`, `match`, pipeline, operator aliases, and `&&` / `||` source
  semantics before semantic lowering.
- [ ] Elaborate builtin expressions into typed unsafe builtins without
  interpreting intrinsic names.
- Pattern analysis:
  - [ ] Use a pattern matrix model for exhaustiveness and usefulness checking.
  - [ ] Check primitive literal patterns, enum patterns, struct patterns,
    binder uniqueness, binder scope, and unreachable arms.
  - [ ] Produce checked patterns with resolved variants, resolved struct
    fields, declaration-order struct fields, and typed binders.
  - [ ] Keep checked patterns available for typed core.
  - [ ] Defer decision tree generation to later lowered IR or VM work.
- [ ] Produce a typed source-level semantic result that contains no unresolved
  names, open candidate sets, or source-only ambiguity states.
- [ ] Produce stable diagnostics with origin spans.

## 4. Typed Core ANF

- [ ] Define the typed core program representation after the source-level
  semantic checker has a closed typed result.
- [ ] Lower checked source semantics into structured ANF with typed nodes and
  origin spans.
- [ ] Preserve nominal data, first-class functions, type lambdas, type
  applications, checked patterns, and typed unsafe builtins.
- [ ] Remove source-only constructs such as pipeline, open/preopen lookup,
  candidate sets, and ordinary operator aliases.
- [ ] Lower `&&` and `||` into thunked operator calls according to the checked
  operator selection.
- [ ] Provide a typed core pretty printer and tests based on typed core output.

## 5. Reference Interpreter

- [ ] Evaluate whole typed core programs without hard-coding `main`.
- [ ] Use uniform interpreter values, global environments, call frames, and
  closure environments.
- [ ] Evaluate first-class calls, type lambdas/applications with runtime type
  erasure, nominal data, checked patterns, conditionals, and matches.
- [ ] Define the builtin runtime plugin contract and runtime error reports.
- [ ] Use the interpreter as the semantic oracle for later execution targets.

## 6. Prelude And Conformance

- [ ] Encode and check the v1 prelude as Lane2 source.
- [ ] Populate the initial preopen namespace from prelude-provided open
  bindings.
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
