(module
    ;; import table
    (import "js" "tbl" (table $tbl 4 anyfunc))
    ;; import functions
    (import "js" "increment" (func $increment (result i32)))
    (import "js" "decrement" (func $decrement (result i32)))
    (import "js" "wasm_increment" (func $wasm_increment (result i32)))
    (import "js" "wasm_decrement" (func $wasm_decrement (result i32)))
    ;; Table function type definitions all i32 and take no params.
    (type $returns_i32 (func (result i32)))

    ;; index into function table for the various functions
    (global $inc_ptr i32 (i32.const 0))
    (global $dec_ptr i32 (i32.const 1))
    (global $wasm_inc_ptr i32 (i32.const 2))
    (global $wasm_dec_ptr i32 (i32.const 3))

    ;; test performance of indirect table calls of js functions
    (func (export "js_table_test")
        (loop $inc_cycle
            (call_indirect (type $returns_i32) (global.get $inc_ptr))
            i32.const 4_000_000
            i32.le_u
            br_if $inc_cycle
        )

        (loop $dec_cycle
            (call_indirect (type $returns_i32) (global.get $dec_ptr))
            i32.const 4_000_000
            i32.le_u
            br_if $dec_cycle
        )
    )

    ;; test performance of direct call to JS functions
    (func (export "js_import_test")
        (loop $inc_cycle
            call $increment
            i32.const 4_000_000
            i32.le_u
            br_if $inc_cycle
        )

        (loop $dec_cycle
            call $decrement
            i32.const 4_000_000
            i32.le_u
            br_if $dec_cycle
        )
    )

    ;; Test performance of indirect table calls to WASM functions
    (func (export "wasm_table_test")
        (loop $inc_cycle
            (call_indirect (type $returns_i32) (global.get $wasm_inc_ptr))
            i32.const 4_000_000
            i32.le_u
            br_if $inc_cycle
        )

        (loop $dec_cycle
            (call_indirect (type $returns_i32) (global.get $wasm_dec_ptr))
            i32.const 4_000_000
            i32.le_u
            br_if $dec_cycle
        )
    )

    ;; Test performance of direct calls to WASM functions
    (func (export "wasm_import_test")
        (loop $inc_cycle
            call $wasm_increment
            i32.const 4_000_000
            i32.le_u
            br_if $inc_cycle
        )

        (loop $dec_cycle
            call $wasm_decrement
            i32.const 4_000_000
            i32.le_u
            br_if $dec_cycle
        )
    )
)