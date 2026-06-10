///|
pub impl @prettyprinter.Pretty for DeclarationTypeCheckResult with fn pretty(
  result : DeclarationTypeCheckResult,
) {
  text("declaration_typecheck_result") +
  space +
  @pretty.braced_block([
    result.declarations.pretty(),
    @pretty.section(
      "diagnostics",
      result.diagnostics.map(TypeCheckDiagnostic::pretty),
    ),
  ])
}

///|
pub impl @prettyprinter.Pretty for TypeCheckResult with fn pretty(
  source : TypeCheckResult,
) {
  text("typecheck_result") +
  space +
  @pretty.braced_block([
    source.declarations.pretty(),
    source.values.pretty(),
    @pretty.section(
      "diagnostics",
      source.diagnostics.map(TypeCheckDiagnostic::pretty),
    ),
  ])
}

///|
pub impl @prettyprinter.Pretty for CheckedDeclarationEnvironment with fn pretty(
  environment : CheckedDeclarationEnvironment,
) {
  text("checked_declarations") +
  space +
  @pretty.braced_block([
    @pretty.section(
      "types",
      environment.types.map(CheckedTypeDeclaration::pretty),
    ),
    @pretty.section(
      "fields",
      environment.fields.map(CheckedFieldDeclaration::pretty),
    ),
    @pretty.section(
      "variants",
      environment.variants.map(CheckedVariantDeclaration::pretty),
    ),
  ])
}

///|
pub impl @prettyprinter.Pretty for CheckedValueEnvironment with fn pretty(
  environment : CheckedValueEnvironment,
) {
  text("checked_values") +
  space +
  @pretty.braced_block(environment.values.map(CheckedValueDeclaration::pretty))
}

///|
pub impl @prettyprinter.Pretty for CheckedTypeDeclaration with fn pretty(
  declaration : CheckedTypeDeclaration,
) {
  match declaration {
    Struct(declaration) => declaration.pretty()
    Enum(declaration) => declaration.pretty()
  }
}

///|
pub impl @prettyprinter.Pretty for CheckedValueDeclaration with fn pretty(
  declaration : CheckedValueDeclaration,
) {
  match declaration {
    Function(declaration) => declaration.pretty()
    Let(declaration) => declaration.pretty()
  }
}

///|
pub impl @prettyprinter.Pretty for CheckedStructDeclaration with fn pretty(
  declaration : CheckedStructDeclaration,
) {
  text("struct") +
  space +
  declaration.symbol.pretty() +
  space +
  text(declaration.name) +
  type_parameters_doc(declaration.type_parameters) +
  space +
  @pretty.braced_block(declaration.fields.map(CheckedFieldDeclaration::pretty))
}

///|
pub impl @prettyprinter.Pretty for CheckedFunctionDeclaration with fn pretty(
  declaration : CheckedFunctionDeclaration,
) {
  text("fn") +
  space +
  declaration.symbol.pretty() +
  space +
  text(declaration.name) +
  space +
  text(":") +
  space +
  declaration.type_.pretty()
}

///|
pub impl @prettyprinter.Pretty for CheckedLetDeclaration with fn pretty(
  declaration : CheckedLetDeclaration,
) {
  let name = match declaration.name {
    Some(name) => text(name)
    None => text("<anonymous>")
  }
  text("let") +
  space +
  declaration.symbol.pretty() +
  space +
  name +
  space +
  text(":") +
  space +
  declaration.type_.pretty()
}

///|
pub impl @prettyprinter.Pretty for CheckedFieldDeclaration with fn pretty(
  field : CheckedFieldDeclaration,
) {
  text("field") +
  space +
  field.symbol.pretty() +
  space +
  text(field.name) +
  space +
  text(":") +
  space +
  field.type_.pretty() +
  space +
  text("index=") +
  text(field.index.to_string())
}

///|
pub impl @prettyprinter.Pretty for CheckedEnumDeclaration with fn pretty(
  declaration : CheckedEnumDeclaration,
) {
  text("enum") +
  space +
  declaration.symbol.pretty() +
  space +
  text(declaration.name) +
  type_parameters_doc(declaration.type_parameters) +
  space +
  @pretty.braced_block(
    declaration.variants.map(CheckedVariantDeclaration::pretty),
  )
}

///|
pub impl @prettyprinter.Pretty for CheckedVariantDeclaration with fn pretty(
  variant : CheckedVariantDeclaration,
) {
  text("variant") +
  space +
  variant.symbol.pretty() +
  space +
  text(variant.name) +
  space +
  text("index=") +
  text(variant.index.to_string()) +
  space +
  text("payloads=") +
  text(variant.payload.length().to_string()) +
  payload_doc(variant.payload)
}

///|
pub impl @prettyprinter.Pretty for TypeCheckDiagnostic with fn pretty(
  diagnostic : TypeCheckDiagnostic,
) {
  diagnostic.kind.pretty() +
  space +
  text("@") +
  space +
  @pretty.source_span(diagnostic.loc)
}

///|
pub impl @prettyprinter.Pretty for TypeCheckDiagnosticKind with fn pretty(
  kind : TypeCheckDiagnosticKind,
) {
  match kind {
    UnresolvedType(name) => text("unresolved_type") + space + text(name)
    UnresolvedValue(name) => text("unresolved_value") + space + text(name)
    MissingTopLevelLetAnnotation => text("missing_top_level_let_annotation")
    TypeArgumentArityMismatch(name~, expected~, actual~) =>
      text("type_arity_mismatch") +
      space +
      text(name) +
      space +
      text("expected=") +
      text(expected.to_string()) +
      space +
      text("actual=") +
      text(actual.to_string())
    TypeMismatch(expected~, actual~) =>
      text("type_mismatch") +
      space +
      text("expected=") +
      expected.pretty() +
      space +
      text("actual=") +
      actual.pretty()
    NotCallable(type_) => text("not_callable") + space + type_.pretty()
    UnknownField(name~) => text("unknown_field") + space + text(name)
    MissingField(name~) => text("missing_field") + space + text(name)
    DuplicateField(name~) => text("duplicate_field") + space + text(name)
    NotAStruct(type_) => text("not_a_struct") + space + type_.pretty()
    NonExhaustiveMatch(type_) =>
      text("non_exhaustive_match") + space + type_.pretty()
    UnreachableMatchArm => text("unreachable_match_arm")
    DuplicatePatternBinder(name~) =>
      text("duplicate_pattern_binder") + space + text(name)
    PatternArityMismatch(name~, expected~, actual~) =>
      text("pattern_arity_mismatch") +
      space +
      text(name) +
      space +
      text("expected=") +
      text(expected.to_string()) +
      space +
      text("actual=") +
      text(actual.to_string())
    InvalidIntLiteral(raw) => text("invalid_int_literal") + space + text(raw)
    CannotInferExpression(label) => text("cannot_infer") + space + text(label)
  }
}

///|
fn type_parameters_doc(parameters : Array[@types.TypeParameter]) -> Document {
  if parameters.is_empty() {
    empty
  } else {
    @pretty.bracketed_inline(parameters.map(@types.TypeParameter::pretty))
  }
}

///|
fn payload_doc(payload : Array[@types.Type]) -> Document {
  if payload.is_empty() {
    empty
  } else {
    @pretty.parenthesized_inline(payload.map(@types.Type::pretty))
  }
}
