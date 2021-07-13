(module
    (func (export "AddInt")                     ;; allow other files to access function AddInt
    (param $value_1 i32) (param $value_2 i32)   ;; accept two parameters passed into this function
    (result i32)
        local.get $value_1
        local.get $value_2
        i32.add
    )
)