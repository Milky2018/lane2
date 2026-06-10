///|
pub impl @prettyprinter.Pretty for CheckedSourceFile with fn pretty(
  source : CheckedSourceFile,
) {
  text("checked_source") +
  space +
  @pretty.braced_block(
    source.declarations.map(CheckedTopLevelDeclaration::pretty),
  )
}

///|
pub impl @prettyprinter.Pretty for CheckedTopLevelDeclaration with fn pretty(
  declaration : CheckedTopLevelDeclaration,
) {
  match declaration {
    Struct(declaration) => declaration.pretty()
    Enum(declaration) => declaration.pretty()
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
pub impl @prettyprinter.Pretty for CheckedFunctionDeclaration with fn pretty(
  declaration : CheckedFunctionDeclaration,
) {
  typed_header("fn", declaration.type_) +
  space +
  declaration.symbol.pretty() +
  space +
  text(declaration.name) +
  type_parameters_doc(declaration.type_parameters) +
  space +
  @pretty.braced_block([
    @pretty.section(
      "parameters",
      declaration.parameters.map(CheckedValueParameter::pretty),
    ),
    typed_named_doc("return", declaration.return_type),
    @pretty.section("body", [declaration.body.pretty()]),
  ])
}

///|
pub impl @prettyprinter.Pretty for CheckedLetDeclaration with fn pretty(
  declaration : CheckedLetDeclaration,
) {
  let name = match declaration.name {
    Some(name) => text(name)
    None => text("<anonymous>")
  }
  typed_header("let", declaration.type_) +
  space +
  declaration.symbol.pretty() +
  space +
  name +
  space +
  @pretty.braced_block([declaration.initializer.pretty()])
}

///|
pub impl @prettyprinter.Pretty for CheckedValueParameter with fn pretty(
  parameter : CheckedValueParameter,
) {
  typed_header("param", parameter.type_) +
  space +
  parameter.symbol.pretty() +
  space +
  text(parameter.name)
}

///|
pub impl @prettyprinter.Pretty for CheckedLocalItem with fn pretty(
  item : CheckedLocalItem,
) {
  match item {
    Let(declaration) => declaration.pretty()
    Function(declaration) => declaration.pretty()
  }
}

///|
pub impl @prettyprinter.Pretty for CheckedExpr with fn pretty(
  expression : CheckedExpr,
) {
  match expression {
    Literal(literal~, type_~, ..) =>
      typed_named_doc(literal.expression_label(), type_)
    Value(name~, symbol~, type_~, ..) =>
      typed_header("value", type_) +
      space +
      symbol.pretty() +
      space +
      text(name)
    UnsafeBuiltin(name~, type_~, ..) =>
      typed_named_doc("unsafe_builtin " + quoted(name), type_)
    FunctionLiteral(
      type_parameters~,
      parameters~,
      return_type~,
      body~,
      type_~,
      ..
    ) =>
      typed_header("fn_literal", type_) +
      type_parameters_doc(type_parameters) +
      space +
      @pretty.braced_block([
        @pretty.section(
          "parameters",
          parameters.map(CheckedValueParameter::pretty),
        ),
        typed_named_doc("return", return_type),
        @pretty.section("body", [body.pretty()]),
      ])
    TypeApplication(callee~, arguments~, type_~, ..) =>
      typed_header("type_application", type_) +
      type_arguments_doc(arguments) +
      space +
      @pretty.braced_block([@pretty.section("callee", [callee.pretty()])])
    Block(items~, result~, type_~, ..) => {
      let docs = items.map(CheckedLocalItem::pretty)
      docs.push(@pretty.section("result", [result.pretty()]))
      typed_header("block", type_) + space + @pretty.braced_block(docs)
    }
    If(condition~, then_branch~, else_branch~, type_~, ..) =>
      typed_header("if", type_) +
      space +
      @pretty.braced_block([
        @pretty.section("condition", [condition.pretty()]),
        @pretty.section("then", [then_branch.pretty()]),
        @pretty.section("else", [else_branch.pretty()]),
      ])
    Match(scrutinee~, arms~, type_~, ..) =>
      typed_header("match", type_) +
      space +
      @pretty.braced_block([
        @pretty.section("scrutinee", [scrutinee.pretty()]),
        @pretty.section("arms", arms.map(CheckedMatchArm::pretty)),
      ])
    Call(callee~, arguments~, type_~, ..) =>
      typed_header("call", type_) +
      space +
      @pretty.braced_block([
        @pretty.section("callee", [callee.pretty()]),
        @pretty.section("arguments", arguments.map(CheckedExpr::pretty)),
      ])
    Field(base~, field~, name~, type_~, ..) =>
      typed_header("field", type_) +
      space +
      field.pretty() +
      space +
      text(name) +
      space +
      @pretty.braced_block([@pretty.section("base", [base.pretty()])])
    StructLiteral(symbol~, type_arguments~, fields~, type_~, ..) =>
      typed_header("struct", type_) +
      space +
      symbol.pretty() +
      type_arguments_doc(type_arguments) +
      space +
      @pretty.braced_block(fields.map(CheckedStructLiteralField::pretty))
    Variant(symbol~, arguments~, type_~, ..) =>
      typed_header("variant", type_) +
      space +
      symbol.pretty() +
      space +
      @pretty.braced_block(arguments.map(CheckedExpr::pretty))
  }
}

///|
pub impl @prettyprinter.Pretty for CheckedStructLiteralField with fn pretty(
  field : CheckedStructLiteralField,
) {
  text("field") +
  space +
  field.symbol.pretty() +
  space +
  text(field.name) +
  space +
  @pretty.braced_block([field.value.pretty()])
}

///|
pub impl @prettyprinter.Pretty for CheckedMatchArm with fn pretty(
  arm : CheckedMatchArm,
) {
  text("arm") +
  space +
  @pretty.braced_block([
    @pretty.section("pattern", [arm.pattern.pretty()]),
    @pretty.section("body", [arm.body.pretty()]),
  ])
}

///|
pub impl @prettyprinter.Pretty for CheckedPattern with fn pretty(
  pattern : CheckedPattern,
) {
  match pattern {
    Wildcard(type_~, ..) => typed_named_doc("wildcard", type_)
    Binding(name~, symbol~, type_~, ..) =>
      typed_header("binding", type_) +
      space +
      symbol.pretty() +
      space +
      text(name)
    Literal(literal~, type_~, ..) =>
      typed_named_doc(literal.pattern_label(), type_)
    Variant(symbol~, arguments~, type_~, ..) =>
      typed_header("variant_pattern", type_) +
      space +
      symbol.pretty() +
      space +
      @pretty.braced_block(arguments.map(CheckedPattern::pretty))
    Struct(symbol~, fields~, type_~, ..) =>
      typed_header("struct_pattern", type_) +
      space +
      symbol.pretty() +
      space +
      @pretty.braced_block(fields.map(CheckedStructPatternField::pretty))
  }
}

///|
pub impl @prettyprinter.Pretty for CheckedStructPatternField with fn pretty(
  field : CheckedStructPatternField,
) {
  text("field_pattern") +
  space +
  field.symbol.pretty() +
  space +
  text(field.name) +
  space +
  @pretty.braced_block([field.pattern.pretty()])
}

///|
fn CheckedLiteral::expression_label(self : CheckedLiteral) -> String {
  match self {
    Int(literal) => "int " + literal.raw
    String(value) => "string " + quoted(value)
    Bool(value) => "bool " + value.to_string()
    Unit => "unit"
  }
}

///|
fn CheckedLiteral::pattern_label(self : CheckedLiteral) -> String {
  match self {
    Int(literal) => "int_pattern " + literal.raw
    String(value) => "string_pattern " + quoted(value)
    Bool(value) => "bool_pattern " + value.to_string()
    Unit => "unit_pattern"
  }
}

///|
fn typed_header(label : String, type_ : @types.Type) -> Document {
  text(label) + space + text(":") + space + type_.pretty()
}

///|
fn typed_named_doc(label : String, type_ : @types.Type) -> Document {
  typed_header(label, type_)
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
fn type_arguments_doc(arguments : Array[@types.Type]) -> Document {
  if arguments.is_empty() {
    empty
  } else {
    @pretty.bracketed_inline(arguments.map(@types.Type::pretty))
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

///|
fn quoted(value : String) -> String {
  "\"" + value + "\""
}
