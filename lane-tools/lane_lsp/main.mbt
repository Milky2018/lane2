///|
async fn main {
  @async.pause()
  let prelude = @fs.read_file_to_string(prelude_path, encoding="utf8") catch {
    _ => abort("failed to read prelude")
  }
  run_server(ServerState(prelude))
}

///|
async fn run_server(state : ServerState) -> Unit {
  while read_protocol_message(@stdio.stdin) is Some(message) {
    let result = state.handle_message(message)
    for outgoing in result.outgoing {
      write_protocol_message(@stdio.stdout, outgoing)
    }
    if result.exit_requested {
      break
    }
  }
}
