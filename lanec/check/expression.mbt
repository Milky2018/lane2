///|
fn SemanticChecker::check_expr(
  self : SemanticChecker,
  scope : TypeScope,
  expr : @resolve.ResolvedExpr,
  expected : @types.Type,
) -> Unit {
  // Checking judgment:
  //
  //   Gamma |- e <= Expected
  //
  // The expected type flows only to syntax nodes that are adjacent to this
  // expression: variable candidates, block results, if branches, function
  // literals, calls, and operators. This is the local part of LTI; it never
  // creates global inference variables to be solved elsewhere.
  match expr {
    @resolve.ResolvedExpr::Builtin(_, ..) => ()
    @resolve.ResolvedExpr::Var(name~, reference~, loc~) =>
      match reference {
        @resolve.ResolvedValueReference::Candidates(candidates~, ..) =>
          self.check_candidate_reference(scope, name, candidates, expected, loc)
        _ => {
          let actual = self.synthesize_expr(scope, expr)
          self.expect_type(expected, actual, resolved_expr_loc(expr))
        }
      }
    @resolve.ResolvedExpr::Block(items~, result~, ..) =>
      self.check_block(scope, items, result, expected)
    @resolve.ResolvedExpr::If(condition~, then_branch~, else_branch~, ..) =>
      self.check_if(scope, condition, then_branch, else_branch, expected)
    @resolve.ResolvedExpr::QualifiedVariant(
      type_name~,
      type_arguments~,
      variant~,
      reference~,
      arguments~,
      loc~
    ) => {
      let actual = self.synthesize_qualified_variant(
        scope,
        type_name,
        type_arguments,
        variant,
        reference,
        arguments,
        Some(expected),
        loc,
      )
      self.expect_type(expected, actual, loc)
    }
    @resolve.ResolvedExpr::UnqualifiedVariant(
      variant~,
      reference~,
      arguments~,
      loc~
    ) => {
      let actual = self.synthesize_unqualified_variant(
        scope,
        variant,
        reference,
        arguments,
        Some(expected),
        loc,
      )
      self.expect_type(expected, actual, loc)
    }
    @resolve.ResolvedExpr::Call(callee~, arguments~, loc~) =>
      self.check_call(scope, callee, arguments, expected, loc)
    @resolve.ResolvedExpr::Unary(operator~, reference~, operand~, loc~) =>
      self.check_unary_operator(
        scope, operator, reference, operand, expected, loc,
      )
    @resolve.ResolvedExpr::Binary(operator~, reference~, left~, right~, loc~) =>
      self.check_binary_operator(
        scope, operator, reference, left, right, expected, loc,
      )
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
      let actual = self.synthesize_expr(scope, expr)
      self.expect_type(expected, actual, resolved_expr_loc(expr))
    }
  }
}

///|
fn SemanticChecker::check_if(
  self : SemanticChecker,
  scope : TypeScope,
  condition : @resolve.ResolvedExpr,
  then_branch : @resolve.ResolvedExpr,
  else_branch : @resolve.ResolvedExpr,
  expected : @types.Type,
) -> Unit {
  // Gamma |- condition <= Bool
  // Gamma |- then <= Expected
  // Gamma |- else <= Expected
  // ---
  // Gamma |- if condition { then } else { else } <= Expected
  self.check_expr(
    scope,
    condition,
    @types.Type::Primitive(@types.PrimitiveType::Bool),
  )
  self.check_expr(scope, then_branch, expected)
  self.check_expr(scope, else_branch, expected)
}

///|
fn SemanticChecker::check_block(
  self : SemanticChecker,
  scope : TypeScope,
  items : Array[@resolve.ResolvedLocalItem],
  result : @resolve.ResolvedExpr,
  expected : @types.Type,
) -> Unit {
  // Gamma |- item_1 => Gamma_1
  // ...
  // Gamma_n |- result <= Expected
  // ---
  // Gamma |- { item_1; ...; result } <= Expected
  //
  // Only the block result receives the expected type. Local items are processed
  // sequentially and extend a block-local scope.
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
  self.check_expr(next_scope, result, expected)
}

///|
fn SemanticChecker::synthesize_expr(
  self : SemanticChecker,
  scope : TypeScope,
  expr : @resolve.ResolvedExpr,
) -> @types.Type {
  // Synthesis judgment:
  //
  //   Gamma |- e => T
  //
  // This direction computes a type from the expression itself. If an expression
  // needs an adjacent expected type, it must be handled by `check_expr` instead
  // of inventing a non-local type.
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
      self.synthesize_value_reference(scope, reference, name, loc)
    @resolve.ResolvedExpr::FunctionLiteral(
      type_parameters~,
      parameters~,
      return_type~,
      body~,
      loc~
    ) =>
      self.synthesize_function_literal(
        scope, type_parameters, parameters, return_type, body, loc,
      )
    @resolve.ResolvedExpr::Block(items~, result~, ..) =>
      self.synthesize_block(scope, items, result)
    @resolve.ResolvedExpr::If(condition~, then_branch~, else_branch~, loc~) =>
      self.synthesize_if(scope, condition, then_branch, else_branch, loc)
    @resolve.ResolvedExpr::QualifiedVariant(
      type_name~,
      type_arguments~,
      variant~,
      reference~,
      arguments~,
      loc~
    ) =>
      self.synthesize_qualified_variant(
        scope,
        type_name,
        type_arguments,
        variant,
        reference,
        arguments,
        None,
        loc,
      )
    @resolve.ResolvedExpr::UnqualifiedVariant(
      variant~,
      reference~,
      arguments~,
      loc~
    ) =>
      self.synthesize_unqualified_variant(
        scope,
        variant,
        reference,
        arguments,
        None,
        loc,
      )
    @resolve.ResolvedExpr::Call(callee~, arguments~, loc~) =>
      self.synthesize_call(scope, callee, arguments, loc)
    @resolve.ResolvedExpr::Field(base~, name~, reference~, loc~) =>
      self.synthesize_field(scope, base, name, reference, loc)
    @resolve.ResolvedExpr::Unary(operator~, reference~, operand~, loc~) =>
      self.synthesize_unary_operator(scope, operator, reference, operand, loc)
    @resolve.ResolvedExpr::Binary(operator~, reference~, left~, right~, loc~) =>
      self.synthesize_binary_operator(
        scope, operator, reference, left, right, loc,
      )
    @resolve.ResolvedExpr::StructLiteral(
      type_name~,
      type_arguments~,
      fields~,
      loc~
    ) =>
      self.synthesize_struct_literal(
        scope, type_name, type_arguments, fields, loc,
      )
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
fn SemanticChecker::synthesize_block(
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
  self.synthesize_expr(next_scope, result)
}

///|
fn SemanticChecker::synthesize_if(
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
  let then_type = self.synthesize_expr(scope, then_branch)
  let else_type = self.synthesize_expr(scope, else_branch)
  self.expect_type(then_type, else_type, loc)
  then_type
}

///|
fn SemanticChecker::expect_type(
  self : SemanticChecker,
  expected : @types.Type,
  actual : @types.Type,
  loc : SourceSpan,
) -> Unit {
  if !type_matches(expected, actual) {
    self.diagnostics.push({
      kind: CheckDiagnosticKind::TypeMismatch(expected~, actual~),
      loc,
    })
  }
}

///|
fn type_matches(expected : @types.Type, actual : @types.Type) -> Bool {
  match (expected, actual) {
    (@types.Type::Error, _) | (_, @types.Type::Error) => true
    _ => expected.equals(actual)
  }
}
