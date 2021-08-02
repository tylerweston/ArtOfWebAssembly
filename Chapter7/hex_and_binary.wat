(module
    (import "env" "buffer" (memory 1))

    ;; hex digits
    (global $digit_ptr i32 (i32.const 128))
    (data (i32.const 128) "0123456789ABCDEF")
    ;; decimal string ptr, length, and data section
    (global $dec_string_ptr i32 (i32.const 256))
    (global $dec_string_len i32 (i32.const 16))
    (data (i32.const 256) "               0")
    ;; hex string ptr, length, and data section
    (global $hex_string_ptr i32 (i32.const 384))
    (global $hex_string_len i32 (i32.const 16))
    (data (i32.const 384) "            0x0")
    ;; binary string ptr, length, and data section
    (global $bin_string_ptr i32 (i32.const 512))
    (global $bin_string_len i32 (i32.const 40))
    (data (i32.const 512) " 0000 0000 0000 0000 0000 0000 0000 0000")
    ;; h1 open tag string pointer, length, data section
    (global $h1_open_ptr i32 (i32.const 640))
    (global $h1_open_len i32 (i32.const 4))
    (data (i32.const 640) "<H1>")
    ;; h1 close tag string pointer, length, data section
    (global $h1_close_ptr i32 (i32.const 656))
    (global $h1_close_len i32 (i32.const 5))
    (data (i32.const 656) "</H1>")
    ;; h4 open tag string pointer, length, data section
    (global $h4_open_ptr i32 (i32.const 672))
    (global $h4_open_len i32 (i32.const 4))
    (data (i32.const 672) "<H4>")
    ;; h4 close tag string pointer, length, and data section
    (global $h4_close_ptr i32 (i32.const 688))
    (global $h4_close_len i32 (i32.const 5))
    (data (i32.const 688) "</H4>")
    ;; output string length and data section
    (global $out_str_ptr i32 (i32.const 1024))
    (global $out_str_len (mut i32) (i32.const 0))

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

    (func $byte_copy
        (param $source i32) (param $dest i32) (param $len i32)
        (local $last_source_byte i32)

        local.get $source
        local.get $len
        i32.add

        local.set $last_source_byte ;; $last_source_byte = $source + $len

        (loop $copy_loop (block $break
            local.get $dest                     ;; push $dest on stack for use by store8 call
            (i32.load8_u (local.get $source))   ;; load a single byte from source
            i32.store8                          ;; store the single byte on top of stack to location at $dest

            local.get $dest
            i32.const 1
            i32.add
            local.set $dest                     ;; $dest++

            local.get $source
            i32.const 1
            i32.add
            ;; tee will store a value and also push it to the stack
            local.tee $source                   ;; $source++

            local.get $last_source_byte
            i32.eq
            br_if $break
            br $copy_loop
        ))  ;; end copy_loop
    )

    ;; copy 8 bytes at a time
    (func $byte_copy_i64
        (param $source i32) (param $dest i32) (param $len i32)
        (local $last_source_byte i32)

        local.get $source
        local.get $len
        i32.add
        local.set $last_source_byte     ;; $last_source_byte = $source + $len

        (loop $copy_loop (block $break
            (i64.store (local.get $dest) (i64.load (local.get $source)))

            local.get $dest
            i32.const 8
            i32.add
            local.set $dest     ;; $dest = dest + 8

            local.get $source
            i32.const 8
            i32.add
            local.tee $source   ;; source = source + 8

            local.get $last_source_byte
            i32.ge_u
            br_if $break
            br $copy_loop
        ))  ;; end $copy_loop
    )

    ;; combined 8 byte and single byte copy
    (func $string_copy
        (param $source i32) (param $dest i32) (param $len i32)
        (local $start_source_byte   i32)
        (local $start_dest_byte     i32)
        (local $singles             i32)
        (local $len_less_singles    i32)

        local.get $len
        local.set $len_less_singles

        local.get $len
        i32.const 7             ;; 0111 in binary
        i32.and
        local.tee $singles      ;; set singles to last 3 bits of length

        ;; so we need to check what bytes will be left if we copy a group of 8 bytes
        ;; at a time. First copy the remaining individual bytes.
        if                      ;; if the last 3 bits of len is not 0
            local.get $len
            local.get $singles
            i32.sub
            local.tee $len_less_singles

            local.get $source
            i32.add
            ;;start_source_bytes = source + len_less_singles
            local.set $start_source_byte

            local.get $len_less_singles
            local.get $dest
            i32.add
            local.set $start_dest_byte

            (call $byte_copy (local.get $start_source_byte)
            (local.get $start_dest_byte)(local.get $singles))
        end

        ;; copy leftover bytes in a group of 8
        local.get $len
        i32.const 0xff_ff_ff_f8 ;;all bits 1 except for last 3, which are 0
        i32.and
        local.set $len
        (call $byte_copy_i64 (local.get $source) (local.get $dest) (local.get $len))
    )

    ;; append source string to output string
    (func $append_out (param $source i32) (param $len i32)
        (call $string_copy
            (local.get $source)
            (i32.add
                (global.get $out_str_ptr)
                (global.get $out_str_len)
            )
            (local.get $len)
        )    
        ;; add length to output string length
        global.get $out_str_len
        local.get $len
        i32.add
        global.set $out_str_len
    )

    (func (export "setOutput") (param $num i32) (result i32)
        ;; create decimal string from $num value
        (call $set_dec_string (local.get $num) (global.get $dec_string_len))
        ;; create hex string
        (call $set_hex_string (local.get $num) (global.get $hex_string_len))
        ;; create bin string
        (call $set_bin_string (local.get $num) (global.get $bin_string_len))

        i32.const 0
        global.set $out_str_len

        ;; append <h1>${decimal_string}</h1> to output string
        (call $append_out (global.get $h1_open_ptr) (global.get $h1_open_len))
        (call $append_out (global.get $dec_string_ptr) (global.get $dec_string_len))
        (call $append_out (global.get $h1_close_ptr) (global.get $h1_close_len))

        ;; append hex number
        (call $append_out (global.get $h4_open_ptr) (global.get $h4_open_len))
        (call $append_out (global.get $hex_string_ptr) (global.get $hex_string_len))
        (call $append_out (global.get $h4_close_ptr) (global.get $h4_close_len))
    
        ;; append bin number
        (call $append_out (global.get $h4_open_ptr) (global.get $h4_open_len))
        (call $append_out (global.get $bin_string_ptr) (global.get $bin_string_len))
        (call $append_out (global.get $h4_close_ptr) (global.get $h4_close_len))

        ;; return output string length
        global.get $out_str_len
    )
)