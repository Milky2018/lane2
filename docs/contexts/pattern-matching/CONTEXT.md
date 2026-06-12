# Lane2 Pattern Matching

This context names pattern checking, exhaustiveness, and future pattern lowering
concepts.

## Language

**Core Pattern**:
A pattern form limited to wildcard, variable, literal, enum variant, or struct destructuring.
_Avoid_: guard pattern, or-pattern, as-pattern

**Checked Pattern**:
A pattern in Buslane or ANF whose constructors, binders, and covered type have been checked.
_Avoid_: parse pattern, decision tree

**Declaration-Order Struct Pattern**:
A checked struct pattern whose field patterns are ordered by the struct declaration.
_Avoid_: source-order struct pattern, partial record pattern

**Resolved Variant Pattern**:
A checked enum pattern that references a variant by variant symbol identity and stores payload patterns in declaration order.
_Avoid_: source variant spelling, raw tag pattern

**Qualified Variant Pattern**:
An enum variant pattern written with `Type::variant` so that bare identifiers remain variable bindings.
_Avoid_: unqualified variant pattern, capitalization-based pattern

**Pattern Binder Uniqueness**:
The rule that a single pattern cannot bind the same value name more than once.
_Avoid_: implicit equality pattern, binder shadowing within a pattern

**Pattern Matrix**:
A semantic analysis model for match arms where rows are checked arms and columns are matched occurrences.
_Avoid_: ad hoc arm scan, runtime matcher

**Decision Tree**:
A lowered representation of pattern matching as explicit tests and branches.
_Avoid_: source pattern, checked pattern

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

## Relationships

- Pattern matching in v1 uses **Checked Patterns**.
- **Checked Patterns** include primitive inhabitants as literal patterns.
- Enum variants in patterns use **Qualified Variant Pattern** syntax.
- A payloadless **Qualified Variant Pattern** is written without parentheses.
- Struct patterns support punning and explicit field renaming, but not rest or spread.
- Struct patterns must list all fields of the matched struct.
- Buslane and ANF represent struct patterns as **Declaration-Order Struct Patterns**.
- Buslane and ANF represent enum patterns as **Resolved Variant Patterns**.
- A match expression must be an **Exhaustive Match**.
- Every match arm must be a **Useful Match Arm**.
- Match arm usefulness is checked over nested patterns, not only top-level patterns.
- **Pattern Binder Uniqueness** is required.
- Pattern binders may shadow outer value names and are scoped only over their match arm body.
- Match evaluation uses **First-Match Arm Order**.
- **Decision Trees** are a lowered execution model, not the Buslane representation.

## Example dialogue

> **Dev:** "Can a bare identifier in a pattern mean an enum variant?"
> **Domain expert:** "No. Enum variants in patterns use **Qualified Variant Pattern** syntax so bare identifiers remain binders."
