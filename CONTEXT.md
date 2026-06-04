# Lane2

Lane2 is a personal functional programming language designed around a small, orthogonal core.

## Language

**Pure Core**:
The part of Lane2 where evaluating an expression depends only on its inputs and produces a value without observable side effects.
_Avoid_: mutation-free subset, functional mode

**Algebraic Effect**:
A first-class description of an operation whose meaning is supplied outside the pure expression that invokes it.
_Avoid_ : IO hook, builtin side effect

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
The rule that top-level immutable values and top-level opens may refer only to earlier available values.
_Avoid_: recursive top-level values, forward top-level open

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

**Core Pattern**:
A pattern form limited to wildcard, variable, literal, enum variant, or struct destructuring.
_Avoid_: guard pattern, or-pattern, as-pattern

**Qualified Variant Pattern**:
An enum variant pattern written with `Type::variant` so that bare identifiers remain variable bindings.
_Avoid_: unqualified variant pattern, capitalization-based pattern

**Exhaustive Match**:
A match expression whose arms cover every possible value of the matched type.
_Avoid_: best-effort match, runtime match failure

**Arrow Match Arm**:
A match arm written as `pattern => expression`.
_Avoid_: case arm, arrow statement

**Pipeline Expression**:
An expression `value |> call` that rewrites by passing `value` as the first argument to the call.
_Avoid_: method call, placeholder pipeline

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

**Nominal Data Model**:
The rule that user-defined product and sum data is introduced through named structs and enums rather than anonymous tuples or records.
_Avoid_: tuple, anonymous product type

**Implicit Generic Instantiation**:
The rule that type parameters of a generic function or data constructor are inferred at the use site unless ambiguity requires explicit type arguments.
_Avoid_: mandatory type application, global generic inference

**Operation Value**:
A value whose fields provide named operations that may be used explicitly or opened into local resolution.
_Avoid_: trait instance, interface implementation

**Open Scope Extension**:
A lexical scope extension introduced by `open value` where the fields of a struct value may be referenced from the declaration point to the end of the current scope.
_Avoid_: module import, implicit instance search, expression open

**Top-Level Open**:
A top-level **Open Scope Extension**.
_Avoid_: module import, implicit instance search

**Struct Field Forwarding**:
A struct declaration entry `open field` that forwards the opened field's exposed names when the containing struct value is opened.
_Avoid_: inherited field, function-body open

**Operator Alias**:
A symbolic operator form that resolves to a named operation made available through primitive rules or an **Open Scope Extension**.
_Avoid_: operator overloading, type-directed operator lookup

**Recognized Operation**:
A reserved operation struct and field pair, such as `Add::add` or `Equal::equal`, that may provide an operator alias when opened.
_Avoid_: name-only operator, ad-hoc operator field

**Prelude Operation**:
A prelude-defined nominal operation struct whose fields are ordinary values and whose recognized fields may be mapped to operators.
_Avoid_: compiler-only operator magic, user-defined operator trait

**Unsafe Builtin**:
An intrinsic expression whose meaning is supplied outside Lane2, whose type is taken from direct context, and whose incorrect use can produce undefined behavior.
_Avoid_: typed intrinsic, safe primitive

**Preopen Namespace**:
A default-open namespace populated by anonymous top-level values.
_Avoid_: implicit instance search, operation-only prelude

**Anonymous Top-Level Value**:
A top-level value declaration without a name whose fields are exposed through the **Preopen Namespace**.
_Avoid_: discarded value, unnamed local binding

**Prelude**:
The initial language environment that provides primitive types, primitive functions, and default preopened values before user definitions are checked.
_Avoid_: module system, imports

## Relationships

- The **Pure Core** excludes observable effects.
- An **Algebraic Effect** is the planned boundary for effectful behavior outside the **Pure Core**.
- A Lane2 source file contains **Top-Level Definitions**, not an executable entrypoint.
- An **Immutable Value Definition** is a kind of **Top-Level Definition**.
- A top-level **Immutable Value Definition** must include an explicit type annotation.
- Top-level functions and types may form a **Recursive Definition Group**.
- Top-level immutable values and top-level opens follow **Ordered Top-Level Value Scope**.
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
- Lane2 functions are **Uncurried Functions**.
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
- A **Qualified Struct Literal** supports **Struct Field Punning** but not spread, update, or default fields.
- Struct patterns support **Struct Pattern Punning** and explicit field renaming, but not rest or spread.
- Struct patterns must list all fields of the matched struct.
- Struct fields have no visibility modifier in v1 and are accessible wherever the struct value is visible.
- Pattern matching in v1 uses **Core Patterns**.
- Enum variants in patterns use **Qualified Variant Pattern** syntax.
- A payloadless **Qualified Variant Pattern** is written without parentheses.
- A match expression must be an **Exhaustive Match**.
- Match expressions use **Arrow Match Arms**.
- Pattern matching is expressed with `match`; v1 has no `is` pattern expression.
- Lane2 supports **Pipeline Expressions** but not method calls.
- A **Pipeline Expression** requires a call or function literal on its right-hand side.
- Comma-separated lists allow a **Trailing Comma**.
- Lane2 uses **MoonBit-Like Syntax** without mutation or assignment.
- Lane2 uses **Type Annotation Spacing** for type annotations; struct literal field assignment remains `field: expression`.
- Lane2 uses a **Keyword-Delimited Top Level**.
- Lane2 has **Conditional Expressions**, not statement-only conditionals.
- A **Block Expression** may contain local value and function bindings, but not local type definitions.
- A **Block Expression** has local items followed by exactly one final expression, not multiple expression statements or an implicit unit result.
- `open` is a local item and must appear before the final expression in a **Block Expression**.
- A function uses a **Block Function Body**.
- A function uses an **Arrow Return Type**.
- A named function has an **Explicit Named Function Signature**.
- Local bindings use **Sequential Local Binding** scope.
- A local **Sequential Local Binding** may omit its type when local inference can synthesize its expression type.
- A local named function is a **Sequential Local Function**.
- Local value names may shadow earlier value names.
- Lane2 v1 has four **Primitive Types**: `Int`, `Bool`, `String`, and `Unit`.
- Lane2 uses a **Nominal Data Model** and does not include tuple types in v1.
- Collection types are expected later, but are outside the v1 language core.
- Generic functions and data constructors use **Implicit Generic Instantiation**.
- Generic struct literals and enum variants may omit type arguments when local information determines them.
- Lane2 v1 has no type aliases; named domain types are represented with **Struct Types** or **Enum Types**.
- Lane2 v1 has no trait, typeclass, or interface constraints.
- An **Operation Value** can provide behavior without traits, typeclasses, or interfaces.
- An **Open Scope Extension** makes struct field values available as unqualified names.
- An **Open Scope Extension** extends from its declaration point to the end of the current lexical scope.
- An **Open Scope Extension** is introduced from a visible value name, not an arbitrary expression.
- A **Top-Level Open** exposes struct field values to later top-level definitions.
- Local name resolution uses the nearest preceding local binding or **Open Scope Extension**, then falls back to the **Preopen Namespace**.
- **Struct Field Forwarding** affects what is exposed when a struct value is opened, but does not open that field inside ordinary function bodies.
- Operation laws are API conventions, not compiler-checked rules.
- An **Operator Alias** such as `+` maps to a named operation only when that operation is available.
- An **Operator Alias** does not resolve through an ordinary local function that merely has the corresponding name.
- An **Operator Alias** can be provided by a **Recognized Operation**, not by any struct that happens to contain a same-named field.
- A **Recognized Operation** is exposed as a **Prelude Operation** rather than as a trait or interface.
- Lane2 v1 includes `open` and recognized mappings for prelude operations such as `Add`, `Sub`, `Mul`, `Div`, and `Equal`.
- Equality operators are provided by an `Equal` prelude operation containing both `equal` and `not_equal`.
- Ordering operators are provided by a `Compare` prelude operation that may forward an `Equal` operation.
- Recognized operator mappings are `Add::add` for `+`, `Sub::sub` for `-`, `Mul::mul` for `*`, `Div::div` for `/`, `Rem::rem` for `%`, `Neg::neg` for unary `-`, `Equal::equal` for `==`, `Equal::not_equal` for `!=`, `Compare::less` for `<`, `Compare::less_eq` for `<=`, `Compare::greater` for `>`, `Compare::greater_eq` for `>=`, `And::and` for `&&`, `Or::or` for `||`, and `Not::not` for `!`.
- Boolean operators such as `&&` and `||` are strict **Operator Aliases**, not short-circuit control forms.
- Primitive operators are not special-cased; even primitive `+` and `==` require the relevant **Prelude Operation** to be opened.
- An **Unsafe Builtin** is outside Lane2's safety guarantee and requires a direct expected type.
- The **Preopen Namespace** is open by default.
- An **Anonymous Top-Level Value** must have a struct type; its fields are exposed through the **Preopen Namespace**.
- **Preopen Namespace** name conflicts are errors; exposed fields do not override ordinary names or other exposed fields.
- The **Preopen Namespace** exposes field values, not generated field accessors.
- A **Prelude** may contribute anonymous top-level values to the **Preopen Namespace**.
- Module import and export rules are outside the current design scope.
- The v1 **Prelude** is implementation-supplied Lane2 source checked before user code.
- Prelude-provided **Preopen Namespace** entries are visible throughout user code.
- User-defined **Anonymous Top-Level Values** extend the **Preopen Namespace** from their declaration point to the end of the top-level scope.
- A **Top-Level Open** belongs to the global layer and conflicts with ordinary top-level names or preopened names.

## Example dialogue

> **Dev:** "Can a Lane2 expression print while it evaluates?"
> **Domain expert:** "No — printing is not part of the **Pure Core**; effectful behavior belongs behind an **Algebraic Effect** boundary."
>
> **Dev:** "Does a Lane2 file need a `main` function?"
> **Domain expert:** "No — entrypoint selection belongs outside the language core; the file only contributes **Top-Level Definitions**."
>
> **Dev:** "Can a top-level `let` omit its type annotation?"
> **Domain expert:** "No — a top-level **Immutable Value Definition** must include an explicit type annotation."
>
> **Dev:** "Can a top-level `open` refer to a value defined later?"
> **Domain expert:** "No — top-level values and opens follow **Ordered Top-Level Value Scope**."
>
> **Dev:** "Can a top-level function body refer to a value defined later?"
> **Domain expert:** "Yes — top-level function bodies see the complete top-level environment."
>
> **Dev:** "Does calling a function delay evaluation of its arguments?"
> **Domain expert:** "No — Lane2 uses **Strict Evaluation**, while control expressions still choose which branch to evaluate."
>
> **Dev:** "Are all generic functions forced to the top level?"
> **Domain expert:** "No — Lane2 allows a **Local Generic Function**, while top-level functions keep an **Explicit Top-Level Function Signature**."
>
> **Dev:** "Does genericity belong to the local binding or the function value?"
> **Domain expert:** "It belongs to the function value; use a **Generic Function Literal** rather than treating the binding as generic."
>
> **Dev:** "Is a generic named function written `fn id[A](...)`?"
> **Domain expert:** "No — use a **Generic Named Function** form such as `fn[A] id(...)`."
>
> **Dev:** "Can a local function's parameter type be inferred from calls that appear later?"
> **Domain expert:** "No — **Direct Context Inference** can use an immediate expected type, but not later use sites."
>
> **Dev:** "Does local inference create global unification constraints?"
> **Domain expert:** "No — **Local Type Inference** is bidirectional and moves information only between adjacent syntax nodes."
>
> **Dev:** "Can `let f = fn(a, b) { a }` infer parameter types from nowhere?"
> **Domain expert:** "No — a function literal without an expected type must provide explicit parameter types."
>
> **Dev:** "Does `fn[A](value) { value }` infer `value : A` without context?"
> **Domain expert:** "No — a generic function literal without an expected type must provide explicit value parameter types."
>
> **Dev:** "How is the type of `fn[A](value : A) { value }` written?"
> **Domain expert:** "As a **Generic Function Type**, for example `[A](A) -> A`."
>
> **Dev:** "Can I call `add(1)` when `add` expects two parameters?"
> **Domain expert:** "No — Lane2 uses **Uncurried Functions**, so partial application is not implicit."
>
> **Dev:** "Does `Int -> Int` name a one-argument function type?"
> **Domain expert:** "No — use **Parameter-List Function Type** syntax such as `(Int) -> Int`."
>
> **Dev:** "Are two structs with the same fields interchangeable?"
> **Domain expert:** "No — structs are **Nominal Types**, so declaration identity matters."
>
> **Dev:** "Is a generic type written `struct[A] Box`?"
> **Domain expert:** "No — use **Generic Type Definition** syntax such as `struct Box[A]`."
>
> **Dev:** "How is `Option` applied to `Int`?"
> **Domain expert:** "Use **Generic Type Application** syntax: `Option[Int]`."
>
> **Dev:** "Can a value use the same spelling as a type?"
> **Domain expert:** "Yes — **Separated Namespaces** keep type names and value names independent."
>
> **Dev:** "If a value is named `Option`, does `Option::some` refer to that value?"
> **Domain expert:** "No — `Type::member` syntax resolves `Option` in the type namespace."
>
> **Dev:** "Can two enums both define `none`?"
> **Domain expert:** "Yes — variant names are scoped to their enum, and callers can use a **Qualified Variant** such as `Option::none`."
>
> **Dev:** "Can I write `some(1)` instead of `Option::some(1)`?"
> **Domain expert:** "Yes, if `some` resolves as an **Unqualified Variant** without ambiguity."
>
> **Dev:** "Can the same unqualified `some` form be used in a pattern?"
> **Domain expert:** "No — **Unqualified Variant** syntax is expression-only."
>
> **Dev:** "Is `none()` the zero-argument form of `none`?"
> **Domain expert:** "No — a payloadless variant is a **Payloadless Variant Value** and is written without parentheses."
>
> **Dev:** "Can enum variants have labeled payload fields?"
> **Domain expert:** "No — enum variant payloads are positional in v1."
>
> **Dev:** "How should a variant carry named fields?"
> **Domain expert:** "Wrap the named fields in a **Struct Type** and use that struct as positional payload."
>
> **Dev:** "Can functions have labeled parameters?"
> **Domain expert:** "No — functions use positional parameters in v1."
>
> **Dev:** "Can I construct a struct with just `{ x: 1, y: 2 }`?"
> **Domain expert:** "No — use a **Qualified Struct Literal** such as `Point::{ x: 1, y: 2 }`."
>
> **Dev:** "Can `Point::{ x, y }` mean `Point::{ x: x, y: y }`?"
> **Domain expert:** "Yes — **Struct Field Punning** is allowed, but spread and update are not."
>
> **Dev:** "Can `Point::{ x, y }` in a pattern bind both fields?"
> **Domain expert:** "Yes — **Struct Pattern Punning** binds fields by the same variable names."
>
> **Dev:** "Can `Point::{ x }` ignore the `y` field?"
> **Domain expert:** "No — struct patterns must list all fields in v1."
>
> **Dev:** "Can I update one field of a struct value?"
> **Domain expert:** "No — v1 supports **Field Access**, and new struct values are constructed explicitly."
>
> **Dev:** "Can a struct hide a field from `open`?"
> **Domain expert:** "No — v1 struct fields have no visibility modifier."
>
> **Dev:** "Can I use a guard inside a `match` arm?"
> **Domain expert:** "No — v1 pattern matching is limited to **Core Patterns**."
>
> **Dev:** "Can `none` in a pattern mean an enum variant?"
> **Domain expert:** "No — use a **Qualified Variant Pattern** such as `Option::none`; a bare identifier is a variable binding."
>
> **Dev:** "Is `Option::none()` a valid payloadless variant pattern?"
> **Domain expert:** "No — a payloadless **Qualified Variant Pattern** is written without parentheses."
>
> **Dev:** "Can a `match` omit a variant if that case will not happen?"
> **Domain expert:** "No — every `match` must be an **Exhaustive Match**."
>
> **Dev:** "Does Lane2 use `case pattern -> expr`?"
> **Domain expert:** "No — match expressions use **Arrow Match Arms** such as `Option::some(x) => x`."
>
> **Dev:** "Can `if value is some(x)` bind `x`?"
> **Domain expert:** "No — v1 has no `is` pattern expression; use `match`."
>
> **Dev:** "Does `x |> f(y)` call a method on `x`?"
> **Domain expert:** "No — a **Pipeline Expression** rewrites to `f(x, y)`."
>
> **Dev:** "Can I write `x |> f`?"
> **Domain expert:** "No — a **Pipeline Expression** requires a call or function literal on its right-hand side."
>
> **Dev:** "Can a multiline call end with a comma?"
> **Domain expert:** "Yes — comma-separated lists allow a **Trailing Comma**."
>
> **Dev:** "Should Lane2 invent a completely new surface syntax?"
> **Domain expert:** "No — Lane2 uses **MoonBit-Like Syntax**, minus mutable bindings and assignment."
>
> **Dev:** "Can a type annotation be written `x: Int`?"
> **Domain expert:** "No — **Type Annotation Spacing** requires `x : Int`; `x: expr` is reserved for struct literal fields."
>
> **Dev:** "Does Lane2 source require `///|` block separators?"
> **Domain expert:** "No — Lane2 uses a **Keyword-Delimited Top Level**."
>
> **Dev:** "Can an `if` omit `else`?"
> **Domain expert:** "No — a Lane2 `if` is a **Conditional Expression** and must produce a value in both branches."
>
> **Dev:** "Can I define a local enum inside a function body?"
> **Domain expert:** "No — a **Block Expression** is for local value and function bindings followed by a final value."
>
> **Dev:** "Can a block contain `f(x)` and then `g(y)` as two expression statements?"
> **Domain expert:** "No — a **Block Expression** has local items followed by exactly one final expression."
>
> **Dev:** "Can `open` appear after a block's final expression?"
> **Domain expert:** "No — `open` is a local item and must appear before the final expression."
>
> **Dev:** "Can an empty block implicitly return `()`?"
> **Domain expert:** "No — `Unit` must be written explicitly as `()`."
>
> **Dev:** "Can a function body be written as `= expr`?"
> **Domain expert:** "No — Lane2 functions use a **Block Function Body**."
>
> **Dev:** "Is `fn f(): Int` valid?"
> **Domain expert:** "No — function results use an **Arrow Return Type** such as `fn f() -> Int`."
>
> **Dev:** "Can a local named function omit its result type?"
> **Domain expert:** "No — a named function has an **Explicit Named Function Signature**."
>
> **Dev:** "Does `let x = 1 in x + 2` exist?"
> **Domain expert:** "No — Lane2 uses **Sequential Local Binding** inside block expressions."
>
> **Dev:** "Can a local `let` omit its type annotation?"
> **Domain expert:** "Yes — a local **Sequential Local Binding** may omit its type when local inference can synthesize it."
>
> **Dev:** "Can a local function be called before it is defined?"
> **Domain expert:** "No — a local named function is a **Sequential Local Function**."
>
> **Dev:** "Can a local function call itself?"
> **Domain expert:** "Yes — a **Sequential Local Function** may be self-recursive, but local mutually recursive groups are not part of v1."
>
> **Dev:** "Is `Float` a core type?"
> **Domain expert:** "No — v1 **Primitive Types** are only `Int`, `Bool`, `String`, and `Unit`."
>
> **Dev:** "Does `(Int, Bool)` name a tuple type?"
> **Domain expert:** "No — Lane2's **Nominal Data Model** uses named structs and enums, while `()` is only the `Unit` value."
>
> **Dev:** "Are arrays part of the v1 core?"
> **Domain expert:** "No — collections are expected later but are outside the v1 language core."
>
> **Dev:** "Must I write `id[Int](1)` for every generic call?"
> **Domain expert:** "No — **Implicit Generic Instantiation** infers type arguments when the use site is unambiguous."
>
> **Dev:** "Must `Box::{ value: 1 }` be written as `Box[Int]::{ value: 1 }`?"
> **Domain expert:** "No — generic data constructors may omit type arguments when local information determines them."
>
> **Dev:** "Can `type UserId = Int` create a named ID?"
> **Domain expert:** "No — v1 has no type aliases; use a **Struct Type** to create a nominal domain type."
>
> **Dev:** "Can a generic function require `A` to support equality?"
> **Domain expert:** "No — v1 has no trait, typeclass, or interface constraints."
>
> **Dev:** "Does `a + b` search for an `Add` implementation by type?"
> **Domain expert:** "No — an **Operator Alias** resolves through primitive rules or an explicit **Open Scope Extension**."
>
> **Dev:** "What is the scope of `open ops`?"
> **Domain expert:** "It creates an **Open Scope Extension** from the declaration point to the end of the current lexical scope."
>
> **Dev:** "Can a top-level `open` override a preopened `add`?"
> **Domain expert:** "No — a **Top-Level Open** belongs to the global layer and conflicts instead of overriding."
>
> **Dev:** "Can `open constants` expose non-function fields?"
> **Domain expert:** "Yes — an **Open Scope Extension** exposes struct field values, while only recognized operations provide operator aliases."
>
> **Dev:** "Can I write `open make_ops(10)`?"
> **Domain expert:** "No — an **Open Scope Extension** is introduced from a visible value name."
>
> **Dev:** "Does `open equal_impl` inside a struct body make `equal` available in every method body?"
> **Domain expert:** "No — **Struct Field Forwarding** only affects what is exposed when the containing struct value is opened."
>
> **Dev:** "Does the compiler prove that `Compare.less_eq` matches `Compare.less` and `Equal.equal`?"
> **Domain expert:** "No — operation laws are API conventions."
>
> **Dev:** "If a block opens modular addition, does it override preopened integer addition?"
> **Domain expert:** "Yes — local resolution uses the nearest preceding local source before falling back to the **Preopen Namespace**."
>
> **Dev:** "Does a local function named `add` make `+` available?"
> **Domain expert:** "No — an **Operator Alias** requires an operation source, not just an ordinary function with the same name."
>
> **Dev:** "Does any opened struct with an `add` field enable `+`?"
> **Domain expert:** "No — `+` comes from a **Recognized Operation** such as `Add::add`."
>
> **Dev:** "Do `<` and `<=` come from separate operation structs?"
> **Domain expert:** "No — ordering operators come from a `Compare` prelude operation."
>
> **Dev:** "Does `!=` require a separate operation from `==`?"
> **Domain expert:** "No — equality operators come from one `Equal` prelude operation."
>
> **Dev:** "Is `Add` hidden compiler magic?"
> **Domain expert:** "No — `Add` is a **Prelude Operation** with ordinary value-level behavior and a recognized operator mapping."
>
> **Dev:** "Are `Add` and `Equal` postponed until a later trait system exists?"
> **Domain expert:** "No — v1 includes recognized **Prelude Operations** and `open` without adding traits or interfaces."
>
> **Dev:** "Can I write `1 + 2` without opening integer addition?"
> **Domain expert:** "No — primitive operators are not special-cased; `+` requires an opened **Prelude Operation**."
>
> **Dev:** "Does `a && b` skip evaluating `b` when `a` is false?"
> **Domain expert:** "No — boolean operators are strict **Operator Aliases**."
>
> **Dev:** "Does `builtin` preserve Lane2's type safety guarantee?"
> **Domain expert:** "No — **Unsafe Builtin** is an explicit escape hatch whose misuse can cause undefined behavior."
>
> **Dev:** "Can `let x = builtin(\"%anything\")` infer a type for `x`?"
> **Domain expert:** "No — **Unsafe Builtin** requires a direct expected type."
>
> **Dev:** "Can an anonymous `Point` value expose `x` and `y`?"
> **Domain expert:** "Yes — an **Anonymous Top-Level Value** exposes its fields through the default-open **Preopen Namespace**."
>
> **Dev:** "Can `let : Int = 1` add something to preopen?"
> **Domain expert:** "No — only struct values can be opened into the **Preopen Namespace**."
>
> **Dev:** "If two anonymous values expose `x`, does one win?"
> **Domain expert:** "No — **Preopen Namespace** conflicts are errors."
>
> **Dev:** "Does anonymous `Point` create an `x(point)` accessor?"
> **Domain expert:** "No — it exposes the concrete field value `x` from that anonymous value."
>
> **Dev:** "Does this design define module imports?"
> **Domain expert:** "No — only the **Prelude** is in scope for now; module imports are a later design."
>
> **Dev:** "Can two preopened values both expose `add`?"
> **Domain expert:** "No — **Preopen Namespace** conflicts are errors."
>
> **Dev:** "Is the prelude a module import?"
> **Domain expert:** "No — the v1 **Prelude** is implementation-supplied Lane2 source checked before user code."
>
> **Dev:** "Does a user anonymous top-level value affect definitions before it?"
> **Domain expert:** "No — it extends the **Preopen Namespace** from its declaration point to the end of the top-level scope."

## Flagged ambiguities

- "没有可变状态" was clarified to mean a **Pure Core**, not merely an imperative language without mutable variables.
- "变量定义" was clarified as **Immutable Value Definition**, because Lane2 does not allow reassignment in the pure core.
- "type inference" was clarified as **Local Type Inference**, not Hindley-Milner-style global inference that flattens local polymorphism into top-level declarations.
