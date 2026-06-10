///|
fn SemanticChecker::synthesize_unary_operator(
  self : SemanticChecker,
  scope : TypeScope,
  operator : @syntax.UnaryOperator,
  reference : @resolve.ResolvedValueReference,
  operand : @resolve.ResolvedExpr,
  loc : SourceSpan,
) -> @types.Type {
  self.synthesize_resolved_operator_call(
    scope,
    reference,
    operator.operation_name(),
    [operand],
    loc,
  )
}

///|
fn SemanticChecker::synthesize_binary_operator(
  self : SemanticChecker,
  scope : TypeScope,
  operator : @syntax.BinaryOperator,
  reference : @resolve.ResolvedValueReference,
  left : @resolve.ResolvedExpr,
  right : @resolve.ResolvedExpr,
  loc : SourceSpan,
) -> @types.Type {
  if operator is And || operator is Or {
    self.diagnostics.push({
      kind: CannotInferExpression("thunked operator"),
      loc,
    })
    return Error
  }
  self.synthesize_resolved_operator_call(
    scope,
    reference,
    operator.operation_name(),
    [left, right],
    loc,
  )
}

///|
fn SemanticChecker::synthesize_resolved_operator_call(
  self : SemanticChecker,
  scope : TypeScope,
  reference : @resolve.ResolvedValueReference,
  name : String,
  arguments : Array[@resolve.ResolvedExpr],
  loc : SourceSpan,
) -> @types.Type {
  let typed_candidates = if reference is Candidates(candidates~, ..) {
    self.typed_candidates(scope, candidates, name, loc)
  } else if self.typed_candidate(scope, reference, name, loc) is Some(candidate) {
    [candidate]
  } else {
    []
  }
  match
    self.select_callable_by_local_typing(
      scope,
      name,
      typed_candidates,
      arguments,
      None,
      loc,
    ) {
    Selected(candidate) => candidate.result
    Ambiguous(name~, ..) => {
      self.report_ambiguous_value_reference(name, loc)
      Error
    }
    NoMatch(name~) => {
      self.diagnostics.push({
        kind: CannotInferExpression(
          "no matching callable value reference " + name,
        ),
        loc,
      })
      Error
    }
  }
}

///|
fn SemanticChecker::check_unary_operator(
  self : SemanticChecker,
  scope : TypeScope,
  operator : @syntax.UnaryOperator,
  reference : @resolve.ResolvedValueReference,
  operand : @resolve.ResolvedExpr,
  expected : @types.Type,
  loc : SourceSpan,
) -> Unit {
  self.check_resolved_operator_call(
    scope,
    reference,
    operator.operation_name(),
    [operand],
    expected,
    loc,
  )
}

///|
fn SemanticChecker::check_binary_operator(
  self : SemanticChecker,
  scope : TypeScope,
  operator : @syntax.BinaryOperator,
  reference : @resolve.ResolvedValueReference,
  left : @resolve.ResolvedExpr,
  right : @resolve.ResolvedExpr,
  expected : @types.Type,
  loc : SourceSpan,
) -> Unit {
  if operator is And || operator is Or {
    self.diagnostics.push({
      kind: CannotInferExpression("thunked operator"),
      loc,
    })
    return
  }
  self.check_resolved_operator_call(
    scope,
    reference,
    operator.operation_name(),
    [left, right],
    expected,
    loc,
  )
}

///|
fn SemanticChecker::check_resolved_operator_call(
  self : SemanticChecker,
  scope : TypeScope,
  reference : @resolve.ResolvedValueReference,
  name : String,
  arguments : Array[@resolve.ResolvedExpr],
  expected : @types.Type,
  loc : SourceSpan,
) -> Unit {
  let typed_candidates = match reference {
    Candidates(candidates~, ..) =>
      self.typed_candidates(scope, candidates, name, loc)
    _ => {
      let actual = self.synthesize_resolved_operator_call(
        scope, reference, name, arguments, loc,
      )
      self.expect_type(expected, actual, loc)
      return
    }
  }
  match
    self.select_callable_by_local_typing(
      scope,
      name,
      typed_candidates,
      arguments,
      Some(expected),
      loc,
    ) {
    Selected(candidate) =>
      self.check_call_arguments(scope, candidate.parameters, arguments, loc)
    Ambiguous(name~, ..) => self.report_ambiguous_value_reference(name, loc)
    NoMatch(name~) =>
      self.diagnostics.push({
        kind: CannotInferExpression(
          "no matching callable value reference " + name,
        ),
        loc,
      })
  }
}

///|
fn @syntax.UnaryOperator::operation_name(
  self : @syntax.UnaryOperator,
) -> String {
  match self {
    Neg => "op_neg"
    Not => "op_not"
  }
}

///|
fn @syntax.BinaryOperator::operation_name(
  self : @syntax.BinaryOperator,
) -> String {
  match self {
    Add => "op_add"
    Sub => "op_sub"
    Mul => "op_mul"
    Div => "op_div"
    Rem => "op_rem"
    Equal => "op_equal"
    NotEqual => "op_not_equal"
    Less => "op_less"
    LessEqual => "op_less_eq"
    Greater => "op_greater"
    GreaterEqual => "op_greater_eq"
    And => "op_and"
    Or => "op_or"
  }
}
