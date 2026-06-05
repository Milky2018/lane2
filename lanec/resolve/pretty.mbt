///|
pub impl @prettyprinter.Pretty for ResolvedSourceFile with fn pretty(
  source : ResolvedSourceFile,
) {
  text("resolved") +
  space +
  @pretty.braced_block([
    source.symbols.pretty(),
    @pretty.section(
      "declarations",
      source.declarations.map(ResolvedTopLevelDeclaration::pretty),
    ),
  ])
}

///|
pub impl @prettyprinter.Pretty for ResolvedTopLevelDeclaration with fn pretty(
  declaration : ResolvedTopLevelDeclaration,
) {
  match declaration {
    Struct(declaration) => declaration.pretty()
    Enum(declaration) => declaration.pretty()
    Function(declaration) => declaration.pretty()
    Let(declaration) => declaration.pretty()
    Open(declaration) => declaration.pretty()
  }
}

///|
pub impl @prettyprinter.Pretty for ResolvedStructDeclaration with fn pretty(
  declaration : ResolvedStructDeclaration,
) {
  text("struct") +
  space +
  declaration.symbol.pretty() +
  space +
  text(declaration.name) +
  type_parameters_doc(declaration.type_parameters) +
  space +
  @pretty.braced_block(declaration.members.map(ResolvedStructMember::pretty))
}

///|
pub impl @prettyprinter.Pretty for ResolvedStructMember with fn pretty(
  item : ResolvedStructMember,
) {
  match item {
    Field(field) => field.pretty()
    Open(open) => open.pretty()
  }
}

///|
pub impl @prettyprinter.Pretty for ResolvedFieldDeclaration with fn pretty(
  field : ResolvedFieldDeclaration,
) {
  text("field") +
  space +
  field.symbol.pretty() +
  space +
  text(field.name) +
  space +
  text("index=") +
  text(field.index.to_string())
}

///|
pub impl @prettyprinter.Pretty for ResolvedEnumDeclaration with fn pretty(
  declaration : ResolvedEnumDeclaration,
) {
  text("enum") +
  space +
  declaration.symbol.pretty() +
  space +
  text(declaration.name) +
  type_parameters_doc(declaration.type_parameters) +
  space +
  @pretty.braced_block(declaration.variants.map(ResolvedEnumVariant::pretty))
}

///|
pub impl @prettyprinter.Pretty for ResolvedEnumVariant with fn pretty(
  variant : ResolvedEnumVariant,
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
  text(variant.payload_count.to_string())
}

///|
pub impl @prettyprinter.Pretty for ResolvedFunctionDeclaration with fn pretty(
  declaration : ResolvedFunctionDeclaration,
) {
  text("fn") +
  space +
  declaration.symbol.pretty() +
  space +
  text(declaration.name) +
  type_parameters_doc(declaration.type_parameters) +
  parameters_doc(declaration.parameters)
}

///|
pub impl @prettyprinter.Pretty for ResolvedLetDeclaration with fn pretty(
  declaration : ResolvedLetDeclaration,
) {
  let name = match declaration.name {
    Some(name) => text(name)
    None => text("<anonymous>")
  }
  text("let") + space + declaration.symbol.pretty() + space + name
}

///|
pub impl @prettyprinter.Pretty for ResolvedOpenDeclaration with fn pretty(
  declaration : ResolvedOpenDeclaration,
) {
  text("open") + space + text(declaration.name)
}

///|
pub impl @prettyprinter.Pretty for ResolvedTypeParameter with fn pretty(
  parameter : ResolvedTypeParameter,
) {
  parameter.symbol.pretty() + space + text(parameter.name)
}

///|
pub impl @prettyprinter.Pretty for ResolvedValueParameter with fn pretty(
  parameter : ResolvedValueParameter,
) {
  parameter.symbol.pretty() + space + text(parameter.name)
}

///|
fn type_parameters_doc(parameters : Array[ResolvedTypeParameter]) -> Document {
  if parameters.is_empty() {
    empty
  } else {
    @pretty.bracketed_inline(parameters.map(ResolvedTypeParameter::pretty))
  }
}

///|
fn parameters_doc(parameters : Array[ResolvedValueParameter]) -> Document {
  @pretty.parenthesized_inline(parameters.map(ResolvedValueParameter::pretty))
}
