#include "master.hpp"

namespace factor
{

PRIMITIVE_FORWARD(bignum_to_fixnum)
PRIMITIVE_FORWARD(float_to_fixnum)
PRIMITIVE_FORWARD(fixnum_to_bignum)
PRIMITIVE_FORWARD(float_to_bignum)
PRIMITIVE_FORWARD(fixnum_to_float)
PRIMITIVE_FORWARD(bignum_to_float)
PRIMITIVE_FORWARD(str_to_float)
PRIMITIVE_FORWARD(float_to_str)
PRIMITIVE_FORWARD(float_bits)
PRIMITIVE_FORWARD(double_bits)
PRIMITIVE_FORWARD(bits_float)
PRIMITIVE_FORWARD(bits_double)
PRIMITIVE_FORWARD(fixnum_divint)
PRIMITIVE_FORWARD(fixnum_divmod)
PRIMITIVE_FORWARD(fixnum_shift)
PRIMITIVE_FORWARD(bignum_eq)
PRIMITIVE_FORWARD(bignum_add)
PRIMITIVE_FORWARD(bignum_subtract)
PRIMITIVE_FORWARD(bignum_multiply)
PRIMITIVE_FORWARD(bignum_divint)
PRIMITIVE_FORWARD(bignum_mod)
PRIMITIVE_FORWARD(bignum_divmod)
PRIMITIVE_FORWARD(bignum_and)
PRIMITIVE_FORWARD(bignum_or)
PRIMITIVE_FORWARD(bignum_xor)
PRIMITIVE_FORWARD(bignum_not)
PRIMITIVE_FORWARD(bignum_shift)
PRIMITIVE_FORWARD(bignum_less)
PRIMITIVE_FORWARD(bignum_lesseq)
PRIMITIVE_FORWARD(bignum_greater)
PRIMITIVE_FORWARD(bignum_greatereq)
PRIMITIVE_FORWARD(bignum_bitp)
PRIMITIVE_FORWARD(bignum_log2)
PRIMITIVE_FORWARD(byte_array_to_bignum)
PRIMITIVE_FORWARD(float_eq)
PRIMITIVE_FORWARD(float_add)
PRIMITIVE_FORWARD(float_subtract)
PRIMITIVE_FORWARD(float_multiply)
PRIMITIVE_FORWARD(float_divfloat)
PRIMITIVE_FORWARD(float_mod)
PRIMITIVE_FORWARD(float_less)
PRIMITIVE_FORWARD(float_lesseq)
PRIMITIVE_FORWARD(float_greater)
PRIMITIVE_FORWARD(float_greatereq)
PRIMITIVE_FORWARD(word)
PRIMITIVE_FORWARD(word_code)
PRIMITIVE_FORWARD(special_object)
PRIMITIVE_FORWARD(set_special_object)
PRIMITIVE_FORWARD(existsp)
PRIMITIVE_FORWARD(minor_gc)
PRIMITIVE_FORWARD(full_gc)
PRIMITIVE_FORWARD(compact_gc)
PRIMITIVE_FORWARD(save_image)
PRIMITIVE_FORWARD(save_image_and_exit)
PRIMITIVE_FORWARD(datastack)
PRIMITIVE_FORWARD(retainstack)
PRIMITIVE_FORWARD(callstack)
PRIMITIVE_FORWARD(set_datastack)
PRIMITIVE_FORWARD(set_retainstack)
PRIMITIVE_FORWARD(exit)
PRIMITIVE_FORWARD(data_room)
PRIMITIVE_FORWARD(code_room)
PRIMITIVE_FORWARD(system_micros)
PRIMITIVE_FORWARD(nano_count)
PRIMITIVE_FORWARD(modify_code_heap)
PRIMITIVE_FORWARD(dlopen)
PRIMITIVE_FORWARD(dlsym)
PRIMITIVE_FORWARD(dlclose)
PRIMITIVE_FORWARD(byte_array)
PRIMITIVE_FORWARD(uninitialized_byte_array)
PRIMITIVE_FORWARD(displaced_alien)
PRIMITIVE_FORWARD(alien_address)
PRIMITIVE_FORWARD(set_slot)
PRIMITIVE_FORWARD(string_nth)
PRIMITIVE_FORWARD(set_string_nth_fast)
PRIMITIVE_FORWARD(set_string_nth_slow)
PRIMITIVE_FORWARD(resize_array)
PRIMITIVE_FORWARD(resize_string)
PRIMITIVE_FORWARD(array)
PRIMITIVE_FORWARD(all_instances)
PRIMITIVE_FORWARD(size)
PRIMITIVE_FORWARD(die)
PRIMITIVE_FORWARD(fopen)
PRIMITIVE_FORWARD(fgetc)
PRIMITIVE_FORWARD(fread)
PRIMITIVE_FORWARD(fputc)
PRIMITIVE_FORWARD(fwrite)
PRIMITIVE_FORWARD(fflush)
PRIMITIVE_FORWARD(ftell)
PRIMITIVE_FORWARD(fseek)
PRIMITIVE_FORWARD(fclose)
PRIMITIVE_FORWARD(wrapper)
PRIMITIVE_FORWARD(clone)
PRIMITIVE_FORWARD(string)
PRIMITIVE_FORWARD(array_to_quotation)
PRIMITIVE_FORWARD(quotation_code)
PRIMITIVE_FORWARD(tuple)
PRIMITIVE_FORWARD(profiling)
PRIMITIVE_FORWARD(become)
PRIMITIVE_FORWARD(sleep)
PRIMITIVE_FORWARD(tuple_boa)
PRIMITIVE_FORWARD(callstack_to_array)
PRIMITIVE_FORWARD(innermost_stack_frame_executing)
PRIMITIVE_FORWARD(innermost_stack_frame_scan)
PRIMITIVE_FORWARD(set_innermost_stack_frame_quot)
PRIMITIVE_FORWARD(call_clear)
PRIMITIVE_FORWARD(resize_byte_array)
PRIMITIVE_FORWARD(dll_validp)
PRIMITIVE_FORWARD(unimplemented)
PRIMITIVE_FORWARD(jit_compile)
PRIMITIVE_FORWARD(load_locals)
PRIMITIVE_FORWARD(check_datastack)
PRIMITIVE_FORWARD(mega_cache_miss)
PRIMITIVE_FORWARD(lookup_method)
PRIMITIVE_FORWARD(reset_dispatch_stats)
PRIMITIVE_FORWARD(dispatch_stats)
PRIMITIVE_FORWARD(optimized_p)
PRIMITIVE_FORWARD(quot_compiled_p)
PRIMITIVE_FORWARD(vm_ptr)
PRIMITIVE_FORWARD(strip_stack_traces)
PRIMITIVE_FORWARD(callback)
PRIMITIVE_FORWARD(enable_gc_events)
PRIMITIVE_FORWARD(disable_gc_events)
PRIMITIVE_FORWARD(identity_hashcode)
PRIMITIVE_FORWARD(compute_identity_hashcode)

const primitive_type primitives[] = {
	primitive_bignum_to_fixnum,
	primitive_float_to_fixnum,
	primitive_fixnum_to_bignum,
	primitive_float_to_bignum,
	primitive_fixnum_to_float,
	primitive_bignum_to_float,
	primitive_str_to_float,
	primitive_float_to_str,
	primitive_float_bits,
	primitive_double_bits,
	primitive_bits_float,
	primitive_bits_double,
	primitive_fixnum_divint,
	primitive_fixnum_divmod,
	primitive_fixnum_shift,
	primitive_bignum_eq,
	primitive_bignum_add,
	primitive_bignum_subtract,
	primitive_bignum_multiply,
	primitive_bignum_divint,
	primitive_bignum_mod,
	primitive_bignum_divmod,
	primitive_bignum_and,
	primitive_bignum_or,
	primitive_bignum_xor,
	primitive_bignum_not,
	primitive_bignum_shift,
	primitive_bignum_less,
	primitive_bignum_lesseq,
	primitive_bignum_greater,
	primitive_bignum_greatereq,
	primitive_bignum_bitp,
	primitive_bignum_log2,
	primitive_byte_array_to_bignum,
	primitive_float_eq,
	primitive_float_add,
	primitive_float_subtract,
	primitive_float_multiply,
	primitive_float_divfloat,
	primitive_float_mod,
	primitive_float_less,
	primitive_float_lesseq,
	primitive_float_greater,
	primitive_float_greatereq,
	/* The unordered comparison primitives don't have a non-optimizing
	compiler implementation */
	primitive_float_less,
	primitive_float_lesseq,
	primitive_float_greater,
	primitive_float_greatereq,
	primitive_word,
	primitive_word_code,
	primitive_special_object,
	primitive_set_special_object,
	primitive_existsp,
	primitive_minor_gc,
	primitive_full_gc,
	primitive_compact_gc,
	primitive_save_image,
	primitive_save_image_and_exit,
	primitive_datastack,
	primitive_retainstack,
	primitive_callstack,
	primitive_set_datastack,
	primitive_set_retainstack,
	primitive_exit,
	primitive_data_room,
	primitive_code_room,
	primitive_system_micros,
	primitive_nano_count,
	primitive_modify_code_heap,
	primitive_dlopen,
	primitive_dlsym,
	primitive_dlclose,
	primitive_byte_array,
	primitive_uninitialized_byte_array,
	primitive_displaced_alien,
	primitive_alien_signed_cell,
	primitive_set_alien_signed_cell,
	primitive_alien_unsigned_cell,
	primitive_set_alien_unsigned_cell,
	primitive_alien_signed_8,
	primitive_set_alien_signed_8,
	primitive_alien_unsigned_8,
	primitive_set_alien_unsigned_8,
	primitive_alien_signed_4,
	primitive_set_alien_signed_4,
	primitive_alien_unsigned_4,
	primitive_set_alien_unsigned_4,
	primitive_alien_signed_2,
	primitive_set_alien_signed_2,
	primitive_alien_unsigned_2,
	primitive_set_alien_unsigned_2,
	primitive_alien_signed_1,
	primitive_set_alien_signed_1,
	primitive_alien_unsigned_1,
	primitive_set_alien_unsigned_1,
	primitive_alien_float,
	primitive_set_alien_float,
	primitive_alien_double,
	primitive_set_alien_double,
	primitive_alien_cell,
	primitive_set_alien_cell,
	primitive_alien_address,
	primitive_set_slot,
	primitive_string_nth,
	primitive_set_string_nth_fast,
	primitive_set_string_nth_slow,
	primitive_resize_array,
	primitive_resize_string,
	primitive_array,
	primitive_all_instances,
	primitive_size,
	primitive_die,
	primitive_fopen,
	primitive_fgetc,
	primitive_fread,
	primitive_fputc,
	primitive_fwrite,
	primitive_fflush,
	primitive_ftell,
	primitive_fseek,
	primitive_fclose,
	primitive_wrapper,
	primitive_clone,
	primitive_string,
	primitive_array_to_quotation,
	primitive_quotation_code,
	primitive_tuple,
	primitive_profiling,
	primitive_become,
	primitive_sleep,
	primitive_tuple_boa,
	primitive_callstack_to_array,
	primitive_innermost_stack_frame_executing,
	primitive_innermost_stack_frame_scan,
	primitive_set_innermost_stack_frame_quot,
	primitive_call_clear,
	primitive_resize_byte_array,
	primitive_dll_validp,
	primitive_unimplemented,
	primitive_jit_compile,
	primitive_load_locals,
	primitive_check_datastack,
	primitive_mega_cache_miss,
	primitive_lookup_method,
	primitive_reset_dispatch_stats,
	primitive_dispatch_stats,
	primitive_optimized_p,
	primitive_quot_compiled_p,
	primitive_vm_ptr,
	primitive_strip_stack_traces,
	primitive_callback,
	primitive_enable_gc_events,
	primitive_disable_gc_events,
	primitive_identity_hashcode,
	primitive_compute_identity_hashcode,
};

}
