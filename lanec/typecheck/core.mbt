///|
pub(all) struct DeclarationTypeCheckResult {
  declarations : CheckedDeclarationEnvironment
  diagnostics : Array[TypeCheckDiagnostic]
} derive(Debug, Eq)

///|
pub(all) struct TypeCheckResult {
  declarations : CheckedDeclarationEnvironment
  values : CheckedValueEnvironment
  diagnostics : Array[TypeCheckDiagnostic]
} derive(Debug, Eq)

///|
pub(all) struct CheckedSourceTypeCheckResult {
  source : @checked.CheckedSourceFile?
  diagnostics : Array[TypeCheckDiagnostic]
} derive(Debug, Eq)

///|
pub(all) struct CheckedDeclarationEnvironment {
  types : Array[CheckedTypeDeclaration]
  fields : Array[CheckedFieldDeclaration]
  variants : Array[CheckedVariantDeclaration]
} derive(Debug, Eq)

///|
pub(all) struct CheckedValueEnvironment {
  values : Array[CheckedValueDeclaration]
} derive(Debug, Eq)

///|
pub(all) enum CheckedTypeDeclaration {
  Struct(CheckedStructDeclaration)
  Enum(CheckedEnumDeclaration)
} derive(Debug, Eq)

///|
pub(all) enum CheckedValueDeclaration {
  Function(CheckedFunctionDeclaration)
  Let(CheckedLetDeclaration)
} derive(Debug, Eq)

///|
pub(all) struct CheckedStructDeclaration {
  symbol : TypeSymbolId
  name : String
  type_parameters : Array[@types.TypeParameter]
  fields : Array[CheckedFieldDeclaration]
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) struct CheckedFieldDeclaration {
  symbol : FieldSymbolId
  name : String
  index : Int
  type_ : @types.Type
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) struct CheckedEnumDeclaration {
  symbol : TypeSymbolId
  name : String
  type_parameters : Array[@types.TypeParameter]
  variants : Array[CheckedVariantDeclaration]
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) struct CheckedVariantDeclaration {
  symbol : VariantSymbolId
  name : String
  index : Int
  payload : Array[@types.Type]
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) struct CheckedFunctionDeclaration {
  symbol : ValueSymbolId
  name : String
  type_ : @types.Type
  parameters : Array[@checked.CheckedValueParameter]
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) struct CheckedLetDeclaration {
  symbol : ValueSymbolId
  name : String?
  type_ : @types.Type
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) struct TypeCheckDiagnostic {
  kind : TypeCheckDiagnosticKind
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) enum TypeCheckDiagnosticKind {
  UnresolvedType(String)
  UnresolvedValue(String)
  MissingTopLevelLetAnnotation
  TypeArgumentArityMismatch(name~ : String, expected~ : Int, actual~ : Int)
  TypeMismatch(expected~ : @types.Type, actual~ : @types.Type)
  NotCallable(@types.Type)
  UnknownField(name~ : String)
  MissingField(name~ : String)
  DuplicateField(name~ : String)
  NotAStruct(@types.Type)
  NonExhaustiveMatch(@types.Type)
  UnreachableMatchArm
  DuplicatePatternBinder(name~ : String)
  PatternArityMismatch(name~ : String, expected~ : Int, actual~ : Int)
  InvalidIntLiteral(String)
  CannotInferExpression(String)
} derive(Debug, Eq)
