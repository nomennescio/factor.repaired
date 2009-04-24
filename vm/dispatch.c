#include "master.h"

static CELL search_lookup_alist(CELL table, CELL class)
{
	F_ARRAY *pairs = untag_object(table);
	F_FIXNUM index = array_capacity(pairs) - 1;
	while(index >= 0)
	{
		F_ARRAY *pair = untag_object(array_nth(pairs,index));
		if(array_nth(pair,0) == class)
			return array_nth(pair,1);
		else
			index--;
	}

	return F;
}

static CELL search_lookup_hash(CELL table, CELL class, CELL hashcode)
{
	F_ARRAY *buckets = untag_object(table);
	CELL bucket = array_nth(buckets,hashcode & (array_capacity(buckets) - 1));
	if(type_of(bucket) == WORD_TYPE || bucket == F)
		return bucket;
	else
		return search_lookup_alist(bucket,class);
}

static CELL nth_superclass(F_TUPLE_LAYOUT *layout, F_FIXNUM echelon)
{
	CELL *ptr = (CELL *)(layout + 1);
	return ptr[echelon * 2];
}

static CELL nth_hashcode(F_TUPLE_LAYOUT *layout, F_FIXNUM echelon)
{
	CELL *ptr = (CELL *)(layout + 1);
	return ptr[echelon * 2 + 1];
}

static CELL lookup_tuple_method(CELL object, CELL methods)
{
	F_ARRAY *echelons = untag_object(methods);
	F_TUPLE *tuple = untag_object(object);
	F_TUPLE_LAYOUT *layout = untag_object(tuple->layout);

	F_FIXNUM echelon = untag_fixnum_fast(layout->echelon);
	F_FIXNUM max_echelon = array_capacity(echelons) - 1;
	if(echelon > max_echelon) echelon = max_echelon;
       
	while(echelon >= 0)
	{
		CELL echelon_methods = array_nth(echelons,echelon);

		if(type_of(echelon_methods) == WORD_TYPE)
			return echelon_methods;
		else if(echelon_methods != F)
		{
			CELL class = nth_superclass(layout,echelon);
			CELL hashcode = untag_fixnum_fast(nth_hashcode(layout,echelon));
			CELL result = search_lookup_hash(echelon_methods,class,hashcode);
			if(result != F)
				return result;
		}

		echelon--;
	}

	critical_error("Cannot find tuple method",object);
	return F;
}

static CELL lookup_hi_tag_method(CELL object, CELL methods)
{
	F_ARRAY *hi_tag_methods = untag_object(methods);
	CELL hi_tag = object_type(object);
	return array_nth(hi_tag_methods,hi_tag - HEADER_TYPE);
}

static CELL lookup_method(CELL object, CELL methods)
{
	F_ARRAY *tag_methods = untag_object(methods);
	CELL tag = TAG(object);
	CELL element = array_nth(tag_methods,tag);

	if(type_of(element) == WORD_TYPE)
		return element;
	else
	{
		switch(tag)
		{
		case TUPLE_TYPE:
			return lookup_tuple_method(object,element);
		case OBJECT_TYPE:
			return lookup_hi_tag_method(object,element);
		default:
			critical_error("Bad methods array",methods);
			return F;
		}
	}
}

void primitive_lookup_method(void)
{
	CELL methods = dpop();
	CELL object = dpop();
	dpush(lookup_method(object,methods));
}
