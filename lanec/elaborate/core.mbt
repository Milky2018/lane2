///|
pub(all) struct ElaborateResult {
  source : @checked.CheckedSourceFile?
  diagnostics : Array[@typecheck.TypeCheckDiagnostic]
} derive(Debug, Eq)

///|
pub(all) struct CoreElaborateResult {
  program : @core.CoreProgram?
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
/// Elaborates a resolved source file into Typed Core when Checked Source
/// construction succeeds.
pub fn elaborate_resolved_source_file_to_core(
  source : @resolve.ResolvedSourceFile,
) -> CoreElaborateResult {
  let result = @typecheck.typecheck_checked_source_file(source)
  let program = match result.source {
    Some(source) => Some(@core.lower_checked_source_file(source))
    None => None
  }
  { program, diagnostics: result.diagnostics }
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

///|
pub impl @prettyprinter.Pretty for CoreElaborateResult with fn pretty(
  result : CoreElaborateResult,
) {
  let program = match result.program {
    Some(program) => program.pretty()
    None => text("<no core program>")
  }
  text("core_elaborate_result") +
  space +
  @pretty.braced_block([
    program,
    @pretty.section(
      "diagnostics",
      result.diagnostics.map(@typecheck.TypeCheckDiagnostic::pretty),
    ),
  ])
}
