///|
priv struct ValueTypeBinding {
  symbol : ValueSymbolId
  type_ : @types.Type
}

///|
priv struct TypeScope {
  values : Array[ValueTypeBinding]
}

///|
fn SemanticChecker::root_scope(self : SemanticChecker) -> TypeScope {
  { values: self.value_types.copy() }
}

///|
fn TypeScope::bind(
  self : TypeScope,
  symbol : ValueSymbolId,
  type_ : @types.Type,
) -> Unit {
  self.values.push({ symbol, type_ })
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
  scope.bind(declaration.symbol, type_)
  let body_scope : TypeScope = { values: scope.values.copy() }
  for parameter in declaration.parameters {
    body_scope.bind(parameter.symbol, self.check_type(parameter.type_))
  }
  self.check_expr(
    body_scope,
    declaration.body,
    self.check_type(declaration.return_type),
  )
}
