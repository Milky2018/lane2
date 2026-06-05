# ANF typed core IR

Lane2 uses structured administrative normal form for its typed core IR rather than making CPS or basic-block CFG the first core representation. Structured ANF keeps `if` and `match` as structured nodes while requiring non-trivial computations to be named, which matches Lane2's strict evaluation model, keeps diagnostics and the reference interpreter close to source semantics, and lowers naturally to locals plus instructions for a future bytecode VM. CPS and CFG remain possible later lowerings for effects, handlers, or VM control-flow implementation.
