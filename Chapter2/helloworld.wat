(module
    ;; Module code goes here

    (;
    Block comment, similar to /* */ in other languages
    ;)
    (import "env" "print_string" (func $print_string( param i32 ))) ;; expect an import object, env, from the embedded environment
    ;; that will have a print_string function attached to it. It will take a single integer parameter.
    (import "env" "buffer" (memory 1))  ;; import something named buffer from env that has a size of 1 memory page, a page is 64kb 
    (global $start_string (import "env" "start_string") i32)    ;; like a pointer, an index into our linear memory page
    (global $string_len i32 (i32.const 12)) ;; a constant string_len variable with value of 12
    (data (global.get $start_string) "hello world!")    ;; define our string in memory
    (func (export "helloworld") ;; declare our function as helloworld for use in javascript
        (call $print_string (global.get $string_len))
    )
)