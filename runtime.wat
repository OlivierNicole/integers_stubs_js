(module
   (import "env" "Int64_val" (func $Int64_val (param (ref eq)) (result i64)))
   (import "env" "caml_copy_int64"
      (func $caml_copy_int64 (param i64) (result (ref eq))))
   (import "env" "caml_int64_format"
      (func $caml_int64_format
         (param (ref eq)) (param (ref eq)) (result (ref eq))))
   (import "fail" "caml_failwith" (func $caml_failwith (param (ref eq))))

   (type $string (array (mut i8)))

   (func $caml_int64_sub
      (param $x (ref eq)) (param $y (ref eq)) (result (ref eq))
      (call $caml_copy_int64
         (i64.sub (call $Int64_val (local.get $x))
                  (call $Int64_val (local.get $y)))))

   (func (export "integers_uint64_sub")
      (param $x (ref eq)) (param $y (ref eq)) (result (ref eq))
      (call $caml_int64_sub (local.get $x) (local.get $y)))

   (global $UNSIGNED_FORMAT (ref $string)
      (array.new_fixed $string 2 ;; "%u"
         (i32.const 37) (i32.const 117)))

   (func $integers_uint64_to_string
      (param $i (ref eq)) (result (ref eq))
      ;; Resort to caml_int64_format, which we know will work even on
      ;; arguments greater than Int64.max_int.
      (call $caml_int64_format (global.get $UNSIGNED_FORMAT) (local.get $i)))

   (global $INT_OF_STRING_ERRMSG (ref $string)
      (array.new_fixed $string 13 ;; "int_of_string"
         (i32.const 0x69) (i32.const 0x6e) (i32.const 0x74) (i32.const 0x5f)
         (i32.const 0x6f) (i32.const 0x66) (i32.const 0x5f) (i32.const 0x73)
         (i32.const 0x74) (i32.const 0x72) (i32.const 0x69) (i32.const 0x6e)
         (i32.const 0x67)))


   (func integers_uint_of_string
      (param $s (ref $string)) (param $max_val i64)
      (local $i i32) (local $len i32)
      (local $negative i32) (local $no_digits i32) ;; booleans
      (local $c i32) (local $max_base_10 i64) (local $res i64)
      (local.set $i (i32.const 0))
      (local.set $len (array.len (local.get $s)))
      (local.set $c (i32.const 0)) ;; false
      (if (i32.eqz (local.get $len))
         (then (call $caml_failwith (global.get $INT_OF_STRING_ERRMSG))))
      (local.set $c (array.get_u $string (local.get $s) (local.get $i)))
      (if (i32.eq (local.get $c) (i32.const 45)) ;; Minus sign '-'
         (then
            (local.set $i (i32.add (local.get $i) (i32.const 1)))
            (local.set $negative (i32.const 1)))) ;; true
      (else
         (if (i32.eq $c (i32.const 43)) ;; Plus sign '+'
            (local.set $i (i32.add (local.get $i) (i32.const 1)))))
      (local.set $no_digits (i32.const 1)) ;; true
      (local.set $max_base_10 (i64.div_u (local.get $max_val) (i64.const 10)))
      (local.set $res (i64.const 0))
      (loop $loop
         (if (i32.lt_u (local.get $i) (local.get $len))
           (then
              (br $loop)))))
)
