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
