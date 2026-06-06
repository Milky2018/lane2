///|
pub(all) struct CheckResult {
  declarations : CheckedDeclarationEnvironment
  diagnostics : Array[CheckDiagnostic]
} derive(Debug, Eq)

///|
pub(all) struct CheckedDeclarationEnvironment {
  types : Array[CheckedTypeDeclaration]
  fields : Array[CheckedFieldDeclaration]
  variants : Array[CheckedVariantDeclaration]
} derive(Debug, Eq)

///|
pub(all) enum CheckedTypeDeclaration {
  Struct(CheckedStructDeclaration)
  Enum(CheckedEnumDeclaration)
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
pub(all) struct CheckDiagnostic {
  kind : CheckDiagnosticKind
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) enum CheckDiagnosticKind {
  UnresolvedType(String)
  TypeArgumentArityMismatch(name~ : String, expected~ : Int, actual~ : Int)
} derive(Debug, Eq)
