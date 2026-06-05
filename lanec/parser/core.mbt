///|
pub(all) struct ParseError {
  message : String
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub struct ParseResult {
  source : @syntax.SourceFile?
  lexical_errors : Array[@lexer.LexError]
  parse_errors : Array[ParseError]
} derive(Debug, Eq)
