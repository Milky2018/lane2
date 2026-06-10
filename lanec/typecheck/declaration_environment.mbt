///|
fn CheckedDeclarationEnvironment::checked_struct(
  self : CheckedDeclarationEnvironment,
  symbol : TypeSymbolId,
) -> CheckedStructDeclaration? {
  for declaration in self.types {
    if declaration is Struct(declaration) && declaration.symbol == symbol {
      return Some(declaration)
    }
  }
  None
}

///|
fn CheckedDeclarationEnvironment::checked_enum(
  self : CheckedDeclarationEnvironment,
  symbol : TypeSymbolId,
) -> CheckedEnumDeclaration? {
  for declaration in self.types {
    if declaration is Enum(declaration) && declaration.symbol == symbol {
      return Some(declaration)
    }
  }
  None
}

///|
fn CheckedDeclarationEnvironment::field_path_type(
  self : CheckedDeclarationEnvironment,
  diagnostics : Array[TypeCheckDiagnostic],
  base_type : @types.Type,
  path : Array[FieldSymbolId],
  name : String,
  loc : SourceSpan,
) -> @types.Type {
  let mut current = base_type
  for field in path {
    current = self.field_type(diagnostics, current, field, name, loc)
  }
  current
}

///|
fn CheckedDeclarationEnvironment::field_type(
  self : CheckedDeclarationEnvironment,
  diagnostics : Array[TypeCheckDiagnostic],
  base_type : @types.Type,
  field : FieldSymbolId,
  name : String,
  loc : SourceSpan,
) -> @types.Type {
  match base_type {
    Nominal(owner, arguments) => {
      guard self.checked_struct(owner) is Some(declaration) else {
        diagnostics.push({ kind: NotAStruct(base_type), loc })
        return Error
      }
      guard declaration.field(field) is Some(field_declaration) else {
        diagnostics.push({ kind: UnknownField(name~), loc })
        return Error
      }
      field_declaration.type_.substitute(
        declaration.nominal_substitution(arguments),
      )
    }
    Error => Error
    _ => {
      diagnostics.push({ kind: NotAStruct(base_type), loc })
      Error
    }
  }
}

///|
fn CheckedStructDeclaration::field(
  self : CheckedStructDeclaration,
  symbol : FieldSymbolId,
) -> CheckedFieldDeclaration? {
  for field in self.fields {
    if field.symbol == symbol {
      return Some(field)
    }
  }
  None
}

///|
fn CheckedEnumDeclaration::variant(
  self : CheckedEnumDeclaration,
  symbol : VariantSymbolId,
) -> CheckedVariantDeclaration? {
  for variant in self.variants {
    if variant.symbol == symbol {
      return Some(variant)
    }
  }
  None
}

///|
fn CheckedStructDeclaration::nominal_substitution(
  self : CheckedStructDeclaration,
  arguments : Array[@types.Type],
) -> @types.TypeSubstitution {
  let substitution = @types.TypeSubstitution::TypeSubstitution()
  let length = if self.type_parameters.length() < arguments.length() {
    self.type_parameters.length()
  } else {
    arguments.length()
  }
  for index in 0..<length {
    substitution.insert(self.type_parameters[index].id, arguments[index])
  }
  substitution
}
