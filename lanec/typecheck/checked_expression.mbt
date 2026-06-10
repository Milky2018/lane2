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
    IntLiteral(value, loc~) =>
      checked_expression(
        IntLiteral(value~, type_=Primitive(Int), loc~),
        Primitive(Int),
      )
    StringLiteral(value, loc~) =>
      checked_expression(
        StringLiteral(value~, type_=Primitive(String), loc~),
        Primitive(String),
      )
    BoolLiteral(value, loc~) =>
      checked_expression(
        BoolLiteral(value~, type_=Primitive(Bool), loc~),
        Primitive(Bool),
      )
    UnitLiteral(loc~) =>
      checked_expression(
        UnitLiteral(type_=Primitive(Unit), loc~),
        Primitive(Unit),
      )
    Var(name~, reference~, loc~) =>
      self.synthesize_checked_value_reference(scope, reference, name, loc)
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
