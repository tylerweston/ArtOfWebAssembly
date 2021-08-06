(module
    (func (export "pow2_mul")
        (param $p1 i32)
        (param $p2 i32)
        (result i32)
        local.get $p1
        i32.const 16
        i32.mul
        local.get $p2
        i32.const 8
        i32.div_u
        i32.add
    )
)