///|
fn loc() -> SourceSpan {
  SourceSpan::dummy()
}

///|
fn hide_type(symbol : TypeSymbolId) -> @types.Type {
  Nominal(symbol, [])
}

///|
fn expect_core_program(source : String) -> CoreProgram {
  let parse_result = @parser.parse_string(source)
  if !parse_result.lexical_errors.is_empty() ||
    !parse_result.parse_errors.is_empty() {
    abort("expected parse success")
  }
  guard parse_result.source is Some(file) else { abort("expected source") }
  let resolved = @resolve.resolve_source_file(file)
  let checked = @typecheck.typecheck_checked_source_file(resolved)
  guard checked.source is Some(source) else {
    abort(@prettyprinter.render(checked.diagnostics, width=100))
  }
  lower_checked_source_file(source)
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

///|
test "lower checked source existential struct opening to typed core" {
  let program = expect_core_program(
    (
      #|struct Hide {
      #|  type T : Type
      #|  val : T
      #|}
      #|fn repack(h : Hide) -> Hide {
      #|  {
      #|    let Hide::{ T, val } = h
      #|    Hide::{ T = T, val: val }
      #|  }
      #|}
    ),
  )
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
      #|              temp_binding : type#0 temp#0 {
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
      #|                temp : type#0 temp#0
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

///|
test "lower checked source existential enum opening to typed core" {
  let program = expect_core_program(
    (
      #|enum Packed {
      #|  hide[T](T)
      #|}
      #|fn repack(p : Packed) -> Packed {
      #|  match p {
      #|    Packed::hide[T](value) => Packed::hide[T](value)
      #|  }
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(program, width=100),
    content=(
      #|core_program {
      #|  enum type#0 Packed {
      #|    variant variant#0 hide index=0 payloads=1[tparam#0 T : Type](tparam#0)
      #|  }
      #|  fn : (type#0) -> type#0 value#0 repack {
      #|    parameters {
      #|      param : type#0 value#1 p
      #|    }
      #|    return : type#0
      #|    body {
      #|      match : type#0 {
      #|        scrutinee {
      #|          value : type#0 value#1 p
      #|        }
      #|        arms {
      #|          arm {
      #|            pattern {
      #|              variant_pattern : type#0 variant#0[tparam#1] {
      #|                binding : tparam#1 value#2 value
      #|              }
      #|            }
      #|            body {
      #|              let_expr : type#0 {
      #|                binding {
      #|                  temp_binding : type#0 temp#0 {
      #|                    variant : type#0 variant#0[tparam#1] {
      #|                      value : tparam#1 value#2 value
      #|                    }
      #|                  }
      #|                }
      #|                body {
      #|                  atom : type#0 {
      #|                    temp : type#0 temp#0
      #|                  }
      #|                }
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

///|
test "lower checked source generic call and unsafe builtin to typed core" {
  let program = expect_core_program(
    (
      #|fn[A] id(value : A) -> A {
      #|  value
      #|}
      #|let answer : Int = id(builtin("%answer"))
    ),
  )
  inspect(
    @prettyprinter.render(program, width=100),
    content=(
      #|core_program {
      #|  fn : forall [tparam#0 A : Type]. (tparam#0) -> tparam#0 value#0 id[tparam#0 A : Type] {
      #|    parameters {
      #|      param : tparam#0 value#1 value
      #|    }
      #|    return : tparam#0
      #|    body {
      #|      atom : tparam#0 {
      #|        value : tparam#0 value#1 value
      #|      }
      #|    }
      #|  }
      #|  let : Int value#2 answer {
      #|    let_expr : Int {
      #|      binding {
      #|        temp_binding : (Int) -> Int temp#0 {
      #|          type_application : (Int) -> Int[Int] {
      #|            callee {
      #|              value : forall [tparam#0 A : Type]. (tparam#0) -> tparam#0 value#0 id
      #|            }
      #|          }
      #|        }
      #|      }
      #|      body {
      #|        let_expr : Int {
      #|          binding {
      #|            temp_binding : Int temp#1 {
      #|              call : Int {
      #|                callee {
      #|                  temp : (Int) -> Int temp#0
      #|                }
      #|                arguments {
      #|                  unsafe_builtin "%answer" : Int
      #|                }
      #|              }
      #|            }
      #|          }
      #|          body {
      #|            atom : Int {
      #|              temp : Int temp#1
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
