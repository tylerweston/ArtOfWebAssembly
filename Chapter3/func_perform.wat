(module
    ;; external call to a JS function
    (import "js" "external_call" (func $external_call (result i32)))
    (global $i (mut i32) (i32.const 0))     ;; create a global mutable variable i with initial value 0

    (func $internal_call (result i32)       ;; returns an i32 to calling function
        global.get $i
        i32.const 1
        i32.add
        global.set $i                       ;; i++
        global.get $i                       ;; return i by placing it on top of the stack
    )

    (func (export "wasm_call")
        (loop $again
            call $internal_call             ;; call $internal_call
            i32.const 4_000_000
            i32.le_u                        ;; check if we've called internal_call 4000000 times
            br_if $again
        )
    )

    (func (export "js_call")
        (loop $again
            (call $external_call)           ;; external function call
            i32.const 4_000_000
            i32.le_u
            br_if $again
        )
    )
)