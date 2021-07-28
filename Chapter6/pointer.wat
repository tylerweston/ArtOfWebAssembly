(module
    (memory 1)
    (global $pointer i32 (i32.const 128))
    (func $init
        (i32.store
        (global.get $pointer)   ;; store at address $pointer
        (i32.const 99)          ;; store value of 99
        )   
    )
    (func (export "get_ptr") (result i32)
    (i32.load (global.get $pointer))    ;; return value at location $pointer
    )
    (start $init)               ;; start declares a function to be the intialization function for a module
    ;; start $init means $init will run automatically when the module is instantiated
)