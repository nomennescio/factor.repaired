namespace factor
{

#define DECLARE_PRIMITIVE(name) VM_C_API void primitive_##name(factor_vm *parent);

/* Generated with PRIMITIVE in primitives.cpp */
DECLARE_PRIMITIVE(alien_address)
DECLARE_PRIMITIVE(all_instances)
DECLARE_PRIMITIVE(array)
DECLARE_PRIMITIVE(array_to_quotation)
DECLARE_PRIMITIVE(become)
DECLARE_PRIMITIVE(bignum_add)
DECLARE_PRIMITIVE(bignum_and)
DECLARE_PRIMITIVE(bignum_bitp)
DECLARE_PRIMITIVE(bignum_divint)
DECLARE_PRIMITIVE(bignum_divmod)
DECLARE_PRIMITIVE(bignum_eq)
DECLARE_PRIMITIVE(bignum_greater)
DECLARE_PRIMITIVE(bignum_greatereq)
DECLARE_PRIMITIVE(bignum_less)
DECLARE_PRIMITIVE(bignum_lesseq)
DECLARE_PRIMITIVE(bignum_log2)
DECLARE_PRIMITIVE(bignum_mod)
DECLARE_PRIMITIVE(bignum_multiply)
DECLARE_PRIMITIVE(bignum_not)
DECLARE_PRIMITIVE(bignum_or)
DECLARE_PRIMITIVE(bignum_shift)
DECLARE_PRIMITIVE(bignum_subtract)
DECLARE_PRIMITIVE(bignum_to_fixnum)
DECLARE_PRIMITIVE(bignum_to_float)
DECLARE_PRIMITIVE(bignum_xor)
DECLARE_PRIMITIVE(bits_double)
DECLARE_PRIMITIVE(bits_float)
DECLARE_PRIMITIVE(byte_array)
DECLARE_PRIMITIVE(byte_array_to_bignum)
DECLARE_PRIMITIVE(call_clear)
DECLARE_PRIMITIVE(callback)
DECLARE_PRIMITIVE(callstack)
DECLARE_PRIMITIVE(callstack_to_array)
DECLARE_PRIMITIVE(check_datastack)
DECLARE_PRIMITIVE(clone)
DECLARE_PRIMITIVE(code_blocks)
DECLARE_PRIMITIVE(code_room)
DECLARE_PRIMITIVE(compact_gc)
DECLARE_PRIMITIVE(compute_identity_hashcode)
DECLARE_PRIMITIVE(data_room)
DECLARE_PRIMITIVE(datastack)
DECLARE_PRIMITIVE(die)
DECLARE_PRIMITIVE(disable_gc_events)
DECLARE_PRIMITIVE(dispatch_stats)
DECLARE_PRIMITIVE(displaced_alien)
DECLARE_PRIMITIVE(dlclose)
DECLARE_PRIMITIVE(dll_validp)
DECLARE_PRIMITIVE(dlopen)
DECLARE_PRIMITIVE(dlsym)
DECLARE_PRIMITIVE(double_bits)
DECLARE_PRIMITIVE(enable_gc_events)
DECLARE_PRIMITIVE(existsp)
DECLARE_PRIMITIVE(exit)
DECLARE_PRIMITIVE(fclose)
DECLARE_PRIMITIVE(fflush)
DECLARE_PRIMITIVE(fgetc)
DECLARE_PRIMITIVE(fixnum_divint)
DECLARE_PRIMITIVE(fixnum_divmod)
DECLARE_PRIMITIVE(fixnum_shift)
DECLARE_PRIMITIVE(fixnum_to_bignum)
DECLARE_PRIMITIVE(fixnum_to_float)
DECLARE_PRIMITIVE(float_add)
DECLARE_PRIMITIVE(float_bits)
DECLARE_PRIMITIVE(float_divfloat)
DECLARE_PRIMITIVE(float_eq)
DECLARE_PRIMITIVE(float_greater)
DECLARE_PRIMITIVE(float_greatereq)
DECLARE_PRIMITIVE(float_less)
DECLARE_PRIMITIVE(float_lesseq)
DECLARE_PRIMITIVE(float_mod)
DECLARE_PRIMITIVE(float_multiply)
DECLARE_PRIMITIVE(float_subtract)
DECLARE_PRIMITIVE(float_to_bignum)
DECLARE_PRIMITIVE(float_to_fixnum)
DECLARE_PRIMITIVE(float_to_str)
DECLARE_PRIMITIVE(fopen)
DECLARE_PRIMITIVE(fputc)
DECLARE_PRIMITIVE(fread)
DECLARE_PRIMITIVE(fseek)
DECLARE_PRIMITIVE(ftell)
DECLARE_PRIMITIVE(full_gc)
DECLARE_PRIMITIVE(fwrite)
DECLARE_PRIMITIVE(identity_hashcode)
DECLARE_PRIMITIVE(innermost_stack_frame_executing)
DECLARE_PRIMITIVE(innermost_stack_frame_scan)
DECLARE_PRIMITIVE(jit_compile)
DECLARE_PRIMITIVE(load_locals)
DECLARE_PRIMITIVE(lookup_method)
DECLARE_PRIMITIVE(mega_cache_miss)
DECLARE_PRIMITIVE(minor_gc)
DECLARE_PRIMITIVE(modify_code_heap)
DECLARE_PRIMITIVE(nano_count)
DECLARE_PRIMITIVE(optimized_p)
DECLARE_PRIMITIVE(profiling)
DECLARE_PRIMITIVE(quot_compiled_p)
DECLARE_PRIMITIVE(quotation_code)
DECLARE_PRIMITIVE(reset_dispatch_stats)
DECLARE_PRIMITIVE(resize_array)
DECLARE_PRIMITIVE(resize_byte_array)
DECLARE_PRIMITIVE(resize_string)
DECLARE_PRIMITIVE(retainstack)
DECLARE_PRIMITIVE(save_image)
DECLARE_PRIMITIVE(save_image_and_exit)
DECLARE_PRIMITIVE(set_datastack)
DECLARE_PRIMITIVE(set_innermost_stack_frame_quot)
DECLARE_PRIMITIVE(set_retainstack)
DECLARE_PRIMITIVE(set_slot)
DECLARE_PRIMITIVE(set_special_object)
DECLARE_PRIMITIVE(set_string_nth_fast)
DECLARE_PRIMITIVE(set_string_nth_slow)
DECLARE_PRIMITIVE(size)
DECLARE_PRIMITIVE(sleep)
DECLARE_PRIMITIVE(special_object)
DECLARE_PRIMITIVE(string)
DECLARE_PRIMITIVE(string_nth)
DECLARE_PRIMITIVE(strip_stack_traces)
DECLARE_PRIMITIVE(system_micros)
DECLARE_PRIMITIVE(tuple)
DECLARE_PRIMITIVE(tuple_boa)
DECLARE_PRIMITIVE(unimplemented)
DECLARE_PRIMITIVE(uninitialized_byte_array)
DECLARE_PRIMITIVE(word)
DECLARE_PRIMITIVE(word_code)
DECLARE_PRIMITIVE(wrapper)

/* These are generated with macros in alien.cpp, and not with PRIMIIVE in
primitives.cpp */
DECLARE_PRIMITIVE(alien_signed_cell)
DECLARE_PRIMITIVE(set_alien_signed_cell)
DECLARE_PRIMITIVE(alien_unsigned_cell)
DECLARE_PRIMITIVE(set_alien_unsigned_cell)
DECLARE_PRIMITIVE(alien_signed_8)
DECLARE_PRIMITIVE(set_alien_signed_8)
DECLARE_PRIMITIVE(alien_unsigned_8)
DECLARE_PRIMITIVE(set_alien_unsigned_8)
DECLARE_PRIMITIVE(alien_signed_4)
DECLARE_PRIMITIVE(set_alien_signed_4)
DECLARE_PRIMITIVE(alien_unsigned_4)
DECLARE_PRIMITIVE(set_alien_unsigned_4)
DECLARE_PRIMITIVE(alien_signed_2)
DECLARE_PRIMITIVE(set_alien_signed_2)
DECLARE_PRIMITIVE(alien_unsigned_2)
DECLARE_PRIMITIVE(set_alien_unsigned_2)
DECLARE_PRIMITIVE(alien_signed_1)
DECLARE_PRIMITIVE(set_alien_signed_1)
DECLARE_PRIMITIVE(alien_unsigned_1)
DECLARE_PRIMITIVE(set_alien_unsigned_1)
DECLARE_PRIMITIVE(alien_float)
DECLARE_PRIMITIVE(set_alien_float)
DECLARE_PRIMITIVE(alien_double)
DECLARE_PRIMITIVE(set_alien_double)
DECLARE_PRIMITIVE(alien_cell)
DECLARE_PRIMITIVE(set_alien_cell)

}
