///|
fn loc() -> SourceSpan {
  SourceSpan::dummy()
}

///|
fn hide_type(symbol : TypeSymbolId) -> @types.Type {
  Nominal(symbol, [])
}

///|
test "pretty prints typed core existential package and opening" {
  let registry = @symbol.SymbolRegistry::SymbolRegistry()
  let hide = registry.define_type("Hide", Struct, 0, loc())
  let member_parameter = registry.define_type_parameter("T", loc())
  let type_member = registry.define_type_member(
    hide,
    "T",
    0,
    member_parameter,
    loc(),
  )
  let field = registry.define_field(hide, "val", 0, loc())
  let repack = registry.define_value("repack", TopLevelFunction, loc())
  let input = registry.define_value("h", Parameter, loc())
  let opened_parameter = registry.define_type_parameter("T", loc())
  let binder = registry.define_value("val", PatternBinder, loc())
  let packed = registry.define_value("packed", LocalBinding, loc())
  let hide_type = hide_type(hide)
  let opened_type = @types.Type::Parameter(opened_parameter)
  let pattern = @checked.CheckedPattern::Struct(
    symbol=hide,
    type_binders=[
      {
        symbol: type_member,
        type_parameter: Some({ id: opened_parameter, name: "T", kind: Type }),
        name: Some("T"),
        loc: loc(),
      },
    ],
    fields=[
      {
        symbol: field,
        name: "val",
        pattern: Binding(
          name="val",
          symbol=binder,
          type_=opened_type,
          loc=loc(),
        ),
        loc: loc(),
      },
    ],
    type_=hide_type,
    loc=loc(),
  )
  let initializer = CoreAtom::Value(
    name="h",
    symbol=input,
    type_=hide_type,
    loc=loc(),
  )
  let packed_value = CoreRhs::Struct(
    symbol=hide,
    type_arguments=[],
    type_witnesses=[
      { symbol: type_member, name: "T", type_: opened_type, loc: loc() },
    ],
    fields=[
      {
        symbol: field,
        name: "val",
        value: Value(name="val", symbol=binder, type_=opened_type, loc=loc()),
        loc: loc(),
      },
    ],
    type_=hide_type,
    loc=loc(),
  )
  let body = CoreExpr::Let(
    binding=Pattern(pattern~, initializer~, loc=loc()),
    body=Let(
      binding=Value(
        symbol=packed,
        name=Some("packed"),
        rhs=packed_value,
        type_=hide_type,
        loc=loc(),
      ),
      body=Atom(
        atom=Value(name="packed", symbol=packed, type_=hide_type, loc=loc()),
        type_=hide_type,
        loc=loc(),
      ),
      type_=hide_type,
      loc=loc(),
    ),
    type_=hide_type,
    loc=loc(),
  )
  let program = CoreProgram::{
    declarations: [
      Struct({
        symbol: hide,
        name: "Hide",
        type_parameters: [],
        type_members: [
          {
            symbol: type_member,
            type_parameter: { id: member_parameter, name: "T", kind: Type },
            name: "T",
            kind: Type,
            index: 0,
            loc: loc(),
          },
        ],
        fields: [
          {
            symbol: field,
            is_offered: false,
            name: "val",
            index: 0,
            type_: Parameter(member_parameter),
            loc: loc(),
          },
        ],
        loc: loc(),
      }),
      Function({
        symbol: repack,
        name: "repack",
        type_parameters: [],
        parameters: [
          {
            symbol: input,
            is_auto: false,
            is_offered: false,
            name: "h",
            type_: hide_type,
            loc: loc(),
          },
        ],
        return_type: hide_type,
        body,
        type_: Function([hide_type], hide_type),
        loc: loc(),
      }),
    ],
    loc: loc(),
  }
  inspect(
    @prettyprinter.render(program, width=100),
    content=(
      #|core_program {
      #|  struct type#0 Hide {
      #|    type tmember#0 tparam#0 T : Type index=0
      #|    field field#0 val : tparam#0 index=0
      #|  }
      #|  fn : (type#0) -> type#0 value#0 repack {
      #|    parameters {
      #|      param : type#0 value#1 h
      #|    }
      #|    return : type#0
      #|    body {
      #|      let_expr : type#0 {
      #|        binding {
      #|          pattern_binding {
      #|            pattern {
      #|              struct_pattern : type#0 type#0 {
      #|                type_pattern tmember#0 tparam#1 T
      #|                field_pattern field#0 val {
      #|                  binding : tparam#1 value#2 val
      #|                }
      #|              }
      #|            }
      #|            initializer {
      #|              value : type#0 value#1 h
      #|            }
      #|          }
      #|        }
      #|        body {
      #|          let_expr : type#0 {
      #|            binding {
      #|              binding : type#0 value#3 packed {
      #|                struct : type#0 type#0 {
      #|                  type tmember#0 T = tparam#1
      #|                  field field#0 val {
      #|                    value : tparam#1 value#2 val
      #|                  }
      #|                }
      #|              }
      #|            }
      #|            body {
      #|              atom : type#0 {
      #|                value : type#0 value#3 packed
      #|              }
      #|            }
      #|          }
      #|        }
      #|      }
      #|    }
      #|  }
      #|}
    ),
  )
}
