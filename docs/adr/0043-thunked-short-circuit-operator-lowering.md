# Thunked short-circuit operator lowering

Lane2 typed core lowers `&&` and `||` to calls of the resolved `And::and` or `Or::or` operation with the right operand wrapped as a zero-argument thunk. These operators do not lower directly to `if` in typed core, because local `open` and preopen operation resolution must determine the actual operation value; the default prelude's boolean operations may themselves be implemented with ordinary `if`.
