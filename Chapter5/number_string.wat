;; converting a string into numeric data
;; no built-in wasm function for this so we'll roll our own
;; js has built-ins for this

(module
    (import "env" "print_string" (func $print_string (param i32 i32)))
    (import "env" "buffer" (memory 1))

    (data (i32.const 128) "0123456789ABCDEF")   ;; hex data
    (data (i32.const 256) "               0")

    (global $bin_string_len i32 (i32.const 40))     ;; binary data
    (data (i32.const 512) " 0000 0000 0000 0000 0000 0000 0000 0000")

    (global $dec_string_len i32 (i32.const 16)) ;; decimal character count

    (global $hex_string_len i32 (i32.const 16)) ;; hex character count
    (data (i32.const 384) "            0x0")    ;; hex string data

    (func $set_bin_string (param $num i32) (param $string_len i32)
        (local $index i32)
        (local $loops_remaining i32)
        (local $nibble_bits i32)

        global.get $bin_string_len
        local.set $index
        
        i32.const 8 ;; 8 nibbles per i32
        local.set $loops_remaining

        (loop $bin_loop (block $outer_break
            local.get $index
            i32.eqz
            br_if $outer_break  ;; stop loops when $index == 0

            i32.const 4
            local.set $nibble_bits      ;; 4 bits per nibble

            (loop $nibble_loop (block $nibble_break
                local.get $index
                i32.const 1
                i32.sub
                local.set $index

                local.get $num
                i32.const 1
                i32.and     ;; true if last bit is 1, else 0
                if
                    local.get $index
                    i32.const 49            ;; ascii 49 = '1'
                    i32.store8 offset=512   ;; store 1 at 512 + index
                else
                    local.get $index
                    i32.const 48            ;; ascii 48 = '0'
                    i32.store8 offset=512   ;; store 0 at 512 + index
                end

                local.get $num
                i32.const 1
                i32.shr_u
                local.set $num

                local.get $nibble_bits
                i32.const 1
                i32.sub
                local.tee  $nibble_bits
                i32.eqz
                br_if $nibble_break ;; break when nibble_bits = 0
                br $nibble_loop
            ))  ;; end nibble_loop

            local.get $index
            i32.const 1
            i32.sub
            local.tee $index
            i32.const 32            ;; ascii space
            i32.store8 offset=512   ;; insert space between each nibble

            br $bin_loop
        ))  ;; end $bin_loop
    )

    (func $set_hex_string (param $num i32) (param $string_len i32)
    ;; and with 0xf to get last 4 bits, convert to hex, then shr by 4 bits
        (local $index       i32)
        (local $digit_char  i32)
        (local $digit_val   i32)
        (local $x_pos       i32)

        global.get $hex_string_len
        local.set $index    ;; set index to the number of hex characters

        (loop $digit_loop (block $break
            local.get $index
            i32.eqz
            br_if $break

            local.get $num
            i32.const 0xf   ;; last 4 bits set to 1
            i32.and         ;; offset into $digits is last 4 bits of num

            local.set $digit_val    ;; digit_val is last 4 bits
            local.get $num
            i32.eqz
            if
                local.get $x_pos
                i32.eqz
                if
                    local.get $index
                    local.set $x_pos
                else
                    i32.const 32
                    local.set $digit_char
                end
            else
                ;; load chars from 128 + $digit_val
                (i32.load8_u offset=128 (local.get $digit_val))
                local.set $digit_char
            end

            local.get $index
            i32.const 1
            i32.sub
            local.tee $index    ;; $index = $index - 1
            local.get $digit_char
            
            ;; store $digit_char at location 384 + $index
            i32.store8 offset=384
            local.get $num
            i32.const 4
            i32.shr_u   ;; shift 1 hex digit off $num
            local.set $num

            br $digit_loop
        ))

        local.get $x_pos
        i32.const 1
        i32.sub

        i32.const 120           ;; ascii x
        i32.store8 offset=384

        local.get $x_pos
        i32.const 2
        i32.sub

        i32.const 48            ;; ascii 0
        i32.store8 offset=384   ;; store 0x at front of string
    )

    (func $set_dec_string (param $num i32) (param $string_len i32)
        (local $index       i32)
        (local $digit_char  i32)
        (local $digit_val   i32)

        local.get $string_len
        local.set $index        ;; set index equal to string length

        local.get $num
        i32.eqz     ;; if num is 0, we want to return 0, not a bunch of empty space
        if
            local.get $index
            i32.const 1
            i32.sub
            local.set $index    ;; $index--

            (i32.store8 offset=256 (local.get $index) (i32.const 48))
        end

        (loop $digit_loop (block $break
            local.get $index
            i32.eqz
            br_if $break    ;; if index is 0, break out of our loop

            local.get $num
            i32.const 10
            i32.rem_u       ;; get digit in 1 place

            local.set $digit_val
            local.get $num
            i32.eqz
            if                          ;; if we're equal to zero, pad with spaces
                i32.const 32
                local.set $digit_char   ;; 32 is space, left pad spaces
            else
                (i32.load8_u offset=128 (local.get $digit_val))
                local.set $digit_char   ;; set digit_char to appropriate ascii digit
            end

            local.get $index
            i32.const 1
            i32.sub
            local.set $index
            ;; store ascii digit in 256 + $index
            (i32.store8 offset=256 (local.get $index) (local.get $digit_char))

            local.get $num
            i32.const 10
            i32.div_u
            local.set $num  ;; remove last digit, divide by 10
            br $digit_loop  ;; loop
        ))  ;; end of $block and $loop
    )

    (func (export "to_string") (param $num i32)
        (call $set_dec_string (local.get $num) (global.get $dec_string_len))
        (call $print_string (i32.const 256) (global.get $dec_string_len))
        (call $set_hex_string (local.get $num) (global.get $hex_string_len))
        (call $print_string (i32.const 384) (global.get $hex_string_len))
        (call $set_bin_string (local.get $num) (global.get $bin_string_len))
        (call $print_string (i32.const 512) (global.get $bin_string_len))
    )
)