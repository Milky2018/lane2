///|
priv struct ValueTypeBinding {
  symbol : ValueSymbolId
  name : String
  type_ : @types.Type
}

///|
priv struct TypeScope {
  values : Array[ValueTypeBinding]
}

///|
priv struct SemanticChecker {
  source : @resolve.ResolvedSourceFile
  declarations : CheckedDeclarationEnvironment
  diagnostics : Array[CheckDiagnostic]
  values : Array[CheckedValueDeclaration]
  value_types : Array[ValueTypeBinding]
}

///|
pub fn check_source_file(
  source : @resolve.ResolvedSourceFile,
) -> CheckedSourceFile {
  let declaration_result = check_declarations(source)
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
      @resolve.ResolvedTopLevelDeclaration::Function(declaration) =>
        checker.check_top_level_function(declaration)
      @resolve.ResolvedTopLevelDeclaration::Let(declaration) =>
        checker.check_top_level_let(declaration)
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
    match declaration {
      @resolve.ResolvedTopLevelDeclaration::Function(declaration) => {
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
          CheckedValueDeclaration::Function({
            symbol: declaration.symbol,
            name: declaration.name,
            type_,
            loc: declaration.loc,
          }),
        )
      }
      _ => ()
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
  let type_ = match declaration.type_annotation {
    Some(type_annotation) => {
      let type_ = self.check_type(type_annotation)
      self.check_expr(self.root_scope(), declaration.initializer, type_)
      type_
    }
    None => {
      self.diagnostics.push({
        kind: CheckDiagnosticKind::MissingTopLevelLetAnnotation,
        loc: declaration.loc,
      })
      self.infer_expr(self.root_scope(), declaration.initializer)
    }
  }
  self.value_types.push({
    symbol: declaration.symbol,
    name: declaration.name.unwrap_or("<anonymous>"),
    type_,
  })
  self.values.push(
    CheckedValueDeclaration::Let({
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
    @types.Type::Forall(type_parameters.map(checked_type_parameter), type_)
  }
}

///|
fn SemanticChecker::check_type(
  self : SemanticChecker,
  type_ : @resolve.ResolvedType,
) -> @types.Type {
  check_resolved_type(self.source, self.diagnostics, type_)
}

///|
fn SemanticChecker::root_scope(self : SemanticChecker) -> TypeScope {
  { values: self.value_types.copy() }
}

///|
fn TypeScope::bind(
  self : TypeScope,
  symbol : ValueSymbolId,
  name : String,
  type_ : @types.Type,
) -> Unit {
  self.values.push({ symbol, name, type_ })
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
fn TypeScope::lookup_name(self : TypeScope, name : String) -> @types.Type? {
  for index = self.values.length() - 1; index >= 0; index = index - 1 {
    let binding = self.values[index]
    if binding.name == name {
      return Some(binding.type_)
    }
  }
  None
}

///|
fn SemanticChecker::check_expr(
  self : SemanticChecker,
  scope : TypeScope,
  expr : @resolve.ResolvedExpr,
  expected : @types.Type,
) -> Unit {
  match expr {
    @resolve.ResolvedExpr::Builtin(_, ..) => ()
    @resolve.ResolvedExpr::FunctionLiteral(
      type_parameters~,
      parameters~,
      return_type~,
      body~,
      loc~
    ) =>
      self.check_function_literal(
        scope, type_parameters, parameters, return_type, body, expected, loc,
      )
    _ => {
      let actual = self.infer_expr(scope, expr)
      self.expect_type(expected, actual, resolved_expr_loc(expr))
    }
  }
}

///|
fn SemanticChecker::infer_expr(
  self : SemanticChecker,
  scope : TypeScope,
  expr : @resolve.ResolvedExpr,
) -> @types.Type {
  match expr {
    @resolve.ResolvedExpr::IntLiteral(_, ..) =>
      @types.Type::Primitive(@types.PrimitiveType::Int)
    @resolve.ResolvedExpr::StringLiteral(_, ..) =>
      @types.Type::Primitive(@types.PrimitiveType::String)
    @resolve.ResolvedExpr::BoolLiteral(_, ..) =>
      @types.Type::Primitive(@types.PrimitiveType::Bool)
    @resolve.ResolvedExpr::UnitLiteral(..) =>
      @types.Type::Primitive(@types.PrimitiveType::Unit)
    @resolve.ResolvedExpr::Var(name~, reference~, loc~) =>
      self.infer_value_reference(scope, reference, name, loc)
    @resolve.ResolvedExpr::FunctionLiteral(
      type_parameters~,
      parameters~,
      return_type~,
      body~,
      loc~
    ) =>
      self.infer_function_literal(
        scope, type_parameters, parameters, return_type, body, loc,
      )
    @resolve.ResolvedExpr::Block(items~, result~, ..) =>
      self.infer_block(scope, items, result)
    @resolve.ResolvedExpr::If(condition~, then_branch~, else_branch~, loc~) =>
      self.infer_if(scope, condition, then_branch, else_branch, loc)
    @resolve.ResolvedExpr::Call(callee~, arguments~, loc~) =>
      self.infer_call(scope, callee, arguments, loc)
    @resolve.ResolvedExpr::Field(base~, name~, loc~) =>
      self.infer_field(scope, base, name, loc)
    @resolve.ResolvedExpr::StructLiteral(
      type_name~,
      type_arguments~,
      fields~,
      loc~
    ) =>
      self.infer_struct_literal(scope, type_name, type_arguments, fields, loc)
    @resolve.ResolvedExpr::Builtin(_, loc~) => {
      self.diagnostics.push({
        kind: CheckDiagnosticKind::CannotInferExpression("builtin"),
        loc,
      })
      @types.Type::Error
    }
    _ => {
      self.diagnostics.push({
        kind: CheckDiagnosticKind::CannotInferExpression("expression"),
        loc: resolved_expr_loc(expr),
      })
      @types.Type::Error
    }
  }
}

///|
fn resolved_expr_loc(expr : @resolve.ResolvedExpr) -> SourceSpan {
  match expr {
    @resolve.ResolvedExpr::IntLiteral(_, loc~)
    | @resolve.ResolvedExpr::StringLiteral(_, loc~)
    | @resolve.ResolvedExpr::BoolLiteral(_, loc~)
    | @resolve.ResolvedExpr::UnitLiteral(loc~)
    | @resolve.ResolvedExpr::Var(loc~, ..)
    | @resolve.ResolvedExpr::QualifiedVariant(loc~, ..)
    | @resolve.ResolvedExpr::UnqualifiedVariant(loc~, ..)
    | @resolve.ResolvedExpr::StructLiteral(loc~, ..)
    | @resolve.ResolvedExpr::Builtin(_, loc~)
    | @resolve.ResolvedExpr::FunctionLiteral(loc~, ..)
    | @resolve.ResolvedExpr::Block(loc~, ..)
    | @resolve.ResolvedExpr::If(loc~, ..)
    | @resolve.ResolvedExpr::Match(loc~, ..)
    | @resolve.ResolvedExpr::Call(loc~, ..)
    | @resolve.ResolvedExpr::Field(loc~, ..)
    | @resolve.ResolvedExpr::Unary(loc~, ..)
    | @resolve.ResolvedExpr::Binary(loc~, ..)
    | @resolve.ResolvedExpr::Pipeline(loc~, ..) => loc
  }
}

///|
fn SemanticChecker::infer_struct_literal(
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
      let struct_declaration = match self.checked_struct(symbol) {
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
            let expected = self.field_type(
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
fn SemanticChecker::infer_value_reference(
  self : SemanticChecker,
  scope : TypeScope,
  reference : @resolve.ResolvedValueReference,
  name : String,
  loc : SourceSpan,
) -> @types.Type {
  match reference {
    @resolve.ResolvedValueReference::Symbol(symbol) =>
      match scope.lookup(symbol) {
        Some(type_) => type_
        None => {
          self.diagnostics.push({
            kind: CheckDiagnosticKind::UnresolvedValue(name),
            loc,
          })
          @types.Type::Error
        }
      }
    @resolve.ResolvedValueReference::OpenedField(base~, field~) =>
      match scope.lookup(base) {
        Some(base_type) => self.field_type(base_type, field, name, loc)
        None => {
          self.diagnostics.push({
            kind: CheckDiagnosticKind::UnresolvedValue(name),
            loc,
          })
          @types.Type::Error
        }
      }
    @resolve.ResolvedValueReference::Unresolved(name) => {
      self.diagnostics.push({
        kind: CheckDiagnosticKind::UnresolvedValue(name),
        loc,
      })
      @types.Type::Error
    }
  }
}

///|
fn SemanticChecker::infer_block(
  self : SemanticChecker,
  scope : TypeScope,
  items : Array[@resolve.ResolvedLocalItem],
  result : @resolve.ResolvedExpr,
) -> @types.Type {
  let next_scope : TypeScope = { values: scope.values.copy() }
  for item in items {
    match item {
      @resolve.ResolvedLocalItem::Let(declaration) =>
        self.check_local_let(next_scope, declaration)
      @resolve.ResolvedLocalItem::Function(declaration) =>
        self.check_local_function(next_scope, declaration)
      @resolve.ResolvedLocalItem::Open(_) => ()
    }
  }
  self.infer_expr(next_scope, result)
}

///|
fn SemanticChecker::check_local_let(
  self : SemanticChecker,
  scope : TypeScope,
  declaration : @resolve.ResolvedLetDeclaration,
) -> Unit {
  let type_ = match declaration.type_annotation {
    Some(type_annotation) => {
      let type_ = self.check_type(type_annotation)
      self.check_expr(scope, declaration.initializer, type_)
      type_
    }
    None => self.infer_expr(scope, declaration.initializer)
  }
  scope.bind(
    declaration.symbol,
    declaration.name.unwrap_or("<anonymous>"),
    type_,
  )
}

///|
fn SemanticChecker::check_local_function(
  self : SemanticChecker,
  scope : TypeScope,
  declaration : @resolve.ResolvedFunctionDeclaration,
) -> Unit {
  let type_ = self.function_type(
    declaration.type_parameters,
    declaration.parameters,
    declaration.return_type,
  )
  scope.bind(declaration.symbol, declaration.name, type_)
  let body_scope : TypeScope = { values: scope.values.copy() }
  for parameter in declaration.parameters {
    body_scope.bind(
      parameter.symbol,
      parameter.name,
      self.check_type(parameter.type_),
    )
  }
  self.check_expr(
    body_scope,
    declaration.body,
    self.check_type(declaration.return_type),
  )
}

///|
fn SemanticChecker::infer_if(
  self : SemanticChecker,
  scope : TypeScope,
  condition : @resolve.ResolvedExpr,
  then_branch : @resolve.ResolvedExpr,
  else_branch : @resolve.ResolvedExpr,
  loc : SourceSpan,
) -> @types.Type {
  self.check_expr(
    scope,
    condition,
    @types.Type::Primitive(@types.PrimitiveType::Bool),
  )
  let then_type = self.infer_expr(scope, then_branch)
  let else_type = self.infer_expr(scope, else_branch)
  self.expect_type(then_type, else_type, loc)
  then_type
}

///|
fn SemanticChecker::infer_call(
  self : SemanticChecker,
  scope : TypeScope,
  callee : @resolve.ResolvedExpr,
  arguments : Array[@resolve.ResolvedExpr],
  loc : SourceSpan,
) -> @types.Type {
  match self.infer_expr(scope, callee) {
    @types.Type::Function(parameters, result) => {
      self.check_call_arguments(scope, parameters, arguments, loc)
      result
    }
    @types.Type::Forall(_, _) as type_ => {
      self.diagnostics.push({
        kind: CheckDiagnosticKind::CannotInferExpression("generic call"),
        loc,
      })
      type_
    }
    @types.Type::Error => @types.Type::Error
    type_ => {
      self.diagnostics.push({
        kind: CheckDiagnosticKind::NotCallable(type_),
        loc,
      })
      @types.Type::Error
    }
  }
}

///|
fn SemanticChecker::check_call_arguments(
  self : SemanticChecker,
  scope : TypeScope,
  parameters : Array[@types.Type],
  arguments : Array[@resolve.ResolvedExpr],
  loc : SourceSpan,
) -> Unit {
  if parameters.length() != arguments.length() {
    self.diagnostics.push({
      kind: CheckDiagnosticKind::CannotInferExpression("call arity"),
      loc,
    })
    return
  }
  for index in 0..<parameters.length() {
    self.check_expr(scope, arguments[index], parameters[index])
  }
}

///|
fn SemanticChecker::infer_field(
  self : SemanticChecker,
  scope : TypeScope,
  base : @resolve.ResolvedExpr,
  name : String,
  loc : SourceSpan,
) -> @types.Type {
  let base_type = self.infer_expr(scope, base)
  match base_type {
    @types.Type::Nominal(symbol, _) =>
      match self.source.symbols.field_named(symbol, name) {
        Some(field) => self.field_type(base_type, field, name, loc)
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

///|
fn SemanticChecker::field_type(
  self : SemanticChecker,
  base_type : @types.Type,
  field : FieldSymbolId,
  name : String,
  loc : SourceSpan,
) -> @types.Type {
  match base_type {
    @types.Type::Nominal(owner, arguments) =>
      match self.checked_struct(owner) {
        Some(declaration) =>
          match declaration.field(field) {
            Some(field_declaration) =>
              field_declaration.type_.substitute(
                declaration.nominal_substitution(arguments),
              )
            None => {
              self.diagnostics.push({
                kind: CheckDiagnosticKind::UnknownField(name~),
                loc,
              })
              @types.Type::Error
            }
          }
        None => {
          self.diagnostics.push({
            kind: CheckDiagnosticKind::NotAStruct(base_type),
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

///|
fn SemanticChecker::checked_struct(
  self : SemanticChecker,
  symbol : TypeSymbolId,
) -> CheckedStructDeclaration? {
  for declaration in self.declarations.types {
    match declaration {
      CheckedTypeDeclaration::Struct(declaration) =>
        if declaration.symbol == symbol {
          return Some(declaration)
        }
      _ => ()
    }
  }
  None
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

///|
fn SemanticChecker::infer_function_literal(
  self : SemanticChecker,
  scope : TypeScope,
  type_parameters : Array[@resolve.ResolvedTypeParameter],
  parameters : Array[@resolve.ResolvedFunctionLiteralParameter],
  return_type : @resolve.ResolvedType?,
  body : @resolve.ResolvedExpr,
  loc : SourceSpan,
) -> @types.Type {
  ignore(loc)
  let parameter_types = []
  let body_scope : TypeScope = { values: scope.values.copy() }
  for parameter in parameters {
    match parameter.type_annotation {
      Some(type_annotation) => {
        let type_ = self.check_type(type_annotation)
        body_scope.bind(parameter.symbol, parameter.name, type_)
        parameter_types.push(type_)
      }
      None => {
        self.diagnostics.push({
          kind: CheckDiagnosticKind::CannotInferExpression(
            "function literal parameter",
          ),
          loc: parameter.loc,
        })
        body_scope.bind(parameter.symbol, parameter.name, @types.Type::Error)
        parameter_types.push(@types.Type::Error)
      }
    }
  }
  let result = match return_type {
    Some(type_annotation) => {
      let type_ = self.check_type(type_annotation)
      self.check_expr(body_scope, body, type_)
      type_
    }
    None => self.infer_expr(body_scope, body)
  }
  let type_ = @types.Type::Function(parameter_types, result)
  if type_parameters.is_empty() {
    type_
  } else {
    @types.Type::Forall(type_parameters.map(checked_type_parameter), type_)
  }
}

///|
fn SemanticChecker::check_function_literal(
  self : SemanticChecker,
  scope : TypeScope,
  type_parameters : Array[@resolve.ResolvedTypeParameter],
  parameters : Array[@resolve.ResolvedFunctionLiteralParameter],
  return_type : @resolve.ResolvedType?,
  body : @resolve.ResolvedExpr,
  expected : @types.Type,
  loc : SourceSpan,
) -> Unit {
  ignore(type_parameters)
  match expected {
    @types.Type::Function(expected_parameters, expected_result) => {
      if expected_parameters.length() != parameters.length() {
        self.diagnostics.push({
          kind: CheckDiagnosticKind::CannotInferExpression("function arity"),
          loc,
        })
        return
      }
      let body_scope : TypeScope = { values: scope.values.copy() }
      for index in 0..<parameters.length() {
        let parameter = parameters[index]
        match parameter.type_annotation {
          Some(type_annotation) =>
            self.expect_type(
              expected_parameters[index],
              self.check_type(type_annotation),
              parameter.loc,
            )
          None => ()
        }
        body_scope.bind(
          parameter.symbol,
          parameter.name,
          expected_parameters[index],
        )
      }
      match return_type {
        Some(type_annotation) =>
          self.expect_type(
            expected_result,
            self.check_type(type_annotation),
            loc,
          )
        None => ()
      }
      self.check_expr(body_scope, body, expected_result)
    }
    @types.Type::Error => ()
    _ => {
      let actual = self.infer_function_literal(
        scope, type_parameters, parameters, return_type, body, loc,
      )
      self.expect_type(expected, actual, loc)
    }
  }
}

///|
fn SemanticChecker::expect_type(
  self : SemanticChecker,
  expected : @types.Type,
  actual : @types.Type,
  loc : SourceSpan,
) -> Unit {
  match (expected, actual) {
    (@types.Type::Error, _) | (_, @types.Type::Error) => ()
    _ =>
      if expected != actual {
        self.diagnostics.push({
          kind: CheckDiagnosticKind::TypeMismatch(expected~, actual~),
          loc,
        })
      }
  }
}
