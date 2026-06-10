///|
pub(all) struct ElaborateResult {
  source : @checked.CheckedSourceFile?
  diagnostics : Array[@typecheck.TypeCheckDiagnostic]
} derive(Debug, Eq)

///|
/// Elaborates a resolved source file into Checked Source AST when type checking
/// succeeds and all checked-source nodes required by the file are implemented.
pub fn elaborate_resolved_source_file(
  source : @resolve.ResolvedSourceFile,
) -> ElaborateResult {
  let result = @typecheck.typecheck_checked_source_file(source)
  { source: result.source, diagnostics: result.diagnostics }
}

///|
pub impl @prettyprinter.Pretty for ElaborateResult with fn pretty(
  result : ElaborateResult,
) {
  let source = match result.source {
    Some(source) => source.pretty()
    None => text("<no checked source>")
  }
  text("elaborate_result") +
  space +
  @pretty.braced_block([
    source,
    @pretty.section(
      "diagnostics",
      result.diagnostics.map(@typecheck.TypeCheckDiagnostic::pretty),
    ),
  ])
}
