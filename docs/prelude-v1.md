# Lane2 v1 Prelude Design

This document sketches the v1 prelude. The prelude is implementation-supplied Lane2 source checked before user code. It is not a module system.

## Role

The prelude provides:

- operation structs used by recognized operators;
- primitive wrappers around unsafe builtins;
- anonymous top-level values that populate the initial preopen namespace.

Prelude entries are ordinary Lane2 values and types except where the compiler recognizes operation field pairs for operator aliases.

## Unsafe Builtins

Primitive functions are written using `builtin("...")`:

```lane2
fn int_add(a : Int, b : Int) -> Int {
  builtin("%i64_add")
}
```

`builtin` takes its type from direct expected context. In a function body, that expected type is the declared return type.

The type checker does not interpret intrinsic strings. Incorrect builtin use is undefined behavior.

## Operation Structs

Arithmetic operations:

```lane2
struct Add[T] {
  add : (T, T) -> T
}

struct Sub[T] {
  sub : (T, T) -> T
}

struct Mul[T] {
  mul : (T, T) -> T
}

struct Div[T] {
  div : (T, T) -> T
}

struct Rem[T] {
  rem : (T, T) -> T
}

struct Neg[T] {
  neg : (T) -> T
}
```

Boolean operations:

```lane2
struct And[T] {
  and : (T, T) -> T
}

struct Or[T] {
  or : (T, T) -> T
}

struct Not[T] {
  not : (T) -> T
}
```

Equality:

```lane2
struct Equal[T] {
  equal : (T, T) -> Bool
  not_equal : (T, T) -> Bool
}
```

Ordering:

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

Opening a `Compare[T]` also exposes `equal` and `not_equal` through struct field forwarding.

## Constructors

Operation laws are API conventions, not compiler-checked rules.

`make_equal` derives `not_equal` from `equal`:

```lane2
fn[T] make_equal(equal : (T, T) -> Bool) -> Equal[T] {
  Equal::{
    equal,
    not_equal: fn(a : T, b : T) {
      if equal(a, b) {
        false
      } else {
        true
      }
    },
  }
}
```

`make_compare` derives the rest of the ordering operations from `Equal[T]` and strict less-than:

```lane2
fn[T] make_compare(equal_impl : Equal[T], less : (T, T) -> Bool) -> Compare[T] {
  Compare::{
    equal_impl,
    less,
    less_eq: fn(a : T, b : T) {
      if equal_impl.equal(a, b) {
        true
      } else {
        less(a, b)
      }
    },
    greater: fn(a : T, b : T) {
      less(b, a)
    },
    greater_eq: fn(a : T, b : T) {
      if equal_impl.equal(a, b) {
        true
      } else {
        less(b, a)
      }
    },
  }
}
```

Function bodies do not inherit `open equal_impl` from the `Compare` struct declaration. They must use `equal_impl.equal(...)` or explicitly `open equal_impl`.

## Primitive Implementations

Example primitive wrappers:

```lane2
fn int_add(a : Int, b : Int) -> Int {
  builtin("%i64_add")
}

fn int_sub(a : Int, b : Int) -> Int {
  builtin("%i64_sub")
}

fn int_mul(a : Int, b : Int) -> Int {
  builtin("%i64_mul")
}

fn int_div(a : Int, b : Int) -> Int {
  builtin("%i64_div")
}

fn int_rem(a : Int, b : Int) -> Int {
  builtin("%i64_rem")
}

fn int_neg(a : Int) -> Int {
  builtin("%i64_neg")
}

fn int_equal(a : Int, b : Int) -> Bool {
  builtin("%i64_equal")
}

fn int_less(a : Int, b : Int) -> Bool {
  builtin("%i64_less")
}
```

Boolean wrappers:

```lane2
fn bool_and(a : Bool, b : Bool) -> Bool {
  builtin("%bool_and")
}

fn bool_or(a : Bool, b : Bool) -> Bool {
  builtin("%bool_or")
}

fn bool_not(a : Bool) -> Bool {
  builtin("%bool_not")
}

fn bool_equal(a : Bool, b : Bool) -> Bool {
  builtin("%bool_equal")
}
```

String equality:

```lane2
fn string_equal(a : String, b : String) -> Bool {
  builtin("%string_equal")
}
```

The exact intrinsic names are placeholders for the first interpreter/backend intrinsic table.

## Default Preopen Values

The prelude can populate the initial preopen namespace with anonymous top-level values.

```lane2
let : Add[Int] = Add::{ add: int_add }
let : Sub[Int] = Sub::{ sub: int_sub }
let : Mul[Int] = Mul::{ mul: int_mul }
let : Div[Int] = Div::{ div: int_div }
let : Rem[Int] = Rem::{ rem: int_rem }
let : Neg[Int] = Neg::{ neg: int_neg }

let int_equal_ops : Equal[Int] = make_equal(int_equal)
let : Compare[Int] = make_compare(int_equal_ops, int_less)

let : And[Bool] = And::{ and: bool_and }
let : Or[Bool] = Or::{ or: bool_or }
let : Not[Bool] = Not::{ not: bool_not }
let : Equal[Bool] = make_equal(bool_equal)

let : Equal[String] = make_equal(string_equal)
```

Because `Compare[Int]` forwards `Equal[Int]`, preopening `Compare[Int]` exposes `equal`, `not_equal`, `less`, `less_eq`, `greater`, and `greater_eq` for `Int`.

Do not also anonymously preopen `Equal[Int]` in the same scope if `Compare[Int]` already forwards it; that would conflict on `equal` and `not_equal`.

## Recognized Operator Mapping

| Operator | Recognized operation |
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
| `&&` | `And::and` |
| `||` | `Or::or` |
| `!` | `Not::not` |

Operators resolve through currently opened/preopened operation values. There is no type-directed instance search.

## Overriding With Local Open

Local `open` can shadow preopen:

```lane2
fn add_mod(a : Int, b : Int) -> Int {
  open modular_int_add_ops
  a + b
}
```

This is lexical scope, not global instance selection.

Top-level `open` belongs to the global layer and conflicts with preopened names instead of overriding them.
