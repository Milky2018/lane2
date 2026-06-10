///|
priv struct SemanticChecker {
  source : @resolve.ResolvedSourceFile
  declarations : CheckedDeclarationEnvironment
  diagnostics : Array[TypeCheckDiagnostic]
  values : Array[CheckedValueDeclaration]
  value_types : Array[ValueTypeBinding]
}

///|
/// Checks a resolved source file and returns checked declarations, values, and diagnostics.
pub fn typecheck_source_file(
  source : @resolve.ResolvedSourceFile,
) -> TypeCheckResult {
  let declaration_result = typecheck_declarations(source)
  let checker = SemanticChecker::{
    source,
    declarations: declaration_result.declarations,
    diagnostics: declaration_result.diagnostics.copy(),
    values: [],
    value_types: [],
  }
  checker.collect_top_level_function_types()
  for declaration in source.declarations {
    match declaration {
      Function(declaration) => checker.check_top_level_function(declaration)
      Let(declaration) => checker.check_top_level_let(declaration)
      _ => ()
    }
  }
  {
    declarations: checker.declarations,
    values: { values: checker.values },
    diagnostics: checker.diagnostics,
  }
}

///|
fn SemanticChecker::collect_top_level_function_types(
  self : SemanticChecker,
) -> Unit {
  for declaration in self.source.declarations {
    if declaration is Function(declaration) {
      let type_ = self.function_type(
        declaration.type_parameters,
        declaration.parameters,
        declaration.return_type,
      )
      self.value_types.push({
        symbol: declaration.symbol,
        name: declaration.name,
        type_,
      })
      self.values.push(
        Function({
          symbol: declaration.symbol,
          name: declaration.name,
          type_,
          loc: declaration.loc,
        }),
      )
    }
  }
}

///|
fn SemanticChecker::check_top_level_function(
  self : SemanticChecker,
  declaration : @resolve.ResolvedFunctionDeclaration,
) -> Unit {
  let scope = self.root_scope()
  for parameter in declaration.parameters {
    scope.bind(
      parameter.symbol,
      parameter.name,
      self.check_type(parameter.type_),
    )
  }
  self.check_expr(
    scope,
    declaration.body,
    self.check_type(declaration.return_type),
  )
}

///|
fn SemanticChecker::check_top_level_let(
  self : SemanticChecker,
  declaration : @resolve.ResolvedLetDeclaration,
) -> Unit {
  let type_ = if declaration.type_annotation is Some(type_annotation) {
    let type_ = self.check_type(type_annotation)
    self.check_expr(self.root_scope(), declaration.initializer, type_)
    type_
  } else {
    self.diagnostics.push({
      kind: MissingTopLevelLetAnnotation,
      loc: declaration.loc,
    })
    self.synthesize_expr(self.root_scope(), declaration.initializer)
  }
  self.value_types.push({
    symbol: declaration.symbol,
    name: declaration.name.unwrap_or("<anonymous>"),
    type_,
  })
  self.values.push(
    Let({
      symbol: declaration.symbol,
      name: declaration.name,
      type_,
      loc: declaration.loc,
    }),
  )
}

///|
fn SemanticChecker::function_type(
  self : SemanticChecker,
  type_parameters : Array[@resolve.ResolvedTypeParameter],
  parameters : Array[@resolve.ResolvedValueParameter],
  return_type : @resolve.ResolvedType,
) -> @types.Type {
  let parameters = parameters.map(fn(parameter) {
    self.check_type(parameter.type_)
  })
  let result = self.check_type(return_type)
  let type_ = @types.Type::Function(parameters, result)
  if type_parameters.is_empty() {
    type_
  } else {
    Forall(type_parameters.map(checked_type_parameter), type_)
  }
}

///|
fn SemanticChecker::check_type(
  self : SemanticChecker,
  type_ : @resolve.ResolvedType,
) -> @types.Type {
  check_resolved_type(self.source, self.diagnostics, type_)
}
