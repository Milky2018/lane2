///|
fn candidate(type_ : @types.Type) -> TypedCandidate {
  { reference: @resolve.ResolvedValueReference::Unresolved("candidate"), type_ }
}

///|
test "select candidate by expected type" {
  let selected = select_by_expected(
    "value",
    [
      candidate(@types.Type::Primitive(@types.PrimitiveType::Bool)),
      candidate(@types.Type::Primitive(@types.PrimitiveType::Int)),
    ],
    @types.Type::Primitive(@types.PrimitiveType::Int),
  )
  debug_inspect(
    selected,
    content="Selected({ reference: Unresolved(\"candidate\"), type_: Primitive(Int) })",
  )
}

///|
test "keep ambiguity when expected type matches more than one candidate" {
  let selected = select_by_expected(
    "value",
    [
      candidate(@types.Type::Primitive(@types.PrimitiveType::Int)),
      candidate(@types.Type::Primitive(@types.PrimitiveType::Int)),
    ],
    @types.Type::Primitive(@types.PrimitiveType::Int),
  )
  debug_inspect(
    selected,
    content=(
      #|Ambiguous(
      #|  name="value",
      #|  candidates=[
      #|    { reference: Unresolved("candidate"), type_: Primitive(Int) },
      #|    { reference: Unresolved("candidate"), type_: Primitive(Int) },
      #|  ],
      #|)
    ),
  )
}
