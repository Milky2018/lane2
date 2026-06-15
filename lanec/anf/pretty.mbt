///|
using @prettyprinter {type Document, empty, space, text}

///|
pub impl @prettyprinter.Pretty for AnfProgram with fn pretty(
  program : AnfProgram,
) {
  text("anf_program") +
  space +
  @pretty.braced_block(program.declarations.map(AnfTopLevelDeclaration::pretty))
}

///|
pub impl @prettyprinter.Pretty for AnfTopLevelDeclaration with fn pretty(
  declaration : AnfTopLevelDeclaration,
) {
  match declaration {
    Struct(declaration) => declaration.pretty()
    Enum(declaration) => declaration.pretty()
    Function(declaration) => declaration.pretty()
    Let(declaration) => declaration.pretty()
  }
}

///|
pub impl @prettyprinter.Pretty for AnfFunctionDeclaration with fn pretty(
  declaration : AnfFunctionDeclaration,
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
pub impl @prettyprinter.Pretty for AnfLetDeclaration with fn pretty(
  declaration : AnfLetDeclaration,
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
pub impl @prettyprinter.Pretty for AnfExpr with fn pretty(expr : AnfExpr) {
  match expr {
    Atom(atom~, type_~, ..) =>
      typed_header("atom", type_) +
      space +
      @pretty.braced_block([atom.pretty()])
    Let(binding~, body~, type_~, ..) =>
      typed_header("let_expr", type_) +
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
        @pretty.section("arms", arms.map(AnfMatchArm::pretty)),
      ])
  }
}

///|
pub impl @prettyprinter.Pretty for AnfBinding with fn pretty(
  binding : AnfBinding,
) {
  match binding {
    Value(symbol~, name~, rhs~, type_~, ..) => {
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
      @pretty.braced_block([rhs.pretty()])
    }
    Temp(temp~, rhs~, type_~, ..) =>
      typed_header("temp_binding", type_) +
      space +
      temp.pretty() +
      space +
      @pretty.braced_block([rhs.pretty()])
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
pub impl @prettyprinter.Pretty for AnfRhs with fn pretty(rhs : AnfRhs) {
  match rhs {
    Atom(atom) => atom.pretty()
    Call(callee~, arguments~, type_~, ..) =>
      typed_header("call", type_) +
      space +
      @pretty.braced_block([
        @pretty.section("callee", [callee.pretty()]),
        @pretty.section("arguments", arguments.map(AnfAtom::pretty)),
      ])
    TypeApplication(callee~, arguments~, type_~, ..) =>
      typed_header("type_application", type_) +
      type_arguments_doc(arguments) +
      space +
      @pretty.braced_block([@pretty.section("callee", [callee.pretty()])])
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
        fields.map(AnfStructField::pretty),
      )
    Variant(symbol~, type_arguments~, arguments~, type_~, ..) =>
      typed_header("variant", type_) +
      space +
      symbol.pretty() +
      type_arguments_doc(type_arguments) +
      space +
      @pretty.braced_block(arguments.map(AnfAtom::pretty))
  }
}

///|
pub impl @prettyprinter.Pretty for AnfStructField with fn pretty(
  field : AnfStructField,
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
pub impl @prettyprinter.Pretty for AnfAtom with fn pretty(atom : AnfAtom) {
  match atom {
    Literal(literal~, type_~, ..) =>
      typed_named_doc(literal_label(literal), type_)
    Value(name~, symbol~, type_~, ..) =>
      typed_header("value", type_) +
      space +
      symbol.pretty() +
      space +
      text(name)
    Temp(temp~, type_~, ..) =>
      typed_header("temp", type_) + space + temp.pretty()
    UnsafeBuiltin(name~, type_~, ..) =>
      typed_named_doc("unsafe_builtin " + quoted(name), type_)
    Function(parameters~, body~, type_~, ..) =>
      typed_header("fn_atom", type_) +
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
  }
}

///|
pub impl @prettyprinter.Pretty for AnfMatchArm with fn pretty(arm : AnfMatchArm) {
  text("arm") +
  space +
  @pretty.braced_block([
    @pretty.section("pattern", [arm.pattern.pretty()]),
    @pretty.section("body", [arm.body.pretty()]),
  ])
}

///|
pub impl @prettyprinter.Pretty for AnfTempId with fn pretty(id : AnfTempId) {
  text("temp#") + text(id.index.to_string())
}

///|
pub impl @prettyprinter.Pretty for BuslaneAnfProgram with fn pretty(
  program : BuslaneAnfProgram,
) {
  text("buslane_anf_program") +
  space +
  @pretty.braced_block(program.terms.map(BuslaneAnfTopTerm::pretty))
}

///|
pub impl @prettyprinter.Pretty for BuslaneAnfTopTerm with fn pretty(
  term : BuslaneAnfTopTerm,
) {
  match term {
    Let(id, expr) =>
      text("top_let") +
      space +
      id.pretty() +
      space +
      @pretty.braced_block([expr.pretty()])
    LetRec(bindings) =>
      text("top_letrec") +
      space +
      @pretty.braced_block(bindings.map(BuslaneAnfRecursiveBinding::pretty))
    External(id) => text("external") + space + id.pretty()
  }
}

///|
pub impl @prettyprinter.Pretty for BuslaneAnfRecursiveBinding with fn pretty(
  binding : BuslaneAnfRecursiveBinding,
) {
  text("rec") +
  space +
  binding.id.pretty() +
  space +
  @pretty.braced_block([binding.rhs.pretty()])
}

///|
pub impl @prettyprinter.Pretty for BuslaneAnfExpr with fn pretty(
  expr : BuslaneAnfExpr,
) {
  match expr {
    Atom(atom) => text("atom") + space + @pretty.braced_block([atom.pretty()])
    Let(binding, body) =>
      text("let_expr") +
      space +
      @pretty.braced_block([
        @pretty.section("binding", [binding.pretty()]),
        @pretty.section("body", [body.pretty()]),
      ])
    LetRec(bindings, body) =>
      text("letrec_expr") +
      space +
      @pretty.braced_block([
        @pretty.section(
          "bindings",
          bindings.map(BuslaneAnfRecursiveBinding::pretty),
        ),
        @pretty.section("body", [body.pretty()]),
      ])
    Match(match_) => match_.pretty()
  }
}

///|
pub impl @prettyprinter.Pretty for BuslaneAnfBinding with fn pretty(
  binding : BuslaneAnfBinding,
) {
  match binding {
    Value(id~, rhs~) =>
      text("value_binding") +
      space +
      id.pretty() +
      space +
      @pretty.braced_block([rhs.pretty()])
    Temp(temp~, rhs~) =>
      text("temp_binding") +
      space +
      temp.pretty() +
      space +
      @pretty.braced_block([rhs.pretty()])
  }
}

///|
pub impl @prettyprinter.Pretty for BuslaneAnfRhs with fn pretty(
  rhs : BuslaneAnfRhs,
) {
  match rhs {
    Atom(atom) => atom.pretty()
    Call(callee~, arguments~) =>
      text("call") +
      space +
      @pretty.braced_block([
        @pretty.section("callee", [callee.pretty()]),
        @pretty.section("arguments", arguments.map(BuslaneAnfAtom::pretty)),
      ])
    TypeApply(callee~, arguments~) =>
      text("type_apply") +
      buslane_type_arguments_doc(arguments) +
      space +
      @pretty.braced_block([@pretty.section("callee", [callee.pretty()])])
    Construct(construct) => construct.pretty()
  }
}

///|
pub impl @prettyprinter.Pretty for BuslaneAnfConstruct with fn pretty(
  construct : BuslaneAnfConstruct,
) {
  text("construct") +
  space +
  construct.data_constructor.pretty() +
  buslane_type_arguments_doc(construct.type_arguments) +
  buslane_hidden_witnesses_doc(construct.hidden_witnesses) +
  space +
  @pretty.braced_block(construct.payloads.map(BuslaneAnfAtom::pretty))
}

///|
pub impl @prettyprinter.Pretty for BuslaneAnfAtom with fn pretty(
  atom : BuslaneAnfAtom,
) {
  match atom {
    Literal(literal) => literal.pretty()
    Ref(id) => text("ref") + space + id.pretty()
    Temp(temp) => text("temp") + space + temp.pretty()
    Function(function) => function.pretty()
    TypeLambda(type_parameters~, body~) =>
      text("type_lambda") +
      space +
      @pretty.bracketed_inline(
        type_parameters.map(@buslane.TypeParameterId::pretty),
      ) +
      space +
      @pretty.braced_block([body.pretty()])
  }
}

///|
pub impl @prettyprinter.Pretty for BuslaneAnfFunction with fn pretty(
  function : BuslaneAnfFunction,
) {
  text("fn") +
  space +
  @pretty.braced_block([
    text("parameters") +
    space +
    @pretty.bracketed_inline(function.parameters.map(@buslane.ValueId::pretty)),
    text("result") + space + function.result_type.pretty(),
    @pretty.section("body", [function.body.pretty()]),
  ])
}

///|
pub impl @prettyprinter.Pretty for BuslaneAnfMatch with fn pretty(
  match_ : BuslaneAnfMatch,
) {
  text("match") +
  space +
  @pretty.braced_block([
    @pretty.section("scrutinee", [match_.scrutinee.pretty()]),
    text("binder") + space + match_.binder.pretty(),
    text("result") + space + match_.result_type.pretty(),
    @pretty.section(
      "alternatives",
      match_.alternatives.map(BuslaneAnfAlternative::pretty),
    ),
  ])
}

///|
pub impl @prettyprinter.Pretty for BuslaneAnfAlternative with fn pretty(
  alternative : BuslaneAnfAlternative,
) {
  text("alt") +
  space +
  alternative.alt_constructor.pretty() +
  space +
  @pretty.braced_block([
    text("type_binders") +
    space +
    @pretty.bracketed_inline(
      alternative.type_binders.map(@buslane.TypeParameterId::pretty),
    ),
    text("value_binders") +
    space +
    @pretty.bracketed_inline(
      alternative.value_binders.map(@buslane.ValueId::pretty),
    ),
    @pretty.section("body", [alternative.body.pretty()]),
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
fn buslane_type_arguments_doc(arguments : Array[@buslane.Type]) -> Document {
  if arguments.is_empty() {
    empty
  } else {
    @pretty.bracketed_inline(arguments.map(@buslane.Type::pretty))
  }
}

///|
fn buslane_hidden_witnesses_doc(arguments : Array[@buslane.Type]) -> Document {
  if arguments.is_empty() {
    empty
  } else {
    text(" exists") +
    @pretty.bracketed_inline(arguments.map(@buslane.Type::pretty))
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
