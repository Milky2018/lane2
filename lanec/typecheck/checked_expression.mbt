///|
priv struct CheckedExpressionSynthesis {
  expression : @checked.CheckedExpr?
  type_ : @types.Type
  missing_reported : Bool
}

///|
fn SemanticChecker::check_checked_expr(
  self : SemanticChecker,
  scope : TypeScope,
  expression : @resolve.ResolvedExpr,
  expected : @types.Type,
) -> CheckedExpressionSynthesis {
  // Checked expression construction follows the checking judgment:
  //
  //   Gamma |- e <= Expected ~~> checked_e
  //
  // Only syntax that can use direct expected context is constructed here. The
  // remaining source forms continue to use the existing type-only checker until
  // their checked-node rules are moved over one by one.
  match expression {
    Builtin(name, loc~) =>
      checked_expression(UnsafeBuiltin(name~, type_=expected, loc~), expected)
    IntLiteral(_, ..)
    | StringLiteral(_, ..)
    | BoolLiteral(_, ..)
    | UnitLiteral(..) => {
      let checked = self.synthesize_checked_expr(scope, expression)
      self.expect_type(expected, checked.type_, resolved_expr_loc(expression))
      checked
    }
    Block(items~, result~, loc~) =>
      self.check_checked_block(scope, items, result, expected, loc)
    Pipeline(left~, right~, loc~) =>
      self.check_checked_pipeline(scope, left, right, expected, loc)
    Call(callee~, arguments~, loc~) =>
      self.check_checked_call(scope, callee, arguments, expected, loc)
    FunctionLiteral(type_parameters~, parameters~, return_type~, body~, loc~) =>
      self.check_checked_function_literal(
        scope, type_parameters, parameters, return_type, body, expected, loc,
      )
    Var(name~, reference~, loc~) =>
      match reference {
        Candidates(candidates~, ..) =>
          self.check_checked_candidate_reference(
            scope, name, candidates, expected, loc,
          )
        _ => {
          let checked = self.synthesize_checked_expr(scope, expression)
          self.expect_type(
            expected,
            checked.type_,
            resolved_expr_loc(expression),
          )
          checked
        }
      }
    _ => {
      self.check_expr(scope, expression, expected)
      checked_expression_none(expected)
    }
  }
}

///|
fn SemanticChecker::synthesize_checked_expr(
  self : SemanticChecker,
  scope : TypeScope,
  expression : @resolve.ResolvedExpr,
) -> CheckedExpressionSynthesis {
  // Checked expression construction follows the synthesis judgment:
  //
  //   Gamma |- e => T ~~> checked_e
  //
  // This initial slice covers source forms whose checked node does not need a
  // recursive checked subtree. Compound expressions still return their
  // synthesized type through the existing checker and no checked node.
  match expression {
    IntLiteral(raw, loc~) =>
      checked_expression(
        Literal(
          literal=Int(self.check_int_literal(raw, loc)),
          type_=Primitive(Int),
          loc~,
        ),
        Primitive(Int),
      )
    StringLiteral(value, loc~) =>
      checked_expression(
        Literal(literal=String(value), type_=Primitive(String), loc~),
        Primitive(String),
      )
    BoolLiteral(value, loc~) =>
      checked_expression(
        Literal(literal=Bool(value), type_=Primitive(Bool), loc~),
        Primitive(Bool),
      )
    UnitLiteral(loc~) =>
      checked_expression(
        Literal(literal=Unit, type_=Primitive(Unit), loc~),
        Primitive(Unit),
      )
    FunctionLiteral(type_parameters~, parameters~, return_type~, body~, loc~) =>
      self.synthesize_checked_function_literal(
        scope, type_parameters, parameters, return_type, body, loc,
      )
    Var(name~, reference~, loc~) =>
      self.synthesize_checked_value_reference(scope, reference, name, loc)
    Call(callee~, arguments~, loc~) =>
      self.synthesize_checked_call(scope, callee, arguments, loc)
    Pipeline(left~, right~, loc~) =>
      self.synthesize_checked_pipeline(scope, left, right, loc)
    Builtin(_, loc~) => {
      self.diagnostics.push({ kind: CannotInferExpression("builtin"), loc })
      checked_expression_none_reported(Error)
    }
    _ => checked_expression_none(self.synthesize_expr(scope, expression))
  }
}

///|
fn SemanticChecker::check_checked_block(
  self : SemanticChecker,
  scope : TypeScope,
  items : Array[@resolve.ResolvedLocalItem],
  result : @resolve.ResolvedExpr,
  expected : @types.Type,
  loc : SourceSpan,
) -> CheckedExpressionSynthesis {
  let next_scope : TypeScope = { values: scope.values.copy() }
  let checked_items : Array[@checked.CheckedLocalItem] = []
  let mut complete = true
  for item in items {
    match item {
      Let(declaration) =>
        match self.check_checked_local_let(next_scope, declaration) {
          Some(declaration) => checked_items.push(Let(declaration))
          None => complete = false
        }
      Function(declaration) =>
        match self.check_checked_local_function(next_scope, declaration) {
          Some(declaration) => checked_items.push(Function(declaration))
          None => complete = false
        }
      Open(_) => ()
    }
  }
  let checked_result = self.check_checked_expr(next_scope, result, expected)
  guard self.require_checked_expression(
      checked_result,
      resolved_expr_loc(result),
      "block result",
    )
    is Some(result) else {
    return checked_expression_none_reported(expected)
  }
  if complete {
    checked_expression(
      Block(items=checked_items, result~, type_=expected, loc~),
      expected,
    )
  } else {
    checked_expression_none_reported(expected)
  }
}

///|
fn SemanticChecker::synthesize_checked_pipeline(
  self : SemanticChecker,
  scope : TypeScope,
  left : @resolve.ResolvedExpr,
  right : @resolve.ResolvedExpr,
  loc : SourceSpan,
) -> CheckedExpressionSynthesis {
  match right {
    Call(callee~, arguments~, ..) =>
      self.synthesize_checked_call(
        scope,
        callee,
        pipeline_arguments(left, arguments),
        loc,
      )
    _ => self.synthesize_checked_call(scope, right, [left], loc)
  }
}

///|
fn SemanticChecker::check_checked_pipeline(
  self : SemanticChecker,
  scope : TypeScope,
  left : @resolve.ResolvedExpr,
  right : @resolve.ResolvedExpr,
  expected : @types.Type,
  loc : SourceSpan,
) -> CheckedExpressionSynthesis {
  match right {
    Call(callee~, arguments~, ..) =>
      self.check_checked_call(
        scope,
        callee,
        pipeline_arguments(left, arguments),
        expected,
        loc,
      )
    _ => self.check_checked_call(scope, right, [left], expected, loc)
  }
}

///|
fn SemanticChecker::synthesize_checked_call(
  self : SemanticChecker,
  scope : TypeScope,
  callee : @resolve.ResolvedExpr,
  arguments : Array[@resolve.ResolvedExpr],
  loc : SourceSpan,
) -> CheckedExpressionSynthesis {
  let checked_callee = self.synthesize_checked_expr(scope, callee)
  guard self.require_checked_expression(
      checked_callee,
      resolved_expr_loc(callee),
      "call callee",
    )
    is Some(callee) else {
    return checked_expression_none_reported(Error)
  }
  match checked_callee.type_ {
    Function(parameters, result) => {
      guard self.check_checked_call_arguments(scope, parameters, arguments, loc)
        is Some(arguments) else {
        return checked_expression_none_reported(result)
      }
      checked_expression(Call(callee~, arguments~, type_=result, loc~), result)
    }
    Error => checked_expression_none_reported(Error)
    type_ => {
      self.diagnostics.push({ kind: NotCallable(type_), loc })
      checked_expression_none_reported(Error)
    }
  }
}

///|
fn SemanticChecker::check_checked_call(
  self : SemanticChecker,
  scope : TypeScope,
  callee : @resolve.ResolvedExpr,
  arguments : Array[@resolve.ResolvedExpr],
  expected : @types.Type,
  loc : SourceSpan,
) -> CheckedExpressionSynthesis {
  let checked = self.synthesize_checked_call(scope, callee, arguments, loc)
  self.expect_type(expected, checked.type_, loc)
  checked
}

///|
fn SemanticChecker::check_checked_call_arguments(
  self : SemanticChecker,
  scope : TypeScope,
  parameters : Array[@types.Type],
  arguments : Array[@resolve.ResolvedExpr],
  loc : SourceSpan,
) -> Array[@checked.CheckedExpr]? {
  if parameters.length() != arguments.length() {
    self.diagnostics.push({ kind: CannotInferExpression("call arity"), loc })
    return None
  }
  let checked_arguments = []
  let mut complete = true
  for index in 0..<parameters.length() {
    let checked = self.check_checked_expr(
      scope,
      arguments[index],
      parameters[index],
    )
    match
      self.require_checked_expression(
        checked,
        resolved_expr_loc(arguments[index]),
        "call argument",
      ) {
      Some(argument) => checked_arguments.push(argument)
      None => complete = false
    }
  }
  if complete {
    Some(checked_arguments)
  } else {
    None
  }
}

///|
fn SemanticChecker::synthesize_checked_function_literal(
  self : SemanticChecker,
  scope : TypeScope,
  type_parameters : Array[@resolve.ResolvedTypeParameter],
  parameters : Array[@resolve.ResolvedFunctionLiteralParameter],
  return_type : @resolve.ResolvedType?,
  body : @resolve.ResolvedExpr,
  loc : SourceSpan,
) -> CheckedExpressionSynthesis {
  let parameter_types = []
  let checked_parameters : Array[@checked.CheckedValueParameter] = []
  let body_scope : TypeScope = { values: scope.values.copy() }
  for parameter in parameters {
    if parameter.type_annotation is Some(type_annotation) {
      let type_ = self.check_type(type_annotation)
      body_scope.bind(parameter.symbol, parameter.name, type_)
      parameter_types.push(type_)
      checked_parameters.push({
        symbol: parameter.symbol,
        name: parameter.name,
        type_,
        loc: parameter.loc,
      })
    } else {
      let type_ : @types.Type = Error
      self.diagnostics.push({
        kind: CannotInferExpression("function literal parameter"),
        loc: parameter.loc,
      })
      body_scope.bind(parameter.symbol, parameter.name, type_)
      parameter_types.push(type_)
      checked_parameters.push({
        symbol: parameter.symbol,
        name: parameter.name,
        type_,
        loc: parameter.loc,
      })
    }
  }
  let result_type = if return_type is Some(type_annotation) {
    self.check_type(type_annotation)
  } else {
    self.synthesize_expr(body_scope, body)
  }
  let checked_body = self.check_checked_expr(body_scope, body, result_type)
  guard self.require_checked_expression(
      checked_body,
      resolved_expr_loc(body),
      "function body",
    )
    is Some(body) else {
    return checked_expression_none_reported(
      Function(parameter_types, result_type),
    )
  }
  let function_type = @types.Type::Function(parameter_types, result_type)
  let type_ = if type_parameters.is_empty() {
    function_type
  } else {
    Forall(type_parameters.map(checked_type_parameter), function_type)
  }
  checked_expression(
    FunctionLiteral(
      type_parameters=type_parameters.map(checked_type_parameter),
      parameters=checked_parameters,
      return_type=result_type,
      body~,
      type_~,
      loc~,
    ),
    type_,
  )
}

///|
fn SemanticChecker::check_checked_function_literal(
  self : SemanticChecker,
  scope : TypeScope,
  type_parameters : Array[@resolve.ResolvedTypeParameter],
  parameters : Array[@resolve.ResolvedFunctionLiteralParameter],
  return_type : @resolve.ResolvedType?,
  body : @resolve.ResolvedExpr,
  expected : @types.Type,
  loc : SourceSpan,
) -> CheckedExpressionSynthesis {
  let checked = self.synthesize_checked_function_literal(
    scope, type_parameters, parameters, return_type, body, loc,
  )
  self.expect_type(expected, checked.type_, loc)
  checked
}

///|
fn SemanticChecker::check_checked_candidate_reference(
  self : SemanticChecker,
  scope : TypeScope,
  name : String,
  candidates : Array[@resolve.ResolvedValueReference],
  expected : @types.Type,
  loc : SourceSpan,
) -> CheckedExpressionSynthesis {
  let typed_candidates = self.typed_candidates(scope, candidates, name, loc)
  match @candidates.select_by_expected(name, typed_candidates, expected) {
    Selected(candidate) =>
      self.synthesize_checked_value_reference(
        scope,
        candidate.reference,
        name,
        loc,
      )
    Ambiguous(name~, ..) => {
      self.report_ambiguous_value_reference(name, loc)
      checked_expression_none(Error)
    }
    NoMatch(name~) => {
      self.diagnostics.push({
        kind: CannotInferExpression("no matching value reference " + name),
        loc,
      })
      checked_expression_none(Error)
    }
  }
}

///|
fn SemanticChecker::synthesize_checked_value_reference(
  self : SemanticChecker,
  scope : TypeScope,
  reference : @resolve.ResolvedValueReference,
  name : String,
  loc : SourceSpan,
) -> CheckedExpressionSynthesis {
  match reference {
    Symbol(symbol) =>
      self.synthesize_checked_symbol_value(scope, symbol, name, loc)
    OpenedField(base~, path~) =>
      self.synthesize_checked_opened_field(scope, base, path, name, loc)
    Candidates(name~, candidates~) => {
      let typed_candidates = self.typed_candidates(scope, candidates, name, loc)
      match @candidates.select_without_context(name, typed_candidates) {
        Selected(candidate) =>
          self.synthesize_checked_value_reference(
            scope,
            candidate.reference,
            name,
            loc,
          )
        Ambiguous(name~, ..) => {
          self.report_ambiguous_value_reference(name, loc)
          checked_expression_none(Error)
        }
        NoMatch(name~) => {
          self.diagnostics.push({
            kind: CannotInferExpression("no matching value reference " + name),
            loc,
          })
          checked_expression_none(Error)
        }
      }
    }
    Unresolved(name) => {
      self.diagnostics.push({ kind: UnresolvedValue(name), loc })
      checked_expression_none(Error)
    }
  }
}

///|
fn SemanticChecker::synthesize_checked_symbol_value(
  self : SemanticChecker,
  scope : TypeScope,
  symbol : ValueSymbolId,
  name : String,
  loc : SourceSpan,
) -> CheckedExpressionSynthesis {
  guard scope.lookup(symbol) is Some(type_) else {
    self.diagnostics.push({ kind: UnresolvedValue(name), loc })
    return checked_expression_none(Error)
  }
  checked_expression(Value(name~, symbol~, type_~, loc~), type_)
}

///|
fn SemanticChecker::synthesize_checked_opened_field(
  self : SemanticChecker,
  scope : TypeScope,
  base : ValueSymbolId,
  path : Array[FieldSymbolId],
  name : String,
  loc : SourceSpan,
) -> CheckedExpressionSynthesis {
  guard scope.lookup(base) is Some(base_type) else {
    self.diagnostics.push({ kind: UnresolvedValue(name), loc })
    return checked_expression_none(Error)
  }
  let base_name = match self.source.symbols.value_metadata(base) {
    Some(metadata) => metadata.name
    None => name
  }
  let mut expression : @checked.CheckedExpr = Value(
    name=base_name,
    symbol=base,
    type_=base_type,
    loc~,
  )
  let mut type_ = base_type
  for field in path {
    let field_name = match self.source.symbols.field_metadata(field) {
      Some(metadata) => metadata.name
      None => name
    }
    let field_type = self.declarations.field_type(
      self.diagnostics,
      type_,
      field,
      field_name,
      loc,
    )
    expression = Field(
      base=expression,
      field~,
      name=field_name,
      type_=field_type,
      loc~,
    )
    type_ = field_type
  }
  checked_expression(expression, type_)
}

///|
fn checked_expression(
  expression : @checked.CheckedExpr,
  type_ : @types.Type,
) -> CheckedExpressionSynthesis {
  { expression: Some(expression), type_, missing_reported: false }
}

///|
fn checked_expression_none(type_ : @types.Type) -> CheckedExpressionSynthesis {
  { expression: None, type_, missing_reported: false }
}

///|
fn checked_expression_none_reported(
  type_ : @types.Type,
) -> CheckedExpressionSynthesis {
  { expression: None, type_, missing_reported: true }
}

///|
fn SemanticChecker::require_checked_expression(
  self : SemanticChecker,
  checked : CheckedExpressionSynthesis,
  loc : SourceSpan,
  label : String,
) -> @checked.CheckedExpr? {
  match checked.expression {
    Some(expression) => Some(expression)
    None => {
      if !checked.missing_reported {
        self.diagnostics.push({
          kind: CannotInferExpression("checked " + label),
          loc,
        })
      }
      None
    }
  }
}
