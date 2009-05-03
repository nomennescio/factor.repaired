#include "master.hpp"

CELL string_nth(F_STRING* string, CELL index)
{
	/* If high bit is set, the most significant 16 bits of the char
	come from the aux vector. The least significant bit of the
	corresponding aux vector entry is negated, so that we can
	XOR the two components together and get the original code point
	back. */
	CELL ch = bget(SREF(string,index));
	if((ch & 0x80) == 0)
		return ch;
	else
	{
		F_BYTE_ARRAY *aux = untag<F_BYTE_ARRAY>(string->aux);
		return (cget(BREF(aux,index * sizeof(u16))) << 7) ^ ch;
	}
}

void set_string_nth_fast(F_STRING *string, CELL index, CELL ch)
{
	bput(SREF(string,index),ch);
}

void set_string_nth_slow(F_STRING *string_, CELL index, CELL ch)
{
	gc_root<F_STRING> string(string_);

	F_BYTE_ARRAY *aux;

	bput(SREF(string.untagged(),index),(ch & 0x7f) | 0x80);

	if(string->aux == F)
	{
		/* We don't need to pre-initialize the
		byte array with any data, since we
		only ever read from the aux vector
		if the most significant bit of a
		character is set. Initially all of
		the bits are clear. */
		aux = allot_array_internal<F_BYTE_ARRAY>(
			untag_fixnum(string->length)
			* sizeof(u16));

		write_barrier(string.value());
		string->aux = tag<F_BYTE_ARRAY>(aux);
	}
	else
		aux = untag<F_BYTE_ARRAY>(string->aux);

	cput(BREF(aux,index * sizeof(u16)),(ch >> 7) ^ 1);
}

/* allocates memory */
void set_string_nth(F_STRING* string, CELL index, CELL ch)
{
	if(ch <= 0x7f)
		set_string_nth_fast(string,index,ch);
	else
		set_string_nth_slow(string,index,ch);
}

/* Allocates memory */
F_STRING *allot_string_internal(CELL capacity)
{
	F_STRING *string = allot<F_STRING>(string_size(capacity));

	string->length = tag_fixnum(capacity);
	string->hashcode = F;
	string->aux = F;

	return string;
}

/* Allocates memory */
void fill_string(F_STRING *string_, CELL start, CELL capacity, CELL fill)
{
	gc_root<F_STRING> string(string_);

	if(fill <= 0x7f)
		memset((void *)SREF(string.untagged(),start),fill,capacity - start);
	else
	{
		CELL i;

		for(i = start; i < capacity; i++)
			set_string_nth(string.untagged(),i,fill);
	}
}

/* Allocates memory */
F_STRING *allot_string(CELL capacity, CELL fill)
{
	gc_root<F_STRING> string(allot_string_internal(capacity));
	fill_string(string.untagged(),0,capacity,fill);
	return string.untagged();
}

void primitive_string(void)
{
	CELL initial = to_cell(dpop());
	CELL length = unbox_array_size();
	dpush(tag<F_STRING>(allot_string(length,initial)));
}

static bool reallot_string_in_place_p(F_STRING *string, CELL capacity)
{
	return in_zone(&nursery,(CELL)string) && capacity <= string_capacity(string);
}

F_STRING* reallot_string(F_STRING *string_, CELL capacity)
{
	gc_root<F_STRING> string(string_);

	if(reallot_string_in_place_p(string.untagged(),capacity))
	{
		string->length = tag_fixnum(capacity);

		if(string->aux != F)
		{
			F_BYTE_ARRAY *aux = untag<F_BYTE_ARRAY>(string->aux);
			aux->capacity = tag_fixnum(capacity * 2);
		}

		return string.untagged();
	}
	else
	{
		CELL to_copy = string_capacity(string.untagged());
		if(capacity < to_copy)
			to_copy = capacity;

		gc_root<F_STRING> new_string(allot_string_internal(capacity));

		memcpy(new_string.untagged() + 1,string.untagged() + 1,to_copy);

		if(string->aux != F)
		{
			F_BYTE_ARRAY *new_aux = allot_byte_array(capacity * sizeof(u16));

			write_barrier(new_string.value());
			new_string->aux = tag<F_BYTE_ARRAY>(new_aux);

			F_BYTE_ARRAY *aux = untag<F_BYTE_ARRAY>(string->aux);
			memcpy(new_aux + 1,aux + 1,to_copy * sizeof(u16));
		}

		fill_string(new_string.untagged(),to_copy,capacity,'\0');
		return new_string.untagged();
	}
}

void primitive_resize_string(void)
{
	F_STRING* string = untag_check<F_STRING>(dpop());
	CELL capacity = unbox_array_size();
	dpush(tag<F_STRING>(reallot_string(string,capacity)));
}

void primitive_string_nth(void)
{
	F_STRING *string = untag<F_STRING>(dpop());
	CELL index = untag_fixnum(dpop());
	dpush(tag_fixnum(string_nth(string,index)));
}

void primitive_set_string_nth(void)
{
	F_STRING *string = untag<F_STRING>(dpop());
	CELL index = untag_fixnum(dpop());
	CELL value = untag_fixnum(dpop());
	set_string_nth(string,index,value);
}

void primitive_set_string_nth_fast(void)
{
	F_STRING *string = untag<F_STRING>(dpop());
	CELL index = untag_fixnum(dpop());
	CELL value = untag_fixnum(dpop());
	set_string_nth_fast(string,index,value);
}

void primitive_set_string_nth_slow(void)
{
	F_STRING *string = untag<F_STRING>(dpop());
	CELL index = untag_fixnum(dpop());
	CELL value = untag_fixnum(dpop());
	set_string_nth_slow(string,index,value);
}
