(module
    ;; import three different types of variables
    (global $import_integer_32  (import "env" "import_i32") i32)
    (global $import_float_32    (import "env" "import_f32") f32)
    (global $import_float_64    (import "env" "import_f64") f64)

    ;; import three functions that each take a different type of parameter
    (import "js" "log_i32"  (func $log_i32 (param i32)))
    (import "js" "log_f32"  (func $log_f32 (param f32)))
    (import "js" "log_f64"  (func $log_f64 (param f64)))

    ;; our function that we'll execute, call each of the functions we've imported with our global variables
    (func (export "globaltest")
        (call $log_i32 (global.get $import_integer_32))
        (call $log_f32 (global.get $import_float_32))
        (call $log_f64 (global.get $import_float_64))
    )
)