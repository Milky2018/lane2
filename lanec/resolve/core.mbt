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
  payload_count : Int
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) struct ResolvedFunctionDeclaration {
  symbol : ValueSymbolId
  name : String
  type_parameters : Array[ResolvedTypeParameter]
  parameters : Array[ResolvedValueParameter]
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) struct ResolvedLetDeclaration {
  symbol : ValueSymbolId
  name : String?
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
  loc : SourceSpan
} derive(Debug, Eq)
