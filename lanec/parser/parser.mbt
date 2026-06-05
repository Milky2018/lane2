///|
pub fn parse_string(source : String) -> ParseResult {
  let lexed = @lexer.tokens_from_string(source)
  if !lexed.errors.is_empty() {
    ParseResult::{
      source: None,
      lexical_errors: lexed.errors,
      parse_errors: [],
    }
  } else {
    let result = parse_tokens(lexed.tokens)
    ParseResult::{
      source: result.source,
      lexical_errors: [],
      parse_errors: result.parse_errors,
    }
  }
}

///|
pub fn parse_tokens(tokens : Array[(@lexer.Token, SourceSpan)]) -> ParseResult {
  let state = State::{ tokens, errors: [], next: 0 }
  let source = state.parse_source_file()
  ParseResult::{
    source: Some(source),
    lexical_errors: [],
    parse_errors: state.errors,
  }
}

///|
fn State::parse_source_file(self : State) -> @syntax.SourceFile {
  let start = self.peek_span()
  let declarations : Array[@syntax.TopLevelDeclaration] = []
  while !(self.peek_token() is @lexer.Token::EOF) {
    match self.parse_top_level_declaration() {
      Some(decl) => declarations.push(decl)
      None => self.consume() |> ignore
    }
  }
  let end = self.expect(@lexer.Token::EOF, "end of file")
  @syntax.SourceFile::{ declarations, loc: join_span(start, end) }
}

///|
fn State::parse_top_level_declaration(
  self : State,
) -> @syntax.TopLevelDeclaration? {
  match self.peek_token() {
    @lexer.Token::STRUCT =>
      Some(@syntax.TopLevelDeclaration::Struct(self.parse_struct_declaration()))
    @lexer.Token::ENUM =>
      Some(@syntax.TopLevelDeclaration::Enum(self.parse_enum_declaration()))
    @lexer.Token::FN =>
      Some(
        @syntax.TopLevelDeclaration::Function(self.parse_function_declaration()),
      )
    @lexer.Token::LET =>
      Some(
        @syntax.TopLevelDeclaration::Let(
          self.parse_let_declaration(allow_anonymous=true, require_type=true),
        ),
      )
    @lexer.Token::OPEN =>
      Some(@syntax.TopLevelDeclaration::Open(self.parse_open_declaration()))
    _ => {
      self.report("Expected top-level declaration.", self.peek_span())
      None
    }
  }
}

///|
fn State::parse_struct_declaration(self : State) -> @syntax.StructDeclaration {
  let start = self.expect(@lexer.Token::STRUCT, "`struct`")
  let (name, _) = self.expect_ident("struct name")
  let type_parameters = self.parse_type_parameters()
  self.expect(@lexer.Token::LBRACE, "`{`") |> ignore
  let members : Array[@syntax.StructMember] = []
  while !self.at_rbrace_or_eof() {
    if self.peek_token() is @lexer.Token::OPEN {
      members.push(@syntax.StructMember::Open(self.parse_open_declaration()))
    } else {
      members.push(@syntax.StructMember::Field(self.parse_field_declaration()))
    }
  }
  let end = self.expect(@lexer.Token::RBRACE, "`}`")
  @syntax.StructDeclaration::{
    name,
    type_parameters,
    members,
    loc: join_span(start, end),
  }
}

///|
fn State::parse_field_declaration(self : State) -> @syntax.FieldDeclaration {
  let (name, start) = self.expect_ident("field name")
  self.expect(@lexer.Token::COLON, "`:`") |> ignore
  let type_ = self.parse_type()
  @syntax.FieldDeclaration::{ name, type_, loc: join_span(start, type_.loc()) }
}

///|
fn State::parse_enum_declaration(self : State) -> @syntax.EnumDeclaration {
  let start = self.expect(@lexer.Token::ENUM, "`enum`")
  let (name, _) = self.expect_ident("enum name")
  let type_parameters = self.parse_type_parameters()
  self.expect(@lexer.Token::LBRACE, "`{`") |> ignore
  let variants : Array[@syntax.EnumVariant] = []
  while !self.at_rbrace_or_eof() {
    variants.push(self.parse_enum_variant())
  }
  let end = self.expect(@lexer.Token::RBRACE, "`}`")
  @syntax.EnumDeclaration::{
    name,
    type_parameters,
    variants,
    loc: join_span(start, end),
  }
}

///|
fn State::parse_enum_variant(self : State) -> @syntax.EnumVariant {
  let (name, start) = self.expect_ident("enum variant")
  let payload = if self.match_token(@lexer.Token::LPAREN) {
    if self.peek_token() is @lexer.Token::RPAREN {
      self.report(
        "Expected at least one enum variant payload type.",
        self.peek_span(),
      )
    }
    let items = self.parse_comma_separated_types_until(@lexer.Token::RPAREN)
    self.expect(@lexer.Token::RPAREN, "`)`") |> ignore
    items
  } else {
    []
  }
  let end = if payload.is_empty() {
    start
  } else {
    payload[payload.length() - 1].loc()
  }
  @syntax.EnumVariant::{ name, payload, loc: join_span(start, end) }
}

///|
fn State::parse_function_declaration(
  self : State,
) -> @syntax.FunctionDeclaration {
  let start = self.expect(@lexer.Token::FN, "`fn`")
  let type_parameters = self.parse_type_parameters()
  let (name, _) = self.expect_ident("function name")
  let parameters = self.parse_parameters()
  self.expect(@lexer.Token::THIN_ARROW, "`->`") |> ignore
  let return_type = self.parse_type()
  let body = self.parse_block_expression()
  @syntax.FunctionDeclaration::{
    type_parameters,
    name,
    parameters,
    return_type,
    body,
    loc: join_span(start, body.loc()),
  }
}

///|
fn State::parse_parameters(self : State) -> Array[@syntax.Parameter] {
  self.expect(@lexer.Token::LPAREN, "`(`") |> ignore
  let parameters : Array[@syntax.Parameter] = []
  if !(self.peek_token() is @lexer.Token::RPAREN) {
    let mut keep_going = true
    while keep_going {
      let (name, start) = self.expect_ident("parameter")
      self.expect(@lexer.Token::COLON, "`:`") |> ignore
      let type_ = self.parse_type()
      parameters.push(@syntax.Parameter::{
        name,
        type_,
        loc: join_span(start, type_.loc()),
      })
      keep_going = self.match_token(@lexer.Token::COMMA) &&
        !(self.peek_token() is @lexer.Token::RPAREN)
    }
  }
  self.expect(@lexer.Token::RPAREN, "`)`") |> ignore
  parameters
}

///|
fn State::parse_let_declaration(
  self : State,
  allow_anonymous~ : Bool,
  require_type~ : Bool,
) -> @syntax.LetDeclaration {
  let start = self.expect(@lexer.Token::LET, "`let`")
  let (name, type_annotation) = if allow_anonymous &&
    self.peek_token() is @lexer.Token::COLON {
    self.consume() |> ignore
    (None, Some(self.parse_type()))
  } else {
    let (parsed_name, _) = self.expect_ident("let binding")
    if self.match_token(@lexer.Token::COLON) {
      (Some(parsed_name), Some(self.parse_type()))
    } else {
      if require_type {
        self.report(
          "Expected type annotation for top-level let.",
          self.peek_span(),
        )
      }
      (Some(parsed_name), None)
    }
  }
  self.expect(@lexer.Token::EQUAL, "`=`") |> ignore
  let initializer = self.parse_expression()
  @syntax.LetDeclaration::{
    name,
    type_annotation,
    initializer,
    loc: join_span(start, initializer.loc()),
  }
}

///|
fn State::parse_open_declaration(self : State) -> @syntax.OpenDeclaration {
  let start = self.expect(@lexer.Token::OPEN, "`open`")
  let (name, end) = self.expect_ident("open declaration")
  @syntax.OpenDeclaration::{ name, loc: join_span(start, end) }
}

///|
fn State::parse_type_parameters(self : State) -> Array[String] {
  if !self.match_token(@lexer.Token::LBRACKET) {
    return []
  }
  let parameters : Array[String] = []
  if !(self.peek_token() is @lexer.Token::RBRACKET) {
    let mut keep_going = true
    while keep_going {
      let (name, _) = self.expect_ident("type parameter")
      parameters.push(name)
      keep_going = self.match_token(@lexer.Token::COMMA) &&
        !(self.peek_token() is @lexer.Token::RBRACKET)
    }
  }
  self.expect(@lexer.Token::RBRACKET, "`]`") |> ignore
  parameters
}

///|
fn State::parse_type(self : State) -> @syntax.Type {
  let type_parameters = if self.peek_token() is @lexer.Token::LBRACKET {
    self.parse_type_parameters()
  } else {
    []
  }
  match self.peek_token() {
    @lexer.Token::LPAREN => self.parse_function_type(type_parameters)
    @lexer.Token::IDENT(_) if type_parameters.is_empty() =>
      self.parse_named_type()
    _ => {
      let loc = self.peek_span()
      self.report("Expected type.", loc)
      @syntax.Type::Name(name="", arguments=[], loc~)
    }
  }
}

///|
fn State::parse_named_type(self : State) -> @syntax.Type {
  let (name, start) = self.expect_ident("type name")
  let arguments = if self.match_token(@lexer.Token::LBRACKET) {
    let args = self.parse_comma_separated_types_until(@lexer.Token::RBRACKET)
    self.expect(@lexer.Token::RBRACKET, "`]`") |> ignore
    args
  } else {
    []
  }
  let end = if arguments.is_empty() {
    start
  } else {
    arguments[arguments.length() - 1].loc()
  }
  @syntax.Type::Name(name~, arguments~, loc=join_span(start, end))
}

///|
fn State::parse_function_type(
  self : State,
  type_parameters : Array[String],
) -> @syntax.Type {
  let start = self.expect(@lexer.Token::LPAREN, "`(`")
  let parameters = self.parse_comma_separated_types_until(@lexer.Token::RPAREN)
  self.expect(@lexer.Token::RPAREN, "`)`") |> ignore
  self.expect(@lexer.Token::THIN_ARROW, "`->`") |> ignore
  let result = self.parse_type()
  @syntax.Type::Function(
    type_parameters~,
    parameters~,
    result~,
    loc=join_span(start, result.loc()),
  )
}

///|
fn State::parse_comma_separated_types_until(
  self : State,
  end_token : @lexer.Token,
) -> Array[@syntax.Type] {
  let items : Array[@syntax.Type] = []
  if self.peek_token() == end_token {
    return items
  }
  let mut keep_going = true
  while keep_going {
    items.push(self.parse_type())
    keep_going = self.match_token(@lexer.Token::COMMA) &&
      self.peek_token() != end_token
  }
  items
}

///|
fn State::parse_expression(self : State) -> @syntax.Expr {
  self.parse_pipeline_expression()
}

///|
fn State::parse_pipeline_expression(self : State) -> @syntax.Expr {
  let mut left = self.parse_binary_expression(prec=1)
  while self.peek_token() is @lexer.Token::PIPE {
    self.consume() |> ignore
    let right = if self.peek_token() is @lexer.Token::FN {
      self.parse_function_literal()
    } else {
      self.parse_call_expression()
    }
    left = @syntax.Expr::Pipeline(
      left~,
      right~,
      loc=join_span(left.loc(), right.loc()),
    )
  }
  left
}

///|
fn State::parse_binary_expression(self : State, prec~ : Int) -> @syntax.Expr {
  let mut left = self.parse_unary_expression()
  let mut current = self.binary_operator()
  while current is Some((op, op_prec)) && op_prec >= prec {
    self.consume() |> ignore
    let right = self.parse_binary_expression(prec=op_prec + 1)
    left = @syntax.Expr::Binary(
      operator=op,
      left~,
      right~,
      loc=join_span(left.loc(), right.loc()),
    )
    current = self.binary_operator()
  }
  left
}

///|
fn State::binary_operator(self : State) -> (@syntax.BinaryOperator, Int)? {
  match self.peek_token() {
    @lexer.Token::BARBAR => Some((@syntax.BinaryOperator::Or, 1))
    @lexer.Token::AMPAMP => Some((@syntax.BinaryOperator::And, 2))
    @lexer.Token::EQEQ => Some((@syntax.BinaryOperator::Equal, 3))
    @lexer.Token::BANGEQ => Some((@syntax.BinaryOperator::NotEqual, 3))
    @lexer.Token::LT => Some((@syntax.BinaryOperator::Less, 4))
    @lexer.Token::LTEQ => Some((@syntax.BinaryOperator::LessEqual, 4))
    @lexer.Token::GT => Some((@syntax.BinaryOperator::Greater, 4))
    @lexer.Token::GTEQ => Some((@syntax.BinaryOperator::GreaterEqual, 4))
    @lexer.Token::PLUS => Some((@syntax.BinaryOperator::Add, 5))
    @lexer.Token::MINUS => Some((@syntax.BinaryOperator::Sub, 5))
    @lexer.Token::STAR => Some((@syntax.BinaryOperator::Mul, 6))
    @lexer.Token::SLASH => Some((@syntax.BinaryOperator::Div, 6))
    @lexer.Token::PERCENT => Some((@syntax.BinaryOperator::Rem, 6))
    _ => None
  }
}

///|
fn State::parse_unary_expression(self : State) -> @syntax.Expr {
  match self.peek_token() {
    @lexer.Token::MINUS => {
      let start = self.consume().1
      let operand = self.parse_unary_expression()
      @syntax.Expr::Unary(
        operator=@syntax.UnaryOperator::Neg,
        operand~,
        loc=join_span(start, operand.loc()),
      )
    }
    @lexer.Token::BANG => {
      let start = self.consume().1
      let operand = self.parse_unary_expression()
      @syntax.Expr::Unary(
        operator=@syntax.UnaryOperator::Not,
        operand~,
        loc=join_span(start, operand.loc()),
      )
    }
    _ => self.parse_call_expression()
  }
}

///|
fn State::parse_call_expression(self : State) -> @syntax.Expr {
  let mut expr = self.parse_primary_expression()
  let mut continue_loop = true
  while continue_loop {
    match self.peek_token() {
      @lexer.Token::LPAREN => {
        let arguments = self.parse_arguments()
        let end = if arguments.is_empty() {
          self.peek_span()
        } else {
          arguments[arguments.length() - 1].loc()
        }
        expr = @syntax.Expr::Call(
          callee=expr,
          arguments~,
          loc=join_span(expr.loc(), end),
        )
      }
      @lexer.Token::DOT => {
        self.consume() |> ignore
        let (name, end) = self.expect_ident("field access")
        expr = @syntax.Expr::Field(
          base=expr,
          name~,
          loc=join_span(expr.loc(), end),
        )
      }
      _ => continue_loop = false
    }
  }
  expr
}

///|
fn State::parse_arguments(self : State) -> Array[@syntax.Expr] {
  self.expect(@lexer.Token::LPAREN, "`(`") |> ignore
  let arguments : Array[@syntax.Expr] = []
  if !(self.peek_token() is @lexer.Token::RPAREN) {
    let mut keep_going = true
    while keep_going {
      arguments.push(self.parse_expression())
      keep_going = self.match_token(@lexer.Token::COMMA) &&
        !(self.peek_token() is @lexer.Token::RPAREN)
    }
  }
  self.expect(@lexer.Token::RPAREN, "`)`") |> ignore
  arguments
}

///|
fn State::parse_primary_expression(self : State) -> @syntax.Expr {
  match self.peek_token() {
    @lexer.Token::INT(value) => {
      let loc = self.consume().1
      @syntax.Expr::IntLiteral(value, loc~)
    }
    @lexer.Token::STRING(value) => {
      let loc = self.consume().1
      @syntax.Expr::StringLiteral(value, loc~)
    }
    @lexer.Token::TRUE => {
      let loc = self.consume().1
      @syntax.Expr::BoolLiteral(true, loc~)
    }
    @lexer.Token::FALSE => {
      let loc = self.consume().1
      @syntax.Expr::BoolLiteral(false, loc~)
    }
    @lexer.Token::IDENT(_) => self.parse_identifier_expression()
    @lexer.Token::LPAREN => self.parse_parenthesized_expression()
    @lexer.Token::LBRACE => self.parse_block_expression()
    @lexer.Token::IF => self.parse_if_expression()
    @lexer.Token::MATCH => self.parse_match_expression()
    @lexer.Token::FN => self.parse_function_literal()
    @lexer.Token::BUILTIN => self.parse_builtin_expression()
    _ => {
      let loc = self.peek_span()
      self.report("Expected expression.", loc)
      self.consume() |> ignore
      @syntax.Expr::UnitLiteral(loc~)
    }
  }
}

///|
fn State::parse_identifier_expression(self : State) -> @syntax.Expr {
  let (name, start) = self.expect_ident("expression")
  let type_arguments = if self.peek_token() is @lexer.Token::LBRACKET {
    self.consume() |> ignore
    let args = self.parse_comma_separated_types_until(@lexer.Token::RBRACKET)
    self.expect(@lexer.Token::RBRACKET, "`]`") |> ignore
    args
  } else {
    []
  }
  if self.match_token(@lexer.Token::COLONCOLON) {
    if self.peek_token() is @lexer.Token::LBRACE {
      self.parse_struct_literal_after_type(name, type_arguments, start)
    } else {
      self.parse_variant_expression_after_type(name, type_arguments, start)
    }
  } else {
    if !type_arguments.is_empty() {
      self.report(
        "Expected `::` after type arguments in expression.",
        self.peek_span(),
      )
    }
    @syntax.Expr::Var(name, loc=start)
  }
}

///|
fn State::parse_struct_literal_after_type(
  self : State,
  type_name : String,
  type_arguments : Array[@syntax.Type],
  start : SourceSpan,
) -> @syntax.Expr {
  self.expect(@lexer.Token::LBRACE, "`{`") |> ignore
  let fields : Array[@syntax.StructLiteralField] = []
  if !(self.peek_token() is @lexer.Token::RBRACE) {
    let mut keep_going = true
    while keep_going {
      fields.push(self.parse_struct_literal_field())
      keep_going = self.match_token(@lexer.Token::COMMA) &&
        !(self.peek_token() is @lexer.Token::RBRACE)
    }
  }
  let end = self.expect(@lexer.Token::RBRACE, "`}`")
  @syntax.Expr::StructLiteral(
    type_name~,
    type_arguments~,
    fields~,
    loc=join_span(start, end),
  )
}

///|
fn State::parse_struct_literal_field(
  self : State,
) -> @syntax.StructLiteralField {
  let (name, start) = self.expect_ident("struct literal field")
  let value = if self.match_token(@lexer.Token::COLON) {
    Some(self.parse_expression())
  } else {
    None
  }
  let end = match value {
    Some(expr) => expr.loc()
    None => start
  }
  @syntax.StructLiteralField::{ name, value, loc: join_span(start, end) }
}

///|
fn State::parse_variant_expression_after_type(
  self : State,
  type_name : String,
  type_arguments : Array[@syntax.Type],
  start : SourceSpan,
) -> @syntax.Expr {
  let (variant, variant_loc) = self.expect_ident("enum variant")
  let arguments = if self.peek_token() is @lexer.Token::LPAREN {
    self.parse_variant_arguments()
  } else {
    []
  }
  let end = if arguments.is_empty() {
    variant_loc
  } else {
    arguments[arguments.length() - 1].loc()
  }
  @syntax.Expr::QualifiedVariant(
    type_name~,
    type_arguments~,
    variant~,
    arguments~,
    loc=join_span(start, end),
  )
}

///|
fn State::parse_variant_arguments(self : State) -> Array[@syntax.Expr] {
  self.expect(@lexer.Token::LPAREN, "`(`") |> ignore
  if self.peek_token() is @lexer.Token::RPAREN {
    self.report(
      "Expected at least one enum variant argument.",
      self.peek_span(),
    )
    self.consume() |> ignore
    return []
  }
  let arguments : Array[@syntax.Expr] = []
  let mut keep_going = true
  while keep_going {
    arguments.push(self.parse_expression())
    keep_going = self.match_token(@lexer.Token::COMMA) &&
      !(self.peek_token() is @lexer.Token::RPAREN)
  }
  self.expect(@lexer.Token::RPAREN, "`)`") |> ignore
  arguments
}

///|
fn State::parse_parenthesized_expression(self : State) -> @syntax.Expr {
  let start = self.expect(@lexer.Token::LPAREN, "`(`")
  if self.peek_token() is @lexer.Token::RPAREN {
    let end = self.consume().1
    @syntax.Expr::UnitLiteral(loc=join_span(start, end))
  } else {
    let expr = self.parse_expression()
    self.expect(@lexer.Token::RPAREN, "`)`") |> ignore
    expr
  }
}

///|
fn State::parse_builtin_expression(self : State) -> @syntax.Expr {
  let start = self.expect(@lexer.Token::BUILTIN, "`builtin`")
  self.expect(@lexer.Token::LPAREN, "`(`") |> ignore
  let (name, end) = match self.peek() {
    (@lexer.Token::STRING(value), loc) => {
      self.consume() |> ignore
      (value, loc)
    }
    (_, loc) => {
      self.report("Expected builtin intrinsic string.", loc)
      ("", loc)
    }
  }
  self.expect(@lexer.Token::RPAREN, "`)`") |> ignore
  @syntax.Expr::Builtin(name, loc=join_span(start, end))
}

///|
fn State::parse_function_literal(self : State) -> @syntax.Expr {
  let start = self.expect(@lexer.Token::FN, "`fn`")
  let type_parameters = self.parse_type_parameters()
  self.expect(@lexer.Token::LPAREN, "`(`") |> ignore
  let parameters : Array[@syntax.FunctionLiteralParameter] = []
  if !(self.peek_token() is @lexer.Token::RPAREN) {
    let mut keep_going = true
    while keep_going {
      parameters.push(self.parse_function_literal_parameter())
      keep_going = self.match_token(@lexer.Token::COMMA) &&
        !(self.peek_token() is @lexer.Token::RPAREN)
    }
  }
  self.expect(@lexer.Token::RPAREN, "`)`") |> ignore
  let return_type = if self.match_token(@lexer.Token::THIN_ARROW) {
    Some(self.parse_type())
  } else {
    None
  }
  let body = self.parse_block_expression()
  @syntax.Expr::FunctionLiteral(
    type_parameters~,
    parameters~,
    return_type~,
    body~,
    loc=join_span(start, body.loc()),
  )
}

///|
fn State::parse_function_literal_parameter(
  self : State,
) -> @syntax.FunctionLiteralParameter {
  let (name, start) = self.expect_ident("function literal parameter")
  let type_annotation = if self.match_token(@lexer.Token::COLON) {
    Some(self.parse_type())
  } else {
    None
  }
  let end = match type_annotation {
    Some(type_) => type_.loc()
    None => start
  }
  @syntax.FunctionLiteralParameter::{
    name,
    type_annotation,
    loc: join_span(start, end),
  }
}

///|
fn State::parse_block_expression(self : State) -> @syntax.Expr {
  let start = self.expect(@lexer.Token::LBRACE, "`{`")
  let items : Array[@syntax.LocalItem] = []
  while self.starts_local_item() {
    items.push(self.parse_local_item())
  }
  let result = if self.peek_token() is @lexer.Token::RBRACE {
    self.report("Expected final block expression.", self.peek_span())
    @syntax.Expr::UnitLiteral(loc=self.peek_span())
  } else {
    self.parse_expression()
  }
  let end = self.expect(@lexer.Token::RBRACE, "`}`")
  @syntax.Expr::Block(items~, result~, loc=join_span(start, end))
}

///|
fn State::starts_local_item(self : State) -> Bool {
  match self.peek_token() {
    @lexer.Token::LET | @lexer.Token::OPEN => true
    @lexer.Token::FN => self.looks_like_function_declaration()
    _ => false
  }
}

///|
fn State::looks_like_function_declaration(self : State) -> Bool {
  let mut index = self.next + 1
  if self.tokens.get(index) is Some((@lexer.Token::LBRACKET, _)) {
    let mut depth = 0
    while self.tokens.get(index) is Some((token, _)) {
      match token {
        @lexer.Token::LBRACKET => depth += 1
        @lexer.Token::RBRACKET => {
          depth -= 1
          if depth == 0 {
            index += 1
            break
          }
        }
        @lexer.Token::EOF => return false
        _ => ()
      }
      index += 1
    }
  }
  match self.tokens.get(index) {
    Some((@lexer.Token::IDENT(_), _)) => true
    _ => false
  }
}

///|
fn State::parse_local_item(self : State) -> @syntax.LocalItem {
  match self.peek_token() {
    @lexer.Token::LET =>
      @syntax.LocalItem::Let(
        self.parse_let_declaration(allow_anonymous=false, require_type=false),
      )
    @lexer.Token::OPEN => @syntax.LocalItem::Open(self.parse_open_declaration())
    @lexer.Token::FN =>
      @syntax.LocalItem::Function(self.parse_function_declaration())
    _ => {
      self.report("Expected local item.", self.peek_span())
      @syntax.LocalItem::Open(@syntax.OpenDeclaration::{
        name: "",
        loc: self.peek_span(),
      })
    }
  }
}

///|
fn State::parse_if_expression(self : State) -> @syntax.Expr {
  let start = self.expect(@lexer.Token::IF, "`if`")
  let condition = self.parse_expression()
  let then_branch = self.parse_block_expression()
  self.expect(@lexer.Token::ELSE, "`else`") |> ignore
  let else_branch = self.parse_block_expression()
  @syntax.Expr::If(
    condition~,
    then_branch~,
    else_branch~,
    loc=join_span(start, else_branch.loc()),
  )
}

///|
fn State::parse_match_expression(self : State) -> @syntax.Expr {
  let start = self.expect(@lexer.Token::MATCH, "`match`")
  let scrutinee = self.parse_expression()
  self.expect(@lexer.Token::LBRACE, "`{`") |> ignore
  let arms : Array[@syntax.MatchArm] = []
  while !self.at_rbrace_or_eof() {
    arms.push(self.parse_match_arm())
  }
  let end = self.expect(@lexer.Token::RBRACE, "`}`")
  @syntax.Expr::Match(scrutinee~, arms~, loc=join_span(start, end))
}

///|
fn State::at_rbrace_or_eof(self : State) -> Bool {
  self.peek_token() is @lexer.Token::RBRACE ||
  self.peek_token() is @lexer.Token::EOF
}

///|
fn State::parse_match_arm(self : State) -> @syntax.MatchArm {
  let pattern = self.parse_pattern()
  self.expect(@lexer.Token::FAT_ARROW, "`=>`") |> ignore
  let body = self.parse_expression()
  @syntax.MatchArm::{ pattern, body, loc: join_span(pattern.loc(), body.loc()) }
}

///|
fn State::parse_pattern(self : State) -> @syntax.Pattern {
  match self.peek_token() {
    @lexer.Token::UNDERSCORE => {
      let loc = self.consume().1
      @syntax.Pattern::Wildcard(loc)
    }
    @lexer.Token::INT(value) => {
      let loc = self.consume().1
      @syntax.Pattern::IntLiteral(value, loc~)
    }
    @lexer.Token::STRING(value) => {
      let loc = self.consume().1
      @syntax.Pattern::StringLiteral(value, loc~)
    }
    @lexer.Token::TRUE => {
      let loc = self.consume().1
      @syntax.Pattern::BoolLiteral(true, loc~)
    }
    @lexer.Token::FALSE => {
      let loc = self.consume().1
      @syntax.Pattern::BoolLiteral(false, loc~)
    }
    @lexer.Token::IDENT(_) => self.parse_identifier_pattern()
    _ => {
      let loc = self.peek_span()
      self.report("Expected pattern.", loc)
      self.consume() |> ignore
      @syntax.Pattern::Wildcard(loc)
    }
  }
}

///|
fn State::parse_identifier_pattern(self : State) -> @syntax.Pattern {
  let (name, start) = self.expect_ident("pattern")
  if self.match_token(@lexer.Token::COLONCOLON) {
    if self.peek_token() is @lexer.Token::LBRACE {
      self.expect(@lexer.Token::LBRACE, "`{`") |> ignore
      let fields : Array[@syntax.StructPatternField] = []
      if !(self.peek_token() is @lexer.Token::RBRACE) {
        let mut keep_going = true
        while keep_going {
          fields.push(self.parse_struct_pattern_field())
          keep_going = self.match_token(@lexer.Token::COMMA) &&
            !(self.peek_token() is @lexer.Token::RBRACE)
        }
      }
      let end = self.expect(@lexer.Token::RBRACE, "`}`")
      @syntax.Pattern::Struct(
        type_name=name,
        fields~,
        loc=join_span(start, end),
      )
    } else {
      let (variant, variant_loc) = self.expect_ident("enum variant pattern")
      let arguments = if self.peek_token() is @lexer.Token::LPAREN {
        self.expect(@lexer.Token::LPAREN, "`(`") |> ignore
        let args = self.parse_comma_separated_patterns_until(
          @lexer.Token::RPAREN,
        )
        self.expect(@lexer.Token::RPAREN, "`)`") |> ignore
        args
      } else {
        []
      }
      let end = if arguments.is_empty() {
        variant_loc
      } else {
        arguments[arguments.length() - 1].loc()
      }
      @syntax.Pattern::QualifiedVariant(
        type_name=name,
        variant~,
        arguments~,
        loc=join_span(start, end),
      )
    }
  } else {
    @syntax.Pattern::Binding(name, loc=start)
  }
}

///|
fn State::parse_struct_pattern_field(
  self : State,
) -> @syntax.StructPatternField {
  let (name, start) = self.expect_ident("struct pattern field")
  let pattern = if self.match_token(@lexer.Token::COLON) {
    Some(self.parse_pattern())
  } else {
    None
  }
  let end = match pattern {
    Some(pattern) => pattern.loc()
    None => start
  }
  @syntax.StructPatternField::{ name, pattern, loc: join_span(start, end) }
}

///|
fn State::parse_comma_separated_patterns_until(
  self : State,
  end_token : @lexer.Token,
) -> Array[@syntax.Pattern] {
  let items : Array[@syntax.Pattern] = []
  if self.peek_token() == end_token {
    return items
  }
  let mut keep_going = true
  while keep_going {
    items.push(self.parse_pattern())
    keep_going = self.match_token(@lexer.Token::COMMA) &&
      self.peek_token() != end_token
  }
  items
}
