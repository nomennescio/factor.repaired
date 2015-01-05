#include "master.hpp"

namespace factor {

/* Allocates memory (allot) */
callstack* factor_vm::allot_callstack(cell size) {
  callstack* stack = allot<callstack>(callstack_object_size(size));
  stack->length = tag_fixnum(size);
  return stack;
}

/* We ignore the two topmost frames, the 'callstack' primitive
frame itself, and the frame calling the 'callstack' primitive,
so that set-callstack doesn't get stuck in an infinite loop.

This means that if 'callstack' is called in tail position, we
will have popped a necessary frame... however this word is only
called by continuation implementation, and user code shouldn't
be calling it at all, so we leave it as it is for now. */
cell factor_vm::second_from_top_stack_frame(context* ctx) {
  cell frame_top = ctx->callstack_top;
  for (cell i = 0; i < 2; ++i) {
    cell pred = frame_predecessor(frame_top);
    if (pred >= ctx->callstack_bottom)
      return frame_top;
    frame_top = pred;
  }
  return frame_top;
}

/* Allocates memory (allot_callstack) */
cell factor_vm::capture_callstack(context* ctx) {
  cell top = second_from_top_stack_frame(ctx);
  cell bottom = ctx->callstack_bottom;

  fixnum size = std::max((cell)0, bottom - top);

  callstack* stack = allot_callstack(size);
  memcpy(stack->top(), (void *)top, size);
  return tag<callstack>(stack);
}

/* Allocates memory (capture_callstack) */
void factor_vm::primitive_callstack() { ctx->push(capture_callstack(ctx)); }

/* Allocates memory (capture_callstack) */
void factor_vm::primitive_callstack_for() {
  context* other_ctx = (context*)pinned_alien_offset(ctx->peek());
  ctx->replace(capture_callstack(other_ctx));
}

cell factor_vm::frame_predecessor(cell frame_top) {
  cell addr = *(cell*)frame_top;
  FACTOR_ASSERT(addr != 0);
  code_block* owner = code->code_block_for_address(addr);
  cell frame_size = owner->stack_frame_size_for_address(addr);
  return frame_top + frame_size;
}

struct stack_frame_accumulator {
  factor_vm* parent;
  growable_array frames;

  /* Allocates memory (frames is a growable_array, constructor allocates) */
  explicit stack_frame_accumulator(factor_vm* parent)
      : parent(parent), frames(parent) {}


  /* Allocates memory (frames.add()) */
  void operator()(cell frame_top, cell size, code_block* owner, cell addr) {
    data_root<object> executing_quot(owner->owner_quot(), parent);
    data_root<object> executing(owner->owner, parent);
    data_root<object> scan(owner->scan(parent, addr), parent);

    frames.add(executing.value());
    frames.add(executing_quot.value());
    frames.add(scan.value());
  }
};

struct stack_frame_in_array {
  cell cells[3];
};

/* Allocates memory (frames.trim()), iterate_callstack_object() */
void factor_vm::primitive_callstack_to_array() {
  data_root<callstack> callstack(ctx->peek(), this);

  stack_frame_accumulator accum(this);
  iterate_callstack_object(callstack.untagged(), accum);

  /* The callstack iterator visits frames in reverse order (top to bottom) */
  std::reverse((stack_frame_in_array*)accum.frames.elements->data(),
               (stack_frame_in_array*)(accum.frames.elements->data() +
                                       accum.frames.count));

  accum.frames.trim();

  ctx->replace(accum.frames.elements.value());

}

/* Some primitives implementing a limited form of callstack mutation.
Used by the single stepper. */
void factor_vm::primitive_innermost_stack_frame_executing() {
  callstack* stack = untag_check<callstack>(ctx->peek());
  void* frame = stack->top();
  void* addr = *(void**)frame;
  ctx->replace(code->code_block_for_address((cell)addr)->owner_quot());
}

void factor_vm::primitive_innermost_stack_frame_scan() {
  callstack* stack = untag_check<callstack>(ctx->peek());
  void* frame = stack->top();
  cell addr = *(cell*)frame;
  ctx->replace(code->code_block_for_address((cell)addr)->scan(this, addr));
}

/* Allocates memory (jit_compile_quot) */
void factor_vm::primitive_set_innermost_stack_frame_quot() {
  data_root<callstack> stack(ctx->pop(), this);
  data_root<quotation> quot(ctx->pop(), this);

  stack.untag_check(this);
  quot.untag_check(this);

  jit_compile_quot(quot.value(), true);

  void* inner = stack->top();
  void* addr = *(void**)inner;
  code_block* block = code->code_block_for_address((cell)addr);
  cell offset = block->offset(addr);
  *(void**)inner = (char*)quot->entry_point + offset;
}

/* Allocates memory (allot_alien) */
void factor_vm::primitive_callstack_bounds() {
  ctx->push(allot_alien((void*)ctx->callstack_seg->start));
  ctx->push(allot_alien((void*)ctx->callstack_seg->end));
}

}
