#include "master.hpp"

static void check_frame(F_STACK_FRAME *frame)
{
#ifdef FACTOR_DEBUG
	check_code_pointer((CELL)frame->xt);
	assert(frame->size != 0);
#endif
}

/* called before entry into Factor code. */
F_FASTCALL void save_callstack_bottom(F_STACK_FRAME *callstack_bottom)
{
	stack_chain->callstack_bottom = callstack_bottom;
}

void iterate_callstack(CELL top, CELL bottom, CALLSTACK_ITER iterator)
{
	F_STACK_FRAME *frame = (F_STACK_FRAME *)bottom - 1;

	while((CELL)frame >= top)
	{
		iterator(frame);
		frame = frame_successor(frame);
	}
}

void iterate_callstack_object(F_CALLSTACK *stack, CALLSTACK_ITER iterator)
{
	CELL top = (CELL)FIRST_STACK_FRAME(stack);
	CELL bottom = top + untag_fixnum(stack->length);

	iterate_callstack(top,bottom,iterator);
}

F_CALLSTACK *allot_callstack(CELL size)
{
	F_CALLSTACK *callstack = allot<F_CALLSTACK>(callstack_size(size));
	callstack->length = tag_fixnum(size);
	return callstack;
}

F_STACK_FRAME *fix_callstack_top(F_STACK_FRAME *top, F_STACK_FRAME *bottom)
{
	F_STACK_FRAME *frame = bottom - 1;

	while(frame >= top)
		frame = frame_successor(frame);

	return frame + 1;
}

/* We ignore the topmost frame, the one calling 'callstack',
so that set-callstack doesn't get stuck in an infinite loop.

This means that if 'callstack' is called in tail position, we
will have popped a necessary frame... however this word is only
called by continuation implementation, and user code shouldn't
be calling it at all, so we leave it as it is for now. */
F_STACK_FRAME *capture_start(void)
{
	F_STACK_FRAME *frame = stack_chain->callstack_bottom - 1;
	while(frame >= stack_chain->callstack_top
		&& frame_successor(frame) >= stack_chain->callstack_top)
	{
		frame = frame_successor(frame);
	}
	return frame + 1;
}

void primitive_callstack(void)
{
	F_STACK_FRAME *top = capture_start();
	F_STACK_FRAME *bottom = stack_chain->callstack_bottom;

	F_FIXNUM size = (CELL)bottom - (CELL)top;
	if(size < 0)
		size = 0;

	F_CALLSTACK *callstack = allot_callstack(size);
	memcpy(FIRST_STACK_FRAME(callstack),top,size);
	dpush(tag<F_CALLSTACK>(callstack));
}

void primitive_set_callstack(void)
{
	F_CALLSTACK *stack = untag_check<F_CALLSTACK>(dpop());

	set_callstack(stack_chain->callstack_bottom,
		FIRST_STACK_FRAME(stack),
		untag_fixnum(stack->length),
		memcpy);

	/* We cannot return here ... */
	critical_error("Bug in set_callstack()",0);
}

F_CODE_BLOCK *frame_code(F_STACK_FRAME *frame)
{
	check_frame(frame);
	return (F_CODE_BLOCK *)frame->xt - 1;
}

CELL frame_type(F_STACK_FRAME *frame)
{
	return frame_code(frame)->block.type;
}

CELL frame_executing(F_STACK_FRAME *frame)
{
	F_CODE_BLOCK *compiled = frame_code(frame);
	if(compiled->literals == F || !stack_traces_p())
		return F;
	else
	{
		F_ARRAY *array = untag<F_ARRAY>(compiled->literals);
		return array_nth(array,0);
	}
}

F_STACK_FRAME *frame_successor(F_STACK_FRAME *frame)
{
	check_frame(frame);
	return (F_STACK_FRAME *)((CELL)frame - frame->size);
}

CELL frame_scan(F_STACK_FRAME *frame)
{
	if(frame_type(frame) == QUOTATION_TYPE)
	{
		CELL quot = frame_executing(frame);
		if(quot == F)
			return F;
		else
		{
			char *return_addr = (char *)FRAME_RETURN_ADDRESS(frame);
			char *quot_xt = (char *)(frame_code(frame) + 1);

			return tag_fixnum(quot_code_offset_to_scan(
				quot,(CELL)(return_addr - quot_xt)));
		}
	}
	else
		return F;
}

/* C doesn't have closures... */
static CELL frame_count;

void count_stack_frame(F_STACK_FRAME *frame)
{
	frame_count += 2; 
}

static CELL frame_index;
static F_ARRAY *array;

void stack_frame_to_array(F_STACK_FRAME *frame)
{
	set_array_nth(array,frame_index++,frame_executing(frame));
	set_array_nth(array,frame_index++,frame_scan(frame));
}

void primitive_callstack_to_array(void)
{
	gc_root<F_CALLSTACK> callstack(dpop());

	frame_count = 0;
	iterate_callstack_object(callstack.untagged(),count_stack_frame);

	array = allot_array_internal<F_ARRAY>(frame_count);

	frame_index = 0;
	iterate_callstack_object(callstack.untagged(),stack_frame_to_array);

	dpush(tag<F_ARRAY>(array));
}

F_STACK_FRAME *innermost_stack_frame(F_CALLSTACK *callstack)
{
	F_STACK_FRAME *top = FIRST_STACK_FRAME(callstack);
	CELL bottom = (CELL)top + untag_fixnum(callstack->length);

	F_STACK_FRAME *frame = (F_STACK_FRAME *)bottom - 1;

	while(frame >= top && frame_successor(frame) >= top)
		frame = frame_successor(frame);

	return frame;
}

/* Some primitives implementing a limited form of callstack mutation.
Used by the single stepper. */
void primitive_innermost_stack_frame_quot(void)
{
	F_STACK_FRAME *inner = innermost_stack_frame(
		untag_check<F_CALLSTACK>(dpop()));
	type_check(QUOTATION_TYPE,frame_executing(inner));

	dpush(frame_executing(inner));
}

void primitive_innermost_stack_frame_scan(void)
{
	F_STACK_FRAME *inner = innermost_stack_frame(
		untag_check<F_CALLSTACK>(dpop()));
	type_check(QUOTATION_TYPE,frame_executing(inner));

	dpush(frame_scan(inner));
}

void primitive_set_innermost_stack_frame_quot(void)
{
	gc_root<F_CALLSTACK> callstack(dpop());
	gc_root<F_QUOTATION> quot(dpop());

	jit_compile(quot.value(),true);

	F_STACK_FRAME *inner = innermost_stack_frame(callstack.untagged());
	type_check(QUOTATION_TYPE,frame_executing(inner));

	CELL offset = (char *)FRAME_RETURN_ADDRESS(inner) - (char *)inner->xt;

	inner->xt = quot->xt;

	FRAME_RETURN_ADDRESS(inner) = (char *)quot->xt + offset;
}
