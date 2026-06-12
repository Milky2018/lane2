///|
fn expect_buslane_program(source : String) -> BuslaneProgram {
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
  lower_checked_source_file_to_buslane(source)
}

///|
test "lower checked source to buslane expression core" {
  let program = expect_buslane_program(
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
      #|buslane_program {
      #|  fn : forall [tparam#0 A : Type]. (tparam#0) -> tparam#0 value#0 id[tparam#0 A : Type] {
      #|    parameters {
      #|      param : tparam#0 value#1 value
      #|    }
      #|    return : tparam#0
      #|    body {
      #|      value : tparam#0 value#1 value
      #|    }
      #|  }
      #|  let : Int value#2 answer {
      #|    call : Int {
      #|      callee {
      #|        type_application : (Int) -> Int[Int] {
      #|          callee {
      #|            value : forall [tparam#0 A : Type]. (tparam#0) -> tparam#0 value#0 id
      #|          }
      #|        }
      #|      }
      #|      arguments {
      #|        unsafe_builtin "%answer" : Int
      #|      }
      #|    }
      #|  }
      #|}
    ),
  )
}
