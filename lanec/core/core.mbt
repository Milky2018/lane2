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
pub(all) struct CoreTempId {
  index : Int
} derive(Debug, Eq, Compare)

///|
pub(all) struct CoreProgram {
  declarations : Array[CoreTopLevelDeclaration]
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) enum CoreTopLevelDeclaration {
  Struct(@checked.CheckedStructDeclaration)
  Enum(@checked.CheckedEnumDeclaration)
  Function(CoreFunctionDeclaration)
  Let(CoreLetDeclaration)
} derive(Debug, Eq)

///|
pub(all) struct CoreFunctionDeclaration {
  symbol : ValueSymbolId
  name : String
  type_parameters : Array[@types.TypeParameter]
  parameters : Array[@checked.CheckedValueParameter]
  return_type : @types.Type
  body : CoreExpr
  type_ : @types.Type
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) struct CoreLetDeclaration {
  symbol : ValueSymbolId
  name : String?
  value : CoreExpr
  type_ : @types.Type
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) enum CoreExpr {
  Atom(atom~ : CoreAtom, type_~ : @types.Type, loc~ : SourceSpan)
  Let(
    binding~ : CoreBinding,
    body~ : CoreExpr,
    type_~ : @types.Type,
    loc~ : SourceSpan
  )
  If(
    condition~ : CoreAtom,
    then_branch~ : CoreExpr,
    else_branch~ : CoreExpr,
    type_~ : @types.Type,
    loc~ : SourceSpan
  )
  Match(
    scrutinee~ : CoreAtom,
    arms~ : Array[CoreMatchArm],
    type_~ : @types.Type,
    loc~ : SourceSpan
  )
} derive(Debug, Eq)

///|
pub(all) enum CoreBinding {
  Value(
    symbol~ : ValueSymbolId,
    name~ : String?,
    rhs~ : CoreRhs,
    type_~ : @types.Type,
    loc~ : SourceSpan
  )
  Temp(
    temp~ : CoreTempId,
    rhs~ : CoreRhs,
    type_~ : @types.Type,
    loc~ : SourceSpan
  )
  Pattern(
    pattern~ : @checked.CheckedPattern,
    initializer~ : CoreAtom,
    loc~ : SourceSpan
  )
} derive(Debug, Eq)

///|
pub(all) enum CoreRhs {
  Atom(CoreAtom)
  Call(
    callee~ : CoreAtom,
    arguments~ : Array[CoreAtom],
    type_~ : @types.Type,
    loc~ : SourceSpan
  )
  TypeApplication(
    callee~ : CoreAtom,
    arguments~ : Array[@types.Type],
    type_~ : @types.Type,
    loc~ : SourceSpan
  )
  Field(
    base~ : CoreAtom,
    field~ : FieldSymbolId,
    name~ : String,
    type_~ : @types.Type,
    loc~ : SourceSpan
  )
  Struct(
    symbol~ : TypeSymbolId,
    type_arguments~ : Array[@types.Type],
    type_witnesses~ : Array[@checked.CheckedStructTypeWitness],
    fields~ : Array[CoreStructField],
    type_~ : @types.Type,
    loc~ : SourceSpan
  )
  Variant(
    symbol~ : VariantSymbolId,
    type_arguments~ : Array[@types.Type],
    arguments~ : Array[CoreAtom],
    type_~ : @types.Type,
    loc~ : SourceSpan
  )
} derive(Debug, Eq)

///|
pub(all) struct CoreStructField {
  symbol : FieldSymbolId
  name : String
  value : CoreAtom
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) enum CoreAtom {
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
  Temp(temp~ : CoreTempId, type_~ : @types.Type, loc~ : SourceSpan)
  UnsafeBuiltin(name~ : String, type_~ : @types.Type, loc~ : SourceSpan)
  Function(
    parameters~ : Array[@checked.CheckedValueParameter],
    body~ : CoreExpr,
    type_~ : @types.Type,
    loc~ : SourceSpan
  )
  TypeLambda(
    type_parameters~ : Array[@types.TypeParameter],
    body~ : CoreAtom,
    type_~ : @types.Type,
    loc~ : SourceSpan
  )
} derive(Debug, Eq)

///|
pub(all) struct CoreMatchArm {
  pattern : @checked.CheckedPattern
  body : CoreExpr
  loc : SourceSpan
} derive(Debug, Eq)

///|
/// Returns the type assigned to this core expression.
pub fn CoreExpr::type_(self : CoreExpr) -> @types.Type {
  match self {
    Atom(type_~, ..) | Let(type_~, ..) | If(type_~, ..) | Match(type_~, ..) =>
      type_
  }
}

///|
/// Returns the source span that produced this core expression.
pub fn CoreExpr::loc(self : CoreExpr) -> SourceSpan {
  match self {
    Atom(loc~, ..) | Let(loc~, ..) | If(loc~, ..) | Match(loc~, ..) => loc
  }
}

///|
/// Returns the type assigned to this core right-hand side.
pub fn CoreRhs::type_(self : CoreRhs) -> @types.Type {
  match self {
    Atom(atom) => atom.type_()
    Call(type_~, ..)
    | TypeApplication(type_~, ..)
    | Field(type_~, ..)
    | Struct(type_~, ..)
    | Variant(type_~, ..) => type_
  }
}

///|
/// Returns the source span that produced this core right-hand side.
pub fn CoreRhs::loc(self : CoreRhs) -> SourceSpan {
  match self {
    Atom(atom) => atom.loc()
    Call(loc~, ..)
    | TypeApplication(loc~, ..)
    | Field(loc~, ..)
    | Struct(loc~, ..)
    | Variant(loc~, ..) => loc
  }
}

///|
/// Returns the type assigned to this core atom.
pub fn CoreAtom::type_(self : CoreAtom) -> @types.Type {
  match self {
    Literal(type_~, ..)
    | Value(type_~, ..)
    | Temp(type_~, ..)
    | UnsafeBuiltin(type_~, ..)
    | Function(type_~, ..)
    | TypeLambda(type_~, ..) => type_
  }
}

///|
/// Returns the source span that produced this core atom.
pub fn CoreAtom::loc(self : CoreAtom) -> SourceSpan {
  match self {
    Literal(loc~, ..)
    | Value(loc~, ..)
    | Temp(loc~, ..)
    | UnsafeBuiltin(loc~, ..)
    | Function(loc~, ..)
    | TypeLambda(loc~, ..) => loc
  }
}
