(module
    ;; imported JS functions
    (import "env" "str_pos_len" (func $str_pos_len (param i32 i32)))
    (import "env" "null_str" (func $null_str (param i32)))
    (import "env" "len_prefix" (func $len_prefix (param i32)))
    (import "env" "buffer" (memory 1))

    ;; null terminated
    (data (i32.const 0) "null-terminating string\00")
    (data (i32.const 128) "another null-terminating string\00")

    ;; we'll manually keep track of the length of these strings
    ;; 30 char string
    (data (i32.const 256) "Know the length of this string") ;; position is arbitrary
    ;; 35 char string
    (data (i32.const 384) "Also know the length of this string")

    ;; length-prefixed strings
    ;; 22 chars, 16 in hex
    (data (i32.const 512) "\16length-prefixed string")
    ;; 30 chars, 1e in hex
    (data (i32.const 640) "\1eanother length-prefixed string")

    (func (export "main")
        (;
        ;; null-terminated strings
        (call $null_str (i32.const 0))
        (call $null_str (i32.const 128))
        ;)

        ;; length of first string is 30 char
        (call $str_pos_len (i32.const 256) (i32.const 30))
        (call $str_pos_len (i32.const 384) (i32.const 35))

        (call $string_copy (i32.const 256) (i32.const 384) (i32.const 30))

        ;; wrong, since we copied our 30 char string there
        (call $str_pos_len (i32.const 384) (i32.const 35))
        ;; correct!
        (call $str_pos_len (i32.const 384) (i32.const 30))
        
        (;
        ;; length-prefixed strings
        (call $len_prefix (i32.const 512))
        (call $len_prefix (i32.const 640))
        ;)
    )

    ;; copy byte-by-byte
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
)