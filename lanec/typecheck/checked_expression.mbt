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
  expression : @desugar.DesugaredExpr,
  expected : @types.Type,
) -> CheckedExpressionSynthesis {
  // Checked expression construction follows the checking judgment:
  //
  //   Gamma |- e <= Expected ~~> checked_e
  //
  // Only desugared forms that can use direct expected context are constructed
  // here. The remaining forms continue to use the existing type-only checker
  // until their checked-node rules are moved over one by one.
  match expression {
    Builtin(name, loc~) =>
      // `builtin` is unsafe and opaque to the checker. The adjacent expected
      // type is the whole type of the resulting checked node.
      checked_expression(UnsafeBuiltin(name~, type_=expected, loc~), expected)
    Literal(..) | Field(..) => {
      let checked = self.synthesize_checked_expr(scope, expression)
      self.expect_type(expected, checked.type_, expression.loc())
      checked
    }
    Block(items~, result~, loc~) =>
      self.check_checked_block(scope, items, result, expected, loc)
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
          self.expect_type(expected, checked.type_, expression.loc())
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
  expression : @desugar.DesugaredExpr,
) -> CheckedExpressionSynthesis {
  // Checked expression construction follows the synthesis judgment:
  //
  //   Gamma |- e => T ~~> checked_e
  //
  // This initial slice covers source forms whose checked node does not need a
  // recursive checked subtree. Compound expressions still return their
  // synthesized type through the existing checker and no checked node.
  match expression {
    Literal(literal~, loc~) => {
      let type_ = literal.type_()
      checked_expression(
        Literal(literal=self.checked_literal(literal, loc), type_~, loc~),
        type_,
      )
    }
    FunctionLiteral(type_parameters~, parameters~, return_type~, body~, loc~) =>
      self.synthesize_checked_function_literal(
        scope, type_parameters, parameters, return_type, body, loc,
      )
    Var(name~, reference~, loc~) =>
      self.synthesize_checked_value_reference(scope, reference, name, loc)
    Field(base~, name~, reference~, loc~) =>
      self.synthesize_checked_field(scope, base, name, reference, loc)
    Call(callee~, arguments~, loc~) =>
      self.synthesize_checked_call(scope, callee, arguments, loc)
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
  items : Array[@desugar.DesugaredLocalItem],
  result : @desugar.DesugaredExpr,
  expected : @types.Type,
  loc : SourceSpan,
) -> CheckedExpressionSynthesis {
  let next_scope = scope.copy()
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
      Offer(declaration) =>
        match self.check_checked_local_offer(next_scope, declaration) {
          Some(declaration) => checked_items.push(Let(declaration))
          None => complete = false
        }
    }
  }
  let checked_result = self.check_checked_expr(next_scope, result, expected)
  guard self.require_checked_expression(
      checked_result,
      result.loc(),
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
fn SemanticChecker::synthesize_checked_call(
  self : SemanticChecker,
  scope : TypeScope,
  callee : @desugar.DesugaredExpr,
  arguments : Array[@desugar.DesugaredCallArgument],
  loc : SourceSpan,
) -> CheckedExpressionSynthesis {
  self.synthesize_checked_call_with_expected(
    scope,
    callee,
    arguments,
    None,
    loc,
  )
}

///|
fn SemanticChecker::synthesize_checked_call_with_expected(
  self : SemanticChecker,
  scope : TypeScope,
  callee : @desugar.DesugaredExpr,
  arguments : Array[@desugar.DesugaredCallArgument],
  expected_result : @types.Type?,
  loc : SourceSpan,
) -> CheckedExpressionSynthesis {
  if callee is Var(name~, reference~, loc=callee_loc) &&
    reference is Candidates(..) {
    return self.synthesize_checked_resolved_callable_call(
      scope, reference, name, arguments, expected_result, callee_loc,
    )
  }
  let checked_callee = self.synthesize_checked_expr(scope, callee)
  guard self.require_checked_expression(
      checked_callee,
      callee.loc(),
      "call callee",
    )
    is Some(checked_callee_expr) else {
    return checked_expression_none_reported(Error)
  }
  let arguments = self.prepare_direct_call_arguments(
    scope,
    callee,
    checked_callee.type_,
    arguments,
    expected_result,
    loc,
  )
  match checked_callee.type_ {
    Function(parameters, result) => {
      guard self.check_checked_call_arguments(scope, parameters, arguments, loc)
        is Some(arguments) else {
        return checked_expression_none_reported(result)
      }
      checked_expression(
        Call(callee=checked_callee_expr, arguments~, type_=result, loc~),
        result,
      )
    }
    Forall(type_parameters, body) => {
      guard self.instantiate_generic_callable(
          scope, type_parameters, body, arguments, expected_result, loc, true,
        )
        is Some(instantiated) else {
        return checked_expression_none_reported(Error)
      }
      guard self.check_checked_call_arguments(
          scope,
          instantiated.parameters,
          arguments,
          loc,
        )
        is Some(arguments) else {
        return checked_expression_none_reported(instantiated.result)
      }
      let callee = type_applied_callee(
        checked_callee_expr,
        instantiated.type_arguments,
        Function(instantiated.parameters, instantiated.result),
        loc,
      )
      checked_expression(
        Call(callee~, arguments~, type_=instantiated.result, loc~),
        instantiated.result,
      )
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
  callee : @desugar.DesugaredExpr,
  arguments : Array[@desugar.DesugaredCallArgument],
  expected : @types.Type,
  loc : SourceSpan,
) -> CheckedExpressionSynthesis {
  let checked = self.synthesize_checked_call_with_expected(
    scope,
    callee,
    arguments,
    Some(expected),
    loc,
  )
  self.expect_type(expected, checked.type_, loc)
  checked
}

///|
fn SemanticChecker::synthesize_checked_resolved_callable_call(
  self : SemanticChecker,
  scope : TypeScope,
  reference : @resolve.ResolvedValueReference,
  name : String,
  arguments : Array[@desugar.DesugaredCallArgument],
  expected_result : @types.Type?,
  loc : SourceSpan,
) -> CheckedExpressionSynthesis {
  // Candidate selection is still type-directed at the desugared-call boundary.
  // Once a callable candidate is selected, this function constructs the
  // concrete checked callee and checked arguments so no candidate set reaches
  // Checked Source.
  let typed_candidates = if reference is Candidates(candidates~, ..) {
    self.typed_candidates(scope, candidates, name, loc)
  } else if self.typed_candidate(scope, reference, name, loc) is Some(candidate) {
    [candidate]
  } else {
    []
  }
  match
    self.select_callable_by_local_typing(
      scope, name, typed_candidates, arguments, expected_result, loc,
    ) {
    Selected(candidate) =>
      self.synthesize_checked_callable_candidate(
        scope, name, candidate, arguments, loc,
      )
    Ambiguous(name~, ..) => {
      self.report_ambiguous_value_reference(name, loc)
      checked_expression_none_reported(Error)
    }
    NoMatch(name~) => {
      self.diagnostics.push({
        kind: CannotInferExpression(
          "no matching callable value reference " + name,
        ),
        loc,
      })
      checked_expression_none_reported(Error)
    }
  }
}

///|
fn SemanticChecker::synthesize_checked_callable_candidate(
  self : SemanticChecker,
  scope : TypeScope,
  name : String,
  candidate : @candidates.CallableCandidate,
  arguments : Array[@desugar.DesugaredCallArgument],
  loc : SourceSpan,
) -> CheckedExpressionSynthesis {
  let checked_callee = self.synthesize_checked_value_reference(
    scope,
    candidate.reference,
    name,
    loc,
  )
  guard self.require_checked_expression(checked_callee, loc, "call callee")
    is Some(callee) else {
    return checked_expression_none_reported(candidate.result)
  }
  guard self.check_checked_call_arguments(
      scope,
      candidate.parameters,
      arguments,
      loc,
    )
    is Some(arguments) else {
    return checked_expression_none_reported(candidate.result)
  }
  let callee = type_applied_callee(
    callee,
    candidate.type_arguments,
    Function(candidate.parameters, candidate.result),
    loc,
  )
  checked_expression(
    Call(callee~, arguments~, type_=candidate.result, loc~),
    candidate.result,
  )
}

///|
fn type_applied_callee(
  callee : @checked.CheckedExpr,
  type_arguments : Array[@types.Type],
  type_ : @types.Type,
  loc : SourceSpan,
) -> @checked.CheckedExpr {
  // Non-generic calls keep the value callee directly. Generic calls insert the
  // explicit checked type application inferred by local call checking.
  if type_arguments.is_empty() {
    callee
  } else {
    TypeApplication(callee~, arguments=type_arguments, type_~, loc~)
  }
}

///|
fn SemanticChecker::check_checked_call_arguments(
  self : SemanticChecker,
  scope : TypeScope,
  parameters : Array[@types.Type],
  arguments : Array[@desugar.DesugaredCallArgument],
  loc : SourceSpan,
) -> Array[@checked.CheckedExpr]? {
  if parameters.length() != arguments.length() {
    self.diagnostics.push({ kind: CannotInferExpression("call arity"), loc })
    return None
  }
  let checked_arguments = []
  let mut complete = true
  for index in 0..<parameters.length() {
    let checked = self.check_checked_call_argument(
      scope,
      arguments[index],
      parameters[index],
    )
    match
      self.require_checked_expression(
        checked,
        arguments[index].value_expr().loc(),
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
fn SemanticChecker::check_checked_call_argument(
  self : SemanticChecker,
  scope : TypeScope,
  argument : @desugar.DesugaredCallArgument,
  parameter : @types.Type,
) -> CheckedExpressionSynthesis {
  match argument {
    Positional(expression) =>
      self.check_checked_expr(scope, expression, parameter)
    Named(name~, value~, loc~) => {
      self.diagnostics.push({
        kind: CannotInferExpression("invalid named argument " + name),
        loc,
      })
      self.check_checked_expr(scope, value, parameter)
    }
  }
}

///|
fn SemanticChecker::synthesize_checked_function_literal(
  self : SemanticChecker,
  scope : TypeScope,
  type_parameters : Array[@resolve.ResolvedTypeParameter],
  parameters : Array[@resolve.ResolvedFunctionLiteralParameter],
  return_type : @resolve.ResolvedType?,
  body : @desugar.DesugaredExpr,
  loc : SourceSpan,
) -> CheckedExpressionSynthesis {
  let parameter_types = []
  let checked_parameters : Array[@checked.CheckedValueParameter] = []
  let body_scope = scope.copy()
  for parameter in parameters {
    if parameter.type_annotation is Some(type_annotation) {
      let type_ = self.check_type(type_annotation)
      body_scope.bind(parameter.symbol, type_)
      if parameter.is_offered {
        self.offer_symbol(
          body_scope.offers,
          parameter.symbol,
          type_,
          parameter.loc,
        )
      }
      parameter_types.push(type_)
      checked_parameters.push({
        symbol: parameter.symbol,
        is_auto: false,
        is_offered: parameter.is_offered,
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
      body_scope.bind(parameter.symbol, type_)
      if parameter.is_offered {
        self.offer_symbol(
          body_scope.offers,
          parameter.symbol,
          type_,
          parameter.loc,
        )
      }
      parameter_types.push(type_)
      checked_parameters.push({
        symbol: parameter.symbol,
        is_auto: false,
        is_offered: parameter.is_offered,
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
      body.loc(),
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
  body : @desugar.DesugaredExpr,
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
fn SemanticChecker::synthesize_checked_field(
  self : SemanticChecker,
  scope : TypeScope,
  base : @desugar.DesugaredExpr,
  name : String,
  reference : @resolve.ResolvedFieldReference,
  loc : SourceSpan,
) -> CheckedExpressionSynthesis {
  let checked_base = self.synthesize_checked_expr(scope, base)
  guard self.require_checked_expression(checked_base, base.loc(), "field base")
    is Some(base) else {
    return checked_expression_none_reported(Error)
  }
  match reference {
    Symbol(field) =>
      self.checked_field_from_symbol(base, checked_base.type_, field, name, loc)
    Deferred(_) =>
      if checked_base.type_ is Nominal(symbol, _) {
        guard self.source.symbols.field_named(symbol, name) is Some(field) else {
          self.diagnostics.push({ kind: UnknownField(name~), loc })
          return checked_expression_none_reported(Error)
        }
        self.checked_field_from_symbol(
          base,
          checked_base.type_,
          field,
          name,
          loc,
        )
      } else if checked_base.type_ is Error {
        checked_expression_none_reported(Error)
      } else {
        self.diagnostics.push({ kind: NotAStruct(checked_base.type_), loc })
        checked_expression_none_reported(Error)
      }
    Unresolved(..) => {
      self.diagnostics.push({ kind: UnknownField(name~), loc })
      checked_expression_none_reported(Error)
    }
  }
}

///|
fn SemanticChecker::checked_field_from_symbol(
  self : SemanticChecker,
  base : @checked.CheckedExpr,
  base_type : @types.Type,
  field : FieldSymbolId,
  name : String,
  loc : SourceSpan,
) -> CheckedExpressionSynthesis {
  let type_ = self.declarations.field_type(
    self.diagnostics,
    base_type,
    field,
    name,
    loc,
  )
  checked_expression(Field(base~, field~, name~, type_~, loc~), type_)
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
