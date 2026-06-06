///|
pub impl @prettyprinter.Pretty for CheckResult with fn pretty(
  result : CheckResult,
) {
  text("check_result") +
  space +
  @pretty.braced_block([
    result.declarations.pretty(),
    @pretty.section(
      "diagnostics",
      result.diagnostics.map(CheckDiagnostic::pretty),
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
pub impl @prettyprinter.Pretty for CheckedTypeDeclaration with fn pretty(
  declaration : CheckedTypeDeclaration,
) {
  match declaration {
    Struct(declaration) => declaration.pretty()
    Enum(declaration) => declaration.pretty()
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
pub impl @prettyprinter.Pretty for CheckDiagnostic with fn pretty(
  diagnostic : CheckDiagnostic,
) {
  diagnostic.kind.pretty()
}

///|
pub impl @prettyprinter.Pretty for CheckDiagnosticKind with fn pretty(
  kind : CheckDiagnosticKind,
) {
  match kind {
    UnresolvedType(name) => text("unresolved_type") + space + text(name)
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
