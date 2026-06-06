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
  assert_true(
    selected
    is Selection::Selected(
      { type_: @types.Type::Primitive(@types.PrimitiveType::Int), .. }
    ),
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
  assert_true(selected is Selection::Ambiguous(candidates=[_, _], ..))
}

///|
test "select callable candidate by argument types" {
  let selected = select_by_call_arguments(
    "op_add",
    [
      candidate(
        @types.Type::Function(
          [
            @types.Type::Primitive(@types.PrimitiveType::Bool),
            @types.Type::Primitive(@types.PrimitiveType::Bool),
          ],
          @types.Type::Primitive(@types.PrimitiveType::Bool),
        ),
      ),
      candidate(
        @types.Type::Function(
          [
            @types.Type::Primitive(@types.PrimitiveType::Int),
            @types.Type::Primitive(@types.PrimitiveType::Int),
          ],
          @types.Type::Primitive(@types.PrimitiveType::Int),
        ),
      ),
    ],
    [
      @types.Type::Primitive(@types.PrimitiveType::Int),
      @types.Type::Primitive(@types.PrimitiveType::Int),
    ],
  )
  assert_true(
    selected
    is CallableSelection::Selected(
      { result: @types.Type::Primitive(@types.PrimitiveType::Int), .. }
    ),
  )
}
