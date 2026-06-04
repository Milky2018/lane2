# Lane2 v1 Language Design

This document is the working v1 language design. `CONTEXT.md` remains the glossary; this file states the user-visible rules that the first parser, type checker, and AST interpreter should implement.

## Core Model

Lane2 v1 is a strict, pure, expression-oriented functional language.

- There is no mutable state, `mut`, assignment, or field update.
- Function arguments are evaluated before the function body runs.
- `if` and `match` evaluate only the selected branch.
- IO and other effects are outside v1 core semantics and are planned to use algebraic effects later.
- `builtin("...")` is an unsafe escape hatch. It can appear wherever an expression has a direct expected type, but the type checker does not interpret the string. Misuse is undefined behavior.
- Required portable intrinsics are `%i64_add`, `%i64_sub`, `%i64_mul`, `%i64_div`, `%i64_rem`, `%i64_neg`, `%i64_equal`, `%i64_less`, and `%string_equal`.
- `%bool_and`, `%bool_or`, `%bool_not`, and `%bool_equal` are not required intrinsics; the prelude defines these boolean operations with ordinary `if`.

## Source Shape

A source file contains top-level definitions. It does not define an executable `main`; entrypoint selection belongs to a later linker/runtime layer.

Top-level definitions are keyword-delimited. Lane2 source does not use MoonBit `///|` separators or semicolon-delimited top-level items.

Type annotations follow MoonBit-style spacing: the colon between a name and a type is written with spaces on both sides, as in `value : Int`. Struct literal field assignment remains `field: expression`.

Allowed top-level forms in v1:

```lane2
struct Point {
  x : Int
  y : Int
}

enum Option[A] {
  none
  some(A)
}

fn add(a : Int, b : Int) -> Int {
  a + b
}

let answer : Int = 42

let : Add[Int] = Add::{ add: int_add }

open int_add_ops
```

Top-level rules:

- Top-level `fn`, `struct`, and `enum` definitions may refer to each other regardless of textual order.
- Top-level `let` definitions must have explicit type annotations.
- Top-level `let` initializers and top-level `open` declarations follow ordered value scope: they may only refer to values already available at that declaration point.
- A top-level function body may refer to any top-level value or function regardless of textual order.
- A top-level `open` creates an open scope extension from its declaration point to the end of the top-level scope.

## Namespaces

Type names and value names are separate namespaces and may use the same spelling.

`Type::member` syntax always resolves `Type` in the type namespace:

```lane2
enum Option[A] {
  none
  some(A)
}

let Option : Int = 42
let x : Option[Int] = Option::some(1)
```

Enum variant names are scoped to their enum. In expressions, an unqualified variant is allowed only when it resolves without ambiguity:

```lane2
let x : Option[Int] = some(1)
let y : Option[Int] = Option::some(1)
```

In patterns, variants must always be qualified; bare identifiers are variable bindings.

## Types

Primitive v1 types:

```lane2
Int
Bool
String
Unit
```

The `Unit` value is written explicitly as `()`. Empty blocks do not implicitly produce `()`.

Lane2 v1 has no tuples, type aliases, traits, typeclasses, interfaces, arrays, lists, maps, or collection syntax. Collections are expected later but are outside v1 core.

User-defined data is nominal:

```lane2
struct UserId {
  value : Int
}

struct OrderId {
  value : Int
}
```

`UserId` and `OrderId` are different types even though they have the same fields.

Generic type definitions put type parameters after the type name:

```lane2
struct Box[A] {
  value : A
}

enum Option[A] {
  none
  some(A)
}
```

Generic type application uses brackets:

```lane2
Option[Int]
Box[String]
Add[Int]
```

Generic struct literals and enum variants may omit type arguments when local information determines them:

```lane2
let b : Box[Int] = Box::{ value: 1 }
let s : Option[Int] = some(1)
```

Payloadless enum variants are values, not zero-argument calls:

```lane2
let x : Option[Int] = Option::none
```

`Option::none()` is not valid.

Enum variant payloads are positional in v1. If a variant needs named product data, use a struct:

```lane2
struct Node[A] {
  left : Tree[A]
  value : A
  right : Tree[A]
}

enum Tree[A] {
  leaf(A)
  node(Node[A])
}
```

## Structs

Struct values are constructed with qualified struct literals:

```lane2
let p : Point = Point::{ x: 1, y: 2 }
```

Field punning is allowed:

```lane2
let p : Point = Point::{ x, y }
```

Punning means `Point::{ x: x, y: y }`.

Struct literals must provide all fields. There are no default fields, spread, copy update, or field update syntax.

Field access uses dot syntax:

```lane2
p.x
```

All struct fields are accessible in v1; there are no field visibility modifiers.

## Functions

Lane2 functions are uncurried. There is no automatic currying or partial application.

Function definitions use block bodies only:

```lane2
fn add(a : Int, b : Int) -> Int {
  a + b
}
```

There is no `= expr` function body form.

Function result types use `->`, not `:`. Parameters are positional in v1; labeled parameters are not supported.

Named functions must have explicit parameter types and result type. This applies both at top level and locally.

Generic named functions write type parameters after `fn` and before the function name:

```lane2
fn[A] id(value : A) -> A {
  value
}
```

Function types use a parenthesized parameter list:

```lane2
(Int) -> Int
(Int, Int) -> Int
() -> Int
```

Do not write `Int -> Int` for a one-argument function type.

Generic function types write type parameters before the value parameter list:

```lane2
[A](A) -> A
[A](Bool, A, A) -> A
```

Function literals are function values:

```lane2
let f : (Int, Int) -> Int = fn(a, b) {
  a + b
}
```

Local generic function literals are allowed:

```lane2
let id = fn[A](value : A) {
  value
}
```

## Blocks And Local Items

A block expression contains local items followed by exactly one final expression:

```lane2
{
  let x = 1
  fn double(n : Int) -> Int {
    n + n
  }
  double(x)
}
```

Allowed local items:

- local `let`
- local named `fn`
- local `open`

Local type definitions are not part of v1.

Blocks do not allow multiple expression statements:

```lane2
{
  f(x)
  g(y)
}
```

This is invalid because there are two expression statements. Use a binding or return one final expression.

Local `let` bindings are sequential and may omit type annotations when local inference can synthesize the expression type:

```lane2
let x = 1
```

Local named functions are sequential too. They are visible only to later items in the same block, may call themselves, and cannot form local mutually recursive groups:

```lane2
fn f(n : Int) -> Int {
  fn loop(x : Int) -> Int {
    if x == 0 {
      0
    } else {
      loop(x - 1)
    }
  }
  loop(n)
}
```

## Local Type Inference

Lane2 uses bidirectional local type inference:

- expression types may synthesize upward;
- expected types may check downward;
- information moves between adjacent syntax nodes;
- there is no Hindley-Milner-style global constraint solving;
- a binding's type is never inferred from later uses.

Function literals can be checked against an expected function type:

```lane2
let f : (Int, Int) -> Int = fn(a, b) {
  a + b
}
```

Without an expected type, a function literal must provide explicit parameter types:

```lane2
let f = fn(a : Int, b : Int) {
  a + b
}
```

Generic function literals without an expected type must provide both explicit type parameters and explicit value parameter types:

```lane2
let id = fn[A](value : A) {
  value
}
```

This is invalid:

```lane2
let id = fn[A](value) {
  value
}
```

Polymorphic calls may instantiate type arguments locally:

```lane2
id(1)
id("x")
```

## Control Expressions

`if` is an expression and must have both branches:

```lane2
if ok {
  value
} else {
  fallback
}
```

Both branches must have the same type.

`match` is an expression. Arms use `pattern => expression`:

```lane2
match value {
  Option::none => fallback
  Option::some(x) => x
}
```

Match expressions must be exhaustive.

V1 patterns:

- `_` wildcard
- variable binding with a bare identifier
- literal patterns
- qualified enum variant patterns
- qualified struct patterns

Enum variants in patterns must be qualified:

```lane2
Option::some(x)
Option::none
```

Bare identifiers in patterns always bind variables:

```lane2
match value {
  x => x
}
```

Struct patterns use qualified syntax. They must list all fields, support punning and explicit renaming, and do not support rest/spread:

```lane2
match p {
  Point::{ x, y } => x + y
}

match p {
  Point::{ x: a, y: b } => a + b
}
```

There are no guards, or-patterns, as-patterns, or `is` pattern expressions in v1.

## Calls, Fields, And Pipeline

Function call is ordinary application:

```lane2
f(x, y)
```

Field access is dot syntax:

```lane2
ops.add
ops.add(x, y)
```

`ops.add(x, y)` is field access followed by a call. It is not method call syntax.

Lane2 v1 does not support methods or receiver lookup.

Pipeline syntax is supported:

```lane2
value |> f(a, b)
```

It rewrites to:

```lane2
f(value, a, b)
```

The right side must be a call or function literal. Bare function names and placeholders are not supported:

```lane2
value |> f
value |> f(_, y)
```

Both are invalid.

Comma-separated lists allow trailing commas.

## Open And Preopen

`open value` creates an open scope extension. The value must be a visible value name with a struct type. It cannot be an arbitrary expression.

```lane2
open ops
```

The fields of `ops` become available as unqualified names from the `open` declaration point to the end of the current lexical scope.

Top-level `open` is the same mechanism at top-level scope. It affects definitions after the declaration point.

Local name resolution uses the nearest preceding local binding or open scope extension, then falls back to the preopen namespace.

Anonymous top-level values extend the preopen namespace:

```lane2
let : Add[Int] = Add::{ add: int_add }
```

The anonymous value must have a struct type. Its field values, not generated accessors, are exposed through preopen from the declaration point to the end of the top-level scope.

Prelude-provided anonymous values are checked before user code, so their preopen entries are available throughout user code.

Preopen conflicts are errors. Top-level open belongs to the global layer and conflicts with ordinary top-level names or preopened names. Local open may shadow preopen inside its lexical scope.

Struct declarations may forward opened fields:

```lane2
struct Compare[T] {
  equal_impl : Equal[T]
  open equal_impl
  less : (T, T) -> Bool
  less_eq : (T, T) -> Bool
  greater : (T, T) -> Bool
  greater_eq : (T, T) -> Bool
}
```

`open equal_impl` inside the struct declaration affects what is exposed when a `Compare[T]` value is opened. It does not open `equal_impl` inside ordinary function bodies.

## Operators

Operators are aliases for recognized prelude operation fields. They are not resolved by type-directed instance search.

Primitive operators are not special-cased. Even primitive `+` and `==` require the relevant prelude operation to be preopened or opened.

Recognized v1 operator mappings:

| Operator | Operation |
| --- | --- |
| `+` | `Add::add` |
| `-` | `Sub::sub` |
| `*` | `Mul::mul` |
| `/` | `Div::div` |
| `%` | `Rem::rem` |
| unary `-` | `Neg::neg` |
| `==` | `Equal::equal` |
| `!=` | `Equal::not_equal` |
| `<` | `Compare::less` |
| `<=` | `Compare::less_eq` |
| `>` | `Compare::greater` |
| `>=` | `Compare::greater_eq` |
| `&&` | `And::and` with a thunked right operand |
| `||` | `Or::or` with a thunked right operand |
| `!` | `Not::not` |

`&&` and `||` are short-circuit boolean operators. They are recognized mappings to `And::and` and `Or::or`, but the right operand is passed as `fn() { ... }` instead of being evaluated before the operation call.

`a && b` desugars to a call equivalent to `and(a, fn() { b })` after resolving an available `And::and` operation. `a || b` follows the same rule with `Or::or`. Both operators are defined only for `Bool`.

Concrete precedence, associativity, and unary/binary disambiguation should follow the MoonBit parser reference where Lane2 has not deliberately removed a feature.
