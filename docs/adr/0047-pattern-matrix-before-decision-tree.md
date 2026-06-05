# Pattern matrix before decision tree

Lane2 keeps checked patterns in typed core, uses a pattern matrix as the semantic model for exhaustiveness and usefulness checking, and reserves decision trees for lowered execution IR or bytecode VM work. This follows the standard pattern-compilation architecture used by ML-family compilers: source-facing checked patterns remain diagnosable while later lowering can compile the matrix into efficient tests and branches.
