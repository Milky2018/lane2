///|
pub fn comma_space() -> Document {
  text(",") + space
}

///|
pub fn comma_line() -> Document {
  text(",") + line
}

///|
pub fn join_comma(docs : Array[Document]) -> Document {
  separate(comma_space(), docs)
}

///|
pub fn join_comma_group(docs : Array[Document]) -> Document {
  group(separate(comma_line(), docs))
}

///|
pub fn braced_block(docs : Array[Document]) -> Document {
  if docs.is_empty() {
    surround(char('{'), char('}'), empty)
  } else {
    surround(
      char('{'),
      hardline + char('}'),
      nest(hardline + separate(hardline, docs)),
    )
  }
}

///|
pub fn section(title : String, docs : Array[Document]) -> Document {
  text(title) + space + braced_block(docs)
}

///|
pub fn bracketed_inline(docs : Array[Document]) -> Document {
  surround(char('['), char(']'), join_comma(docs))
}

///|
pub fn parenthesized_inline(docs : Array[Document]) -> Document {
  surround(char('('), char(')'), join_comma(docs))
}
