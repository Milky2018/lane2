///|
priv struct ValueBinding {
  name : String
  symbol : ValueSymbolId
}

///|
priv struct ResolveScope {
  values : Array[ValueBinding]
  type_parameters : Array[ResolvedTypeParameter]
}

///|
priv struct Resolver {
  registry : SymbolRegistry
  top_values : Array[ValueBinding]
  diagnostics : Array[ResolveDiagnostic]
}

///|
pub fn resolve_source_file(source : @syntax.SourceFile) -> ResolvedSourceFile {
  resolve_source_file_result(source).source
}

///|
pub fn resolve_source_file_result(source : @syntax.SourceFile) -> ResolveResult {
  let resolver = Resolver::Resolver(SymbolRegistry())
  resolver.collect_top_level_headers(source)
  resolver.collect_nominal_members(source)
  let declarations = source.declarations.map(fn(declaration) {
    declaration.resolve_top_level(resolver)
  })
  let resolved = { symbols: resolver.registry, declarations, loc: source.loc }
  { source: resolved, diagnostics: resolver.diagnostics }
}

///|
fn Resolver::Resolver(registry : SymbolRegistry) -> Resolver {
  { registry, top_values: [], diagnostics: [] }
}

///|
fn Resolver::collect_top_level_headers(
  self : Resolver,
  source : @syntax.SourceFile,
) -> Unit {
  for declaration in source.declarations {
    match declaration {
      Struct(declaration) =>
        self.registry.define_type(
          declaration.name,
          Struct,
          declaration.type_parameters.length(),
          declaration.loc,
        )
        |> ignore
      Enum(declaration) =>
        self.registry.define_type(
          declaration.name,
          Enum,
          declaration.type_parameters.length(),
          declaration.loc,
        )
        |> ignore
      Function(declaration) => {
        let symbol = self.registry.define_value(
          declaration.name,
          TopLevelFunction,
          declaration.loc,
        )
        self.top_values.push({ name: declaration.name, symbol })
      }
      Let(_) | Open(_) => ()
    }
  }
}

///|
fn Resolver::collect_nominal_members(
  self : Resolver,
  source : @syntax.SourceFile,
) -> Unit {
  for declaration in source.declarations {
    match declaration {
      Struct(declaration) => {
        let owner = self.type_symbol(declaration.name)
        let mut index = 0
        for item in declaration.members {
          match item {
            Field(field) => {
              self.registry.define_field(owner, field.name, index, field.loc)
              |> ignore
              index += 1
            }
            Open(_) => ()
          }
        }
      }
      Enum(declaration) => {
        let owner = self.type_symbol(declaration.name)
        for index = 0; index < declaration.variants.length(); index = index + 1 {
          let variant = declaration.variants[index]
          self.registry.define_variant(
            owner,
            variant.name,
            index,
            variant.payload.length(),
            variant.loc,
          )
          |> ignore
        }
      }
      Function(_) | Let(_) | Open(_) => ()
    }
  }
}

///|
fn @syntax.TopLevelDeclaration::resolve_top_level(
  self : @syntax.TopLevelDeclaration,
  resolver : Resolver,
) -> ResolvedTopLevelDeclaration {
  match self {
    Struct(declaration) => Struct(declaration.resolve_struct(resolver))
    Enum(declaration) => Enum(declaration.resolve_enum(resolver))
    Function(declaration) =>
      Function(declaration.resolve_top_level_function(resolver))
    Let(declaration) => Let(declaration.resolve_top_level_let(resolver))
    Open(declaration) => Open(declaration.resolve_open())
  }
}

///|
fn @syntax.StructDeclaration::resolve_struct(
  self : @syntax.StructDeclaration,
  resolver : Resolver,
) -> ResolvedStructDeclaration {
  let symbol = resolver.type_symbol(self.name)
  let type_parameters = resolver.resolve_type_parameters(
    self.type_parameters,
    self.loc,
  )
  let scope = resolver.scope(type_parameters)
  let mut field_index = 0
  let members = self.members.map(fn(item) {
    match item {
      Field(field) => {
        let resolved = field.resolve_field(resolver, scope, symbol, field_index)
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
  resolver : Resolver,
) -> ResolvedEnumDeclaration {
  let symbol = resolver.type_symbol(self.name)
  let type_parameters = resolver.resolve_type_parameters(
    self.type_parameters,
    self.loc,
  )
  let scope = resolver.scope(type_parameters)
  let variants = self.variants.mapi(fn(index, variant) {
    variant.resolve_variant(resolver, scope, symbol, index)
  })
  { symbol, name: self.name, type_parameters, variants, loc: self.loc }
}

///|
fn Resolver::resolve_type_parameters(
  self : Resolver,
  names : Array[String],
  loc : SourceSpan,
) -> Array[ResolvedTypeParameter] {
  names.map(fn(name) {
    let symbol = self.registry.define_type_parameter(name, loc)
    { symbol, name, loc }
  })
}

///|
fn @syntax.FieldDeclaration::resolve_field(
  self : @syntax.FieldDeclaration,
  resolver : Resolver,
  scope : ResolveScope,
  owner : TypeSymbolId,
  index : Int,
) -> ResolvedFieldDeclaration {
  let symbol = resolver.registry.field_named(owner, self.name).unwrap()
  {
    symbol,
    name: self.name,
    type_: self.type_.resolve_type(resolver, scope),
    index,
    loc: self.loc,
  }
}

///|
fn @syntax.EnumVariant::resolve_variant(
  self : @syntax.EnumVariant,
  resolver : Resolver,
  scope : ResolveScope,
  owner : TypeSymbolId,
  index : Int,
) -> ResolvedEnumVariant {
  let symbol = resolver.registry.variant_named(owner, self.name).unwrap()
  {
    symbol,
    name: self.name,
    index,
    payload: self.payload.map(fn(type_) { type_.resolve_type(resolver, scope) }),
    loc: self.loc,
  }
}

///|
fn @syntax.FunctionDeclaration::resolve_top_level_function(
  self : @syntax.FunctionDeclaration,
  resolver : Resolver,
) -> ResolvedFunctionDeclaration {
  self.resolve_function_with_symbol(resolver, resolver.value_symbol(self.name))
}

///|
fn @syntax.FunctionDeclaration::resolve_function_with_symbol(
  self : @syntax.FunctionDeclaration,
  resolver : Resolver,
  symbol : ValueSymbolId,
) -> ResolvedFunctionDeclaration {
  let type_parameters = resolver.resolve_type_parameters(
    self.type_parameters,
    self.loc,
  )
  let parameter_scope = resolver.scope(type_parameters)
  let parameters = self.parameters.map(fn(parameter) {
    parameter.resolve_parameter(resolver, parameter_scope)
  })
  let return_type = self.return_type.resolve_type(resolver, parameter_scope)
  {
    symbol,
    name: self.name,
    type_parameters,
    parameters,
    return_type,
    body: self.body.resolve_expr(resolver, parameter_scope),
    loc: self.loc,
  }
}

///|
fn @syntax.Parameter::resolve_parameter(
  self : @syntax.Parameter,
  resolver : Resolver,
  scope : ResolveScope,
) -> ResolvedValueParameter {
  let type_ = self.type_.resolve_type(resolver, scope)
  let symbol = resolver.registry.define_value(self.name, Parameter, self.loc)
  scope.define_value(self.name, symbol)
  { symbol, name: self.name, type_, loc: self.loc }
}

///|
fn @syntax.LetDeclaration::resolve_top_level_let(
  self : @syntax.LetDeclaration,
  resolver : Resolver,
) -> ResolvedLetDeclaration {
  let scope = resolver.scope([])
  let declaration = self.resolve_let(resolver, scope, TopLevelValue)
  let display_name = self.name.unwrap_or("<anonymous>")
  resolver.top_values.push({ name: display_name, symbol: declaration.symbol })
  declaration
}

///|
fn @syntax.LetDeclaration::resolve_let(
  self : @syntax.LetDeclaration,
  resolver : Resolver,
  scope : ResolveScope,
  kind : @symbol.ValueSymbolKind,
) -> ResolvedLetDeclaration {
  let display_name = self.name.unwrap_or("<anonymous>")
  let initializer = self.initializer.resolve_expr(resolver, scope)
  let type_annotation = self.type_annotation.map(fn(type_) {
    type_.resolve_type(resolver, scope)
  })
  let symbol = resolver.registry.define_value(display_name, kind, self.loc)
  match self.name {
    Some(name) => scope.define_value(name, symbol)
    None => ()
  }
  { symbol, name: self.name, type_annotation, initializer, loc: self.loc }
}

///|
fn @syntax.OpenDeclaration::resolve_open(
  self : @syntax.OpenDeclaration,
) -> ResolvedOpenDeclaration {
  { name: self.name, loc: self.loc }
}

///|
fn @syntax.Type::resolve_type(
  self : @syntax.Type,
  resolver : Resolver,
  scope : ResolveScope,
) -> ResolvedType {
  match self {
    Name(name~, arguments~, loc~) => {
      let resolved_arguments = arguments.map(fn(argument) {
        argument.resolve_type(resolver, scope)
      })
      match primitive_type(name) {
        Some(primitive) => Primitive(primitive, loc~)
        None =>
          match scope.type_parameter(name) {
            Some(symbol) => Parameter(symbol~, name~, loc~)
            None =>
              match resolver.registry.type_named(name) {
                Some(symbol) =>
                  Nominal(symbol~, name~, arguments=resolved_arguments, loc~)
                None => {
                  resolver.report(UnresolvedType(name), loc)
                  Unresolved(name~, arguments=resolved_arguments, loc~)
                }
              }
          }
      }
    }
    Function(type_parameters~, parameters~, result~, loc~) => {
      let resolved_type_parameters = resolver.resolve_type_parameters(
        type_parameters, loc,
      )
      let next_scope = scope.copy()
      next_scope.type_parameters.append(resolved_type_parameters)
      Function(
        type_parameters=resolved_type_parameters,
        parameters=parameters.map(fn(type_) {
          type_.resolve_type(resolver, next_scope)
        }),
        result=result.resolve_type(resolver, next_scope),
        loc~,
      )
    }
  }
}

///|
fn @syntax.Expr::resolve_expr(
  self : @syntax.Expr,
  resolver : Resolver,
  scope : ResolveScope,
) -> ResolvedExpr {
  match self {
    IntLiteral(value, loc~) => IntLiteral(value, loc~)
    StringLiteral(value, loc~) => StringLiteral(value, loc~)
    BoolLiteral(value, loc~) => BoolLiteral(value, loc~)
    UnitLiteral(loc~) => UnitLiteral(loc~)
    Var(name, loc~) => {
      let reference = scope.value_reference(name)
      resolver.report_unresolved_value(reference, loc)
      Var(name~, reference~, loc~)
    }
    QualifiedVariant(type_name~, type_arguments~, variant~, arguments~, loc~) =>
      QualifiedVariant(
        type_name~,
        type_arguments=type_arguments.map(fn(type_) {
          type_.resolve_type(resolver, scope)
        }),
        variant~,
        reference=resolver.variant_reference(type_name, variant, loc),
        arguments=arguments.map(fn(argument) {
          argument.resolve_expr(resolver, scope)
        }),
        loc~,
      )
    StructLiteral(type_name~, type_arguments~, fields~, loc~) =>
      StructLiteral(
        type_name~,
        type_arguments=type_arguments.map(fn(type_) {
          type_.resolve_type(resolver, scope)
        }),
        fields=fields.map(fn(field) {
          field.resolve_struct_literal_field(resolver, scope)
        }),
        loc~,
      )
    Builtin(name, loc~) => Builtin(name, loc~)
    FunctionLiteral(type_parameters~, parameters~, return_type~, body~, loc~) => {
      let resolved_type_parameters = resolver.resolve_type_parameters(
        type_parameters, loc,
      )
      let next_scope = scope.copy()
      next_scope.type_parameters.append(resolved_type_parameters)
      let resolved_parameters = parameters.map(fn(parameter) {
        parameter.resolve_function_literal_parameter(resolver, next_scope)
      })
      FunctionLiteral(
        type_parameters=resolved_type_parameters,
        parameters=resolved_parameters,
        return_type=return_type.map(fn(type_) {
          type_.resolve_type(resolver, next_scope)
        }),
        body=body.resolve_expr(resolver, next_scope),
        loc~,
      )
    }
    Block(items~, result~, loc~) => {
      let next_scope = scope.copy()
      Block(
        items=items.map(fn(item) {
          item.resolve_local_item(resolver, next_scope)
        }),
        result=result.resolve_expr(resolver, next_scope),
        loc~,
      )
    }
    If(condition~, then_branch~, else_branch~, loc~) =>
      If(
        condition=condition.resolve_expr(resolver, scope),
        then_branch=then_branch.resolve_expr(resolver, scope),
        else_branch=else_branch.resolve_expr(resolver, scope),
        loc~,
      )
    Match(scrutinee~, arms~, loc~) =>
      Match(
        scrutinee=scrutinee.resolve_expr(resolver, scope),
        arms=arms.map(fn(arm) { arm.resolve_match_arm(resolver, scope) }),
        loc~,
      )
    Call(callee~, arguments~, loc~) =>
      callee.resolve_call(resolver, scope, arguments, loc)
    Field(base~, name~, loc~) =>
      Field(base=base.resolve_expr(resolver, scope), name~, loc~)
    Unary(operator~, operand~, loc~) =>
      Unary(operator~, operand=operand.resolve_expr(resolver, scope), loc~)
    Binary(operator~, left~, right~, loc~) =>
      Binary(
        operator~,
        left=left.resolve_expr(resolver, scope),
        right=right.resolve_expr(resolver, scope),
        loc~,
      )
    Pipeline(left~, right~, loc~) =>
      Pipeline(
        left=left.resolve_expr(resolver, scope),
        right=right.resolve_expr(resolver, scope),
        loc~,
      )
  }
}

///|
fn @syntax.Expr::resolve_call(
  self : @syntax.Expr,
  resolver : Resolver,
  scope : ResolveScope,
  arguments : Array[@syntax.Expr],
  loc : SourceSpan,
) -> ResolvedExpr {
  match self {
    Var(name, ..) =>
      match scope.value_reference(name) {
        Symbol(_) as reference =>
          Call(
            callee=Var(name~, reference~, loc=self.loc()),
            arguments=arguments.map(fn(argument) {
              argument.resolve_expr(resolver, scope)
            }),
            loc~,
          )
        Unresolved(_) =>
          match resolver.unqualified_variant_reference(name, loc) {
            Symbol(_) | Ambiguous(_) as reference =>
              UnqualifiedVariant(
                variant=name,
                reference~,
                arguments=arguments.map(fn(argument) {
                  argument.resolve_expr(resolver, scope)
                }),
                loc~,
              )
            UnresolvedUnqualified(_) => {
              resolver.report(UnresolvedValue(name), loc)
              Call(
                callee=Var(name~, reference=Unresolved(name), loc=self.loc()),
                arguments=arguments.map(fn(argument) {
                  argument.resolve_expr(resolver, scope)
                }),
                loc~,
              )
            }
            Unresolved(..) =>
              Call(
                callee=Var(name~, reference=Unresolved(name), loc=self.loc()),
                arguments=arguments.map(fn(argument) {
                  argument.resolve_expr(resolver, scope)
                }),
                loc~,
              )
          }
      }
    _ =>
      Call(
        callee=self.resolve_expr(resolver, scope),
        arguments=arguments.map(fn(argument) {
          argument.resolve_expr(resolver, scope)
        }),
        loc~,
      )
  }
}

///|
fn @syntax.StructLiteralField::resolve_struct_literal_field(
  self : @syntax.StructLiteralField,
  resolver : Resolver,
  scope : ResolveScope,
) -> ResolvedStructLiteralField {
  {
    name: self.name,
    value: self.value.map(fn(value) { value.resolve_expr(resolver, scope) }),
    loc: self.loc,
  }
}

///|
fn @syntax.FunctionLiteralParameter::resolve_function_literal_parameter(
  self : @syntax.FunctionLiteralParameter,
  resolver : Resolver,
  scope : ResolveScope,
) -> ResolvedFunctionLiteralParameter {
  let type_annotation = self.type_annotation.map(fn(type_) {
    type_.resolve_type(resolver, scope)
  })
  let symbol = resolver.registry.define_value(self.name, Parameter, self.loc)
  scope.define_value(self.name, symbol)
  { symbol, name: self.name, type_annotation, loc: self.loc }
}

///|
fn @syntax.LocalItem::resolve_local_item(
  self : @syntax.LocalItem,
  resolver : Resolver,
  scope : ResolveScope,
) -> ResolvedLocalItem {
  match self {
    Let(declaration) =>
      Let(declaration.resolve_let(resolver, scope, LocalBinding))
    Function(declaration) => {
      let symbol = resolver.registry.define_value(
        declaration.name,
        LocalFunction,
        declaration.loc,
      )
      scope.define_value(declaration.name, symbol)
      Function(declaration.resolve_function_with_symbol(resolver, symbol))
    }
    Open(declaration) => Open(declaration.resolve_open())
  }
}

///|
fn @syntax.MatchArm::resolve_match_arm(
  self : @syntax.MatchArm,
  resolver : Resolver,
  scope : ResolveScope,
) -> ResolvedMatchArm {
  let arm_scope = scope.copy()
  {
    pattern: self.pattern.resolve_pattern(resolver, arm_scope),
    body: self.body.resolve_expr(resolver, arm_scope),
    loc: self.loc,
  }
}

///|
fn @syntax.Pattern::resolve_pattern(
  self : @syntax.Pattern,
  resolver : Resolver,
  scope : ResolveScope,
) -> ResolvedPattern {
  match self {
    Wildcard(loc) => Wildcard(loc)
    Binding(name, loc~) => {
      let symbol = resolver.registry.define_value(name, PatternBinder, loc)
      scope.define_value(name, symbol)
      Binding(name~, symbol~, loc~)
    }
    IntLiteral(value, loc~) => IntLiteral(value, loc~)
    StringLiteral(value, loc~) => StringLiteral(value, loc~)
    BoolLiteral(value, loc~) => BoolLiteral(value, loc~)
    QualifiedVariant(type_name~, variant~, arguments~, loc~) =>
      QualifiedVariant(
        type_name~,
        variant~,
        reference=resolver.variant_reference(type_name, variant, loc),
        arguments=arguments.map(fn(argument) {
          argument.resolve_pattern(resolver, scope)
        }),
        loc~,
      )
    Struct(type_name~, fields~, loc~) =>
      Struct(
        type_name~,
        fields=fields.map(fn(field) {
          field.resolve_struct_pattern_field(resolver, scope)
        }),
        loc~,
      )
  }
}

///|
fn @syntax.StructPatternField::resolve_struct_pattern_field(
  self : @syntax.StructPatternField,
  resolver : Resolver,
  scope : ResolveScope,
) -> ResolvedStructPatternField {
  {
    name: self.name,
    pattern: self.pattern.map(fn(pattern) {
      pattern.resolve_pattern(resolver, scope)
    }),
    loc: self.loc,
  }
}

///|
fn Resolver::scope(
  self : Resolver,
  type_parameters : Array[ResolvedTypeParameter],
) -> ResolveScope {
  { values: self.top_values.copy(), type_parameters }
}

///|
fn ResolveScope::copy(self : ResolveScope) -> ResolveScope {
  { values: self.values.copy(), type_parameters: self.type_parameters.copy() }
}

///|
fn ResolveScope::define_value(
  self : ResolveScope,
  name : String,
  symbol : ValueSymbolId,
) -> Unit {
  self.values.push({ name, symbol })
}

///|
fn ResolveScope::value_reference(
  self : ResolveScope,
  name : String,
) -> ResolvedValueReference {
  for index = self.values.length(); index > 0; index = index - 1 {
    let binding = self.values[index - 1]
    if binding.name == name {
      return Symbol(binding.symbol)
    }
  }
  Unresolved(name)
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

///|
fn Resolver::type_symbol(self : Resolver, name : String) -> TypeSymbolId {
  self.registry.type_named(name).unwrap()
}

///|
fn Resolver::value_symbol(self : Resolver, name : String) -> ValueSymbolId {
  for binding in self.top_values {
    if binding.name == name {
      return binding.symbol
    }
  }
  abort("missing predeclared value symbol")
}

///|
fn Resolver::variant_reference(
  self : Resolver,
  type_name : String,
  variant : String,
  loc : SourceSpan,
) -> ResolvedVariantReference {
  match self.registry.type_named(type_name) {
    Some(owner) =>
      match self.registry.variant_named(owner, variant) {
        Some(symbol) => Symbol(symbol)
        None => {
          resolver_report_qualified_variant(self, type_name, variant, loc)
          Unresolved(type_name~, variant~)
        }
      }
    None => {
      resolver_report_qualified_variant(self, type_name, variant, loc)
      Unresolved(type_name~, variant~)
    }
  }
}

///|
fn Resolver::unqualified_variant_reference(
  self : Resolver,
  name : String,
  loc : SourceSpan,
) -> ResolvedVariantReference {
  let candidates = self.registry.variants_named(name)
  match candidates.length() {
    0 => UnresolvedUnqualified(name)
    1 => Symbol(candidates[0])
    _ => {
      self.report(
        AmbiguousUnqualifiedVariant(
          name~,
          candidates=candidates.map(fn(candidate) {
            self.variant_candidate(candidate)
          }),
        ),
        loc,
      )
      Ambiguous(name~, candidates~)
    }
  }
}

///|
fn Resolver::variant_candidate(
  self : Resolver,
  symbol : VariantSymbolId,
) -> ResolveVariantCandidate {
  match self.registry.variant_metadata(symbol) {
    Some(variant) =>
      match self.registry.type_metadata(variant.owner) {
        Some(owner) => { owner: owner.name, variant: variant.name }
        None => { owner: "<unknown>", variant: variant.name }
      }
    None => { owner: "<unknown>", variant: "<unknown>" }
  }
}

///|
fn Resolver::report(
  self : Resolver,
  kind : ResolveDiagnosticKind,
  loc : SourceSpan,
) -> Unit {
  self.diagnostics.push({ kind, loc })
}

///|
fn Resolver::report_unresolved_value(
  self : Resolver,
  reference : ResolvedValueReference,
  loc : SourceSpan,
) -> Unit {
  match reference {
    Symbol(_) => ()
    Unresolved(name) => self.report(UnresolvedValue(name), loc)
  }
}

///|
fn resolver_report_qualified_variant(
  resolver : Resolver,
  type_name : String,
  variant : String,
  loc : SourceSpan,
) -> Unit {
  resolver.report(UnresolvedQualifiedVariant(type_name~, variant~), loc)
}

///|
fn primitive_type(name : String) -> @types.PrimitiveType? {
  match name {
    "Int" => Some(Int)
    "Bool" => Some(Bool)
    "String" => Some(String)
    "Unit" => Some(Unit)
    _ => None
  }
}
