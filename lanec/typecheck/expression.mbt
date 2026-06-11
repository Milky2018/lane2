///|
fn SemanticChecker::check_expr(
  self : SemanticChecker,
  scope : TypeScope,
  expr : @desugar.DesugaredExpr,
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
    IntLiteral(raw, loc~) => {
      ignore(self.check_int_literal(raw, loc))
      self.expect_type(expected, Primitive(Int), loc)
    }
    Builtin(_, ..) => ()
    Var(name~, reference~, loc~) =>
      match reference {
        Candidates(candidates~, ..) =>
          self.check_candidate_reference(scope, name, candidates, expected, loc)
        _ => {
          let actual = self.synthesize_expr(scope, expr)
          self.expect_type(expected, actual, expr.loc())
        }
      }
    Block(items~, result~, ..) =>
      self.check_block(scope, items, result, expected)
    If(condition~, then_branch~, else_branch~, ..) =>
      self.check_if(scope, condition, then_branch, else_branch, expected)
    Match(scrutinee~, arms~, loc~) =>
      self.check_match(scope, scrutinee, arms, expected, loc)
    QualifiedVariant(
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
    UnqualifiedVariant(variant~, reference~, arguments~, loc~) => {
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
    Call(callee~, arguments~, loc~) =>
      self.check_call(scope, callee, arguments, expected, loc)
    FunctionLiteral(type_parameters~, parameters~, return_type~, body~, loc~) =>
      self.check_function_literal(
        scope, type_parameters, parameters, return_type, body, expected, loc,
      )
    _ => {
      let actual = self.synthesize_expr(scope, expr)
      self.expect_type(expected, actual, expr.loc())
    }
  }
}

///|
fn SemanticChecker::check_if(
  self : SemanticChecker,
  scope : TypeScope,
  condition : @desugar.DesugaredExpr,
  then_branch : @desugar.DesugaredExpr,
  else_branch : @desugar.DesugaredExpr,
  expected : @types.Type,
) -> Unit {
  // Gamma |- condition <= Bool
  // Gamma |- then <= Expected
  // Gamma |- else <= Expected
  // ---
  // Gamma |- if condition { then } else { else } <= Expected
  self.check_expr(scope, condition, Primitive(Bool))
  self.check_expr(scope, then_branch, expected)
  self.check_expr(scope, else_branch, expected)
}

///|
fn SemanticChecker::check_block(
  self : SemanticChecker,
  scope : TypeScope,
  items : Array[@desugar.DesugaredLocalItem],
  result : @desugar.DesugaredExpr,
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
      Let(declaration) => self.check_local_let(next_scope, declaration)
      Function(declaration) =>
        self.check_local_function(next_scope, declaration)
      Open(_) => ()
    }
  }
  self.check_expr(next_scope, result, expected)
}

///|
fn SemanticChecker::synthesize_expr(
  self : SemanticChecker,
  scope : TypeScope,
  expr : @desugar.DesugaredExpr,
) -> @types.Type {
  // Synthesis judgment:
  //
  //   Gamma |- e => T
  //
  // This direction computes a type from the expression itself. If an expression
  // needs an adjacent expected type, it must be handled by `check_expr` instead
  // of inventing a non-local type.
  match expr {
    IntLiteral(raw, loc~) => {
      ignore(self.check_int_literal(raw, loc))
      Primitive(Int)
    }
    StringLiteral(_, ..) => Primitive(String)
    BoolLiteral(_, ..) => Primitive(Bool)
    UnitLiteral(..) => Primitive(Unit)
    Var(name~, reference~, loc~) =>
      self.synthesize_value_reference(scope, reference, name, loc)
    FunctionLiteral(type_parameters~, parameters~, return_type~, body~, loc~) =>
      self.synthesize_function_literal(
        scope, type_parameters, parameters, return_type, body, loc,
      )
    Block(items~, result~, ..) => self.synthesize_block(scope, items, result)
    If(condition~, then_branch~, else_branch~, loc~) =>
      self.synthesize_if(scope, condition, then_branch, else_branch, loc)
    Match(scrutinee~, arms~, loc~) =>
      self.synthesize_match(scope, scrutinee, arms, loc)
    QualifiedVariant(
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
    UnqualifiedVariant(variant~, reference~, arguments~, loc~) =>
      self.synthesize_unqualified_variant(
        scope,
        variant,
        reference,
        arguments,
        None,
        loc,
      )
    Call(callee~, arguments~, loc~) =>
      self.synthesize_call(scope, callee, arguments, loc)
    Field(base~, name~, reference~, loc~) =>
      self.synthesize_field(scope, base, name, reference, loc)
    StructLiteral(type_name~, type_arguments~, fields~, loc~) =>
      self.synthesize_struct_literal(
        scope, type_name, type_arguments, fields, loc,
      )
    Builtin(_, loc~) => {
      self.diagnostics.push({ kind: CannotInferExpression("builtin"), loc })
      Error
    }
  }
}

///|
fn SemanticChecker::synthesize_block(
  self : SemanticChecker,
  scope : TypeScope,
  items : Array[@desugar.DesugaredLocalItem],
  result : @desugar.DesugaredExpr,
) -> @types.Type {
  let next_scope : TypeScope = { values: scope.values.copy() }
  for item in items {
    match item {
      Let(declaration) => self.check_local_let(next_scope, declaration)
      Function(declaration) =>
        self.check_local_function(next_scope, declaration)
      Open(_) => ()
    }
  }
  self.synthesize_expr(next_scope, result)
}

///|
fn SemanticChecker::synthesize_if(
  self : SemanticChecker,
  scope : TypeScope,
  condition : @desugar.DesugaredExpr,
  then_branch : @desugar.DesugaredExpr,
  else_branch : @desugar.DesugaredExpr,
  loc : SourceSpan,
) -> @types.Type {
  self.check_expr(scope, condition, Primitive(Bool))
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
    self.diagnostics.push({ kind: TypeMismatch(expected~, actual~), loc })
  }
}

///|
fn type_matches(expected : @types.Type, actual : @types.Type) -> Bool {
  expected is Error || actual is Error || expected.equals(actual)
}
