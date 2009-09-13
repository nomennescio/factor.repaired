#include "master.hpp"

namespace factor
{

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
	primitive_fixnum_add,
	primitive_fixnum_subtract,
	primitive_fixnum_multiply,
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
	primitive_word_xt,
	primitive_getenv,
	primitive_setenv,
	primitive_existsp,
	primitive_gc,
	primitive_gc_stats,
	primitive_save_image,
	primitive_save_image_and_exit,
	primitive_datastack,
	primitive_retainstack,
	primitive_callstack,
	primitive_set_datastack,
	primitive_set_retainstack,
	primitive_set_callstack,
	primitive_exit,
	primitive_data_room,
	primitive_code_room,
	primitive_micros,
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
	primitive_begin_scan,
	primitive_next_object,
	primitive_end_scan,
	primitive_size,
	primitive_die,
	primitive_fopen,
	primitive_fgetc,
	primitive_fread,
	primitive_fputc,
	primitive_fwrite,
	primitive_fflush,
	primitive_fseek,
	primitive_fclose,
	primitive_wrapper,
	primitive_clone,
	primitive_string,
	primitive_array_to_quotation,
	primitive_quotation_xt,
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
	primitive_clear_gc_stats,
	primitive_jit_compile,
	primitive_load_locals,
	primitive_check_datastack,
	primitive_inline_cache_miss,
	primitive_inline_cache_miss_tail,
	primitive_mega_cache_miss,
	primitive_lookup_method,
	primitive_reset_dispatch_stats,
	primitive_dispatch_stats,
	primitive_reset_inline_cache_stats,
	primitive_inline_cache_stats,
	primitive_optimized_p,
	primitive_quot_compiled_p,
};

}
