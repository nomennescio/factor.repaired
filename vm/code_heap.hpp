namespace factor
{

struct code_heap : heap {
	/* Maps code blocks to the youngest generation containing
	one of their literals. If this is tenured (0), the code block
	is not part of the remembered set. */
	unordered_map<code_block *, cell> remembered_set;
	
	/* Minimum value in the above map. */
	cell youngest_referenced_generation;

	explicit code_heap(factor_vm *myvm, cell size);
	void write_barrier(code_block *compiled);
	void code_heap_free(code_block *compiled);
};

}
