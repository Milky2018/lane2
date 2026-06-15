///|
fn expect_parse_ok(source : String) -> @syntax.SourceFile {
  let result = @parser.parse_string(source)
  if !result.lexical_errors.is_empty() || !result.parse_errors.is_empty() {
    abort("expected parse success")
  }
  guard result.source is Some(file) else { abort("expected source file") }
  file
}

///|
fn elaborate_source(source : String) -> ElaborateResult {
  let file = expect_parse_ok(source)
  let resolved = @resolve.resolve_source_file(file)
  elaborate_resolved_source_file(resolved)
}

///|
fn elaborate_buslane_source(source : String) -> BuslaneElaborateResult {
  let file = expect_parse_ok(source)
  let resolved = @resolve.resolve_source_file(file)
  elaborate_resolved_source_file_to_buslane(resolved)
}

///|
fn elaborate_anf_source(source : String) -> AnfElaborateResult {
  let file = expect_parse_ok(source)
  let resolved = @resolve.resolve_source_file(file)
  elaborate_resolved_source_file_to_anf(resolved)
}

///|
test "elaborate resolved source into checked source" {
  let result = elaborate_source(
    (
      #|struct Box {
      #|  value : Int
      #|}
      #|fn identity(x : Int) -> Int {
      #|  x
      #|}
      #|let answer : Int = 42
    ),
  )
  inspect(
    @prettyprinter.render(result, width=100),
    content=(
      #|elaborate_result {
      #|  checked_source {
      #|    struct type#0 Box {
      #|      field field#0 value : Int index=0
      #|    }
      #|    fn : (Int) -> Int value#0 identity {
      #|      parameters {
      #|        param : Int value#1 x
      #|      }
      #|      return : Int
      #|      body {
      #|        block : Int {
      #|          result {
      #|            value : Int value#1 x
      #|          }
      #|        }
      #|      }
      #|    }
      #|    let : Int value#2 answer {
      #|      int 42 : Int
      #|    }
      #|  }
      #|  diagnostics {}
      #|}
    ),
  )
}

///|
test "elaborate resolved source into buslane core" {
  let result = elaborate_buslane_source(
    (
      #|fn identity(x : Int) -> Int {
      #|  x
      #|}
      #|let answer : Int = identity(42)
    ),
  )
  inspect(
    @prettyprinter.render(result, width=100),
    content=(
      #|buslane_elaborate_result {
      #|  buslane_program {
      #|    metadata {
      #|      types {}
      #|      type_parameters {}
      #|      values {
      #|        value_info {
      #|          kind function
      #|          type (Int) -> Int
      #|        }
      #|        value_info {
      #|          kind value
      #|          type Int
      #|        }
      #|        value_info {
      #|          kind parameter
      #|          type Int
      #|        }
      #|      }
      #|      data_constructors {}
      #|    }
      #|    terms {
      #|      top_letrec {
      #|        rec value#0 {
      #|          fn {
      #|            parameters [value#2]
      #|            result Int
      #|            body {
      #|              ref value#2
      #|            }
      #|          }
      #|        }
      #|      }
      #|      top_let value#1 {
      #|        call {
      #|          callee {
      #|            ref value#0
      #|          }
      #|          arguments {
      #|            int 42
      #|          }
      #|        }
      #|      }
      #|    }
      #|  }
      #|  diagnostics {}
      #|}
    ),
  )
}

///|
test "elaborate generic enum variant into verifiable buslane" {
  let result = elaborate_buslane_source(
    (
      #|enum Option[A] {
      #|  none
      #|  some(A)
      #|}
      #|let answer : Option[Int] = Option::some(1)
    ),
  )
  guard result.program is Some(program) else {
    abort("expected buslane program")
  }
  inspect(
    @prettyprinter.render(@buslane.verify_program(program), width=100),
    content=(
      #|verify_result {}
    ),
  )
}

///|
test "elaborate struct field access into buslane selector" {
  let result = elaborate_buslane_source(
    (
      #|struct Point {
      #|  x : Int
      #|  y : Int
      #|}
      #|let answer : Int = Point::{ x: 1, y: 2 }.x
    ),
  )
  guard result.program is Some(program) else {
    abort("expected buslane program")
  }
  inspect(
    @prettyprinter.render(@buslane.verify_program(program), width=100),
    content=(
      #|verify_result {}
    ),
  )
}

///|
test "elaborate resolved source into anf" {
  let result = elaborate_anf_source(
    (
      #|fn identity(x : Int) -> Int {
      #|  x
      #|}
      #|let answer : Int = identity(42)
    ),
  )
  inspect(
    @prettyprinter.render(result, width=100),
    content=(
      #|anf_elaborate_result {
      #|  buslane_anf_program {
      #|    top_letrec {
      #|      rec value#0 {
      #|        fn {
      #|          parameters [value#2]
      #|          result Int
      #|          body {
      #|            atom {
      #|              ref value#2
      #|            }
      #|          }
      #|        }
      #|      }
      #|    }
      #|    top_let value#1 {
      #|      let_expr {
      #|        binding {
      #|          temp_binding temp#0 {
      #|            call {
      #|              callee {
      #|                ref value#0
      #|              }
      #|              arguments {
      #|                int 42
      #|              }
      #|            }
      #|          }
      #|        }
      #|        body {
      #|          atom {
      #|            temp temp#0
      #|          }
      #|        }
      #|      }
      #|    }
      #|  }
      #|  diagnostics {}
      #|}
    ),
  )
}

///|
test "elaborate builtins through contextual expected types" {
  let result = elaborate_source(
    (
      #|fn identity(value : Int) -> Int {
      #|  value
      #|}
      #|let top : Int = builtin("%top")
      #|fn direct() -> Int {
      #|  builtin("%direct")
      #|}
      #|fn use() -> Int {
      #|  let local : Int = builtin("%local")
      #|  identity(builtin("%argument"))
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result, width=100),
    content=(
      #|elaborate_result {
      #|  checked_source {
      #|    fn : (Int) -> Int value#0 identity {
      #|      parameters {
      #|        param : Int value#3 value
      #|      }
      #|      return : Int
      #|      body {
      #|        block : Int {
      #|          result {
      #|            value : Int value#3 value
      #|          }
      #|        }
      #|      }
      #|    }
      #|    let : Int value#4 top {
      #|      unsafe_builtin "%top" : Int
      #|    }
      #|    fn : () -> Int value#1 direct {
      #|      parameters {}
      #|      return : Int
      #|      body {
      #|        block : Int {
      #|          result {
      #|            unsafe_builtin "%direct" : Int
      #|          }
      #|        }
      #|      }
      #|    }
      #|    fn : () -> Int value#2 use {
      #|      parameters {}
      #|      return : Int
      #|      body {
      #|        block : Int {
      #|          let : Int value#5 local {
      #|            unsafe_builtin "%local" : Int
      #|          }
      #|          result {
      #|            call : Int {
      #|              callee {
      #|                value : (Int) -> Int value#0 identity
      #|              }
      #|              arguments {
      #|                unsafe_builtin "%argument" : Int
      #|              }
      #|            }
      #|          }
      #|        }
      #|      }
      #|    }
      #|  }
      #|  diagnostics {}
      #|}
    ),
  )
}

///|
test "elaborate reports unimplemented checked expression shape" {
  let result = elaborate_source(
    (
      #|fn choose(value : Bool) -> Int {
      #|  if value { 1 } else { 2 }
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result, width=100),
    content=(
      #|elaborate_result {
      #|  <no checked source>
      #|  diagnostics {
      #|    cannot_infer checked block result @ 2:12-2:28
      #|  }
      #|}
    ),
  )
}

///|
test "elaborate top level offer value declarations" {
  let result = elaborate_source(
    (
      #|struct Box {
      #|  value : Int
      #|}
      #|offer box : Box = builtin("%box")
      #|fn use() -> Box {
      #|  box
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result, width=100),
    content=(
      #|elaborate_result {
      #|  checked_source {
      #|    struct type#0 Box {
      #|      field field#0 value : Int index=0
      #|    }
      #|    let : type#0 value#1 box {
      #|      unsafe_builtin "%box" : type#0
      #|    }
      #|    fn : () -> type#0 value#0 use {
      #|      parameters {}
      #|      return : type#0
      #|      body {
      #|        block : type#0 {
      #|          result {
      #|            value : type#0 value#1 box
      #|          }
      #|        }
      #|      }
      #|    }
      #|  }
      #|  diagnostics {}
      #|}
    ),
  )
}

///|
test "elaborate pipeline expression into checked call" {
  let result = elaborate_source(
    (
      #|fn first(a : Int, b : Int) -> Int {
      #|  a
      #|}
      #|fn use() -> Int {
      #|  1 |> first(2)
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result, width=100),
    content=(
      #|elaborate_result {
      #|  checked_source {
      #|    fn : (Int, Int) -> Int value#0 first {
      #|      parameters {
      #|        param : Int value#2 a
      #|        param : Int value#3 b
      #|      }
      #|      return : Int
      #|      body {
      #|        block : Int {
      #|          result {
      #|            value : Int value#2 a
      #|          }
      #|        }
      #|      }
      #|    }
      #|    fn : () -> Int value#1 use {
      #|      parameters {}
      #|      return : Int
      #|      body {
      #|        block : Int {
      #|          result {
      #|            call : Int {
      #|              callee {
      #|                value : (Int, Int) -> Int value#0 first
      #|              }
      #|              arguments {
      #|                int 1 : Int
      #|                int 2 : Int
      #|              }
      #|            }
      #|          }
      #|        }
      #|      }
      #|    }
      #|  }
      #|  diagnostics {}
      #|}
    ),
  )
}

///|
test "elaborate direct binary operator alias into checked call" {
  let result = elaborate_source(
    (
      #|fn op_add(a : Int, b : Int) -> Int {
      #|  a
      #|}
      #|fn use() -> Int {
      #|  1 + 2
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result, width=100),
    content=(
      #|elaborate_result {
      #|  checked_source {
      #|    fn : (Int, Int) -> Int value#0 op_add {
      #|      parameters {
      #|        param : Int value#2 a
      #|        param : Int value#3 b
      #|      }
      #|      return : Int
      #|      body {
      #|        block : Int {
      #|          result {
      #|            value : Int value#2 a
      #|          }
      #|        }
      #|      }
      #|    }
      #|    fn : () -> Int value#1 use {
      #|      parameters {}
      #|      return : Int
      #|      body {
      #|        block : Int {
      #|          result {
      #|            call : Int {
      #|              callee {
      #|                value : (Int, Int) -> Int value#0 op_add
      #|              }
      #|              arguments {
      #|                int 1 : Int
      #|                int 2 : Int
      #|              }
      #|            }
      #|          }
      #|        }
      #|      }
      #|    }
      #|  }
      #|  diagnostics {}
      #|}
    ),
  )
}

///|
test "elaborate direct unary operator alias into checked call" {
  let result = elaborate_source(
    (
      #|fn op_neg(value : Int) -> Int {
      #|  value
      #|}
      #|fn use() -> Int {
      #|  -1
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result, width=100),
    content=(
      #|elaborate_result {
      #|  checked_source {
      #|    fn : (Int) -> Int value#0 op_neg {
      #|      parameters {
      #|        param : Int value#2 value
      #|      }
      #|      return : Int
      #|      body {
      #|        block : Int {
      #|          result {
      #|            value : Int value#2 value
      #|          }
      #|        }
      #|      }
      #|    }
      #|    fn : () -> Int value#1 use {
      #|      parameters {}
      #|      return : Int
      #|      body {
      #|        block : Int {
      #|          result {
      #|            call : Int {
      #|              callee {
      #|                value : (Int) -> Int value#0 op_neg
      #|              }
      #|              arguments {
      #|                int 1 : Int
      #|              }
      #|            }
      #|          }
      #|        }
      #|      }
      #|    }
      #|  }
      #|  diagnostics {}
      #|}
    ),
  )
}

///|
test "elaborate pipeline into function literal call" {
  let result = elaborate_source(
    (
      #|fn use() -> Int {
      #|  1 |> fn(value : Int) {
      #|    value
      #|  }
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result, width=100),
    content=(
      #|elaborate_result {
      #|  checked_source {
      #|    fn : () -> Int value#0 use {
      #|      parameters {}
      #|      return : Int
      #|      body {
      #|        block : Int {
      #|          result {
      #|            call : Int {
      #|              callee {
      #|                fn_literal : (Int) -> Int {
      #|                  parameters {
      #|                    param : Int value#1 value
      #|                  }
      #|                  return : Int
      #|                  body {
      #|                    block : Int {
      #|                      result {
      #|                        value : Int value#1 value
      #|                      }
      #|                    }
      #|                  }
      #|                }
      #|              }
      #|              arguments {
      #|                int 1 : Int
      #|              }
      #|            }
      #|          }
      #|        }
      #|      }
      #|    }
      #|  }
      #|  diagnostics {}
      #|}
    ),
  )
}

///|
test "elaborate lazy bool operator into thunked checked call" {
  let result = elaborate_source(
    (
      #|fn op_and(a : Bool, b : () -> Bool) -> Bool {
      #|  a
      #|}
      #|fn use(a : Bool, b : Bool) -> Bool {
      #|  a && b
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result, width=100),
    content=(
      #|elaborate_result {
      #|  checked_source {
      #|    fn : (Bool, () -> Bool) -> Bool value#0 op_and {
      #|      parameters {
      #|        param : Bool value#2 a
      #|        param : () -> Bool value#3 b
      #|      }
      #|      return : Bool
      #|      body {
      #|        block : Bool {
      #|          result {
      #|            value : Bool value#2 a
      #|          }
      #|        }
      #|      }
      #|    }
      #|    fn : (Bool, Bool) -> Bool value#1 use {
      #|      parameters {
      #|        param : Bool value#4 a
      #|        param : Bool value#5 b
      #|      }
      #|      return : Bool
      #|      body {
      #|        block : Bool {
      #|          result {
      #|            call : Bool {
      #|              callee {
      #|                value : (Bool, () -> Bool) -> Bool value#0 op_and
      #|              }
      #|              arguments {
      #|                value : Bool value#4 a
      #|                fn_literal : () -> Bool {
      #|                  parameters {}
      #|                  return : Bool
      #|                  body {
      #|                    value : Bool value#5 b
      #|                  }
      #|                }
      #|              }
      #|            }
      #|          }
      #|        }
      #|      }
      #|    }
      #|  }
      #|  diagnostics {}
      #|}
    ),
  )
}

///|
test "elaborate existential openings into checked source" {
  let result = elaborate_source(
    (
      #|struct Hide {
      #|  type T : Type
      #|  val : T
      #|}
      #|enum Packed {
      #|  hide[T](T)
      #|}
      #|fn repack_struct(h : Hide) -> Hide {
      #|  {
      #|    let Hide::{ T, val } = h
      #|    Hide::{ T = T, val: val }
      #|  }
      #|}
      #|fn repack_enum(p : Packed) -> Packed {
      #|  match p {
      #|    Packed::hide[T](value) => Packed::hide[T](value)
      #|  }
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result, width=100),
    content=(
      #|elaborate_result {
      #|  checked_source {
      #|    struct type#0 Hide {
      #|      type tmember#0 tparam#0 T : Type index=0
      #|      field field#0 val : tparam#0 index=0
      #|    }
      #|    enum type#1 Packed {
      #|      variant variant#0 hide index=0 payloads=1[tparam#1 T : Type](tparam#1)
      #|    }
      #|    fn : (type#0) -> type#0 value#0 repack_struct {
      #|      parameters {
      #|        param : type#0 value#2 h
      #|      }
      #|      return : type#0
      #|      body {
      #|        block : type#0 {
      #|          result {
      #|            block : type#0 {
      #|              pattern_let {
      #|                pattern {
      #|                  struct_pattern : type#0 type#0 {
      #|                    type_pattern tmember#0 tparam#2 T
      #|                    field_pattern field#0 val {
      #|                      binding : tparam#2 value#3 val
      #|                    }
      #|                  }
      #|                }
      #|                initializer {
      #|                  value : type#0 value#2 h
      #|                }
      #|              }
      #|              result {
      #|                struct : type#0 type#0 {
      #|                  type tmember#0 T = tparam#2
      #|                  field field#0 val {
      #|                    value : tparam#2 value#3 val
      #|                  }
      #|                }
      #|              }
      #|            }
      #|          }
      #|        }
      #|      }
      #|    }
      #|    fn : (type#1) -> type#1 value#1 repack_enum {
      #|      parameters {
      #|        param : type#1 value#4 p
      #|      }
      #|      return : type#1
      #|      body {
      #|        block : type#1 {
      #|          result {
      #|            match : type#1 {
      #|              scrutinee {
      #|                value : type#1 value#4 p
      #|              }
      #|              arms {
      #|                arm {
      #|                  pattern {
      #|                    variant_pattern : type#1 variant#0[tparam#3] {
      #|                      binding : tparam#3 value#5 value
      #|                    }
      #|                  }
      #|                  body {
      #|                    variant : type#1 variant#0[tparam#3] {
      #|                      value : tparam#3 value#5 value
      #|                    }
      #|                  }
      #|                }
      #|              }
      #|            }
      #|          }
      #|        }
      #|      }
      #|    }
      #|  }
      #|  diagnostics {}
      #|}
    ),
  )
}
