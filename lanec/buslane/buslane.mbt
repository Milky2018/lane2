///|
using @basic {type SourceSpan}

///|
using @symbol {
  type FieldSymbolId,
  type TypeSymbolId,
  type ValueSymbolId,
  type VariantSymbolId,
}

///|
pub(all) struct BuslaneProgram {
  declarations : Array[BuslaneTopLevelDeclaration]
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) enum BuslaneTopLevelDeclaration {
  Struct(@checked.CheckedStructDeclaration)
  Enum(@checked.CheckedEnumDeclaration)
  Function(BuslaneFunctionDeclaration)
  Let(BuslaneLetDeclaration)
} derive(Debug, Eq)

///|
pub(all) struct BuslaneFunctionDeclaration {
  symbol : ValueSymbolId
  name : String
  type_parameters : Array[@types.TypeParameter]
  parameters : Array[@checked.CheckedValueParameter]
  return_type : @types.Type
  body : BuslaneExpr
  type_ : @types.Type
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) struct BuslaneLetDeclaration {
  symbol : ValueSymbolId
  name : String?
  value : BuslaneExpr
  type_ : @types.Type
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) enum BuslaneBinding {
  Value(
    symbol~ : ValueSymbolId,
    name~ : String?,
    value~ : BuslaneExpr,
    type_~ : @types.Type,
    loc~ : SourceSpan
  )
  Pattern(
    pattern~ : @checked.CheckedPattern,
    initializer~ : BuslaneExpr,
    loc~ : SourceSpan
  )
} derive(Debug, Eq)

///|
pub(all) enum BuslaneExpr {
  Literal(
    literal~ : @checked.CheckedLiteral,
    type_~ : @types.Type,
    loc~ : SourceSpan
  )
  Value(
    name~ : String,
    symbol~ : ValueSymbolId,
    type_~ : @types.Type,
    loc~ : SourceSpan
  )
  UnsafeBuiltin(name~ : String, type_~ : @types.Type, loc~ : SourceSpan)
  Function(
    parameters~ : Array[@checked.CheckedValueParameter],
    body~ : BuslaneExpr,
    type_~ : @types.Type,
    loc~ : SourceSpan
  )
  TypeLambda(
    type_parameters~ : Array[@types.TypeParameter],
    body~ : BuslaneExpr,
    type_~ : @types.Type,
    loc~ : SourceSpan
  )
  TypeApplication(
    callee~ : BuslaneExpr,
    arguments~ : Array[@types.Type],
    type_~ : @types.Type,
    loc~ : SourceSpan
  )
  Let(
    binding~ : BuslaneBinding,
    body~ : BuslaneExpr,
    type_~ : @types.Type,
    loc~ : SourceSpan
  )
  If(
    condition~ : BuslaneExpr,
    then_branch~ : BuslaneExpr,
    else_branch~ : BuslaneExpr,
    type_~ : @types.Type,
    loc~ : SourceSpan
  )
  Match(
    scrutinee~ : BuslaneExpr,
    arms~ : Array[BuslaneMatchArm],
    type_~ : @types.Type,
    loc~ : SourceSpan
  )
  Call(
    callee~ : BuslaneExpr,
    arguments~ : Array[BuslaneExpr],
    type_~ : @types.Type,
    loc~ : SourceSpan
  )
  Field(
    base~ : BuslaneExpr,
    field~ : FieldSymbolId,
    name~ : String,
    type_~ : @types.Type,
    loc~ : SourceSpan
  )
  Struct(
    symbol~ : TypeSymbolId,
    type_arguments~ : Array[@types.Type],
    type_witnesses~ : Array[@checked.CheckedStructTypeWitness],
    fields~ : Array[BuslaneStructField],
    type_~ : @types.Type,
    loc~ : SourceSpan
  )
  Variant(
    symbol~ : VariantSymbolId,
    type_arguments~ : Array[@types.Type],
    arguments~ : Array[BuslaneExpr],
    type_~ : @types.Type,
    loc~ : SourceSpan
  )
} derive(Debug, Eq)

///|
pub(all) struct BuslaneStructField {
  symbol : FieldSymbolId
  name : String
  value : BuslaneExpr
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) struct BuslaneMatchArm {
  pattern : @checked.CheckedPattern
  body : BuslaneExpr
  loc : SourceSpan
} derive(Debug, Eq)

///|
/// Returns the type assigned to this Buslane expression.
pub fn BuslaneExpr::type_(self : BuslaneExpr) -> @types.Type {
  match self {
    Literal(type_~, ..)
    | Value(type_~, ..)
    | UnsafeBuiltin(type_~, ..)
    | Function(type_~, ..)
    | TypeLambda(type_~, ..)
    | TypeApplication(type_~, ..)
    | Let(type_~, ..)
    | If(type_~, ..)
    | Match(type_~, ..)
    | Call(type_~, ..)
    | Field(type_~, ..)
    | Struct(type_~, ..)
    | Variant(type_~, ..) => type_
  }
}

///|
/// Returns the source span that produced this Buslane expression.
pub fn BuslaneExpr::loc(self : BuslaneExpr) -> SourceSpan {
  match self {
    Literal(loc~, ..)
    | Value(loc~, ..)
    | UnsafeBuiltin(loc~, ..)
    | Function(loc~, ..)
    | TypeLambda(loc~, ..)
    | TypeApplication(loc~, ..)
    | Let(loc~, ..)
    | If(loc~, ..)
    | Match(loc~, ..)
    | Call(loc~, ..)
    | Field(loc~, ..)
    | Struct(loc~, ..)
    | Variant(loc~, ..) => loc
  }
}
