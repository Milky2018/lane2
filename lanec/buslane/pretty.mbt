///|
using @prettyprinter {type Document, empty, space, text}

///|
pub impl @prettyprinter.Pretty for BuslaneProgram with fn pretty(
  program : BuslaneProgram,
) {
  text("buslane_program") +
  space +
  @pretty.braced_block(
    program.declarations.map(BuslaneTopLevelDeclaration::pretty),
  )
}

///|
pub impl @prettyprinter.Pretty for BuslaneTopLevelDeclaration with fn pretty(
  declaration : BuslaneTopLevelDeclaration,
) {
  match declaration {
    Struct(declaration) => declaration.pretty()
    Enum(declaration) => declaration.pretty()
    Function(declaration) => declaration.pretty()
    Let(declaration) => declaration.pretty()
  }
}

///|
pub impl @prettyprinter.Pretty for BuslaneFunctionDeclaration with fn pretty(
  declaration : BuslaneFunctionDeclaration,
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
      declaration.parameters.map(@checked.CheckedValueParameter::pretty),
    ),
    typed_named_doc("return", declaration.return_type),
    @pretty.section("body", [declaration.body.pretty()]),
  ])
}

///|
pub impl @prettyprinter.Pretty for BuslaneLetDeclaration with fn pretty(
  declaration : BuslaneLetDeclaration,
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
  @pretty.braced_block([declaration.value.pretty()])
}

///|
pub impl @prettyprinter.Pretty for BuslaneBinding with fn pretty(
  binding : BuslaneBinding,
) {
  match binding {
    Value(symbol~, name~, value~, type_~, ..) => {
      let name_doc = match name {
        Some(name) => text(name)
        None => text("<anonymous>")
      }
      typed_header("binding", type_) +
      space +
      symbol.pretty() +
      space +
      name_doc +
      space +
      @pretty.braced_block([value.pretty()])
    }
    Pattern(pattern~, initializer~, ..) =>
      text("pattern_binding") +
      space +
      @pretty.braced_block([
        @pretty.section("pattern", [pattern.pretty()]),
        @pretty.section("initializer", [initializer.pretty()]),
      ])
  }
}

///|
pub impl @prettyprinter.Pretty for BuslaneExpr with fn pretty(
  expression : BuslaneExpr,
) {
  match expression {
    Literal(literal~, type_~, ..) =>
      typed_named_doc(literal_label(literal), type_)
    Value(name~, symbol~, type_~, ..) =>
      typed_header("value", type_) +
      space +
      symbol.pretty() +
      space +
      text(name)
    UnsafeBuiltin(name~, type_~, ..) =>
      typed_named_doc("unsafe_builtin " + quoted(name), type_)
    Function(parameters~, body~, type_~, ..) =>
      typed_header("fn_value", type_) +
      space +
      @pretty.braced_block([
        @pretty.section(
          "parameters",
          parameters.map(@checked.CheckedValueParameter::pretty),
        ),
        @pretty.section("body", [body.pretty()]),
      ])
    TypeLambda(type_parameters~, body~, type_~, ..) =>
      typed_header("type_lambda", type_) +
      type_parameters_doc(type_parameters) +
      space +
      @pretty.braced_block([@pretty.section("body", [body.pretty()])])
    TypeApplication(callee~, arguments~, type_~, ..) =>
      typed_header("type_application", type_) +
      type_arguments_doc(arguments) +
      space +
      @pretty.braced_block([@pretty.section("callee", [callee.pretty()])])
    Let(binding~, body~, type_~, ..) =>
      typed_header("let", type_) +
      space +
      @pretty.braced_block([
        @pretty.section("binding", [binding.pretty()]),
        @pretty.section("body", [body.pretty()]),
      ])
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
        @pretty.section("arms", arms.map(BuslaneMatchArm::pretty)),
      ])
    Call(callee~, arguments~, type_~, ..) =>
      typed_header("call", type_) +
      space +
      @pretty.braced_block([
        @pretty.section("callee", [callee.pretty()]),
        @pretty.section("arguments", arguments.map(BuslaneExpr::pretty)),
      ])
    Field(base~, field~, name~, type_~, ..) =>
      typed_header("field", type_) +
      space +
      field.pretty() +
      space +
      text(name) +
      space +
      @pretty.braced_block([@pretty.section("base", [base.pretty()])])
    Struct(symbol~, type_arguments~, type_witnesses~, fields~, type_~, ..) =>
      typed_header("struct", type_) +
      space +
      symbol.pretty() +
      type_arguments_doc(type_arguments) +
      space +
      @pretty.braced_block(
        type_witnesses.map(@checked.CheckedStructTypeWitness::pretty) +
        fields.map(BuslaneStructField::pretty),
      )
    Variant(symbol~, type_arguments~, arguments~, type_~, ..) =>
      typed_header("variant", type_) +
      space +
      symbol.pretty() +
      type_arguments_doc(type_arguments) +
      space +
      @pretty.braced_block(arguments.map(BuslaneExpr::pretty))
  }
}

///|
pub impl @prettyprinter.Pretty for BuslaneStructField with fn pretty(
  field : BuslaneStructField,
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
pub impl @prettyprinter.Pretty for BuslaneMatchArm with fn pretty(
  arm : BuslaneMatchArm,
) {
  text("arm") +
  space +
  @pretty.braced_block([
    @pretty.section("pattern", [arm.pattern.pretty()]),
    @pretty.section("body", [arm.body.pretty()]),
  ])
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
fn literal_label(literal : @checked.CheckedLiteral) -> String {
  match literal {
    Int(literal) => "int " + literal.raw
    String(value) => "string " + quoted(value)
    Bool(value) => "bool " + value.to_string()
    Unit => "unit"
  }
}

///|
fn quoted(value : String) -> String {
  "\"" + value + "\""
}
