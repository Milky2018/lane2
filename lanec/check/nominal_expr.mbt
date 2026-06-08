///|
fn SemanticChecker::synthesize_qualified_variant(
  self : SemanticChecker,
  scope : TypeScope,
  type_name : String,
  type_arguments : Array[@resolve.ResolvedType],
  variant : String,
  reference : @resolve.ResolvedVariantReference,
  arguments : Array[@resolve.ResolvedExpr],
  expected_result : @types.Type?,
  loc : SourceSpan,
) -> @types.Type {
  let checked_arguments = type_arguments.map(fn(type_) {
    self.check_type(type_)
  })
  match reference {
    @resolve.ResolvedVariantReference::Symbol(symbol) =>
      self.synthesize_variant_symbol(
        scope,
        symbol,
        type_name + "::" + variant,
        checked_arguments,
        arguments,
        expected_result,
        loc,
      )
    @resolve.ResolvedVariantReference::Unresolved(type_name~, variant~) => {
      self.diagnostics.push({
        kind: CheckDiagnosticKind::CannotInferExpression(
          "unresolved variant " + type_name + "::" + variant,
        ),
        loc,
      })
      @types.Type::Error
    }
    @resolve.ResolvedVariantReference::Ambiguous(name~, ..) => {
      self.report_ambiguous_variant_reference(name, loc)
      @types.Type::Error
    }
    @resolve.ResolvedVariantReference::UnresolvedUnqualified(name) => {
      self.diagnostics.push({
        kind: CheckDiagnosticKind::CannotInferExpression(
          "unresolved variant " + name,
        ),
        loc,
      })
      @types.Type::Error
    }
  }
}

///|
fn SemanticChecker::synthesize_unqualified_variant(
  self : SemanticChecker,
  scope : TypeScope,
  variant : String,
  reference : @resolve.ResolvedVariantReference,
  arguments : Array[@resolve.ResolvedExpr],
  expected_result : @types.Type?,
  loc : SourceSpan,
) -> @types.Type {
  match reference {
    @resolve.ResolvedVariantReference::Symbol(symbol) =>
      self.synthesize_variant_symbol(
        scope,
        symbol,
        variant,
        [],
        arguments,
        expected_result,
        loc,
      )
    @resolve.ResolvedVariantReference::Ambiguous(name~, ..) => {
      self.report_ambiguous_variant_reference(name, loc)
      @types.Type::Error
    }
    @resolve.ResolvedVariantReference::UnresolvedUnqualified(name) => {
      self.diagnostics.push({
        kind: CheckDiagnosticKind::CannotInferExpression(
          "unresolved variant " + name,
        ),
        loc,
      })
      @types.Type::Error
    }
    @resolve.ResolvedVariantReference::Unresolved(type_name~, variant~) => {
      self.diagnostics.push({
        kind: CheckDiagnosticKind::CannotInferExpression(
          "unresolved variant " + type_name + "::" + variant,
        ),
        loc,
      })
      @types.Type::Error
    }
  }
}

///|
fn SemanticChecker::synthesize_variant_symbol(
  self : SemanticChecker,
  scope : TypeScope,
  symbol : VariantSymbolId,
  display_name : String,
  explicit_type_arguments : Array[@types.Type],
  arguments : Array[@resolve.ResolvedExpr],
  expected_result : @types.Type?,
  loc : SourceSpan,
) -> @types.Type {
  guard self.source.symbols.variant_metadata(symbol) is Some(metadata) else {
    self.diagnostics.push({
      kind: CheckDiagnosticKind::CannotInferExpression(
        "unknown variant " + display_name,
      ),
      loc,
    })
    return @types.Type::Error
  }
  guard self.declarations.checked_enum(metadata.owner) is Some(declaration) else {
    self.diagnostics.push({
      kind: CheckDiagnosticKind::CannotInferExpression(
        "unknown variant owner " + display_name,
      ),
      loc,
    })
    return @types.Type::Error
  }
  guard declaration.variant(symbol) is Some(variant_declaration) else {
    self.diagnostics.push({
      kind: CheckDiagnosticKind::CannotInferExpression(
        "unknown variant " + display_name,
      ),
      loc,
    })
    return @types.Type::Error
  }
  if variant_declaration.payload.length() != arguments.length() {
    self.diagnostics.push({
      kind: CheckDiagnosticKind::CannotInferExpression("variant arity"),
      loc,
    })
    return @types.Type::Nominal(metadata.owner, explicit_type_arguments)
  }
  let type_arguments = if explicit_type_arguments.is_empty() &&
    !declaration.type_parameters.is_empty() {
    match
      self.infer_variant_type_arguments(
        scope, declaration, variant_declaration, arguments, expected_result, loc,
      ) {
      Some(type_arguments) => type_arguments
      None => return @types.Type::Error
    }
  } else {
    check_type_arity(
      self.source,
      self.diagnostics,
      metadata.owner,
      display_name,
      explicit_type_arguments.length(),
      loc,
    )
    explicit_type_arguments
  }
  let substitution = variant_type_substitution(
    declaration.type_parameters,
    type_arguments,
  )
  for index in 0..<variant_declaration.payload.length() {
    self.check_expr(
      scope,
      arguments[index],
      variant_declaration.payload[index].substitute(substitution),
    )
  }
  @types.Type::Nominal(metadata.owner, type_arguments)
}

///|
fn SemanticChecker::infer_variant_type_arguments(
  self : SemanticChecker,
  scope : TypeScope,
  declaration : CheckedEnumDeclaration,
  variant : CheckedVariantDeclaration,
  arguments : Array[@resolve.ResolvedExpr],
  expected_result : @types.Type?,
  loc : SourceSpan,
) -> Array[@types.Type]? {
  let inference = TypeArgumentInference::TypeArgumentInference(
    declaration.type_parameters,
  )
  if expected_result is Some(expected) {
    let result_template = @types.Type::Nominal(
      declaration.symbol,
      declaration.type_parameters.map(fn(parameter) {
        @types.Type::Parameter(parameter.id)
      }),
    )
    inference.collect(result_template, expected)
  }
  for index in 0..<variant.payload.length() {
    if self.synthesize_argument_for_type_arguments(scope, arguments[index])
      is Some(actual) {
      inference.collect(variant.payload[index], actual)
    }
  }
  guard inference.substitution() is Some(substitution) else {
    self.diagnostics.push({
      kind: CheckDiagnosticKind::CannotInferExpression("type arguments"),
      loc,
    })
    return None
  }
  Some(
    declaration.type_parameters.map(fn(parameter) {
      @types.Type::Parameter(parameter.id).substitute(substitution)
    }),
  )
}

///|
fn variant_type_substitution(
  parameters : Array[@types.TypeParameter],
  arguments : Array[@types.Type],
) -> @types.TypeSubstitution {
  let substitution = @types.TypeSubstitution::TypeSubstitution()
  let length = if parameters.length() < arguments.length() {
    parameters.length()
  } else {
    arguments.length()
  }
  for index in 0..<length {
    substitution.insert(parameters[index].id, arguments[index])
  }
  substitution
}

///|
fn SemanticChecker::synthesize_struct_literal(
  self : SemanticChecker,
  scope : TypeScope,
  type_name : String,
  type_arguments : Array[@resolve.ResolvedType],
  fields : Array[@resolve.ResolvedStructLiteralField],
  loc : SourceSpan,
) -> @types.Type {
  match self.source.symbols.type_named(type_name) {
    Some(symbol) => {
      let arguments = type_arguments.map(fn(type_) { self.check_type(type_) })
      check_type_arity(
        self.source,
        self.diagnostics,
        symbol,
        type_name,
        arguments.length(),
        loc,
      )
      let type_ = @types.Type::Nominal(symbol, arguments)
      let struct_declaration = match self.declarations.checked_struct(symbol) {
        Some(declaration) => declaration
        None => {
          self.diagnostics.push({
            kind: CheckDiagnosticKind::NotAStruct(type_),
            loc,
          })
          return @types.Type::Error
        }
      }
      let seen = []
      for field in fields {
        if seen.contains(field.name) {
          self.diagnostics.push({
            kind: CheckDiagnosticKind::DuplicateField(name=field.name),
            loc: field.loc,
          })
        } else {
          seen.push(field.name)
        }
        match self.source.symbols.field_named(symbol, field.name) {
          Some(field_symbol) => {
            let expected = self.declarations.field_type(
              self.diagnostics,
              type_,
              field_symbol,
              field.name,
              field.loc,
            )
            match field.value {
              Some(value) => self.check_expr(scope, value, expected)
              None =>
                match scope.lookup_name(field.name) {
                  Some(actual) => self.expect_type(expected, actual, field.loc)
                  None =>
                    self.diagnostics.push({
                      kind: CheckDiagnosticKind::UnresolvedValue(field.name),
                      loc: field.loc,
                    })
                }
            }
          }
          None =>
            self.diagnostics.push({
              kind: CheckDiagnosticKind::UnknownField(name=field.name),
              loc: field.loc,
            })
        }
      }
      for field in struct_declaration.fields {
        if !seen.contains(field.name) {
          self.diagnostics.push({
            kind: CheckDiagnosticKind::MissingField(name=field.name),
            loc,
          })
        }
      }
      type_
    }
    None => {
      self.diagnostics.push({
        kind: CheckDiagnosticKind::UnresolvedType(type_name),
        loc,
      })
      @types.Type::Error
    }
  }
}

///|
fn SemanticChecker::synthesize_field(
  self : SemanticChecker,
  scope : TypeScope,
  base : @resolve.ResolvedExpr,
  name : String,
  reference : @resolve.ResolvedFieldReference,
  loc : SourceSpan,
) -> @types.Type {
  let base_type = self.synthesize_expr(scope, base)
  match reference {
    @resolve.ResolvedFieldReference::Symbol(field) =>
      self.declarations.field_type(
        self.diagnostics,
        base_type,
        field,
        name,
        loc,
      )
    @resolve.ResolvedFieldReference::Unresolved(..) => {
      self.diagnostics.push({
        kind: CheckDiagnosticKind::UnknownField(name~),
        loc,
      })
      @types.Type::Error
    }
    @resolve.ResolvedFieldReference::Deferred(_) =>
      match base_type {
        @types.Type::Nominal(symbol, _) =>
          match self.source.symbols.field_named(symbol, name) {
            Some(field) =>
              self.declarations.field_type(
                self.diagnostics,
                base_type,
                field,
                name,
                loc,
              )
            None => {
              self.diagnostics.push({
                kind: CheckDiagnosticKind::UnknownField(name~),
                loc,
              })
              @types.Type::Error
            }
          }
        @types.Type::Error => @types.Type::Error
        _ => {
          self.diagnostics.push({
            kind: CheckDiagnosticKind::NotAStruct(base_type),
            loc,
          })
          @types.Type::Error
        }
      }
  }
}
