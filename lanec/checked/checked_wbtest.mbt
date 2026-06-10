///|
fn loc() -> SourceSpan {
  SourceSpan::dummy()
}

///|
fn int_type() -> @types.Type {
  Primitive(Int)
}

///|
fn bool_type() -> @types.Type {
  Primitive(Bool)
}

///|
fn function_type(
  parameters : Array[@types.Type],
  result : @types.Type,
) -> @types.Type {
  Function(parameters, result)
}

///|
test "pretty prints checked source without surface-only syntax" {
  let registry = @symbol.SymbolRegistry::SymbolRegistry()
  let x = registry.define_value("x", LocalBinding, loc())
  let increment = registry.define_value("increment", TopLevelFunction, loc())
  let answer = registry.define_value("answer", TopLevelValue, loc())
  let value = CheckedExpr::Value(
    name="x",
    symbol=x,
    type_=int_type(),
    loc=loc(),
  )
  let callee = CheckedExpr::Value(
    name="increment",
    symbol=increment,
    type_=function_type([int_type()], int_type()),
    loc=loc(),
  )
  let call = CheckedExpr::Call(
    callee~,
    arguments=[value],
    type_=int_type(),
    loc=loc(),
  )
  let source = CheckedSourceFile::{
    declarations: [
      Let({
        symbol: answer,
        name: Some("answer"),
        initializer: call,
        type_: int_type(),
        loc: loc(),
      }),
    ],
    loc: loc(),
  }
  inspect(
    @prettyprinter.render(source),
    content=(
      #|checked_source {
      #|  let : Int value#2 answer {
      #|    call : Int {
      #|      callee {
      #|        value : (Int) -> Int value#1 increment
      #|      }
      #|      arguments {
      #|        value : Int value#0 x
      #|      }
      #|    }
      #|  }
      #|}
    ),
  )
}

///|
test "pretty prints checked thunked short circuit call shape" {
  let registry = @symbol.SymbolRegistry::SymbolRegistry()
  let op_and_symbol = registry.define_value("op_and", TopLevelValue, loc())
  let op_and_type = function_type(
    [bool_type(), function_type([], bool_type())],
    bool_type(),
  )
  let op_and = CheckedExpr::Value(
    name="op_and",
    symbol=op_and_symbol,
    type_=op_and_type,
    loc=loc(),
  )
  let left = CheckedExpr::Literal(
    literal=Bool(true),
    type_=bool_type(),
    loc=loc(),
  )
  let right = CheckedExpr::Literal(
    literal=Bool(false),
    type_=bool_type(),
    loc=loc(),
  )
  let thunk = CheckedExpr::FunctionLiteral(
    type_parameters=[],
    parameters=[],
    return_type=bool_type(),
    body=right,
    type_=function_type([], bool_type()),
    loc=loc(),
  )
  let call = CheckedExpr::Call(
    callee=op_and,
    arguments=[left, thunk],
    type_=bool_type(),
    loc=loc(),
  )
  inspect(
    @prettyprinter.render(call),
    content=(
      #|call : Bool {
      #|  callee {
      #|    value : (Bool, () -> Bool) -> Bool value#0 op_and
      #|  }
      #|  arguments {
      #|    bool true : Bool
      #|    fn_literal : () -> Bool {
      #|      parameters {}
      #|      return : Bool
      #|      body {
      #|        bool false : Bool
      #|      }
      #|    }
      #|  }
      #|}
    ),
  )
}

///|
test "pretty prints checked match with resolved patterns" {
  let registry = @symbol.SymbolRegistry::SymbolRegistry()
  let option = registry.define_type("Option", Enum, 1, loc())
  let box = registry.define_type("Box", Struct, 1, loc())
  let some = registry.define_variant(option, "some", 0, 1, loc())
  let field = registry.define_field(box, "value", 0, loc())
  let binder = registry.define_value("x", PatternBinder, loc())
  let scrutinee = registry.define_value("value", Parameter, loc())
  let box_int = @types.Type::Nominal(box, [int_type()])
  let option_box = @types.Type::Nominal(option, [box_int])
  let pattern = CheckedPattern::Variant(
    symbol=some,
    arguments=[
      Struct(
        symbol=box,
        fields=[
          {
            symbol: field,
            name: "value",
            pattern: Binding(
              name="x",
              symbol=binder,
              type_=int_type(),
              loc=loc(),
            ),
            loc: loc(),
          },
        ],
        type_=box_int,
        loc=loc(),
      ),
    ],
    type_=option_box,
    loc=loc(),
  )
  let arm = CheckedMatchArm::{
    pattern,
    body: Value(name="x", symbol=binder, type_=int_type(), loc=loc()),
    loc: loc(),
  }
  let match_expr = CheckedExpr::Match(
    scrutinee=Value(name="value", symbol=scrutinee, type_=option_box, loc=loc()),
    arms=[arm],
    type_=int_type(),
    loc=loc(),
  )
  inspect(
    @prettyprinter.render(match_expr),
    content=(
      #|match : Int {
      #|  scrutinee {
      #|    value : type#0[type#1[Int]] value#1 value
      #|  }
      #|  arms {
      #|    arm {
      #|      pattern {
      #|        variant_pattern : type#0[type#1[Int]] variant#0 {
      #|          struct_pattern : type#1[Int] type#1 {
      #|            field_pattern field#0 value {
      #|              binding : Int value#0 x
      #|            }
      #|          }
      #|        }
      #|      }
      #|      body {
      #|        value : Int value#0 x
      #|      }
      #|    }
      #|  }
      #|}
    ),
  )
}
