///|
priv struct BuslaneLowerer {}

///|
/// Lowers Checked Source into the Buslane Core Language.
pub fn lower_checked_source_file_to_buslane(
  source : @checked.CheckedSourceFile,
) -> BuslaneProgram {
  let lowerer = BuslaneLowerer::{  }
  {
    declarations: source.declarations.map(fn(declaration) {
      lowerer.lower_top_level_declaration(declaration)
    }),
    loc: source.loc,
  }
}

///|
fn BuslaneLowerer::lower_top_level_declaration(
  self : BuslaneLowerer,
  declaration : @checked.CheckedTopLevelDeclaration,
) -> BuslaneTopLevelDeclaration {
  match declaration {
    Struct(declaration) => Struct(declaration)
    Enum(declaration) => Enum(declaration)
    Function(declaration) =>
      Function(self.lower_function_declaration(declaration))
    Let(declaration) => Let(self.lower_let_declaration(declaration))
  }
}

///|
fn BuslaneLowerer::lower_function_declaration(
  self : BuslaneLowerer,
  declaration : @checked.CheckedFunctionDeclaration,
) -> BuslaneFunctionDeclaration {
  {
    symbol: declaration.symbol,
    name: declaration.name,
    type_parameters: declaration.type_parameters,
    parameters: declaration.parameters,
    return_type: declaration.return_type,
    body: self.lower_expr(declaration.body),
    type_: declaration.type_,
    loc: declaration.loc,
  }
}

///|
fn BuslaneLowerer::lower_let_declaration(
  self : BuslaneLowerer,
  declaration : @checked.CheckedLetDeclaration,
) -> BuslaneLetDeclaration {
  {
    symbol: declaration.symbol,
    name: declaration.name,
    value: self.lower_expr(declaration.initializer),
    type_: declaration.type_,
    loc: declaration.loc,
  }
}

///|
fn BuslaneLowerer::lower_expr(
  self : BuslaneLowerer,
  expression : @checked.CheckedExpr,
) -> BuslaneExpr {
  match expression {
    Literal(literal~, type_~, loc~) => Literal(literal~, type_~, loc~)
    Value(name~, symbol~, type_~, loc~) => Value(name~, symbol~, type_~, loc~)
    UnsafeBuiltin(name~, type_~, loc~) => UnsafeBuiltin(name~, type_~, loc~)
    FunctionLiteral(
      type_parameters~,
      parameters~,
      return_type~,
      body~,
      type_~,
      loc~
    ) =>
      self.lower_function_literal(
        type_parameters, parameters, return_type, body, type_, loc,
      )
    TypeApplication(callee~, arguments~, type_~, loc~) =>
      TypeApplication(callee=self.lower_expr(callee), arguments~, type_~, loc~)
    Block(items~, result~, type_~, loc~) =>
      self.lower_items(items, 0, self.lower_expr(result), type_, loc)
    If(condition~, then_branch~, else_branch~, type_~, loc~) =>
      If(
        condition=self.lower_expr(condition),
        then_branch=self.lower_expr(then_branch),
        else_branch=self.lower_expr(else_branch),
        type_~,
        loc~,
      )
    Match(scrutinee~, arms~, type_~, loc~) =>
      Match(
        scrutinee=self.lower_expr(scrutinee),
        arms=arms.map(fn(arm) { self.lower_match_arm(arm) }),
        type_~,
        loc~,
      )
    Call(callee~, arguments~, type_~, loc~) =>
      Call(
        callee=self.lower_expr(callee),
        arguments=arguments.map(fn(argument) { self.lower_expr(argument) }),
        type_~,
        loc~,
      )
    Field(base~, field~, name~, type_~, loc~) =>
      Field(base=self.lower_expr(base), field~, name~, type_~, loc~)
    StructLiteral(
      symbol~,
      type_arguments~,
      type_witnesses~,
      fields~,
      type_~,
      loc~
    ) =>
      Struct(
        symbol~,
        type_arguments~,
        type_witnesses~,
        fields=fields.map(fn(field) { self.lower_struct_field(field) }),
        type_~,
        loc~,
      )
    Variant(symbol~, type_arguments~, arguments~, type_~, loc~) =>
      Variant(
        symbol~,
        type_arguments~,
        arguments=arguments.map(fn(argument) { self.lower_expr(argument) }),
        type_~,
        loc~,
      )
  }
}

///|
fn BuslaneLowerer::lower_function_literal(
  self : BuslaneLowerer,
  type_parameters : Array[@types.TypeParameter],
  parameters : Array[@checked.CheckedValueParameter],
  return_type : @types.Type,
  body : @checked.CheckedExpr,
  type_ : @types.Type,
  loc : SourceSpan,
) -> BuslaneExpr {
  let function_type = @types.Type::Function(
    parameters.map(fn(parameter) { parameter.type_ }),
    return_type,
  )
  let function = BuslaneExpr::Function(
    parameters~,
    body=self.lower_expr(body),
    type_=function_type,
    loc~,
  )
  if type_parameters.is_empty() {
    function
  } else {
    TypeLambda(type_parameters~, body=function, type_~, loc~)
  }
}

///|
fn BuslaneLowerer::lower_items(
  self : BuslaneLowerer,
  items : Array[@checked.CheckedLocalItem],
  index : Int,
  body : BuslaneExpr,
  type_ : @types.Type,
  loc : SourceSpan,
) -> BuslaneExpr {
  if index >= items.length() {
    body
  } else {
    let item = items[items.length() - index - 1]
    let lowered_body = self.lower_items(items, index + 1, body, type_, loc)
    Let(binding=self.lower_local_item(item), body=lowered_body, type_~, loc~)
  }
}

///|
fn BuslaneLowerer::lower_local_item(
  self : BuslaneLowerer,
  item : @checked.CheckedLocalItem,
) -> BuslaneBinding {
  match item {
    Let(declaration) =>
      Value(
        symbol=declaration.symbol,
        name=declaration.name,
        value=self.lower_expr(declaration.initializer),
        type_=declaration.type_,
        loc=declaration.loc,
      )
    PatternLet(declaration) =>
      Pattern(
        pattern=declaration.pattern,
        initializer=self.lower_expr(declaration.initializer),
        loc=declaration.loc,
      )
    Function(declaration) =>
      Value(
        symbol=declaration.symbol,
        name=Some(declaration.name),
        value=self.lower_local_function(declaration),
        type_=declaration.type_,
        loc=declaration.loc,
      )
  }
}

///|
fn BuslaneLowerer::lower_local_function(
  self : BuslaneLowerer,
  declaration : @checked.CheckedFunctionDeclaration,
) -> BuslaneExpr {
  self.lower_function_literal(
    declaration.type_parameters,
    declaration.parameters,
    declaration.return_type,
    declaration.body,
    declaration.type_,
    declaration.loc,
  )
}

///|
fn BuslaneLowerer::lower_struct_field(
  self : BuslaneLowerer,
  field : @checked.CheckedStructLiteralField,
) -> BuslaneStructField {
  {
    symbol: field.symbol,
    name: field.name,
    value: self.lower_expr(field.value),
    loc: field.loc,
  }
}

///|
fn BuslaneLowerer::lower_match_arm(
  self : BuslaneLowerer,
  arm : @checked.CheckedMatchArm,
) -> BuslaneMatchArm {
  { pattern: arm.pattern, body: self.lower_expr(arm.body), loc: arm.loc }
}
