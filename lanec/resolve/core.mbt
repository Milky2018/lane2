///|
pub(all) struct ResolvedSourceFile {
  symbols : SymbolRegistry
  declarations : Array[ResolvedTopLevelDeclaration]
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) enum ResolvedTopLevelDeclaration {
  Struct(ResolvedStructDeclaration)
  Enum(ResolvedEnumDeclaration)
  Function(ResolvedFunctionDeclaration)
  Let(ResolvedLetDeclaration)
  Open(ResolvedOpenDeclaration)
} derive(Debug, Eq)

///|
pub(all) struct ResolvedStructDeclaration {
  symbol : TypeSymbolId
  name : String
  type_parameters : Array[ResolvedTypeParameter]
  members : Array[ResolvedStructMember]
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) enum ResolvedStructMember {
  Field(ResolvedFieldDeclaration)
  Open(ResolvedOpenDeclaration)
} derive(Debug, Eq)

///|
pub(all) struct ResolvedFieldDeclaration {
  symbol : FieldSymbolId
  name : String
  type_ : ResolvedType
  index : Int
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) struct ResolvedEnumDeclaration {
  symbol : TypeSymbolId
  name : String
  type_parameters : Array[ResolvedTypeParameter]
  variants : Array[ResolvedEnumVariant]
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) struct ResolvedEnumVariant {
  symbol : VariantSymbolId
  name : String
  index : Int
  payload : Array[ResolvedType]
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) struct ResolvedFunctionDeclaration {
  symbol : ValueSymbolId
  name : String
  type_parameters : Array[ResolvedTypeParameter]
  parameters : Array[ResolvedValueParameter]
  return_type : ResolvedType
  body : ResolvedExpr
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) struct ResolvedLetDeclaration {
  symbol : ValueSymbolId
  name : String?
  type_annotation : ResolvedType?
  initializer : ResolvedExpr
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) struct ResolvedOpenDeclaration {
  name : String
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) struct ResolvedTypeParameter {
  symbol : TypeParameterId
  name : String
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) struct ResolvedValueParameter {
  symbol : ValueSymbolId
  name : String
  type_ : ResolvedType
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) enum ResolvedType {
  Primitive(@types.PrimitiveType, loc~ : SourceSpan)
  Nominal(
    symbol~ : TypeSymbolId,
    name~ : String,
    arguments~ : Array[ResolvedType],
    loc~ : SourceSpan
  )
  Parameter(symbol~ : TypeParameterId, name~ : String, loc~ : SourceSpan)
  Function(
    type_parameters~ : Array[ResolvedTypeParameter],
    parameters~ : Array[ResolvedType],
    result~ : ResolvedType,
    loc~ : SourceSpan
  )
  Unresolved(
    name~ : String,
    arguments~ : Array[ResolvedType],
    loc~ : SourceSpan
  )
} derive(Debug, Eq)

///|
pub(all) enum ResolvedValueReference {
  Symbol(ValueSymbolId)
  Unresolved(String)
} derive(Debug, Eq)

///|
pub(all) enum ResolvedVariantReference {
  Symbol(VariantSymbolId)
  Unresolved(type_name~ : String, variant~ : String)
  UnresolvedUnqualified(String)
  Ambiguous(name~ : String, candidates~ : Array[VariantSymbolId])
} derive(Debug, Eq)

///|
pub(all) struct ResolvedFunctionLiteralParameter {
  symbol : ValueSymbolId
  name : String
  type_annotation : ResolvedType?
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) struct ResolvedStructLiteralField {
  name : String
  value : ResolvedExpr?
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) struct ResolvedMatchArm {
  pattern : ResolvedPattern
  body : ResolvedExpr
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) struct ResolvedStructPatternField {
  name : String
  pattern : ResolvedPattern?
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) enum ResolvedLocalItem {
  Let(ResolvedLetDeclaration)
  Function(ResolvedFunctionDeclaration)
  Open(ResolvedOpenDeclaration)
} derive(Debug, Eq)

///|
pub(all) enum ResolvedExpr {
  IntLiteral(String, loc~ : SourceSpan)
  StringLiteral(String, loc~ : SourceSpan)
  BoolLiteral(Bool, loc~ : SourceSpan)
  UnitLiteral(loc~ : SourceSpan)
  Var(name~ : String, reference~ : ResolvedValueReference, loc~ : SourceSpan)
  QualifiedVariant(
    type_name~ : String,
    type_arguments~ : Array[ResolvedType],
    variant~ : String,
    reference~ : ResolvedVariantReference,
    arguments~ : Array[ResolvedExpr],
    loc~ : SourceSpan
  )
  UnqualifiedVariant(
    variant~ : String,
    reference~ : ResolvedVariantReference,
    arguments~ : Array[ResolvedExpr],
    loc~ : SourceSpan
  )
  StructLiteral(
    type_name~ : String,
    type_arguments~ : Array[ResolvedType],
    fields~ : Array[ResolvedStructLiteralField],
    loc~ : SourceSpan
  )
  Builtin(String, loc~ : SourceSpan)
  FunctionLiteral(
    type_parameters~ : Array[ResolvedTypeParameter],
    parameters~ : Array[ResolvedFunctionLiteralParameter],
    return_type~ : ResolvedType?,
    body~ : ResolvedExpr,
    loc~ : SourceSpan
  )
  Block(
    items~ : Array[ResolvedLocalItem],
    result~ : ResolvedExpr,
    loc~ : SourceSpan
  )
  If(
    condition~ : ResolvedExpr,
    then_branch~ : ResolvedExpr,
    else_branch~ : ResolvedExpr,
    loc~ : SourceSpan
  )
  Match(
    scrutinee~ : ResolvedExpr,
    arms~ : Array[ResolvedMatchArm],
    loc~ : SourceSpan
  )
  Call(
    callee~ : ResolvedExpr,
    arguments~ : Array[ResolvedExpr],
    loc~ : SourceSpan
  )
  Field(base~ : ResolvedExpr, name~ : String, loc~ : SourceSpan)
  Unary(
    operator~ : @syntax.UnaryOperator,
    operand~ : ResolvedExpr,
    loc~ : SourceSpan
  )
  Binary(
    operator~ : @syntax.BinaryOperator,
    left~ : ResolvedExpr,
    right~ : ResolvedExpr,
    loc~ : SourceSpan
  )
  Pipeline(left~ : ResolvedExpr, right~ : ResolvedExpr, loc~ : SourceSpan)
} derive(Debug, Eq)

///|
pub(all) enum ResolvedPattern {
  Wildcard(SourceSpan)
  Binding(name~ : String, symbol~ : ValueSymbolId, loc~ : SourceSpan)
  IntLiteral(String, loc~ : SourceSpan)
  StringLiteral(String, loc~ : SourceSpan)
  BoolLiteral(Bool, loc~ : SourceSpan)
  QualifiedVariant(
    type_name~ : String,
    variant~ : String,
    reference~ : ResolvedVariantReference,
    arguments~ : Array[ResolvedPattern],
    loc~ : SourceSpan
  )
  Struct(
    type_name~ : String,
    fields~ : Array[ResolvedStructPatternField],
    loc~ : SourceSpan
  )
} derive(Debug, Eq)
