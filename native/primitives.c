#include "factor.h"

void* primitives[] = {
	undefined,
	docol,
	dosym,
	primitive_execute,
	primitive_call,
	primitive_ifte,
	primitive_cons,
	primitive_vector,
	primitive_string_nth,
	primitive_string_compare,
	primitive_string_eq,
	primitive_index_of,
	primitive_substring,
	primitive_sbuf,
	primitive_sbuf_length,
	primitive_set_sbuf_length,
	primitive_sbuf_nth,
	primitive_set_sbuf_nth,
	primitive_sbuf_append,
	primitive_sbuf_to_string,
	primitive_sbuf_clone,
	primitive_sbuf_eq,
	primitive_arithmetic_type,
	primitive_to_fixnum,
	primitive_to_bignum,
	primitive_to_float,
	primitive_from_fraction,
	primitive_str_to_float,
	primitive_float_to_str,
	primitive_from_rect,
	primitive_fixnum_add,
	primitive_fixnum_subtract,
	primitive_fixnum_multiply,
	primitive_fixnum_divint,
	primitive_fixnum_divfloat,
	primitive_fixnum_mod,
	primitive_fixnum_divmod,
	primitive_fixnum_and,
	primitive_fixnum_or,
	primitive_fixnum_xor,
	primitive_fixnum_not,
	primitive_fixnum_shift,
	primitive_fixnum_less,
	primitive_fixnum_lesseq,
	primitive_fixnum_greater,
	primitive_fixnum_greatereq,
	primitive_bignum_eq,
	primitive_bignum_add,
	primitive_bignum_subtract,
	primitive_bignum_multiply,
	primitive_bignum_divint,
	primitive_bignum_divfloat,
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
	primitive_float_eq,
	primitive_float_add,
	primitive_float_subtract,
	primitive_float_multiply,
	primitive_float_divfloat,
	primitive_float_less,
	primitive_float_lesseq,
	primitive_float_greater,
	primitive_float_greatereq,
	primitive_facos,
	primitive_fasin,
	primitive_fatan,
        primitive_fatan2,
        primitive_fcos,
        primitive_fexp,
        primitive_fcosh,
        primitive_flog,
        primitive_fpow,
        primitive_fsin,
        primitive_fsinh,
        primitive_fsqrt,
	primitive_word,
	primitive_update_xt,
	primitive_call_profiling,
	primitive_allot_profiling,
	primitive_word_compiledp,
	primitive_drop,
	primitive_dup,
	primitive_swap,
	primitive_over,
	primitive_pick,
	primitive_to_r,
	primitive_from_r,
	primitive_eq,
	primitive_getenv,
	primitive_setenv,
	primitive_stat,
	primitive_read_dir,
	primitive_gc,
	primitive_gc_time,
	primitive_save_image,
	primitive_datastack,
	primitive_callstack,
	primitive_set_datastack,
	primitive_set_callstack,
	primitive_exit,
	primitive_room,
	primitive_os_env,
	primitive_millis,
	primitive_init_random,
	primitive_random_int,
	primitive_type,
	primitive_cwd,
	primitive_cd,
	primitive_compiled_offset,
	primitive_set_compiled_offset,
	primitive_literal_top,
	primitive_set_literal_top,
	primitive_address,
	primitive_dlopen,
	primitive_dlsym,
	primitive_dlclose,
	primitive_alien,
	primitive_byte_array,
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
	primitive_alien_value_string,
	primitive_throw,
	primitive_string_to_memory,
	primitive_memory_to_string,
	primitive_alien_address,
	primitive_slot,
	primitive_set_slot,
	primitive_integer_slot,
	primitive_set_integer_slot,
	primitive_grow_array,
	primitive_hashtable,
	primitive_array,
	primitive_tuple,
	primitive_begin_scan,
	primitive_next_object,
	primitive_end_scan,
	primitive_size,
	primitive_die,
	primitive_flush_icache,
	primitive_fopen,
	primitive_fgetln,
	primitive_fwrite,
	primitive_fflush,
	primitive_fclose
};

CELL primitive_to_xt(CELL primitive)
{
	if(primitive < 0 || primitive >= PRIMITIVE_COUNT)
		return (CELL)undefined;
	else
		return (CELL)primitives[primitive];
}
