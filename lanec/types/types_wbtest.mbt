///|
fn type_id(index : Int) -> TypeSymbolId {
  { index, }
}

///|
fn tparam_id(index : Int) -> TypeParameterId {
  { index, }
}

///|
fn tparam(index : Int, name : String) -> TypeParameter {
  { id: tparam_id(index), name, kind: Type }
}

///|
test "pretty prints checked type objects" {
  let option = type_id(0)
  let a = tparam(0, "A")
  let type_ = Forall(
    [a],
    Function(
      [Nominal(option, [Parameter(a.id)]), Primitive(Int)],
      Parameter(a.id),
    ),
  )
  inspect(
    @prettyprinter.render(type_),
    content=(
      #|forall [tparam#0 A : Type]. (type#0[tparam#0], Int) -> tparam#0
    ),
  )
}

///|
test "substitutes free type parameters but not forall-bound parameters" {
  let a = tparam(0, "A")
  let b = tparam(1, "B")
  let substitution = TypeSubstitution::single(a.id, Primitive(Int))
  let free = Function([Parameter(a.id)], Parameter(b.id))
  let bound = Forall([a], Function([Parameter(a.id)], Parameter(b.id)))
  inspect(
    @prettyprinter.render(free.substitute(substitution)),
    content="(Int) -> tparam#1",
  )
  inspect(
    @prettyprinter.render(bound.substitute(substitution)),
    content="forall [tparam#0 A : Type]. (tparam#0) -> tparam#1",
  )
}

///|
test "forall equality is alpha-equivalent" {
  let a = tparam(0, "A")
  let b = tparam(1, "B")
  let left = Forall([a], Function([Parameter(a.id)], Parameter(a.id)))
  let right = Forall([b], Function([Parameter(b.id)], Parameter(b.id)))
  let free_mismatch = Forall([a], Function([Parameter(a.id)], Parameter(b.id)))
  assert_true(left.alpha_equal(right))
  assert_true(left == right)
  assert_false(left.alpha_equal(free_mismatch))
  assert_false(left == free_mismatch)
}
