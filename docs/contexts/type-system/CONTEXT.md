# Lane2 Type System

This context names type-level concepts used by the checker, specification, and
later IRs.

## Language

**Type Object**:
A checked type representation shared by semantic analysis, Buslane Core Language, and execution contracts.
_Avoid_: source type syntax, parser type node

**Kind**:
A classifier of type-level expressions, with v1 supporting only the `Type` kind.
_Avoid_: runtime type, trait constraint

**Primitive Type**:
A built-in type provided by the language core: `Int`, `Bool`, `String`, or `Unit`.
_Avoid_: standard library type, numeric tower

**ASCII String**:
An immutable sequence of ASCII bytes.
_Avoid_: Unicode string, UTF-16 string

**Nominal Type**:
A type whose identity comes from its declaration name rather than from having the same structure as another type.
_Avoid_: structural type, shape-compatible type

**Generic Type Definition**:
A struct or enum declaration whose explicit type parameter list follows the type name.
_Avoid_: keyword-attached type parameters

**Generic Type Application**:
A use of a generic type name with explicit type arguments in brackets.
_Avoid_: inferred type constructor use, angle-bracket type application

**Parameter-List Function Type**:
A function type written with a parenthesized parameter list followed by `->` and a result type.
_Avoid_: curried function type, bare arrow chain

**Generic Function Type**:
A function type whose explicit type parameter list precedes its parenthesized value parameter list.
_Avoid_: implicit forall, top-level-only polymorphic type

**Forall Type**:
A type object that binds type parameters over another type.
_Avoid_: function-owned generic parameter list, implicit polymorphic wrapper

**Type Alpha-Equivalence**:
The rule that types differing only by bound type parameter names are equal.
_Avoid_: display-name equality, raw binder identity equality

**Local Type Inference**:
The bidirectional rule that type information may be synthesized upward or checked downward between adjacent syntax nodes without global constraint solving.
_Avoid_: global inference, HM flattening, use-site backpropagation

**Direct Context Inference**:
The rule that an omitted local type may be inferred only from the expression's immediate expected type, not from later uses of a bound name.
_Avoid_: use-site backpropagation, whole-scope inference

**Implicit Generic Instantiation**:
The rule that type parameters of a generic function or data constructor are inferred at the use site unless ambiguity requires explicit type arguments.
_Avoid_: mandatory type application, global generic inference

**Local Generic Function**:
A function defined inside an expression or definition that may introduce its own type parameters.
_Avoid_: top-level-only polymorphism, lifted generic function

**Generic Function Literal**:
A function literal that introduces its own type parameters where the function is written.
_Avoid_: generic binding, inferred generic let

**Type Application**:
A Buslane operation that instantiates a polymorphic value with type arguments.
_Avoid_: runtime type argument, erased substitution only

**First-Class Type Application**:
A Buslane type application whose callee is any polymorphic value rather than only a known generic function symbol.
_Avoid_: direct generic call only, runtime typecase

**Type Lambda**:
A Buslane value form that abstracts over type parameters to create a polymorphic value.
_Avoid_: generic ordinary lambda, runtime type function

**Runtime Typecase**:
A runtime branch whose behavior depends on inspecting a type argument or type constructor.
_Avoid_: ordinary pattern match, implicit reflection

**Runtime Type Erasure**:
The rule that generic type arguments used for checking are not represented in execution targets.
_Avoid_: runtime generic metadata, implicit type evidence

**Uniform Value Representation**:
A runtime representation where values share one execution-level value model rather than being specialized by generic type arguments.
_Avoid_: monomorphized value layout, type-specialized runtime

## Relationships

- **Type Objects** are distinct from source type syntax.
- Every type parameter identity has a **Kind**; v1 supports only `Type`.
- Lane2 v1 has four **Primitive Types**: `Int`, `Bool`, `String`, and `Unit`.
- **Enum Types** and **Struct Types** create **Nominal Types**.
- A generic struct or enum uses **Generic Type Definition** syntax and is used with **Generic Type Application** syntax.
- Lane2 function types use **Parameter-List Function Type** syntax.
- **Generic Function Type** syntax elaborates to a **Forall Type**.
- **Forall Types** use **Type Alpha-Equivalence** for equality.
- **Local Type Inference** uses **Direct Context Inference** and does not infer a local function's parameters from later calls.
- Generic functions and data constructors use **Implicit Generic Instantiation**.
- Lane2 v1 has no **Runtime Typecase**.
- Generic type arguments use **Runtime Type Erasure** before execution.
- Execution targets use **Uniform Value Representation** for generic code.

## Example dialogue

> **Dev:** "Can we infer a local function parameter type from a later call?"
> **Domain expert:** "No. **Local Type Inference** only moves through adjacent syntax; later uses do not back-propagate into the binding."
