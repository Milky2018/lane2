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
fn elaborate_core_source(source : String) -> CoreElaborateResult {
  let file = expect_parse_ok(source)
  let resolved = @resolve.resolve_source_file(file)
  elaborate_resolved_source_file_to_core(resolved)
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
test "elaborate resolved source into typed core" {
  let result = elaborate_core_source(
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
      #|core_elaborate_result {
      #|  core_program {
      #|    fn : (Int) -> Int value#0 identity {
      #|      parameters {
      #|        param : Int value#1 x
      #|      }
      #|      return : Int
      #|      body {
      #|        atom : Int {
      #|          value : Int value#1 x
      #|        }
      #|      }
      #|    }
      #|    let : Int value#2 answer {
      #|      let_expr : Int {
      #|        binding {
      #|          temp_binding : Int temp#0 {
      #|            call : Int {
      #|              callee {
      #|                value : (Int) -> Int value#0 identity
      #|              }
      #|              arguments {
      #|                int 42 : Int
      #|              }
      #|            }
      #|          }
      #|        }
      #|        body {
      #|          atom : Int {
      #|            temp : Int temp#0
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
