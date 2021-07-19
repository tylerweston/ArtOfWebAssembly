(module
    ;; even_check(i32: n) -> i32: result, check if an i32 is even
    (func $even_check (param $n i32) (result i32)
        local.get $n
        i32.const 2
        i32.rem_u       ;; take the remainder of a division by 2    ;; u = unsigned?
        i32.const 0     ;; if that remainder is 0
        i32.eq          ;; $n % 2 == 0
    )

    ;; eq_2(i32: n) -> i32: result, check if a number is 2
    ;; overkill, but here as an example
    (func $eq_2 (param $n i32) (result i32)
        local.get $n
        i32.const 2
        i32.eq      ;; return 1 if n == 2
    )

    ;; multiple_check(i32: n, i32: m) -> i32: result
    (func $multiple_check (param $n i32) (param $m i32) (result i32)
        local.get $n
        local.get $m
        i32.rem_u       ;; get remainder of $n / $m
        i32.const 0     ;; Check if reamainder is 0
        i32.eq          ;; n % m == 0
    )

    ;; is_prime(i32: n) -> i32: result
    ;; (func $is_prime (export "is_prime") (param $n i32) (result i32)) ;; if we want to call is_prime internally as well
    (func (export "is_prime") (param $n i32) (result i32)
        (local $i i32)
        (if (i32.eq (local.get $n) (i32.const 1))
        (then
            i32.const 0     ;; 1 is not prime
            return
        ))
        (if (call $eq_2 (local.get $n))
            (then
                i32.const 1     ;; 2 is prime
                return
            )
        )

        (block $not_prime
            (call $even_check (local.get $n))
            br_if $not_prime    ;; even numbers are not prime

            (local.set $i (i32.const 1))

            (loop $prime_test_loop

                (local.tee $i (i32.add (local.get $i) (i32.const 2)))   ;; $i += 2
                local.get $n    ;; stack = [$n, $i]

                i32.ge_u        ;; $i >= $n
                if
                    i32.const 1 ;; i > n and we haven't broke, so n is prime
                    return
                end

                (call $multiple_check (local.get $n) (local.get $i))
                br_if $not_prime
                br $prime_test_loop
            )
        )
        i32.const 0 ;; not prime!
    )
)
