///|
priv struct PatternMatrix {
  rows : Array[@checked.CheckedPattern]
}

///|
fn PatternMatrix::PatternMatrix() -> PatternMatrix {
  { rows: [] }
}

///|
fn PatternMatrix::add(
  self : PatternMatrix,
  pattern : @checked.CheckedPattern,
) -> Unit {
  self.rows.push(pattern)
}

///|
fn SemanticChecker::check_match(
  self : SemanticChecker,
  scope : TypeScope,
  scrutinee : @resolve.ResolvedExpr,
  arms : Array[@resolve.ResolvedMatchArm],
  expected : @types.Type,
  loc : SourceSpan,
) -> Unit {
  // Match checking judgment:
  //
  //   Gamma |- scrutinee => S
  //   Gamma, binders(p_i : S) |- body_i <= Expected
  //   useful(p_i, previous_patterns)
  //   exhaustive(S, patterns)
  //
  // The scrutinee type is synthesized once, then every arm pattern is checked
  // against that type. Pattern binders extend only the copied arm scope. This
  // pass records the checked patterns needed by later typed core, but it does
  // not build a decision tree; the tree is an execution lowering concern.
  let scrutinee_type = self.synthesize_expr(scope, scrutinee)
  let matrix = PatternMatrix::PatternMatrix()
  for arm in arms {
    let arm_scope : TypeScope = { values: scope.values.copy() }
    let pattern = self.check_match_pattern(
      arm_scope,
      arm.pattern,
      scrutinee_type,
    )
    if !matrix.is_useful(self.declarations, pattern, scrutinee_type) {
      self.diagnostics.push({ kind: UnreachableMatchArm, loc: arm.loc })
    }
    matrix.add(pattern)
    self.check_expr(arm_scope, arm.body, expected)
  }
  if !matrix.is_exhaustive(self.declarations, scrutinee_type) {
    self.diagnostics.push({ kind: NonExhaustiveMatch(scrutinee_type), loc })
  }
}

///|
fn SemanticChecker::synthesize_match(
  self : SemanticChecker,
  scope : TypeScope,
  scrutinee : @resolve.ResolvedExpr,
  arms : Array[@resolve.ResolvedMatchArm],
  loc : SourceSpan,
) -> @types.Type {
  // Match synthesis judgment:
  //
  //   Gamma |- scrutinee => S
  //   Gamma, binders(p_i : S) |- body_i => T_i
  //   T_1 == ... == T_n
  //
  // Unlike checking mode, no result type is pushed into arm bodies. The first
  // arm establishes the synthesized result type, and later arms are required to
  // match it. Exhaustiveness and usefulness are still checked on the same
  // pattern matrix used by checking mode.
  let scrutinee_type = self.synthesize_expr(scope, scrutinee)
  let matrix = PatternMatrix::PatternMatrix()
  let mut result : @types.Type = Error
  let mut has_result = false
  for arm in arms {
    let arm_scope : TypeScope = { values: scope.values.copy() }
    let pattern = self.check_match_pattern(
      arm_scope,
      arm.pattern,
      scrutinee_type,
    )
    if !matrix.is_useful(self.declarations, pattern, scrutinee_type) {
      self.diagnostics.push({ kind: UnreachableMatchArm, loc: arm.loc })
    }
    matrix.add(pattern)
    let arm_type = self.synthesize_expr(arm_scope, arm.body)
    if has_result {
      self.expect_type(result, arm_type, arm.loc)
    } else {
      result = arm_type
      has_result = true
    }
  }
  if !has_result {
    self.diagnostics.push({ kind: CannotInferExpression("empty match"), loc })
  }
  if !matrix.is_exhaustive(self.declarations, scrutinee_type) {
    self.diagnostics.push({ kind: NonExhaustiveMatch(scrutinee_type), loc })
  }
  result
}

///|
fn SemanticChecker::check_match_pattern(
  self : SemanticChecker,
  scope : TypeScope,
  pattern : @resolve.ResolvedPattern,
  expected : @types.Type,
) -> @checked.CheckedPattern {
  // Pattern checking judgment:
  //
  //   Gamma |- p <= T ~~> checked_p, Gamma'
  //
  // Patterns are checked against an already known scrutinee type. They do not
  // synthesize the scrutinee type and do not create non-local type variables.
  // The binder set is per-pattern and rejects repeated names before the arm
  // body is checked under the extended scope.
  let binders = []
  self.check_pattern(scope, pattern, expected, binders)
}

///|
fn SemanticChecker::check_pattern(
  self : SemanticChecker,
  scope : TypeScope,
  pattern : @resolve.ResolvedPattern,
  expected : @types.Type,
  binders : Array[String],
) -> @checked.CheckedPattern {
  match pattern {
    Wildcard(loc) => Wildcard(type_=expected, loc~)
    Binding(name~, symbol~, loc~) => {
      if binders.contains(name) {
        self.diagnostics.push({ kind: DuplicatePatternBinder(name~), loc })
      } else {
        binders.push(name)
      }
      scope.bind(symbol, name, expected)
      Binding(name~, symbol~, type_=expected, loc~)
    }
    IntLiteral(value, loc~) => {
      self.expect_type(expected, Primitive(Int), loc)
      IntLiteral(value~, type_=expected, loc~)
    }
    StringLiteral(value, loc~) => {
      self.expect_type(expected, Primitive(String), loc)
      StringLiteral(value~, type_=expected, loc~)
    }
    BoolLiteral(value, loc~) => {
      self.expect_type(expected, Primitive(Bool), loc)
      BoolLiteral(value~, type_=expected, loc~)
    }
    QualifiedVariant(type_name~, variant~, reference~, arguments~, loc~) =>
      self.check_variant_pattern(
        scope, type_name, variant, reference, arguments, expected, binders, loc,
      )
    Struct(type_name~, fields~, loc~) =>
      self.check_struct_pattern(
        scope, type_name, fields, expected, binders, loc,
      )
  }
}

///|
fn SemanticChecker::check_variant_pattern(
  self : SemanticChecker,
  scope : TypeScope,
  type_name : String,
  variant : String,
  reference : @resolve.ResolvedVariantReference,
  arguments : Array[@resolve.ResolvedPattern],
  expected : @types.Type,
  binders : Array[String],
  loc : SourceSpan,
) -> @checked.CheckedPattern {
  match reference {
    Symbol(symbol) =>
      self.check_variant_symbol_pattern(
        scope, type_name, variant, symbol, arguments, expected, binders, loc,
      )
    Ambiguous(name~, ..) => {
      self.report_ambiguous_variant_reference(name, loc)
      Wildcard(type_=Error, loc~)
    }
    Unresolved(type_name~, variant~) => {
      self.diagnostics.push({
        kind: CannotInferExpression(
          "unresolved variant " + type_name + "::" + variant,
        ),
        loc,
      })
      Wildcard(type_=Error, loc~)
    }
    UnresolvedUnqualified(name) => {
      self.diagnostics.push({
        kind: CannotInferExpression("unresolved variant " + name),
        loc,
      })
      Wildcard(type_=Error, loc~)
    }
  }
}

///|
fn SemanticChecker::check_variant_symbol_pattern(
  self : SemanticChecker,
  scope : TypeScope,
  type_name : String,
  variant : String,
  symbol : VariantSymbolId,
  arguments : Array[@resolve.ResolvedPattern],
  expected : @types.Type,
  binders : Array[String],
  loc : SourceSpan,
) -> @checked.CheckedPattern {
  // Variant pattern rule:
  //
  //   Expected = E[A_1, ..., A_n]
  //   variant v belongs to E
  //   payload_i[v][A_1, ..., A_n] checks pattern_i
  //
  // Variant patterns are nominal. The variant symbol determines the owner enum,
  // and the expected enum application supplies the type arguments used to
  // substitute payload types.
  guard self.source.symbols.variant_metadata(symbol) is Some(metadata) else {
    self.diagnostics.push({
      kind: CannotInferExpression(
        "unknown variant " + type_name + "::" + variant,
      ),
      loc,
    })
    return Wildcard(type_=Error, loc~)
  }
  guard self.declarations.checked_enum(metadata.owner) is Some(declaration) else {
    self.diagnostics.push({
      kind: CannotInferExpression("unknown variant owner " + type_name),
      loc,
    })
    return Wildcard(type_=Error, loc~)
  }
  guard declaration.variant(symbol) is Some(variant_declaration) else {
    self.diagnostics.push({
      kind: CannotInferExpression(
        "unknown variant " + type_name + "::" + variant,
      ),
      loc,
    })
    return Wildcard(type_=Error, loc~)
  }
  let type_arguments = match expected {
    Nominal(owner, arguments) if owner == metadata.owner => arguments
    Error => []
    _ => {
      self.expect_type(
        expected,
        Nominal(
          metadata.owner,
          declaration.type_parameters.map(fn(parameter) {
            Parameter(parameter.id)
          }),
        ),
        loc,
      )
      []
    }
  }
  if variant_declaration.payload.length() != arguments.length() {
    self.diagnostics.push({
      kind: PatternArityMismatch(
        name=type_name + "::" + variant,
        expected=variant_declaration.payload.length(),
        actual=arguments.length(),
      ),
      loc,
    })
  }
  let substitution = variant_type_substitution(
    declaration.type_parameters,
    type_arguments,
  )
  let checked_arguments = []
  let length = if variant_declaration.payload.length() < arguments.length() {
    variant_declaration.payload.length()
  } else {
    arguments.length()
  }
  for index in 0..<length {
    checked_arguments.push(
      self.check_pattern(
        scope,
        arguments[index],
        variant_declaration.payload[index].substitute(substitution),
        binders,
      ),
    )
  }
  Variant(symbol~, arguments=checked_arguments, type_=expected, loc~)
}

///|
fn SemanticChecker::check_struct_pattern(
  self : SemanticChecker,
  scope : TypeScope,
  type_name : String,
  fields : Array[@resolve.ResolvedStructPatternField],
  expected : @types.Type,
  binders : Array[String],
  loc : SourceSpan,
) -> @checked.CheckedPattern {
  // Struct pattern rule:
  //
  //   Expected = S[A_1, ..., A_n]
  //   every declared field of S appears exactly once
  //   field_i[S][A_1, ..., A_n] checks pattern_i
  //
  // Source field order is ignored after checking. The checked struct pattern is
  // emitted in declaration order so typed core and later execution lowering do
  // not depend on source spelling order.
  guard self.source.symbols.type_named(type_name) is Some(symbol) else {
    self.diagnostics.push({ kind: UnresolvedType(type_name), loc })
    return Wildcard(type_=Error, loc~)
  }
  let type_arguments = match expected {
    Nominal(owner, arguments) if owner == symbol => arguments
    Error => []
    _ => {
      self.expect_type(expected, Nominal(symbol, []), loc)
      []
    }
  }
  guard self.declarations.checked_struct(symbol) is Some(declaration) else {
    self.diagnostics.push({
      kind: NotAStruct(Nominal(symbol, type_arguments)),
      loc,
    })
    return Wildcard(type_=Error, loc~)
  }
  let seen = []
  for field in fields {
    if seen.contains(field.name) {
      self.diagnostics.push({
        kind: DuplicateField(name=field.name),
        loc: field.loc,
      })
    } else {
      seen.push(field.name)
    }
    if self.source.symbols.field_named(symbol, field.name) is None {
      self.diagnostics.push({
        kind: UnknownField(name=field.name),
        loc: field.loc,
      })
    }
  }
  let substitution = declaration.nominal_substitution(type_arguments)
  let checked_fields = []
  for declaration_field in declaration.fields {
    match fields.find_by_name(declaration_field.name) {
      Some(field) => {
        let checked = self.check_pattern(
          scope,
          field.pattern,
          declaration_field.type_.substitute(substitution),
          binders,
        )
        let checked_field : @checked.CheckedStructPatternField = {
          symbol: declaration_field.symbol,
          name: declaration_field.name,
          pattern: checked,
          loc: field.loc,
        }
        checked_fields.push(checked_field)
      }
      None =>
        self.diagnostics.push({
          kind: MissingField(name=declaration_field.name),
          loc,
        })
    }
  }
  Struct(symbol~, fields=checked_fields, type_=expected, loc~)
}

///|
fn Array::find_by_name(
  self : Array[@resolve.ResolvedStructPatternField],
  name : String,
) -> @resolve.ResolvedStructPatternField? {
  for field in self {
    if field.name == name {
      return Some(field)
    }
  }
  None
}

///|
fn PatternMatrix::is_useful(
  self : PatternMatrix,
  declarations : CheckedDeclarationEnvironment,
  pattern : @checked.CheckedPattern,
  type_ : @types.Type,
) -> Bool {
  // Usefulness judgment:
  //
  //   useful(matrix, p, T)
  //
  // The current implementation is the single-scrutinee slice of the standard
  // pattern-matrix algorithm. It is intentionally conservative for nested
  // payloads: a constructor pattern covers a previous constructor only when its
  // payload patterns are irrefutable or structurally identical.
  if self.is_exhaustive(declarations, type_) {
    return false
  }
  match pattern {
    Wildcard(..) | Binding(..) => true
    BoolLiteral(value~, ..) => !self.covers_bool_literal(value)
    IntLiteral(value~, ..) => !self.covers_int_literal(value)
    StringLiteral(value~, ..) => !self.covers_string_literal(value)
    Variant(symbol~, arguments~, ..) =>
      !self.covers_variant(declarations, symbol, arguments)
    Struct(..) => true
    UnitLiteral(..) => true
  }
}

///|
fn PatternMatrix::is_exhaustive(
  self : PatternMatrix,
  declarations : CheckedDeclarationEnvironment,
  type_ : @types.Type,
) -> Bool {
  // Exhaustiveness judgment:
  //
  //   exhaustive(matrix, T)
  //
  // Bool and Unit use their finite primitive inhabitant sets. Int and String
  // require an irrefutable fallback because their literal spaces are open in
  // v1. Nominal enums are exhaustive when every variant constructor is covered;
  // nominal structs need an irrefutable struct, wildcard, or binding pattern.
  for row in self.rows {
    if pattern_is_irrefutable(declarations, row, type_) {
      return true
    }
  }
  match type_ {
    Error => true
    Primitive(Bool) =>
      self.covers_bool_literal(true) && self.covers_bool_literal(false)
    Primitive(Unit) => false
    Primitive(Int) | Primitive(String) => false
    Nominal(symbol, _) =>
      match declarations.checked_enum(symbol) {
        Some(declaration) =>
          declaration.variants.all(fn(variant) {
            self.covers_variant_constructor(declarations, variant)
          })
        None =>
          match declarations.checked_struct(symbol) {
            Some(_) => false
            None => false
          }
      }
    Parameter(_) | Function(_, _) | Forall(_, _) => false
  }
}

///|
fn PatternMatrix::covers_bool_literal(
  self : PatternMatrix,
  value : Bool,
) -> Bool {
  for row in self.rows {
    match row {
      Wildcard(..) | Binding(..) => return true
      BoolLiteral(value=row_value, ..) => if row_value == value { return true }
      _ => ()
    }
  }
  false
}

///|
fn PatternMatrix::covers_int_literal(
  self : PatternMatrix,
  value : String,
) -> Bool {
  for row in self.rows {
    match row {
      Wildcard(..) | Binding(..) => return true
      IntLiteral(value=row_value, ..) => if row_value == value { return true }
      _ => ()
    }
  }
  false
}

///|
fn PatternMatrix::covers_string_literal(
  self : PatternMatrix,
  value : String,
) -> Bool {
  for row in self.rows {
    match row {
      Wildcard(..) | Binding(..) => return true
      StringLiteral(value=row_value, ..) =>
        if row_value == value {
          return true
        }
      _ => ()
    }
  }
  false
}

///|
fn PatternMatrix::covers_variant(
  self : PatternMatrix,
  declarations : CheckedDeclarationEnvironment,
  symbol : VariantSymbolId,
  arguments : Array[@checked.CheckedPattern],
) -> Bool {
  for row in self.rows {
    match row {
      Wildcard(..) | Binding(..) => return true
      Variant(symbol=row_symbol, arguments=row_arguments, ..) =>
        if row_symbol == symbol &&
          variant_arguments_cover(declarations, row_arguments, arguments) {
          return true
        }
      _ => ()
    }
  }
  false
}

///|
fn PatternMatrix::covers_variant_constructor(
  self : PatternMatrix,
  declarations : CheckedDeclarationEnvironment,
  variant : CheckedVariantDeclaration,
) -> Bool {
  for row in self.rows {
    match row {
      Wildcard(..) | Binding(..) => return true
      Variant(symbol~, arguments~, ..) =>
        if symbol == variant.symbol &&
          variant_arguments_irrefutable(declarations, arguments) {
          return true
        }
      _ => ()
    }
  }
  false
}

///|
fn pattern_is_irrefutable(
  declarations : CheckedDeclarationEnvironment,
  pattern : @checked.CheckedPattern,
  type_ : @types.Type,
) -> Bool {
  match pattern {
    Wildcard(..) | Binding(..) => true
    Struct(fields~, ..) =>
      fields.all(fn(field) {
        pattern_is_irrefutable(
          declarations,
          field.pattern,
          field.pattern.type_(),
        )
      })
    Variant(symbol~, arguments~, ..) =>
      if type_ is Nominal(owner, _) {
        match declarations.checked_enum(owner) {
          Some(declaration) =>
            declaration.variants.length() == 1 &&
            declaration.variants[0].symbol == symbol &&
            variant_arguments_irrefutable(declarations, arguments)
          None => false
        }
      } else {
        false
      }
    UnitLiteral(..) | BoolLiteral(..) | IntLiteral(..) | StringLiteral(..) =>
      false
  }
}

///|
fn variant_arguments_cover(
  declarations : CheckedDeclarationEnvironment,
  covered : Array[@checked.CheckedPattern],
  target : Array[@checked.CheckedPattern],
) -> Bool {
  if covered.length() != target.length() {
    return false
  }
  for index in 0..<covered.length() {
    if !pattern_is_irrefutable(
        declarations,
        covered[index],
        target[index].type_(),
      ) &&
      covered[index] != target[index] {
      return false
    }
  }
  true
}

///|
fn variant_arguments_irrefutable(
  declarations : CheckedDeclarationEnvironment,
  arguments : Array[@checked.CheckedPattern],
) -> Bool {
  arguments.all(fn(argument) {
    pattern_is_irrefutable(declarations, argument, argument.type_())
  })
}
