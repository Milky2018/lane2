# Typed core top-level shape

Lane2 typed core represents a checked program as nominal type definitions, typed function definitions, typed value definitions, and open exposure metadata rather than preserving source-shaped `open` declarations or open bindings. Top-level `open`, `let open`, preopen, and ordered value scope are semantic-front-end rules. Prelude-provided open bindings contribute checked preopen exposures before user code is checked, and user-defined open bindings contribute checked open exposures from their declaration point forward.
