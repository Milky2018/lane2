# Buslane Core Language before ANF

Lane2 separates its semantic core language from administrative normal form.
Buslane is the typed expression-tree Core Language produced after Checked Source
elaboration. ANF is a later normalized IR that introduces atom/RHS/binding
structure and explicit administrative temporaries.

The previous design used structured ANF as the first typed core representation.
That conflated two different responsibilities: preserving the language's
semantic constructs and making evaluation order mechanically explicit for later
execution. Buslane now owns the semantic core boundary; ANF owns the
normalization boundary after Buslane.

The current interpreter still evaluates ANF while the compiler is being
re-layered. The intended pipeline is:

```text
Source -> Resolved -> Desugared -> Checked Source -> Buslane -> ANF -> Interpreter/VM
```

ADR-0004 is superseded by this decision. Other older ADRs that mention "typed
core" should be read as applying to Buslane when they describe semantic
constructs, and to ANF only when they describe administrative atom/RHS/binding
shape.
