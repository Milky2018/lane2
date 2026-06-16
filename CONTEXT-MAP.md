# Context Map

Lane2 has several related design contexts. Read the context that matches the
topic instead of loading every glossary at once.

## Contexts

- [Project](./CONTEXT.md) — repository-level terms shared by all Lane2 work.
- [Language Surface](./docs/contexts/language-surface/CONTEXT.md) — source syntax, declarations, blocks, functions, structs, enums, and operator surface forms.
- [Type System](./docs/contexts/type-system/CONTEXT.md) — checked type objects, local type inference, generics, nominal types, and runtime type erasure.
- [Compiler Pipeline](./docs/contexts/compiler-pipeline/CONTEXT.md) — compiler identities, source IRs, Buslane Core Language, ANF IR, and semantic lowering.
- [Pattern Matching](./docs/contexts/pattern-matching/CONTEXT.md) — checked patterns, exhaustiveness, usefulness, and future decision-tree lowering.
- [Contextual Resolution](./docs/contexts/contextual-resolution/CONTEXT.md) — contextual offers, contextual parameters, operator aliases, prelude operations, and unsafe builtins.
- [Runtime And Execution](./docs/contexts/runtime-execution/CONTEXT.md) — execution targets, the reference interpreter, runtime values, environments, closures, and runtime error boundaries.
- [IDE Tooling](./docs/contexts/ide-tooling/CONTEXT.md) — LSP server boundaries, VS Code extension responsibilities, editor diagnostics, and compiler-analysis APIs.

## Relationships

- **Language Surface -> Type System**: source forms are checked using local type inference and nominal type rules.
- **Language Surface -> Contextual Resolution**: operator syntax and omitted contextual arguments elaborate through contextual resolution.
- **Type System -> Compiler Pipeline**: checked type objects and symbol identities are carried through Checked Source, Buslane, and ANF.
- **Pattern Matching -> Compiler Pipeline**: checked patterns are analyzed before Buslane; Buslane uses one-level matches, while decision trees are reserved for later execution IR.
- **Compiler Pipeline -> Runtime And Execution**: Buslane defines the semantic core; ANF currently feeds the reference interpreter.
- **IDE Tooling -> Compiler Pipeline**: editor features call compiler-analysis APIs and consume diagnostics without owning compiler semantics.
