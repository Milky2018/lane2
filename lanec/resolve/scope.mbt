///|
priv struct ValueBinding {
  name : String
  reference : ResolvedValueReference
  type_ : ResolvedType?
  kind : ValueBindingKind
  depth : Int
}

///|
priv enum ValueBindingKind {
  Plain
  OpenExposure
} derive(Eq)

///|
priv struct ResolveScope {
  values : Array[ValueBinding]
  type_parameters : Array[ResolvedTypeParameter]
  depth : Int
}

///|
fn ResolveScope::copy(self : ResolveScope) -> ResolveScope {
  {
    values: self.values.copy(),
    type_parameters: self.type_parameters.copy(),
    depth: self.depth,
  }
}

///|
fn ResolveScope::enter_scope(self : ResolveScope) -> ResolveScope {
  {
    values: self.values.copy(),
    type_parameters: self.type_parameters.copy(),
    depth: self.depth + 1,
  }
}

///|
fn ResolveScope::define_value(
  self : ResolveScope,
  name : String,
  symbol : ValueSymbolId,
  type_ : ResolvedType?,
) -> Unit {
  self.values.push({
    name,
    reference: Symbol(symbol),
    type_,
    kind: Plain,
    depth: self.depth,
  })
}

///|
fn ResolveScope::define_binding(
  self : ResolveScope,
  binding : ValueBinding,
) -> Unit {
  self.values.push(binding)
}

///|
fn ResolveScope::value_reference(
  self : ResolveScope,
  name : String,
) -> ResolvedValueReference {
  let candidates = []
  let mut found_plain = false
  let mut open_depth = None
  // Plain lexical bindings shadow earlier plain bindings, but they do not erase
  // open exposures. Open exposures are collected only from the nearest open
  // depth so an inner block-local `open` shadows outer open exposures.
  for index = self.values.length(); index > 0; index = index - 1 {
    let binding = self.values[index - 1]
    if binding.name == name {
      match binding.kind {
        Plain =>
          if !found_plain {
            candidates.push(binding.reference)
            found_plain = true
          }
        OpenExposure =>
          match open_depth {
            Some(depth) =>
              if binding.depth == depth {
                candidates.push(binding.reference)
              }
            None => {
              open_depth = Some(binding.depth)
              candidates.push(binding.reference)
            }
          }
      }
    }
  }
  match candidates.length() {
    0 => Unresolved(name)
    1 => candidates[0]
    _ => Candidates(name~, candidates~)
  }
}

///|
fn ResolveScope::value_binding(
  self : ResolveScope,
  name : String,
) -> ValueBinding? {
  for index = self.values.length(); index > 0; index = index - 1 {
    let binding = self.values[index - 1]
    if binding.name == name && binding.kind == Plain {
      return Some(binding)
    }
  }
  None
}

///|
fn ResolveScope::value_type(
  self : ResolveScope,
  reference : ResolvedValueReference,
) -> ResolvedType? {
  match reference {
    Symbol(symbol) => {
      for index = self.values.length(); index > 0; index = index - 1 {
        let binding = self.values[index - 1]
        if binding.reference == Symbol(symbol) {
          return binding.type_
        }
      }
      None
    }
    _ => None
  }
}

///|
fn ResolveScope::type_parameter(
  self : ResolveScope,
  name : String,
) -> TypeParameterId? {
  for index = self.type_parameters.length(); index > 0; index = index - 1 {
    let parameter = self.type_parameters[index - 1]
    if parameter.name == name {
      return Some(parameter.symbol)
    }
  }
  None
}
