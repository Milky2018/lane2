///|
using @basic {type SourceSpan}

///|
using @symbol {type SymbolRegistry}

///|
fn loc() -> SourceSpan {
  SourceSpan::dummy()
}

///|
test "pretty runtime nominal values erase existential witnesses" {
  let registry = SymbolRegistry::SymbolRegistry()
  let box = registry.define_type("Box", Struct, 0, loc())
  let value_field = registry.define_field(box, "value", 0, loc())
  let value = RuntimeValue::Struct(symbol=box, fields=[
    { symbol: value_field, name: "value", value: Int(42L) },
  ])
  inspect(
    @prettyprinter.render(value, width=80),
    content=(
      #|struct_value type#0 {
      #|  field field#0 value {
      #|    int 42
      #|  }
      #|}
    ),
  )
}

///|
test "lookup prefers latest runtime binding" {
  let registry = SymbolRegistry::SymbolRegistry()
  let symbol = registry.define_value("answer", LocalBinding, loc())
  let environment = RuntimeEnvironment::RuntimeEnvironment()
  environment.bind_value(symbol, Int(1L))
  environment.bind_value(symbol, Int(2L))
  inspect(
    @prettyprinter.render(environment.lookup_value(symbol), width=80),
    content="int 2",
  )
}

///|
test "builtin runtime delegates to handlers" {
  let runtime = BuiltinRuntime::BuiltinRuntime()
  runtime.add_handler((name, type_, arguments) => {
    guard name == "%answer" else { raise MissingBuiltin(name~, type_~) }
    guard arguments.is_empty() else {
      raise BuiltinFailure(name~, message="expected no arguments")
    }
    Int(42L)
  })
  inspect(
    @prettyprinter.render(
      runtime.invoke("%answer", Primitive(Unit), []),
      width=80,
    ),
    content="int 42",
  )
}

///|
test "pretty runtime errors" {
  inspect(
    @prettyprinter.render(InvalidRuntimeValue(message="not callable")),
    content="invalid_runtime_value \"not callable\"",
  )
}
