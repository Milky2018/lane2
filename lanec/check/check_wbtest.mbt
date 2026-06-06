///|
fn expect_parse_ok(source : String) -> @syntax.SourceFile {
  let result = @parser.parse_string(source)
  if !result.lexical_errors.is_empty() || !result.parse_errors.is_empty() {
    abort("expected parse success")
  }
  match result.source {
    Some(file) => file
    None => abort("expected source file")
  }
}

///|
fn expect_check_result(source : String) -> CheckResult {
  let file = expect_parse_ok(source)
  let resolved = @resolve.resolve_source_file(file)
  check_declarations(resolved)
}

///|
fn expect_checked_source(source : String) -> CheckedSourceFile {
  let file = expect_parse_ok(source)
  let resolved = @resolve.resolve_source_file(file)
  check_source_file(resolved)
}

///|
test "check custom type declaration environment" {
  let result = expect_check_result(
    (
      #|struct Box[A] {
      #|  value : A
      #|}
      #|enum Option[A] {
      #|  none
      #|  some(A)
      #|}
      #|struct Uses {
      #|  boxed : Box[Int]
      #|  option : Option[String]
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result, width=100),
    content=(
      #|check_result {
      #|  checked_declarations {
      #|    types {
      #|      struct type#0 Box[tparam#0 A : Type] {
      #|        field field#0 value : tparam#0 index=0
      #|      }
      #|      enum type#1 Option[tparam#1 A : Type] {
      #|        variant variant#0 none index=0 payloads=0
      #|        variant variant#1 some index=1 payloads=1(tparam#1)
      #|      }
      #|      struct type#2 Uses {
      #|        field field#1 boxed : type#0[Int] index=0
      #|        field field#2 option : type#1[String] index=1
      #|      }
      #|    }
      #|    fields {
      #|      field field#0 value : tparam#0 index=0
      #|      field field#1 boxed : type#0[Int] index=0
      #|      field field#2 option : type#1[String] index=1
      #|    }
      #|    variants {
      #|      variant variant#0 none index=0 payloads=0
      #|      variant variant#1 some index=1 payloads=1(tparam#1)
      #|    }
      #|  }
      #|  diagnostics {}
      #|}
    ),
  )
}

///|
test "check top level values and direct calls" {
  let result = expect_checked_source(
    (
      #|fn id(value : Int) -> Int {
      #|  value
      #|}
      #|let answer : Int = id(42)
      #|fn use_answer() -> Int {
      #|  answer
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result, width=100),
    content=(
      #|checked_source {
      #|  checked_declarations {
      #|    types {}
      #|    fields {}
      #|    variants {}
      #|  }
      #|  checked_values {
      #|    fn value#0 id : (Int) -> Int
      #|    fn value#1 use_answer : () -> Int
      #|    let value#3 answer : Int
      #|  }
      #|  diagnostics {}
      #|}
    ),
  )
}

///|
test "check local let inference and opened field reference" {
  let result = expect_checked_source(
    (
      #|struct Box {
      #|  value : Int
      #|}
      #|let box : Box = Box::{ value: 1 }
      #|open box
      #|fn use() -> Int {
      #|  {
      #|    let local = value
      #|    local
      #|  }
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result, width=100),
    content=(
      #|checked_source {
      #|  checked_declarations {
      #|    types {
      #|      struct type#0 Box {
      #|        field field#0 value : Int index=0
      #|      }
      #|    }
      #|    fields {
      #|      field field#0 value : Int index=0
      #|    }
      #|    variants {}
      #|  }
      #|  checked_values {
      #|    fn value#0 use : () -> Int
      #|    let value#1 box : type#0
      #|  }
      #|  diagnostics {}
      #|}
    ),
  )
}

///|
test "check reports type mismatch" {
  let result = expect_checked_source(
    (
      #|fn bad() -> Int {
      #|  true
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result.diagnostics[0]),
    content="type_mismatch expected=Int actual=Bool",
  )
}

///|
test "check struct literal punning and required fields" {
  let result = expect_checked_source(
    (
      #|struct Point {
      #|  x : Int
      #|  y : Int
      #|}
      #|fn bad(x : Int) -> Point {
      #|  Point::{ x }
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result.diagnostics[0]),
    content="missing_field y",
  )
}

///|
test "check reports nominal type arity mismatch" {
  let result = expect_check_result(
    (
      #|struct Box[A] {
      #|  value : A
      #|}
      #|struct Bad {
      #|  broken : Box[Int, Bool]
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result.diagnostics[0]),
    content="type_arity_mismatch Box expected=1 actual=2",
  )
}

///|
test "check keeps unresolved type as error type" {
  let result = expect_check_result(
    (
      #|struct Bad {
      #|  missing : Missing
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result, width=100),
    content=(
      #|check_result {
      #|  checked_declarations {
      #|    types {
      #|      struct type#0 Bad {
      #|        field field#0 missing : <error> index=0
      #|      }
      #|    }
      #|    fields {
      #|      field field#0 missing : <error> index=0
      #|    }
      #|    variants {}
      #|  }
      #|  diagnostics {
      #|    unresolved_type Missing
      #|  }
      #|}
    ),
  )
}
