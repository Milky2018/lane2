///|
priv struct DeclarationChecker {
  source : @resolve.ResolvedSourceFile
  diagnostics : Array[CheckDiagnostic]
}

///|
pub fn check_declarations(source : @resolve.ResolvedSourceFile) -> CheckResult {
  let checker = DeclarationChecker::{ source, diagnostics: [] }
  let types = []
  let fields = []
  let variants = []
  for declaration in source.declarations {
    match declaration {
      @resolve.ResolvedTopLevelDeclaration::Struct(declaration) => {
        let checked = checker.check_struct(declaration)
        for field in checked.fields {
          fields.push(field)
        }
        types.push(CheckedTypeDeclaration::Struct(checked))
      }
      @resolve.ResolvedTopLevelDeclaration::Enum(declaration) => {
        let checked = checker.check_enum(declaration)
        for variant in checked.variants {
          variants.push(variant)
        }
        types.push(CheckedTypeDeclaration::Enum(checked))
      }
      _ => ()
    }
  }
  {
    declarations: { types, fields, variants },
    diagnostics: checker.diagnostics,
  }
}

///|
fn DeclarationChecker::check_struct(
  self : DeclarationChecker,
  declaration : @resolve.ResolvedStructDeclaration,
) -> CheckedStructDeclaration {
  let fields = []
  for item in declaration.members {
    match item {
      @resolve.ResolvedStructMember::Field(field) =>
        fields.push(self.check_field(field))
      @resolve.ResolvedStructMember::Open(_) => ()
    }
  }
  {
    symbol: declaration.symbol,
    name: declaration.name,
    type_parameters: declaration.type_parameters.map(checked_type_parameter),
    fields,
    loc: declaration.loc,
  }
}

///|
fn DeclarationChecker::check_field(
  self : DeclarationChecker,
  field : @resolve.ResolvedFieldDeclaration,
) -> CheckedFieldDeclaration {
  {
    symbol: field.symbol,
    name: field.name,
    index: field.index,
    type_: self.check_type(field.type_),
    loc: field.loc,
  }
}

///|
fn DeclarationChecker::check_enum(
  self : DeclarationChecker,
  declaration : @resolve.ResolvedEnumDeclaration,
) -> CheckedEnumDeclaration {
  let variants = []
  for variant in declaration.variants {
    variants.push(self.check_variant(variant))
  }
  {
    symbol: declaration.symbol,
    name: declaration.name,
    type_parameters: declaration.type_parameters.map(checked_type_parameter),
    variants,
    loc: declaration.loc,
  }
}

///|
fn DeclarationChecker::check_variant(
  self : DeclarationChecker,
  variant : @resolve.ResolvedEnumVariant,
) -> CheckedVariantDeclaration {
  {
    symbol: variant.symbol,
    name: variant.name,
    index: variant.index,
    payload: variant.payload.map(fn(type_) { self.check_type(type_) }),
    loc: variant.loc,
  }
}

///|
fn DeclarationChecker::check_type(
  self : DeclarationChecker,
  type_ : @resolve.ResolvedType,
) -> @types.Type {
  check_resolved_type(self.source, self.diagnostics, type_)
}

///|
fn check_resolved_type(
  source : @resolve.ResolvedSourceFile,
  diagnostics : Array[CheckDiagnostic],
  type_ : @resolve.ResolvedType,
) -> @types.Type {
  match type_ {
    @resolve.ResolvedType::Primitive(primitive, ..) =>
      @types.Type::Primitive(primitive)
    @resolve.ResolvedType::Nominal(symbol~, name~, arguments~, loc~) => {
      let checked_arguments = arguments.map(fn(argument) {
        check_resolved_type(source, diagnostics, argument)
      })
      check_type_arity(
        source,
        diagnostics,
        symbol,
        name,
        checked_arguments.length(),
        loc,
      )
      @types.Type::Nominal(symbol, checked_arguments)
    }
    @resolve.ResolvedType::Parameter(symbol~, ..) =>
      @types.Type::Parameter(symbol)
    @resolve.ResolvedType::Function(type_parameters~, parameters~, result~, ..) => {
      let checked_parameters = parameters.map(fn(parameter) {
        check_resolved_type(source, diagnostics, parameter)
      })
      let checked_result = check_resolved_type(source, diagnostics, result)
      let function_type = @types.Type::Function(
        checked_parameters, checked_result,
      )
      if type_parameters.is_empty() {
        function_type
      } else {
        @types.Type::Forall(
          type_parameters.map(checked_type_parameter),
          function_type,
        )
      }
    }
    @resolve.ResolvedType::Unresolved(name~, arguments~, loc~) => {
      for argument in arguments {
        ignore(check_resolved_type(source, diagnostics, argument))
      }
      diagnostics.push({ kind: CheckDiagnosticKind::UnresolvedType(name), loc })
      @types.Type::Error
    }
  }
}

///|
fn check_type_arity(
  source : @resolve.ResolvedSourceFile,
  diagnostics : Array[CheckDiagnostic],
  symbol : TypeSymbolId,
  name : String,
  actual : Int,
  loc : SourceSpan,
) -> Unit {
  match source.symbols.type_metadata(symbol) {
    Some(metadata) =>
      if metadata.arity != actual {
        diagnostics.push({
          kind: CheckDiagnosticKind::TypeArgumentArityMismatch(
            name~,
            expected=metadata.arity,
            actual~,
          ),
          loc,
        })
      }
    None => ()
  }
}

///|
fn checked_type_parameter(
  parameter : @resolve.ResolvedTypeParameter,
) -> @types.TypeParameter {
  { id: parameter.symbol, name: parameter.name, kind: @types.Kind::Type }
}
