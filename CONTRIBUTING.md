# Contributing

## MoonBit Workflow

Keep changes scoped to the package and behavior being changed. MoonBit packages
are directories with their own `moon.pkg`; file names inside a package are only
organizational.

Before handing off a change, run the relevant checks:

```sh
moon check --warn-list +73
moon test
moon info
moon fmt
moon check --target all --warn-list +73
git diff --check
```

For generated files such as parser output, avoid manual style-only edits unless
the generator or its input changes.

## MoonBit Control-Flow Style

Use `if ... is ...` and `guard ... is ... else` when they make the code
structurally simpler. Do not mechanically rewrite every two-arm `match`.

Prefer `if ... is ...` when a `match` only handles one useful case and the other
case is empty:

```mbt
if item is Field(field) {
  fields.push(check_field(field))
}
```

Prefer `guard ... else` when the fallback is an early exit and the success path
should continue at the current indentation level:

```mbt
guard result.source is Some(file) else { abort("expected source file") }
file
```

Prefer an `if` / `else if` chain when it flattens a nested fallback decision:

```mbt
let token = if keyword_table.get(name) is Some(token) {
  token
} else if reserved_word_table.contains(name) {
  RESERVED(name)
} else {
  IDENT(name)
}
```

Prefer an `if ... is ...` expression when both branches compute the same local
binding and the rewritten form removes a `match` layer around block branches:

```mbt
let type_ = if declaration.type_annotation is Some(type_annotation) {
  let type_ = check_type(type_annotation)
  check_initializer(type_)
  type_
} else {
  synthesize_initializer()
}
```

Keep `match` when it is a real domain dispatch over several cases, or when the
`if` form would not reduce indentation, line count, or branching complexity.
This is especially true for direct `Some`/`None` alternatives where both arms
are meaningful actions:

```mbt
match scope.value_binding(name) {
  Some(binding) => resolver.open_local_binding(binding, scope, loc)
  None => resolver.report(UnresolvedOpenValue(name), loc)
}
```

Also keep `match` for compact optional pretty-printing fragments when the
rewritten `if` form is only a spelling change:

```mbt
let annotation = match parameter.type_annotation {
  Some(type_) => space + text(":") + space + type_.pretty()
  None => empty
}
```

The test for this style rule is the resulting structure, not the syntax form:
rewrite only when the new code is shallower, shorter, or removes an empty
fallback branch without hiding the domain cases.
