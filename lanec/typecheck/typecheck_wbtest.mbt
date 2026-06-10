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
  let checker = SemanticChecker::{
    source: resolved,
    declarations: declaration_result.declarations,
    diagnostics: declaration_result.diagnostics.copy(),
    values: [],
    value_types: [],
  }
  checker.collect_top_level_function_types()
  for declaration in resolved.declarations {
    if declaration is Let(declaration) {
      if declaration.name == Some(name) {
        let checked = checker.check_checked_expr(
          checker.root_scope(),
          declaration.initializer,
          expected,
        )
        guard checked.expression is Some(expression) else {
          abort("expected checked expression")
        }
        return expression
      } else {
        checker.check_top_level_let(declaration)
      }
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
  let checker = SemanticChecker::{
    source: resolved,
    declarations: declaration_result.declarations,
    diagnostics: declaration_result.diagnostics.copy(),
    values: [],
    value_types: [],
  }
  checker.collect_top_level_function_types()
  for declaration in resolved.declarations {
    if declaration is Function(declaration) && declaration.name == name {
      let scope = checker.root_scope()
      for parameter in declaration.parameters {
        scope.bind(
          parameter.symbol,
          parameter.name,
          checker.check_type(parameter.type_),
        )
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
      let arm_scope : TypeScope = { values: scope.values.copy() }
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
test "typecheck builds checked opened field candidate by expected type" {
  let expression = expect_checked_let_initializer(
    (
      #|struct IntSource {
      #|  value : Int
      #|}
      #|struct BoolSource {
      #|  value : Bool
      #|}
      #|let int_source : IntSource = IntSource::{ value: 1 }
      #|let bool_source : BoolSource = BoolSource::{ value: true }
      #|open int_source
      #|open bool_source
      #|let selected : Int = value
    ),
    "selected",
    Primitive(Int),
  )
  inspect(
    @prettyprinter.render(expression, width=100),
    content=(
      #|field : Int field#0 value {
      #|  base {
      #|    value : type#0 value#0 int_source
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
    content="unresolved_value second",
  )
}

///|
test "typecheck local let inference and opened field reference" {
  let result = expect_typecheck_result(
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
      #|typecheck_result {
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
    content="unresolved_value local",
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
test "typecheck selects open candidate by expected type" {
  let result = expect_typecheck_result(
    (
      #|struct IntSource {
      #|  value : Int
      #|}
      #|struct BoolSource {
      #|  value : Bool
      #|}
      #|let int_source : IntSource = IntSource::{ value: 1 }
      #|let bool_source : BoolSource = BoolSource::{ value: true }
      #|open int_source
      #|open bool_source
      #|fn use() -> Int {
      #|  value
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result, width=100),
    content=(
      #|typecheck_result {
      #|  checked_declarations {
      #|    types {
      #|      struct type#0 IntSource {
      #|        field field#0 value : Int index=0
      #|      }
      #|      struct type#1 BoolSource {
      #|        field field#1 value : Bool index=0
      #|      }
      #|    }
      #|    fields {
      #|      field field#0 value : Int index=0
      #|      field field#1 value : Bool index=0
      #|    }
      #|    variants {}
      #|  }
      #|  checked_values {
      #|    fn value#0 use : () -> Int
      #|    let value#1 int_source : type#0
      #|    let value#2 bool_source : type#1
      #|  }
      #|  diagnostics {}
      #|}
    ),
  )
}

///|
test "typecheck keeps same typed open candidates ambiguous" {
  let result = expect_typecheck_result(
    (
      #|struct Left {
      #|  value : Int
      #|}
      #|struct Right {
      #|  value : Int
      #|}
      #|let left : Left = Left::{ value: 1 }
      #|let right : Right = Right::{ value: 2 }
      #|open left
      #|open right
      #|fn use() -> Int {
      #|  value
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result.diagnostics[0]),
    content="cannot_infer ambiguous value reference value",
  )
}

///|
test "typecheck selects callable open candidate by argument types" {
  let result = expect_typecheck_result(
    (
      #|struct IntOps {
      #|  op_add : (Int, Int) -> Int
      #|}
      #|struct BoolOps {
      #|  op_add : (Bool, Bool) -> Bool
      #|}
      #|fn int_add(a : Int, b : Int) -> Int {
      #|  a
      #|}
      #|fn bool_add(a : Bool, b : Bool) -> Bool {
      #|  a
      #|}
      #|let int_ops : IntOps = IntOps::{ op_add: int_add }
      #|let bool_ops : BoolOps = BoolOps::{ op_add: bool_add }
      #|open int_ops
      #|open bool_ops
      #|fn use() -> Int {
      #|  op_add(1, 2)
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result, width=100),
    content=(
      #|typecheck_result {
      #|  checked_declarations {
      #|    types {
      #|      struct type#0 IntOps {
      #|        field field#0 op_add : (Int, Int) -> Int index=0
      #|      }
      #|      struct type#1 BoolOps {
      #|        field field#1 op_add : (Bool, Bool) -> Bool index=0
      #|      }
      #|    }
      #|    fields {
      #|      field field#0 op_add : (Int, Int) -> Int index=0
      #|      field field#1 op_add : (Bool, Bool) -> Bool index=0
      #|    }
      #|    variants {}
      #|  }
      #|  checked_values {
      #|    fn value#0 int_add : (Int, Int) -> Int
      #|    fn value#1 bool_add : (Bool, Bool) -> Bool
      #|    fn value#2 use : () -> Int
      #|    let value#7 int_ops : type#0
      #|    let value#8 bool_ops : type#1
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
    content="type_mismatch expected=Int actual=Bool",
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
test "typecheck selects open binary operator candidate by argument types" {
  let result = expect_typecheck_result(
    (
      #|struct IntOps {
      #|  op_add : (Int, Int) -> Int
      #|}
      #|struct BoolOps {
      #|  op_add : (Bool, Bool) -> Bool
      #|}
      #|fn int_add(a : Int, b : Int) -> Int {
      #|  a
      #|}
      #|fn bool_add(a : Bool, b : Bool) -> Bool {
      #|  a
      #|}
      #|let int_ops : IntOps = IntOps::{ op_add: int_add }
      #|let bool_ops : BoolOps = BoolOps::{ op_add: bool_add }
      #|open int_ops
      #|open bool_ops
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
      #|    types {
      #|      struct type#0 IntOps {
      #|        field field#0 op_add : (Int, Int) -> Int index=0
      #|      }
      #|      struct type#1 BoolOps {
      #|        field field#1 op_add : (Bool, Bool) -> Bool index=0
      #|      }
      #|    }
      #|    fields {
      #|      field field#0 op_add : (Int, Int) -> Int index=0
      #|      field field#1 op_add : (Bool, Bool) -> Bool index=0
      #|    }
      #|    variants {}
      #|  }
      #|  checked_values {
      #|    fn value#0 int_add : (Int, Int) -> Int
      #|    fn value#1 bool_add : (Bool, Bool) -> Bool
      #|    fn value#2 use : () -> Int
      #|    let value#7 int_ops : type#0
      #|    let value#8 bool_ops : type#1
      #|  }
      #|  diagnostics {}
      #|}
    ),
  )
}

///|
test "typecheck keeps same typed binary operator candidates ambiguous" {
  let result = expect_typecheck_result(
    (
      #|struct LeftOps {
      #|  op_add : (Int, Int) -> Int
      #|}
      #|struct RightOps {
      #|  op_add : (Int, Int) -> Int
      #|}
      #|fn left_add(a : Int, b : Int) -> Int {
      #|  a
      #|}
      #|fn right_add(a : Int, b : Int) -> Int {
      #|  b
      #|}
      #|let left_ops : LeftOps = LeftOps::{ op_add: left_add }
      #|let right_ops : RightOps = RightOps::{ op_add: right_add }
      #|open left_ops
      #|open right_ops
      #|fn use() -> Int {
      #|  1 + 2
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result.diagnostics[0]),
    content="cannot_infer ambiguous value reference op_add",
  )
}

///|
test "typecheck selects open candidate in if branches by expected type" {
  let result = expect_typecheck_result(
    (
      #|struct IntSource {
      #|  value : Int
      #|}
      #|struct BoolSource {
      #|  value : Bool
      #|}
      #|let int_source : IntSource = IntSource::{ value: 1 }
      #|let bool_source : BoolSource = BoolSource::{ value: true }
      #|open int_source
      #|open bool_source
      #|fn use(flag : Bool) -> Int {
      #|  if flag {
      #|    value
      #|  } else {
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
      #|    types {
      #|      struct type#0 IntSource {
      #|        field field#0 value : Int index=0
      #|      }
      #|      struct type#1 BoolSource {
      #|        field field#1 value : Bool index=0
      #|      }
      #|    }
      #|    fields {
      #|      field field#0 value : Int index=0
      #|      field field#1 value : Bool index=0
      #|    }
      #|    variants {}
      #|  }
      #|  checked_values {
      #|    fn value#0 use : (Bool) -> Int
      #|    let value#1 int_source : type#0
      #|    let value#2 bool_source : type#1
      #|  }
      #|  diagnostics {}
      #|}
    ),
  )
}

///|
test "typecheck selects argument candidate from known function parameter type" {
  let result = expect_typecheck_result(
    (
      #|struct IntSource {
      #|  value : Int
      #|}
      #|struct BoolSource {
      #|  value : Bool
      #|}
      #|fn take_int(value : Int) -> Int {
      #|  value
      #|}
      #|let int_source : IntSource = IntSource::{ value: 1 }
      #|let bool_source : BoolSource = BoolSource::{ value: true }
      #|open int_source
      #|open bool_source
      #|fn use() -> Int {
      #|  take_int(value)
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result, width=100),
    content=(
      #|typecheck_result {
      #|  checked_declarations {
      #|    types {
      #|      struct type#0 IntSource {
      #|        field field#0 value : Int index=0
      #|      }
      #|      struct type#1 BoolSource {
      #|        field field#1 value : Bool index=0
      #|      }
      #|    }
      #|    fields {
      #|      field field#0 value : Int index=0
      #|      field field#1 value : Bool index=0
      #|    }
      #|    variants {}
      #|  }
      #|  checked_values {
      #|    fn value#0 take_int : (Int) -> Int
      #|    fn value#1 use : () -> Int
      #|    let value#3 int_source : type#0
      #|    let value#4 bool_source : type#1
      #|  }
      #|  diagnostics {}
      #|}
    ),
  )
}

///|
test "typecheck selects callable open candidate by expected result type" {
  let result = expect_typecheck_result(
    (
      #|struct IntFactory {
      #|  make : () -> Int
      #|}
      #|struct BoolFactory {
      #|  make : () -> Bool
      #|}
      #|fn make_int() -> Int {
      #|  1
      #|}
      #|fn make_bool() -> Bool {
      #|  true
      #|}
      #|let int_factory : IntFactory = IntFactory::{ make: make_int }
      #|let bool_factory : BoolFactory = BoolFactory::{ make: make_bool }
      #|open int_factory
      #|open bool_factory
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
      #|    types {
      #|      struct type#0 IntFactory {
      #|        field field#0 make : () -> Int index=0
      #|      }
      #|      struct type#1 BoolFactory {
      #|        field field#1 make : () -> Bool index=0
      #|      }
      #|    }
      #|    fields {
      #|      field field#0 make : () -> Int index=0
      #|      field field#1 make : () -> Bool index=0
      #|    }
      #|    variants {}
      #|  }
      #|  checked_values {
      #|    fn value#0 make_int : () -> Int
      #|    fn value#1 make_bool : () -> Bool
      #|    fn value#2 use : () -> Int
      #|    let value#3 int_factory : type#0
      #|    let value#4 bool_factory : type#1
      #|  }
      #|  diagnostics {}
      #|}
    ),
  )
}

///|
test "typecheck selects callable candidate by checking argument candidates" {
  let result = expect_typecheck_result(
    (
      #|struct IntSource {
      #|  value : Int
      #|}
      #|struct BoolSource {
      #|  value : Bool
      #|}
      #|struct IntApply {
      #|  apply : (Int) -> Int
      #|}
      #|struct BoolApply {
      #|  apply : (Bool) -> Bool
      #|}
      #|fn apply_int(value : Int) -> Int {
      #|  value
      #|}
      #|fn apply_bool(value : Bool) -> Bool {
      #|  value
      #|}
      #|let int_source : IntSource = IntSource::{ value: 1 }
      #|let bool_source : BoolSource = BoolSource::{ value: true }
      #|let int_apply : IntApply = IntApply::{ apply: apply_int }
      #|let bool_apply : BoolApply = BoolApply::{ apply: apply_bool }
      #|open int_source
      #|open bool_source
      #|open int_apply
      #|open bool_apply
      #|fn use() -> Int {
      #|  apply(value)
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result, width=100),
    content=(
      #|typecheck_result {
      #|  checked_declarations {
      #|    types {
      #|      struct type#0 IntSource {
      #|        field field#0 value : Int index=0
      #|      }
      #|      struct type#1 BoolSource {
      #|        field field#1 value : Bool index=0
      #|      }
      #|      struct type#2 IntApply {
      #|        field field#2 apply : (Int) -> Int index=0
      #|      }
      #|      struct type#3 BoolApply {
      #|        field field#3 apply : (Bool) -> Bool index=0
      #|      }
      #|    }
      #|    fields {
      #|      field field#0 value : Int index=0
      #|      field field#1 value : Bool index=0
      #|      field field#2 apply : (Int) -> Int index=0
      #|      field field#3 apply : (Bool) -> Bool index=0
      #|    }
      #|    variants {}
      #|  }
      #|  checked_values {
      #|    fn value#0 apply_int : (Int) -> Int
      #|    fn value#1 apply_bool : (Bool) -> Bool
      #|    fn value#2 use : () -> Int
      #|    let value#5 int_source : type#0
      #|    let value#6 bool_source : type#1
      #|    let value#7 int_apply : type#2
      #|    let value#8 bool_apply : type#3
      #|  }
      #|  diagnostics {}
      #|}
    ),
  )
}

///|
test "typecheck reports ambiguous candidate without expected type" {
  let result = expect_typecheck_result(
    (
      #|struct IntSource {
      #|  value : Int
      #|}
      #|struct BoolSource {
      #|  value : Bool
      #|}
      #|let int_source : IntSource = IntSource::{ value: 1 }
      #|let bool_source : BoolSource = BoolSource::{ value: true }
      #|open int_source
      #|open bool_source
      #|fn use() -> Bool {
      #|  {
      #|    let local = value
      #|    true
      #|  }
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result.diagnostics[0]),
    content="cannot_infer ambiguous value reference value",
  )
}

///|
test "typecheck reports no callable candidate when arguments reject all candidates" {
  let result = expect_typecheck_result(
    (
      #|struct IntApply {
      #|  apply : (Int) -> Int
      #|}
      #|struct BoolApply {
      #|  apply : (Bool) -> Bool
      #|}
      #|fn apply_int(value : Int) -> Int {
      #|  value
      #|}
      #|fn apply_bool(value : Bool) -> Bool {
      #|  value
      #|}
      #|let int_apply : IntApply = IntApply::{ apply: apply_int }
      #|let bool_apply : BoolApply = BoolApply::{ apply: apply_bool }
      #|open int_apply
      #|open bool_apply
      #|fn use() -> Int {
      #|  apply("text")
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result.diagnostics[0]),
    content="cannot_infer no matching callable value reference apply",
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
    content="cannot_infer generic function arity",
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
    content="cannot_infer generic function arity",
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
test "typecheck selects generic open callable candidate by argument type" {
  let result = expect_typecheck_result(
    (
      #|struct IdOps {
      #|  id : [A](A) -> A
      #|}
      #|fn[A] identity(value : A) -> A {
      #|  value
      #|}
      #|let ops : IdOps = IdOps::{ id: identity }
      #|open ops
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
      #|    types {
      #|      struct type#0 IdOps {
      #|        field field#0 id : forall [tparam#0 A : Type]. (tparam#0) -> tparam#0 index=0
      #|      }
      #|    }
      #|    fields {
      #|      field field#0 id : forall [tparam#0 A : Type]. (tparam#0) -> tparam#0 index=0
      #|    }
      #|    variants {}
      #|  }
      #|  checked_values {
      #|    fn value#0 identity : forall [tparam#1 A : Type]. (tparam#1) -> tparam#1
      #|    fn value#1 use : () -> Int
      #|    let value#3 ops : type#0
      #|  }
      #|  diagnostics {}
      #|}
    ),
  )
}

///|
test "typecheck keeps generic callable candidates ambiguous" {
  let result = expect_typecheck_result(
    (
      #|struct LeftOps {
      #|  id : [A](A) -> A
      #|}
      #|struct RightOps {
      #|  id : [A](A) -> A
      #|}
      #|fn[A] left_id(value : A) -> A {
      #|  value
      #|}
      #|fn[A] right_id(value : A) -> A {
      #|  value
      #|}
      #|let left_ops : LeftOps = LeftOps::{ id: left_id }
      #|let right_ops : RightOps = RightOps::{ id: right_id }
      #|open left_ops
      #|open right_ops
      #|fn use() -> Int {
      #|  id(1)
      #|}
    ),
  )
  inspect(
    @prettyprinter.render(result.diagnostics[0]),
    content="cannot_infer ambiguous value reference id",
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
    content="cannot_infer type arguments",
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
    content="not_a_struct Int",
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
    content="cannot_infer type arguments",
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
    content="type_mismatch expected=Int actual=Bool",
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
    content="cannot_infer variant arity",
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
    content="cannot_infer ambiguous variant reference same",
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
    content="non_exhaustive_match Bool",
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
    content="unreachable_match_arm",
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
    content="duplicate_pattern_binder x",
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
    content="missing_field y",
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
    content="type_mismatch expected=Int actual=Bool",
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
    content="missing_field y",
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
    content="type_arity_mismatch Box expected=1 actual=2",
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
      #|    unresolved_type Missing
      #|  }
      #|}
    ),
  )
}
