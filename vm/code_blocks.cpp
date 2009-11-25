#include "master.hpp"

namespace factor
{

void *factor_vm::object_xt(cell obj)
{
	switch(tagged<object>(obj).type())
	{
	case WORD_TYPE:
		return untag<word>(obj)->xt;
	case QUOTATION_TYPE:
		return untag<quotation>(obj)->xt;
	default:
		critical_error("Expected word or quotation",obj);
		return NULL;
	}
}

void *factor_vm::xt_pic(word *w, cell tagged_quot)
{
	if(!to_boolean(tagged_quot) || max_pic_size == 0)
		return w->xt;
	else
	{
		quotation *quot = untag<quotation>(tagged_quot);
		if(quot->code)
			return quot->xt;
		else
			return w->xt;
	}
}

void *factor_vm::word_xt_pic(word *w)
{
	return xt_pic(w,w->pic_def);
}

void *factor_vm::word_xt_pic_tail(word *w)
{
	return xt_pic(w,w->pic_tail_def);
}

cell factor_vm::code_block_owner(code_block *compiled)
{
	tagged<object> owner(compiled->owner);

	/* Cold generic word call sites point to quotations that call the
	inline-cache-miss and inline-cache-miss-tail primitives. */
	if(owner.type_p(QUOTATION_TYPE))
	{
		tagged<quotation> quot(owner.as<quotation>());
		tagged<array> elements(quot->array);
#ifdef FACTOR_DEBUG
		assert(array_capacity(elements.untagged()) == 5);
		assert(array_nth(elements.untagged(),4) == special_objects[PIC_MISS_WORD]
			|| array_nth(elements.untagged(),4) == special_objects[PIC_MISS_TAIL_WORD]);
#endif
		tagged<wrapper> word_wrapper(array_nth(elements.untagged(),0));
		return word_wrapper->object;
	}
	else
	{
#ifdef FACTOR_DEBUG
		assert(owner.type_p(WORD_TYPE));
#endif
		return compiled->owner;
	}
}

struct word_references_updater {
	factor_vm *parent;

	word_references_updater(factor_vm *parent_) : parent(parent_) {}

	void operator()(relocation_entry rel, cell index, code_block *compiled)
	{
		relocation_type type = rel.rel_type();
		instruction_operand op(rel.rel_class(),rel.rel_offset() + (cell)compiled->xt());

		switch(type)
		{
		case RT_XT:
			{
				code_block *compiled = op.load_code_block();
				op.store_value((cell)parent->object_xt(compiled->owner));
				break;
			}
		case RT_XT_PIC:
			{
				code_block *compiled = op.load_code_block();
				op.store_value((cell)parent->word_xt_pic(untag<word>(parent->code_block_owner(compiled))));
				break;
			}
		case RT_XT_PIC_TAIL:
			{
				code_block *compiled = op.load_code_block();
				op.store_value((cell)parent->word_xt_pic_tail(untag<word>(parent->code_block_owner(compiled))));
				break;
			}
		default:
			break;
		}
	}
};

/* Relocate new code blocks completely; updating references to literals,
dlsyms, and words. For all other words in the code heap, we only need
to update references to other words, without worrying about literals
or dlsyms. */
void factor_vm::update_word_references(code_block *compiled)
{
	if(code->needs_fixup_p(compiled))
		relocate_code_block(compiled);
	/* update_word_references() is always applied to every block in
	   the code heap. Since it resets all call sites to point to
	   their canonical XT (cold entry point for non-tail calls,
	   standard entry point for tail calls), it means that no PICs
	   are referenced after this is done. So instead of polluting
	   the code heap with dead PICs that will be freed on the next
	   GC, we add them to the free list immediately. */
	else if(compiled->pic_p())
		code->code_heap_free(compiled);
	else
	{
		word_references_updater updater(this);
		iterate_relocations(compiled,updater);
		compiled->flush_icache();
	}
}

/* References to undefined symbols are patched up to call this function on
image load */
void factor_vm::undefined_symbol()
{
	general_error(ERROR_UNDEFINED_SYMBOL,false_object,false_object,NULL);
}

void undefined_symbol()
{
	return tls_vm()->undefined_symbol();
}

/* Look up an external library symbol referenced by a compiled code block */
void *factor_vm::get_rel_symbol(array *literals, cell index)
{
	cell symbol = array_nth(literals,index);
	cell library = array_nth(literals,index + 1);

	dll *d = (to_boolean(library) ? untag<dll>(library) : NULL);

	if(d != NULL && !d->dll)
		return (void *)factor::undefined_symbol;

	switch(tagged<object>(symbol).type())
	{
	case BYTE_ARRAY_TYPE:
		{
			symbol_char *name = alien_offset(symbol);
			void *sym = ffi_dlsym(d,name);

			if(sym)
				return sym;
			else
				return (void *)factor::undefined_symbol;
		}
	case ARRAY_TYPE:
		{
			array *names = untag<array>(symbol);
			for(cell i = 0; i < array_capacity(names); i++)
			{
				symbol_char *name = alien_offset(array_nth(names,i));
				void *sym = ffi_dlsym(d,name);

				if(sym)
					return sym;
			}
			return (void *)factor::undefined_symbol;
		}
	default:
		critical_error("Bad symbol specifier",symbol);
		return (void *)factor::undefined_symbol;
	}
}

cell factor_vm::compute_relocation(relocation_entry rel, cell index, code_block *compiled)
{
	array *literals = (to_boolean(compiled->literals)
		? untag<array>(compiled->literals) : NULL);
	cell offset = rel.rel_offset() + (cell)compiled->xt();

#define ARG array_nth(literals,index)

	switch(rel.rel_type())
	{
	case RT_PRIMITIVE:
		return (cell)primitives[untag_fixnum(ARG)];
	case RT_DLSYM:
		return (cell)get_rel_symbol(literals,index);
	case RT_IMMEDIATE:
		return ARG;
	case RT_XT:
		return (cell)object_xt(ARG);
	case RT_XT_PIC:
		return (cell)word_xt_pic(untag<word>(ARG));
	case RT_XT_PIC_TAIL:
		return (cell)word_xt_pic_tail(untag<word>(ARG));
	case RT_HERE:
	{
		fixnum arg = untag_fixnum(ARG);
		return (arg >= 0 ? offset + arg : (cell)compiled->xt() - arg);
	}
	case RT_THIS:
		return (cell)compiled->xt();
	case RT_CONTEXT:
		return (cell)&ctx;
	case RT_UNTAGGED:
		return untag_fixnum(ARG);
	case RT_MEGAMORPHIC_CACHE_HITS:
		return (cell)&dispatch_stats.megamorphic_cache_hits;
	case RT_VM:
		return (cell)this + untag_fixnum(ARG);
	case RT_CARDS_OFFSET:
		return cards_offset;
	case RT_DECKS_OFFSET:
		return decks_offset;
	default:
		critical_error("Bad rel type",rel.rel_type());
		return 0; /* Can't happen */
	}

#undef ARG
}

void factor_vm::check_code_address(cell address)
{
#ifdef FACTOR_DEBUG
	assert(address >= code->seg->start && address < code->seg->end);
#endif
}

struct code_block_relocator {
	factor_vm *parent;

	explicit code_block_relocator(factor_vm *parent_) : parent(parent_) {}

	void operator()(relocation_entry rel, cell index, code_block *compiled)
	{
		instruction_operand op(rel.rel_class(),rel.rel_offset() + (cell)compiled->xt());
		op.store_value(parent->compute_relocation(rel,index,compiled));
	}
};

/* Perform all fixups on a code block */
void factor_vm::relocate_code_block(code_block *compiled)
{
	code->needs_fixup.erase(compiled);
	code_block_relocator relocator(this);
	iterate_relocations(compiled,relocator);
	compiled->flush_icache();
}

/* Fixup labels. This is done at compile time, not image load time */
void factor_vm::fixup_labels(array *labels, code_block *compiled)
{
	cell i;
	cell size = array_capacity(labels);

	for(i = 0; i < size; i += 3)
	{
		cell rel_class = untag_fixnum(array_nth(labels,i));
		cell offset = untag_fixnum(array_nth(labels,i + 1));
		cell target = untag_fixnum(array_nth(labels,i + 2));

		instruction_operand op(rel_class,offset + (cell)compiled->xt());
		op.store_value(target + (cell)compiled->xt());
	}
}

/* Might GC */
code_block *factor_vm::allot_code_block(cell size, code_block_type type)
{
	code_block *block = code->allocator->allot(size + sizeof(code_block));

	/* If allocation failed, do a full GC and compact the code heap.
	A full GC that occurs as a result of the data heap filling up does not
	trigger a compaction. This setup ensures that most GCs do not compact
	the code heap, but if the code fills up, it probably means it will be
	fragmented after GC anyway, so its best to compact. */
	if(block == NULL)
	{
		primitive_compact_gc();
		block = code->allocator->allot(size + sizeof(code_block));

		/* Insufficient room even after code GC, give up */
		if(block == NULL)
		{
			std::cout << "Code heap used: " << code->allocator->occupied_space() << "\n";
			std::cout << "Code heap free: " << code->allocator->free_space() << "\n";
			fatal_error("Out of memory in add-compiled-block",0);
		}
	}

	block->set_type(type);
	return block;
}

/* Might GC */
code_block *factor_vm::add_code_block(code_block_type type, cell code_, cell labels_, cell owner_, cell relocation_, cell literals_)
{
	data_root<byte_array> code(code_,this);
	data_root<object> labels(labels_,this);
	data_root<object> owner(owner_,this);
	data_root<byte_array> relocation(relocation_,this);
	data_root<array> literals(literals_,this);

	cell code_length = array_capacity(code.untagged());
	code_block *compiled = allot_code_block(code_length,type);

	compiled->owner = owner.value();

	/* slight space optimization */
	if(relocation.type() == BYTE_ARRAY_TYPE && array_capacity(relocation.untagged()) == 0)
		compiled->relocation = false_object;
	else
		compiled->relocation = relocation.value();

	if(literals.type() == ARRAY_TYPE && array_capacity(literals.untagged()) == 0)
		compiled->literals = false_object;
	else
		compiled->literals = literals.value();

	/* code */
	memcpy(compiled + 1,code.untagged() + 1,code_length);

	/* fixup labels */
	if(to_boolean(labels.value()))
		fixup_labels(labels.as<array>().untagged(),compiled);

	/* next time we do a minor GC, we have to scan the code heap for
	literals */
	this->code->write_barrier(compiled);
	this->code->needs_fixup.insert(compiled);

	return compiled;
}

}
