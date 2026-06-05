# Typed core top-level shape

Lane2 typed core represents a checked program as nominal type definitions, typed function definitions, typed value definitions, and preopen exposure metadata rather than preserving source-shaped top-level `open` or anonymous `let` declarations. Top-level `open` and ordered value scope are semantic-front-end rules; anonymous top-level values contribute checked preopen exposures instead of remaining anonymous runtime bindings.
