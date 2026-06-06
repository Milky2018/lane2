///|
pub(all) struct TypedCandidate {
  reference : @resolve.ResolvedValueReference
  type_ : @types.Type
} derive(Debug, Eq)

///|
pub(all) enum Selection {
  Selected(TypedCandidate)
  Ambiguous(name~ : String, candidates~ : Array[TypedCandidate])
  NoMatch(name~ : String)
} derive(Debug, Eq)

///|
pub(all) struct CallableCandidate {
  reference : @resolve.ResolvedValueReference
  parameters : Array[@types.Type]
  result : @types.Type
} derive(Debug, Eq)

///|
pub(all) enum CallableSelection {
  Selected(CallableCandidate)
  Ambiguous(name~ : String, candidates~ : Array[CallableCandidate])
  NoMatch(name~ : String)
} derive(Debug, Eq)

///|
/// Selects a candidate only when the candidate set is already unique.
pub fn select_without_context(
  name : String,
  candidates : Array[TypedCandidate],
) -> Selection {
  select_from(name, candidates, fn(_) { true })
}

///|
/// Selects the unique candidate whose type equals the expected type.
pub fn select_by_expected(
  name : String,
  candidates : Array[TypedCandidate],
  expected : @types.Type,
) -> Selection {
  select_from(name, candidates, fn(candidate) {
    candidate.type_.equals(expected)
  })
}

///|
fn select_from(
  name : String,
  candidates : Array[TypedCandidate],
  keep : (TypedCandidate) -> Bool,
) -> Selection {
  let matches = []
  for candidate in candidates {
    if keep(candidate) {
      matches.push(candidate)
    }
  }
  match matches.length() {
    0 => NoMatch(name~)
    1 => Selected(matches[0])
    _ => Ambiguous(name~, candidates=matches)
  }
}

///|
/// Selects the unique callable candidate matching the supplied argument types.
pub fn select_by_call_arguments(
  name : String,
  candidates : Array[TypedCandidate],
  arguments : Array[@types.Type],
) -> CallableSelection {
  let matches = []
  for candidate in candidates {
    match callable_candidate(candidate, arguments) {
      Some(callable) => matches.push(callable)
      None => ()
    }
  }
  match matches.length() {
    0 => NoMatch(name~)
    1 => CallableSelection::Selected(matches[0])
    _ => CallableSelection::Ambiguous(name~, candidates=matches)
  }
}

///|
fn callable_candidate(
  candidate : TypedCandidate,
  arguments : Array[@types.Type],
) -> CallableCandidate? {
  match candidate.type_ {
    @types.Type::Function(parameters, result) =>
      if same_argument_types(parameters, arguments) {
        Some({ reference: candidate.reference, parameters, result })
      } else {
        None
      }
    _ => None
  }
}

///|
fn same_argument_types(
  parameters : Array[@types.Type],
  arguments : Array[@types.Type],
) -> Bool {
  if parameters.length() != arguments.length() {
    return false
  }
  for index in 0..<parameters.length() {
    if !parameters[index].equals(arguments[index]) {
      return false
    }
  }
  true
}
