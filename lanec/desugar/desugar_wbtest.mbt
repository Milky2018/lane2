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
fn desugar_source(source : String) -> DesugaredSourceFile {
  let file = expect_parse_ok(source)
  let resolved = @resolve.resolve_source_file(file)
  desugar_source_file(resolved)
}

///|
test "desugar operators and pipeline into ordinary calls" {
  let source = desugar_source(
    (
      #|fn op_add(a : Int, b : Int) -> Int {
      #|  a
      #|}
      #|fn first(a : Int, b : Int) -> Int {
      #|  a
      #|}
      #|fn use() -> Int {
      #|  1 + 2 |> first(3)
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(source, width=100),
    content=(
      #|desugared_source {
      #|  fn value#0 op_add {
      #|    body {
      #|      {
      #|        var value#3 a
      #|      }
      #|    }
      #|  }
      #|  fn value#1 first {
      #|    body {
      #|      {
      #|        var value#5 a
      #|      }
      #|    }
      #|  }
      #|  fn value#2 use {
      #|    body {
      #|      {
      #|        var value#1 first(var value#0 op_add(1, 2), 3)
      #|      }
      #|    }
      #|  }
      #|}
    ),
  )
}

///|
test "desugar lazy bool operators into thunked ordinary calls" {
  let source = desugar_source(
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
    @prettyprinter.render(source, width=100),
    content=(
      #|desugared_source {
      #|  fn value#0 op_and {
      #|    body {
      #|      {
      #|        var value#2 a
      #|      }
      #|    }
      #|  }
      #|  fn value#1 use {
      #|    body {
      #|      {
      #|        var value#0 op_and(var value#4 a, fn() -> Bool var value#5 b)
      #|      }
      #|    }
      #|  }
      #|}
    ),
  )
}
