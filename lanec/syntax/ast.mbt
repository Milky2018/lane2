///|
pub(all) struct SourceFile {
  declarations : Array[TopLevelDeclaration]
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) enum TopLevelDeclaration {
  Struct(StructDeclaration)
  Enum(EnumDeclaration)
  Function(FunctionDeclaration)
  Let(LetDeclaration)
  Open(OpenDeclaration)
} derive(Debug, Eq)

///|
pub(all) struct StructDeclaration {
  name : String
  type_parameters : Array[String]
  members : Array[StructMember]
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) enum StructMember {
  Field(FieldDeclaration)
  Open(OpenDeclaration)
} derive(Debug, Eq)

///|
pub(all) struct FieldDeclaration {
  name : String
  type_ : Type
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) struct EnumDeclaration {
  name : String
  type_parameters : Array[String]
  variants : Array[EnumVariant]
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) struct EnumVariant {
  name : String
  payload : Array[Type]
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) struct FunctionDeclaration {
  type_parameters : Array[String]
  name : String
  parameters : Array[Parameter]
  return_type : Type
  body : Expr
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) struct Parameter {
  name : String
  type_ : Type
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) struct LetDeclaration {
  name : String?
  type_annotation : Type?
  initializer : Expr
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) struct OpenDeclaration {
  name : String
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) enum Type {
  Name(name~ : String, arguments~ : Array[Type], loc~ : SourceSpan)
  Function(
    type_parameters~ : Array[String],
    parameters~ : Array[Type],
    result~ : Type,
    loc~ : SourceSpan
  )
} derive(Debug, Eq)

///|
pub fn Type::loc(self : Type) -> SourceSpan {
  match self {
    Name(loc~, ..) | Function(loc~, ..) => loc
  }
}

///|
pub(all) enum Expr {
  IntLiteral(String, loc~ : SourceSpan)
  StringLiteral(String, loc~ : SourceSpan)
  BoolLiteral(Bool, loc~ : SourceSpan)
  UnitLiteral(loc~ : SourceSpan)
  Var(String, loc~ : SourceSpan)
  QualifiedVariant(
    type_name~ : String,
    type_arguments~ : Array[Type],
    variant~ : String,
    arguments~ : Array[Expr],
    loc~ : SourceSpan
  )
  StructLiteral(
    type_name~ : String,
    type_arguments~ : Array[Type],
    fields~ : Array[StructLiteralField],
    loc~ : SourceSpan
  )
  Builtin(String, loc~ : SourceSpan)
  FunctionLiteral(
    type_parameters~ : Array[String],
    parameters~ : Array[FunctionLiteralParameter],
    return_type~ : Type?,
    body~ : Expr,
    loc~ : SourceSpan
  )
  Block(items~ : Array[LocalItem], result~ : Expr, loc~ : SourceSpan)
  If(
    condition~ : Expr,
    then_branch~ : Expr,
    else_branch~ : Expr,
    loc~ : SourceSpan
  )
  Match(scrutinee~ : Expr, arms~ : Array[MatchArm], loc~ : SourceSpan)
  Call(callee~ : Expr, arguments~ : Array[Expr], loc~ : SourceSpan)
  Field(base~ : Expr, name~ : String, loc~ : SourceSpan)
  Unary(operator~ : UnaryOperator, operand~ : Expr, loc~ : SourceSpan)
  Binary(
    operator~ : BinaryOperator,
    left~ : Expr,
    right~ : Expr,
    loc~ : SourceSpan
  )
  Pipeline(left~ : Expr, right~ : Expr, loc~ : SourceSpan)
} derive(Debug, Eq)

///|
pub fn Expr::loc(self : Expr) -> SourceSpan {
  match self {
    IntLiteral(_, loc~)
    | StringLiteral(_, loc~)
    | BoolLiteral(_, loc~)
    | UnitLiteral(loc~)
    | Var(_, loc~)
    | QualifiedVariant(loc~, ..)
    | StructLiteral(loc~, ..)
    | Builtin(_, loc~)
    | FunctionLiteral(loc~, ..)
    | Block(loc~, ..)
    | If(loc~, ..)
    | Match(loc~, ..)
    | Call(loc~, ..)
    | Field(loc~, ..)
    | Unary(loc~, ..)
    | Binary(loc~, ..)
    | Pipeline(loc~, ..) => loc
  }
}

///|
pub(all) enum LocalItem {
  Let(LetDeclaration)
  Function(FunctionDeclaration)
  Open(OpenDeclaration)
} derive(Debug, Eq)

///|
pub(all) struct FunctionLiteralParameter {
  name : String
  type_annotation : Type?
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) struct StructLiteralField {
  name : String
  value : Expr?
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) struct MatchArm {
  pattern : Pattern
  body : Expr
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) enum Pattern {
  Wildcard(SourceSpan)
  Binding(String, loc~ : SourceSpan)
  IntLiteral(String, loc~ : SourceSpan)
  StringLiteral(String, loc~ : SourceSpan)
  BoolLiteral(Bool, loc~ : SourceSpan)
  QualifiedVariant(
    type_name~ : String,
    variant~ : String,
    arguments~ : Array[Pattern],
    loc~ : SourceSpan
  )
  Struct(
    type_name~ : String,
    fields~ : Array[StructPatternField],
    loc~ : SourceSpan
  )
} derive(Debug, Eq)

///|
pub fn Pattern::loc(self : Pattern) -> SourceSpan {
  match self {
    Wildcard(loc)
    | Binding(_, loc~)
    | IntLiteral(_, loc~)
    | StringLiteral(_, loc~)
    | BoolLiteral(_, loc~)
    | QualifiedVariant(loc~, ..)
    | Struct(loc~, ..) => loc
  }
}

///|
pub(all) struct StructPatternField {
  name : String
  pattern : Pattern?
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) enum UnaryOperator {
  Neg
  Not
} derive(Debug, Eq)

///|
pub(all) enum BinaryOperator {
  Add
  Sub
  Mul
  Div
  Rem
  Equal
  NotEqual
  Less
  LessEqual
  Greater
  GreaterEqual
  And
  Or
} derive(Debug, Eq)
