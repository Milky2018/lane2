# Lane2

Lane2 is a personal functional programming language designed around a small, orthogonal core.

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

**Type Object**:
A checked type representation shared by semantic analysis, typed core, and execution contracts.
_Avoid_: source type syntax, parser type node

**Nominal Type Symbol**:
A type-namespace symbol identity for a declared struct or enum type constructor.
_Avoid_: type parameter, source type name

**Type Parameter Identity**:
A compiler identity for a type parameter introduced by a generic binder.
_Avoid_: nominal type symbol, erased runtime type

**Kind**:
A classifier of type-level expressions, with v1 supporting only the `Type` kind.
_Avoid_: runtime type, trait constraint

**Execution Target**:
A way to execute a checked Lane2 program, such as an interpreter or a bytecode virtual machine.
_Avoid_: host target, MoonBit target, backend platform

**Reference Interpreter**:
The first execution target that directly evaluates typed core to define observable Lane2/Core behavior.
_Avoid_: source interpreter, bytecode VM

**Interpreter Entry Selection**:
The rule that a caller chooses which checked value or function to evaluate rather than the interpreter hard-coding `main`.
_Avoid_: built-in main, source entrypoint

**Global Environment**:
The interpreter environment containing initialized top-level and prelude values.
_Avoid_: module namespace, source scope

**Call Frame**:
The interpreter environment for a single function call or local evaluation scope.
_Avoid_: global scope, closure object

**Tail-Call Optimization**:
An execution optimization that reuses a call frame for a tail-position call.
_Avoid_: required recursion semantics, function correctness

**Closure Environment**:
The captured interpreter environment stored with a first-class function value.
_Avoid_: call frame, lambda-lifted parameter list

**Syntax AST**:
The source-shaped tree produced from Lane2 concrete syntax.
_Avoid_: typed tree, core IR

**Resolved AST**:
A source-shaped tree whose names, variants, and operator aliases have been resolved.
_Avoid_: parsed AST, typed core

**Semantic Lowering**:
The transformation from Checked Source AST into Typed Core IR.
_Avoid_: source elaboration, parsing, bytecode generation

**Symbol Identity**:
A stable compiler identity for a resolved type, value, constructor, or local binding.
_Avoid_: source spelling, de Bruijn-only identity

**Separated Symbol Identity**:
Distinct compiler identity types for different namespaces such as type, value, field, and variant symbols.
_Avoid_: kind-tagged universal symbol id, string namespace

**Owned Symbol Metadata**:
Compiler metadata that records the nominal owner of a globally unique field or variant symbol.
_Avoid_: locally indexed field only, ownerless constructor

**Value Symbol**:
A value-namespace symbol identity for top-level values, functions, parameters, local bindings, local functions, and pattern binders.
_Avoid_: function-only id, parameter-only id

**Origin Span**:
A diagnostic annotation that links resolved or core IR back to source text.
_Avoid_: semantic location, runtime value

**Typed Core IR**:
The typed Structured ANF representation produced from Checked Source AST while preserving Lane2/Core semantics.
_Avoid_: source AST, checked source AST, bytecode, VM instruction format

**Typed Core Node**:
A typed core expression or binding whose type is explicitly available after type checking.
_Avoid_: re-inferred core node, untyped core expression

**IR Pretty Printer**:
A stable human-readable printer for an intermediate representation used in diagnostics and tests.
_Avoid_: debug dump, unstable snapshot

**Nominal Core Data**:
Typed core data that retains its struct or enum constructor identity.
_Avoid_: anonymous tuple, raw tag

**Dedicated Data Constructor**:
A typed core construction form for nominal struct or enum data that is not a first-class function value.
_Avoid_: constructor function, curried constructor

**Declaration-Order Struct Construction**:
A typed core struct construction whose field values are ordered by the struct declaration.
_Avoid_: source-order field construction, string-key record

**Declaration-Order Struct Pattern**:
A checked struct pattern whose field patterns are ordered by the struct declaration.
_Avoid_: source-order struct pattern, partial record pattern

**Resolved Variant Construction**:
A typed core enum construction that references a variant by variant symbol identity and stores payloads in declaration order.
_Avoid_: string variant lookup, raw tag only

**Resolved Variant Pattern**:
A checked enum pattern that references a variant by variant symbol identity and stores payload patterns in declaration order.
_Avoid_: source variant spelling, raw tag pattern

**Administrative Normal Form**:
An intermediate representation shape where non-trivial computations are named so that evaluation order is explicit.
_Avoid_: CPS, bytecode

**Structured ANF**:
An **Administrative Normal Form** that keeps structured conditionals and matches while requiring their inputs and calls to use atomic values.
_Avoid_: CFG, basic blocks, jump IR

**Core Atom**:
A typed core ANF value form that can be referenced without introducing additional evaluation order.
_Avoid_: arbitrary expression, computed RHS

**Tools Project**:
The `lane-tools/` directory containing developer tools built around the compiler.
_Avoid_: compiler core, standard library

**Standard Library Project**:
The `lane-std/` directory containing Lane standard library source.
_Avoid_: MoonBit runtime helpers, compiler builtins

**Algebraic Effect**:
A first-class description of an operation whose meaning is supplied outside the pure expression that invokes it.
_Avoid_: IO hook, builtin side effect

**Top-Level Definition**:
A named definition that may introduce a type, function, or immutable value at the outermost program scope.
_Avoid_: statement, entrypoint, main function

**Immutable Value Definition**:
A top-level binding that gives a name to a value without permitting reassignment.
_Avoid_: variable, mutable binding

**Recursive Definition Group**:
A set of top-level functions or types that may refer to one another regardless of textual order.
_Avoid_: forward declarations, hoisted statements

**Ordered Top-Level Value Scope**:
The rule that top-level immutable values may refer only to earlier available values.
_Avoid_: recursive top-level values, forward top-level value reference

**Strict Evaluation**:
The rule that an expression is evaluated when it is reached, and function arguments are evaluated before the function body runs.
_Avoid_: eager mode, non-lazy evaluation

**Explicit Top-Level Function Signature**:
A top-level function boundary that states its parameter types and result type.
_Avoid_: inferred top-level function, signature elision

**Local Type Inference**:
The bidirectional rule that type information may be synthesized upward or checked downward between adjacent syntax nodes without global constraint solving.
_Avoid_: global inference, HM flattening, use-site backpropagation

**Local Generic Function**:
A function defined inside an expression or definition that may introduce its own type parameters.
_Avoid_: top-level-only polymorphism, lifted generic function

**Generic Function Literal**:
A function literal that introduces its own type parameters where the function is written.
_Avoid_: generic binding, inferred generic let

**Generic Named Function**:
A named function whose explicit type parameter list follows `fn` and precedes the function name.
_Avoid_: name-attached type parameters

**Direct Context Inference**:
The rule that an omitted local type may be inferred only from the expression's immediate expected type, not from later uses of a bound name.
_Avoid_: use-site backpropagation, whole-scope inference

**Uncurried Function**:
A function that accepts its parameters as one call shape and is not automatically transformed into nested one-argument functions.
_Avoid_: curried function, automatic partial application

**Parameter-List Function Type**:
A function type written with a parenthesized parameter list followed by `->` and a result type.
_Avoid_: curried function type, bare arrow chain

**Generic Function Type**:
A function type whose explicit type parameter list precedes its parenthesized value parameter list.
_Avoid_: implicit forall, top-level-only polymorphic type

**Forall Type**:
A type object that binds type parameters over another type.
_Avoid_: function-owned generic parameter list, implicit polymorphic wrapper

**Type Application**:
A typed core operation that instantiates a polymorphic value with type arguments.
_Avoid_: runtime type argument, erased substitution only

**First-Class Type Application**:
A typed core type application whose callee is any polymorphic atom rather than only a known generic function symbol.
_Avoid_: direct generic call only, runtime typecase

**Type Lambda**:
A typed core value form that abstracts over type parameters to create a polymorphic value.
_Avoid_: generic ordinary lambda, runtime type function

**Type Alpha-Equivalence**:
The rule that types differing only by bound type parameter names are equal.
_Avoid_: display-name equality, raw binder identity equality

**Nominal Type**:
A type whose identity comes from its declaration name rather than from having the same structure as another type.
_Avoid_: structural type, shape-compatible type

**Enum Type**:
A nominal type defined by a closed set of named variants.
_Avoid_: sum type, tagged union

**Struct Type**:
A nominal type defined by a fixed set of named fields.
_Avoid_: record type, anonymous record

**Generic Type Definition**:
A struct or enum declaration whose explicit type parameter list follows the type name.
_Avoid_: keyword-attached type parameters

**Generic Type Application**:
A use of a generic type name with explicit type arguments in brackets.
_Avoid_: inferred type constructor use, angle-bracket type application

**Runtime Typecase**:
A runtime branch whose behavior depends on inspecting a type argument or type constructor.
_Avoid_: ordinary pattern match, implicit reflection

**Runtime Type Erasure**:
The rule that generic type arguments used for checking are not represented in execution targets.
_Avoid_: runtime generic metadata, implicit type evidence

**Uniform Value Representation**:
A runtime representation where values share one execution-level value model rather than being specialized by generic type arguments.
_Avoid_: monomorphized value layout, type-specialized runtime

**Interpreter Value**:
A uniform runtime value used by the reference interpreter.
_Avoid_: unboxed primitive special case, source AST node

**First-Class Function Value**:
A function that can be stored, passed, returned, and called as a value.
_Avoid_: top-level-only function, method

**First-Class Call**:
A typed core call whose callee is any function-valued atom rather than only a known function symbol.
_Avoid_: direct-call-only core, method dispatch

**Closure Conversion**:
A lowering step that makes captured lexical variables explicit in function values.
_Avoid_: type checking, name resolution

**Separated Namespaces**:
The rule that type names and value names are resolved in distinct namespaces and may use the same spelling without conflict.
_Avoid_: single namespace, unrestricted shadowing

**Qualified Variant**:
An enum variant referred to through its enum type name using `Type::variant`.
_Avoid_: globally unique variant, dotted variant

**Unqualified Variant**:
An enum variant referred to by its variant name alone when that name resolves without ambiguity.
_Avoid_: mandatory qualified variant, inferred later variant

**Payloadless Variant Value**:
An enum variant without payload that is used as a value without call parentheses.
_Avoid_: zero-argument variant call

**Qualified Struct Literal**:
A struct value constructed with its struct type name followed by `::{ ... }`.
_Avoid_: anonymous record literal, unqualified struct literal

**Struct Field Punning**:
A struct literal shorthand where a field name alone means `field: field`.
_Avoid_: spread update, default field

**Struct Pattern Punning**:
A struct pattern shorthand where a field name alone binds that field to a variable with the same name.
_Avoid_: rest pattern, spread pattern

**Field Access**:
Reading a named field from a struct value with dot syntax.
_Avoid_: field update, copy update

**Resolved Field Access**:
A typed core field access that references a field by field symbol identity.
_Avoid_: string field lookup, raw field index only

**Core Pattern**:
A pattern form limited to wildcard, variable, literal, enum variant, or struct destructuring.
_Avoid_: guard pattern, or-pattern, as-pattern

**Checked Pattern**:
A pattern in typed core whose constructors, binders, and covered type have been checked.
_Avoid_: parse pattern, decision tree

**Pattern Binder Uniqueness**:
The rule that a single pattern cannot bind the same value name more than once.
_Avoid_: implicit equality pattern, binder shadowing within a pattern

**Pattern Matrix**:
A semantic analysis model for match arms where rows are checked arms and columns are matched occurrences.
_Avoid_: ad hoc arm scan, runtime matcher

**Decision Tree**:
A lowered representation of pattern matching as explicit tests and branches.
_Avoid_: source pattern, checked pattern

**Qualified Variant Pattern**:
An enum variant pattern written with `Type::variant` so that bare identifiers remain variable bindings.
_Avoid_: unqualified variant pattern, capitalization-based pattern

**Exhaustive Match**:
A match expression whose arms cover every possible value of the matched type.
_Avoid_: best-effort match, runtime match failure

**Useful Match Arm**:
A match arm that can be selected by at least one value not already covered by earlier arms.
_Avoid_: unreachable arm, redundant arm

**First-Match Arm Order**:
The rule that match arms are considered in source order and the first matching arm is selected.
_Avoid_: unordered pattern set, priority-free match

**Arrow Match Arm**:
A match arm written as `pattern => expression`.
_Avoid_: case arm, arrow statement

**Type Checking**:
The static phase that assigns or verifies types for resolved source terms and rejects type-inconsistent programs.
_Avoid_: name resolution, source desugaring, runtime checking

**Source Elaboration**:
The source-level checking phase that turns resolved surface syntax into checked source syntax by removing source-only forms and selecting concrete symbols.
_Avoid_: pure desugaring, typed core lowering

**Checked Source AST**:
The typed, symbol-resolved source tree produced by Source Elaboration before lowering to Typed Core IR.
_Avoid_: typed core ANF, resolved surface AST, environment-only check result

**Source-Level Structure**:
The expression structure of the source language, such as blocks, conditionals, matches, calls, literals, and function literals, preserved before ANF lowering.
_Avoid_: atomized core shape, source-only syntax, basic blocks

**Pipeline Expression**:
An expression `value |> call` that rewrites by passing `value` as the first argument to the call.
_Avoid_: core pipeline node, method call, placeholder pipeline

**Trailing Comma**:
An optional final comma in a comma-separated syntax list.
_Avoid_: comma-sensitive list ending

**MoonBit-Like Syntax**:
Lane2 surface syntax that follows MoonBit's expression-oriented style while excluding mutable bindings and assignment.
_Avoid_: custom syntax from scratch, MoonBit compatibility

**Type Annotation Spacing**:
The rule that a colon between a value or field name and a type is written with whitespace on both sides.
_Avoid_: compact type annotation, struct-literal field assignment

**Keyword-Delimited Top Level**:
Top-level definitions are separated by their defining keywords rather than semicolons or MoonBit block separators.
_Avoid_: `///|` separator, semicolon-delimited top level

**Conditional Expression**:
An `if` expression with both then and else branches, where both branches have the same type.
_Avoid_: statement if, optional else

**Block Expression**:
A scoped expression containing local value or function bindings followed by a final value expression.
_Avoid_: statement block, local type scope

**Block Function Body**:
A function body written as a block expression rather than with an equals-sign expression body.
_Avoid_: equals body, expression-bodied function

**Arrow Return Type**:
A function result type written with `->` after the parameter list.
_Avoid_: colon return type

**Explicit Named Function Signature**:
A named function boundary that states every parameter type and the result type.
_Avoid_: inferred named function signature

**Sequential Local Binding**:
A local binding that is visible only to later items in the same block.
_Avoid_: let-in expression, simultaneous local binding

**Sequential Local Function**:
A named local function that may call itself, is visible only to later items in the same block, and is not part of a forward-referenced group.
_Avoid_: local recursive group, local forward declaration

**Primitive Type**:
A built-in type provided by the language core: `Int`, `Bool`, `String`, or `Unit`.
_Avoid_: standard library type, numeric tower

**Primitive Inhabitant**:
A value belonging to a primitive type, such as an integer literal, boolean literal, string literal, or `()`.
_Avoid_: enum variant, nominal constructor

**ASCII String**:
An immutable sequence of ASCII bytes.
_Avoid_: Unicode string, UTF-16 string

**Short-Circuit Boolean Operation**:
A boolean operation whose right-hand expression is delayed as a zero-argument function and evaluated only by the operation implementation.
_Avoid_: generic logical operation, ordinary strict binary function

**Thunked Operator Call**:
A typed core call to a resolved operation where a delayed operand is represented as a zero-argument function value.
_Avoid_: direct if lowering, strict binary call

**Resolved Operator Call**:
A typed core call produced from an operator alias after resolving the operation value.
_Avoid_: special operator node, primitive operator

**Integer Undefined Behavior**:
Undefined behavior caused by invalid `Int` arithmetic such as signed overflow or division by zero.
_Avoid_: integer trap, arbitrary precision integer

**Nominal Data Model**:
The rule that user-defined product and sum data is introduced through named structs and enums rather than anonymous tuples or records.
_Avoid_: tuple, anonymous product type

**Implicit Generic Instantiation**:
The rule that type parameters of a generic function or data constructor are inferred at the use site unless ambiguity requires explicit type arguments.
_Avoid_: mandatory type application, global generic inference

**Contextual Resolution**:
The type-directed process that supplies omitted contextual arguments from visible offers.
_Avoid_: open overload resolution, trait instance search, name resolution

**Contextual Offer**:
A named value identifier made available to **Contextual Resolution**.
_Avoid_: offered expression, offered field path, open binding

**Contextual Parameter**:
A function parameter marked for omission at eligible call sites and supplied by **Contextual Resolution**.
_Avoid_: typeclass constraint, trait bound, hidden type parameter

**Offered Parameter**:
A function parameter that is automatically offered in the function body.
_Avoid_: automatically propagated auto parameter, implicit local open

**Contextual Forwarding Field**:
A struct field that becomes an additional contextual offer when the containing struct value is offered.
_Avoid_: open field, inherited field, ordinary unqualified field exposure

**Explicit Contextual Argument**:
A named call argument that explicitly supplies a **Contextual Parameter** instead of using **Contextual Resolution**.
_Avoid_: general labelled argument, positional contextual argument

**Direct Named Function Call**:
A call whose callee is a direct value reference to a function definition symbol.
_Avoid_: function value call, field function call, parenthesized callee expression

**Call Origin Metadata**:
Source information retained across desugaring so diagnostics can refer to the user-written call or operator form.
_Avoid_: erased source name, generated-only span

**Contextual Resolution Diagnostic**:
A diagnostic produced when contextual arguments cannot be supplied or checked.
_Avoid_: generic inference failure, unresolved open candidate

**Offer Declaration**:
A declaration that adds an existing value identifier to the contextual offer environment.
_Avoid_: open declaration, import declaration, expression offer

**Offered Value Definition**:
A value definition that defines a named value and immediately adds it to the contextual offer environment.
_Avoid_: anonymous offer, open binding, unnamed prelude entry

**Operation Value**:
A value whose fields provide named operations through ordinary field access.
_Avoid_: trait instance, interface implementation

**Operator Alias**:
A symbolic operator form that resolves through its corresponding ordinary operation name.
_Avoid_: primitive operator, compiler-only operator

**Recognized Operation**:
A conventional operation name, such as `op_add` or `op_equal`, that may be referenced by an operator alias.
_Avoid_: compiler-only operator method, ad-hoc operator field

**Operation Name**:
A normal value name with an `op_` prefix that may be targeted by a fixed operator alias mapping.
_Avoid_: reserved identifier, user-defined operator token

**Operation Field**:
A field inside a prelude operation struct that stores the implementation function.
_Avoid_: operator alias target, op-prefixed field

**Prelude Operation**:
A prelude-defined nominal operation struct whose fields use conventional operation names.
_Avoid_: compiler-only operator magic, user-defined operator trait

**Unsafe Builtin**:
An intrinsic expression whose meaning is supplied outside Lane2, whose type is taken from direct context, and whose incorrect use can produce undefined behavior.
_Avoid_: typed intrinsic, safe primitive

**Typed Unsafe Builtin**:
A typed core representation of an unsafe builtin whose intrinsic name is uninterpreted but whose expected type is explicit.
_Avoid_: intrinsic lookup during type checking, safe builtin

**Builtin Runtime Plugin**:
An execution-time extension that supplies behavior for unsafe builtin intrinsic names according to the compiler core contract.
_Avoid_: compiler intrinsic table, hard-coded primitive

**Builtin Dispatch Key**:
The intrinsic name and typed core expected type used to select or call a builtin runtime plugin entry.
_Avoid_: name-only builtin lookup, type-checked intrinsic

**Runtime Error Report**:
An execution-target diagnostic result that reports interpreter or plugin failure without becoming a Lane2 language-level exception.
_Avoid_: catchable exception, panic

**Ambiguous Contextual Offer Diagnostic**:
A diagnostic that reports multiple visible contextual offers matching one contextual parameter type.
_Avoid_: open candidate ambiguity, silent default choice

**Required Intrinsic**:
An intrinsic name that every conforming Lane2/Core v1 implementation must provide for portable programs.
_Avoid_: placeholder builtin, implementation-only primitive

**Qualified Field Access**:
A field access expression whose base value is resolved before selecting a field.
_Avoid_: candidate-set field search, namespace lookup

**Prelude**:
The initial language environment that provides primitive types, primitive functions, and default language support before user definitions are checked.
_Avoid_: module system, imports

## Relationships

- The **Pure Core** excludes observable effects.
- An **Algebraic Effect** is the planned boundary for effectful behavior outside the **Pure Core**.
- **Type Objects** are distinct from source type syntax.
- **Nominal Type Symbols** and **Type Parameter Identities** are distinct.
- Every **Type Parameter Identity** has a **Kind**; v1 supports only `Type`.
- A **Syntax AST** is resolved into a **Resolved AST** before type checking.
- A **Resolved AST** attaches **Symbol Identity** to resolved names while preserving source names for diagnostics.
- Lane2 compiler IR uses **Separated Symbol Identity**.
- Field and variant identities use **Owned Symbol Metadata**.
- Value references use **Value Symbols**.
- **Type Checking** assigns and verifies types over a **Resolved AST**.
- **Source Elaboration** consumes type checking information and produces a **Checked Source AST**.
- A **Checked Source AST** preserves **Source-Level Structure** while removing source-only syntax and unresolved or ambiguous references.
- **Semantic Lowering** transforms a **Checked Source AST** into **Typed Core IR**.
- Every compiler IR layer has an **IR Pretty Printer**.
- **Typed Core IR** uses **Symbol Identity** for references.
- Expressions and bindings in **Typed Core IR** are **Typed Core Nodes**.
- **Typed Core IR** may carry **Origin Spans** for diagnostics, but spans do not affect semantics.
- **Source Elaboration** removes **Pipeline Expressions** and **Operator Aliases** before **Typed Core IR**.
- **Typed Core IR** uses **Administrative Normal Form**.
- **Typed Core IR** uses **Structured ANF**, not basic blocks.
- **Core Atoms** may include function values and **Type Lambdas**.
- **Typed Core IR** represents structs and enums as **Nominal Core Data**.
- **Nominal Core Data** is introduced through **Dedicated Data Constructors**.
- Struct values in **Typed Core IR** use **Declaration-Order Struct Construction**.
- Enum values in **Typed Core IR** use **Resolved Variant Construction**.
- The first **Execution Target** is the **Reference Interpreter** for **Typed Core IR**.
- The **Reference Interpreter** uses **Interpreter Entry Selection** over a whole typed core program.
- The **Reference Interpreter** separates the **Global Environment**, **Call Frame**, and **Closure Environment**.
- Lane2 v1 does not require **Tail-Call Optimization**.
- An **Execution Target** consumes checked compiler output rather than raw source syntax.
- A Lane2 source file contains **Top-Level Definitions**, not an executable entrypoint.
- An **Immutable Value Definition** is a kind of **Top-Level Definition**.
- A top-level **Immutable Value Definition** must include an explicit type annotation.
- Top-level functions and types may form a **Recursive Definition Group**.
- Top-level immutable values follow **Ordered Top-Level Value Scope**.
- A top-level function body may refer to any top-level value or function regardless of textual order.
- Lane2 uses **Strict Evaluation**.
- A top-level function has an **Explicit Top-Level Function Signature**.
- **Local Type Inference** applies below explicit top-level boundaries.
- A **Local Generic Function** does not have to be lifted into a top-level definition.
- A **Local Generic Function** is written as a **Generic Function Literal** when its type parameters are local to the function value.
- A named generic function is written as a **Generic Named Function**, such as `fn[A] id(value : A) -> A { value }`.
- **Local Type Inference** uses **Direct Context Inference** and never infers a local function's parameters from later calls.
- A function literal can be checked against an expected function type or synthesized when its parameter types are explicitly available and its body can synthesize a result type.
- A function literal without an expected type must provide explicit parameter types.
- A generic function literal without an expected type must provide both explicit type parameters and explicit value parameter types.
- A polymorphic function value uses **Generic Function Type** syntax such as `[A](A) -> A`.
- **Generic Function Type** syntax elaborates to a **Forall Type** over a non-generic function type.
- **Forall Types** use **Type Alpha-Equivalence** for equality.
- **Typed Core IR** preserves **Type Application** before **Runtime Type Erasure**.
- **Typed Core IR** uses **First-Class Type Application**.
- A **Generic Function Literal** elaborates to a **Type Lambda** over an ordinary function value.
- Lane2 v1 has no **Runtime Typecase**.
- Generic type arguments use **Runtime Type Erasure** before execution.
- Execution targets use **Uniform Value Representation** for generic code.
- The **Reference Interpreter** evaluates to **Interpreter Values**.
- Lane2 functions are **Uncurried Functions**.
- Lane2 has **First-Class Function Values**.
- **Typed Core IR** uses **First-Class Calls**.
- **Closure Conversion** happens after **Typed Core IR**.
- Lane2 function types use **Parameter-List Function Type** syntax.
- **Enum Type** and **Struct Type** declarations create **Nominal Types**.
- A generic struct or enum uses **Generic Type Definition** syntax such as `struct Box[A]`.
- A generic type is used with **Generic Type Application** syntax such as `Option[Int]`.
- Lane2 uses **Separated Namespaces** for type names and value names.
- An enum variant name must be unique within its **Enum Type** and may be used as a **Qualified Variant**.
- An **Unqualified Variant** is allowed when exactly one visible enum variant has that name; ambiguous unqualified variants are rejected.
- **Unqualified Variant** syntax is expression-only; enum variants in patterns must be qualified.
- A variant without payload is a **Payloadless Variant Value**.
- Enum variant payloads are positional in v1.
- Functions use positional parameters in v1.
- Named product data is represented with **Struct Types**, not enum payload labels.
- A **Struct Type** value is constructed with a **Qualified Struct Literal**.
- `Type::member` syntax resolves `Type` in the type namespace.
- A **Struct Type** supports **Field Access** but not field update syntax.
- **Typed Core IR** represents **Field Access** as **Resolved Field Access**.
- A **Qualified Struct Literal** supports **Struct Field Punning** but not spread, update, or default fields.
- Struct patterns support **Struct Pattern Punning** and explicit field renaming, but not rest or spread.
- Struct patterns must list all fields of the matched struct.
- **Typed Core IR** represents struct patterns as **Declaration-Order Struct Patterns**.
- Struct fields have no visibility modifier in v1 and are accessible wherever the struct value is visible.
- Pattern matching in v1 uses **Core Patterns**.
- **Core Patterns** include **Primitive Inhabitants** as literal patterns.
- `Int` and `String` literal patterns require a wildcard or binding fallback for an **Exhaustive Match**.
- `Bool` and `Unit` literal patterns can be exhaustive by covering all primitive inhabitants.
- Enum variants in patterns use **Qualified Variant Pattern** syntax.
- A payloadless **Qualified Variant Pattern** is written without parentheses.
- **Typed Core IR** represents enum patterns as **Resolved Variant Patterns**.
- A match expression must be an **Exhaustive Match**.
- **Typed Core IR** represents match arms with **Checked Patterns** rather than a **Decision Tree**.
- Semantic analysis uses a **Pattern Matrix** for match exhaustiveness and usefulness checking.
- Every match arm must be a **Useful Match Arm**.
- A wildcard or binding match arm makes later arms for the same remaining space unreachable.
- Repeated literal or variant coverage makes later duplicate arms unreachable.
- Match arm usefulness is checked over nested patterns, not only top-level patterns.
- **Pattern Binder Uniqueness** is required.
- Pattern binders may shadow outer value names.
- A pattern binder is scoped only over its match arm body.
- Match evaluation uses **First-Match Arm Order**.
- **Decision Trees** are a lowered execution model for pattern matching, not the typed core representation.
- Match expressions use **Arrow Match Arms**.
- Pattern matching is expressed with `match`; v1 has no `is` pattern expression.
- Lane2 supports **Pipeline Expressions** but not method calls.
- A **Pipeline Expression** requires a call or function literal on its right-hand side.
- **Pipeline Expressions** do not appear in **Typed Core IR**.
- Comma-separated lists allow a **Trailing Comma**.
- Lane2 uses **MoonBit-Like Syntax** without mutation or assignment.
- Lane2 uses **Type Annotation Spacing** for type annotations; struct literal field assignment remains `field: expression`.
- Lane2 uses a **Keyword-Delimited Top Level**.
- `offer` is a Lane2 keyword.
- Lane2 has **Conditional Expressions**, not statement-only conditionals.
- A **Conditional Expression** requires a `Bool` condition; Lane2 has no truthiness conversion.
- A **Block Expression** may contain local value and function bindings, but not local type definitions.
- A **Block Expression** has local items followed by exactly one final expression, not multiple expression statements or an implicit unit result.
- A function uses a **Block Function Body**.
- A function uses an **Arrow Return Type**.
- A named function has an **Explicit Named Function Signature**.
- Local bindings use **Sequential Local Binding** scope.
- A local **Sequential Local Binding** may omit its type when local inference can synthesize its expression type.
- A local named function is a **Sequential Local Function**.
- Local value names may shadow earlier value names.
- Ordinary value bindings in the same scope must have distinct names.
- Function parameters, local lets, top-level values, local functions, and pattern binders are ordinary value bindings.
- Lane2 v1 has four **Primitive Types**: `Int`, `Bool`, `String`, and `Unit`.
- **Primitive Types** are core type constants with **Primitive Inhabitants**, not nominal enum or struct types.
- `true`, `false`, integer literals, string literals, and `()` are matched as **Primitive Inhabitants**, not **Qualified Variant Patterns**.
- `String` is an **ASCII String** in v1.
- `Bool` has only `true` and `false`, and `&&` and `||` are **Short-Circuit Boolean Operations**.
- `Int` is a signed 64-bit integer, and invalid integer arithmetic is **Integer Undefined Behavior**.
- Lane2 uses a **Nominal Data Model** and does not include tuple types in v1.
- Collection types are expected later, but are outside the v1 language core.
- Generic functions and data constructors use **Implicit Generic Instantiation**.
- Generic struct literals and enum variants may omit type arguments when local information determines them.
- Lane2 v1 has no type aliases; named domain types are represented with **Struct Types** or **Enum Types**.
- Lane2 v1 has no trait, typeclass, or interface constraints.
- **Contextual Resolution** supplies omitted contextual arguments from visible **Contextual Offers**.
- **Contextual Resolution Diagnostics** distinguish missing offers, ambiguous offers, and invalid explicit contextual arguments.
- A **Contextual Offer** offers a value identifier, not an expression or field path.
- An **Offer Declaration** has the shape `offer name`.
- An **Offered Value Definition** has the shape `let offer name : Type = expression`.
- An **Offered Value Definition** is equivalent to defining the value and then introducing an **Offer Declaration** for the same identifier.
- An **Offered Value Definition** must be named.
- An **Offered Value Definition** checks its initializer before the defined value enters the contextual offer environment.
- **Contextual Offers** use lexical scope and affect only **Contextual Resolution**.
- A local **Offer Declaration** is visible from its declaration point to the end of the current block.
- A top-level **Offer Declaration** contributes to the top-level contextual offer environment.
- Top-level **Offer Declarations** follow **Ordered Top-Level Value Scope** and cannot refer to later values.
- Top-level function bodies are checked with the complete top-level contextual offer environment.
- Top-level value initializers are checked only with contextual offers available earlier in **Ordered Top-Level Value Scope**.
- Local **Offer Declarations** can only offer values already visible at that point in the block.
- Nested local function bodies can see contextual offers from their lexical environment.
- Any value identifier with a known type may become a **Contextual Offer**.
- A **Contextual Forwarding Field** is offered only when the containing value is offered.
- A **Contextual Forwarding Field** is declared as a struct field with the `offer` modifier.
- A **Contextual Forwarding Field** contributes only to **Contextual Resolution**, not to ordinary value lookup.
- A **Contextual Forwarding Field** is constructed and accessed with the same field name as an ordinary struct field.
- A **Contextual Forwarding Field** has the field type obtained from normal nominal field typing of the containing value.
- **Contextual Forwarding Fields** are expanded recursively with cycle detection.
- Multiple visible **Contextual Offers** may overlap; ambiguity is reported only when **Contextual Resolution** needs one matching value.
- Contextual offer deduplication uses offer identity, not runtime value equality.
- Visible **Contextual Offers** from nested lexical scopes are combined rather than shadowed.
- Repeating the same **Contextual Offer** is semantically idempotent but should produce a warning.
- A value must have a known synthesized or annotated type before it can become a **Contextual Offer**.
- **Contextual Resolution** never infers an offered value's type from later contextual uses.
- **Contextual Resolution** never infers generic type arguments for the call being completed.
- **Contextual Resolution** matches offers by Lane2 type equality only.
- **Contextual Resolution** does not apply offered functions or recursively resolve their contextual parameters to manufacture a matching value.
- Lane2 v1 does not instantiate polymorphic offers during **Contextual Resolution**.
- A **Contextual Parameter** may have any Lane2 type.
- A **Contextual Parameter** remains an ordinary value parameter in the function type.
- **Contextual Resolution** is call syntax sugar; checked calls contain all ordinary arguments explicitly.
- Only functions introduced by a function definition may declare **Contextual Parameters**.
- Top-level functions and local named functions may declare **Contextual Parameters**.
- Function literals cannot declare **Contextual Parameters**.
- A **Contextual Parameter** is an ordinary value binding inside the function body.
- A **Contextual Parameter** is not automatically offered inside the function body.
- Any function parameter may be an **Offered Parameter**.
- Function literals may declare **Offered Parameters**.
- `auto offer` marks a parameter as both a **Contextual Parameter** and an **Offered Parameter**.
- An **Offered Parameter** behaves as if the function body starts with an **Offer Declaration** for that parameter.
- Calls through ordinary function values must provide every ordinary argument explicitly.
- **Contextual Parameters** must form a contiguous suffix of a function definition's parameter list.
- **Offered Parameters** that are not contextual may appear anywhere in a parameter list.
- A caller may supply an **Explicit Contextual Argument** for a **Contextual Parameter** using `name=value`.
- **Explicit Contextual Arguments** are named so that a caller may supply selected contextual parameters while leaving others to **Contextual Resolution**.
- **Explicit Contextual Arguments** may appear in any order but cannot repeat the same contextual parameter.
- **Explicit Contextual Arguments** remove the named parameters from the set that **Contextual Resolution** must supply.
- The right-hand side of an **Explicit Contextual Argument** is an ordinary expression.
- **Explicit Contextual Arguments** participate in generic call inference like ordinary explicit arguments.
- **Explicit Contextual Arguments** are processed before **Contextual Resolution** supplies remaining omitted contextual arguments.
- **Explicit Contextual Arguments** are valid only for direct calls to named functions that declare **Contextual Parameters**.
- Calls through ordinary function values cannot use **Explicit Contextual Arguments**.
- **Contextual Resolution** for omitted call arguments is valid only for **Direct Named Function Calls**.
- Positional call arguments fill non-contextual parameters before any omitted contextual suffix.
- Positional call arguments cannot fill **Contextual Parameters**.
- Non-contextual parameters cannot be supplied with named call arguments in v1.
- An **Operation Value** can provide behavior without traits, typeclasses, or interfaces.
- Plain value bindings use lexical shadowing between scope layers.
- **Qualified Field Access** requires its base expression to resolve to a unique value before field selection.
- Operation laws are API conventions, not compiler-checked rules.
- An **Operator Alias** such as `+` resolves as the corresponding ordinary operation name, such as `op_add`.
- An **Operator Alias** may resolve through an ordinary local function with the corresponding operation name.
- An **Operator Alias** is elaborated through the corresponding ordinary operation name.
- An **Operator Alias** elaborates to a **Direct Named Function Call** when its operation name resolves to a function definition symbol.
- Desugaring an **Operator Alias** preserves **Call Origin Metadata** such as the operation name and source span.
- A **Recognized Operation** requires only that the corresponding operation name resolves to a suitable value.
- An **Operation Name** is an ordinary value name, not a reserved word.
- User code may define **Operation Names**.
- Ordinary value binding uniqueness still applies to **Operation Names**.
- **Operation Names** use the `op_` prefix at top level, while **Operation Fields** use short names such as `add` or `sub`.
- Lane2 fixes mappings from built-in operator tokens to operation names, but does not allow user-defined operator tokens or mappings in v1.
- A **Prelude Operation** is an API convention rather than a required source for operator resolution.
- Lane2 v1 does not include `open`.
- Equality operators are provided by an `Equal` prelude operation containing both `equal` and `not_equal`.
- `op_equal` and `op_not_equal` use **Contextual Resolution** to obtain an `Equal[T]` operation value.
- Ordering operators are provided by a `Compare` prelude operation that may forward an `Equal` operation.
- Recognized operator mappings use operation names such as `op_add` for `+`, `op_sub` for `-`, `op_mul` for `*`, `op_div` for `/`, `op_rem` for `%`, `op_neg` for unary `-`, `op_equal` for `==`, `op_not_equal` for `!=`, `op_less` for `<`, `op_less_eq` for `<=`, `op_greater` for `>`, `op_greater_eq` for `>=`, `op_and` for `&&`, `op_or` for `||`, and `op_not` for `!`.
- `&&` and `||` are recognized **Short-Circuit Boolean Operations** whose right operand is thunked before calling `op_and` or `op_or`.
- `&&` and `||` still use **Contextual Resolution** through their thunked `op_and` and `op_or` calls.
- In **Typed Core IR**, `&&` and `||` lower to **Thunked Operator Calls**, not direct `if` expressions.
- Ordinary calls to `op_and` and `op_or` do not thunk their arguments.
- Other operator aliases lower to **Resolved Operator Calls**.
- Primitive operators are not special-cased by source syntax.
- An **Unsafe Builtin** is outside Lane2's safety guarantee and requires a direct expected type.
- **Typed Core IR** represents an **Unsafe Builtin** as a **Typed Unsafe Builtin**.
- **Builtin Runtime Plugins** provide execution behavior for unsafe builtins while the **Compiler Project** defines the core contract.
- A **Builtin Runtime Plugin** receives a **Builtin Dispatch Key**.
- A **Builtin Runtime Plugin** may produce a **Runtime Error Report**, but builtin misuse remains outside Lane2's safety guarantee.
- A **Required Intrinsic** is a portable builtin name; other builtin names are implementation-defined unsafe intrinsics.
- `%bool_and`, `%bool_or`, `%bool_not`, and `%bool_equal` are not **Required Intrinsics**; the corresponding boolean prelude operations are implemented through ordinary `if`.
- Module import and export rules are outside the current design scope.
- The v1 **Prelude** is implementation-supplied Lane2 source checked before user code.

## Resolved Clarifications

- "没有可变状态" was clarified to mean a **Pure Core**, not merely an imperative language without mutable variables.
- "变量定义" was clarified as **Immutable Value Definition**, because Lane2 does not allow reassignment in the pure core.
- "type inference" was clarified as **Local Type Inference**, not Hindley-Milner-style global inference that flattens local polymorphism into top-level declarations.
- "`open`" was retired from Lane2 v1; operator support is no longer modeled as opened struct-field lookup.
