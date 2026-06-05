///|
pub struct SymbolRegistry {
  types : Array[TypeSymbolMetadata]
  type_parameters : Array[TypeParameterMetadata]
  values : Array[ValueSymbolMetadata]
  fields : Array[FieldSymbolMetadata]
  variants : Array[VariantSymbolMetadata]
} derive(Debug, Eq)

///|
pub fn SymbolRegistry::SymbolRegistry() -> SymbolRegistry {
  { types: [], type_parameters: [], values: [], fields: [], variants: [] }
}

///|
pub fn SymbolRegistry::define_type(
  self : SymbolRegistry,
  name : String,
  kind : NominalTypeKind,
  arity : Int,
  loc : SourceSpan,
) -> TypeSymbolId {
  let id = TypeSymbolId::{ index: self.types.length() }
  self.types.push({ id, name, kind, arity, loc })
  id
}

///|
pub fn SymbolRegistry::define_type_parameter(
  self : SymbolRegistry,
  name : String,
  loc : SourceSpan,
) -> TypeParameterId {
  let id = TypeParameterId::{ index: self.type_parameters.length() }
  self.type_parameters.push({ id, name, loc })
  id
}

///|
pub fn SymbolRegistry::define_value(
  self : SymbolRegistry,
  name : String,
  kind : ValueSymbolKind,
  loc : SourceSpan,
) -> ValueSymbolId {
  let id = ValueSymbolId::{ index: self.values.length() }
  self.values.push({ id, name, kind, loc })
  id
}

///|
pub fn SymbolRegistry::define_field(
  self : SymbolRegistry,
  owner : TypeSymbolId,
  name : String,
  index : Int,
  loc : SourceSpan,
) -> FieldSymbolId {
  let id = FieldSymbolId::{ index: self.fields.length() }
  self.fields.push({ id, owner, name, index, loc })
  id
}

///|
pub fn SymbolRegistry::define_variant(
  self : SymbolRegistry,
  owner : TypeSymbolId,
  name : String,
  index : Int,
  payload_count : Int,
  loc : SourceSpan,
) -> VariantSymbolId {
  let id = VariantSymbolId::{ index: self.variants.length() }
  self.variants.push({ id, owner, name, index, payload_count, loc })
  id
}

///|
pub fn SymbolRegistry::type_metadata(
  self : SymbolRegistry,
  id : TypeSymbolId,
) -> TypeSymbolMetadata? {
  self.types.get(id.index)
}

///|
pub fn SymbolRegistry::type_parameter_metadata(
  self : SymbolRegistry,
  id : TypeParameterId,
) -> TypeParameterMetadata? {
  self.type_parameters.get(id.index)
}

///|
pub fn SymbolRegistry::value_metadata(
  self : SymbolRegistry,
  id : ValueSymbolId,
) -> ValueSymbolMetadata? {
  self.values.get(id.index)
}

///|
pub fn SymbolRegistry::field_metadata(
  self : SymbolRegistry,
  id : FieldSymbolId,
) -> FieldSymbolMetadata? {
  self.fields.get(id.index)
}

///|
pub fn SymbolRegistry::variant_metadata(
  self : SymbolRegistry,
  id : VariantSymbolId,
) -> VariantSymbolMetadata? {
  self.variants.get(id.index)
}

///|
pub fn SymbolRegistry::type_named(
  self : SymbolRegistry,
  name : String,
) -> TypeSymbolId? {
  for metadata in self.types {
    if metadata.name == name {
      return Some(metadata.id)
    }
  }
  None
}

///|
pub fn SymbolRegistry::variant_named(
  self : SymbolRegistry,
  owner : TypeSymbolId,
  name : String,
) -> VariantSymbolId? {
  for metadata in self.variants {
    if metadata.owner == owner && metadata.name == name {
      return Some(metadata.id)
    }
  }
  None
}

///|
pub fn SymbolRegistry::variants_named(
  self : SymbolRegistry,
  name : String,
) -> Array[VariantSymbolId] {
  let variants = []
  for metadata in self.variants {
    if metadata.name == name {
      variants.push(metadata.id)
    }
  }
  variants
}

///|
pub fn SymbolRegistry::field_named(
  self : SymbolRegistry,
  owner : TypeSymbolId,
  name : String,
) -> FieldSymbolId? {
  for metadata in self.fields {
    if metadata.owner == owner && metadata.name == name {
      return Some(metadata.id)
    }
  }
  None
}

///|
pub fn SymbolRegistry::fields_of(
  self : SymbolRegistry,
  owner : TypeSymbolId,
) -> Array[FieldSymbolMetadata] {
  let fields = []
  for metadata in self.fields {
    if metadata.owner == owner {
      fields.push(metadata)
    }
  }
  fields
}
