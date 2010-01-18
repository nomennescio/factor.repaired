CC = gcc
CPP = g++
AR = ar
LD = ld

EXECUTABLE = factor
CONSOLE_EXECUTABLE = factor-console
TEST_LIBRARY = factor-ffi-test
VERSION = 0.92

BUNDLE = Factor.app
LIBPATH = -L/usr/X11R6/lib
CFLAGS = -Wall

ifdef DEBUG
	CFLAGS += -g -DFACTOR_DEBUG
else
	CFLAGS += -O3
endif

ifdef REENTRANT
	CFLAGS += -DFACTOR_REENTRANT
endif

CFLAGS += $(SITE_CFLAGS)

ENGINE = $(DLL_PREFIX)factor$(DLL_SUFFIX)$(DLL_EXTENSION)

ifdef CONFIG
	include $(CONFIG)
endif

DLL_OBJS = $(PLAF_DLL_OBJS) \
	vm/aging_collector.o \
	vm/alien.o \
	vm/arrays.o \
	vm/bignum.o \
	vm/booleans.o \
	vm/byte_arrays.o \
	vm/callbacks.o \
	vm/callstack.o \
	vm/code_blocks.o \
	vm/code_heap.o \
	vm/compaction.o \
	vm/contexts.o \
	vm/data_heap.o \
	vm/data_heap_checker.o \
	vm/debug.o \
	vm/dispatch.o \
	vm/entry_points.o \
	vm/errors.o \
	vm/factor.o \
	vm/free_list.o \
	vm/full_collector.o \
	vm/gc.o \
	vm/image.o \
	vm/inline_cache.o \
	vm/instruction_operands.o \
	vm/io.o \
	vm/jit.o \
	vm/math.o \
	vm/nursery_collector.o \
	vm/object_start_map.o \
	vm/objects.o \
	vm/primitives.o \
	vm/profiler.o \
	vm/quotations.o \
	vm/run.o \
	vm/strings.o \
	vm/to_tenured_collector.o \
	vm/tuples.o \
	vm/utilities.o \
        vm/vm.o \
	vm/words.o

EXE_OBJS = $(PLAF_EXE_OBJS)

TEST_OBJS = vm/ffi_test.o

default:
	$(MAKE) `./build-support/factor.sh make-target`

help:
	@echo "Run '$(MAKE)' with one of the following parameters:"
	@echo ""
	@echo "freebsd-x86-32"
	@echo "freebsd-x86-64"
	@echo "linux-x86-32"
	@echo "linux-x86-64"
	@echo "linux-ppc"
	@echo "linux-arm"
	@echo "openbsd-x86-32"
	@echo "openbsd-x86-64"
	@echo "netbsd-x86-32"
	@echo "netbsd-x86-64"
	@echo "macosx-x86-32"
	@echo "macosx-x86-64"
	@echo "macosx-ppc"
	@echo "solaris-x86-32"
	@echo "solaris-x86-64"
	@echo "wince-arm"
	@echo "winnt-x86-32"
	@echo "winnt-x86-64"
	@echo ""
	@echo "Additional modifiers:"
	@echo ""
	@echo "DEBUG=1  compile VM with debugging information"
	@echo "SITE_CFLAGS=...  additional optimization flags"
	@echo "NO_UI=1  don't link with X11 libraries (ignored on Mac OS X)"
	@echo "X11=1  force link with X11 libraries instead of Cocoa (only on Mac OS X)"

openbsd-x86-32:
	$(MAKE) $(EXECUTABLE) $(TEST_LIBRARY) CONFIG=vm/Config.openbsd.x86.32

openbsd-x86-64:
	$(MAKE) $(EXECUTABLE) $(TEST_LIBRARY) CONFIG=vm/Config.openbsd.x86.64

freebsd-x86-32:
	$(MAKE) $(EXECUTABLE) $(TEST_LIBRARY) CONFIG=vm/Config.freebsd.x86.32

freebsd-x86-64:
	$(MAKE) $(EXECUTABLE) $(TEST_LIBRARY) CONFIG=vm/Config.freebsd.x86.64

netbsd-x86-32:
	$(MAKE) $(EXECUTABLE) $(TEST_LIBRARY) CONFIG=vm/Config.netbsd.x86.32

netbsd-x86-64:
	$(MAKE) $(EXECUTABLE) $(TEST_LIBRARY) CONFIG=vm/Config.netbsd.x86.64

macosx-ppc:
	$(MAKE) $(EXECUTABLE) $(TEST_LIBRARY) macosx.app CONFIG=vm/Config.macosx.ppc

macosx-x86-32:
	$(MAKE) $(EXECUTABLE) $(TEST_LIBRARY) macosx.app CONFIG=vm/Config.macosx.x86.32

macosx-x86-64:
	$(MAKE) $(EXECUTABLE) $(TEST_LIBRARY) macosx.app CONFIG=vm/Config.macosx.x86.64

linux-x86-32:
	$(MAKE) $(EXECUTABLE) $(TEST_LIBRARY) CONFIG=vm/Config.linux.x86.32

linux-x86-64:
	$(MAKE) $(EXECUTABLE) $(TEST_LIBRARY) CONFIG=vm/Config.linux.x86.64

linux-ppc:
	$(MAKE) $(EXECUTABLE) $(TEST_LIBRARY) CONFIG=vm/Config.linux.ppc

linux-arm:
	$(MAKE) $(EXECUTABLE) $(TEST_LIBRARY) CONFIG=vm/Config.linux.arm

solaris-x86-32:
	$(MAKE) $(EXECUTABLE) $(TEST_LIBRARY) CONFIG=vm/Config.solaris.x86.32

solaris-x86-64:
	$(MAKE) $(EXECUTABLE) $(TEST_LIBRARY) CONFIG=vm/Config.solaris.x86.64

winnt-x86-32:
	$(MAKE) $(EXECUTABLE) $(TEST_LIBRARY) CONFIG=vm/Config.windows.nt.x86.32
	$(MAKE) $(CONSOLE_EXECUTABLE) CONFIG=vm/Config.windows.nt.x86.32

winnt-x86-64:
	$(MAKE) $(EXECUTABLE) $(TEST_LIBRARY) CONFIG=vm/Config.windows.nt.x86.64
	$(MAKE) $(CONSOLE_EXECUTABLE) CONFIG=vm/Config.windows.nt.x86.64

wince-arm:
	$(MAKE) $(EXECUTABLE) $(TEST_LIBRARY) CONFIG=vm/Config.windows.ce.arm

macosx.app: factor
	mkdir -p $(BUNDLE)/Contents/MacOS
	mkdir -p $(BUNDLE)/Contents/Frameworks
	mv $(EXECUTABLE) $(BUNDLE)/Contents/MacOS/factor
	ln -s Factor.app/Contents/MacOS/factor ./factor
	cp $(ENGINE) $(BUNDLE)/Contents/Frameworks/$(ENGINE)

	install_name_tool \
		-change libfactor.dylib \
		@executable_path/../Frameworks/libfactor.dylib \
		Factor.app/Contents/MacOS/factor

factor.dll:
	$(TOOLCHAIN_PREFIX)$(LINKER) $(ENGINE) $(DLL_OBJS)

$(EXECUTABLE): $(DLL_OBJS) $(EXE_OBJS)
	$(MAKE) factor.dll
	$(TOOLCHAIN_PREFIX)$(CPP) $(LIBS) $(LIBPATH) -L. $(LINK_WITH_ENGINE) \
		$(CFLAGS) -o $@$(EXE_SUFFIX)$(EXE_EXTENSION) $(EXE_OBJS)

$(CONSOLE_EXECUTABLE): $(DLL_OBJS) $(EXE_OBJS)
	$(MAKE) factor.dll
	$(TOOLCHAIN_PREFIX)$(CPP) $(LIBS) $(LIBPATH) -L. $(LINK_WITH_ENGINE) \
		$(CFLAGS) $(CFLAGS_CONSOLE) -o factor$(EXE_SUFFIX)$(CONSOLE_EXTENSION) $(EXE_OBJS)


$(TEST_LIBRARY): vm/ffi_test.o
	$(TOOLCHAIN_PREFIX)$(CC) $(LIBPATH) $(CFLAGS) $(FFI_TEST_CFLAGS) $(SHARED_FLAG) -o libfactor-ffi-test$(SHARED_DLL_EXTENSION) $(TEST_OBJS)

clean:
	rm -f vm/*.o
	rm -f factor.dll
	rm -f libfactor.*
	rm -f libfactor-ffi-test.*
	rm -f Factor.app/Contents/Frameworks/libfactor.dylib

tags:
	etags vm/*.{cpp,hpp,mm,S,c}

vm/resources.o:
	$(TOOLCHAIN_PREFIX)$(WINDRES) vm/factor.rs vm/resources.o

vm/ffi_test.o: vm/ffi_test.c
	$(TOOLCHAIN_PREFIX)$(CC) -c $(CFLAGS) $(FFI_TEST_CFLAGS) -o $@ $<

.c.o:
	$(TOOLCHAIN_PREFIX)$(CC) -c $(CFLAGS) -o $@ $<

.cpp.o:
	$(TOOLCHAIN_PREFIX)$(CPP) -c $(CFLAGS) -o $@ $<

.S.o:
	$(TOOLCHAIN_PREFIX)$(CC) -x assembler-with-cpp -c $(CFLAGS) -o $@ $<

.mm.o:
	$(TOOLCHAIN_PREFIX)$(CPP) -c $(CFLAGS) -o $@ $<

.PHONY: factor tags clean

.SUFFIXES: .mm
