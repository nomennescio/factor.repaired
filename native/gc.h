/* generational copying GC divides memory into zones */
typedef struct {
	/* start of zone */
	CELL base;
	/* allocation pointer */
	CELL here;
	/* only for nursery: when it gets this full, call GC */
	CELL alarm;
	/* end of zone */
	CELL limit;
} ZONE;

/* total number of generations. */
#define GC_GENERATIONS 3
/* the 0th generation is where new objects are allocated. */
#define NURSERY 0
/* the oldest generation */
#define TENURED (GC_GENERATIONS-1)

ZONE generations[GC_GENERATIONS];

/* used during garbage collection only */
ZONE *newspace;

#define tenured generations[TENURED]
#define nursery generations[NURSERY]

/* spare semi-space; rotates with tenured. */
ZONE prior;

INLINE bool in_zone(ZONE* z, CELL pointer)
{
	return pointer >= z->base && pointer < z->limit;
}

CELL init_zone(ZONE *z, CELL size, CELL base);

void init_arena(CELL young_size, CELL aging_size);

s64 gc_time;

/* only meaningful during a GC */
CELL collecting_generation;

/* test if the pointer is in generation being collected, or a younger one.
init_arena() arranges things so that the older generations are first,
so we have to check that the pointer occurs after the beginning of
the requested generation. */
#define COLLECTING_GEN(ptr) (collecting_generation <= ptr)

/* #define GC_DEBUG */

INLINE void gc_debug(char* msg, CELL x) {
#ifdef GC_DEBUG
	printf("%s %ld\n",msg,x);
#endif
}

CELL copy_object(CELL pointer);
#define COPY_OBJECT(lvalue) if(COLLECTING_GEN(lvalue)) lvalue = copy_object(lvalue)

INLINE void copy_handle(CELL *handle)
{
	COPY_OBJECT(*handle);
}

/* in case a generation fills up in the middle of a gc, we jump back
up to try collecting the next generation. */
jmp_buf gc_jmp;

/* A heap walk allows useful things to be done, like finding all
references to an object for debugging purposes. */
CELL heap_scan_ptr;

/* GC is off during heap walking */
bool heap_scan;

INLINE void *allot_zone(ZONE *z, CELL a)
{
	CELL h = z->here;
	z->here = h + align8(a);
	allot_barrier(h);
	return (void*)h;
}

INLINE void *allot(CELL a)
{
	if(allot_profiling)
		allot_profile_step(align8(a));
	allot_barrier(nursery.here);
	return allot_zone(&nursery,a);
}

/*
 * It is up to the caller to fill in the object's fields in a meaningful
 * fashion!
 */
INLINE void* allot_object(CELL type, CELL length)
{
	CELL* object = allot(length);
	*object = tag_header(type);
	return object;
}

CELL collect_next(CELL scan);
void garbage_collection(CELL gen);
void primitive_gc(void);
void maybe_garbage_collection(void);
void primitive_gc_time(void);
