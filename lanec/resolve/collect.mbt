///|
pub fn resolve_source_file(source : @syntax.SourceFile) -> ResolvedSourceFile {
  let registry = SymbolRegistry()
  let declarations = source.declarations.map(fn(declaration) {
    declaration.resolve_top_level(registry)
  })
  { symbols: registry, declarations, loc: source.loc }
}

///|
fn @syntax.TopLevelDeclaration::resolve_top_level(
  self : @syntax.TopLevelDeclaration,
  registry : SymbolRegistry,
) -> ResolvedTopLevelDeclaration {
  match self {
    Struct(declaration) => Struct(declaration.resolve_struct(registry))
    Enum(declaration) => Enum(declaration.resolve_enum(registry))
    Function(declaration) =>
      Function(declaration.resolve_function(registry, TopLevelFunction))
    Let(declaration) => Let(declaration.resolve_top_level_let(registry))
    Open(declaration) => Open(declaration.resolve_open())
  }
}

///|
fn @syntax.StructDeclaration::resolve_struct(
  self : @syntax.StructDeclaration,
  registry : SymbolRegistry,
) -> ResolvedStructDeclaration {
  let symbol = registry.define_type(
    self.name,
    Struct,
    self.type_parameters.length(),
    self.loc,
  )
  let type_parameters = self.resolve_type_parameters(registry)
  let mut field_index = 0
  let members = self.members.map(fn(item) {
    match item {
      Field(field) => {
        let resolved = field.resolve_field(registry, symbol, field_index)
        field_index += 1
        ResolvedStructMember::Field(resolved)
      }
      Open(open) => Open(open.resolve_open())
    }
  })
  { symbol, name: self.name, type_parameters, members, loc: self.loc }
}

///|
fn @syntax.EnumDeclaration::resolve_enum(
  self : @syntax.EnumDeclaration,
  registry : SymbolRegistry,
) -> ResolvedEnumDeclaration {
  let symbol = registry.define_type(
    self.name,
    Enum,
    self.type_parameters.length(),
    self.loc,
  )
  let type_parameters = self.resolve_type_parameters(registry)
  let variants = self.variants.mapi(fn(index, variant) {
    variant.resolve_variant(registry, symbol, index)
  })
  { symbol, name: self.name, type_parameters, variants, loc: self.loc }
}

///|
fn @syntax.StructDeclaration::resolve_type_parameters(
  self : @syntax.StructDeclaration,
  registry : SymbolRegistry,
) -> Array[ResolvedTypeParameter] {
  self.type_parameters.map(fn(name) {
    let symbol = registry.define_type_parameter(name, self.loc)
    { symbol, name, loc: self.loc }
  })
}

///|
fn @syntax.EnumDeclaration::resolve_type_parameters(
  self : @syntax.EnumDeclaration,
  registry : SymbolRegistry,
) -> Array[ResolvedTypeParameter] {
  self.type_parameters.map(fn(name) {
    let symbol = registry.define_type_parameter(name, self.loc)
    { symbol, name, loc: self.loc }
  })
}

///|
fn @syntax.FunctionDeclaration::resolve_type_parameters(
  self : @syntax.FunctionDeclaration,
  registry : SymbolRegistry,
) -> Array[ResolvedTypeParameter] {
  self.type_parameters.map(fn(name) {
    let symbol = registry.define_type_parameter(name, self.loc)
    { symbol, name, loc: self.loc }
  })
}

///|
fn @syntax.FieldDeclaration::resolve_field(
  self : @syntax.FieldDeclaration,
  registry : SymbolRegistry,
  owner : TypeSymbolId,
  index : Int,
) -> ResolvedFieldDeclaration {
  let symbol = registry.define_field(owner, self.name, index, self.loc)
  { symbol, name: self.name, index, loc: self.loc }
}

///|
fn @syntax.EnumVariant::resolve_variant(
  self : @syntax.EnumVariant,
  registry : SymbolRegistry,
  owner : TypeSymbolId,
  index : Int,
) -> ResolvedEnumVariant {
  let symbol = registry.define_variant(
    owner,
    self.name,
    index,
    self.payload.length(),
    self.loc,
  )
  {
    symbol,
    name: self.name,
    index,
    payload_count: self.payload.length(),
    loc: self.loc,
  }
}

///|
fn @syntax.FunctionDeclaration::resolve_function(
  self : @syntax.FunctionDeclaration,
  registry : SymbolRegistry,
  kind : @symbol.ValueSymbolKind,
) -> ResolvedFunctionDeclaration {
  let symbol = registry.define_value(self.name, kind, self.loc)
  let type_parameters = self.resolve_type_parameters(registry)
  let parameters = self.parameters.map(fn(parameter) {
    parameter.resolve_parameter(registry)
  })
  { symbol, name: self.name, type_parameters, parameters, loc: self.loc }
}

///|
fn @syntax.Parameter::resolve_parameter(
  self : @syntax.Parameter,
  registry : SymbolRegistry,
) -> ResolvedValueParameter {
  let symbol = registry.define_value(self.name, Parameter, self.loc)
  { symbol, name: self.name, loc: self.loc }
}

///|
fn @syntax.LetDeclaration::resolve_top_level_let(
  self : @syntax.LetDeclaration,
  registry : SymbolRegistry,
) -> ResolvedLetDeclaration {
  let display_name = self.name.unwrap_or("<anonymous>")
  let symbol = registry.define_value(display_name, TopLevelValue, self.loc)
  { symbol, name: self.name, loc: self.loc }
}

///|
fn @syntax.OpenDeclaration::resolve_open(
  self : @syntax.OpenDeclaration,
) -> ResolvedOpenDeclaration {
  { name: self.name, loc: self.loc }
}
