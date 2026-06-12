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
fn expect_declaration_typecheck_result(
  source : String,
) -> DeclarationTypeCheckResult {
  let file = expect_parse_ok(source)
  let resolved = @resolve.resolve_source_file(file)
  typecheck_declarations(resolved)
}

///|
fn expect_typecheck_result(source : String) -> TypeCheckResult {
  let file = expect_parse_ok(source)
  let resolved = @resolve.resolve_source_file(file)
  typecheck_source_file(resolved)
}

///|
fn expect_checked_let_initializer(
  source : String,
  name : String,
  expected : @types.Type,
) -> @checked.CheckedExpr {
  let file = expect_parse_ok(source)
  let resolved = @resolve.resolve_source_file(file)
  let declaration_result = typecheck_declarations(resolved)
  let source = @desugar.desugar_source_file(resolved)
  let checker = SemanticChecker::{
    source,
    declarations: declaration_result.declarations,
    diagnostics: declaration_result.diagnostics.copy(),
    values: [],
    value_types: [],
    offers: [],
  }
  checker.collect_top_level_function_types()
  for declaration in source.declarations {
    match declaration {
      Let(declaration) =>
        if declaration.name == Some(name) {
          let checked = checker.check_checked_expr(
            checker.root_scope(),
            declaration.initializer,
            expected,
          )
          guard checked.expression is Some(expression) else {
            abort(@prettyprinter.render(checker.diagnostics, width=100))
          }
          return expression
        } else {
          checker.check_top_level_let(declaration)
        }
      Offer(declaration) => checker.check_top_level_offer(declaration)
      _ => ()
    }
  }
  abort("expected named let")
}

///|
fn expect_first_checked_match_pattern(
  source : String,
  name : String,
) -> @checked.CheckedPattern {
  let file = expect_parse_ok(source)
  let resolved = @resolve.resolve_source_file(file)
  let declaration_result = typecheck_declarations(resolved)
  let source = @desugar.desugar_source_file(resolved)
  let checker = SemanticChecker::{
    source,
    declarations: declaration_result.declarations,
    diagnostics: declaration_result.diagnostics.copy(),
    values: [],
    value_types: [],
    offers: [],
  }
  checker.collect_top_level_function_types()
  for declaration in source.declarations {
    if declaration is Function(declaration) && declaration.name == name {
      let scope = checker.root_scope()
      for parameter in declaration.parameters {
        scope.bind(parameter.symbol, checker.check_type(parameter.type_))
      }
      let body = match declaration.body {
        Block(items=[], result~, ..) => result
        _ => declaration.body
      }
      guard body is Match(scrutinee~, arms~, ..) else {
        abort("expected match body")
      }
      guard !arms.is_empty() else { abort("expected match arm") }
      let scrutinee_type = checker.synthesize_expr(scope, scrutinee)
      let arm_scope = scope.copy()
      return checker.check_match_pattern(
        arm_scope,
        arms[0].pattern,
        scrutinee_type,
      )
    }
  }
  abort("expected function")
}

///|
test "typecheck custom type declaration environment" {
  let result = expect_declaration_typecheck_result(
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
      #|declaration_typecheck_result {
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
test "typecheck builds checked builtin from direct expected type" {
  let expression = expect_checked_let_initializer(
    (
      #|let host_value : Int = builtin("%host_value")
    ),
    "host_value",
    Primitive(Int),
  )
  inspect(
    @prettyprinter.render(expression),
    content="unsafe_builtin \"%host_value\" : Int",
  )
}

///|
test "typecheck parses checked int literal as i64 value" {
  let expression = expect_checked_let_initializer(
    (
      #|let answer : Int = 042
    ),
    "answer",
    Primitive(Int),
  )
  guard expression is Literal(literal=Int(literal), ..) else {
    abort("expected checked int literal")
  }
  @test.assert_eq(literal.raw, "042")
  @test.assert_eq(literal.value, 42L)
}

///|
test "typecheck reports out of range int literal" {
  let result = expect_typecheck_result(
    (
      #|let bad : Int = 9223372036854775808
    ),
  )
  inspect(
    @prettyprinter.render(result.diagnostics[0]),
    content="invalid_int_literal 9223372036854775808 @ 1:17-1:36",
  )
}

///|
test "typecheck inserts contextual auto argument" {
  let expression = expect_checked_let_initializer(
    (
      #|struct Add[A] {
      #|  add : (A, A) -> A
      #|}
      #|fn[A] op_add(a : A, b : A, auto op : Add[A]) -> A {
      #|  op.add(a, b)
      #|}
      #|offer int_add_ops : Add[Int] = builtin("%int_add_ops")
      #|let answer : Int = 1 + 2
    ),
    "answer",
    Primitive(Int),
  )
  inspect(
    @prettyprinter.render(expression, width=100),
    content=(
      #|call : Int {
      #|  callee {
      #|    type_application : (Int, Int, type#0[Int]) -> Int[Int] {
      #|      callee {
      #|        value : forall [tparam#1 A : Type]. (tparam#1, tparam#1, type#0[tparam#1]) -> tparam#1 value#0 op_add
      #|      }
      #|    }
      #|  }
      #|  arguments {
      #|    int 1 : Int
      #|    int 2 : Int
      #|    value : type#0[Int] value#4 int_add_ops
      #|  }
      #|}
    ),
  )
}

///|
test "typecheck accepts explicit named contextual argument" {
  let expression = expect_checked_let_initializer(
    (
      #|struct Add[A] {
      #|  add : (A, A) -> A
      #|}
      #|fn[A] op_add(a : A, b : A, auto op : Add[A]) -> A {
      #|  op.add(a, b)
      #|}
      #|let custom_add : Add[Int] = builtin("%custom_add")
      #|let answer : Int = op_add(1, 2, op=custom_add)
    ),
    "answer",
    Primitive(Int),
  )
  inspect(
    @prettyprinter.render(expression, width=100),
    content=(
      #|call : Int {
      #|  callee {
      #|    type_application : (Int, Int, type#0[Int]) -> Int[Int] {
      #|      callee {
      #|        value : forall [tparam#1 A : Type]. (tparam#1, tparam#1, type#0[tparam#1]) -> tparam#1 value#0 op_add
      #|      }
      #|    }
      #|  }
      #|  arguments {
      #|    int 1 : Int
      #|    int 2 : Int
      #|    value : type#0[Int] value#4 custom_add
      #|  }
      #|}
    ),
  )
}

///|
test "typecheck offer value declaration supplies contextual argument" {
  let expression = expect_checked_let_initializer(
    (
      #|struct Add[A] {
      #|  add : (A, A) -> A
      #|}
      #|fn[A] op_add(a : A, b : A, auto op : Add[A]) -> A {
      #|  op.add(a, b)
      #|}
      #|offer int_add_ops : Add[Int] = builtin("%int_add_ops")
      #|let answer : Int = 1 + 2
    ),
    "answer",
    Primitive(Int),
  )
  inspect(
    @prettyprinter.render(expression, width=100),
    content=(
      #|call : Int {
      #|  callee {
      #|    type_application : (Int, Int, type#0[Int]) -> Int[Int] {
      #|      callee {
      #|        value : forall [tparam#1 A : Type]. (tparam#1, tparam#1, type#0[tparam#1]) -> tparam#1 value#0 op_add
      #|      }
      #|    }
      #|  }
      #|  arguments {
      #|    int 1 : Int
      #|    int 2 : Int
      #|    value : type#0[Int] value#4 int_add_ops
      #|  }
      #|}
    ),
  )
}

///|
test "typecheck auto offer parameter is visible in function body" {
  let result = expect_typecheck_result(
    (
      #|struct Add[A] {
      #|  add : (A, A) -> A
      #|}
      #|fn[A] op_add(a : A, b : A, auto op : Add[A]) -> A {
      #|  op.add(a, b)
      #|}
      #|fn[A] twice(x : A, auto offer op : Add[A]) -> A {
      #|  x + x
      #|}
      #|offer int_add_ops : Add[Int] = builtin("%int_add_ops")
      #|let answer : Int = twice(1)
    ),
  )
  inspect(
    @prettyprinter.render(result, width=100),
    content=(
      #|typecheck_result {
      #|  checked_declarations {
      #|    types {
      #|      struct type#0 Add[tparam#0 A : Type] {
      #|        field field#0 add : (tparam#0, tparam#0) -> tparam#0 index=0
      #|      }
      #|    }
      #|    fields {
      #|      field field#0 add : (tparam#0, tparam#0) -> tparam#0 index=0
      #|    }
      #|    variants {}
      #|  }
      #|  checked_values {
      #|    fn value#0 op_add : forall [
      #|      tparam#1 A : Type
      #|    ]. (tparam#1, tparam#1, type#0[tparam#1]) -> tparam#1
      #|    fn value#1 twice : forall [tparam#2 A : Type]. (tparam#2, type#0[tparam#2]) -> tparam#2
      #|    let value#7 int_add_ops : type#0[Int]
      #|    let value#8 answer : Int
      #|  }
      #|  diagnostics {}
      #|}
    ),
  )
}

///|
test "typecheck forwards offered struct fields" {
  let expression = expect_checked_let_initializer(
    (
      #|struct Equal[A] {
      #|  equal : (A, A) -> Bool
      #|}
      #|struct Compare[A] {
      #|  offer equal_impl : Equal[A]
      #|}
      #|fn[A] op_equal(a : A, b : A, auto op : Equal[A]) -> Bool {
      #|  op.equal(a, b)
      #|}
      #|offer int_compare_ops : Compare[Int] = builtin("%int_compare_ops")
      #|let answer : Bool = 1 == 2
    ),
    "answer",
    Primitive(Bool),
  )
  inspect(
    @prettyprinter.render(expression, width=100),
    content=(
      #|call : Bool {
      #|  callee {
      #|    type_application : (Int, Int, type#0[Int]) -> Bool[Int] {
      #|      callee {
      #|        value : forall [tparam#2 A : Type]. (tparam#2, tparam#2, type#0[tparam#2]) -> Bool value#0 op_equal
      #|      }
      #|    }
      #|  }
      #|  arguments {
      #|    int 1 : Int
      #|    int 2 : Int
      #|    field : type#0[Int] field#1 equal_impl {
      #|      base {
      #|        value : type#1[Int] value#4 int_compare_ops
      #|      }
      #|    }
      #|  }
      #|}
    ),
  )
}

///|
test "typecheck local offer value declaration supplies contextual argument" {
  let expression = expect_checked_let_initializer(
    (
      #|struct Add[A] {
      #|  add : (A, A) -> A
      #|}
      #|fn[A] op_add(a : A, b : A, auto op : Add[A]) -> A {
      #|  op.add(a, b)
      #|}
      #|let answer : Int = {
      #|  offer int_add_ops : Add[Int] = builtin("%int_add_ops")
      #|  1 + 2
      #|}
    ),
    "answer",
    Primitive(Int),
  )
  inspect(
    @prettyprinter.render(expression, width=100),
    content=(
      #|block : Int {
      #|  let : type#0[Int] value#4 int_add_ops {
      #|    unsafe_builtin "%int_add_ops" : type#0[Int]
      #|  }
      #|  result {
      #|    call : Int {
      #|      callee {
      #|        type_application : (Int, Int, type#0[Int]) -> Int[Int] {
      #|          callee {
      #|            value : forall [tparam#1 A : Type]. (tparam#1, tparam#1, type#0[tparam#1]) -> tparam#1 value#0 op_add
      #|          }
      #|        }
      #|      }
      #|      arguments {
      #|        int 1 : Int
      #|        int 2 : Int
      #|        value : type#0[Int] value#4 int_add_ops
      #|      }
      #|    }
      #|  }
      #|}
    ),
  )
}

///|
test "typecheck reports missing contextual offer" {
  let result = expect_typecheck_result(
    (
      #|struct Add[A] {
      #|  add : (A, A) -> A
      #|}
      #|fn[A] op_add(a : A, b : A, auto op : Add[A]) -> A {
      #|  op.add(a, b)
      #|}
      #|let answer : Int = 1 + 2
    ),
  )
  inspect(
    @prettyprinter.render(result, width=100),
    content=(
      #|typecheck_result {
      #|  checked_declarations {
      #|    types {
      #|      struct type#0 Add[tparam#0 A : Type] {
      #|        field field#0 add : (tparam#0, tparam#0) -> tparam#0 index=0
      #|      }
      #|    }
      #|    fields {
      #|      field field#0 add : (tparam#0, tparam#0) -> tparam#0 index=0
      #|    }
      #|    variants {}
      #|  }
      #|  checked_values {
      #|    fn value#0 op_add : forall [
      #|      tparam#1 A : Type
      #|    ]. (tparam#1, tparam#1, type#0[tparam#1]) -> tparam#1
      #|    let value#4 answer : Int
      #|  }
      #|  diagnostics {
      #|    cannot_infer missing contextual offer @ 7:24-7:25
      #|  }
      #|}
    ),
  )
}

///|
test "typecheck reports ambiguous contextual offer" {
  let result = expect_typecheck_result(
    (
      #|struct Add[A] {
      #|  add : (A, A) -> A
      #|}
      #|fn[A] op_add(a : A, b : A, auto op : Add[A]) -> A {
      #|  op.add(a, b)
      #|}
      #|offer add_a : Add[Int] = builtin("%add_a")
      #|offer add_b : Add[Int] = builtin("%add_b")
      #|let answer : Int = 1 + 2
    ),
  )
  inspect(
    @prettyprinter.render(result, width=100),
    content=(
      #|typecheck_result {
      #|  checked_declarations {
      #|    types {
      #|      struct type#0 Add[tparam#0 A : Type] {
      #|        field field#0 add : (tparam#0, tparam#0) -> tparam#0 index=0
      #|      }
      #|    }
      #|    fields {
      #|      field field#0 add : (tparam#0, tparam#0) -> tparam#0 index=0
      #|    }
      #|    variants {}
      #|  }
      #|  checked_values {
      #|    fn value#0 op_add : forall [
      #|      tparam#1 A : Type
      #|    ]. (tparam#1, tparam#1, type#0[tparam#1]) -> tparam#1
      #|    let value#4 add_a : type#0[Int]
      #|    let value#5 add_b : type#0[Int]
      #|    let value#6 answer : Int
      #|  }
      #|  diagnostics {
      #|    cannot_infer ambiguous contextual offer @ 9:24-9:25
      #|  }
      #|}
    ),
  )
}

///|
test "typecheck top level values and direct calls" {
  let result = expect_typecheck_result(
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
      #|typecheck_result {
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
test "typecheck top level functions recurse and values stay ordered" {
  let result = expect_typecheck_result(
    (
      #|fn first(value : Int) -> Int {
      #|  second(value)
      #|}
      #|let base : Int = 1
      #|fn second(value : Int) -> Int {
      #|  first(value)
      #|}
      #|let copied : Int = base
      #|fn use() -> Int {
      #|  copied
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result, width=100),
    content=(
      #|typecheck_result {
      #|  checked_declarations {
      #|    types {}
      #|    fields {}
      #|    variants {}
      #|  }
      #|  checked_values {
      #|    fn value#0 first : (Int) -> Int
      #|    fn value#1 second : (Int) -> Int
      #|    fn value#2 use : () -> Int
      #|    let value#4 base : Int
      #|    let value#6 copied : Int
      #|  }
      #|  diagnostics {}
      #|}
    ),
  )
}

///|
test "typecheck reports forward top level value use" {
  let result = expect_typecheck_result(
    (
      #|let first : Int = second
      #|let second : Int = 1
    ),
  )
  inspect(
    @prettyprinter.render(result.diagnostics[0]),
    content="unresolved_value second @ 1:19-1:25",
  )
}

///|
test "typecheck local bindings are sequential and local functions see prior scope" {
  let result = expect_typecheck_result(
    (
      #|fn use() -> Int {
      #|  {
      #|    let base = 1
      #|    fn local(value : Int) -> Int {
      #|      base
      #|    }
      #|    local(2)
      #|  }
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result, width=100),
    content=(
      #|typecheck_result {
      #|  checked_declarations {
      #|    types {}
      #|    fields {}
      #|    variants {}
      #|  }
      #|  checked_values {
      #|    fn value#0 use : () -> Int
      #|  }
      #|  diagnostics {}
      #|}
    ),
  )
}

///|
test "typecheck local function can call itself after declaration" {
  let result = expect_typecheck_result(
    (
      #|fn use() -> Int {
      #|  {
      #|    fn loop(value : Int) -> Int {
      #|      loop(value)
      #|    }
      #|    loop(1)
      #|  }
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result, width=100),
    content=(
      #|typecheck_result {
      #|  checked_declarations {
      #|    types {}
      #|    fields {}
      #|    variants {}
      #|  }
      #|  checked_values {
      #|    fn value#0 use : () -> Int
      #|  }
      #|  diagnostics {}
      #|}
    ),
  )
}

///|
test "typecheck reports local function forward reference" {
  let result = expect_typecheck_result(
    (
      #|fn use() -> Int {
      #|  {
      #|    let result = local(1)
      #|    fn local(value : Int) -> Int {
      #|      value
      #|    }
      #|    result
      #|  }
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result.diagnostics[0]),
    content="unresolved_value local @ 3:18-3:23",
  )
}

///|
test "typecheck local generic function after declaration" {
  let result = expect_typecheck_result(
    (
      #|fn use() -> Int {
      #|  {
      #|    fn[A] id(value : A) -> A {
      #|      value
      #|    }
      #|    id(1)
      #|  }
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result, width=100),
    content=(
      #|typecheck_result {
      #|  checked_declarations {
      #|    types {}
      #|    fields {}
      #|    variants {}
      #|  }
      #|  checked_values {
      #|    fn value#0 use : () -> Int
      #|  }
      #|  diagnostics {}
      #|}
    ),
  )
}

///|
test "typecheck direct binary operator alias" {
  let result = expect_typecheck_result(
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
      #|typecheck_result {
      #|  checked_declarations {
      #|    types {}
      #|    fields {}
      #|    variants {}
      #|  }
      #|  checked_values {
      #|    fn value#0 op_add : (Int, Int) -> Int
      #|    fn value#1 use : () -> Int
      #|  }
      #|  diagnostics {}
      #|}
    ),
  )
}

///|
test "typecheck direct binary operator result mismatch" {
  let result = expect_typecheck_result(
    (
      #|fn op_add(a : Int, b : Int) -> Bool {
      #|  true
      #|}
      #|fn use() -> Int {
      #|  1 + 2
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result.diagnostics[0]),
    content="type_mismatch expected=Int actual=Bool @ 5:7-5:8",
  )
}

///|
test "typecheck direct unary operator alias" {
  let result = expect_typecheck_result(
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
      #|typecheck_result {
      #|  checked_declarations {
      #|    types {}
      #|    fields {}
      #|    variants {}
      #|  }
      #|  checked_values {
      #|    fn value#0 op_neg : (Int) -> Int
      #|    fn value#1 use : () -> Int
      #|  }
      #|  diagnostics {}
      #|}
    ),
  )
}

///|
test "typecheck function literal parameters from expected function type" {
  let result = expect_typecheck_result(
    (
      #|fn apply(callback : (Int) -> Int) -> Int {
      #|  callback(1)
      #|}
      #|fn use() -> Int {
      #|  apply(fn(value) {
      #|    value
      #|  })
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result, width=100),
    content=(
      #|typecheck_result {
      #|  checked_declarations {
      #|    types {}
      #|    fields {}
      #|    variants {}
      #|  }
      #|  checked_values {
      #|    fn value#0 apply : ((Int) -> Int) -> Int
      #|    fn value#1 use : () -> Int
      #|  }
      #|  diagnostics {}
      #|}
    ),
  )
}

///|
test "typecheck pipeline expression as first argument call" {
  let result = expect_typecheck_result(
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
      #|typecheck_result {
      #|  checked_declarations {
      #|    types {}
      #|    fields {}
      #|    variants {}
      #|  }
      #|  checked_values {
      #|    fn value#0 first : (Int, Int) -> Int
      #|    fn value#1 use : () -> Int
      #|  }
      #|  diagnostics {}
      #|}
    ),
  )
}

///|
test "typecheck pipeline expression into function literal" {
  let result = expect_typecheck_result(
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
      #|typecheck_result {
      #|  checked_declarations {
      #|    types {}
      #|    fields {}
      #|    variants {}
      #|  }
      #|  checked_values {
      #|    fn value#0 use : () -> Int
      #|  }
      #|  diagnostics {}
      #|}
    ),
  )
}

///|
test "typecheck generic function literal parameters from expected forall type" {
  let result = expect_typecheck_result(
    (
      #|let id : [A](A) -> A = fn[A](value) {
      #|  value
      #|}
      #|fn use() -> Int {
      #|  id(1)
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result, width=100),
    content=(
      #|typecheck_result {
      #|  checked_declarations {
      #|    types {}
      #|    fields {}
      #|    variants {}
      #|  }
      #|  checked_values {
      #|    fn value#0 use : () -> Int
      #|    let value#2 id : forall [tparam#1 A : Type]. (tparam#1) -> tparam#1
      #|  }
      #|  diagnostics {}
      #|}
    ),
  )
}

///|
test "typecheck reports generic function literal arity mismatch" {
  let result = expect_typecheck_result(
    (
      #|let id : [A](A) -> A = fn(value) {
      #|  value
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result.diagnostics[0]),
    content="cannot_infer generic function arity @ 1:26-3:2",
  )
}

///|
test "typecheck reports generic literal against non-generic function type" {
  let result = expect_typecheck_result(
    (
      #|let id : (Int) -> Int = fn[A](value : A) -> A {
      #|  value
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result.diagnostics[0]),
    content="cannot_infer generic function arity @ 1:27-3:2",
  )
}

///|
test "typecheck synthesizes direct generic call from argument type" {
  let result = expect_typecheck_result(
    (
      #|fn[A] id(value : A) -> A {
      #|  value
      #|}
      #|fn use() -> Int {
      #|  id(1)
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result, width=100),
    content=(
      #|typecheck_result {
      #|  checked_declarations {
      #|    types {}
      #|    fields {}
      #|    variants {}
      #|  }
      #|  checked_values {
      #|    fn value#0 id : forall [tparam#0 A : Type]. (tparam#0) -> tparam#0
      #|    fn value#1 use : () -> Int
      #|  }
      #|  diagnostics {}
      #|}
    ),
  )
}

///|
test "typecheck generic call uses expected result type" {
  let result = expect_typecheck_result(
    (
      #|fn[A] make() -> A {
      #|  builtin("%make")
      #|}
      #|fn use() -> Int {
      #|  make()
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result, width=100),
    content=(
      #|typecheck_result {
      #|  checked_declarations {
      #|    types {}
      #|    fields {}
      #|    variants {}
      #|  }
      #|  checked_values {
      #|    fn value#0 make : forall [tparam#0 A : Type]. () -> tparam#0
      #|    fn value#1 use : () -> Int
      #|  }
      #|  diagnostics {}
      #|}
    ),
  )
}

///|
test "typecheck generic call drives function literal argument" {
  let result = expect_typecheck_result(
    (
      #|fn[A] apply(callback : (A) -> A, value : A) -> A {
      #|  callback(value)
      #|}
      #|fn use() -> Int {
      #|  apply(fn(value) {
      #|    value
      #|  }, 1)
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result, width=100),
    content=(
      #|typecheck_result {
      #|  checked_declarations {
      #|    types {}
      #|    fields {}
      #|    variants {}
      #|  }
      #|  checked_values {
      #|    fn value#0 apply : forall [tparam#0 A : Type]. ((tparam#0) -> tparam#0, tparam#0) -> tparam#0
      #|    fn value#1 use : () -> Int
      #|  }
      #|  diagnostics {}
      #|}
    ),
  )
}

///|
test "typecheck polymorphic function parameter instantiation" {
  let result = expect_typecheck_result(
    (
      #|fn[B] apply(f : [A](A) -> A, x : B) -> B {
      #|  f(x)
      #|}
      #|fn[A] id(value : A) -> A {
      #|  value
      #|}
      #|fn use() -> Int {
      #|  apply(id, 1)
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result, width=100),
    content=(
      #|typecheck_result {
      #|  checked_declarations {
      #|    types {}
      #|    fields {}
      #|    variants {}
      #|  }
      #|  checked_values {
      #|    fn value#0 apply : forall [
      #|      tparam#0 B : Type
      #|    ]. (forall [tparam#1 A : Type]. (tparam#1) -> tparam#1, tparam#0) -> tparam#0
      #|    fn value#1 id : forall [tparam#2 A : Type]. (tparam#2) -> tparam#2
      #|    fn value#2 use : () -> Int
      #|  }
      #|  diagnostics {}
      #|}
    ),
  )
}

///|
test "typecheck reports unresolved generic type arguments" {
  let result = expect_typecheck_result(
    (
      #|fn[A] make() -> A {
      #|  builtin("%make")
      #|}
      #|fn use() -> Bool {
      #|  {
      #|    let value = make()
      #|    true
      #|  }
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result.diagnostics[0]),
    content="cannot_infer type arguments @ 6:22-6:23",
  )
}

///|
test "typecheck generic struct construction and field access" {
  let result = expect_typecheck_result(
    (
      #|struct Box[A] {
      #|  value : A
      #|}
      #|fn use() -> Int {
      #|  {
      #|    let box = Box[Int]::{ value: 1 }
      #|    box.value
      #|  }
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result, width=100),
    content=(
      #|typecheck_result {
      #|  checked_declarations {
      #|    types {
      #|      struct type#0 Box[tparam#0 A : Type] {
      #|        field field#0 value : tparam#0 index=0
      #|      }
      #|    }
      #|    fields {
      #|      field field#0 value : tparam#0 index=0
      #|    }
      #|    variants {}
      #|  }
      #|  checked_values {
      #|    fn value#0 use : () -> Int
      #|  }
      #|  diagnostics {}
      #|}
    ),
  )
}

///|
test "typecheck reports field access on non-struct value" {
  let result = expect_typecheck_result(
    (
      #|fn bad() -> Int {
      #|  1.value
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result.diagnostics[0]),
    content="not_a_struct Int @ 2:5-2:10",
  )
}

///|
test "typecheck qualified enum variant construction" {
  let result = expect_typecheck_result(
    (
      #|enum Option[A] {
      #|  none
      #|  some(A)
      #|}
      #|fn wrap(value : Int) -> Option[Int] {
      #|  Option::some(value)
      #|}
      #|fn empty() -> Option[Int] {
      #|  Option::none
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result, width=100),
    content=(
      #|typecheck_result {
      #|  checked_declarations {
      #|    types {
      #|      enum type#0 Option[tparam#0 A : Type] {
      #|        variant variant#0 none index=0 payloads=0
      #|        variant variant#1 some index=1 payloads=1(tparam#0)
      #|      }
      #|    }
      #|    fields {}
      #|    variants {
      #|      variant variant#0 none index=0 payloads=0
      #|      variant variant#1 some index=1 payloads=1(tparam#0)
      #|    }
      #|  }
      #|  checked_values {
      #|    fn value#0 wrap : (Int) -> type#0[Int]
      #|    fn value#1 empty : () -> type#0[Int]
      #|  }
      #|  diagnostics {}
      #|}
    ),
  )
}

///|
test "typecheck unqualified enum variant construction" {
  let result = expect_typecheck_result(
    (
      #|enum Option[A] {
      #|  none
      #|  some(A)
      #|}
      #|fn wrap(value : Int) -> Option[Int] {
      #|  some(value)
      #|}
      #|fn empty() -> Option[Int] {
      #|  none()
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result, width=100),
    content=(
      #|typecheck_result {
      #|  checked_declarations {
      #|    types {
      #|      enum type#0 Option[tparam#0 A : Type] {
      #|        variant variant#0 none index=0 payloads=0
      #|        variant variant#1 some index=1 payloads=1(tparam#0)
      #|      }
      #|    }
      #|    fields {}
      #|    variants {
      #|      variant variant#0 none index=0 payloads=0
      #|      variant variant#1 some index=1 payloads=1(tparam#0)
      #|    }
      #|  }
      #|  checked_values {
      #|    fn value#0 wrap : (Int) -> type#0[Int]
      #|    fn value#1 empty : () -> type#0[Int]
      #|  }
      #|  diagnostics {}
      #|}
    ),
  )
}

///|
test "typecheck reports unresolved variant type arguments" {
  let result = expect_typecheck_result(
    (
      #|enum Option[A] {
      #|  none
      #|  some(A)
      #|}
      #|fn use() -> Bool {
      #|  {
      #|    let value = none()
      #|    true
      #|  }
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result.diagnostics[0]),
    content="cannot_infer type arguments @ 7:22-7:23",
  )
}

///|
test "typecheck reports enum variant payload mismatch" {
  let result = expect_typecheck_result(
    (
      #|enum Option[A] {
      #|  none
      #|  some(A)
      #|}
      #|fn bad() -> Option[Int] {
      #|  some(true)
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result.diagnostics[0]),
    content="type_mismatch expected=Int actual=Bool @ 6:8-6:12",
  )
}

///|
test "typecheck reports enum variant arity mismatch" {
  let result = expect_typecheck_result(
    (
      #|enum Option[A] {
      #|  none
      #|  some(A)
      #|}
      #|fn bad() -> Option[Int] {
      #|  some()
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result.diagnostics[0]),
    content="cannot_infer variant arity @ 6:8-6:9",
  )
}

///|
test "typecheck reports ambiguous unqualified enum variant" {
  let result = expect_typecheck_result(
    (
      #|enum Left {
      #|  same(Int)
      #|}
      #|enum Right {
      #|  same(Int)
      #|}
      #|fn bad() -> Left {
      #|  same(1)
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result.diagnostics[0]),
    content="cannot_infer ambiguous variant reference same @ 8:9-8:10",
  )
}

///|
test "typecheck exhaustive enum match" {
  let result = expect_typecheck_result(
    (
      #|enum Option[A] {
      #|  none
      #|  some(A)
      #|}
      #|fn unwrap(value : Option[Int], fallback : Int) -> Int {
      #|  match value {
      #|    Option::none => fallback
      #|    Option::some(x) => x
      #|  }
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result, width=100),
    content=(
      #|typecheck_result {
      #|  checked_declarations {
      #|    types {
      #|      enum type#0 Option[tparam#0 A : Type] {
      #|        variant variant#0 none index=0 payloads=0
      #|        variant variant#1 some index=1 payloads=1(tparam#0)
      #|      }
      #|    }
      #|    fields {}
      #|    variants {
      #|      variant variant#0 none index=0 payloads=0
      #|      variant variant#1 some index=1 payloads=1(tparam#0)
      #|    }
      #|  }
      #|  checked_values {
      #|    fn value#0 unwrap : (type#0[Int], Int) -> Int
      #|  }
      #|  diagnostics {}
      #|}
    ),
  )
}

///|
test "typecheck reports non-exhaustive bool match" {
  let result = expect_typecheck_result(
    (
      #|fn bad(value : Bool) -> Int {
      #|  match value {
      #|    true => 1
      #|  }
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result.diagnostics[0]),
    content="non_exhaustive_match Bool @ 2:15-4:4",
  )
}

///|
test "typecheck reports unreachable match arm" {
  let result = expect_typecheck_result(
    (
      #|fn bad(value : Bool) -> Int {
      #|  match value {
      #|    _ => 1
      #|    true => 2
      #|  }
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result.diagnostics[0]),
    content="unreachable_match_arm @ 4:13-4:14",
  )
}

///|
test "typecheck compares int patterns by checked value" {
  let result = expect_typecheck_result(
    (
      #|fn bad(value : Int) -> Int {
      #|  match value {
      #|    1 => 1
      #|    01 => 2
      #|    _ => 0
      #|  }
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result.diagnostics[0]),
    content="unreachable_match_arm @ 4:11-4:12",
  )
}

///|
test "typecheck reports duplicate pattern binder" {
  let result = expect_typecheck_result(
    (
      #|enum Pair {
      #|  pair(Int, Int)
      #|}
      #|fn bad(value : Pair) -> Int {
      #|  match value {
      #|    Pair::pair(x, x) => x
      #|  }
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result.diagnostics[0]),
    content="duplicate_pattern_binder x @ 6:19-6:20",
  )
}

///|
test "typecheck reports missing struct pattern field" {
  let result = expect_typecheck_result(
    (
      #|struct Point {
      #|  x : Int
      #|  y : Int
      #|}
      #|fn bad(point : Point) -> Int {
      #|  match point {
      #|    Point::{ x } => x
      #|  }
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result.diagnostics[0]),
    content="missing_field y @ 7:16-7:17",
  )
}

///|
test "typecheck produces checked struct pattern fields in declaration order" {
  let pattern = expect_first_checked_match_pattern(
    (
      #|struct Point {
      #|  x : Int
      #|  y : Int
      #|}
      #|fn use(point : Point) -> Int {
      #|  match point {
      #|    Point::{ y, x } => x
      #|  }
      #|}
    ),
    "use",
  )
  inspect(
    @prettyprinter.render(pattern, width=100),
    content=(
      #|struct_pattern : type#0 type#0 {
      #|  field_pattern field#0 x {
      #|    binding : Int value#3 x
      #|  }
      #|  field_pattern field#1 y {
      #|    binding : Int value#2 y
      #|  }
      #|}
    ),
  )
}

///|
test "typecheck reports type mismatch" {
  let result = expect_typecheck_result(
    (
      #|fn bad() -> Int {
      #|  true
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result.diagnostics[0]),
    content="type_mismatch expected=Int actual=Bool @ 2:3-2:7",
  )
}

///|
test "typecheck struct literal punning and required fields" {
  let result = expect_typecheck_result(
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
    content="missing_field y @ 6:14-6:15",
  )
}

///|
test "typecheck reports nominal type arity mismatch" {
  let result = expect_declaration_typecheck_result(
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
    content="type_arity_mismatch Box expected=1 actual=2 @ 5:16-5:26",
  )
}

///|
test "typecheck keeps unresolved type as error type" {
  let result = expect_declaration_typecheck_result(
    (
      #|struct Bad {
      #|  missing : Missing
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result, width=100),
    content=(
      #|declaration_typecheck_result {
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
      #|    unresolved_type Missing @ 2:13-2:20
      #|  }
      #|}
    ),
  )
}
