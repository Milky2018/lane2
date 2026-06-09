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
fn string_type() -> @types.Type {
  Primitive(String)
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
test "elaborates pipeline call by prepending the piped value" {
  let registry = @symbol.SymbolRegistry::SymbolRegistry()
  let format = registry.define_value("format", TopLevelFunction, loc())
  let left = CheckedExpr::IntLiteral(value="1", type_=int_type(), loc=loc())
  let rhs = CheckedExpr::Call(
    callee=Value(
      name="format",
      symbol=format,
      type_=function_type([int_type(), bool_type()], string_type()),
      loc=loc(),
    ),
    arguments=[BoolLiteral(value=false, type_=bool_type(), loc=loc())],
    type_=string_type(),
    loc=loc(),
  )
  inspect(
    @prettyprinter.render(elaborate_pipeline_expression(left, rhs, loc())),
    content=(
      #|source_elaboration {
      #|  expression {
      #|    call : String {
      #|      callee {
      #|        value : (Int, Bool) -> String value#0 format
      #|      }
      #|      arguments {
      #|        int 1 : Int
      #|        bool false : Bool
      #|      }
      #|    }
      #|  }
      #|  diagnostics {}
      #|}
    ),
  )
}

///|
test "elaborates pipeline function literal into direct call" {
  let registry = @symbol.SymbolRegistry::SymbolRegistry()
  let value = registry.define_value("value", Parameter, loc())
  let left = CheckedExpr::IntLiteral(value="1", type_=int_type(), loc=loc())
  let rhs = CheckedExpr::FunctionLiteral(
    type_parameters=[],
    parameters=[{ symbol: value, name: "value", type_: int_type(), loc: loc() }],
    return_type=bool_type(),
    body=BoolLiteral(value=true, type_=bool_type(), loc=loc()),
    type_=function_type([int_type()], bool_type()),
    loc=loc(),
  )
  inspect(
    @prettyprinter.render(elaborate_pipeline_expression(left, rhs, loc())),
    content=(
      #|source_elaboration {
      #|  expression {
      #|    call : Bool {
      #|      callee {
      #|        fn_literal : (Int) -> Bool {
      #|          parameters {
      #|            param : Int value#0 value
      #|          }
      #|          return : Bool
      #|          body {
      #|            bool true : Bool
      #|          }
      #|        }
      #|      }
      #|      arguments {
      #|        int 1 : Int
      #|      }
      #|    }
      #|  }
      #|  diagnostics {}
      #|}
    ),
  )
}

///|
test "rejects pipeline rhs that is not call or function literal" {
  let registry = @symbol.SymbolRegistry::SymbolRegistry()
  let f = registry.define_value("f", TopLevelFunction, loc())
  let left = CheckedExpr::IntLiteral(value="1", type_=int_type(), loc=loc())
  let rhs = CheckedExpr::Value(
    name="f",
    symbol=f,
    type_=function_type([int_type()], int_type()),
    loc=loc(),
  )
  inspect(
    @prettyprinter.render(elaborate_pipeline_expression(left, rhs, loc())),
    content=(
      #|source_elaboration {
      #|  expression {
      #|    <none>
      #|  }
      #|  diagnostics {
      #|    invalid_pipeline_rhs
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
  let left = CheckedExpr::BoolLiteral(value=true, type_=bool_type(), loc=loc())
  let right = CheckedExpr::BoolLiteral(
    value=false,
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
