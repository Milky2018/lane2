///|
pub(all) struct SourceSpan {
  start_offset : Int
  end_offset : Int
  start_line : Int
  start_column : Int
  end_line : Int
  end_column : Int
} derive(Debug, Eq)

///|
pub fn SourceSpan::join(start : SourceSpan, end : SourceSpan) -> SourceSpan {
  SourceSpan::{
    start_offset: start.start_offset,
    end_offset: end.end_offset,
    start_line: start.start_line,
    start_column: start.start_column,
    end_line: end.end_line,
    end_column: end.end_column,
  }
}

///|
pub fn SourceSpan::dummy() -> SourceSpan {
  SourceSpan::{
    start_offset: 0,
    end_offset: 0,
    start_line: 1,
    start_column: 1,
    end_line: 1,
    end_column: 1,
  }
}
