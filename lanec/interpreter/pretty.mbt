///|
using @prettyprinter {type Document, space, text}

///|
pub impl @prettyprinter.Pretty for RuntimeValue with fn pretty(
  value : RuntimeValue,
) {
  match value {
    Int(value) => text("int") + space + text(value.to_string())
    Bool(value) => text("bool") + space + text(value.to_string())
    String(value) => text("string") + space + quoted(value)
    Unit => text("unit")
    Struct(symbol~, fields~) =>
      text("struct_value") +
      space +
      symbol.pretty() +
      space +
      @pretty.braced_block(fields.map(RuntimeStructField::pretty))
    Variant(symbol~, arguments~) =>
      text("variant_value") +
      space +
      symbol.pretty() +
      space +
      @pretty.braced_block(arguments.map(RuntimeValue::pretty))
    Closure(function~, environment~) =>
      text("closure") +
      space +
      function.symbol.pretty() +
      space +
      text(function.name) +
      space +
      @pretty.braced_block([
        @pretty.section("environment", [environment.pretty()]),
      ])
    FunctionAtom(function~, environment~) =>
      text("function_atom") +
      space +
      @pretty.braced_block([
        @pretty.section("function", [function.pretty()]),
        @pretty.section("environment", [environment.pretty()]),
      ])
  }
}

///|
pub impl @prettyprinter.Pretty for RuntimeStructField with fn pretty(
  field : RuntimeStructField,
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
impl @prettyprinter.Pretty for RuntimeBinding with fn pretty(
  binding : RuntimeBinding,
) {
  text("value") +
  space +
  binding.symbol.pretty() +
  space +
  @pretty.braced_block([binding.value.pretty()])
}

///|
impl @prettyprinter.Pretty for RuntimeTempBinding with fn pretty(
  binding : RuntimeTempBinding,
) {
  text("temp") +
  space +
  binding.temp.pretty() +
  space +
  @pretty.braced_block([binding.value.pretty()])
}

///|
pub impl @prettyprinter.Pretty for RuntimeEnvironment with fn pretty(
  environment : RuntimeEnvironment,
) {
  text("environment") +
  space +
  @pretty.braced_block([
    @pretty.section("values", environment.values.map(RuntimeBinding::pretty)),
    @pretty.section("temps", environment.temps.map(RuntimeTempBinding::pretty)),
  ])
}

///|
pub impl @prettyprinter.Pretty for RuntimeCallFrame with fn pretty(
  frame : RuntimeCallFrame,
) {
  text("call_frame") +
  space +
  @pretty.braced_block([@pretty.section("locals", [frame.locals.pretty()])])
}

///|
pub impl @prettyprinter.Pretty for RuntimeProgram with fn pretty(
  program : RuntimeProgram,
) {
  text("runtime_program") +
  space +
  @pretty.braced_block([@pretty.section("globals", [program.globals.pretty()])])
}

///|
pub impl @prettyprinter.Pretty for RuntimeError with fn pretty(
  error : RuntimeError,
) {
  match error {
    UnboundValue(symbol) => text("unbound_value") + space + symbol.pretty()
    UnboundTemp(temp) => text("unbound_temp") + space + temp.pretty()
    MissingBuiltin(name~, type_~) =>
      text("missing_builtin") + space + quoted(name) + space + type_.pretty()
    BuiltinFailure(name~, message~) =>
      text("builtin_failure") + space + quoted(name) + space + quoted(message)
    InvalidRuntimeValue(message~) =>
      text("invalid_runtime_value") + space + quoted(message)
  }
}

///|
pub impl @prettyprinter.Pretty for BuslaneRuntimeValue with fn pretty(
  value : BuslaneRuntimeValue,
) {
  match value {
    Int(value) => text("int") + space + text(value.to_string())
    Bool(value) => text("bool") + space + text(value.to_string())
    String(value) => text("string") + space + quoted(value)
    Unit => text("unit")
    Data(data_constructor~, arguments~) =>
      text("data_value") +
      space +
      data_constructor.pretty() +
      space +
      @pretty.braced_block(arguments.map(BuslaneRuntimeValue::pretty))
    Closure(parameters~, environment~, ..) =>
      text("buslane_closure") +
      space +
      @pretty.braced_block([
        @pretty.section("parameters", parameters.map(@buslane.ValueId::pretty)),
        @pretty.section("environment", [environment.pretty()]),
      ])
    TypeClosure(type_parameters~, environment~, ..) =>
      text("buslane_type_closure") +
      space +
      @pretty.braced_block([
        @pretty.section(
          "type_parameters",
          type_parameters.map(@buslane.TypeParameterId::pretty),
        ),
        @pretty.section("environment", [environment.pretty()]),
      ])
    External(id) => text("external_value") + space + id.pretty()
  }
}

///|
impl @prettyprinter.Pretty for BuslaneRuntimeBinding with fn pretty(
  binding : BuslaneRuntimeBinding,
) {
  text("value") +
  space +
  binding.id.pretty() +
  space +
  @pretty.braced_block([binding.value.pretty()])
}

///|
pub impl @prettyprinter.Pretty for BuslaneRuntimeEnvironment with fn pretty(
  environment : BuslaneRuntimeEnvironment,
) {
  text("buslane_environment") +
  space +
  @pretty.braced_block(environment.values.map(BuslaneRuntimeBinding::pretty))
}

///|
pub impl @prettyprinter.Pretty for BuslaneRuntimeProgram with fn pretty(
  program : BuslaneRuntimeProgram,
) {
  text("buslane_runtime_program") +
  space +
  @pretty.braced_block([@pretty.section("globals", [program.globals.pretty()])])
}

///|
pub impl @prettyprinter.Pretty for BuslaneRuntimeError with fn pretty(
  error : BuslaneRuntimeError,
) {
  match error {
    InvalidProgram(diagnostics) =>
      text("invalid_program") +
      space +
      @pretty.braced_block(diagnostics.map(@buslane.VerifyDiagnostic::pretty))
    UnboundValue(id) => text("unbound_value") + space + id.pretty()
    MissingExternal(id) => text("missing_external") + space + id.pretty()
    ExternalFailure(id~, message~) =>
      text("external_failure") + space + id.pretty() + space + quoted(message)
    InvalidValue(message~) => text("invalid_value") + space + quoted(message)
  }
}

///|
fn quoted(value : String) -> Document {
  text("\"") + text(value) + text("\"")
}
