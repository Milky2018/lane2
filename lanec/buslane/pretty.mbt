///|
using @prettyprinter {
  type Document,
  char,
  empty,
  line,
  nest,
  separate,
  space,
  surround,
  text,
}

///|
pub impl @prettyprinter.Pretty for TypeId with fn pretty(id : TypeId) {
  text("type#") + text(id.index.to_string())
}

///|
pub impl @prettyprinter.Pretty for TypeParameterId with fn pretty(
  id : TypeParameterId,
) {
  text("tparam#") + text(id.index.to_string())
}

///|
pub impl @prettyprinter.Pretty for ValueId with fn pretty(id : ValueId) {
  text("value#") + text(id.index.to_string())
}

///|
pub impl @prettyprinter.Pretty for DataConId with fn pretty(id : DataConId) {
  text("datacon#") + text(id.index.to_string())
}

///|
pub impl @prettyprinter.Pretty for Kind with fn pretty(kind : Kind) {
  match kind {
    Type => text("Type")
  }
}

///|
pub impl @prettyprinter.Pretty for PrimitiveType with fn pretty(
  primitive : PrimitiveType,
) {
  match primitive {
    Unit => text("Unit")
    Bool => text("Bool")
    Int => text("Int")
    String => text("String")
  }
}

///|
pub impl @prettyprinter.Pretty for Type with fn pretty(type_ : Type) {
  match type_ {
    Primitive(primitive) => primitive.pretty()
    Parameter(parameter) => parameter.pretty()
    Nominal(type_id, arguments) =>
      type_id.pretty() + type_arguments_doc(arguments)
    Function(parameters, result) =>
      @pretty.parenthesized_inline(parameters.map(Type::pretty)) +
      space +
      text("->") +
      space +
      result.pretty()
    Forall(parameters, body) =>
      text("forall") +
      space +
      @pretty.bracketed_inline(parameters.map(TypeParameterId::pretty)) +
      text(".") +
      space +
      body.pretty()
  }
}

///|
pub impl @prettyprinter.Pretty for Literal with fn pretty(literal : Literal) {
  match literal {
    Unit => text("unit")
    Bool(value) => text("bool ") + text(value.to_string())
    Int(value) => text("int ") + text(value.to_string())
    String(value) => text("string ") + quoted(value)
  }
}

///|
pub impl @prettyprinter.Pretty for ValueKind with fn pretty(kind : ValueKind) {
  match kind {
    Function => text("function")
    Value => text("value")
    External => text("external")
    Parameter => text("parameter")
    Local => text("local")
    MatchBinder => text("match_binder")
  }
}

///|
pub impl @prettyprinter.Pretty for TypeInfo with fn pretty(info : TypeInfo) {
  text("type_info") +
  space +
  @pretty.braced_block([
    section_inline("parameters", info.parameters.map(TypeParameterId::pretty)),
    section_inline("constructors", info.constructors.map(DataConId::pretty)),
  ])
}

///|
pub impl @prettyprinter.Pretty for TypeParameterInfo with fn pretty(
  info : TypeParameterInfo,
) {
  text("type_parameter_info") +
  space +
  @pretty.braced_block([text("kind ") + info.kind.pretty()])
}

///|
pub impl @prettyprinter.Pretty for ValueInfo with fn pretty(info : ValueInfo) {
  text("value_info") +
  space +
  @pretty.braced_block([
    text("kind ") + info.kind.pretty(),
    text("type ") + info.type_.pretty(),
  ])
}

///|
pub impl @prettyprinter.Pretty for DataConInfo with fn pretty(
  info : DataConInfo,
) {
  text("datacon_info") +
  space +
  @pretty.braced_block([
    text("owner ") + info.owner.pretty(),
    section_inline(
      "hidden_type_parameters",
      info.hidden_type_parameters.map(TypeParameterId::pretty),
    ),
    section_inline("payload_types", info.payload_types.map(Type::pretty)),
  ])
}

///|
pub impl @prettyprinter.Pretty for MetadataRegistry with fn pretty(
  metadata : MetadataRegistry,
) {
  text("metadata") +
  space +
  @pretty.braced_block([
    indexed_section("types", metadata.types.map(TypeInfo::pretty)),
    indexed_section(
      "type_parameters",
      metadata.type_parameters.map(TypeParameterInfo::pretty),
    ),
    indexed_section("values", metadata.values.map(ValueInfo::pretty)),
    indexed_section(
      "data_constructors",
      metadata.data_constructors.map(DataConInfo::pretty),
    ),
  ])
}

///|
pub impl @prettyprinter.Pretty for Program with fn pretty(program : Program) {
  text("buslane_program") +
  space +
  @pretty.braced_block([
    program.metadata.pretty(),
    @pretty.section("terms", program.terms.map(TopTerm::pretty)),
  ])
}

///|
pub impl @prettyprinter.Pretty for TopTerm with fn pretty(term : TopTerm) {
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
      @pretty.braced_block(bindings.map(RecursiveBinding::pretty))
    External(id) => text("external") + space + id.pretty()
  }
}

///|
pub impl @prettyprinter.Pretty for RecursiveBinding with fn pretty(
  binding : RecursiveBinding,
) {
  text("rec") +
  space +
  binding.id.pretty() +
  space +
  @pretty.braced_block([binding.rhs.pretty()])
}

///|
pub impl @prettyprinter.Pretty for Expr with fn pretty(expr : Expr) {
  match expr {
    Ref(id) => text("ref") + space + id.pretty()
    Literal(literal) => literal.pretty()
    Function(function) => function.pretty()
    Call(callee, arguments) =>
      text("call") +
      space +
      @pretty.braced_block([
        @pretty.section("callee", [callee.pretty()]),
        @pretty.section("arguments", arguments.map(Expr::pretty)),
      ])
    TypeLambda(parameters, body) =>
      text("type_lambda") +
      space +
      @pretty.bracketed_inline(parameters.map(TypeParameterId::pretty)) +
      space +
      @pretty.braced_block([body.pretty()])
    TypeApply(callee, arguments) =>
      text("type_apply") +
      type_arguments_doc(arguments) +
      space +
      @pretty.braced_block([callee.pretty()])
    Construct(construct) => construct.pretty()
    Let(id, initializer, body) =>
      text("let") +
      space +
      id.pretty() +
      space +
      @pretty.braced_block([
        @pretty.section("initializer", [initializer.pretty()]),
        @pretty.section("body", [body.pretty()]),
      ])
    LetRec(bindings, body) =>
      text("letrec") +
      space +
      @pretty.braced_block([
        @pretty.section("bindings", bindings.map(RecursiveBinding::pretty)),
        @pretty.section("body", [body.pretty()]),
      ])
    Match(match_) => match_.pretty()
  }
}

///|
pub impl @prettyprinter.Pretty for FunctionExpr with fn pretty(
  function : FunctionExpr,
) {
  text("fn") +
  space +
  @pretty.braced_block([
    section_inline("parameters", function.parameters.map(ValueId::pretty)),
    text("result ") + function.result_type.pretty(),
    @pretty.section("body", [function.body.pretty()]),
  ])
}

///|
pub impl @prettyprinter.Pretty for ConstructExpr with fn pretty(
  construct : ConstructExpr,
) {
  text("construct") +
  space +
  construct.data_constructor.pretty() +
  type_arguments_doc(construct.type_arguments) +
  hidden_witnesses_doc(construct.hidden_witnesses) +
  space +
  @pretty.braced_block(construct.payloads.map(Expr::pretty))
}

///|
pub impl @prettyprinter.Pretty for MatchExpr with fn pretty(match_ : MatchExpr) {
  text("match") +
  space +
  @pretty.braced_block([
    @pretty.section("scrutinee", [match_.scrutinee.pretty()]),
    text("binder ") + match_.binder.pretty(),
    text("result ") + match_.result_type.pretty(),
    @pretty.section(
      "alternatives",
      match_.alternatives.map(Alternative::pretty),
    ),
  ])
}

///|
pub impl @prettyprinter.Pretty for Alternative with fn pretty(
  alternative : Alternative,
) {
  text("alt") +
  space +
  alternative.alt_constructor.pretty() +
  space +
  @pretty.braced_block([
    section_inline(
      "type_binders",
      alternative.type_binders.map(TypeParameterId::pretty),
    ),
    section_inline(
      "value_binders",
      alternative.value_binders.map(ValueId::pretty),
    ),
    @pretty.section("body", [alternative.body.pretty()]),
  ])
}

///|
pub impl @prettyprinter.Pretty for AltCon with fn pretty(alt : AltCon) {
  match alt {
    Default => text("default")
    Literal(literal) => text("literal ") + literal.pretty()
    DataCon(id) => text("data ") + id.pretty()
  }
}

///|
pub impl @prettyprinter.Pretty for VerifyResult with fn pretty(
  result : VerifyResult,
) {
  text("verify_result") +
  space +
  @pretty.braced_block(result.diagnostics.map(VerifyDiagnostic::pretty))
}

///|
pub impl @prettyprinter.Pretty for VerifyDiagnostic with fn pretty(
  diagnostic : VerifyDiagnostic,
) {
  diagnostic.kind.pretty()
}

///|
pub impl @prettyprinter.Pretty for VerifyDiagnosticKind with fn pretty(
  kind : VerifyDiagnosticKind,
) {
  match kind {
    UnknownType(id) => text("unknown_type") + space + id.pretty()
    UnknownTypeParameter(id) =>
      text("unknown_type_parameter") + space + id.pretty()
    UnknownValue(id) => text("unknown_value") + space + id.pretty()
    UnknownDataConstructor(id) =>
      text("unknown_data_constructor") + space + id.pretty()
    TypeMismatch(expected~, actual~) =>
      text("type_mismatch") +
      space +
      @pretty.braced_block([
        text("expected ") + expected.pretty(),
        text("actual ") + actual.pretty(),
      ])
    NotFunction(type_) => text("not_function") + space + type_.pretty()
    NotForall(type_) => text("not_forall") + space + type_.pretty()
    ArityMismatch(expected~, actual~) =>
      text("arity_mismatch") +
      space +
      @pretty.braced_block([
        text("expected ") + text(expected.to_string()),
        text("actual ") + text(actual.to_string()),
      ])
    InvalidExternal(id) => text("invalid_external") + space + id.pretty()
    InvalidLetRecRhs(id) => text("invalid_letrec_rhs") + space + id.pretty()
    InvalidAlternativeBinderCount => text("invalid_alternative_binder_count")
    DuplicateDefaultAlternative => text("duplicate_default_alternative")
    DefaultAlternativeNotLast => text("default_alternative_not_last")
    DuplicateAlternative => text("duplicate_alternative")
    NonExhaustiveMatch => text("non_exhaustive_match")
  }
}

///|
fn type_arguments_doc(arguments : Array[Type]) -> Document {
  if arguments.is_empty() {
    empty
  } else {
    @pretty.bracketed_inline(arguments.map(Type::pretty))
  }
}

///|
fn hidden_witnesses_doc(witnesses : Array[Type]) -> Document {
  if witnesses.is_empty() {
    empty
  } else {
    text(" exists") + @pretty.bracketed_inline(witnesses.map(Type::pretty))
  }
}

///|
fn section_inline(label : String, docs : Array[Document]) -> Document {
  text(label) + space + @pretty.bracketed_inline(docs)
}

///|
fn indexed_section(label : String, docs : Array[Document]) -> Document {
  text(label) + space + braced_block(docs)
}

///|
fn braced_block(docs : Array[Document]) -> Document {
  if docs.is_empty() {
    surround(char('{'), char('}'), empty)
  } else {
    surround(char('{'), line + char('}'), nest(line + separate(line, docs)))
  }
}

///|
fn quoted(value : String) -> Document {
  text("\"") + text(value) + text("\"")
}
