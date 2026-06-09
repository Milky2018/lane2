///|
fn CheckedDeclarationEnvironment::checked_struct(
  self : CheckedDeclarationEnvironment,
  symbol : TypeSymbolId,
) -> CheckedStructDeclaration? {
  for declaration in self.types {
    match declaration {
      Struct(declaration) =>
        if declaration.symbol == symbol {
          return Some(declaration)
        }
      _ => ()
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
    match declaration {
      Enum(declaration) =>
        if declaration.symbol == symbol {
          return Some(declaration)
        }
      _ => ()
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
    Nominal(owner, arguments) =>
      match self.checked_struct(owner) {
        Some(declaration) =>
          match declaration.field(field) {
            Some(field_declaration) =>
              field_declaration.type_.substitute(
                declaration.nominal_substitution(arguments),
              )
            None => {
              diagnostics.push({ kind: UnknownField(name~), loc })
              Error
            }
          }
        None => {
          diagnostics.push({ kind: NotAStruct(base_type), loc })
          Error
        }
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
