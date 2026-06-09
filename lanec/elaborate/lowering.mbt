///|
pub(all) struct SourceElaborationResult {
  expression : CheckedExpr?
  diagnostics : Array[SourceElaborationDiagnostic]
} derive(Debug, Eq)

///|
pub(all) struct SourceElaborationDiagnostic {
  kind : SourceElaborationDiagnosticKind
  loc : SourceSpan
} derive(Debug, Eq)

///|
pub(all) enum SourceElaborationDiagnosticKind {
  InvalidPipelineRhs
} derive(Debug, Eq)

///|
/// Lowers `left |> right` into an ordinary checked call.
///
/// A checked pipeline right-hand side must already be either a checked call or
/// a checked function literal. For `left |> f(a, b)`, this produces
/// `f(left, a, b)`. For `left |> fn(x) { ... }`, this produces a direct call
/// to the checked function literal. Invalid right-hand sides produce only a
/// diagnostic; no expression is returned.
pub fn elaborate_pipeline_expression(
  left : CheckedExpr,
  right : CheckedExpr,
  loc : SourceSpan,
) -> SourceElaborationResult {
  match right {
    Call(callee~, arguments~, type_~, ..) =>
      ok(
        Call(callee~, arguments=prepend_argument(left, arguments), type_~, loc~),
      )
    FunctionLiteral(return_type~, ..) =>
      ok(Call(callee=right, arguments=[left], type_=return_type, loc~))
    _ => { expression: None, diagnostics: [{ kind: InvalidPipelineRhs, loc }] }
  }
}

///|
fn ok(expression : CheckedExpr) -> SourceElaborationResult {
  { expression: Some(expression), diagnostics: [] }
}

///|
fn prepend_argument(
  argument : CheckedExpr,
  arguments : Array[CheckedExpr],
) -> Array[CheckedExpr] {
  let result = [argument]
  for item in arguments {
    result.push(item)
  }
  result
}
