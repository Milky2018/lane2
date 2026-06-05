///|
using @basic {type SourceSpan}

///|
using @syntax {
  type EnumDeclaration,
  type EnumVariant,
  type Expr,
  type FieldDeclaration,
  type FunctionDeclaration,
  type FunctionLiteralParameter,
  type LetDeclaration,
  type LocalItem,
  type MatchArm,
  type OpenDeclaration,
  type Parameter,
  type Pattern,
  type SourceFile,
  type StructDeclaration,
  type StructLiteralField,
  type StructMember,
  type StructPatternField,
  type TopLevelDeclaration,
  type Type,
}

///|
fn span(loc : (SourceSpan, SourceSpan)) -> SourceSpan {
  SourceSpan::join(loc.0, loc.1)
}

///|
fn[T] comma_push(items : Array[T], item : T) -> Array[T] {
  items.push(item)
  items
}
