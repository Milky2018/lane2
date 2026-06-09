///|
pub(all) struct CheckedSourceFile {
  declarations : Array[CheckedTopLevelDeclaration]
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) enum CheckedTopLevelDeclaration {
  Struct(@typecheck.CheckedStructDeclaration)
  Enum(@typecheck.CheckedEnumDeclaration)
  Function(CheckedFunctionDeclaration)
  Let(CheckedLetDeclaration)
} derive(Debug, Eq)

///|
pub(all) struct CheckedFunctionDeclaration {
  symbol : ValueSymbolId
  name : String
  type_parameters : Array[@types.TypeParameter]
  parameters : Array[CheckedValueParameter]
  return_type : @types.Type
  body : CheckedExpr
  type_ : @types.Type
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) struct CheckedLetDeclaration {
  symbol : ValueSymbolId
  name : String?
  initializer : CheckedExpr
  type_ : @types.Type
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) struct CheckedValueParameter {
  symbol : ValueSymbolId
  name : String
  type_ : @types.Type
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) enum CheckedLocalItem {
  Let(CheckedLetDeclaration)
  Function(CheckedFunctionDeclaration)
} derive(Debug, Eq)

///|
pub(all) enum CheckedExpr {
  IntLiteral(value~ : String, type_~ : @types.Type, loc~ : SourceSpan)
  StringLiteral(value~ : String, type_~ : @types.Type, loc~ : SourceSpan)
  BoolLiteral(value~ : Bool, type_~ : @types.Type, loc~ : SourceSpan)
  UnitLiteral(type_~ : @types.Type, loc~ : SourceSpan)
  Value(
    name~ : String,
    symbol~ : ValueSymbolId,
    type_~ : @types.Type,
    loc~ : SourceSpan
  )
  UnsafeBuiltin(name~ : String, type_~ : @types.Type, loc~ : SourceSpan)
  FunctionLiteral(
    type_parameters~ : Array[@types.TypeParameter],
    parameters~ : Array[CheckedValueParameter],
    return_type~ : @types.Type,
    body~ : CheckedExpr,
    type_~ : @types.Type,
    loc~ : SourceSpan
  )
  TypeApplication(
    callee~ : CheckedExpr,
    arguments~ : Array[@types.Type],
    type_~ : @types.Type,
    loc~ : SourceSpan
  )
  Block(
    items~ : Array[CheckedLocalItem],
    result~ : CheckedExpr,
    type_~ : @types.Type,
    loc~ : SourceSpan
  )
  If(
    condition~ : CheckedExpr,
    then_branch~ : CheckedExpr,
    else_branch~ : CheckedExpr,
    type_~ : @types.Type,
    loc~ : SourceSpan
  )
  Match(
    scrutinee~ : CheckedExpr,
    arms~ : Array[CheckedMatchArm],
    type_~ : @types.Type,
    loc~ : SourceSpan
  )
  Call(
    callee~ : CheckedExpr,
    arguments~ : Array[CheckedExpr],
    type_~ : @types.Type,
    loc~ : SourceSpan
  )
  Field(
    base~ : CheckedExpr,
    field~ : FieldSymbolId,
    name~ : String,
    type_~ : @types.Type,
    loc~ : SourceSpan
  )
  StructLiteral(
    symbol~ : TypeSymbolId,
    type_arguments~ : Array[@types.Type],
    fields~ : Array[CheckedStructLiteralField],
    type_~ : @types.Type,
    loc~ : SourceSpan
  )
  Variant(
    symbol~ : VariantSymbolId,
    arguments~ : Array[CheckedExpr],
    type_~ : @types.Type,
    loc~ : SourceSpan
  )
} derive(Debug, Eq)

///|
pub(all) struct CheckedStructLiteralField {
  symbol : FieldSymbolId
  name : String
  value : CheckedExpr
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) struct CheckedMatchArm {
  pattern : CheckedPattern
  body : CheckedExpr
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) enum CheckedPattern {
  Wildcard(type_~ : @types.Type, loc~ : SourceSpan)
  Binding(
    name~ : String,
    symbol~ : ValueSymbolId,
    type_~ : @types.Type,
    loc~ : SourceSpan
  )
  IntLiteral(value~ : String, type_~ : @types.Type, loc~ : SourceSpan)
  StringLiteral(value~ : String, type_~ : @types.Type, loc~ : SourceSpan)
  BoolLiteral(value~ : Bool, type_~ : @types.Type, loc~ : SourceSpan)
  UnitLiteral(type_~ : @types.Type, loc~ : SourceSpan)
  Variant(
    symbol~ : VariantSymbolId,
    arguments~ : Array[CheckedPattern],
    type_~ : @types.Type,
    loc~ : SourceSpan
  )
  Struct(
    symbol~ : TypeSymbolId,
    fields~ : Array[CheckedStructPatternField],
    type_~ : @types.Type,
    loc~ : SourceSpan
  )
} derive(Debug, Eq)

///|
pub(all) struct CheckedStructPatternField {
  symbol : FieldSymbolId
  name : String
  pattern : CheckedPattern
  loc : SourceSpan
} derive(Debug, Eq)

///|
/// Returns the type assigned to this checked expression.
pub fn CheckedExpr::type_(self : CheckedExpr) -> @types.Type {
  match self {
    IntLiteral(type_~, ..)
    | StringLiteral(type_~, ..)
    | BoolLiteral(type_~, ..)
    | UnitLiteral(type_~, ..)
    | Value(type_~, ..)
    | UnsafeBuiltin(type_~, ..)
    | FunctionLiteral(type_~, ..)
    | TypeApplication(type_~, ..)
    | Block(type_~, ..)
    | If(type_~, ..)
    | Match(type_~, ..)
    | Call(type_~, ..)
    | Field(type_~, ..)
    | StructLiteral(type_~, ..)
    | Variant(type_~, ..) => type_
  }
}

///|
/// Returns the source span that produced this checked expression.
pub fn CheckedExpr::loc(self : CheckedExpr) -> SourceSpan {
  match self {
    IntLiteral(loc~, ..)
    | StringLiteral(loc~, ..)
    | BoolLiteral(loc~, ..)
    | UnitLiteral(loc~, ..)
    | Value(loc~, ..)
    | UnsafeBuiltin(loc~, ..)
    | FunctionLiteral(loc~, ..)
    | TypeApplication(loc~, ..)
    | Block(loc~, ..)
    | If(loc~, ..)
    | Match(loc~, ..)
    | Call(loc~, ..)
    | Field(loc~, ..)
    | StructLiteral(loc~, ..)
    | Variant(loc~, ..) => loc
  }
}

///|
/// Returns the type covered by this checked pattern.
pub fn CheckedPattern::type_(self : CheckedPattern) -> @types.Type {
  match self {
    Wildcard(type_~, ..)
    | Binding(type_~, ..)
    | IntLiteral(type_~, ..)
    | StringLiteral(type_~, ..)
    | BoolLiteral(type_~, ..)
    | UnitLiteral(type_~, ..)
    | Variant(type_~, ..)
    | Struct(type_~, ..) => type_
  }
}

///|
/// Returns the source span that produced this checked pattern.
pub fn CheckedPattern::loc(self : CheckedPattern) -> SourceSpan {
  match self {
    Wildcard(loc~, ..)
    | Binding(loc~, ..)
    | IntLiteral(loc~, ..)
    | StringLiteral(loc~, ..)
    | BoolLiteral(loc~, ..)
    | UnitLiteral(loc~, ..)
    | Variant(loc~, ..)
    | Struct(loc~, ..) => loc
  }
}
