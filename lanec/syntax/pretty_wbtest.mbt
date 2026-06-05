///|
fn test_loc() -> SourceSpan {
  SourceSpan::dummy()
}

///|
fn test_type(name : String, arguments? : Array[Type] = []) -> Type {
  Type::Name(name~, arguments~, loc=test_loc())
}

///|
test "pretty print source file" {
  let int_type = test_type("Int")
  let option_int_type = test_type("Option", arguments=[int_type])
  let file = SourceFile::{
    declarations: [
      TopLevelDeclaration::Struct(StructDeclaration::{
        name: "Point",
        type_parameters: [],
        members: [
          StructMember::Field(FieldDeclaration::{
            name: "x",
            type_: int_type,
            loc: test_loc(),
          }),
          StructMember::Field(FieldDeclaration::{
            name: "y",
            type_: int_type,
            loc: test_loc(),
          }),
        ],
        loc: test_loc(),
      }),
      TopLevelDeclaration::Enum(EnumDeclaration::{
        name: "Option",
        type_parameters: ["A"],
        variants: [
          EnumVariant::{ name: "none", payload: [], loc: test_loc() },
          EnumVariant::{
            name: "some",
            payload: [test_type("A")],
            loc: test_loc(),
          },
        ],
        loc: test_loc(),
      }),
      TopLevelDeclaration::Function(FunctionDeclaration::{
        type_parameters: [],
        name: "unwrap_or",
        parameters: [
          Parameter::{ name: "value", type_: option_int_type, loc: test_loc() },
          Parameter::{ name: "fallback", type_: int_type, loc: test_loc() },
        ],
        return_type: int_type,
        body: Expr::Block(
          items=[],
          result=Expr::Match(
            scrutinee=Expr::Var("value", loc=test_loc()),
            arms=[
              MatchArm::{
                pattern: Pattern::QualifiedVariant(
                  type_name="Option",
                  variant="none",
                  arguments=[],
                  loc=test_loc(),
                ),
                body: Expr::Var("fallback", loc=test_loc()),
                loc: test_loc(),
              },
              MatchArm::{
                pattern: Pattern::QualifiedVariant(
                  type_name="Option",
                  variant="some",
                  arguments=[Pattern::Binding("x", loc=test_loc())],
                  loc=test_loc(),
                ),
                body: Expr::Var("x", loc=test_loc()),
                loc: test_loc(),
              },
            ],
            loc=test_loc(),
          ),
          loc=test_loc(),
        ),
        loc: test_loc(),
      }),
    ],
    loc: test_loc(),
  }
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
test "pretty print expression precedence" {
  let expression = Expr::Binary(
    operator=BinaryOperator::Mul,
    left=Expr::Binary(
      operator=BinaryOperator::Add,
      left=Expr::IntLiteral("1", loc=test_loc()),
      right=Expr::IntLiteral("2", loc=test_loc()),
      loc=test_loc(),
    ),
    right=Expr::IntLiteral("3", loc=test_loc()),
    loc=test_loc(),
  )
  inspect(@prettyprinter.render(expression), content="(1 + 2) * 3")
}
