///|
enum BuslaneRuntimeValueKind {
  Int(Int64)
  Bool(Bool)
  String(String)
  Unit
  Data(
    data_constructor~ : @buslane.DataConId,
    arguments~ : Array[BuslaneRuntimeValue]
  )
  Closure(
    parameters~ : Array[@buslane.ValueId],
    body~ : @buslane.Expr,
    environment~ : BuslaneRuntimeEnvironment
  )
  TypeClosure(
    type_parameters~ : Array[@buslane.TypeParameterId],
    body~ : @buslane.Expr,
    environment~ : BuslaneRuntimeEnvironment
  )
  External(@buslane.ValueId)
} derive(Debug, Eq)

///|
pub struct BuslaneRuntimeValue {
  priv kind : BuslaneRuntimeValueKind
} derive(Debug, Eq)

///|
struct BuslaneRuntimeBinding {
  id : @buslane.ValueId
  value : BuslaneRuntimeValue
} derive(Debug, Eq)

///|
struct BuslaneRuntimeEnvironment {
  values : Array[BuslaneRuntimeBinding]
} derive(Debug, Eq)

///|
pub struct BuslaneRuntimeProgram {
  priv globals : BuslaneRuntimeEnvironment
} derive(Debug, Eq)

///|
#warnings("-unused_constructor")
pub suberror BuslaneRuntimeError {
  InvalidProgram(Array[@buslane.VerifyDiagnostic])
  UnboundValue(@buslane.ValueId)
  MissingExternal(@buslane.ValueId)
  ExternalFailure(id~ : @buslane.ValueId, message~ : String)
  InvalidValue(message~ : String)
} derive(Debug, Eq)

///|
pub type BuslaneExternalHandler = (@buslane.ValueId, Array[BuslaneRuntimeValue]) -> BuslaneRuntimeValue raise BuslaneRuntimeError

///|
pub struct BuslaneExternalRuntime {
  priv handlers : Array[BuslaneExternalHandler]
}

///|
/// Creates an integer Buslane runtime value.
pub fn BuslaneRuntimeValue::int(value : Int64) -> BuslaneRuntimeValue {
  { kind: Int(value) }
}

///|
/// Creates a boolean Buslane runtime value.
pub fn BuslaneRuntimeValue::bool(value : Bool) -> BuslaneRuntimeValue {
  { kind: Bool(value) }
}

///|
/// Creates a string Buslane runtime value.
pub fn BuslaneRuntimeValue::string(value : String) -> BuslaneRuntimeValue {
  { kind: String(value) }
}

///|
/// Returns the unit Buslane runtime value.
pub fn BuslaneRuntimeValue::unit() -> BuslaneRuntimeValue {
  { kind: Unit }
}

///|
/// Creates a nominal data Buslane runtime value.
pub fn BuslaneRuntimeValue::data(
  data_constructor : @buslane.DataConId,
  arguments : Array[BuslaneRuntimeValue],
) -> BuslaneRuntimeValue {
  { kind: Data(data_constructor~, arguments~) }
}

///|
fn BuslaneRuntimeValue::runtime(
  kind : BuslaneRuntimeValueKind,
) -> BuslaneRuntimeValue {
  { kind, }
}

///|
/// Creates an empty Buslane runtime environment.
fn BuslaneRuntimeEnvironment::BuslaneRuntimeEnvironment() -> BuslaneRuntimeEnvironment {
  { values: [] }
}

///|
/// Creates a runtime program from a global environment.
fn BuslaneRuntimeProgram::BuslaneRuntimeProgram(
  globals : BuslaneRuntimeEnvironment,
) -> BuslaneRuntimeProgram {
  { globals, }
}

///|
/// Creates an external runtime with no handlers.
pub fn BuslaneExternalRuntime::BuslaneExternalRuntime() -> BuslaneExternalRuntime {
  { handlers: [] }
}

///|
/// Adds an external handler. Handlers are tried in insertion order.
pub fn BuslaneExternalRuntime::add_handler(
  self : BuslaneExternalRuntime,
  handler : BuslaneExternalHandler,
) -> Unit {
  self.handlers.push(handler)
}

///|
/// Invokes the first external handler that accepts the value identity.
fn BuslaneExternalRuntime::invoke(
  self : BuslaneExternalRuntime,
  id : @buslane.ValueId,
  arguments : Array[BuslaneRuntimeValue],
) -> BuslaneRuntimeValue raise BuslaneRuntimeError {
  for handler in self.handlers {
    try {
      return handler(id, arguments)
    } catch {
      MissingExternal(_) => ()
      error => raise error
    }
  }
  raise MissingExternal(id)
}

///|
/// Binds a Buslane value identity in this runtime environment.
fn BuslaneRuntimeEnvironment::bind(
  self : BuslaneRuntimeEnvironment,
  id : @buslane.ValueId,
  value : BuslaneRuntimeValue,
) -> Unit {
  self.values.push({ id, value })
}

///|
/// Returns a copy of this runtime environment.
fn BuslaneRuntimeEnvironment::copy(
  self : BuslaneRuntimeEnvironment,
) -> BuslaneRuntimeEnvironment {
  { values: self.values.copy() }
}

///|
/// Looks up a value identity, preferring the latest binding.
fn BuslaneRuntimeEnvironment::lookup(
  self : BuslaneRuntimeEnvironment,
  id : @buslane.ValueId,
) -> BuslaneRuntimeValue raise BuslaneRuntimeError {
  for index = self.values.length() - 1; index >= 0; index = index - 1 {
    let binding = self.values[index]
    if binding.id == id {
      return binding.value
    }
  }
  raise UnboundValue(id)
}

///|
/// Looks up a global value in a runtime program.
pub fn BuslaneRuntimeProgram::lookup(
  self : BuslaneRuntimeProgram,
  id : @buslane.ValueId,
) -> BuslaneRuntimeValue raise BuslaneRuntimeError {
  self.globals.lookup(id)
}
