name = "Milky2018/lane2"

version = "0.1.0"

readme = "README.mbt.md"

repository = ""

license = "Apache-2.0"

keywords = [ "language", "compiler", "moonbit" ]

description = "A MoonBit implementation of the Lane2 programming language."

import {
  "Milky2018/buslane@0.1.0",
  "moonbit-community/prettyprinter@0.4.10",
  "moonbitlang/yacc@0.7.13",
}

options(
  "bin-deps": { "moonbitlang/yacc": "0.7.13" },
)
