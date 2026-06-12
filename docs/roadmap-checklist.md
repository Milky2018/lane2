# Lane2 Compiler Roadmap Checklist

This checklist tracks the main compiler pipeline phases. It is intentionally
high-level; detailed module tasks should live in issues or implementation
notes.

Cross-cutting language features are tracked inside the pipeline phases they
affect. Items prefixed with `Existential:` refer to the design note in
`docs/existential-types.md`.

## 0. Source Surface And Specification

- [x] Workspace layout for `spec`, `lanec`, `lane-tools`, and `lane-std`.
- [x] Lexer and parser.
- [x] Syntax AST and syntax pretty printer.
- [x] Parser tests based on pretty-printed output.
- [x] Existential: promote the design into the language specification,
  including formation, introduction, elimination, scope, and escape rules.
- [x] Existential: extend syntax, parser, and pretty printers for enum variant
  type binders such as `hide[T](T)`.
- [x] Existential: extend syntax, parser, and pretty printers for struct type
  members such as `type T : Type`, struct literal type witnesses such as
  `T = Int`, and struct patterns such as `Hide::{ T, val }`.
- [x] Existential: decide and implement the wildcard spelling for ignored
  hidden type binders in struct patterns.

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
- [x] Existential: extend type objects and kind checking so existential
  packages can carry explicit hidden type members while preserving nominal
  struct and enum identity.

## 2. Name Resolution

- [x] Collect top-level declarations, nominal members, parameters, and type
  parameters into separated symbol identities while preserving display names
  and origin spans.
- [x] Provide an initial resolved IR pretty printer and tests based on resolved
  declaration output.
- [x] Resolve source type references, value references, qualified variants,
  patterns, function bodies, and expression-local binders into resolved IR.
- [x] Resolve unqualified variant calls when exactly one visible variant
  matches.
- [x] Remove `open` and `let open` from syntax, resolution, desugaring,
  typechecking, and tests.
- [x] Resolve offered value definitions into a contextual offer environment.
- [x] Resolve field access into field symbol identities after enough type
  information is available.
- [x] Resolve contextual forwarding fields declared with `offer field : Type`
  after checked field types are available.
- [ ] Resolve operator aliases through ordinary operation names while
  preserving call origin metadata for diagnostics.
- [x] Report diagnostics for unresolved types, unresolved values, unresolved
  qualified variants, and ambiguous unqualified variants.
- [ ] Report diagnostics and warnings for invalid offers, duplicate offers,
  missing contextual offers, ambiguous contextual offers, and invalid explicit
  contextual arguments.
- [x] Extend resolved IR pretty tests to cover expression and pattern
  resolution once those nodes carry symbols.
- [x] Existential: add symbol and resolved IR support for existential type
  binders, struct type members, type witness fields, and pattern-opened hidden
  type binders.

## 3. Type Checking

Local type inference is implemented as two source-level judgments: synthesis
computes a type from an expression, and checking verifies an expression against
an expected type. It must not introduce Hindley-Milner-style global unification
state. Contextual Resolution supplies omitted contextual arguments only after
ordinary local typing has determined their target types.

- [x] Move the type-checking engine into the dedicated `lanec/typecheck`
  package, with no compatibility wrapper under `lanec/check`.
- [x] Build the checked declaration environment for custom types, including
  struct field types and enum variant payload types.
- [x] Introduce the first source-level type checker slice for annotated
  values, direct calls, blocks, struct literals, and field access.
- [x] Replace open candidate selection with Contextual Resolution for omitted
  `auto` parameters.
- [x] Propagate expected types through function bodies, block results, `if`
  branches, and known call parameters to drive local checking.
- [x] Check desugared operator alias calls as ordinary calls to resolved `op_*`
  named functions.
- [x] Reframe the checker around explicit synthesis (`synthesize(expr) -> T`)
  and checking (`check(expr, expected)`) judgments.
- [x] Implement non-generic bidirectional local checking for function literals,
  calls, blocks, `if` branches, struct literals, field access, and non-thunked
  operator aliases.
- [x] Check direct named calls with trailing `auto` parameters, explicit
  contextual arguments, and contextually resolved omitted arguments.
- [x] Implement local type argument synthesis for generic applications,
  including constraints from argument types and expected result types in
  checking mode.
- [x] Ensure checked source contains no omitted contextual arguments and no
  contextual offer ambiguity states.
- [x] Check top-level recursive groups, ordered top-level values, local
  sequential bindings, and local generic functions.
- [x] Check forall introduction/elimination, generic candidate instantiation,
  primitive operations, nominal construction, and field access.
- [x] Check enum variant construction and unqualified variant calls after type
  information is available.
- [x] Existential: type check enum construction by choosing witness types and
  checking payloads under the instantiated variant payload type.
- [x] Existential: type check struct construction by checking type-member
  witnesses and value fields against the declared member types.
- [ ] Existential: reject hidden type escape from opened scopes unless the
  value is repacked into another existential before leaving the scope.
- Pattern analysis:
  - [x] Use a pattern matrix model for exhaustiveness and usefulness checking.
  - [x] Check primitive literal patterns, enum patterns, struct patterns,
    binder uniqueness, binder scope, and unreachable arms.
  - [x] Produce checked patterns with resolved variants, resolved struct
    fields, declaration-order struct fields, and typed binders.
  - [x] Keep checked patterns available for typed core.
  - [x] Defer decision tree generation to later lowered IR or VM work.
  - [x] Existential: type check enum and struct pattern elimination by
    introducing fresh abstract type binders into the arm or remaining local
    scope.
- [x] Produce stable diagnostics with origin spans.

## 4. Source Elaboration

Source elaboration consumes the type checker and produces the Checked Source
AST. It preserves source-level structure while eliminating source-only syntax
and unresolved or ambiguous states before typed core lowering.

- [x] Create the `lanec/checked` package as the owner of the Checked Source
  AST.
- [x] Create the `lanec/desugar` package as the owner of the resolved-to-
  desugared AST pass.
- [x] Define checked expressions, checked local items, checked top-level bodies,
  checked match arms, and checked patterns with attached types and origin spans.
- [x] Provide a Checked Source pretty printer and snapshot tests for the initial
  checked expression and pattern shapes.
- [x] Implement `lanec/elaborate` as the source-to-checked pipeline over
  resolved source and type-checking judgments.
- [x] Desugar pipeline expressions into ordinary calls before type checking.
- [x] Desugar ordinary operator aliases into resolved `op_*` calls before type
  checking.
- [x] Desugar `&&` and `||` into thunked calls to `op_and` and
  `op_or`.
- [ ] Preserve call origin metadata when desugaring operators into `op_*`
  direct named calls.
- [x] Desugar struct field punning into explicit field values.
- [x] Desugar qualified and unqualified enum variant expressions into one
  variant-call expression shape.
- [x] Elaborate builtin expressions into typed unsafe builtins without
  interpreting intrinsic names.
- [ ] Integrate checked-source lowering with the resolved-to-checked source
  elaboration pipeline.
- [ ] Produce a typed source-level result that contains no unresolved names,
  omitted contextual arguments, or source-only ambiguity states.
- [ ] Existential: preserve witness and opened-type information in Checked
  Source so later typed core lowering does not need source syntax.

## 5. Typed Core ANF

- [ ] Define the typed core program representation after the source-level
  elaborator has a closed typed result.
- [ ] Lower checked source semantics into structured ANF with typed nodes and
  origin spans.
- [ ] Preserve nominal data, first-class functions, type lambdas, type
  applications, existential packages, checked patterns, and typed unsafe
  builtins.
- [ ] Existential: lower checked existential packages and unpack/opened-type
  scopes without depending on source syntax.
- [ ] Remove source-only constructs such as pipeline, contextual offer lookup,
  omitted contextual arguments, and ordinary operator aliases.
- [ ] Provide a typed core pretty printer and tests based on typed core output.

## 6. Reference Interpreter

- [ ] Evaluate whole typed core programs without hard-coding `main`.
- [ ] Use uniform interpreter values, global environments, call frames, and
  closure environments.
- [ ] Evaluate first-class calls, type lambdas/applications with runtime type
  erasure, existential packages, nominal data, checked patterns, conditionals,
  and matches.
- [ ] Existential: evaluate packages and unpacking with runtime type erasure
  while preserving the checked scope discipline.
- [ ] Define the builtin runtime plugin contract and runtime error reports.
- [ ] Use the interpreter as the semantic oracle for later execution targets.

## 7. Prelude And Conformance

- [ ] Encode and check the v1 prelude as Lane2 source.
- [ ] Populate the initial contextual offer environment from prelude-provided
  offered value definitions.
- [ ] Provide required intrinsic implementations through builtin runtime
  plugins.
- [ ] Expand valid and invalid conformance fixtures under `spec/examples`.
- [ ] Existential: add valid and invalid parser, resolver, type checker,
  elaborator, typed core, and interpreter fixture coverage for existential
  enums, structs, higher-kind-ready type members, and escape diagnostics.
- [ ] Run parser, type checker, elaborator, and interpreter tests over shared
  fixtures where practical.

## Later Execution Work

- [ ] Lowered IR for closure conversion, decision trees, and execution layout.
- [ ] Portable bytecode VM.
- [ ] Linker entrypoint selection.
- [ ] Algebraic effects and handlers.
- [ ] Direct native, WebAssembly, or JavaScript execution targets.
- [ ] Optional monomorphization and specialized runtime layouts.
