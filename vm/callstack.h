F_FASTCALL void save_callstack_bottom(F_STACK_FRAME *callstack_bottom);
F_FASTCALL __attribute__((noinline)) void save_callstack_top(F_STACK_FRAME *callstack_top);

#define FIRST_STACK_FRAME(stack) (F_STACK_FRAME *)((stack) + 1)

typedef void (*CALLSTACK_ITER)(F_STACK_FRAME *frame);

F_STACK_FRAME *fix_callstack_top(F_STACK_FRAME *top, F_STACK_FRAME *bottom);
void iterate_callstack(CELL top, CELL bottom, CALLSTACK_ITER iterator);
void iterate_callstack_object(F_CALLSTACK *stack, CALLSTACK_ITER iterator);
F_STACK_FRAME *frame_successor(F_STACK_FRAME *frame);
F_COMPILED *frame_code(F_STACK_FRAME *frame);
CELL frame_executing(F_STACK_FRAME *frame);
CELL frame_scan(F_STACK_FRAME *frame);
CELL frame_type(F_STACK_FRAME *frame);

DECLARE_PRIMITIVE(callstack);
DECLARE_PRIMITIVE(set_datastack);
DECLARE_PRIMITIVE(set_retainstack);
DECLARE_PRIMITIVE(set_callstack);
DECLARE_PRIMITIVE(callstack_to_array);
DECLARE_PRIMITIVE(innermost_stack_frame_quot);
DECLARE_PRIMITIVE(innermost_stack_frame_scan);
DECLARE_PRIMITIVE(set_innermost_stack_frame_quot);
