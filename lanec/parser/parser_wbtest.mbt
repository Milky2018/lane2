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
fn parse_error_messages(source : String) -> Array[String] {
  let result = parse_string(source)
  if !result.lexical_errors.is_empty() {
    abort("expected parser errors, got lexer errors")
  }
  result.parse_errors.map(fn(error) { error.message })
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
  inspect(
    @prettyprinter.render(
      parse_error_messages("fn add(a : Int, b : Int) -> Int = a + b"),
    ),
    content=(
      #|["Unexpected token."]
    ),
  )
}

///|
test "parse rejects empty enum variant payload syntax" {
  inspect(
    @prettyprinter.render(
      parse_error_messages("enum Option[A] { none() some(A) }"),
    ),
    content=(
      #|["Unexpected token."]
    ),
  )
}

///|
test "parse rejects empty qualified variant argument syntax" {
  inspect(
    @prettyprinter.render(
      parse_error_messages(
        (
          #|enum Option[A] { none some(A) }
          #|let value : Option[Int] = Option::none()
        ),
      ),
    ),
    content=(
      #|["Unexpected token."]
    ),
  )
}
