///|
let keyword_table : @hashmap.HashMap[String, Token] = [
    ("struct", STRUCT),
    ("enum", ENUM),
    ("fn", FN),
    ("let", LET),
    ("open", OPEN),
    ("if", IF),
    ("else", ELSE),
    ("match", MATCH),
    ("builtin", BUILTIN),
    ("true", TRUE),
    ("false", FALSE),
    ("_", UNDERSCORE),
  ]
  |> @hashmap.from_array()

///|
let reserved_word_table : @hashset.HashSet[String] = [
    "effect", "handler", "module", "import", "pub", "type", "return",
  ]
  |> @hashset.from_array()
