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

///|
priv struct State {
  tokens : Array[(@lexer.Token, SourceSpan)]
  errors : Array[ParseError]
  mut next : Int
}

///|
fn State::peek(self : State, nth? : Int = 0) -> (@lexer.Token, SourceSpan) {
  let index = self.next + nth
  match self.tokens.get(index) {
    Some(item) => item
    None =>
      match self.tokens.last() {
        Some(last) => last
        None => (@lexer.Token::EOF, SourceSpan::dummy())
      }
  }
}

///|
fn State::peek_token(self : State, nth? : Int = 0) -> @lexer.Token {
  self.peek(nth~).0
}

///|
fn State::peek_span(self : State, nth? : Int = 0) -> SourceSpan {
  self.peek(nth~).1
}

///|
fn State::consume(self : State) -> (@lexer.Token, SourceSpan) {
  let item = self.peek()
  if !(item.0 is @lexer.Token::EOF) {
    self.next += 1
  }
  item
}

///|
fn State::match_token(self : State, expected : @lexer.Token) -> Bool {
  if self.peek_token() == expected {
    self.consume() |> ignore
    true
  } else {
    false
  }
}

///|
fn State::expect(
  self : State,
  expected : @lexer.Token,
  expected_text : String,
) -> SourceSpan {
  if self.peek_token() == expected {
    self.consume().1
  } else {
    let loc = self.peek_span()
    self.report("Expected " + expected_text + ".", loc)
    loc
  }
}

///|
fn State::expect_ident(self : State, context : String) -> (String, SourceSpan) {
  match self.peek() {
    (@lexer.Token::IDENT(name), loc) => {
      self.consume() |> ignore
      (name, loc)
    }
    (_, loc) => {
      self.report("Expected identifier for " + context + ".", loc)
      ("", loc)
    }
  }
}

///|
fn State::report(self : State, message : String, loc : SourceSpan) -> Unit {
  self.errors.push(ParseError::{ message, loc })
}

///|
fn join_span(start : SourceSpan, end : SourceSpan) -> SourceSpan {
  SourceSpan::join(start, end)
}
