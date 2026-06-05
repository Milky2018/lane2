///|
fn expect_parse_ok(source : String) -> @syntax.SourceFile {
  let result = parse_string(source)
  if !result.lexical_errors.is_empty() || !result.parse_errors.is_empty() {
    abort("expected parse success")
  }
  match result.source {
    Some(file) => file
    None => abort("expected source file")
  }
}

///|
fn parse_errors(source : String) -> Array[ParseError] {
  let result = parse_string(source)
  if !result.lexical_errors.is_empty() {
    abort("expected parser errors, got lexer errors")
  }
  result.parse_errors
}

///|
fn parse_error_kinds(source : String) -> Array[ParseErrorKind] {
  parse_errors(source).map(fn(error) { error.kind })
}

///|
test "parse nominal declarations and match" {
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
    ),
  )
  inspect(
    @prettyprinter.render(file),
    content=(
      #|struct Point {
      #|  x : Int
      #|  y : Int
      #|}
      #|
      #|enum Option[A] {
      #|  none
      #|  some(A)
      #|}
      #|
      #|fn unwrap_or(value : Option[Int], fallback : Int) -> Int {
      #|  match value {
      #|    Option::none => fallback
      #|    Option::some(x) => x
      #|  }
      #|}
    ),
  )
}

///|
test "parse function literal and pipeline" {
  let file = expect_parse_ok(
    (
      #|fn pipeline_literal(x : Int) -> Int {
      #|  x |> fn(value : Int) {
      #|    value
      #|  }
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(file),
    content=(
      #|fn pipeline_literal(x : Int) -> Int {
      #|  x |> fn (value : Int) {
      #|    value
      #|  }
      #|}
    ),
  )
}

///|
test "parse anonymous top level let and struct forwarding" {
  let file = expect_parse_ok(
    (
      #|struct Constants {
      #|  answer : Int
      #|}
      #|struct Environment {
      #|  constants : Constants
      #|  open constants
      #|}
      #|let : Constants = Constants::{ answer: 42 }
    ),
  )
  inspect(
    @prettyprinter.render(file),
    content=(
      #|struct Constants {
      #|  answer : Int
      #|}
      #|
      #|struct Environment {
      #|  constants : Constants
      #|  open constants
      #|}
      #|
      #|let : Constants = Constants::{
      #|  answer: 42
      #|}
    ),
  )
}

///|
test "parse rejects equals function body syntax" {
  debug_inspect(
    parse_error_kinds("fn add(a : Int, b : Int) -> Int = a + b"),
    content=(
      #|[
      #|  UnexpectedToken(
      #|    { label: "`=`" },
      #|    [{ label: "`{`" }, { label: "`[`" }],
      #|  ),
      #|]
    ),
  )
}

///|
test "parse rejects empty enum variant payload syntax" {
  debug_inspect(
    parse_error_kinds("enum Option[A] { none() some(A) }"),
    content=(
      #|[
      #|  UnexpectedToken(
      #|    { label: "`)`" },
      #|    [{ label: "identifier" }, { label: "`(`" }, { label: "`[`" }],
      #|  ),
      #|]
    ),
  )
}

///|
test "parse rejects empty qualified variant argument syntax" {
  debug_inspect(
    parse_error_kinds(
      (
        #|enum Option[A] { none some(A) }
        #|let value : Option[Int] = Option::none()
      ),
    ),
    content=(
      #|[
      #|  UnexpectedToken(
      #|    { label: "`)`" },
      #|    [
      #|      { label: "integer literal" },
      #|      { label: "string literal" },
      #|      { label: "identifier" },
      #|      { label: "`false`" },
      #|      { label: "`true`" },
      #|      { label: "`fn`" },
      #|      { label: "`if`" },
      #|      { label: "`match`" },
      #|      { label: "`builtin`" },
      #|      { label: "`-`" },
      #|      { label: "`!`" },
      #|      { label: "`(`" },
      #|      { label: "`{`" },
      #|    ],
      #|  ),
      #|]
    ),
  )
}
