///|
pub(all) enum Token {
  CHAR(String)
  INT(String)
  STRING(String)
  IDENT(String)
  RESERVED(String)
  EOF
  FALSE
  TRUE
  STRUCT
  ENUM
  FN
  LET
  OPEN
  IF
  ELSE
  MATCH
  BUILTIN
  PLUS
  MINUS
  STAR
  SLASH
  PERCENT
  EQEQ
  BANGEQ
  LT
  LTEQ
  GT
  GTEQ
  AMPAMP
  BARBAR
  BANG
  PIPE
  LPAREN
  RPAREN
  LBRACE
  RBRACE
  LBRACKET
  RBRACKET
  COMMA
  DOT
  COLON
  COLONCOLON
  THIN_ARROW
  FAT_ARROW
  EQUAL
  UNDERSCORE
} derive(Debug)

///|
pub fn Token::kind(self : Token) -> TokenKind {
  match self {
    CHAR(_) => TK_CHAR
    INT(_) => TK_INT
    STRING(_) => TK_STRING
    IDENT(_) => TK_IDENT
    RESERVED(_) => TK_RESERVED
    EOF => TK_EOF
    FALSE => TK_FALSE
    TRUE => TK_TRUE
    STRUCT => TK_STRUCT
    ENUM => TK_ENUM
    FN => TK_FN
    LET => TK_LET
    OPEN => TK_OPEN
    IF => TK_IF
    ELSE => TK_ELSE
    MATCH => TK_MATCH
    BUILTIN => TK_BUILTIN
    PLUS => TK_PLUS
    MINUS => TK_MINUS
    STAR => TK_STAR
    SLASH => TK_SLASH
    PERCENT => TK_PERCENT
    EQEQ => TK_EQEQ
    BANGEQ => TK_BANGEQ
    LT => TK_LT
    LTEQ => TK_LTEQ
    GT => TK_GT
    GTEQ => TK_GTEQ
    AMPAMP => TK_AMPAMP
    BARBAR => TK_BARBAR
    BANG => TK_BANG
    PIPE => TK_PIPE
    LPAREN => TK_LPAREN
    RPAREN => TK_RPAREN
    LBRACE => TK_LBRACE
    RBRACE => TK_RBRACE
    LBRACKET => TK_LBRACKET
    RBRACKET => TK_RBRACKET
    COMMA => TK_COMMA
    DOT => TK_DOT
    COLON => TK_COLON
    COLONCOLON => TK_COLONCOLON
    THIN_ARROW => TK_THIN_ARROW
    FAT_ARROW => TK_FAT_ARROW
    EQUAL => TK_EQUAL
    UNDERSCORE => TK_UNDERSCORE
  }
}

///|
pub(all) enum TokenKind {
  TK_CHAR
  TK_INT
  TK_STRING
  TK_IDENT
  TK_RESERVED
  TK_EOF
  TK_FALSE
  TK_TRUE
  TK_STRUCT
  TK_ENUM
  TK_FN
  TK_LET
  TK_OPEN
  TK_IF
  TK_ELSE
  TK_MATCH
  TK_BUILTIN
  TK_PLUS
  TK_MINUS
  TK_STAR
  TK_SLASH
  TK_PERCENT
  TK_EQEQ
  TK_BANGEQ
  TK_LT
  TK_LTEQ
  TK_GT
  TK_GTEQ
  TK_AMPAMP
  TK_BARBAR
  TK_BANG
  TK_PIPE
  TK_LPAREN
  TK_RPAREN
  TK_LBRACE
  TK_RBRACE
  TK_LBRACKET
  TK_RBRACKET
  TK_COMMA
  TK_DOT
  TK_COLON
  TK_COLONCOLON
  TK_THIN_ARROW
  TK_FAT_ARROW
  TK_EQUAL
  TK_UNDERSCORE
} derive(Eq, Hash, Compare)

///|
pub impl Show for TokenKind with fn output(self, logger) {
  logger.write_string(
    match self {
      TK_CHAR => "CHAR"
      TK_INT => "INT"
      TK_STRING => "STRING"
      TK_IDENT => "IDENT"
      TK_RESERVED => "RESERVED"
      TK_EOF => "EOF"
      TK_FALSE => "\"false\""
      TK_TRUE => "\"true\""
      TK_STRUCT => "\"struct\""
      TK_ENUM => "\"enum\""
      TK_FN => "\"fn\""
      TK_LET => "\"let\""
      TK_OPEN => "\"open\""
      TK_IF => "\"if\""
      TK_ELSE => "\"else\""
      TK_MATCH => "\"match\""
      TK_BUILTIN => "\"builtin\""
      TK_PLUS => "\"+\""
      TK_MINUS => "\"-\""
      TK_STAR => "\"*\""
      TK_SLASH => "\"/\""
      TK_PERCENT => "\"%\""
      TK_EQEQ => "\"==\""
      TK_BANGEQ => "\"!=\""
      TK_LT => "\"<\""
      TK_LTEQ => "\"<=\""
      TK_GT => "\">\""
      TK_GTEQ => "\">=\""
      TK_AMPAMP => "\"&&\""
      TK_BARBAR => "\"||\""
      TK_BANG => "\"!\""
      TK_PIPE => "\"|>\""
      TK_LPAREN => "\"(\""
      TK_RPAREN => "\")\""
      TK_LBRACE => "\"{\""
      TK_RBRACE => "\"}\""
      TK_LBRACKET => "\"[\""
      TK_RBRACKET => "\"]\""
      TK_COMMA => "\",\""
      TK_DOT => "\".\""
      TK_COLON => "\":\""
      TK_COLONCOLON => "\"::\""
      TK_THIN_ARROW => "\"->\""
      TK_FAT_ARROW => "\"=>\""
      TK_EQUAL => "\"=\""
      TK_UNDERSCORE => "\"_\""
    },
  )
}

///|
pub impl Debug for TokenKind with fn to_repr(self) {
  match self {
    TK_CHAR => to_repr("CHAR")
    TK_INT => to_repr("INT")
    TK_STRING => to_repr("STRING")
    TK_IDENT => to_repr("IDENT")
    TK_RESERVED => to_repr("RESERVED")
    TK_EOF => to_repr("EOF")
    TK_FALSE => to_repr("false")
    TK_TRUE => to_repr("true")
    TK_STRUCT => to_repr("struct")
    TK_ENUM => to_repr("enum")
    TK_FN => to_repr("fn")
    TK_LET => to_repr("let")
    TK_OPEN => to_repr("open")
    TK_IF => to_repr("if")
    TK_ELSE => to_repr("else")
    TK_MATCH => to_repr("match")
    TK_BUILTIN => to_repr("builtin")
    TK_PLUS => to_repr("+")
    TK_MINUS => to_repr("-")
    TK_STAR => to_repr("*")
    TK_SLASH => to_repr("/")
    TK_PERCENT => to_repr("%")
    TK_EQEQ => to_repr("==")
    TK_BANGEQ => to_repr("!=")
    TK_LT => to_repr("<")
    TK_LTEQ => to_repr("<=")
    TK_GT => to_repr(">")
    TK_GTEQ => to_repr(">=")
    TK_AMPAMP => to_repr("&&")
    TK_BARBAR => to_repr("||")
    TK_BANG => to_repr("!")
    TK_PIPE => to_repr("|>")
    TK_LPAREN => to_repr("(")
    TK_RPAREN => to_repr(")")
    TK_LBRACE => to_repr("{")
    TK_RBRACE => to_repr("}")
    TK_LBRACKET => to_repr("[")
    TK_RBRACKET => to_repr("]")
    TK_COMMA => to_repr(",")
    TK_DOT => to_repr(".")
    TK_COLON => to_repr(":")
    TK_COLONCOLON => to_repr("::")
    TK_THIN_ARROW => to_repr("->")
    TK_FAT_ARROW => to_repr("=>")
    TK_EQUAL => to_repr("=")
    TK_UNDERSCORE => to_repr("_")
  }
}

///|
pub suberror ParseError {
  UnexpectedToken(Token, (SourceSpan, SourceSpan), Array[TokenKind])
  UnexpectedEndOfInput(SourceSpan, Array[TokenKind])
} derive(Debug)

///|
type YYObj = Error

///|
priv suberror YYObj_Void

///|
priv suberror YYObj_Expr {
  YYObj_Expr(Expr)
}

///|
priv suberror YYObj_Type {
  YYObj_Type(Type)
}

///|
priv suberror YYObj_Array_Expr_ {
  YYObj_Array_Expr_(Array[Expr])
}

///|
priv suberror YYObj_Array_Type_ {
  YYObj_Array_Type_(Array[Type])
}

///|
priv suberror YYObj_Array_String_ {
  YYObj_Array_String_(Array[String])
}

///|
priv suberror YYObj_Array_Pattern_ {
  YYObj_Array_Pattern_(Array[Pattern])
}

///|
priv suberror YYObj_Array_MatchArm_ {
  YYObj_Array_MatchArm_(Array[MatchArm])
}

///|
priv suberror YYObj_Array_LocalItem_ {
  YYObj_Array_LocalItem_(Array[LocalItem])
}

///|
priv suberror YYObj_Array_Parameter_ {
  YYObj_Array_Parameter_(Array[Parameter])
}

///|
priv suberror YYObj_Array_EnumVariant_ {
  YYObj_Array_EnumVariant_(Array[EnumVariant])
}

///|
priv suberror YYObj_Array_StructMember_ {
  YYObj_Array_StructMember_(Array[StructMember])
}

///|
priv suberror YYObj_Array_StructLiteralField_ {
  YYObj_Array_StructLiteralField_(Array[StructLiteralField])
}

///|
priv suberror YYObj_Array_StructPatternField_ {
  YYObj_Array_StructPatternField_(Array[StructPatternField])
}

///|
priv suberror YYObj_Array_TopLevelDeclaration_ {
  YYObj_Array_TopLevelDeclaration_(Array[TopLevelDeclaration])
}

///|
priv suberror YYObj_Array_FunctionLiteralParameter_ {
  YYObj_Array_FunctionLiteralParameter_(Array[FunctionLiteralParameter])
}

///|
priv suberror YYObj_String {
  YYObj_String(String)
}

///|
priv suberror YYObj_Pattern {
  YYObj_Pattern(Pattern)
}

///|
priv suberror YYObj_MatchArm {
  YYObj_MatchArm(MatchArm)
}

///|
priv suberror YYObj_LocalItem {
  YYObj_LocalItem(LocalItem)
}

///|
priv suberror YYObj_Parameter {
  YYObj_Parameter(Parameter)
}

///|
priv suberror YYObj_SourceFile {
  YYObj_SourceFile(SourceFile)
}

///|
priv suberror YYObj_EnumVariant {
  YYObj_EnumVariant(EnumVariant)
}

///|
priv suberror YYObj_StructMember {
  YYObj_StructMember(StructMember)
}

///|
priv suberror YYObj_LetDeclaration {
  YYObj_LetDeclaration(LetDeclaration)
}

///|
priv suberror YYObj_EnumDeclaration {
  YYObj_EnumDeclaration(EnumDeclaration)
}

///|
priv suberror YYObj_OpenDeclaration {
  YYObj_OpenDeclaration(OpenDeclaration)
}

///|
priv suberror YYObj_FieldDeclaration {
  YYObj_FieldDeclaration(FieldDeclaration)
}

///|
priv suberror YYObj_StructDeclaration {
  YYObj_StructDeclaration(StructDeclaration)
}

///|
priv suberror YYObj_StructLiteralField {
  YYObj_StructLiteralField(StructLiteralField)
}

///|
priv suberror YYObj_StructPatternField {
  YYObj_StructPatternField(StructPatternField)
}

///|
priv suberror YYObj_FunctionDeclaration {
  YYObj_FunctionDeclaration(FunctionDeclaration)
}

///|
priv suberror YYObj_TopLevelDeclaration {
  YYObj_TopLevelDeclaration(TopLevelDeclaration)
}

///|
priv suberror YYObj_FunctionLiteralParameter {
  YYObj_FunctionLiteralParameter(FunctionLiteralParameter)
}

///|
priv suberror YYObj_Type_ {
  YYObj_Type_(Type?)
}

///|
type YYState = (YYSymbol) -> YYDecision

///|
type YYAction = (SourceSpan, ArrayView[(YYObj, SourceSpan, SourceSpan)]) -> YYObj

///|
priv enum YYDecision {
  Accept
  Shift(YYState)
  Reduce(Int, YYSymbol, YYAction)
  ReduceNoLookahead(Int, YYSymbol, YYAction)
  Error
}

///|
priv enum YYSymbol {
  T_CHAR
  T_INT
  T_STRING
  T_IDENT
  T_RESERVED
  T_EOF
  T_FALSE
  T_TRUE
  T_STRUCT
  T_ENUM
  T_FN
  T_LET
  T_OPEN
  T_IF
  T_ELSE
  T_MATCH
  T_BUILTIN
  T_PLUS
  T_MINUS
  T_STAR
  T_SLASH
  T_PERCENT
  T_EQEQ
  T_BANGEQ
  T_LT
  T_LTEQ
  T_GT
  T_GTEQ
  T_AMPAMP
  T_BARBAR
  T_BANG
  T_PIPE
  T_LPAREN
  T_RPAREN
  T_LBRACE
  T_RBRACE
  T_LBRACKET
  T_RBRACKET
  T_COMMA
  T_DOT
  T_COLON
  T_COLONCOLON
  T_THIN_ARROW
  T_FAT_ARROW
  T_EQUAL
  T_UNDERSCORE
  NT_source_file
  NT_top_level_declarations
  NT_top_level_declaration
  NT_struct_declaration
  NT_struct_members
  NT_struct_member
  NT_field_declaration
  NT_enum_declaration
  NT_enum_variants
  NT_enum_variant
  NT_function_declaration
  NT_parameters
  NT_non_empty_parameter_list
  NT_parameter
  NT_top_level_let_declaration
  NT_local_let_declaration
  NT_local_type_annotation
  NT_open_declaration
  NT_type_parameters
  NT_non_empty_ident_list
  NT_type
  NT_named_type
  NT_function_type
  NT_type_list
  NT_non_empty_type_list
  NT_expression
  NT_primary_expression
  NT_qualified_expression
  NT_type_arguments
  NT_struct_literal_fields
  NT_non_empty_struct_literal_fields
  NT_struct_literal_field
  NT_variant_arguments
  NT_argument_list
  NT_non_empty_argument_list
  NT_block_expression
  NT_local_items
  NT_local_item
  NT_if_expression
  NT_match_expression
  NT_match_arms
  NT_match_arm
  NT_function_literal
  NT_function_literal_parameters
  NT_non_empty_function_literal_parameters
  NT_function_literal_parameter
  NT_return_type_annotation
  NT_builtin_expression
  NT_pattern
  NT_pattern_arguments
  NT_pattern_list
  NT_non_empty_pattern_list
  NT_struct_pattern_fields
  NT_non_empty_struct_pattern_fields
  NT_struct_pattern_field
  EOI
}

// Workaround for EOI unused warning

///|
fn init {
  match (EOI : YYSymbol) {
    EOI => ()
    _ => ()
  }
}

// file:///./parser.mbty
// 70|    top_level_declarations EOF {
// 71|    SourceFile::{ declarations: $1, loc: span($sloc) }
// 72|  }

///|
fn yy_action_0(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Array_TopLevelDeclaration_(_dollar1)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_SourceFile(
    {
      ()
      SourceFile::{
        declarations: _dollar1,
        loc: span((_symbol_start_pos, _end_pos)),
      }
    },
  )
}

// file:///./parser.mbty
// 77|    top_level_declarations top_level_declaration { comma_push($1, $2) }

///|
fn yy_action_1(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Array_TopLevelDeclaration_(_dollar1)
  guard _args[1].0 is YYObj_TopLevelDeclaration(_dollar2)
  YYObj_Array_TopLevelDeclaration_(
    {
      ()
      comma_push(_dollar1, _dollar2)
    },
  )
}

// file:///./parser.mbty
// 81|    struct_declaration { TopLevelDeclaration::Struct($1) }

///|
fn yy_action_2(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_StructDeclaration(_dollar1)
  YYObj_TopLevelDeclaration(
    {
      ()
      TopLevelDeclaration::Struct(_dollar1)
    },
  )
}

// file:///./parser.mbty
// 82|    enum_declaration { TopLevelDeclaration::Enum($1) }

///|
fn yy_action_3(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_EnumDeclaration(_dollar1)
  YYObj_TopLevelDeclaration(
    {
      ()
      TopLevelDeclaration::Enum(_dollar1)
    },
  )
}

// file:///./parser.mbty
// 83|    function_declaration { TopLevelDeclaration::Function($1) }

///|
fn yy_action_4(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_FunctionDeclaration(_dollar1)
  YYObj_TopLevelDeclaration(
    {
      ()
      TopLevelDeclaration::Function(_dollar1)
    },
  )
}

// file:///./parser.mbty
// 84|    top_level_let_declaration { TopLevelDeclaration::Let($1) }

///|
fn yy_action_5(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_LetDeclaration(_dollar1)
  YYObj_TopLevelDeclaration(
    {
      ()
      TopLevelDeclaration::Let(_dollar1)
    },
  )
}

// file:///./parser.mbty
// 85|    open_declaration { TopLevelDeclaration::Open($1) }

///|
fn yy_action_6(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_OpenDeclaration(_dollar1)
  YYObj_TopLevelDeclaration(
    {
      ()
      TopLevelDeclaration::Open(_dollar1)
    },
  )
}

// file:///./parser.mbty
// 89|    "struct" IDENT type_parameters "{" struct_members "}" {
// 90|    StructDeclaration::{ name: $2, type_parameters: $3, members: $5, loc: span($sloc) }
// 91|  }

///|
fn yy_action_7(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[1].0 is YYObj_String(_dollar2)
  guard _args[2].0 is YYObj_Array_String_(_dollar3)
  guard _args[4].0 is YYObj_Array_StructMember_(_dollar5)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_StructDeclaration(
    {
      ()
      StructDeclaration::{
        name: _dollar2,
        type_parameters: _dollar3,
        members: _dollar5,
        loc: span((_symbol_start_pos, _end_pos)),
      }
    },
  )
}

// file:///./parser.mbty
// 96|    struct_members struct_member { comma_push($1, $2) }

///|
fn yy_action_8(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Array_StructMember_(_dollar1)
  guard _args[1].0 is YYObj_StructMember(_dollar2)
  YYObj_Array_StructMember_(
    {
      ()
      comma_push(_dollar1, _dollar2)
    },
  )
}

// file:///./parser.mbty
// 100|    field_declaration { StructMember::Field($1) }

///|
fn yy_action_9(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_FieldDeclaration(_dollar1)
  YYObj_StructMember(
    {
      ()
      StructMember::Field(_dollar1)
    },
  )
}

// file:///./parser.mbty
// 101|    open_declaration { StructMember::Open($1) }

///|
fn yy_action_10(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_OpenDeclaration(_dollar1)
  YYObj_StructMember(
    {
      ()
      StructMember::Open(_dollar1)
    },
  )
}

// file:///./parser.mbty
// 105|    IDENT ":" type {
// 106|    FieldDeclaration::{ name: $1, type_: $3, loc: span($sloc) }
// 107|  }

///|
fn yy_action_11(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_String(_dollar1)
  guard _args[2].0 is YYObj_Type(_dollar3)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_FieldDeclaration(
    {
      ()
      FieldDeclaration::{
        name: _dollar1,
        type_: _dollar3,
        loc: span((_symbol_start_pos, _end_pos)),
      }
    },
  )
}

// file:///./parser.mbty
// 95|    { [] }

///|
fn yy_action_12(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  YYObj_Array_StructMember_(
    {
      ()
      []
    },
  )
}

// file:///./parser.mbty
// 111|    "enum" IDENT type_parameters "{" enum_variants "}" {
// 112|    EnumDeclaration::{ name: $2, type_parameters: $3, variants: $5, loc: span($sloc) }
// 113|  }

///|
fn yy_action_13(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[1].0 is YYObj_String(_dollar2)
  guard _args[2].0 is YYObj_Array_String_(_dollar3)
  guard _args[4].0 is YYObj_Array_EnumVariant_(_dollar5)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_EnumDeclaration(
    {
      ()
      EnumDeclaration::{
        name: _dollar2,
        type_parameters: _dollar3,
        variants: _dollar5,
        loc: span((_symbol_start_pos, _end_pos)),
      }
    },
  )
}

// file:///./parser.mbty
// 118|    enum_variants enum_variant { comma_push($1, $2) }

///|
fn yy_action_14(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Array_EnumVariant_(_dollar1)
  guard _args[1].0 is YYObj_EnumVariant(_dollar2)
  YYObj_Array_EnumVariant_(
    {
      ()
      comma_push(_dollar1, _dollar2)
    },
  )
}

// file:///./parser.mbty
// 125|    IDENT "(" non_empty_type_list ")" {
// 126|    EnumVariant::{ name: $1, payload: $3, loc: span($sloc) }
// 127|  }

///|
fn yy_action_15(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_String(_dollar1)
  guard _args[2].0 is YYObj_Array_Type_(_dollar3)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_EnumVariant(
    {
      ()
      EnumVariant::{
        name: _dollar1,
        payload: _dollar3,
        loc: span((_symbol_start_pos, _end_pos)),
      }
    },
  )
}

// file:///./parser.mbty
// 122|    IDENT {
// 123|    EnumVariant::{ name: $1, payload: [], loc: span($sloc) }
// 124|  }

///|
fn yy_action_16(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_String(_dollar1)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_EnumVariant(
    {
      ()
      EnumVariant::{
        name: _dollar1,
        payload: [],
        loc: span((_symbol_start_pos, _end_pos)),
      }
    },
  )
}

// file:///./parser.mbty
// 117|    { [] }

///|
fn yy_action_17(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  YYObj_Array_EnumVariant_(
    {
      ()
      []
    },
  )
}

// file:///./parser.mbty
// 160|    "let" IDENT ":" type "=" expression {
// 161|    LetDeclaration::{ name: Some($2), type_annotation: Some($4), initializer: $6, loc: span($sloc) }
// 162|  }

///|
fn yy_action_18(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[1].0 is YYObj_String(_dollar2)
  guard _args[3].0 is YYObj_Type(_dollar4)
  guard _args[5].0 is YYObj_Expr(_dollar6)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_LetDeclaration(
    {
      ()
      LetDeclaration::{
        name: Some(_dollar2),
        type_annotation: Some(_dollar4),
        initializer: _dollar6,
        loc: span((_symbol_start_pos, _end_pos)),
      }
    },
  )
}

// file:///./parser.mbty
// 163|    "let" ":" type "=" expression {
// 164|    LetDeclaration::{ name: None, type_annotation: Some($3), initializer: $5, loc: span($sloc) }
// 165|  }

///|
fn yy_action_19(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[2].0 is YYObj_Type(_dollar3)
  guard _args[4].0 is YYObj_Expr(_dollar5)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_LetDeclaration(
    {
      ()
      LetDeclaration::{
        name: None,
        type_annotation: Some(_dollar3),
        initializer: _dollar5,
        loc: span((_symbol_start_pos, _end_pos)),
      }
    },
  )
}

// file:///./parser.mbty
// 131|    "fn" type_parameters IDENT parameters "->" type block_expression {
// 132|    FunctionDeclaration::{
// 133|      type_parameters: $2,
// 134|      name: $3,
// 135|      parameters: $4,
// 136|      return_type: $6,
// 137|      body: $7,
// 138|      loc: span($sloc),
// 139|    }
// 140|  }

///|
fn yy_action_20(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[1].0 is YYObj_Array_String_(_dollar2)
  guard _args[2].0 is YYObj_String(_dollar3)
  guard _args[3].0 is YYObj_Array_Parameter_(_dollar4)
  guard _args[5].0 is YYObj_Type(_dollar6)
  guard _args[6].0 is YYObj_Expr(_dollar7)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_FunctionDeclaration(
    {
      ()
      FunctionDeclaration::{
        type_parameters: _dollar2,
        name: _dollar3,
        parameters: _dollar4,
        return_type: _dollar6,
        body: _dollar7,
        loc: span((_symbol_start_pos, _end_pos)),
      }
    },
  )
}

// file:///./parser.mbty
// 144|    "(" ")" { [] }

///|
fn yy_action_21(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  YYObj_Array_Parameter_(
    {
      ()
      []
    },
  )
}

// file:///./parser.mbty
// 145|    "(" non_empty_parameter_list ")" { $2 }

///|
fn yy_action_22(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[1].0 is YYObj_Array_Parameter_(_dollar2)
  YYObj_Array_Parameter_(
    {
      ()
      _dollar2
    },
  )
}

// file:///./parser.mbty
// 150|    non_empty_parameter_list "," parameter { comma_push($1, $3) }

///|
fn yy_action_23(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Array_Parameter_(_dollar1)
  guard _args[2].0 is YYObj_Parameter(_dollar3)
  YYObj_Array_Parameter_(
    {
      ()
      comma_push(_dollar1, _dollar3)
    },
  )
}

// file:///./parser.mbty
// 149|    parameter { [ $1 ] }

///|
fn yy_action_24(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Parameter(_dollar1)
  YYObj_Array_Parameter_(
    {
      ()
      [_dollar1]
    },
  )
}

// file:///./parser.mbty
// 154|    IDENT ":" type {
// 155|    Parameter::{ name: $1, type_: $3, loc: span($sloc) }
// 156|  }

///|
fn yy_action_25(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_String(_dollar1)
  guard _args[2].0 is YYObj_Type(_dollar3)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Parameter(
    {
      ()
      Parameter::{
        name: _dollar1,
        type_: _dollar3,
        loc: span((_symbol_start_pos, _end_pos)),
      }
    },
  )
}

// file:///./parser.mbty
// 187|    "[" non_empty_ident_list "]" { $2 }

///|
fn yy_action_26(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[1].0 is YYObj_Array_String_(_dollar2)
  YYObj_Array_String_(
    {
      ()
      _dollar2
    },
  )
}

// file:///./parser.mbty
// 169|    "let" IDENT local_type_annotation "=" expression {
// 170|    LetDeclaration::{ name: Some($2), type_annotation: $3, initializer: $5, loc: span($sloc) }
// 171|  }

///|
fn yy_action_27(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[1].0 is YYObj_String(_dollar2)
  guard _args[2].0 is YYObj_Type_(_dollar3)
  guard _args[4].0 is YYObj_Expr(_dollar5)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_LetDeclaration(
    {
      ()
      LetDeclaration::{
        name: Some(_dollar2),
        type_annotation: _dollar3,
        initializer: _dollar5,
        loc: span((_symbol_start_pos, _end_pos)),
      }
    },
  )
}

// file:///./parser.mbty
// 354|    "{" local_items expression "}" {
// 355|    Expr::Block(items=$2, result=$3, loc=span($sloc))
// 356|  }

///|
fn yy_action_28(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[1].0 is YYObj_Array_LocalItem_(_dollar2)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Expr(
    {
      ()
      Expr::Block(
        items=_dollar2,
        result=_dollar3,
        loc=span((_symbol_start_pos, _end_pos)),
      )
    },
  )
}

// file:///./parser.mbty
// 361|    local_items local_item { comma_push($1, $2) }

///|
fn yy_action_29(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Array_LocalItem_(_dollar1)
  guard _args[1].0 is YYObj_LocalItem(_dollar2)
  YYObj_Array_LocalItem_(
    {
      ()
      comma_push(_dollar1, _dollar2)
    },
  )
}

// file:///./parser.mbty
// 365|    local_let_declaration { LocalItem::Let($1) }

///|
fn yy_action_30(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_LetDeclaration(_dollar1)
  YYObj_LocalItem(
    {
      ()
      LocalItem::Let(_dollar1)
    },
  )
}

// file:///./parser.mbty
// 366|    function_declaration { LocalItem::Function($1) }

///|
fn yy_action_31(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_FunctionDeclaration(_dollar1)
  YYObj_LocalItem(
    {
      ()
      LocalItem::Function(_dollar1)
    },
  )
}

// file:///./parser.mbty
// 367|    open_declaration { LocalItem::Open($1) }

///|
fn yy_action_32(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_OpenDeclaration(_dollar1)
  YYObj_LocalItem(
    {
      ()
      LocalItem::Open(_dollar1)
    },
  )
}

// file:///./parser.mbty
// 377|    "match" expression "{" match_arms "}" {
// 378|    Expr::Match(scrutinee=$2, arms=$4, loc=span($sloc))
// 379|  }

///|
fn yy_action_33(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[1].0 is YYObj_Expr(_dollar2)
  guard _args[3].0 is YYObj_Array_MatchArm_(_dollar4)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Expr(
    {
      ()
      Expr::Match(
        scrutinee=_dollar2,
        arms=_dollar4,
        loc=span((_symbol_start_pos, _end_pos)),
      )
    },
  )
}

// file:///./parser.mbty
// 384|    match_arms match_arm { comma_push($1, $2) }

///|
fn yy_action_34(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Array_MatchArm_(_dollar1)
  guard _args[1].0 is YYObj_MatchArm(_dollar2)
  YYObj_Array_MatchArm_(
    {
      ()
      comma_push(_dollar1, _dollar2)
    },
  )
}

// file:///./parser.mbty
// 388|    pattern "=>" expression {
// 389|    MatchArm::{ pattern: $1, body: $3, loc: span($sloc) }
// 390|  }

///|
fn yy_action_35(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Pattern(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_MatchArm(
    {
      ()
      MatchArm::{
        pattern: _dollar1,
        body: _dollar3,
        loc: span((_symbol_start_pos, _end_pos)),
      }
    },
  )
}

// file:///./parser.mbty
// 433|    IDENT "::" "{" struct_pattern_fields "}" {
// 434|    Pattern::Struct(type_name=$1, fields=$4, loc=span($sloc))
// 435|  }

///|
fn yy_action_36(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_String(_dollar1)
  guard _args[3].0 is YYObj_Array_StructPatternField_(_dollar4)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Pattern(
    {
      ()
      Pattern::Struct(
        type_name=_dollar1,
        fields=_dollar4,
        loc=span((_symbol_start_pos, _end_pos)),
      )
    },
  )
}

// file:///./parser.mbty
// 464|    non_empty_struct_pattern_fields "," struct_pattern_field { comma_push($1, $3) }

///|
fn yy_action_37(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Array_StructPatternField_(_dollar1)
  guard _args[2].0 is YYObj_StructPatternField(_dollar3)
  YYObj_Array_StructPatternField_(
    {
      ()
      comma_push(_dollar1, _dollar3)
    },
  )
}

// file:///./parser.mbty
// 465|    non_empty_struct_pattern_fields "," { $1 }

///|
fn yy_action_38(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Array_StructPatternField_(_dollar1)
  YYObj_Array_StructPatternField_(
    {
      ()
      _dollar1
    },
  )
}

// file:///./parser.mbty
// 459|    non_empty_struct_pattern_fields { $1 }

///|
fn yy_action_39(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Array_StructPatternField_(_dollar1)
  YYObj_Array_StructPatternField_(
    {
      ()
      _dollar1
    },
  )
}

// file:///./parser.mbty
// 463|    struct_pattern_field { [ $1 ] }

///|
fn yy_action_40(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_StructPatternField(_dollar1)
  YYObj_Array_StructPatternField_(
    {
      ()
      [_dollar1]
    },
  )
}

// file:///./parser.mbty
// 472|    IDENT ":" pattern {
// 473|    StructPatternField::{ name: $1, pattern: Some($3), loc: span($sloc) }
// 474|  }

///|
fn yy_action_41(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_String(_dollar1)
  guard _args[2].0 is YYObj_Pattern(_dollar3)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_StructPatternField(
    {
      ()
      StructPatternField::{
        name: _dollar1,
        pattern: Some(_dollar3),
        loc: span((_symbol_start_pos, _end_pos)),
      }
    },
  )
}

// file:///./parser.mbty
// 469|    IDENT {
// 470|    StructPatternField::{ name: $1, pattern: None, loc: span($sloc) }
// 471|  }

///|
fn yy_action_42(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_String(_dollar1)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_StructPatternField(
    {
      ()
      StructPatternField::{
        name: _dollar1,
        pattern: None,
        loc: span((_symbol_start_pos, _end_pos)),
      }
    },
  )
}

// file:///./parser.mbty
// 458|    { [] }

///|
fn yy_action_43(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  YYObj_Array_StructPatternField_(
    {
      ()
      []
    },
  )
}

// file:///./parser.mbty
// 436|    IDENT "::" IDENT pattern_arguments {
// 437|    Pattern::QualifiedVariant(type_name=$1, variant=$3, arguments=$4, loc=span($sloc))
// 438|  }

///|
fn yy_action_44(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_String(_dollar1)
  guard _args[2].0 is YYObj_String(_dollar3)
  guard _args[3].0 is YYObj_Array_Pattern_(_dollar4)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Pattern(
    {
      ()
      Pattern::QualifiedVariant(
        type_name=_dollar1,
        variant=_dollar3,
        arguments=_dollar4,
        loc=span((_symbol_start_pos, _end_pos)),
      )
    },
  )
}

// file:///./parser.mbty
// 443|    "(" pattern_list ")" { $2 }

///|
fn yy_action_45(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[1].0 is YYObj_Array_Pattern_(_dollar2)
  YYObj_Array_Pattern_(
    {
      ()
      _dollar2
    },
  )
}

// file:///./parser.mbty
// 427|    "_" { Pattern::Wildcard(span($sloc)) }

///|
fn yy_action_46(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Pattern(
    {
      ()
      Pattern::Wildcard(span((_symbol_start_pos, _end_pos)))
    },
  )
}

// file:///./parser.mbty
// 428|    INT { Pattern::IntLiteral($1, loc=span($sloc)) }

///|
fn yy_action_47(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_String(_dollar1)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Pattern(
    {
      ()
      Pattern::IntLiteral(_dollar1, loc=span((_symbol_start_pos, _end_pos)))
    },
  )
}

// file:///./parser.mbty
// 429|    STRING { Pattern::StringLiteral($1, loc=span($sloc)) }

///|
fn yy_action_48(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_String(_dollar1)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Pattern(
    {
      ()
      Pattern::StringLiteral(_dollar1, loc=span((_symbol_start_pos, _end_pos)))
    },
  )
}

// file:///./parser.mbty
// 430|    "true" { Pattern::BoolLiteral(true, loc=span($sloc)) }

///|
fn yy_action_49(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Pattern(
    {
      ()
      Pattern::BoolLiteral(true, loc=span((_symbol_start_pos, _end_pos)))
    },
  )
}

// file:///./parser.mbty
// 431|    "false" { Pattern::BoolLiteral(false, loc=span($sloc)) }

///|
fn yy_action_50(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Pattern(
    {
      ()
      Pattern::BoolLiteral(false, loc=span((_symbol_start_pos, _end_pos)))
    },
  )
}

// file:///./parser.mbty
// 453|    non_empty_pattern_list "," pattern { comma_push($1, $3) }

///|
fn yy_action_51(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Array_Pattern_(_dollar1)
  guard _args[2].0 is YYObj_Pattern(_dollar3)
  YYObj_Array_Pattern_(
    {
      ()
      comma_push(_dollar1, _dollar3)
    },
  )
}

// file:///./parser.mbty
// 454|    non_empty_pattern_list "," { $1 }

///|
fn yy_action_52(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Array_Pattern_(_dollar1)
  YYObj_Array_Pattern_(
    {
      ()
      _dollar1
    },
  )
}

// file:///./parser.mbty
// 448|    non_empty_pattern_list { $1 }

///|
fn yy_action_53(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Array_Pattern_(_dollar1)
  YYObj_Array_Pattern_(
    {
      ()
      _dollar1
    },
  )
}

// file:///./parser.mbty
// 452|    pattern { [ $1 ] }

///|
fn yy_action_54(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Pattern(_dollar1)
  YYObj_Array_Pattern_(
    {
      ()
      [_dollar1]
    },
  )
}

// file:///./parser.mbty
// 447|    { [] }

///|
fn yy_action_55(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  YYObj_Array_Pattern_(
    {
      ()
      []
    },
  )
}

// file:///./parser.mbty
// 442|    { [] }

///|
fn yy_action_56(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  YYObj_Array_Pattern_(
    {
      ()
      []
    },
  )
}

// file:///./parser.mbty
// 432|    IDENT { Pattern::Binding($1, loc=span($sloc)) }

///|
fn yy_action_57(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_String(_dollar1)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Pattern(
    {
      ()
      Pattern::Binding(_dollar1, loc=span((_symbol_start_pos, _end_pos)))
    },
  )
}

// file:///./parser.mbty
// 383|    { [] }

///|
fn yy_action_58(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  YYObj_Array_MatchArm_(
    {
      ()
      []
    },
  )
}

// file:///./parser.mbty
// 371|    "if" expression block_expression "else" block_expression {
// 372|    Expr::If(condition=$2, then_branch=$3, else_branch=$5, loc=span($sloc))
// 373|  }

///|
fn yy_action_59(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[1].0 is YYObj_Expr(_dollar2)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  guard _args[4].0 is YYObj_Expr(_dollar5)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Expr(
    {
      ()
      Expr::If(
        condition=_dollar2,
        then_branch=_dollar3,
        else_branch=_dollar5,
        loc=span((_symbol_start_pos, _end_pos)),
      )
    },
  )
}

// file:///./parser.mbty
// 295|    "(" expression ")" { $2 }

///|
fn yy_action_60(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[1].0 is YYObj_Expr(_dollar2)
  YYObj_Expr(
    {
      ()
      _dollar2
    },
  )
}

// file:///./parser.mbty
// 304|    IDENT type_arguments "::" "{" struct_literal_fields "}" {
// 305|    Expr::StructLiteral(type_name=$1, type_arguments=$2, fields=$5, loc=span($sloc))
// 306|  }

///|
fn yy_action_61(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_String(_dollar1)
  guard _args[1].0 is YYObj_Array_Type_(_dollar2)
  guard _args[4].0 is YYObj_Array_StructLiteralField_(_dollar5)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Expr(
    {
      ()
      Expr::StructLiteral(
        type_name=_dollar1,
        type_arguments=_dollar2,
        fields=_dollar5,
        loc=span((_symbol_start_pos, _end_pos)),
      )
    },
  )
}

// file:///./parser.mbty
// 324|    non_empty_struct_literal_fields "," struct_literal_field { comma_push($1, $3) }

///|
fn yy_action_62(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Array_StructLiteralField_(_dollar1)
  guard _args[2].0 is YYObj_StructLiteralField(_dollar3)
  YYObj_Array_StructLiteralField_(
    {
      ()
      comma_push(_dollar1, _dollar3)
    },
  )
}

// file:///./parser.mbty
// 325|    non_empty_struct_literal_fields "," { $1 }

///|
fn yy_action_63(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Array_StructLiteralField_(_dollar1)
  YYObj_Array_StructLiteralField_(
    {
      ()
      _dollar1
    },
  )
}

// file:///./parser.mbty
// 319|    non_empty_struct_literal_fields { $1 }

///|
fn yy_action_64(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Array_StructLiteralField_(_dollar1)
  YYObj_Array_StructLiteralField_(
    {
      ()
      _dollar1
    },
  )
}

// file:///./parser.mbty
// 323|    struct_literal_field { [ $1 ] }

///|
fn yy_action_65(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_StructLiteralField(_dollar1)
  YYObj_Array_StructLiteralField_(
    {
      ()
      [_dollar1]
    },
  )
}

// file:///./parser.mbty
// 332|    IDENT ":" expression {
// 333|    StructLiteralField::{ name: $1, value: Some($3), loc: span($sloc) }
// 334|  }

///|
fn yy_action_66(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_String(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_StructLiteralField(
    {
      ()
      StructLiteralField::{
        name: _dollar1,
        value: Some(_dollar3),
        loc: span((_symbol_start_pos, _end_pos)),
      }
    },
  )
}

// file:///./parser.mbty
// 329|    IDENT {
// 330|    StructLiteralField::{ name: $1, value: None, loc: span($sloc) }
// 331|  }

///|
fn yy_action_67(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_String(_dollar1)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_StructLiteralField(
    {
      ()
      StructLiteralField::{
        name: _dollar1,
        value: None,
        loc: span((_symbol_start_pos, _end_pos)),
      }
    },
  )
}

// file:///./parser.mbty
// 318|    { [] }

///|
fn yy_action_68(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  YYObj_Array_StructLiteralField_(
    {
      ()
      []
    },
  )
}

// file:///./parser.mbty
// 307|    IDENT type_arguments "::" IDENT variant_arguments {
// 308|    Expr::QualifiedVariant(type_name=$1, type_arguments=$2, variant=$4, arguments=$5, loc=span($sloc))
// 309|  }

///|
fn yy_action_69(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_String(_dollar1)
  guard _args[1].0 is YYObj_Array_Type_(_dollar2)
  guard _args[3].0 is YYObj_String(_dollar4)
  guard _args[4].0 is YYObj_Array_Expr_(_dollar5)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Expr(
    {
      ()
      Expr::QualifiedVariant(
        type_name=_dollar1,
        type_arguments=_dollar2,
        variant=_dollar4,
        arguments=_dollar5,
        loc=span((_symbol_start_pos, _end_pos)),
      )
    },
  )
}

// file:///./parser.mbty
// 339|    "(" non_empty_argument_list ")" { $2 }

///|
fn yy_action_70(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[1].0 is YYObj_Array_Expr_(_dollar2)
  YYObj_Array_Expr_(
    {
      ()
      _dollar2
    },
  )
}

// file:///./parser.mbty
// 349|    non_empty_argument_list "," expression { comma_push($1, $3) }

///|
fn yy_action_71(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Array_Expr_(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  YYObj_Array_Expr_(
    {
      ()
      comma_push(_dollar1, _dollar3)
    },
  )
}

// file:///./parser.mbty
// 275|    "!" expression %prec UNARY {
// 276|    Expr::Unary(operator=UnaryOperator::Not, operand=$2, loc=span($sloc))
// 277|  }

///|
fn yy_action_72(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[1].0 is YYObj_Expr(_dollar2)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Expr(
    {
      ()
      Expr::Unary(
        operator=UnaryOperator::Not,
        operand=_dollar2,
        loc=span((_symbol_start_pos, _end_pos)),
      )
    },
  )
}

// file:///./parser.mbty
// 230|    expression "|>" expression {
// 231|    Expr::Pipeline(left=$1, right=$3, loc=span($sloc))
// 232|  }

///|
fn yy_action_73(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Expr(
    {
      ()
      Expr::Pipeline(
        left=_dollar1,
        right=_dollar3,
        loc=span((_symbol_start_pos, _end_pos)),
      )
    },
  )
}

// file:///./parser.mbty
// 233|    expression "||" expression {
// 234|    Expr::Binary(operator=BinaryOperator::Or, left=$1, right=$3, loc=span($sloc))
// 235|  }

///|
fn yy_action_74(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Expr(
    {
      ()
      Expr::Binary(
        operator=BinaryOperator::Or,
        left=_dollar1,
        right=_dollar3,
        loc=span((_symbol_start_pos, _end_pos)),
      )
    },
  )
}

// file:///./parser.mbty
// 236|    expression "&&" expression {
// 237|    Expr::Binary(operator=BinaryOperator::And, left=$1, right=$3, loc=span($sloc))
// 238|  }

///|
fn yy_action_75(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Expr(
    {
      ()
      Expr::Binary(
        operator=BinaryOperator::And,
        left=_dollar1,
        right=_dollar3,
        loc=span((_symbol_start_pos, _end_pos)),
      )
    },
  )
}

// file:///./parser.mbty
// 239|    expression "==" expression {
// 240|    Expr::Binary(operator=BinaryOperator::Equal, left=$1, right=$3, loc=span($sloc))
// 241|  }

///|
fn yy_action_76(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Expr(
    {
      ()
      Expr::Binary(
        operator=BinaryOperator::Equal,
        left=_dollar1,
        right=_dollar3,
        loc=span((_symbol_start_pos, _end_pos)),
      )
    },
  )
}

// file:///./parser.mbty
// 242|    expression "!=" expression {
// 243|    Expr::Binary(operator=BinaryOperator::NotEqual, left=$1, right=$3, loc=span($sloc))
// 244|  }

///|
fn yy_action_77(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Expr(
    {
      ()
      Expr::Binary(
        operator=BinaryOperator::NotEqual,
        left=_dollar1,
        right=_dollar3,
        loc=span((_symbol_start_pos, _end_pos)),
      )
    },
  )
}

// file:///./parser.mbty
// 245|    expression "<" expression {
// 246|    Expr::Binary(operator=BinaryOperator::Less, left=$1, right=$3, loc=span($sloc))
// 247|  }

///|
fn yy_action_78(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Expr(
    {
      ()
      Expr::Binary(
        operator=BinaryOperator::Less,
        left=_dollar1,
        right=_dollar3,
        loc=span((_symbol_start_pos, _end_pos)),
      )
    },
  )
}

// file:///./parser.mbty
// 248|    expression "<=" expression {
// 249|    Expr::Binary(operator=BinaryOperator::LessEqual, left=$1, right=$3, loc=span($sloc))
// 250|  }

///|
fn yy_action_79(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Expr(
    {
      ()
      Expr::Binary(
        operator=BinaryOperator::LessEqual,
        left=_dollar1,
        right=_dollar3,
        loc=span((_symbol_start_pos, _end_pos)),
      )
    },
  )
}

// file:///./parser.mbty
// 251|    expression ">" expression {
// 252|    Expr::Binary(operator=BinaryOperator::Greater, left=$1, right=$3, loc=span($sloc))
// 253|  }

///|
fn yy_action_80(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Expr(
    {
      ()
      Expr::Binary(
        operator=BinaryOperator::Greater,
        left=_dollar1,
        right=_dollar3,
        loc=span((_symbol_start_pos, _end_pos)),
      )
    },
  )
}

// file:///./parser.mbty
// 254|    expression ">=" expression {
// 255|    Expr::Binary(operator=BinaryOperator::GreaterEqual, left=$1, right=$3, loc=span($sloc))
// 256|  }

///|
fn yy_action_81(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Expr(
    {
      ()
      Expr::Binary(
        operator=BinaryOperator::GreaterEqual,
        left=_dollar1,
        right=_dollar3,
        loc=span((_symbol_start_pos, _end_pos)),
      )
    },
  )
}

// file:///./parser.mbty
// 257|    expression "+" expression {
// 258|    Expr::Binary(operator=BinaryOperator::Add, left=$1, right=$3, loc=span($sloc))
// 259|  }

///|
fn yy_action_82(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Expr(
    {
      ()
      Expr::Binary(
        operator=BinaryOperator::Add,
        left=_dollar1,
        right=_dollar3,
        loc=span((_symbol_start_pos, _end_pos)),
      )
    },
  )
}

// file:///./parser.mbty
// 260|    expression "-" expression {
// 261|    Expr::Binary(operator=BinaryOperator::Sub, left=$1, right=$3, loc=span($sloc))
// 262|  }

///|
fn yy_action_83(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Expr(
    {
      ()
      Expr::Binary(
        operator=BinaryOperator::Sub,
        left=_dollar1,
        right=_dollar3,
        loc=span((_symbol_start_pos, _end_pos)),
      )
    },
  )
}

// file:///./parser.mbty
// 263|    expression "*" expression {
// 264|    Expr::Binary(operator=BinaryOperator::Mul, left=$1, right=$3, loc=span($sloc))
// 265|  }

///|
fn yy_action_84(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Expr(
    {
      ()
      Expr::Binary(
        operator=BinaryOperator::Mul,
        left=_dollar1,
        right=_dollar3,
        loc=span((_symbol_start_pos, _end_pos)),
      )
    },
  )
}

// file:///./parser.mbty
// 266|    expression "/" expression {
// 267|    Expr::Binary(operator=BinaryOperator::Div, left=$1, right=$3, loc=span($sloc))
// 268|  }

///|
fn yy_action_85(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Expr(
    {
      ()
      Expr::Binary(
        operator=BinaryOperator::Div,
        left=_dollar1,
        right=_dollar3,
        loc=span((_symbol_start_pos, _end_pos)),
      )
    },
  )
}

// file:///./parser.mbty
// 269|    expression "%" expression {
// 270|    Expr::Binary(operator=BinaryOperator::Rem, left=$1, right=$3, loc=span($sloc))
// 271|  }

///|
fn yy_action_86(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Expr(
    {
      ()
      Expr::Binary(
        operator=BinaryOperator::Rem,
        left=_dollar1,
        right=_dollar3,
        loc=span((_symbol_start_pos, _end_pos)),
      )
    },
  )
}

// file:///./parser.mbty
// 348|    expression { [ $1 ] }

///|
fn yy_action_87(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  YYObj_Array_Expr_(
    {
      ()
      [_dollar1]
    },
  )
}

// file:///./parser.mbty
// 278|    expression "(" argument_list ")" {
// 279|    Expr::Call(callee=$1, arguments=$3, loc=span($sloc))
// 280|  }

///|
fn yy_action_88(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[2].0 is YYObj_Array_Expr_(_dollar3)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Expr(
    {
      ()
      Expr::Call(
        callee=_dollar1,
        arguments=_dollar3,
        loc=span((_symbol_start_pos, _end_pos)),
      )
    },
  )
}

// file:///./parser.mbty
// 344|    non_empty_argument_list { $1 }

///|
fn yy_action_89(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Array_Expr_(_dollar1)
  YYObj_Array_Expr_(
    {
      ()
      _dollar1
    },
  )
}

// file:///./parser.mbty
// 343|    { [] }

///|
fn yy_action_90(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  YYObj_Array_Expr_(
    {
      ()
      []
    },
  )
}

// file:///./parser.mbty
// 281|    expression "." IDENT {
// 282|    Expr::Field(base=$1, name=$3, loc=span($sloc))
// 283|  }

///|
fn yy_action_91(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[2].0 is YYObj_String(_dollar3)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Expr(
    {
      ()
      Expr::Field(
        base=_dollar1,
        name=_dollar3,
        loc=span((_symbol_start_pos, _end_pos)),
      )
    },
  )
}

// file:///./parser.mbty
// 272|    "-" expression %prec UNARY {
// 273|    Expr::Unary(operator=UnaryOperator::Neg, operand=$2, loc=span($sloc))
// 274|  }

///|
fn yy_action_92(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[1].0 is YYObj_Expr(_dollar2)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Expr(
    {
      ()
      Expr::Unary(
        operator=UnaryOperator::Neg,
        operand=_dollar2,
        loc=span((_symbol_start_pos, _end_pos)),
      )
    },
  )
}

// file:///./parser.mbty
// 284|    primary_expression { $1 }

///|
fn yy_action_93(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  YYObj_Expr(
    {
      ()
      _dollar1
    },
  )
}

// file:///./parser.mbty
// 288|    INT { Expr::IntLiteral($1, loc=span($sloc)) }

///|
fn yy_action_94(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_String(_dollar1)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Expr(
    {
      ()
      Expr::IntLiteral(_dollar1, loc=span((_symbol_start_pos, _end_pos)))
    },
  )
}

// file:///./parser.mbty
// 289|    STRING { Expr::StringLiteral($1, loc=span($sloc)) }

///|
fn yy_action_95(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_String(_dollar1)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Expr(
    {
      ()
      Expr::StringLiteral(_dollar1, loc=span((_symbol_start_pos, _end_pos)))
    },
  )
}

// file:///./parser.mbty
// 290|    "true" { Expr::BoolLiteral(true, loc=span($sloc)) }

///|
fn yy_action_96(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Expr(
    {
      ()
      Expr::BoolLiteral(true, loc=span((_symbol_start_pos, _end_pos)))
    },
  )
}

// file:///./parser.mbty
// 291|    "false" { Expr::BoolLiteral(false, loc=span($sloc)) }

///|
fn yy_action_97(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Expr(
    {
      ()
      Expr::BoolLiteral(false, loc=span((_symbol_start_pos, _end_pos)))
    },
  )
}

// file:///./parser.mbty
// 350|    non_empty_argument_list "," { $1 }

///|
fn yy_action_98(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Array_Expr_(_dollar1)
  YYObj_Array_Expr_(
    {
      ()
      _dollar1
    },
  )
}

// file:///./parser.mbty
// 338|    { [] }

///|
fn yy_action_99(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  YYObj_Array_Expr_(
    {
      ()
      []
    },
  )
}

// file:///./parser.mbty
// 314|    "[" type_list "]" { $2 }

///|
fn yy_action_100(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[1].0 is YYObj_Array_Type_(_dollar2)
  YYObj_Array_Type_(
    {
      ()
      _dollar2
    },
  )
}

// file:///./parser.mbty
// 313|    { [] }

///|
fn yy_action_101(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  YYObj_Array_Type_(
    {
      ()
      []
    },
  )
}

// file:///./parser.mbty
// 292|    IDENT { Expr::Var($1, loc=span($sloc)) }

///|
fn yy_action_102(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_String(_dollar1)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Expr(
    {
      ()
      Expr::Var(_dollar1, loc=span((_symbol_start_pos, _end_pos)))
    },
  )
}

// file:///./parser.mbty
// 293|    qualified_expression { $1 }

///|
fn yy_action_103(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  YYObj_Expr(
    {
      ()
      _dollar1
    },
  )
}

// file:///./parser.mbty
// 294|    "(" ")" { Expr::UnitLiteral(loc=span($sloc)) }

///|
fn yy_action_104(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Expr(
    {
      ()
      Expr::UnitLiteral(loc=span((_symbol_start_pos, _end_pos)))
    },
  )
}

// file:///./parser.mbty
// 296|    block_expression { $1 }

///|
fn yy_action_105(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  YYObj_Expr(
    {
      ()
      _dollar1
    },
  )
}

// file:///./parser.mbty
// 297|    if_expression { $1 }

///|
fn yy_action_106(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  YYObj_Expr(
    {
      ()
      _dollar1
    },
  )
}

// file:///./parser.mbty
// 298|    match_expression { $1 }

///|
fn yy_action_107(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  YYObj_Expr(
    {
      ()
      _dollar1
    },
  )
}

// file:///./parser.mbty
// 299|    function_literal { $1 }

///|
fn yy_action_108(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  YYObj_Expr(
    {
      ()
      _dollar1
    },
  )
}

// file:///./parser.mbty
// 300|    builtin_expression { $1 }

///|
fn yy_action_109(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  YYObj_Expr(
    {
      ()
      _dollar1
    },
  )
}

// file:///./parser.mbty
// 360|    { [] }

///|
fn yy_action_110(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  YYObj_Array_LocalItem_(
    {
      ()
      []
    },
  )
}

// file:///./parser.mbty
// 394|    "fn" type_parameters "(" function_literal_parameters ")" return_type_annotation block_expression {
// 395|    Expr::FunctionLiteral(type_parameters=$2, parameters=$4, return_type=$6, body=$7, loc=span($sloc))
// 396|  }

///|
fn yy_action_111(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[1].0 is YYObj_Array_String_(_dollar2)
  guard _args[3].0 is YYObj_Array_FunctionLiteralParameter_(_dollar4)
  guard _args[5].0 is YYObj_Type_(_dollar6)
  guard _args[6].0 is YYObj_Expr(_dollar7)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Expr(
    {
      ()
      Expr::FunctionLiteral(
        type_parameters=_dollar2,
        parameters=_dollar4,
        return_type=_dollar6,
        body=_dollar7,
        loc=span((_symbol_start_pos, _end_pos)),
      )
    },
  )
}

// file:///./parser.mbty
// 417|    "->" type { Some($2) }

///|
fn yy_action_112(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[1].0 is YYObj_Type(_dollar2)
  YYObj_Type_(
    {
      ()
      Some(_dollar2)
    },
  )
}

// file:///./parser.mbty
// 416|    { None }

///|
fn yy_action_113(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  YYObj_Type_(
    {
      ()
      None
    },
  )
}

// file:///./parser.mbty
// 406|    non_empty_function_literal_parameters "," function_literal_parameter { comma_push($1, $3) }

///|
fn yy_action_114(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Array_FunctionLiteralParameter_(_dollar1)
  guard _args[2].0 is YYObj_FunctionLiteralParameter(_dollar3)
  YYObj_Array_FunctionLiteralParameter_(
    {
      ()
      comma_push(_dollar1, _dollar3)
    },
  )
}

// file:///./parser.mbty
// 401|    non_empty_function_literal_parameters { $1 }

///|
fn yy_action_115(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Array_FunctionLiteralParameter_(_dollar1)
  YYObj_Array_FunctionLiteralParameter_(
    {
      ()
      _dollar1
    },
  )
}

// file:///./parser.mbty
// 405|    function_literal_parameter { [ $1 ] }

///|
fn yy_action_116(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_FunctionLiteralParameter(_dollar1)
  YYObj_Array_FunctionLiteralParameter_(
    {
      ()
      [_dollar1]
    },
  )
}

// file:///./parser.mbty
// 176|    ":" type { Some($2) }

///|
fn yy_action_117(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[1].0 is YYObj_Type(_dollar2)
  YYObj_Type_(
    {
      ()
      Some(_dollar2)
    },
  )
}

// file:///./parser.mbty
// 410|    IDENT local_type_annotation {
// 411|    FunctionLiteralParameter::{ name: $1, type_annotation: $2, loc: span($sloc) }
// 412|  }

///|
fn yy_action_118(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_String(_dollar1)
  guard _args[1].0 is YYObj_Type_(_dollar2)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_FunctionLiteralParameter(
    {
      ()
      FunctionLiteralParameter::{
        name: _dollar1,
        type_annotation: _dollar2,
        loc: span((_symbol_start_pos, _end_pos)),
      }
    },
  )
}

// file:///./parser.mbty
// 175|    { None }

///|
fn yy_action_119(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  YYObj_Type_(
    {
      ()
      None
    },
  )
}

// file:///./parser.mbty
// 400|    { [] }

///|
fn yy_action_120(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  YYObj_Array_FunctionLiteralParameter_(
    {
      ()
      []
    },
  )
}

// file:///./parser.mbty
// 186|    { [] }

///|
fn yy_action_121(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  YYObj_Array_String_(
    {
      ()
      []
    },
  )
}

// file:///./parser.mbty
// 421|    "builtin" "(" STRING ")" {
// 422|    Expr::Builtin($3, loc=span($sloc))
// 423|  }

///|
fn yy_action_122(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[2].0 is YYObj_String(_dollar3)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Expr(
    {
      ()
      Expr::Builtin(_dollar3, loc=span((_symbol_start_pos, _end_pos)))
    },
  )
}

// file:///./parser.mbty
// 214|    "(" type_list ")" "->" type {
// 215|    Type::Function(type_parameters=[], parameters=$2, result=$5, loc=span($sloc))
// 216|  }

///|
fn yy_action_123(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[1].0 is YYObj_Array_Type_(_dollar2)
  guard _args[4].0 is YYObj_Type(_dollar5)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Type(
    {
      ()
      Type::Function(
        type_parameters=[],
        parameters=_dollar2,
        result=_dollar5,
        loc=span((_symbol_start_pos, _end_pos)),
      )
    },
  )
}

// file:///./parser.mbty
// 196|    named_type { $1 }

///|
fn yy_action_124(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Type(_dollar1)
  YYObj_Type(
    {
      ()
      _dollar1
    },
  )
}

// file:///./parser.mbty
// 197|    function_type { $1 }

///|
fn yy_action_125(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Type(_dollar1)
  YYObj_Type(
    {
      ()
      _dollar1
    },
  )
}

// file:///./parser.mbty
// 191|    IDENT { [ $1 ] }

///|
fn yy_action_126(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_String(_dollar1)
  YYObj_Array_String_(
    {
      ()
      [_dollar1]
    },
  )
}

// file:///./parser.mbty
// 192|    non_empty_ident_list "," IDENT { comma_push($1, $3) }

///|
fn yy_action_127(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Array_String_(_dollar1)
  guard _args[2].0 is YYObj_String(_dollar3)
  YYObj_Array_String_(
    {
      ()
      comma_push(_dollar1, _dollar3)
    },
  )
}

// file:///./parser.mbty
// 198|    "[" non_empty_ident_list "]" function_type {
// 199|    guard $4 is Type::Function(type_parameters=_, parameters~, result~, loc~)
// 200|    Type::Function(type_parameters=$2, parameters~, result~, loc~)
// 201|  }

///|
fn yy_action_128(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[3].0 is YYObj_Type(_dollar4)
  guard _args[1].0 is YYObj_Array_String_(_dollar2)
  YYObj_Type(
    {
      ()
      guard _dollar4
        is Type::Function(type_parameters=_, parameters~, result~, loc~)
      Type::Function(type_parameters=_dollar2, parameters~, result~, loc~)
    },
  )
}

// file:///./parser.mbty
// 208|    IDENT "[" type_list "]" {
// 209|    Type::Name(name=$1, arguments=$3, loc=span($sloc))
// 210|  }

///|
fn yy_action_129(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_String(_dollar1)
  guard _args[2].0 is YYObj_Array_Type_(_dollar3)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Type(
    {
      ()
      Type::Name(
        name=_dollar1,
        arguments=_dollar3,
        loc=span((_symbol_start_pos, _end_pos)),
      )
    },
  )
}

// file:///./parser.mbty
// 205|    IDENT {
// 206|    Type::Name(name=$1, arguments=[], loc=span($sloc))
// 207|  }

///|
fn yy_action_130(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_String(_dollar1)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_Type(
    {
      ()
      Type::Name(
        name=_dollar1,
        arguments=[],
        loc=span((_symbol_start_pos, _end_pos)),
      )
    },
  )
}

// file:///./parser.mbty
// 226|    non_empty_type_list "," type { comma_push($1, $3) }

///|
fn yy_action_131(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Array_Type_(_dollar1)
  guard _args[2].0 is YYObj_Type(_dollar3)
  YYObj_Array_Type_(
    {
      ()
      comma_push(_dollar1, _dollar3)
    },
  )
}

// file:///./parser.mbty
// 221|    non_empty_type_list { $1 }

///|
fn yy_action_132(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Array_Type_(_dollar1)
  YYObj_Array_Type_(
    {
      ()
      _dollar1
    },
  )
}

// file:///./parser.mbty
// 225|    type { [ $1 ] }

///|
fn yy_action_133(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[0].0 is YYObj_Type(_dollar1)
  YYObj_Array_Type_(
    {
      ()
      [_dollar1]
    },
  )
}

// file:///./parser.mbty
// 220|    { [] }

///|
fn yy_action_134(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  YYObj_Array_Type_(
    {
      ()
      []
    },
  )
}

// file:///./parser.mbty
// 180|    "open" IDENT {
// 181|    OpenDeclaration::{ name: $2, loc: span($sloc) }
// 182|  }

///|
fn yy_action_135(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  guard _args[1].0 is YYObj_String(_dollar2)
  let _symbol_start_pos = _get_symbol_start_pos(_args, _last_pos)
  let _end_pos = if _args.length() == 0 {
    _last_pos
  } else {
    _args[_args.length() - 1].2
  }
  YYObj_OpenDeclaration(
    {
      ()
      OpenDeclaration::{
        name: _dollar2,
        loc: span((_symbol_start_pos, _end_pos)),
      }
    },
  )
}

// file:///./parser.mbty
// 76|    { [] }

///|
fn yy_action_136(
  _last_pos : SourceSpan,
  _args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
) -> YYObj {
  YYObj_Array_TopLevelDeclaration_(
    {
      ()
      []
    },
  )
}

///|
fn yy_input(
  token : Token,
  _start_pos : SourceSpan,
  _end_pos : SourceSpan,
) -> (YYSymbol, YYObj) {
  match token {
    CHAR(data) => (T_CHAR, YYObj_String(data))
    INT(data) => (T_INT, YYObj_String(data))
    STRING(data) => (T_STRING, YYObj_String(data))
    IDENT(data) => (T_IDENT, YYObj_String(data))
    RESERVED(data) => (T_RESERVED, YYObj_String(data))
    EOF => (T_EOF, YYObj_Void)
    FALSE => (T_FALSE, YYObj_Void)
    TRUE => (T_TRUE, YYObj_Void)
    STRUCT => (T_STRUCT, YYObj_Void)
    ENUM => (T_ENUM, YYObj_Void)
    FN => (T_FN, YYObj_Void)
    LET => (T_LET, YYObj_Void)
    OPEN => (T_OPEN, YYObj_Void)
    IF => (T_IF, YYObj_Void)
    ELSE => (T_ELSE, YYObj_Void)
    MATCH => (T_MATCH, YYObj_Void)
    BUILTIN => (T_BUILTIN, YYObj_Void)
    PLUS => (T_PLUS, YYObj_Void)
    MINUS => (T_MINUS, YYObj_Void)
    STAR => (T_STAR, YYObj_Void)
    SLASH => (T_SLASH, YYObj_Void)
    PERCENT => (T_PERCENT, YYObj_Void)
    EQEQ => (T_EQEQ, YYObj_Void)
    BANGEQ => (T_BANGEQ, YYObj_Void)
    LT => (T_LT, YYObj_Void)
    LTEQ => (T_LTEQ, YYObj_Void)
    GT => (T_GT, YYObj_Void)
    GTEQ => (T_GTEQ, YYObj_Void)
    AMPAMP => (T_AMPAMP, YYObj_Void)
    BARBAR => (T_BARBAR, YYObj_Void)
    BANG => (T_BANG, YYObj_Void)
    PIPE => (T_PIPE, YYObj_Void)
    LPAREN => (T_LPAREN, YYObj_Void)
    RPAREN => (T_RPAREN, YYObj_Void)
    LBRACE => (T_LBRACE, YYObj_Void)
    RBRACE => (T_RBRACE, YYObj_Void)
    LBRACKET => (T_LBRACKET, YYObj_Void)
    RBRACKET => (T_RBRACKET, YYObj_Void)
    COMMA => (T_COMMA, YYObj_Void)
    DOT => (T_DOT, YYObj_Void)
    COLON => (T_COLON, YYObj_Void)
    COLONCOLON => (T_COLONCOLON, YYObj_Void)
    THIN_ARROW => (T_THIN_ARROW, YYObj_Void)
    FAT_ARROW => (T_FAT_ARROW, YYObj_Void)
    EQUAL => (T_EQUAL, YYObj_Void)
    UNDERSCORE => (T_UNDERSCORE, YYObj_Void)
  }
}

///|
fn yy_state_0(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    NT_source_file => Shift(yy_state_1)
    NT_top_level_declarations => Shift(yy_state_2)
    T_EOF | T_STRUCT | T_ENUM | T_FN | T_LET | T_OPEN =>
      Reduce(0, NT_top_level_declarations, yy_action_136)
    _ => Error
  }
}

///|
fn yy_state_1(_lookahead : YYSymbol) -> YYDecision {
  Accept
}

///|
fn yy_state_2(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_OPEN => Shift(yy_state_3)
    T_LET => Shift(yy_state_5)
    T_FN => Shift(yy_state_208)
    T_ENUM => Shift(yy_state_210)
    T_STRUCT => Shift(yy_state_221)
    NT_open_declaration => Shift(yy_state_233)
    NT_top_level_let_declaration => Shift(yy_state_234)
    NT_function_declaration => Shift(yy_state_235)
    NT_enum_declaration => Shift(yy_state_236)
    NT_struct_declaration => Shift(yy_state_237)
    NT_top_level_declaration => Shift(yy_state_238)
    T_EOF => Shift(yy_state_239)
    _ => Error
  }
}

///|
fn yy_state_3(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_4)
    _ => Error
  }
}

///|
fn yy_state_4(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(2, NT_open_declaration, yy_action_135)
}

///|
fn yy_state_5(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_COLON => Shift(yy_state_6)
    T_IDENT => Shift(yy_state_203)
    _ => Error
  }
}

///|
fn yy_state_6(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LPAREN => Shift(yy_state_7)
    T_IDENT => Shift(yy_state_12)
    T_LBRACKET => Shift(yy_state_16)
    NT_function_type => Shift(yy_state_23)
    NT_named_type => Shift(yy_state_24)
    NT_type => Shift(yy_state_29)
    _ => Error
  }
}

///|
fn yy_state_7(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LPAREN => Shift(yy_state_7)
    NT_type => Shift(yy_state_8)
    NT_non_empty_type_list => Shift(yy_state_9)
    T_IDENT => Shift(yy_state_12)
    T_LBRACKET => Shift(yy_state_16)
    NT_function_type => Shift(yy_state_23)
    NT_named_type => Shift(yy_state_24)
    NT_type_list => Shift(yy_state_25)
    T_RPAREN => Reduce(0, NT_type_list, yy_action_134)
    _ => Error
  }
}

///|
fn yy_state_8(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_non_empty_type_list, yy_action_133)
}

///|
fn yy_state_9(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_COMMA => Shift(yy_state_10)
    T_RPAREN | T_RBRACKET => Reduce(1, NT_type_list, yy_action_132)
    _ => Error
  }
}

///|
fn yy_state_10(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LPAREN => Shift(yy_state_7)
    NT_type => Shift(yy_state_11)
    T_IDENT => Shift(yy_state_12)
    T_LBRACKET => Shift(yy_state_16)
    NT_function_type => Shift(yy_state_23)
    NT_named_type => Shift(yy_state_24)
    _ => Error
  }
}

///|
fn yy_state_11(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_non_empty_type_list, yy_action_131)
}

///|
fn yy_state_12(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LBRACKET => Shift(yy_state_13)
    T_IDENT
    | T_OPEN
    | T_RPAREN
    | T_LBRACE
    | T_RBRACE
    | T_RBRACKET
    | T_COMMA
    | T_EQUAL => Reduce(1, NT_named_type, yy_action_130)
    _ => Error
  }
}

///|
fn yy_state_13(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LPAREN => Shift(yy_state_7)
    NT_type => Shift(yy_state_8)
    NT_non_empty_type_list => Shift(yy_state_9)
    T_IDENT => Shift(yy_state_12)
    NT_type_list => Shift(yy_state_14)
    T_LBRACKET => Shift(yy_state_16)
    NT_function_type => Shift(yy_state_23)
    NT_named_type => Shift(yy_state_24)
    T_RBRACKET => Reduce(0, NT_type_list, yy_action_134)
    _ => Error
  }
}

///|
fn yy_state_14(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_RBRACKET => Shift(yy_state_15)
    _ => Error
  }
}

///|
fn yy_state_15(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(4, NT_named_type, yy_action_129)
}

///|
fn yy_state_16(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    NT_non_empty_ident_list => Shift(yy_state_17)
    T_IDENT => Shift(yy_state_22)
    _ => Error
  }
}

///|
fn yy_state_17(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_RBRACKET => Shift(yy_state_18)
    T_COMMA => Shift(yy_state_20)
    _ => Error
  }
}

///|
fn yy_state_18(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LPAREN => Shift(yy_state_7)
    NT_function_type => Shift(yy_state_19)
    _ => Error
  }
}

///|
fn yy_state_19(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(4, NT_type, yy_action_128)
}

///|
fn yy_state_20(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_21)
    _ => Error
  }
}

///|
fn yy_state_21(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_non_empty_ident_list, yy_action_127)
}

///|
fn yy_state_22(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_non_empty_ident_list, yy_action_126)
}

///|
fn yy_state_23(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_type, yy_action_125)
}

///|
fn yy_state_24(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_type, yy_action_124)
}

///|
fn yy_state_25(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_RPAREN => Shift(yy_state_26)
    _ => Error
  }
}

///|
fn yy_state_26(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_THIN_ARROW => Shift(yy_state_27)
    _ => Error
  }
}

///|
fn yy_state_27(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LPAREN => Shift(yy_state_7)
    T_IDENT => Shift(yy_state_12)
    T_LBRACKET => Shift(yy_state_16)
    NT_function_type => Shift(yy_state_23)
    NT_named_type => Shift(yy_state_24)
    NT_type => Shift(yy_state_28)
    _ => Error
  }
}

///|
fn yy_state_28(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(5, NT_function_type, yy_action_123)
}

///|
fn yy_state_29(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_EQUAL => Shift(yy_state_30)
    _ => Error
  }
}

///|
fn yy_state_30(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_BUILTIN => Shift(yy_state_31)
    T_FN => Shift(yy_state_35)
    T_LBRACE => Shift(yy_state_52)
    T_MATCH => Shift(yy_state_54)
    T_IF => Shift(yy_state_55)
    NT_builtin_expression => Shift(yy_state_56)
    NT_function_literal => Shift(yy_state_57)
    NT_match_expression => Shift(yy_state_58)
    NT_if_expression => Shift(yy_state_59)
    NT_block_expression => Shift(yy_state_60)
    T_LPAREN => Shift(yy_state_61)
    NT_qualified_expression => Shift(yy_state_63)
    T_IDENT => Shift(yy_state_64)
    T_FALSE => Shift(yy_state_74)
    T_TRUE => Shift(yy_state_75)
    T_STRING => Shift(yy_state_76)
    T_INT => Shift(yy_state_77)
    NT_primary_expression => Shift(yy_state_78)
    T_BANG => Shift(yy_state_79)
    T_MINUS => Shift(yy_state_80)
    NT_expression => Shift(yy_state_202)
    _ => Error
  }
}

///|
fn yy_state_31(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LPAREN => Shift(yy_state_32)
    _ => Error
  }
}

///|
fn yy_state_32(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_STRING => Shift(yy_state_33)
    _ => Error
  }
}

///|
fn yy_state_33(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_RPAREN => Shift(yy_state_34)
    _ => Error
  }
}

///|
fn yy_state_34(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(4, NT_builtin_expression, yy_action_122)
}

///|
fn yy_state_35(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    NT_type_parameters => Shift(yy_state_36)
    T_LBRACKET => Shift(yy_state_183)
    T_LPAREN => Reduce(0, NT_type_parameters, yy_action_121)
    _ => Error
  }
}

///|
fn yy_state_36(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LPAREN => Shift(yy_state_37)
    _ => Error
  }
}

///|
fn yy_state_37(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_38)
    NT_function_literal_parameter => Shift(yy_state_42)
    NT_non_empty_function_literal_parameters => Shift(yy_state_43)
    NT_function_literal_parameters => Shift(yy_state_46)
    T_RPAREN => Reduce(0, NT_function_literal_parameters, yy_action_120)
    _ => Error
  }
}

///|
fn yy_state_38(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    NT_local_type_annotation => Shift(yy_state_39)
    T_COLON => Shift(yy_state_40)
    T_RPAREN | T_COMMA => Reduce(0, NT_local_type_annotation, yy_action_119)
    _ => Error
  }
}

///|
fn yy_state_39(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(2, NT_function_literal_parameter, yy_action_118)
}

///|
fn yy_state_40(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LPAREN => Shift(yy_state_7)
    T_IDENT => Shift(yy_state_12)
    T_LBRACKET => Shift(yy_state_16)
    NT_function_type => Shift(yy_state_23)
    NT_named_type => Shift(yy_state_24)
    NT_type => Shift(yy_state_41)
    _ => Error
  }
}

///|
fn yy_state_41(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(2, NT_local_type_annotation, yy_action_117)
}

///|
fn yy_state_42(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_non_empty_function_literal_parameters, yy_action_116)
}

///|
fn yy_state_43(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_COMMA => Shift(yy_state_44)
    T_RPAREN => Reduce(1, NT_function_literal_parameters, yy_action_115)
    _ => Error
  }
}

///|
fn yy_state_44(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_38)
    NT_function_literal_parameter => Shift(yy_state_45)
    _ => Error
  }
}

///|
fn yy_state_45(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_non_empty_function_literal_parameters, yy_action_114)
}

///|
fn yy_state_46(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_RPAREN => Shift(yy_state_47)
    _ => Error
  }
}

///|
fn yy_state_47(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_THIN_ARROW => Shift(yy_state_48)
    NT_return_type_annotation => Shift(yy_state_50)
    T_LBRACE => Reduce(0, NT_return_type_annotation, yy_action_113)
    _ => Error
  }
}

///|
fn yy_state_48(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LPAREN => Shift(yy_state_7)
    T_IDENT => Shift(yy_state_12)
    T_LBRACKET => Shift(yy_state_16)
    NT_function_type => Shift(yy_state_23)
    NT_named_type => Shift(yy_state_24)
    NT_type => Shift(yy_state_49)
    _ => Error
  }
}

///|
fn yy_state_49(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(2, NT_return_type_annotation, yy_action_112)
}

///|
fn yy_state_50(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    NT_block_expression => Shift(yy_state_51)
    T_LBRACE => Shift(yy_state_52)
    _ => Error
  }
}

///|
fn yy_state_51(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(7, NT_function_literal, yy_action_111)
}

///|
fn yy_state_52(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    NT_local_items => Shift(yy_state_53)
    T_INT
    | T_STRING
    | T_IDENT
    | T_FALSE
    | T_TRUE
    | T_FN
    | T_LET
    | T_OPEN
    | T_IF
    | T_MATCH
    | T_BUILTIN
    | T_MINUS
    | T_BANG
    | T_LPAREN
    | T_LBRACE => Reduce(0, NT_local_items, yy_action_110)
    _ => Error
  }
}

///|
fn yy_state_53(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_OPEN => Shift(yy_state_3)
    T_BUILTIN => Shift(yy_state_31)
    T_LBRACE => Shift(yy_state_52)
    T_MATCH => Shift(yy_state_54)
    T_IF => Shift(yy_state_55)
    NT_builtin_expression => Shift(yy_state_56)
    NT_function_literal => Shift(yy_state_57)
    NT_match_expression => Shift(yy_state_58)
    NT_if_expression => Shift(yy_state_59)
    NT_block_expression => Shift(yy_state_60)
    T_LPAREN => Shift(yy_state_61)
    NT_qualified_expression => Shift(yy_state_63)
    T_IDENT => Shift(yy_state_64)
    T_FALSE => Shift(yy_state_74)
    T_TRUE => Shift(yy_state_75)
    T_STRING => Shift(yy_state_76)
    T_INT => Shift(yy_state_77)
    NT_primary_expression => Shift(yy_state_78)
    T_BANG => Shift(yy_state_79)
    T_MINUS => Shift(yy_state_80)
    NT_open_declaration => Shift(yy_state_171)
    NT_function_declaration => Shift(yy_state_172)
    NT_local_let_declaration => Shift(yy_state_173)
    NT_local_item => Shift(yy_state_174)
    NT_expression => Shift(yy_state_175)
    T_LET => Shift(yy_state_177)
    T_FN => Shift(yy_state_182)
    _ => Error
  }
}

///|
fn yy_state_54(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_BUILTIN => Shift(yy_state_31)
    T_FN => Shift(yy_state_35)
    T_LBRACE => Shift(yy_state_52)
    T_MATCH => Shift(yy_state_54)
    T_IF => Shift(yy_state_55)
    NT_builtin_expression => Shift(yy_state_56)
    NT_function_literal => Shift(yy_state_57)
    NT_match_expression => Shift(yy_state_58)
    NT_if_expression => Shift(yy_state_59)
    NT_block_expression => Shift(yy_state_60)
    T_LPAREN => Shift(yy_state_61)
    NT_qualified_expression => Shift(yy_state_63)
    T_IDENT => Shift(yy_state_64)
    T_FALSE => Shift(yy_state_74)
    T_TRUE => Shift(yy_state_75)
    T_STRING => Shift(yy_state_76)
    T_INT => Shift(yy_state_77)
    NT_primary_expression => Shift(yy_state_78)
    T_BANG => Shift(yy_state_79)
    T_MINUS => Shift(yy_state_80)
    NT_expression => Shift(yy_state_137)
    _ => Error
  }
}

///|
fn yy_state_55(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_BUILTIN => Shift(yy_state_31)
    T_FN => Shift(yy_state_35)
    T_LBRACE => Shift(yy_state_52)
    T_MATCH => Shift(yy_state_54)
    T_IF => Shift(yy_state_55)
    NT_builtin_expression => Shift(yy_state_56)
    NT_function_literal => Shift(yy_state_57)
    NT_match_expression => Shift(yy_state_58)
    NT_if_expression => Shift(yy_state_59)
    NT_block_expression => Shift(yy_state_60)
    T_LPAREN => Shift(yy_state_61)
    NT_qualified_expression => Shift(yy_state_63)
    T_IDENT => Shift(yy_state_64)
    T_FALSE => Shift(yy_state_74)
    T_TRUE => Shift(yy_state_75)
    T_STRING => Shift(yy_state_76)
    T_INT => Shift(yy_state_77)
    NT_primary_expression => Shift(yy_state_78)
    T_BANG => Shift(yy_state_79)
    T_MINUS => Shift(yy_state_80)
    NT_expression => Shift(yy_state_133)
    _ => Error
  }
}

///|
fn yy_state_56(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_primary_expression, yy_action_109)
}

///|
fn yy_state_57(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_primary_expression, yy_action_108)
}

///|
fn yy_state_58(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_primary_expression, yy_action_107)
}

///|
fn yy_state_59(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_primary_expression, yy_action_106)
}

///|
fn yy_state_60(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_primary_expression, yy_action_105)
}

///|
fn yy_state_61(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_BUILTIN => Shift(yy_state_31)
    T_FN => Shift(yy_state_35)
    T_LBRACE => Shift(yy_state_52)
    T_MATCH => Shift(yy_state_54)
    T_IF => Shift(yy_state_55)
    NT_builtin_expression => Shift(yy_state_56)
    NT_function_literal => Shift(yy_state_57)
    NT_match_expression => Shift(yy_state_58)
    NT_if_expression => Shift(yy_state_59)
    NT_block_expression => Shift(yy_state_60)
    T_LPAREN => Shift(yy_state_61)
    T_RPAREN => Shift(yy_state_62)
    NT_qualified_expression => Shift(yy_state_63)
    T_IDENT => Shift(yy_state_64)
    T_FALSE => Shift(yy_state_74)
    T_TRUE => Shift(yy_state_75)
    T_STRING => Shift(yy_state_76)
    T_INT => Shift(yy_state_77)
    NT_primary_expression => Shift(yy_state_78)
    T_BANG => Shift(yy_state_79)
    T_MINUS => Shift(yy_state_80)
    NT_expression => Shift(yy_state_131)
    _ => Error
  }
}

///|
fn yy_state_62(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(2, NT_primary_expression, yy_action_104)
}

///|
fn yy_state_63(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_primary_expression, yy_action_103)
}

///|
fn yy_state_64(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LBRACKET => Shift(yy_state_65)
    NT_type_arguments => Shift(yy_state_68)
    T_COLONCOLON => Reduce(0, NT_type_arguments, yy_action_101)
    T_INT
    | T_STRING
    | T_IDENT
    | T_EOF
    | T_FALSE
    | T_TRUE
    | T_STRUCT
    | T_ENUM
    | T_FN
    | T_LET
    | T_OPEN
    | T_IF
    | T_MATCH
    | T_BUILTIN
    | T_PLUS
    | T_MINUS
    | T_STAR
    | T_SLASH
    | T_PERCENT
    | T_EQEQ
    | T_BANGEQ
    | T_LT
    | T_LTEQ
    | T_GT
    | T_GTEQ
    | T_AMPAMP
    | T_BARBAR
    | T_BANG
    | T_PIPE
    | T_LPAREN
    | T_RPAREN
    | T_LBRACE
    | T_RBRACE
    | T_COMMA
    | T_DOT
    | T_UNDERSCORE => Reduce(1, NT_primary_expression, yy_action_102)
    _ => Error
  }
}

///|
fn yy_state_65(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LPAREN => Shift(yy_state_7)
    NT_type => Shift(yy_state_8)
    NT_non_empty_type_list => Shift(yy_state_9)
    T_IDENT => Shift(yy_state_12)
    T_LBRACKET => Shift(yy_state_16)
    NT_function_type => Shift(yy_state_23)
    NT_named_type => Shift(yy_state_24)
    NT_type_list => Shift(yy_state_66)
    T_RBRACKET => Reduce(0, NT_type_list, yy_action_134)
    _ => Error
  }
}

///|
fn yy_state_66(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_RBRACKET => Shift(yy_state_67)
    _ => Error
  }
}

///|
fn yy_state_67(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_type_arguments, yy_action_100)
}

///|
fn yy_state_68(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_COLONCOLON => Shift(yy_state_69)
    _ => Error
  }
}

///|
fn yy_state_69(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_70)
    T_LBRACE => Shift(yy_state_121)
    _ => Error
  }
}

///|
fn yy_state_70(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LPAREN => Shift(yy_state_71)
    NT_variant_arguments => Shift(yy_state_120)
    T_INT
    | T_STRING
    | T_IDENT
    | T_EOF
    | T_FALSE
    | T_TRUE
    | T_STRUCT
    | T_ENUM
    | T_FN
    | T_LET
    | T_OPEN
    | T_IF
    | T_MATCH
    | T_BUILTIN
    | T_PLUS
    | T_MINUS
    | T_STAR
    | T_SLASH
    | T_PERCENT
    | T_EQEQ
    | T_BANGEQ
    | T_LT
    | T_LTEQ
    | T_GT
    | T_GTEQ
    | T_AMPAMP
    | T_BARBAR
    | T_BANG
    | T_PIPE
    | T_RPAREN
    | T_LBRACE
    | T_RBRACE
    | T_COMMA
    | T_DOT
    | T_UNDERSCORE => Reduce(0, NT_variant_arguments, yy_action_99)
    _ => Error
  }
}

///|
fn yy_state_71(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_BUILTIN => Shift(yy_state_31)
    T_FN => Shift(yy_state_35)
    T_LBRACE => Shift(yy_state_52)
    T_MATCH => Shift(yy_state_54)
    T_IF => Shift(yy_state_55)
    NT_builtin_expression => Shift(yy_state_56)
    NT_function_literal => Shift(yy_state_57)
    NT_match_expression => Shift(yy_state_58)
    NT_if_expression => Shift(yy_state_59)
    NT_block_expression => Shift(yy_state_60)
    T_LPAREN => Shift(yy_state_61)
    NT_qualified_expression => Shift(yy_state_63)
    T_IDENT => Shift(yy_state_64)
    NT_non_empty_argument_list => Shift(yy_state_72)
    T_FALSE => Shift(yy_state_74)
    T_TRUE => Shift(yy_state_75)
    T_STRING => Shift(yy_state_76)
    T_INT => Shift(yy_state_77)
    NT_primary_expression => Shift(yy_state_78)
    T_BANG => Shift(yy_state_79)
    T_MINUS => Shift(yy_state_80)
    NT_expression => Shift(yy_state_88)
    _ => Error
  }
}

///|
fn yy_state_72(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_COMMA => Shift(yy_state_73)
    T_RPAREN => Shift(yy_state_119)
    _ => Error
  }
}

///|
fn yy_state_73(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_BUILTIN => Shift(yy_state_31)
    T_FN => Shift(yy_state_35)
    T_LBRACE => Shift(yy_state_52)
    T_MATCH => Shift(yy_state_54)
    T_IF => Shift(yy_state_55)
    NT_builtin_expression => Shift(yy_state_56)
    NT_function_literal => Shift(yy_state_57)
    NT_match_expression => Shift(yy_state_58)
    NT_if_expression => Shift(yy_state_59)
    NT_block_expression => Shift(yy_state_60)
    T_LPAREN => Shift(yy_state_61)
    NT_qualified_expression => Shift(yy_state_63)
    T_IDENT => Shift(yy_state_64)
    T_FALSE => Shift(yy_state_74)
    T_TRUE => Shift(yy_state_75)
    T_STRING => Shift(yy_state_76)
    T_INT => Shift(yy_state_77)
    NT_primary_expression => Shift(yy_state_78)
    T_BANG => Shift(yy_state_79)
    T_MINUS => Shift(yy_state_80)
    NT_expression => Shift(yy_state_118)
    T_RPAREN | T_COMMA => Reduce(2, NT_non_empty_argument_list, yy_action_98)
    _ => Error
  }
}

///|
fn yy_state_74(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_primary_expression, yy_action_97)
}

///|
fn yy_state_75(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_primary_expression, yy_action_96)
}

///|
fn yy_state_76(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_primary_expression, yy_action_95)
}

///|
fn yy_state_77(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_primary_expression, yy_action_94)
}

///|
fn yy_state_78(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_expression, yy_action_93)
}

///|
fn yy_state_79(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_BUILTIN => Shift(yy_state_31)
    T_FN => Shift(yy_state_35)
    T_LBRACE => Shift(yy_state_52)
    T_MATCH => Shift(yy_state_54)
    T_IF => Shift(yy_state_55)
    NT_builtin_expression => Shift(yy_state_56)
    NT_function_literal => Shift(yy_state_57)
    NT_match_expression => Shift(yy_state_58)
    NT_if_expression => Shift(yy_state_59)
    NT_block_expression => Shift(yy_state_60)
    T_LPAREN => Shift(yy_state_61)
    NT_qualified_expression => Shift(yy_state_63)
    T_IDENT => Shift(yy_state_64)
    T_FALSE => Shift(yy_state_74)
    T_TRUE => Shift(yy_state_75)
    T_STRING => Shift(yy_state_76)
    T_INT => Shift(yy_state_77)
    NT_primary_expression => Shift(yy_state_78)
    T_BANG => Shift(yy_state_79)
    T_MINUS => Shift(yy_state_80)
    NT_expression => Shift(yy_state_117)
    _ => Error
  }
}

///|
fn yy_state_80(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_BUILTIN => Shift(yy_state_31)
    T_FN => Shift(yy_state_35)
    T_LBRACE => Shift(yy_state_52)
    T_MATCH => Shift(yy_state_54)
    T_IF => Shift(yy_state_55)
    NT_builtin_expression => Shift(yy_state_56)
    NT_function_literal => Shift(yy_state_57)
    NT_match_expression => Shift(yy_state_58)
    NT_if_expression => Shift(yy_state_59)
    NT_block_expression => Shift(yy_state_60)
    T_LPAREN => Shift(yy_state_61)
    NT_qualified_expression => Shift(yy_state_63)
    T_IDENT => Shift(yy_state_64)
    T_FALSE => Shift(yy_state_74)
    T_TRUE => Shift(yy_state_75)
    T_STRING => Shift(yy_state_76)
    T_INT => Shift(yy_state_77)
    NT_primary_expression => Shift(yy_state_78)
    T_BANG => Shift(yy_state_79)
    T_MINUS => Shift(yy_state_80)
    NT_expression => Shift(yy_state_81)
    _ => Error
  }
}

///|
fn yy_state_81(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_DOT => Shift(yy_state_82)
    T_LPAREN => Shift(yy_state_84)
    T_INT
    | T_STRING
    | T_IDENT
    | T_EOF
    | T_FALSE
    | T_TRUE
    | T_STRUCT
    | T_ENUM
    | T_FN
    | T_LET
    | T_OPEN
    | T_IF
    | T_MATCH
    | T_BUILTIN
    | T_PLUS
    | T_MINUS
    | T_STAR
    | T_SLASH
    | T_PERCENT
    | T_EQEQ
    | T_BANGEQ
    | T_LT
    | T_LTEQ
    | T_GT
    | T_GTEQ
    | T_AMPAMP
    | T_BARBAR
    | T_BANG
    | T_PIPE
    | T_RPAREN
    | T_LBRACE
    | T_RBRACE
    | T_COMMA
    | T_UNDERSCORE => Reduce(2, NT_expression, yy_action_92)
    _ => Error
  }
}

///|
fn yy_state_82(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_83)
    _ => Error
  }
}

///|
fn yy_state_83(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_expression, yy_action_91)
}

///|
fn yy_state_84(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_BUILTIN => Shift(yy_state_31)
    T_FN => Shift(yy_state_35)
    T_LBRACE => Shift(yy_state_52)
    T_MATCH => Shift(yy_state_54)
    T_IF => Shift(yy_state_55)
    NT_builtin_expression => Shift(yy_state_56)
    NT_function_literal => Shift(yy_state_57)
    NT_match_expression => Shift(yy_state_58)
    NT_if_expression => Shift(yy_state_59)
    NT_block_expression => Shift(yy_state_60)
    T_LPAREN => Shift(yy_state_61)
    NT_qualified_expression => Shift(yy_state_63)
    T_IDENT => Shift(yy_state_64)
    T_FALSE => Shift(yy_state_74)
    T_TRUE => Shift(yy_state_75)
    T_STRING => Shift(yy_state_76)
    T_INT => Shift(yy_state_77)
    NT_primary_expression => Shift(yy_state_78)
    T_BANG => Shift(yy_state_79)
    T_MINUS => Shift(yy_state_80)
    NT_non_empty_argument_list => Shift(yy_state_85)
    NT_argument_list => Shift(yy_state_86)
    NT_expression => Shift(yy_state_88)
    T_RPAREN => Reduce(0, NT_argument_list, yy_action_90)
    _ => Error
  }
}

///|
fn yy_state_85(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_COMMA => Shift(yy_state_73)
    T_RPAREN => Reduce(1, NT_argument_list, yy_action_89)
    _ => Error
  }
}

///|
fn yy_state_86(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_RPAREN => Shift(yy_state_87)
    _ => Error
  }
}

///|
fn yy_state_87(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(4, NT_expression, yy_action_88)
}

///|
fn yy_state_88(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_DOT => Shift(yy_state_82)
    T_LPAREN => Shift(yy_state_84)
    T_PERCENT => Shift(yy_state_89)
    T_SLASH => Shift(yy_state_91)
    T_STAR => Shift(yy_state_93)
    T_MINUS => Shift(yy_state_95)
    T_PLUS => Shift(yy_state_97)
    T_GTEQ => Shift(yy_state_99)
    T_GT => Shift(yy_state_101)
    T_LTEQ => Shift(yy_state_103)
    T_LT => Shift(yy_state_105)
    T_BANGEQ => Shift(yy_state_107)
    T_EQEQ => Shift(yy_state_109)
    T_AMPAMP => Shift(yy_state_111)
    T_BARBAR => Shift(yy_state_113)
    T_PIPE => Shift(yy_state_115)
    T_RPAREN | T_COMMA => Reduce(1, NT_non_empty_argument_list, yy_action_87)
    _ => Error
  }
}

///|
fn yy_state_89(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_BUILTIN => Shift(yy_state_31)
    T_FN => Shift(yy_state_35)
    T_LBRACE => Shift(yy_state_52)
    T_MATCH => Shift(yy_state_54)
    T_IF => Shift(yy_state_55)
    NT_builtin_expression => Shift(yy_state_56)
    NT_function_literal => Shift(yy_state_57)
    NT_match_expression => Shift(yy_state_58)
    NT_if_expression => Shift(yy_state_59)
    NT_block_expression => Shift(yy_state_60)
    T_LPAREN => Shift(yy_state_61)
    NT_qualified_expression => Shift(yy_state_63)
    T_IDENT => Shift(yy_state_64)
    T_FALSE => Shift(yy_state_74)
    T_TRUE => Shift(yy_state_75)
    T_STRING => Shift(yy_state_76)
    T_INT => Shift(yy_state_77)
    NT_primary_expression => Shift(yy_state_78)
    T_BANG => Shift(yy_state_79)
    T_MINUS => Shift(yy_state_80)
    NT_expression => Shift(yy_state_90)
    _ => Error
  }
}

///|
fn yy_state_90(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_DOT => Shift(yy_state_82)
    T_LPAREN => Shift(yy_state_84)
    T_INT
    | T_STRING
    | T_IDENT
    | T_EOF
    | T_FALSE
    | T_TRUE
    | T_STRUCT
    | T_ENUM
    | T_FN
    | T_LET
    | T_OPEN
    | T_IF
    | T_MATCH
    | T_BUILTIN
    | T_PLUS
    | T_MINUS
    | T_STAR
    | T_SLASH
    | T_PERCENT
    | T_EQEQ
    | T_BANGEQ
    | T_LT
    | T_LTEQ
    | T_GT
    | T_GTEQ
    | T_AMPAMP
    | T_BARBAR
    | T_BANG
    | T_PIPE
    | T_RPAREN
    | T_LBRACE
    | T_RBRACE
    | T_COMMA
    | T_UNDERSCORE => Reduce(3, NT_expression, yy_action_86)
    _ => Error
  }
}

///|
fn yy_state_91(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_BUILTIN => Shift(yy_state_31)
    T_FN => Shift(yy_state_35)
    T_LBRACE => Shift(yy_state_52)
    T_MATCH => Shift(yy_state_54)
    T_IF => Shift(yy_state_55)
    NT_builtin_expression => Shift(yy_state_56)
    NT_function_literal => Shift(yy_state_57)
    NT_match_expression => Shift(yy_state_58)
    NT_if_expression => Shift(yy_state_59)
    NT_block_expression => Shift(yy_state_60)
    T_LPAREN => Shift(yy_state_61)
    NT_qualified_expression => Shift(yy_state_63)
    T_IDENT => Shift(yy_state_64)
    T_FALSE => Shift(yy_state_74)
    T_TRUE => Shift(yy_state_75)
    T_STRING => Shift(yy_state_76)
    T_INT => Shift(yy_state_77)
    NT_primary_expression => Shift(yy_state_78)
    T_BANG => Shift(yy_state_79)
    T_MINUS => Shift(yy_state_80)
    NT_expression => Shift(yy_state_92)
    _ => Error
  }
}

///|
fn yy_state_92(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_DOT => Shift(yy_state_82)
    T_LPAREN => Shift(yy_state_84)
    T_INT
    | T_STRING
    | T_IDENT
    | T_EOF
    | T_FALSE
    | T_TRUE
    | T_STRUCT
    | T_ENUM
    | T_FN
    | T_LET
    | T_OPEN
    | T_IF
    | T_MATCH
    | T_BUILTIN
    | T_PLUS
    | T_MINUS
    | T_STAR
    | T_SLASH
    | T_PERCENT
    | T_EQEQ
    | T_BANGEQ
    | T_LT
    | T_LTEQ
    | T_GT
    | T_GTEQ
    | T_AMPAMP
    | T_BARBAR
    | T_BANG
    | T_PIPE
    | T_RPAREN
    | T_LBRACE
    | T_RBRACE
    | T_COMMA
    | T_UNDERSCORE => Reduce(3, NT_expression, yy_action_85)
    _ => Error
  }
}

///|
fn yy_state_93(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_BUILTIN => Shift(yy_state_31)
    T_FN => Shift(yy_state_35)
    T_LBRACE => Shift(yy_state_52)
    T_MATCH => Shift(yy_state_54)
    T_IF => Shift(yy_state_55)
    NT_builtin_expression => Shift(yy_state_56)
    NT_function_literal => Shift(yy_state_57)
    NT_match_expression => Shift(yy_state_58)
    NT_if_expression => Shift(yy_state_59)
    NT_block_expression => Shift(yy_state_60)
    T_LPAREN => Shift(yy_state_61)
    NT_qualified_expression => Shift(yy_state_63)
    T_IDENT => Shift(yy_state_64)
    T_FALSE => Shift(yy_state_74)
    T_TRUE => Shift(yy_state_75)
    T_STRING => Shift(yy_state_76)
    T_INT => Shift(yy_state_77)
    NT_primary_expression => Shift(yy_state_78)
    T_BANG => Shift(yy_state_79)
    T_MINUS => Shift(yy_state_80)
    NT_expression => Shift(yy_state_94)
    _ => Error
  }
}

///|
fn yy_state_94(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_DOT => Shift(yy_state_82)
    T_LPAREN => Shift(yy_state_84)
    T_INT
    | T_STRING
    | T_IDENT
    | T_EOF
    | T_FALSE
    | T_TRUE
    | T_STRUCT
    | T_ENUM
    | T_FN
    | T_LET
    | T_OPEN
    | T_IF
    | T_MATCH
    | T_BUILTIN
    | T_PLUS
    | T_MINUS
    | T_STAR
    | T_SLASH
    | T_PERCENT
    | T_EQEQ
    | T_BANGEQ
    | T_LT
    | T_LTEQ
    | T_GT
    | T_GTEQ
    | T_AMPAMP
    | T_BARBAR
    | T_BANG
    | T_PIPE
    | T_RPAREN
    | T_LBRACE
    | T_RBRACE
    | T_COMMA
    | T_UNDERSCORE => Reduce(3, NT_expression, yy_action_84)
    _ => Error
  }
}

///|
fn yy_state_95(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_BUILTIN => Shift(yy_state_31)
    T_FN => Shift(yy_state_35)
    T_LBRACE => Shift(yy_state_52)
    T_MATCH => Shift(yy_state_54)
    T_IF => Shift(yy_state_55)
    NT_builtin_expression => Shift(yy_state_56)
    NT_function_literal => Shift(yy_state_57)
    NT_match_expression => Shift(yy_state_58)
    NT_if_expression => Shift(yy_state_59)
    NT_block_expression => Shift(yy_state_60)
    T_LPAREN => Shift(yy_state_61)
    NT_qualified_expression => Shift(yy_state_63)
    T_IDENT => Shift(yy_state_64)
    T_FALSE => Shift(yy_state_74)
    T_TRUE => Shift(yy_state_75)
    T_STRING => Shift(yy_state_76)
    T_INT => Shift(yy_state_77)
    NT_primary_expression => Shift(yy_state_78)
    T_BANG => Shift(yy_state_79)
    T_MINUS => Shift(yy_state_80)
    NT_expression => Shift(yy_state_96)
    _ => Error
  }
}

///|
fn yy_state_96(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_DOT => Shift(yy_state_82)
    T_LPAREN => Shift(yy_state_84)
    T_PERCENT => Shift(yy_state_89)
    T_SLASH => Shift(yy_state_91)
    T_STAR => Shift(yy_state_93)
    T_INT
    | T_STRING
    | T_IDENT
    | T_EOF
    | T_FALSE
    | T_TRUE
    | T_STRUCT
    | T_ENUM
    | T_FN
    | T_LET
    | T_OPEN
    | T_IF
    | T_MATCH
    | T_BUILTIN
    | T_PLUS
    | T_MINUS
    | T_EQEQ
    | T_BANGEQ
    | T_LT
    | T_LTEQ
    | T_GT
    | T_GTEQ
    | T_AMPAMP
    | T_BARBAR
    | T_BANG
    | T_PIPE
    | T_RPAREN
    | T_LBRACE
    | T_RBRACE
    | T_COMMA
    | T_UNDERSCORE => Reduce(3, NT_expression, yy_action_83)
    _ => Error
  }
}

///|
fn yy_state_97(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_BUILTIN => Shift(yy_state_31)
    T_FN => Shift(yy_state_35)
    T_LBRACE => Shift(yy_state_52)
    T_MATCH => Shift(yy_state_54)
    T_IF => Shift(yy_state_55)
    NT_builtin_expression => Shift(yy_state_56)
    NT_function_literal => Shift(yy_state_57)
    NT_match_expression => Shift(yy_state_58)
    NT_if_expression => Shift(yy_state_59)
    NT_block_expression => Shift(yy_state_60)
    T_LPAREN => Shift(yy_state_61)
    NT_qualified_expression => Shift(yy_state_63)
    T_IDENT => Shift(yy_state_64)
    T_FALSE => Shift(yy_state_74)
    T_TRUE => Shift(yy_state_75)
    T_STRING => Shift(yy_state_76)
    T_INT => Shift(yy_state_77)
    NT_primary_expression => Shift(yy_state_78)
    T_BANG => Shift(yy_state_79)
    T_MINUS => Shift(yy_state_80)
    NT_expression => Shift(yy_state_98)
    _ => Error
  }
}

///|
fn yy_state_98(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_DOT => Shift(yy_state_82)
    T_LPAREN => Shift(yy_state_84)
    T_PERCENT => Shift(yy_state_89)
    T_SLASH => Shift(yy_state_91)
    T_STAR => Shift(yy_state_93)
    T_INT
    | T_STRING
    | T_IDENT
    | T_EOF
    | T_FALSE
    | T_TRUE
    | T_STRUCT
    | T_ENUM
    | T_FN
    | T_LET
    | T_OPEN
    | T_IF
    | T_MATCH
    | T_BUILTIN
    | T_PLUS
    | T_MINUS
    | T_EQEQ
    | T_BANGEQ
    | T_LT
    | T_LTEQ
    | T_GT
    | T_GTEQ
    | T_AMPAMP
    | T_BARBAR
    | T_BANG
    | T_PIPE
    | T_RPAREN
    | T_LBRACE
    | T_RBRACE
    | T_COMMA
    | T_UNDERSCORE => Reduce(3, NT_expression, yy_action_82)
    _ => Error
  }
}

///|
fn yy_state_99(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_BUILTIN => Shift(yy_state_31)
    T_FN => Shift(yy_state_35)
    T_LBRACE => Shift(yy_state_52)
    T_MATCH => Shift(yy_state_54)
    T_IF => Shift(yy_state_55)
    NT_builtin_expression => Shift(yy_state_56)
    NT_function_literal => Shift(yy_state_57)
    NT_match_expression => Shift(yy_state_58)
    NT_if_expression => Shift(yy_state_59)
    NT_block_expression => Shift(yy_state_60)
    T_LPAREN => Shift(yy_state_61)
    NT_qualified_expression => Shift(yy_state_63)
    T_IDENT => Shift(yy_state_64)
    T_FALSE => Shift(yy_state_74)
    T_TRUE => Shift(yy_state_75)
    T_STRING => Shift(yy_state_76)
    T_INT => Shift(yy_state_77)
    NT_primary_expression => Shift(yy_state_78)
    T_BANG => Shift(yy_state_79)
    T_MINUS => Shift(yy_state_80)
    NT_expression => Shift(yy_state_100)
    _ => Error
  }
}

///|
fn yy_state_100(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_DOT => Shift(yy_state_82)
    T_LPAREN => Shift(yy_state_84)
    T_PERCENT => Shift(yy_state_89)
    T_SLASH => Shift(yy_state_91)
    T_STAR => Shift(yy_state_93)
    T_MINUS => Shift(yy_state_95)
    T_PLUS => Shift(yy_state_97)
    T_INT
    | T_STRING
    | T_IDENT
    | T_EOF
    | T_FALSE
    | T_TRUE
    | T_STRUCT
    | T_ENUM
    | T_FN
    | T_LET
    | T_OPEN
    | T_IF
    | T_MATCH
    | T_BUILTIN
    | T_EQEQ
    | T_BANGEQ
    | T_LT
    | T_LTEQ
    | T_GT
    | T_GTEQ
    | T_AMPAMP
    | T_BARBAR
    | T_BANG
    | T_PIPE
    | T_RPAREN
    | T_LBRACE
    | T_RBRACE
    | T_COMMA
    | T_UNDERSCORE => Reduce(3, NT_expression, yy_action_81)
    _ => Error
  }
}

///|
fn yy_state_101(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_BUILTIN => Shift(yy_state_31)
    T_FN => Shift(yy_state_35)
    T_LBRACE => Shift(yy_state_52)
    T_MATCH => Shift(yy_state_54)
    T_IF => Shift(yy_state_55)
    NT_builtin_expression => Shift(yy_state_56)
    NT_function_literal => Shift(yy_state_57)
    NT_match_expression => Shift(yy_state_58)
    NT_if_expression => Shift(yy_state_59)
    NT_block_expression => Shift(yy_state_60)
    T_LPAREN => Shift(yy_state_61)
    NT_qualified_expression => Shift(yy_state_63)
    T_IDENT => Shift(yy_state_64)
    T_FALSE => Shift(yy_state_74)
    T_TRUE => Shift(yy_state_75)
    T_STRING => Shift(yy_state_76)
    T_INT => Shift(yy_state_77)
    NT_primary_expression => Shift(yy_state_78)
    T_BANG => Shift(yy_state_79)
    T_MINUS => Shift(yy_state_80)
    NT_expression => Shift(yy_state_102)
    _ => Error
  }
}

///|
fn yy_state_102(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_DOT => Shift(yy_state_82)
    T_LPAREN => Shift(yy_state_84)
    T_PERCENT => Shift(yy_state_89)
    T_SLASH => Shift(yy_state_91)
    T_STAR => Shift(yy_state_93)
    T_MINUS => Shift(yy_state_95)
    T_PLUS => Shift(yy_state_97)
    T_INT
    | T_STRING
    | T_IDENT
    | T_EOF
    | T_FALSE
    | T_TRUE
    | T_STRUCT
    | T_ENUM
    | T_FN
    | T_LET
    | T_OPEN
    | T_IF
    | T_MATCH
    | T_BUILTIN
    | T_EQEQ
    | T_BANGEQ
    | T_LT
    | T_LTEQ
    | T_GT
    | T_GTEQ
    | T_AMPAMP
    | T_BARBAR
    | T_BANG
    | T_PIPE
    | T_RPAREN
    | T_LBRACE
    | T_RBRACE
    | T_COMMA
    | T_UNDERSCORE => Reduce(3, NT_expression, yy_action_80)
    _ => Error
  }
}

///|
fn yy_state_103(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_BUILTIN => Shift(yy_state_31)
    T_FN => Shift(yy_state_35)
    T_LBRACE => Shift(yy_state_52)
    T_MATCH => Shift(yy_state_54)
    T_IF => Shift(yy_state_55)
    NT_builtin_expression => Shift(yy_state_56)
    NT_function_literal => Shift(yy_state_57)
    NT_match_expression => Shift(yy_state_58)
    NT_if_expression => Shift(yy_state_59)
    NT_block_expression => Shift(yy_state_60)
    T_LPAREN => Shift(yy_state_61)
    NT_qualified_expression => Shift(yy_state_63)
    T_IDENT => Shift(yy_state_64)
    T_FALSE => Shift(yy_state_74)
    T_TRUE => Shift(yy_state_75)
    T_STRING => Shift(yy_state_76)
    T_INT => Shift(yy_state_77)
    NT_primary_expression => Shift(yy_state_78)
    T_BANG => Shift(yy_state_79)
    T_MINUS => Shift(yy_state_80)
    NT_expression => Shift(yy_state_104)
    _ => Error
  }
}

///|
fn yy_state_104(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_DOT => Shift(yy_state_82)
    T_LPAREN => Shift(yy_state_84)
    T_PERCENT => Shift(yy_state_89)
    T_SLASH => Shift(yy_state_91)
    T_STAR => Shift(yy_state_93)
    T_MINUS => Shift(yy_state_95)
    T_PLUS => Shift(yy_state_97)
    T_INT
    | T_STRING
    | T_IDENT
    | T_EOF
    | T_FALSE
    | T_TRUE
    | T_STRUCT
    | T_ENUM
    | T_FN
    | T_LET
    | T_OPEN
    | T_IF
    | T_MATCH
    | T_BUILTIN
    | T_EQEQ
    | T_BANGEQ
    | T_LT
    | T_LTEQ
    | T_GT
    | T_GTEQ
    | T_AMPAMP
    | T_BARBAR
    | T_BANG
    | T_PIPE
    | T_RPAREN
    | T_LBRACE
    | T_RBRACE
    | T_COMMA
    | T_UNDERSCORE => Reduce(3, NT_expression, yy_action_79)
    _ => Error
  }
}

///|
fn yy_state_105(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_BUILTIN => Shift(yy_state_31)
    T_FN => Shift(yy_state_35)
    T_LBRACE => Shift(yy_state_52)
    T_MATCH => Shift(yy_state_54)
    T_IF => Shift(yy_state_55)
    NT_builtin_expression => Shift(yy_state_56)
    NT_function_literal => Shift(yy_state_57)
    NT_match_expression => Shift(yy_state_58)
    NT_if_expression => Shift(yy_state_59)
    NT_block_expression => Shift(yy_state_60)
    T_LPAREN => Shift(yy_state_61)
    NT_qualified_expression => Shift(yy_state_63)
    T_IDENT => Shift(yy_state_64)
    T_FALSE => Shift(yy_state_74)
    T_TRUE => Shift(yy_state_75)
    T_STRING => Shift(yy_state_76)
    T_INT => Shift(yy_state_77)
    NT_primary_expression => Shift(yy_state_78)
    T_BANG => Shift(yy_state_79)
    T_MINUS => Shift(yy_state_80)
    NT_expression => Shift(yy_state_106)
    _ => Error
  }
}

///|
fn yy_state_106(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_DOT => Shift(yy_state_82)
    T_LPAREN => Shift(yy_state_84)
    T_PERCENT => Shift(yy_state_89)
    T_SLASH => Shift(yy_state_91)
    T_STAR => Shift(yy_state_93)
    T_MINUS => Shift(yy_state_95)
    T_PLUS => Shift(yy_state_97)
    T_INT
    | T_STRING
    | T_IDENT
    | T_EOF
    | T_FALSE
    | T_TRUE
    | T_STRUCT
    | T_ENUM
    | T_FN
    | T_LET
    | T_OPEN
    | T_IF
    | T_MATCH
    | T_BUILTIN
    | T_EQEQ
    | T_BANGEQ
    | T_LT
    | T_LTEQ
    | T_GT
    | T_GTEQ
    | T_AMPAMP
    | T_BARBAR
    | T_BANG
    | T_PIPE
    | T_RPAREN
    | T_LBRACE
    | T_RBRACE
    | T_COMMA
    | T_UNDERSCORE => Reduce(3, NT_expression, yy_action_78)
    _ => Error
  }
}

///|
fn yy_state_107(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_BUILTIN => Shift(yy_state_31)
    T_FN => Shift(yy_state_35)
    T_LBRACE => Shift(yy_state_52)
    T_MATCH => Shift(yy_state_54)
    T_IF => Shift(yy_state_55)
    NT_builtin_expression => Shift(yy_state_56)
    NT_function_literal => Shift(yy_state_57)
    NT_match_expression => Shift(yy_state_58)
    NT_if_expression => Shift(yy_state_59)
    NT_block_expression => Shift(yy_state_60)
    T_LPAREN => Shift(yy_state_61)
    NT_qualified_expression => Shift(yy_state_63)
    T_IDENT => Shift(yy_state_64)
    T_FALSE => Shift(yy_state_74)
    T_TRUE => Shift(yy_state_75)
    T_STRING => Shift(yy_state_76)
    T_INT => Shift(yy_state_77)
    NT_primary_expression => Shift(yy_state_78)
    T_BANG => Shift(yy_state_79)
    T_MINUS => Shift(yy_state_80)
    NT_expression => Shift(yy_state_108)
    _ => Error
  }
}

///|
fn yy_state_108(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_DOT => Shift(yy_state_82)
    T_LPAREN => Shift(yy_state_84)
    T_PERCENT => Shift(yy_state_89)
    T_SLASH => Shift(yy_state_91)
    T_STAR => Shift(yy_state_93)
    T_MINUS => Shift(yy_state_95)
    T_PLUS => Shift(yy_state_97)
    T_GTEQ => Shift(yy_state_99)
    T_GT => Shift(yy_state_101)
    T_LTEQ => Shift(yy_state_103)
    T_LT => Shift(yy_state_105)
    T_INT
    | T_STRING
    | T_IDENT
    | T_EOF
    | T_FALSE
    | T_TRUE
    | T_STRUCT
    | T_ENUM
    | T_FN
    | T_LET
    | T_OPEN
    | T_IF
    | T_MATCH
    | T_BUILTIN
    | T_EQEQ
    | T_BANGEQ
    | T_AMPAMP
    | T_BARBAR
    | T_BANG
    | T_PIPE
    | T_RPAREN
    | T_LBRACE
    | T_RBRACE
    | T_COMMA
    | T_UNDERSCORE => Reduce(3, NT_expression, yy_action_77)
    _ => Error
  }
}

///|
fn yy_state_109(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_BUILTIN => Shift(yy_state_31)
    T_FN => Shift(yy_state_35)
    T_LBRACE => Shift(yy_state_52)
    T_MATCH => Shift(yy_state_54)
    T_IF => Shift(yy_state_55)
    NT_builtin_expression => Shift(yy_state_56)
    NT_function_literal => Shift(yy_state_57)
    NT_match_expression => Shift(yy_state_58)
    NT_if_expression => Shift(yy_state_59)
    NT_block_expression => Shift(yy_state_60)
    T_LPAREN => Shift(yy_state_61)
    NT_qualified_expression => Shift(yy_state_63)
    T_IDENT => Shift(yy_state_64)
    T_FALSE => Shift(yy_state_74)
    T_TRUE => Shift(yy_state_75)
    T_STRING => Shift(yy_state_76)
    T_INT => Shift(yy_state_77)
    NT_primary_expression => Shift(yy_state_78)
    T_BANG => Shift(yy_state_79)
    T_MINUS => Shift(yy_state_80)
    NT_expression => Shift(yy_state_110)
    _ => Error
  }
}

///|
fn yy_state_110(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_DOT => Shift(yy_state_82)
    T_LPAREN => Shift(yy_state_84)
    T_PERCENT => Shift(yy_state_89)
    T_SLASH => Shift(yy_state_91)
    T_STAR => Shift(yy_state_93)
    T_MINUS => Shift(yy_state_95)
    T_PLUS => Shift(yy_state_97)
    T_GTEQ => Shift(yy_state_99)
    T_GT => Shift(yy_state_101)
    T_LTEQ => Shift(yy_state_103)
    T_LT => Shift(yy_state_105)
    T_INT
    | T_STRING
    | T_IDENT
    | T_EOF
    | T_FALSE
    | T_TRUE
    | T_STRUCT
    | T_ENUM
    | T_FN
    | T_LET
    | T_OPEN
    | T_IF
    | T_MATCH
    | T_BUILTIN
    | T_EQEQ
    | T_BANGEQ
    | T_AMPAMP
    | T_BARBAR
    | T_BANG
    | T_PIPE
    | T_RPAREN
    | T_LBRACE
    | T_RBRACE
    | T_COMMA
    | T_UNDERSCORE => Reduce(3, NT_expression, yy_action_76)
    _ => Error
  }
}

///|
fn yy_state_111(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_BUILTIN => Shift(yy_state_31)
    T_FN => Shift(yy_state_35)
    T_LBRACE => Shift(yy_state_52)
    T_MATCH => Shift(yy_state_54)
    T_IF => Shift(yy_state_55)
    NT_builtin_expression => Shift(yy_state_56)
    NT_function_literal => Shift(yy_state_57)
    NT_match_expression => Shift(yy_state_58)
    NT_if_expression => Shift(yy_state_59)
    NT_block_expression => Shift(yy_state_60)
    T_LPAREN => Shift(yy_state_61)
    NT_qualified_expression => Shift(yy_state_63)
    T_IDENT => Shift(yy_state_64)
    T_FALSE => Shift(yy_state_74)
    T_TRUE => Shift(yy_state_75)
    T_STRING => Shift(yy_state_76)
    T_INT => Shift(yy_state_77)
    NT_primary_expression => Shift(yy_state_78)
    T_BANG => Shift(yy_state_79)
    T_MINUS => Shift(yy_state_80)
    NT_expression => Shift(yy_state_112)
    _ => Error
  }
}

///|
fn yy_state_112(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_DOT => Shift(yy_state_82)
    T_LPAREN => Shift(yy_state_84)
    T_PERCENT => Shift(yy_state_89)
    T_SLASH => Shift(yy_state_91)
    T_STAR => Shift(yy_state_93)
    T_MINUS => Shift(yy_state_95)
    T_PLUS => Shift(yy_state_97)
    T_GTEQ => Shift(yy_state_99)
    T_GT => Shift(yy_state_101)
    T_LTEQ => Shift(yy_state_103)
    T_LT => Shift(yy_state_105)
    T_BANGEQ => Shift(yy_state_107)
    T_EQEQ => Shift(yy_state_109)
    T_INT
    | T_STRING
    | T_IDENT
    | T_EOF
    | T_FALSE
    | T_TRUE
    | T_STRUCT
    | T_ENUM
    | T_FN
    | T_LET
    | T_OPEN
    | T_IF
    | T_MATCH
    | T_BUILTIN
    | T_AMPAMP
    | T_BARBAR
    | T_BANG
    | T_PIPE
    | T_RPAREN
    | T_LBRACE
    | T_RBRACE
    | T_COMMA
    | T_UNDERSCORE => Reduce(3, NT_expression, yy_action_75)
    _ => Error
  }
}

///|
fn yy_state_113(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_BUILTIN => Shift(yy_state_31)
    T_FN => Shift(yy_state_35)
    T_LBRACE => Shift(yy_state_52)
    T_MATCH => Shift(yy_state_54)
    T_IF => Shift(yy_state_55)
    NT_builtin_expression => Shift(yy_state_56)
    NT_function_literal => Shift(yy_state_57)
    NT_match_expression => Shift(yy_state_58)
    NT_if_expression => Shift(yy_state_59)
    NT_block_expression => Shift(yy_state_60)
    T_LPAREN => Shift(yy_state_61)
    NT_qualified_expression => Shift(yy_state_63)
    T_IDENT => Shift(yy_state_64)
    T_FALSE => Shift(yy_state_74)
    T_TRUE => Shift(yy_state_75)
    T_STRING => Shift(yy_state_76)
    T_INT => Shift(yy_state_77)
    NT_primary_expression => Shift(yy_state_78)
    T_BANG => Shift(yy_state_79)
    T_MINUS => Shift(yy_state_80)
    NT_expression => Shift(yy_state_114)
    _ => Error
  }
}

///|
fn yy_state_114(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_DOT => Shift(yy_state_82)
    T_LPAREN => Shift(yy_state_84)
    T_PERCENT => Shift(yy_state_89)
    T_SLASH => Shift(yy_state_91)
    T_STAR => Shift(yy_state_93)
    T_MINUS => Shift(yy_state_95)
    T_PLUS => Shift(yy_state_97)
    T_GTEQ => Shift(yy_state_99)
    T_GT => Shift(yy_state_101)
    T_LTEQ => Shift(yy_state_103)
    T_LT => Shift(yy_state_105)
    T_BANGEQ => Shift(yy_state_107)
    T_EQEQ => Shift(yy_state_109)
    T_AMPAMP => Shift(yy_state_111)
    T_INT
    | T_STRING
    | T_IDENT
    | T_EOF
    | T_FALSE
    | T_TRUE
    | T_STRUCT
    | T_ENUM
    | T_FN
    | T_LET
    | T_OPEN
    | T_IF
    | T_MATCH
    | T_BUILTIN
    | T_BARBAR
    | T_BANG
    | T_PIPE
    | T_RPAREN
    | T_LBRACE
    | T_RBRACE
    | T_COMMA
    | T_UNDERSCORE => Reduce(3, NT_expression, yy_action_74)
    _ => Error
  }
}

///|
fn yy_state_115(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_BUILTIN => Shift(yy_state_31)
    T_FN => Shift(yy_state_35)
    T_LBRACE => Shift(yy_state_52)
    T_MATCH => Shift(yy_state_54)
    T_IF => Shift(yy_state_55)
    NT_builtin_expression => Shift(yy_state_56)
    NT_function_literal => Shift(yy_state_57)
    NT_match_expression => Shift(yy_state_58)
    NT_if_expression => Shift(yy_state_59)
    NT_block_expression => Shift(yy_state_60)
    T_LPAREN => Shift(yy_state_61)
    NT_qualified_expression => Shift(yy_state_63)
    T_IDENT => Shift(yy_state_64)
    T_FALSE => Shift(yy_state_74)
    T_TRUE => Shift(yy_state_75)
    T_STRING => Shift(yy_state_76)
    T_INT => Shift(yy_state_77)
    NT_primary_expression => Shift(yy_state_78)
    T_BANG => Shift(yy_state_79)
    T_MINUS => Shift(yy_state_80)
    NT_expression => Shift(yy_state_116)
    _ => Error
  }
}

///|
fn yy_state_116(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_DOT => Shift(yy_state_82)
    T_LPAREN => Shift(yy_state_84)
    T_PERCENT => Shift(yy_state_89)
    T_SLASH => Shift(yy_state_91)
    T_STAR => Shift(yy_state_93)
    T_MINUS => Shift(yy_state_95)
    T_PLUS => Shift(yy_state_97)
    T_GTEQ => Shift(yy_state_99)
    T_GT => Shift(yy_state_101)
    T_LTEQ => Shift(yy_state_103)
    T_LT => Shift(yy_state_105)
    T_BANGEQ => Shift(yy_state_107)
    T_EQEQ => Shift(yy_state_109)
    T_AMPAMP => Shift(yy_state_111)
    T_BARBAR => Shift(yy_state_113)
    T_INT
    | T_STRING
    | T_IDENT
    | T_EOF
    | T_FALSE
    | T_TRUE
    | T_STRUCT
    | T_ENUM
    | T_FN
    | T_LET
    | T_OPEN
    | T_IF
    | T_MATCH
    | T_BUILTIN
    | T_BANG
    | T_PIPE
    | T_RPAREN
    | T_LBRACE
    | T_RBRACE
    | T_COMMA
    | T_UNDERSCORE => Reduce(3, NT_expression, yy_action_73)
    _ => Error
  }
}

///|
fn yy_state_117(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_DOT => Shift(yy_state_82)
    T_LPAREN => Shift(yy_state_84)
    T_INT
    | T_STRING
    | T_IDENT
    | T_EOF
    | T_FALSE
    | T_TRUE
    | T_STRUCT
    | T_ENUM
    | T_FN
    | T_LET
    | T_OPEN
    | T_IF
    | T_MATCH
    | T_BUILTIN
    | T_PLUS
    | T_MINUS
    | T_STAR
    | T_SLASH
    | T_PERCENT
    | T_EQEQ
    | T_BANGEQ
    | T_LT
    | T_LTEQ
    | T_GT
    | T_GTEQ
    | T_AMPAMP
    | T_BARBAR
    | T_BANG
    | T_PIPE
    | T_RPAREN
    | T_LBRACE
    | T_RBRACE
    | T_COMMA
    | T_UNDERSCORE => Reduce(2, NT_expression, yy_action_72)
    _ => Error
  }
}

///|
fn yy_state_118(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_DOT => Shift(yy_state_82)
    T_LPAREN => Shift(yy_state_84)
    T_PERCENT => Shift(yy_state_89)
    T_SLASH => Shift(yy_state_91)
    T_STAR => Shift(yy_state_93)
    T_MINUS => Shift(yy_state_95)
    T_PLUS => Shift(yy_state_97)
    T_GTEQ => Shift(yy_state_99)
    T_GT => Shift(yy_state_101)
    T_LTEQ => Shift(yy_state_103)
    T_LT => Shift(yy_state_105)
    T_BANGEQ => Shift(yy_state_107)
    T_EQEQ => Shift(yy_state_109)
    T_AMPAMP => Shift(yy_state_111)
    T_BARBAR => Shift(yy_state_113)
    T_PIPE => Shift(yy_state_115)
    T_RPAREN | T_COMMA => Reduce(3, NT_non_empty_argument_list, yy_action_71)
    _ => Error
  }
}

///|
fn yy_state_119(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_variant_arguments, yy_action_70)
}

///|
fn yy_state_120(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(5, NT_qualified_expression, yy_action_69)
}

///|
fn yy_state_121(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_122)
    NT_struct_literal_field => Shift(yy_state_125)
    NT_non_empty_struct_literal_fields => Shift(yy_state_126)
    NT_struct_literal_fields => Shift(yy_state_129)
    T_RBRACE => Reduce(0, NT_struct_literal_fields, yy_action_68)
    _ => Error
  }
}

///|
fn yy_state_122(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_COLON => Shift(yy_state_123)
    T_RBRACE | T_COMMA => Reduce(1, NT_struct_literal_field, yy_action_67)
    _ => Error
  }
}

///|
fn yy_state_123(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_BUILTIN => Shift(yy_state_31)
    T_FN => Shift(yy_state_35)
    T_LBRACE => Shift(yy_state_52)
    T_MATCH => Shift(yy_state_54)
    T_IF => Shift(yy_state_55)
    NT_builtin_expression => Shift(yy_state_56)
    NT_function_literal => Shift(yy_state_57)
    NT_match_expression => Shift(yy_state_58)
    NT_if_expression => Shift(yy_state_59)
    NT_block_expression => Shift(yy_state_60)
    T_LPAREN => Shift(yy_state_61)
    NT_qualified_expression => Shift(yy_state_63)
    T_IDENT => Shift(yy_state_64)
    T_FALSE => Shift(yy_state_74)
    T_TRUE => Shift(yy_state_75)
    T_STRING => Shift(yy_state_76)
    T_INT => Shift(yy_state_77)
    NT_primary_expression => Shift(yy_state_78)
    T_BANG => Shift(yy_state_79)
    T_MINUS => Shift(yy_state_80)
    NT_expression => Shift(yy_state_124)
    _ => Error
  }
}

///|
fn yy_state_124(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_DOT => Shift(yy_state_82)
    T_LPAREN => Shift(yy_state_84)
    T_PERCENT => Shift(yy_state_89)
    T_SLASH => Shift(yy_state_91)
    T_STAR => Shift(yy_state_93)
    T_MINUS => Shift(yy_state_95)
    T_PLUS => Shift(yy_state_97)
    T_GTEQ => Shift(yy_state_99)
    T_GT => Shift(yy_state_101)
    T_LTEQ => Shift(yy_state_103)
    T_LT => Shift(yy_state_105)
    T_BANGEQ => Shift(yy_state_107)
    T_EQEQ => Shift(yy_state_109)
    T_AMPAMP => Shift(yy_state_111)
    T_BARBAR => Shift(yy_state_113)
    T_PIPE => Shift(yy_state_115)
    T_RBRACE | T_COMMA => Reduce(3, NT_struct_literal_field, yy_action_66)
    _ => Error
  }
}

///|
fn yy_state_125(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_non_empty_struct_literal_fields, yy_action_65)
}

///|
fn yy_state_126(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_COMMA => Shift(yy_state_127)
    T_RBRACE => Reduce(1, NT_struct_literal_fields, yy_action_64)
    _ => Error
  }
}

///|
fn yy_state_127(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_122)
    NT_struct_literal_field => Shift(yy_state_128)
    T_RBRACE | T_COMMA =>
      Reduce(2, NT_non_empty_struct_literal_fields, yy_action_63)
    _ => Error
  }
}

///|
fn yy_state_128(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_non_empty_struct_literal_fields, yy_action_62)
}

///|
fn yy_state_129(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_RBRACE => Shift(yy_state_130)
    _ => Error
  }
}

///|
fn yy_state_130(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(6, NT_qualified_expression, yy_action_61)
}

///|
fn yy_state_131(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_DOT => Shift(yy_state_82)
    T_LPAREN => Shift(yy_state_84)
    T_PERCENT => Shift(yy_state_89)
    T_SLASH => Shift(yy_state_91)
    T_STAR => Shift(yy_state_93)
    T_MINUS => Shift(yy_state_95)
    T_PLUS => Shift(yy_state_97)
    T_GTEQ => Shift(yy_state_99)
    T_GT => Shift(yy_state_101)
    T_LTEQ => Shift(yy_state_103)
    T_LT => Shift(yy_state_105)
    T_BANGEQ => Shift(yy_state_107)
    T_EQEQ => Shift(yy_state_109)
    T_AMPAMP => Shift(yy_state_111)
    T_BARBAR => Shift(yy_state_113)
    T_PIPE => Shift(yy_state_115)
    T_RPAREN => Shift(yy_state_132)
    _ => Error
  }
}

///|
fn yy_state_132(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_primary_expression, yy_action_60)
}

///|
fn yy_state_133(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LBRACE => Shift(yy_state_52)
    T_DOT => Shift(yy_state_82)
    T_LPAREN => Shift(yy_state_84)
    T_PERCENT => Shift(yy_state_89)
    T_SLASH => Shift(yy_state_91)
    T_STAR => Shift(yy_state_93)
    T_MINUS => Shift(yy_state_95)
    T_PLUS => Shift(yy_state_97)
    T_GTEQ => Shift(yy_state_99)
    T_GT => Shift(yy_state_101)
    T_LTEQ => Shift(yy_state_103)
    T_LT => Shift(yy_state_105)
    T_BANGEQ => Shift(yy_state_107)
    T_EQEQ => Shift(yy_state_109)
    T_AMPAMP => Shift(yy_state_111)
    T_BARBAR => Shift(yy_state_113)
    T_PIPE => Shift(yy_state_115)
    NT_block_expression => Shift(yy_state_134)
    _ => Error
  }
}

///|
fn yy_state_134(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_ELSE => Shift(yy_state_135)
    _ => Error
  }
}

///|
fn yy_state_135(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LBRACE => Shift(yy_state_52)
    NT_block_expression => Shift(yy_state_136)
    _ => Error
  }
}

///|
fn yy_state_136(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(5, NT_if_expression, yy_action_59)
}

///|
fn yy_state_137(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_DOT => Shift(yy_state_82)
    T_LPAREN => Shift(yy_state_84)
    T_PERCENT => Shift(yy_state_89)
    T_SLASH => Shift(yy_state_91)
    T_STAR => Shift(yy_state_93)
    T_MINUS => Shift(yy_state_95)
    T_PLUS => Shift(yy_state_97)
    T_GTEQ => Shift(yy_state_99)
    T_GT => Shift(yy_state_101)
    T_LTEQ => Shift(yy_state_103)
    T_LT => Shift(yy_state_105)
    T_BANGEQ => Shift(yy_state_107)
    T_EQEQ => Shift(yy_state_109)
    T_AMPAMP => Shift(yy_state_111)
    T_BARBAR => Shift(yy_state_113)
    T_PIPE => Shift(yy_state_115)
    T_LBRACE => Shift(yy_state_138)
    _ => Error
  }
}

///|
fn yy_state_138(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    NT_match_arms => Shift(yy_state_139)
    T_INT | T_STRING | T_IDENT | T_FALSE | T_TRUE | T_RBRACE | T_UNDERSCORE =>
      Reduce(0, NT_match_arms, yy_action_58)
    _ => Error
  }
}

///|
fn yy_state_139(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_140)
    T_FALSE => Shift(yy_state_148)
    T_TRUE => Shift(yy_state_149)
    T_STRING => Shift(yy_state_150)
    T_INT => Shift(yy_state_151)
    T_UNDERSCORE => Shift(yy_state_152)
    NT_pattern => Shift(yy_state_166)
    NT_match_arm => Shift(yy_state_169)
    T_RBRACE => Shift(yy_state_170)
    _ => Error
  }
}

///|
fn yy_state_140(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_COLONCOLON => Shift(yy_state_141)
    T_RPAREN | T_RBRACE | T_COMMA | T_FAT_ARROW =>
      Reduce(1, NT_pattern, yy_action_57)
    _ => Error
  }
}

///|
fn yy_state_141(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_142)
    T_LBRACE => Shift(yy_state_156)
    _ => Error
  }
}

///|
fn yy_state_142(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LPAREN => Shift(yy_state_143)
    NT_pattern_arguments => Shift(yy_state_155)
    T_RPAREN | T_RBRACE | T_COMMA | T_FAT_ARROW =>
      Reduce(0, NT_pattern_arguments, yy_action_56)
    _ => Error
  }
}

///|
fn yy_state_143(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_140)
    NT_pattern => Shift(yy_state_144)
    NT_non_empty_pattern_list => Shift(yy_state_145)
    T_FALSE => Shift(yy_state_148)
    T_TRUE => Shift(yy_state_149)
    T_STRING => Shift(yy_state_150)
    T_INT => Shift(yy_state_151)
    T_UNDERSCORE => Shift(yy_state_152)
    NT_pattern_list => Shift(yy_state_153)
    T_RPAREN => Reduce(0, NT_pattern_list, yy_action_55)
    _ => Error
  }
}

///|
fn yy_state_144(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_non_empty_pattern_list, yy_action_54)
}

///|
fn yy_state_145(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_COMMA => Shift(yy_state_146)
    T_RPAREN => Reduce(1, NT_pattern_list, yy_action_53)
    _ => Error
  }
}

///|
fn yy_state_146(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_140)
    NT_pattern => Shift(yy_state_147)
    T_FALSE => Shift(yy_state_148)
    T_TRUE => Shift(yy_state_149)
    T_STRING => Shift(yy_state_150)
    T_INT => Shift(yy_state_151)
    T_UNDERSCORE => Shift(yy_state_152)
    T_RPAREN | T_COMMA => Reduce(2, NT_non_empty_pattern_list, yy_action_52)
    _ => Error
  }
}

///|
fn yy_state_147(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_non_empty_pattern_list, yy_action_51)
}

///|
fn yy_state_148(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_pattern, yy_action_50)
}

///|
fn yy_state_149(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_pattern, yy_action_49)
}

///|
fn yy_state_150(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_pattern, yy_action_48)
}

///|
fn yy_state_151(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_pattern, yy_action_47)
}

///|
fn yy_state_152(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_pattern, yy_action_46)
}

///|
fn yy_state_153(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_RPAREN => Shift(yy_state_154)
    _ => Error
  }
}

///|
fn yy_state_154(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_pattern_arguments, yy_action_45)
}

///|
fn yy_state_155(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(4, NT_pattern, yy_action_44)
}

///|
fn yy_state_156(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_157)
    NT_struct_pattern_field => Shift(yy_state_160)
    NT_non_empty_struct_pattern_fields => Shift(yy_state_161)
    NT_struct_pattern_fields => Shift(yy_state_164)
    T_RBRACE => Reduce(0, NT_struct_pattern_fields, yy_action_43)
    _ => Error
  }
}

///|
fn yy_state_157(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_COLON => Shift(yy_state_158)
    T_RBRACE | T_COMMA => Reduce(1, NT_struct_pattern_field, yy_action_42)
    _ => Error
  }
}

///|
fn yy_state_158(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_140)
    T_FALSE => Shift(yy_state_148)
    T_TRUE => Shift(yy_state_149)
    T_STRING => Shift(yy_state_150)
    T_INT => Shift(yy_state_151)
    T_UNDERSCORE => Shift(yy_state_152)
    NT_pattern => Shift(yy_state_159)
    _ => Error
  }
}

///|
fn yy_state_159(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_struct_pattern_field, yy_action_41)
}

///|
fn yy_state_160(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_non_empty_struct_pattern_fields, yy_action_40)
}

///|
fn yy_state_161(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_COMMA => Shift(yy_state_162)
    T_RBRACE => Reduce(1, NT_struct_pattern_fields, yy_action_39)
    _ => Error
  }
}

///|
fn yy_state_162(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_157)
    NT_struct_pattern_field => Shift(yy_state_163)
    T_RBRACE | T_COMMA =>
      Reduce(2, NT_non_empty_struct_pattern_fields, yy_action_38)
    _ => Error
  }
}

///|
fn yy_state_163(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_non_empty_struct_pattern_fields, yy_action_37)
}

///|
fn yy_state_164(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_RBRACE => Shift(yy_state_165)
    _ => Error
  }
}

///|
fn yy_state_165(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(5, NT_pattern, yy_action_36)
}

///|
fn yy_state_166(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_FAT_ARROW => Shift(yy_state_167)
    _ => Error
  }
}

///|
fn yy_state_167(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_BUILTIN => Shift(yy_state_31)
    T_FN => Shift(yy_state_35)
    T_LBRACE => Shift(yy_state_52)
    T_MATCH => Shift(yy_state_54)
    T_IF => Shift(yy_state_55)
    NT_builtin_expression => Shift(yy_state_56)
    NT_function_literal => Shift(yy_state_57)
    NT_match_expression => Shift(yy_state_58)
    NT_if_expression => Shift(yy_state_59)
    NT_block_expression => Shift(yy_state_60)
    T_LPAREN => Shift(yy_state_61)
    NT_qualified_expression => Shift(yy_state_63)
    T_IDENT => Shift(yy_state_64)
    T_FALSE => Shift(yy_state_74)
    T_TRUE => Shift(yy_state_75)
    T_STRING => Shift(yy_state_76)
    T_INT => Shift(yy_state_77)
    NT_primary_expression => Shift(yy_state_78)
    T_BANG => Shift(yy_state_79)
    T_MINUS => Shift(yy_state_80)
    NT_expression => Shift(yy_state_168)
    _ => Error
  }
}

///|
fn yy_state_168(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_DOT => Shift(yy_state_82)
    T_LPAREN => Shift(yy_state_84)
    T_PERCENT => Shift(yy_state_89)
    T_SLASH => Shift(yy_state_91)
    T_STAR => Shift(yy_state_93)
    T_MINUS => Shift(yy_state_95)
    T_PLUS => Shift(yy_state_97)
    T_GTEQ => Shift(yy_state_99)
    T_GT => Shift(yy_state_101)
    T_LTEQ => Shift(yy_state_103)
    T_LT => Shift(yy_state_105)
    T_BANGEQ => Shift(yy_state_107)
    T_EQEQ => Shift(yy_state_109)
    T_AMPAMP => Shift(yy_state_111)
    T_BARBAR => Shift(yy_state_113)
    T_PIPE => Shift(yy_state_115)
    T_INT | T_STRING | T_IDENT | T_FALSE | T_TRUE | T_RBRACE | T_UNDERSCORE =>
      Reduce(3, NT_match_arm, yy_action_35)
    _ => Error
  }
}

///|
fn yy_state_169(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(2, NT_match_arms, yy_action_34)
}

///|
fn yy_state_170(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(5, NT_match_expression, yy_action_33)
}

///|
fn yy_state_171(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_local_item, yy_action_32)
}

///|
fn yy_state_172(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_local_item, yy_action_31)
}

///|
fn yy_state_173(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_local_item, yy_action_30)
}

///|
fn yy_state_174(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(2, NT_local_items, yy_action_29)
}

///|
fn yy_state_175(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_DOT => Shift(yy_state_82)
    T_LPAREN => Shift(yy_state_84)
    T_PERCENT => Shift(yy_state_89)
    T_SLASH => Shift(yy_state_91)
    T_STAR => Shift(yy_state_93)
    T_MINUS => Shift(yy_state_95)
    T_PLUS => Shift(yy_state_97)
    T_GTEQ => Shift(yy_state_99)
    T_GT => Shift(yy_state_101)
    T_LTEQ => Shift(yy_state_103)
    T_LT => Shift(yy_state_105)
    T_BANGEQ => Shift(yy_state_107)
    T_EQEQ => Shift(yy_state_109)
    T_AMPAMP => Shift(yy_state_111)
    T_BARBAR => Shift(yy_state_113)
    T_PIPE => Shift(yy_state_115)
    T_RBRACE => Shift(yy_state_176)
    _ => Error
  }
}

///|
fn yy_state_176(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(4, NT_block_expression, yy_action_28)
}

///|
fn yy_state_177(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_178)
    _ => Error
  }
}

///|
fn yy_state_178(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_COLON => Shift(yy_state_40)
    NT_local_type_annotation => Shift(yy_state_179)
    T_EQUAL => Reduce(0, NT_local_type_annotation, yy_action_119)
    _ => Error
  }
}

///|
fn yy_state_179(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_EQUAL => Shift(yy_state_180)
    _ => Error
  }
}

///|
fn yy_state_180(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_BUILTIN => Shift(yy_state_31)
    T_FN => Shift(yy_state_35)
    T_LBRACE => Shift(yy_state_52)
    T_MATCH => Shift(yy_state_54)
    T_IF => Shift(yy_state_55)
    NT_builtin_expression => Shift(yy_state_56)
    NT_function_literal => Shift(yy_state_57)
    NT_match_expression => Shift(yy_state_58)
    NT_if_expression => Shift(yy_state_59)
    NT_block_expression => Shift(yy_state_60)
    T_LPAREN => Shift(yy_state_61)
    NT_qualified_expression => Shift(yy_state_63)
    T_IDENT => Shift(yy_state_64)
    T_FALSE => Shift(yy_state_74)
    T_TRUE => Shift(yy_state_75)
    T_STRING => Shift(yy_state_76)
    T_INT => Shift(yy_state_77)
    NT_primary_expression => Shift(yy_state_78)
    T_BANG => Shift(yy_state_79)
    T_MINUS => Shift(yy_state_80)
    NT_expression => Shift(yy_state_181)
    _ => Error
  }
}

///|
fn yy_state_181(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_DOT => Shift(yy_state_82)
    T_LPAREN => Shift(yy_state_84)
    T_PERCENT => Shift(yy_state_89)
    T_SLASH => Shift(yy_state_91)
    T_STAR => Shift(yy_state_93)
    T_MINUS => Shift(yy_state_95)
    T_PLUS => Shift(yy_state_97)
    T_GTEQ => Shift(yy_state_99)
    T_GT => Shift(yy_state_101)
    T_LTEQ => Shift(yy_state_103)
    T_LT => Shift(yy_state_105)
    T_BANGEQ => Shift(yy_state_107)
    T_EQEQ => Shift(yy_state_109)
    T_AMPAMP => Shift(yy_state_111)
    T_BARBAR => Shift(yy_state_113)
    T_PIPE => Shift(yy_state_115)
    T_INT
    | T_STRING
    | T_IDENT
    | T_FALSE
    | T_TRUE
    | T_FN
    | T_LET
    | T_OPEN
    | T_IF
    | T_MATCH
    | T_BUILTIN
    | T_BANG
    | T_LBRACE => Reduce(5, NT_local_let_declaration, yy_action_27)
    _ => Error
  }
}

///|
fn yy_state_182(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LBRACKET => Shift(yy_state_183)
    NT_type_parameters => Shift(yy_state_186)
    T_IDENT | T_LPAREN => Reduce(0, NT_type_parameters, yy_action_121)
    _ => Error
  }
}

///|
fn yy_state_183(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_22)
    NT_non_empty_ident_list => Shift(yy_state_184)
    _ => Error
  }
}

///|
fn yy_state_184(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_COMMA => Shift(yy_state_20)
    T_RBRACKET => Shift(yy_state_185)
    _ => Error
  }
}

///|
fn yy_state_185(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_type_parameters, yy_action_26)
}

///|
fn yy_state_186(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LPAREN => Shift(yy_state_37)
    T_IDENT => Shift(yy_state_187)
    _ => Error
  }
}

///|
fn yy_state_187(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LPAREN => Shift(yy_state_188)
    NT_parameters => Shift(yy_state_198)
    _ => Error
  }
}

///|
fn yy_state_188(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_189)
    NT_parameter => Shift(yy_state_192)
    NT_non_empty_parameter_list => Shift(yy_state_193)
    T_RPAREN => Shift(yy_state_197)
    _ => Error
  }
}

///|
fn yy_state_189(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_COLON => Shift(yy_state_190)
    _ => Error
  }
}

///|
fn yy_state_190(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LPAREN => Shift(yy_state_7)
    T_IDENT => Shift(yy_state_12)
    T_LBRACKET => Shift(yy_state_16)
    NT_function_type => Shift(yy_state_23)
    NT_named_type => Shift(yy_state_24)
    NT_type => Shift(yy_state_191)
    _ => Error
  }
}

///|
fn yy_state_191(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_parameter, yy_action_25)
}

///|
fn yy_state_192(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_non_empty_parameter_list, yy_action_24)
}

///|
fn yy_state_193(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_COMMA => Shift(yy_state_194)
    T_RPAREN => Shift(yy_state_196)
    _ => Error
  }
}

///|
fn yy_state_194(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_189)
    NT_parameter => Shift(yy_state_195)
    _ => Error
  }
}

///|
fn yy_state_195(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_non_empty_parameter_list, yy_action_23)
}

///|
fn yy_state_196(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_parameters, yy_action_22)
}

///|
fn yy_state_197(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(2, NT_parameters, yy_action_21)
}

///|
fn yy_state_198(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_THIN_ARROW => Shift(yy_state_199)
    _ => Error
  }
}

///|
fn yy_state_199(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LPAREN => Shift(yy_state_7)
    T_IDENT => Shift(yy_state_12)
    T_LBRACKET => Shift(yy_state_16)
    NT_function_type => Shift(yy_state_23)
    NT_named_type => Shift(yy_state_24)
    NT_type => Shift(yy_state_200)
    _ => Error
  }
}

///|
fn yy_state_200(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LBRACE => Shift(yy_state_52)
    NT_block_expression => Shift(yy_state_201)
    _ => Error
  }
}

///|
fn yy_state_201(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(7, NT_function_declaration, yy_action_20)
}

///|
fn yy_state_202(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_DOT => Shift(yy_state_82)
    T_LPAREN => Shift(yy_state_84)
    T_PERCENT => Shift(yy_state_89)
    T_SLASH => Shift(yy_state_91)
    T_STAR => Shift(yy_state_93)
    T_MINUS => Shift(yy_state_95)
    T_PLUS => Shift(yy_state_97)
    T_GTEQ => Shift(yy_state_99)
    T_GT => Shift(yy_state_101)
    T_LTEQ => Shift(yy_state_103)
    T_LT => Shift(yy_state_105)
    T_BANGEQ => Shift(yy_state_107)
    T_EQEQ => Shift(yy_state_109)
    T_AMPAMP => Shift(yy_state_111)
    T_BARBAR => Shift(yy_state_113)
    T_PIPE => Shift(yy_state_115)
    T_EOF | T_STRUCT | T_ENUM | T_FN | T_LET | T_OPEN =>
      Reduce(5, NT_top_level_let_declaration, yy_action_19)
    _ => Error
  }
}

///|
fn yy_state_203(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_COLON => Shift(yy_state_204)
    _ => Error
  }
}

///|
fn yy_state_204(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LPAREN => Shift(yy_state_7)
    T_IDENT => Shift(yy_state_12)
    T_LBRACKET => Shift(yy_state_16)
    NT_function_type => Shift(yy_state_23)
    NT_named_type => Shift(yy_state_24)
    NT_type => Shift(yy_state_205)
    _ => Error
  }
}

///|
fn yy_state_205(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_EQUAL => Shift(yy_state_206)
    _ => Error
  }
}

///|
fn yy_state_206(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_BUILTIN => Shift(yy_state_31)
    T_FN => Shift(yy_state_35)
    T_LBRACE => Shift(yy_state_52)
    T_MATCH => Shift(yy_state_54)
    T_IF => Shift(yy_state_55)
    NT_builtin_expression => Shift(yy_state_56)
    NT_function_literal => Shift(yy_state_57)
    NT_match_expression => Shift(yy_state_58)
    NT_if_expression => Shift(yy_state_59)
    NT_block_expression => Shift(yy_state_60)
    T_LPAREN => Shift(yy_state_61)
    NT_qualified_expression => Shift(yy_state_63)
    T_IDENT => Shift(yy_state_64)
    T_FALSE => Shift(yy_state_74)
    T_TRUE => Shift(yy_state_75)
    T_STRING => Shift(yy_state_76)
    T_INT => Shift(yy_state_77)
    NT_primary_expression => Shift(yy_state_78)
    T_BANG => Shift(yy_state_79)
    T_MINUS => Shift(yy_state_80)
    NT_expression => Shift(yy_state_207)
    _ => Error
  }
}

///|
fn yy_state_207(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_DOT => Shift(yy_state_82)
    T_LPAREN => Shift(yy_state_84)
    T_PERCENT => Shift(yy_state_89)
    T_SLASH => Shift(yy_state_91)
    T_STAR => Shift(yy_state_93)
    T_MINUS => Shift(yy_state_95)
    T_PLUS => Shift(yy_state_97)
    T_GTEQ => Shift(yy_state_99)
    T_GT => Shift(yy_state_101)
    T_LTEQ => Shift(yy_state_103)
    T_LT => Shift(yy_state_105)
    T_BANGEQ => Shift(yy_state_107)
    T_EQEQ => Shift(yy_state_109)
    T_AMPAMP => Shift(yy_state_111)
    T_BARBAR => Shift(yy_state_113)
    T_PIPE => Shift(yy_state_115)
    T_EOF | T_STRUCT | T_ENUM | T_FN | T_LET | T_OPEN =>
      Reduce(6, NT_top_level_let_declaration, yy_action_18)
    _ => Error
  }
}

///|
fn yy_state_208(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LBRACKET => Shift(yy_state_183)
    NT_type_parameters => Shift(yy_state_209)
    T_IDENT => Reduce(0, NT_type_parameters, yy_action_121)
    _ => Error
  }
}

///|
fn yy_state_209(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_187)
    _ => Error
  }
}

///|
fn yy_state_210(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_211)
    _ => Error
  }
}

///|
fn yy_state_211(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LBRACKET => Shift(yy_state_183)
    NT_type_parameters => Shift(yy_state_212)
    T_LBRACE => Reduce(0, NT_type_parameters, yy_action_121)
    _ => Error
  }
}

///|
fn yy_state_212(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LBRACE => Shift(yy_state_213)
    _ => Error
  }
}

///|
fn yy_state_213(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    NT_enum_variants => Shift(yy_state_214)
    T_IDENT | T_RBRACE => Reduce(0, NT_enum_variants, yy_action_17)
    _ => Error
  }
}

///|
fn yy_state_214(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_215)
    NT_enum_variant => Shift(yy_state_219)
    T_RBRACE => Shift(yy_state_220)
    _ => Error
  }
}

///|
fn yy_state_215(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LPAREN => Shift(yy_state_216)
    T_IDENT | T_RBRACE => Reduce(1, NT_enum_variant, yy_action_16)
    _ => Error
  }
}

///|
fn yy_state_216(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LPAREN => Shift(yy_state_7)
    NT_type => Shift(yy_state_8)
    T_IDENT => Shift(yy_state_12)
    T_LBRACKET => Shift(yy_state_16)
    NT_function_type => Shift(yy_state_23)
    NT_named_type => Shift(yy_state_24)
    NT_non_empty_type_list => Shift(yy_state_217)
    _ => Error
  }
}

///|
fn yy_state_217(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_COMMA => Shift(yy_state_10)
    T_RPAREN => Shift(yy_state_218)
    _ => Error
  }
}

///|
fn yy_state_218(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(4, NT_enum_variant, yy_action_15)
}

///|
fn yy_state_219(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(2, NT_enum_variants, yy_action_14)
}

///|
fn yy_state_220(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(6, NT_enum_declaration, yy_action_13)
}

///|
fn yy_state_221(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_222)
    _ => Error
  }
}

///|
fn yy_state_222(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LBRACKET => Shift(yy_state_183)
    NT_type_parameters => Shift(yy_state_223)
    T_LBRACE => Reduce(0, NT_type_parameters, yy_action_121)
    _ => Error
  }
}

///|
fn yy_state_223(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LBRACE => Shift(yy_state_224)
    _ => Error
  }
}

///|
fn yy_state_224(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    NT_struct_members => Shift(yy_state_225)
    T_IDENT | T_OPEN | T_RBRACE => Reduce(0, NT_struct_members, yy_action_12)
    _ => Error
  }
}

///|
fn yy_state_225(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_OPEN => Shift(yy_state_3)
    T_IDENT => Shift(yy_state_226)
    NT_open_declaration => Shift(yy_state_229)
    NT_field_declaration => Shift(yy_state_230)
    NT_struct_member => Shift(yy_state_231)
    T_RBRACE => Shift(yy_state_232)
    _ => Error
  }
}

///|
fn yy_state_226(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_COLON => Shift(yy_state_227)
    _ => Error
  }
}

///|
fn yy_state_227(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LPAREN => Shift(yy_state_7)
    T_IDENT => Shift(yy_state_12)
    T_LBRACKET => Shift(yy_state_16)
    NT_function_type => Shift(yy_state_23)
    NT_named_type => Shift(yy_state_24)
    NT_type => Shift(yy_state_228)
    _ => Error
  }
}

///|
fn yy_state_228(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_field_declaration, yy_action_11)
}

///|
fn yy_state_229(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_struct_member, yy_action_10)
}

///|
fn yy_state_230(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_struct_member, yy_action_9)
}

///|
fn yy_state_231(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(2, NT_struct_members, yy_action_8)
}

///|
fn yy_state_232(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(6, NT_struct_declaration, yy_action_7)
}

///|
fn yy_state_233(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_top_level_declaration, yy_action_6)
}

///|
fn yy_state_234(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_top_level_declaration, yy_action_5)
}

///|
fn yy_state_235(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_top_level_declaration, yy_action_4)
}

///|
fn yy_state_236(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_top_level_declaration, yy_action_3)
}

///|
fn yy_state_237(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_top_level_declaration, yy_action_2)
}

///|
fn yy_state_238(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(2, NT_top_level_declarations, yy_action_1)
}

///|
fn yy_state_239(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(2, NT_source_file, yy_action_0)
}

///|
fn[T] yy_parse(
  tokens : Array[(Token, SourceSpan, SourceSpan)],
  start : YYState,
  return_ : (YYObj) -> T,
  initial_pos? : SourceSpan,
) -> T raise ParseError {
  let mut cursor = 0
  let mut state_stack : @list.List[YYState] = @list.cons(start, @list.empty())
  let data_stack : Array[(YYObj, SourceSpan, SourceSpan)] = []
  let mut last_pos = initial_pos.unwrap_or(tokens[0].1)
  let mut state = start
  let mut lookahead : (YYSymbol, (YYObj, SourceSpan, SourceSpan), Token?)? = None
  let mut last_shifted_state_stack = state_stack
  while true {
    let decision = match state(EOI) {
      ReduceNoLookahead(_) | Accept as t => t
      _ =>
        match lookahead {
          Some(la) => state(la.0)
          None =>
            if cursor < tokens.length() {
              let (token, start_pos, end_pos) = tokens[cursor]
              cursor += 1
              let (symbol, data) = yy_input(token, start_pos, end_pos)
              lookahead = Some(
                (symbol, (data, start_pos, end_pos), Some(token)),
              )
              state(symbol)
            } else {
              lookahead = Some((EOI, (YYObj_Void, last_pos, last_pos), None))
              state(EOI)
            }
        }
    }
    match decision {
      Accept => return return_(data_stack.unsafe_pop().0)
      Shift(next_state) => {
        guard lookahead is Some(la)
        data_stack.push(la.1)
        state_stack = @list.cons(next_state, state_stack)
        last_shifted_state_stack = state_stack
        state = next_state
        last_pos = la.1.2
        lookahead = None
      }
      Reduce(count, symbol, action)
      | ReduceNoLookahead(count, symbol, action) =>
        for count = count, symbol = symbol, action = action {
          let args = data_stack[data_stack.length() - count:]
          let data = action(last_pos, args)
          let (start_pos, end_pos) = if args.length() == 0 {
            (last_pos, last_pos)
          } else {
            (args[0].1, args[args.length() - 1].2)
          }
          for _ in 0..<count {
            ignore(data_stack.unsafe_pop())
            state_stack = state_stack.unsafe_tail()
          }
          state = state_stack.unsafe_head()
          data_stack.push((data, start_pos, end_pos))
          match state(symbol) {
            Accept => return return_(data_stack.unsafe_pop().0)
            Shift(next_state) => {
              state_stack = @list.cons(next_state, state_stack)
              state = next_state
              break ()
            }
            Reduce(count, symbol, action)
            | ReduceNoLookahead(count, symbol, action) =>
              continue count, symbol, action
            _ => panic()
          }
        }
      Error => {
        let (_, (_, start_pos, end_pos), token) = lookahead.unwrap()
        error(last_shifted_state_stack, token, (start_pos, end_pos))
      }
    }
  }
  panic()
}

///|
fn error(
  stack : @list.List[YYState],
  token : Token?,
  loc : (SourceSpan, SourceSpan),
) -> Unit raise ParseError {
  let expected = []
  fn try_add(symbol : YYSymbol, kind : TokenKind) {
    fn go(stack : @list.List[YYState]) {
      match stack {
        Empty => ()
        More(state, ..) =>
          match state(symbol) {
            Accept | Shift(_) => expected.push(kind)
            Reduce(count, symbol, _) | ReduceNoLookahead(count, symbol, _) => {
              fn inner_go(stack : @list.List[YYState], count, symbol) {
                let stack = stack.drop(count)
                guard stack is More(state, ..)
                match state(symbol) {
                  Shift(state) => go(@list.cons(state, stack))
                  Reduce(count, symbol, _)
                  | ReduceNoLookahead(count, symbol, _) =>
                    inner_go(stack, count, symbol)
                  _ => panic()
                }
              }
              inner_go(stack, count, symbol)
            }
            Error => ()
          }
      }
    }
    go(stack)
  }
  for
    term in (
      [
        (T_CHAR, TK_CHAR),
        (T_INT, TK_INT),
        (T_STRING, TK_STRING),
        (T_IDENT, TK_IDENT),
        (T_RESERVED, TK_RESERVED),
        (T_EOF, TK_EOF),
        (T_FALSE, TK_FALSE),
        (T_TRUE, TK_TRUE),
        (T_STRUCT, TK_STRUCT),
        (T_ENUM, TK_ENUM),
        (T_FN, TK_FN),
        (T_LET, TK_LET),
        (T_OPEN, TK_OPEN),
        (T_IF, TK_IF),
        (T_ELSE, TK_ELSE),
        (T_MATCH, TK_MATCH),
        (T_BUILTIN, TK_BUILTIN),
        (T_PLUS, TK_PLUS),
        (T_MINUS, TK_MINUS),
        (T_STAR, TK_STAR),
        (T_SLASH, TK_SLASH),
        (T_PERCENT, TK_PERCENT),
        (T_EQEQ, TK_EQEQ),
        (T_BANGEQ, TK_BANGEQ),
        (T_LT, TK_LT),
        (T_LTEQ, TK_LTEQ),
        (T_GT, TK_GT),
        (T_GTEQ, TK_GTEQ),
        (T_AMPAMP, TK_AMPAMP),
        (T_BARBAR, TK_BARBAR),
        (T_BANG, TK_BANG),
        (T_PIPE, TK_PIPE),
        (T_LPAREN, TK_LPAREN),
        (T_RPAREN, TK_RPAREN),
        (T_LBRACE, TK_LBRACE),
        (T_RBRACE, TK_RBRACE),
        (T_LBRACKET, TK_LBRACKET),
        (T_RBRACKET, TK_RBRACKET),
        (T_COMMA, TK_COMMA),
        (T_DOT, TK_DOT),
        (T_COLON, TK_COLON),
        (T_COLONCOLON, TK_COLONCOLON),
        (T_THIN_ARROW, TK_THIN_ARROW),
        (T_FAT_ARROW, TK_FAT_ARROW),
        (T_EQUAL, TK_EQUAL),
        (T_UNDERSCORE, TK_UNDERSCORE),
      ] : Array[(YYSymbol, TokenKind)]) {
    try_add(term.0, term.1)
  }
  match token {
    None => raise UnexpectedEndOfInput(loc.1, expected)
    Some(token) => raise UnexpectedToken(token, loc, expected)
  }
}

///|
pub fn source_file(
  tokens : Array[(Token, SourceSpan, SourceSpan)],
  initial_pos? : SourceSpan,
) -> SourceFile raise ParseError {
  yy_parse(
    tokens,
    yy_state_0,
    it => {
      guard it is YYObj_SourceFile(result)
      result
    },
    initial_pos?,
  )
}

///|
fn _get_symbol_start_pos(
  args : ArrayView[(YYObj, SourceSpan, SourceSpan)],
  last_pos : SourceSpan,
) -> SourceSpan {
  if args.length() == 0 {
    last_pos
  } else {
    for i = 0; i < args.length(); i = i + 1 {
      let (_, start_pos, end_pos) = args[i]
      if start_pos == end_pos {
        continue
      }
      return start_pos
    }
    args[args.length() - 1].2
  }
}
