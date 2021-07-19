(module
    ;; js increment function
    (import "js" "increment" (func $js_increment (result i32)))
    ;; js decrement functin
    (import "js" "decrement" (func $js_decrement (result i32)))

    (table $tbl (export "tbl") 4 anyfunc)       ;; exported table with 4 functions

    (global $i (mut i32) (i32.const 0))

    (func $increment (export "increment") (result i32)
        (global.set $i (i32.add (global.get $i) (i32.const 1))) ;; $i++
        global.get $i       ;; return i
    )

    (func $decrement (export "decrement") (result i32)
        (global.set $i (i32.sub (global.get $i) (i32.const 1))) ;; $i--
        global.get $i
    )

    (; populate the table
    take the index of first element to set, since we are filling table, use i32.const 0
    we could do something like
    (elem (i32.const 0) $js_increment $js_decrement)
    (elem (i32.const 2) $increment $decrement)
    to set first couple elements, then the last couple elements
    ;) 
    (elem (i32.const 0) $js_increment $js_decrement $increment $decrement)
)