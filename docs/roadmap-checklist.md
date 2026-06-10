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

## 3. Type Checking

Local type inference is implemented as two source-level judgments: synthesis
computes a type from an expression, and checking verifies an expression against
an expected type. It must not introduce Hindley-Milner-style global unification
state. Lane2's open overload resolution is an extension layer over these local
typing judgments.

- [x] Move the type-checking engine into the dedicated `lanec/typecheck`
  package, with no compatibility wrapper under `lanec/check`.
- [x] Build the checked declaration environment for custom types, including
  struct field types and enum variant payload types.
- [x] Introduce the first source-level type checker slice for annotated
  values, direct calls, blocks, struct literals, and opened fields.
- [x] Introduce type-directed candidate selection as an internal type-checker
  package for expected-type and call-argument disambiguation.
- [x] Propagate expected types through function bodies, block results, `if`
  branches, and known call parameters to drive local candidate selection.
- [x] Check unary and non-thunked binary operator aliases as calls to resolved
  `op_*` values, including open candidate selection by operand types.
- [x] Reframe the checker around explicit synthesis (`synthesize(expr) -> T`)
  and checking (`check(expr, expected)`) judgments.
- [x] Implement non-generic bidirectional local checking for function literals,
  calls, blocks, `if` branches, struct literals, field access, and non-thunked
  operator aliases.
- [x] Treat open overload selection as a candidate layer over local typing
  derivations: each viable candidate must type-check under the same local
  context, and multiple viable candidates remain ambiguous.
- [x] Implement local type argument synthesis for generic applications,
  including constraints from argument types and expected result types in
  checking mode.
- [x] Ensure candidate sets are eliminated by checking: every resolved value
  candidate use must either select one concrete reference or produce a stable
  ambiguity diagnostic.
- [x] Check top-level recursive groups, ordered top-level values, local
  sequential bindings, and local generic functions.
- [x] Check forall introduction/elimination, generic candidate instantiation,
  primitive operations, nominal construction, and field access.
- [x] Check enum variant construction and unqualified variant calls after type
  information is available.
- Pattern analysis:
  - [ ] Use a pattern matrix model for exhaustiveness and usefulness checking.
  - [ ] Check primitive literal patterns, enum patterns, struct patterns,
    binder uniqueness, binder scope, and unreachable arms.
  - [ ] Produce checked patterns with resolved variants, resolved struct
    fields, declaration-order struct fields, and typed binders.
  - [ ] Keep checked patterns available for typed core.
  - [ ] Defer decision tree generation to later lowered IR or VM work.
- [ ] Produce stable diagnostics with origin spans.

## 4. Source Elaboration

Source elaboration consumes the type checker and produces the Checked Source
AST. It preserves source-level structure while eliminating source-only syntax
and unresolved or ambiguous states before typed core lowering.

- [x] Create the `lanec/checked` package as the owner of the Checked Source
  AST.
- [x] Define checked expressions, checked local items, checked top-level bodies,
  checked match arms, and checked patterns with attached types and origin spans.
- [x] Provide a Checked Source pretty printer and snapshot tests for the initial
  checked expression and pattern shapes.
- [ ] Implement `lanec/elaborate` as the source-to-checked pipeline over
  resolved source and type-checking judgments.
- [ ] Elaborate pipeline expressions into ordinary checked calls.
- [ ] Elaborate ordinary operator aliases into resolved checked calls.
- [ ] Elaborate `&&` and `||` into checked thunked calls to `op_and` and
  `op_or`.
- [ ] Elaborate builtin expressions into typed unsafe builtins without
  interpreting intrinsic names.
- [ ] Integrate checked-source lowering with the resolved-to-checked source
  elaboration pipeline.
- [ ] Produce a typed source-level result that contains no unresolved names,
  open candidate sets, or source-only ambiguity states.

## 5. Typed Core ANF

- [ ] Define the typed core program representation after the source-level
  elaborator has a closed typed result.
- [ ] Lower checked source semantics into structured ANF with typed nodes and
  origin spans.
- [ ] Preserve nominal data, first-class functions, type lambdas, type
  applications, checked patterns, and typed unsafe builtins.
- [ ] Remove source-only constructs such as pipeline, open/preopen lookup,
  candidate sets, and ordinary operator aliases.
- [ ] Lower `&&` and `||` into thunked operator calls according to the checked
  operator selection.
- [ ] Provide a typed core pretty printer and tests based on typed core output.

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
- [ ] Populate the initial preopen namespace from prelude-provided open
  bindings.
- [ ] Provide required intrinsic implementations through builtin runtime
  plugins.
- [ ] Expand valid and invalid conformance fixtures under `spec/examples`.
- [ ] Run parser, type checker, elaborator, and interpreter tests over shared
  fixtures where practical.

## Later Execution Work

- [ ] Lowered IR for closure conversion, decision trees, and execution layout.
- [ ] Portable bytecode VM.
- [ ] Linker entrypoint selection.
- [ ] Algebraic effects and handlers.
- [ ] Direct native, WebAssembly, or JavaScript execution targets.
- [ ] Optional monomorphization and specialized runtime layouts.
