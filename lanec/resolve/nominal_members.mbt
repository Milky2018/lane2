///|
priv struct FieldTypeBinding {
  symbol : FieldSymbolId
  type_ : ResolvedType
}

///|
priv struct StructFieldForwarding {
  owner : TypeSymbolId
  field : FieldSymbolId
}

///|
priv struct NominalMembers {
  field_types : Array[FieldTypeBinding]
  field_forwardings : Array[StructFieldForwarding]
}

///|
fn NominalMembers::NominalMembers() -> NominalMembers {
  { field_types: [], field_forwardings: [] }
}

///|
fn NominalMembers::record_field_type(
  self : NominalMembers,
  symbol : FieldSymbolId,
  type_ : ResolvedType,
) -> Unit {
  self.field_types.push({ symbol, type_ })
}

///|
fn NominalMembers::record_struct_forwarding(
  self : NominalMembers,
  owner : TypeSymbolId,
  field : FieldSymbolId,
) -> Unit {
  self.field_forwardings.push({ owner, field })
}

///|
fn NominalMembers::field_type(
  self : NominalMembers,
  field : FieldSymbolId,
) -> ResolvedType? {
  for binding in self.field_types {
    if binding.symbol == field {
      return Some(binding.type_)
    }
  }
  None
}

///|
fn NominalMembers::opened_field_bindings(
  self : NominalMembers,
  registry : SymbolRegistry,
  base : ValueSymbolId,
  owner : TypeSymbolId,
  depth : Int,
) -> Array[ValueBinding] {
  let bindings = []
  // Opening a value exposes the immediate fields of its nominal struct type and
  // recursively exposes forwarded fields declared by struct-local `open`.
  self.collect_opened_field_bindings(
    registry,
    base,
    owner,
    depth,
    [],
    [],
    bindings,
  )
  bindings
}

///|
fn NominalMembers::collect_opened_field_bindings(
  self : NominalMembers,
  registry : SymbolRegistry,
  base : ValueSymbolId,
  owner : TypeSymbolId,
  depth : Int,
  prefix : Array[FieldSymbolId],
  visited : Array[TypeSymbolId],
  bindings : Array[ValueBinding],
) -> Unit {
  if visited.contains(owner) {
    return
  }
  // Forwarding can form cycles through recursive nominal structs. `visited`
  // keeps field expansion finite without treating the cycle as a resolver error.
  let next_visited = visited.copy()
  next_visited.push(owner)
  for field in registry.fields_of(owner) {
    let path = prefix.copy()
    path.push(field.id)
    bindings.push({
      name: field.name,
      reference: OpenedField(base~, path~),
      type_: None,
      kind: OpenExposure,
      depth,
    })
  }
  for forwarding in self.field_forwardings {
    if forwarding.owner == owner {
      match self.forwarded_owner(forwarding.field) {
        Some(forwarded_owner) => {
          let path = prefix.copy()
          path.push(forwarding.field)
          self.collect_opened_field_bindings(
            registry, base, forwarded_owner, depth, path, next_visited, bindings,
          )
        }
        None => ()
      }
    }
  }
}

///|
fn NominalMembers::forwarded_owner(
  self : NominalMembers,
  field : FieldSymbolId,
) -> TypeSymbolId? {
  match self.field_type(field) {
    Some(Nominal(symbol~, ..)) => Some(symbol)
    _ => None
  }
}
