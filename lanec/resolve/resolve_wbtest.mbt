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
test "collect top level declaration symbols" {
  let file = expect_parse_ok(
    (
      #|struct Point {
      #|  x : Int
      #|  y : Int
      #|}
      #|enum Option[A] {
      #|  none
      #|  some(A)
      #|}
      #|fn unwrap_or(value : Option[Int], fallback : Int) -> Int {
      #|  match value {
      #|    Option::none => fallback
      #|    Option::some(x) => x
      #|  }
      #|}
      #|let : Point = Point::{ x: 1, y: 2 }
    ),
  )
  inspect(
    @prettyprinter.render(resolve_source_file(file), width=100),
    content=(
      #|resolved {
      #|  symbols {
      #|    types {
      #|      type#0 struct Point/0
      #|      type#1 enum Option/1
      #|    }
      #|    type_parameters {
      #|      tparam#0 A
      #|    }
      #|    values {
      #|      value#0 top_function unwrap_or
      #|      value#1 parameter value
      #|      value#2 parameter fallback
      #|      value#3 pattern_binder x
      #|      value#4 top_value <anonymous>
      #|    }
      #|    fields {
      #|      field#0 owner=type#0 x index=0
      #|      field#1 owner=type#0 y index=1
      #|    }
      #|    variants {
      #|      variant#0 owner=type#1 none index=0 payloads=0
      #|      variant#1 owner=type#1 some index=1 payloads=1
      #|    }
      #|  }
      #|  declarations {
      #|    struct type#0 Point {
      #|      field field#0 x : Int index=0
      #|      field field#1 y : Int index=1
      #|    }
      #|    enum type#1 Option[tparam#0 A] {
      #|      variant variant#0 none index=0 payloads=0
      #|      variant variant#1 some index=1 payloads=1(tparam#0 A)
      #|    }
      #|    fn value#0 unwrap_or(value#1 value : type#1 Option[Int], value#2 fallback : Int) -> Int {
      #|      match var value#1 value {
      #|        variant#0 Option::none() => var value#2 fallback
      #|        variant#1 Option::some(bind value#3 x) => var value#3 x
      #|      }
      #|    }
      #|    let value#4 <anonymous> : type#0 Point = Point::{
      #|      x: 1
      #|      y: 2
      #|    }
      #|  }
      #|}
    ),
  )
}

///|
test "resolve unqualified variant calls after nominal member collection" {
  let file = expect_parse_ok(
    (
      #|fn wrap(value : Int) -> Option[Int] {
      #|  some(value)
      #|}
      #|enum Option[A] {
      #|  none
      #|  some(A)
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(resolve_source_file(file), width=100),
    content=(
      #|resolved {
      #|  symbols {
      #|    types {
      #|      type#0 enum Option/1
      #|    }
      #|    type_parameters {
      #|      tparam#0 A
      #|    }
      #|    values {
      #|      value#0 top_function wrap
      #|      value#1 parameter value
      #|    }
      #|    fields {}
      #|    variants {
      #|      variant#0 owner=type#0 none index=0 payloads=0
      #|      variant#1 owner=type#0 some index=1 payloads=1
      #|    }
      #|  }
      #|  declarations {
      #|    fn value#0 wrap(value#1 value : Int) -> type#0 Option[Int] {
      #|      variant#1 some(var value#1 value)
      #|    }
      #|    enum type#0 Option[tparam#0 A] {
      #|      variant variant#0 none index=0 payloads=0
      #|      variant variant#1 some index=1 payloads=1(tparam#0 A)
      #|    }
      #|  }
      #|}
    ),
  )
}

///|
test "report unresolved type and qualified variant diagnostics" {
  let file = expect_parse_ok(
    (
      #|enum Option {
      #|  none
      #|}
      #|fn bad(value : Missing) -> Int {
      #|  Option::some(0)
      #|}
    ),
  )
  let result = resolve_source_file_result(file)
  inspect(
    @prettyprinter.render(result.diagnostics[0]),
    content="unresolved_type Missing",
  )
  inspect(
    @prettyprinter.render(result.diagnostics[1]),
    content="unresolved_variant Option::some",
  )
}

///|
test "resolve ambiguous unqualified variant calls" {
  let file = expect_parse_ok(
    (
      #|enum Left {
      #|  same(Int)
      #|}
      #|enum Right {
      #|  same(Int)
      #|}
      #|fn choose(value : Int) -> Int {
      #|  same(value)
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(resolve_source_file(file), width=100),
    content=(
      #|resolved {
      #|  symbols {
      #|    types {
      #|      type#0 enum Left/0
      #|      type#1 enum Right/0
      #|    }
      #|    type_parameters {}
      #|    values {
      #|      value#0 top_function choose
      #|      value#1 parameter value
      #|    }
      #|    fields {}
      #|    variants {
      #|      variant#0 owner=type#0 same index=0 payloads=1
      #|      variant#1 owner=type#1 same index=0 payloads=1
      #|    }
      #|  }
      #|  declarations {
      #|    enum type#0 Left {
      #|      variant variant#0 same index=0 payloads=1(Int)
      #|    }
      #|    enum type#1 Right {
      #|      variant variant#1 same index=0 payloads=1(Int)
      #|    }
      #|    fn value#0 choose(value#1 value : Int) -> Int {
      #|      ?ambiguous same [variant#0, variant#1] same(var value#1 value)
      #|    }
      #|  }
      #|}
    ),
  )
  let result = resolve_source_file_result(file)
  inspect(
    @prettyprinter.render(result.diagnostics[0]),
    content="ambiguous_variant same [variant#0, variant#1]",
  )
}

///|
test "keep unknown calls as unresolved value calls" {
  let file = expect_parse_ok(
    (
      #|fn call_unknown(value : Int) -> Int {
      #|  missing(value)
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(resolve_source_file(file), width=100),
    content=(
      #|resolved {
      #|  symbols {
      #|    types {}
      #|    type_parameters {}
      #|    values {
      #|      value#0 top_function call_unknown
      #|      value#1 parameter value
      #|    }
      #|    fields {}
      #|    variants {}
      #|  }
      #|  declarations {
      #|    fn value#0 call_unknown(value#1 value : Int) -> Int {
      #|      var ?missing missing(var value#1 value)
      #|    }
      #|  }
      #|}
    ),
  )
  let result = resolve_source_file_result(file)
  inspect(
    @prettyprinter.render(result.diagnostics[0]),
    content="unresolved_value missing",
  )
}
