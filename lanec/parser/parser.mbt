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
  let yacc_tokens = tokens.map(fn(item) {
    let (token, loc) = item
    (token.to_yacc_token(), loc, loc)
  })
  let source = @yacc_parser.source_file(yacc_tokens) catch {
    UnexpectedEndOfInput(loc, _) =>
      return ParseResult::{
        source: None,
        lexical_errors: [],
        parse_errors: [ParseError::{ message: "Unexpected end of file.", loc }],
      }
    UnexpectedToken(_, (start, end), _) =>
      return ParseResult::{
        source: None,
        lexical_errors: [],
        parse_errors: [
          ParseError::{
            message: "Unexpected token.",
            loc: SourceSpan::join(start, end),
          },
        ],
      }
  }
  ParseResult::{ source: Some(source), lexical_errors: [], parse_errors: [] }
}

///|
fn @lexer.Token::to_yacc_token(self : @lexer.Token) -> @yacc_parser.Token {
  match self {
    CHAR(value) => CHAR(value)
    INT(value) => INT(value)
    STRING(value) => STRING(value)
    IDENT(value) => IDENT(value)
    RESERVED(value) => RESERVED(value)
    EOF => EOF
    FALSE => FALSE
    TRUE => TRUE
    STRUCT => STRUCT
    ENUM => ENUM
    FN => FN
    LET => LET
    OPEN => OPEN
    IF => IF
    ELSE => ELSE
    MATCH => MATCH
    BUILTIN => BUILTIN
    PLUS => PLUS
    MINUS => MINUS
    STAR => STAR
    SLASH => SLASH
    PERCENT => PERCENT
    EQEQ => EQEQ
    BANGEQ => BANGEQ
    LT => LT
    LTEQ => LTEQ
    GT => GT
    GTEQ => GTEQ
    AMPAMP => AMPAMP
    BARBAR => BARBAR
    BANG => BANG
    PIPE => PIPE
    LPAREN => LPAREN
    RPAREN => RPAREN
    LBRACE => LBRACE
    RBRACE => RBRACE
    LBRACKET => LBRACKET
    RBRACKET => RBRACKET
    COMMA => COMMA
    DOT => DOT
    COLON => COLON
    COLONCOLON => COLONCOLON
    THIN_ARROW => THIN_ARROW
    FAT_ARROW => FAT_ARROW
    EQUAL => EQUAL
    UNDERSCORE => UNDERSCORE
  }
}
