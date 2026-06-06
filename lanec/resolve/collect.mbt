///|
priv struct Resolver {
  registry : SymbolRegistry
  top_values : Array[ValueBinding]
  diagnostics : Array[ResolveDiagnostic]
  members : NominalMembers
}

///|
/// Resolves a syntax source file and returns only the resolved source.
pub fn resolve_source_file(source : @syntax.SourceFile) -> ResolvedSourceFile {
  resolve_source_file_result(source).source
}

///|
/// Resolves a syntax source file and returns diagnostics with the result.
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
  {
    registry,
    top_values: [],
    diagnostics: [],
    members: NominalMembers::NominalMembers(),
  }
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
        self.top_values.push({
          name: declaration.name,
          reference: Symbol(symbol),
          type_: None,
          kind: Plain,
          depth: 0,
        })
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
    Open(declaration) => Open(declaration.resolve_top_level_open(resolver))
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
      Open(open) => {
        resolver.resolve_struct_forwarding(symbol, open)
        Open(open.resolve_open())
      }
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
  let type_ = self.type_.resolve_type(resolver, scope)
  resolver.members.record_field_type(symbol, type_)
  { symbol, name: self.name, type_, index, loc: self.loc }
}

///|
fn Resolver::resolve_struct_forwarding(
  self : Resolver,
  owner : TypeSymbolId,
  open : @syntax.OpenDeclaration,
) -> Unit {
  match self.registry.field_named(owner, open.name) {
    Some(field) =>
      match self.members.field_type(field) {
        Some(Nominal(symbol~, ..)) =>
          match self.registry.type_metadata(symbol) {
            Some({ kind: Struct, .. }) =>
              self.members.record_struct_forwarding(owner, field)
            _ => self.report(CannotOpenValue(open.name), open.loc)
          }
        _ => self.report(CannotOpenValue(open.name), open.loc)
      }
    None => self.report(CannotOpenValue(open.name), open.loc)
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
  scope.define_value(self.name, symbol, Some(type_))
  { symbol, name: self.name, type_, loc: self.loc }
}

///|
fn @syntax.LetDeclaration::resolve_top_level_let(
  self : @syntax.LetDeclaration,
  resolver : Resolver,
) -> ResolvedLetDeclaration {
  let scope = resolver.scope([])
  let declaration = self.resolve_let(resolver, scope, TopLevelValue)
  resolver.publish_top_level_let(declaration, self.loc)
  declaration
}

///|
fn Resolver::publish_top_level_let(
  self : Resolver,
  declaration : ResolvedLetDeclaration,
  loc : SourceSpan,
) -> Unit {
  let binding = {
    name: declaration.name.unwrap_or("<anonymous>"),
    reference: Symbol(declaration.symbol),
    type_: declaration.type_annotation,
    kind: Plain,
    depth: 0,
  }
  match declaration.name {
    Some(_) => self.publish_top_level_binding(binding, loc)
    None => self.open_top_level_binding(binding, loc)
  }
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
    Some(name) => scope.define_value(name, symbol, type_annotation)
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
fn @syntax.OpenDeclaration::resolve_top_level_open(
  self : @syntax.OpenDeclaration,
  resolver : Resolver,
) -> ResolvedOpenDeclaration {
  let scope = resolver.scope([])
  match scope.value_binding(self.name) {
    Some(binding) => resolver.open_top_level_binding(binding, self.loc)
    None => resolver.report(UnresolvedOpenValue(self.name), self.loc)
  }
  self.resolve_open()
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
      let next_scope = scope.enter_scope()
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
      let next_scope = scope.enter_scope()
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
      let next_scope = scope.enter_scope()
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
    Field(base~, name~, loc~) => {
      let base = base.resolve_expr(resolver, scope)
      Field(
        base~,
        name~,
        reference=resolver.field_reference(scope, base, name, loc),
        loc~,
      )
    }
    Unary(operator~, operand~, loc~) => {
      let reference = resolver.operator_reference(
        scope,
        operator.operation_name(),
        loc,
      )
      Unary(
        operator~,
        reference~,
        operand=operand.resolve_expr(resolver, scope),
        loc~,
      )
    }
    Binary(operator~, left~, right~, loc~) => {
      let reference = resolver.operator_reference(
        scope,
        operator.operation_name(),
        loc,
      )
      Binary(
        operator~,
        reference~,
        left=left.resolve_expr(resolver, scope),
        right=right.resolve_expr(resolver, scope),
        loc~,
      )
    }
    Pipeline(left~, right~, loc~) =>
      Pipeline(
        left=left.resolve_expr(resolver, scope),
        right=right.resolve_expr(resolver, scope),
        loc~,
      )
  }
}

///|
fn Resolver::operator_reference(
  self : Resolver,
  scope : ResolveScope,
  name : String,
  loc : SourceSpan,
) -> ResolvedValueReference {
  let reference = scope.value_reference(name)
  self.report_unresolved_value(reference, loc)
  reference
}

///|
fn @syntax.UnaryOperator::operation_name(
  self : @syntax.UnaryOperator,
) -> String {
  match self {
    Neg => "op_neg"
    Not => "op_not"
  }
}

///|
fn @syntax.BinaryOperator::operation_name(
  self : @syntax.BinaryOperator,
) -> String {
  match self {
    Add => "op_add"
    Sub => "op_sub"
    Mul => "op_mul"
    Div => "op_div"
    Rem => "op_rem"
    Equal => "op_equal"
    NotEqual => "op_not_equal"
    Less => "op_less"
    LessEqual => "op_less_eq"
    Greater => "op_greater"
    GreaterEqual => "op_greater_eq"
    And => "op_and"
    Or => "op_or"
  }
}

///|
fn Resolver::field_reference(
  self : Resolver,
  scope : ResolveScope,
  base : ResolvedExpr,
  name : String,
  loc : SourceSpan,
) -> ResolvedFieldReference {
  match self.nominal_type_of_expr(scope, base) {
    Some(symbol) =>
      match self.registry.field_named(symbol, name) {
        Some(field) => Symbol(field)
        None => {
          self.report_unresolved_field(symbol, name, loc)
          let type_name = match self.registry.type_metadata(symbol) {
            Some(metadata) => metadata.name
            None => "<unknown>"
          }
          Unresolved(type_name~, field=name)
        }
      }
    None => Deferred(name)
  }
}

///|
fn Resolver::nominal_type_of_expr(
  self : Resolver,
  scope : ResolveScope,
  expr : ResolvedExpr,
) -> TypeSymbolId? {
  match expr {
    Var(reference~, ..) =>
      match scope.value_type(reference) {
        Some(Nominal(symbol~, ..)) => Some(symbol)
        _ => None
      }
    StructLiteral(type_name~, ..) => self.registry.type_named(type_name)
    _ => None
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
        Symbol(_) | OpenedField(..) | Candidates(..) as reference =>
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
  scope.define_value(self.name, symbol, type_annotation)
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
      scope.define_value(declaration.name, symbol, None)
      Function(declaration.resolve_function_with_symbol(resolver, symbol))
    }
    Open(declaration) => Open(declaration.resolve_local_open(resolver, scope))
  }
}

///|
fn @syntax.OpenDeclaration::resolve_local_open(
  self : @syntax.OpenDeclaration,
  resolver : Resolver,
  scope : ResolveScope,
) -> ResolvedOpenDeclaration {
  match scope.value_binding(self.name) {
    Some(binding) => resolver.open_local_binding(binding, scope, self.loc)
    None => resolver.report(UnresolvedOpenValue(self.name), self.loc)
  }
  self.resolve_open()
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
      scope.define_value(name, symbol, None)
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
  { values: self.top_values.copy(), type_parameters, depth: 0 }
}

///|
fn Resolver::type_symbol(self : Resolver, name : String) -> TypeSymbolId {
  self.registry.type_named(name).unwrap()
}

///|
fn Resolver::value_symbol(self : Resolver, name : String) -> ValueSymbolId {
  for binding in self.top_values {
    if binding.name == name {
      match binding.reference {
        Symbol(symbol) => return symbol
        _ => ()
      }
    }
  }
  abort("missing predeclared value symbol")
}

///|
fn Resolver::top_value_binding(self : Resolver, name : String) -> ValueBinding? {
  for index = self.top_values.length(); index > 0; index = index - 1 {
    let binding = self.top_values[index - 1]
    if binding.name == name && binding.kind == Plain {
      return Some(binding)
    }
  }
  None
}

///|
fn Resolver::publish_top_level_binding(
  self : Resolver,
  binding : ValueBinding,
  loc : SourceSpan,
) -> Unit {
  match binding.kind {
    Plain =>
      match self.top_value_binding(binding.name) {
        Some(existing) =>
          self.report(
            ConflictingOpenExposure(
              name=binding.name,
              existing=self.binding_display(existing),
              incoming=self.binding_display(binding),
            ),
            loc,
          )
        None => self.top_values.push(binding)
      }
    OpenExposure => self.top_values.push(binding)
  }
}

///|
fn Resolver::open_top_level_binding(
  self : Resolver,
  binding : ValueBinding,
  loc : SourceSpan,
) -> Unit {
  match self.opened_fields(binding, 0, loc) {
    Some(fields) =>
      for field in fields {
        self.publish_top_level_binding(field, loc)
      }
    None => ()
  }
}

///|
fn Resolver::open_local_binding(
  self : Resolver,
  binding : ValueBinding,
  scope : ResolveScope,
  loc : SourceSpan,
) -> Unit {
  match self.opened_fields(binding, scope.depth, loc) {
    Some(fields) =>
      for field in fields {
        scope.define_binding(field)
      }
    None => ()
  }
}

///|
fn Resolver::opened_fields(
  self : Resolver,
  binding : ValueBinding,
  depth : Int,
  loc : SourceSpan,
) -> Array[ValueBinding]? {
  match (binding.reference, binding.type_) {
    (Symbol(base), Some(Nominal(symbol~, ..))) =>
      match self.registry.type_metadata(symbol) {
        Some({ kind: Struct, .. }) =>
          Some(
            self.members.opened_field_bindings(
              self.registry,
              base,
              symbol,
              depth,
            ),
          )
        _ => {
          self.report(CannotOpenValue(binding.name), loc)
          None
        }
      }
    _ => {
      self.report(CannotOpenValue(binding.name), loc)
      None
    }
  }
}

///|
fn Resolver::binding_display(self : Resolver, binding : ValueBinding) -> String {
  match binding.reference {
    Symbol(symbol) =>
      match self.registry.value_metadata(symbol) {
        Some(metadata) => metadata.name
        None => binding.name
      }
    OpenedField(base~, path~) => {
      let base_name = match self.registry.value_metadata(base) {
        Some(metadata) => metadata.name
        None => "<unknown>"
      }
      base_name + "." + self.field_path_display(path, binding.name)
    }
    Candidates(name~, ..) => name
    Unresolved(name) => name
  }
}

///|
fn Resolver::field_path_display(
  self : Resolver,
  path : Array[FieldSymbolId],
  fallback : String,
) -> String {
  let names = []
  for field in path {
    match self.registry.field_metadata(field) {
      Some(metadata) => names.push(metadata.name)
      None => names.push(fallback)
    }
  }
  names.join(".")
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
    OpenedField(..) => ()
    Candidates(..) => ()
    Unresolved(name) => self.report(UnresolvedValue(name), loc)
  }
}

///|
fn Resolver::report_unresolved_field(
  self : Resolver,
  owner : TypeSymbolId,
  field : String,
  loc : SourceSpan,
) -> Unit {
  let type_name = match self.registry.type_metadata(owner) {
    Some(metadata) => metadata.name
    None => "<unknown>"
  }
  self.report(UnresolvedField(type_name~, field~), loc)
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
