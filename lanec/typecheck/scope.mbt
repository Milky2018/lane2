///|
priv struct ValueTypeBinding {
  symbol : ValueSymbolId
  type_ : @types.Type
  parameters : Array[@checked.CheckedValueParameter]?
}

///|
priv struct ContextualOffer {
  symbol : ValueSymbolId
  type_ : @types.Type
}

///|
priv struct TypeScope {
  values : Array[ValueTypeBinding]
  offers : Array[ContextualOffer]
}

///|
fn SemanticChecker::root_scope(self : SemanticChecker) -> TypeScope {
  { values: self.value_types.copy(), offers: self.offers.copy() }
}

///|
fn TypeScope::bind(
  self : TypeScope,
  symbol : ValueSymbolId,
  type_ : @types.Type,
) -> Unit {
  self.values.push({ symbol, type_, parameters: None })
}

///|
fn TypeScope::bind_function(
  self : TypeScope,
  symbol : ValueSymbolId,
  type_ : @types.Type,
  parameters : Array[@checked.CheckedValueParameter],
) -> Unit {
  self.values.push({ symbol, type_, parameters: Some(parameters) })
}

///|
fn TypeScope::lookup(self : TypeScope, symbol : ValueSymbolId) -> @types.Type? {
  for index = self.values.length() - 1; index >= 0; index = index - 1 {
    let binding = self.values[index]
    if binding.symbol == symbol {
      return Some(binding.type_)
    }
  }
  None
}

///|
fn TypeScope::lookup_function_parameters(
  self : TypeScope,
  symbol : ValueSymbolId,
) -> Array[@checked.CheckedValueParameter]? {
  for index = self.values.length() - 1; index >= 0; index = index - 1 {
    let binding = self.values[index]
    if binding.symbol == symbol {
      return binding.parameters
    }
  }
  None
}

///|
fn TypeScope::offer(
  self : TypeScope,
  symbol : ValueSymbolId,
  type_ : @types.Type,
) -> Unit {
  self.offers.push({ symbol, type_ })
}

///|
fn TypeScope::copy(self : TypeScope) -> TypeScope {
  { values: self.values.copy(), offers: self.offers.copy() }
}

///|
fn TypeScope::offer_reference(
  self : TypeScope,
  reference : @resolve.ResolvedValueReference,
  diagnostics : Array[TypeCheckDiagnostic],
  loc : SourceSpan,
) -> Unit {
  match reference {
    Symbol(symbol) =>
      match self.lookup(symbol) {
        Some(type_) => self.offer(symbol, type_)
        None =>
          diagnostics.push({
            kind: CannotInferExpression("offer value has no checked type"),
            loc,
          })
      }
    _ =>
      diagnostics.push({
        kind: CannotInferExpression("offer requires a resolved value"),
        loc,
      })
  }
}

///|
fn SemanticChecker::check_local_let(
  self : SemanticChecker,
  scope : TypeScope,
  declaration : @desugar.DesugaredLetDeclaration,
) -> Unit {
  let type_ = if declaration.type_annotation is Some(type_annotation) {
    let type_ = self.check_type(type_annotation)
    self.check_expr(scope, declaration.initializer, type_)
    type_
  } else {
    self.synthesize_expr(scope, declaration.initializer)
  }
  scope.bind(declaration.symbol, type_)
  if declaration.is_offered {
    scope.offer(declaration.symbol, type_)
  }
}

///|
fn SemanticChecker::check_local_function(
  self : SemanticChecker,
  scope : TypeScope,
  declaration : @desugar.DesugaredFunctionDeclaration,
) -> Unit {
  let type_ = self.function_type(
    declaration.type_parameters,
    declaration.parameters,
    declaration.return_type,
  )
  let parameters = declaration.parameters.map(fn(parameter) {
    self.checked_value_parameter(parameter)
  })
  scope.bind_function(declaration.symbol, type_, parameters)
  let body_scope = scope.copy()
  for parameter in parameters {
    body_scope.bind(parameter.symbol, parameter.type_)
    if parameter.is_offered {
      body_scope.offer(parameter.symbol, parameter.type_)
    }
  }
  self.check_expr(
    body_scope,
    declaration.body,
    self.check_type(declaration.return_type),
  )
}
