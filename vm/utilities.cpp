#include "master.hpp"

namespace factor
{

/* If memory allocation fails, bail out */
void *factorvm::safe_malloc(size_t size)
{
	void *ptr = malloc(size);
	if(!ptr) fatal_error("Out of memory in safe_malloc", 0);
	return ptr;
}

void *safe_malloc(size_t size)
{
	return vm->safe_malloc(size);
}

vm_char *factorvm::safe_strdup(const vm_char *str)
{
	vm_char *ptr = STRDUP(str);
	if(!ptr) fatal_error("Out of memory in safe_strdup", 0);
	return ptr;
}

vm_char *safe_strdup(const vm_char *str)
{
	return vm->safe_strdup(str);
}

/* We don't use printf directly, because format directives are not portable.
Instead we define the common cases here. */
void factorvm::nl()
{
	fputs("\n",stdout);
}

void nl()
{
	return vm->nl();
}

void factorvm::print_string(const char *str)
{
	fputs(str,stdout);
}

void print_string(const char *str)
{
	return vm->print_string(str);
}

void factorvm::print_cell(cell x)
{
	printf(CELL_FORMAT,x);
}

void print_cell(cell x)
{
	return vm->print_cell(x);
}

void factorvm::print_cell_hex(cell x)
{
	printf(CELL_HEX_FORMAT,x);
}

void print_cell_hex(cell x)
{
	return vm->print_cell_hex(x);
}

void factorvm::print_cell_hex_pad(cell x)
{
	printf(CELL_HEX_PAD_FORMAT,x);
}

void print_cell_hex_pad(cell x)
{
	return vm->print_cell_hex_pad(x);
}

void factorvm::print_fixnum(fixnum x)
{
	printf(FIXNUM_FORMAT,x);
}

void print_fixnum(fixnum x)
{
	return vm->print_fixnum(x);
}

cell factorvm::read_cell_hex()
{
	cell cell;
	if(scanf(CELL_HEX_FORMAT,&cell) < 0) exit(1);
	return cell;
}

cell read_cell_hex()
{
	return vm->read_cell_hex();
};

}
