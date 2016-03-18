! Copyright (C) 2004, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.strings arrays assocs bootstrap.image.private classes
classes.builtin classes.intersection classes.predicate classes.private
classes.singleton classes.tuple classes.tuple.private classes.union
combinators compiler.units io io.encodings.ascii kernel kernel.private
layouts make math math.private namespaces parser quotations sequences
slots source-files splitting vocabs vocabs.loader words ;
IN: bootstrap.primitives

"Creating primitives and basic runtime structures..." print flush

H{ } clone sub-primitives set

"vocab:bootstrap/syntax.factor" parse-file

: asm-file ( arch -- file )
    "-" split reverse "." join
    "vocab:bootstrap/assembler/" ".factor" surround ;

architecture get asm-file parse-file

"vocab:bootstrap/layouts/layouts.factor" parse-file

! Now we have ( syntax-quot arch-quot layouts-quot ) on the stack

! Bring up a bare cross-compiling vocabulary.
"syntax" lookup-vocab vocab-words-assoc bootstrap-syntax set

H{ } clone dictionary set
H{ } clone root-cache set
H{ } clone source-files set
H{ } clone update-map set
H{ } clone implementors-map set

init-caches

bootstrapping? on

call( -- ) ! layouts quot
call( -- ) ! arch quot

! Vocabulary for slot accessors
"accessors" create-vocab drop

! After we execute bootstrap/layouts
num-types get f <array> builtins set

[

call( -- ) ! syntax-quot

! create-word some empty vocabs where the below primitives and
! classes will go
{
    "alien"
    "alien.accessors"
    "alien.libraries"
    "alien.private"
    "arrays"
    "byte-arrays"
    "classes.private"
    "classes.tuple"
    "classes.tuple.private"
    "classes.predicate"
    "compiler.units"
    "continuations.private"
    "generic.single"
    "generic.single.private"
    "growable"
    "hashtables"
    "hashtables.private"
    "io"
    "io.files"
    "io.files.private"
    "io.streams.c"
    "locals.backend"
    "kernel"
    "kernel.private"
    "math"
    "math.parser.private"
    "math.private"
    "memory"
    "memory.private"
    "quotations"
    "quotations.private"
    "sbufs"
    "sbufs.private"
    "scratchpad"
    "sequences"
    "sequences.private"
    "slots.private"
    "strings"
    "strings.private"
    "system"
    "system.private"
    "threads.private"
    "tools.dispatch.private"
    "tools.memory.private"
    "tools.profiler.sampling.private"
    "words"
    "words.private"
    "vectors"
    "vectors.private"
    "vm"
} [ create-vocab drop ] each

! Builtin classes
: lookup-type-number ( word -- n )
    [ target-word ] with-global type-number ;

: register-builtin ( class -- )
    [ dup lookup-type-number "type" set-word-prop ]
    [ dup "type" word-prop builtins get set-nth ]
    [ f f f builtin-class define-class ]
    tri ;

: prepare-slots ( slots -- slots' )
    [ [ dup pair? [ first2 create-word ] when ] map ] map ;

: define-builtin-slots ( class slots -- )
    prepare-slots make-slots 1 finalize-slots
    [ "slots" set-word-prop ] [ define-accessors ] 2bi ;

: define-builtin-predicate ( class -- )
    dup class>type [ eq? ] curry [ tag ] prepend define-predicate ;

: define-builtin ( symbol slotspec -- )
    [ [ define-builtin-predicate ] keep ] dip define-builtin-slots ;

"fixnum" "math" create-word register-builtin
"bignum" "math" create-word register-builtin
"tuple" "kernel" create-word register-builtin
"float" "math" create-word register-builtin
"f" "syntax" lookup-word register-builtin
"array" "arrays" create-word register-builtin
"wrapper" "kernel" create-word register-builtin
"callstack" "kernel" create-word register-builtin
"string" "strings" create-word register-builtin
"quotation" "quotations" create-word register-builtin
"dll" "alien" create-word register-builtin
"alien" "alien" create-word register-builtin
"word" "words" create-word register-builtin
"byte-array" "byte-arrays" create-word register-builtin

! We need this before defining c-ptr below
"f" "syntax" lookup-word { } define-builtin

"f" "syntax" create-word [ not ] "predicate" set-word-prop
"f?" "syntax" vocab-words-assoc delete-at

"t" "syntax" lookup-word define-singleton-class

! Some unions
"c-ptr" "alien" create-word [
    "alien" "alien" lookup-word ,
    "f" "syntax" lookup-word ,
    "byte-array" "byte-arrays" lookup-word ,
] { } make define-union-class

"integer" "math" create-word
"fixnum" "math" lookup-word "bignum" "math" lookup-word 2array
define-union-class

! Two predicate classes used for declarations.
"array-capacity" "sequences.private" create-word
"fixnum" "math" lookup-word
[
    [ dup 0 fixnum>= ] %
    bootstrap-max-array-capacity <fake-bignum> [ fixnum<= ] curry ,
    [ [ drop f ] if ] %
] [ ] make
define-predicate-class

"array-capacity" "sequences.private" lookup-word
[ >fixnum ] bootstrap-max-array-capacity <fake-bignum> [ fixnum-bitand ] curry append
"coercer" set-word-prop

"integer-array-capacity" "sequences.private" create-word
"integer" "math" lookup-word
[
    [ dup 0 >= ] %
    bootstrap-max-array-capacity <fake-bignum> [ <= ] curry ,
    [ [ drop f ] if ] %
] [ ] make
define-predicate-class

! Catch-all class for providing a default method.
"object" "kernel" create-word
[ f f { } intersection-class define-class ]
[ [ drop t ] "predicate" set-word-prop ]
bi

"object?" "kernel" vocab-words-assoc delete-at

! Empty class with no instances
"null" "kernel" create-word
[ f { } f union-class define-class ]
[ [ drop f ] "predicate" set-word-prop ]
bi

"null?" "kernel" vocab-words-assoc delete-at

"fixnum" "math" create-word { } define-builtin
"fixnum" "math" create-word "integer>fixnum-strict" "math" create-word 1quotation "coercer" set-word-prop

"bignum" "math" create-word { } define-builtin
"bignum" "math" create-word ">bignum" "math" create-word 1quotation "coercer" set-word-prop

"float" "math" create-word { } define-builtin
"float" "math" create-word ">float" "math" create-word 1quotation "coercer" set-word-prop

"array" "arrays" create-word {
    { "length" { "array-capacity" "sequences.private" } read-only }
} define-builtin

"wrapper" "kernel" create-word {
    { "wrapped" read-only }
} define-builtin

"string" "strings" create-word {
    { "length" { "array-capacity" "sequences.private" } read-only }
    "aux"
} define-builtin

"quotation" "quotations" create-word {
    { "array" { "array" "arrays" } read-only }
    "cached-effect"
    "cache-counter"
} define-builtin

"dll" "alien" create-word {
    { "path" { "byte-array" "byte-arrays" } read-only }
} define-builtin

"alien" "alien" create-word {
    { "underlying" { "c-ptr" "alien" } read-only }
    "expired"
} define-builtin

"word" "words" create-word {
    { "hashcode" { "fixnum" "math" } }
    "name"
    "vocabulary"
    { "def" { "quotation" "quotations" } initial: [ ] }
    "props"
    "pic-def"
    "pic-tail-def"
    { "sub-primitive" read-only }
} define-builtin

"byte-array" "byte-arrays" create-word {
    { "length" { "array-capacity" "sequences.private" } read-only }
} define-builtin

"callstack" "kernel" create-word { } define-builtin

"tuple" "kernel" create-word
[ { } define-builtin ]
[ define-tuple-layout ]
bi

! create-word special tombstone values
"tombstone" "hashtables.private" create-word
tuple
{ "state" } define-tuple-class

"((empty))" "hashtables.private" create-word
{ f } "tombstone" "hashtables.private" lookup-word
slots>tuple 1quotation ( -- value ) define-inline

"((tombstone))" "hashtables.private" create-word
{ t } "tombstone" "hashtables.private" lookup-word
slots>tuple 1quotation ( -- value ) define-inline

! Some tuple classes
"curry" "kernel" create-word
tuple
{
    { "obj" read-only }
    { "quot" read-only }
} prepare-slots define-tuple-class

"curry" "kernel" lookup-word
{
    [ f "inline" set-word-prop ]
    [ make-flushable ]
    [ ]
    [
        [
            callable instance-check-quot %
            tuple-layout ,
            \ <tuple-boa> ,
        ] [ ] make
    ]
} cleave
( obj quot -- curry ) define-declared

"compose" "kernel" create-word
tuple
{
    { "first" read-only }
    { "second" read-only }
} prepare-slots define-tuple-class

"compose" "kernel" lookup-word
{
    [ f "inline" set-word-prop ]
    [ make-flushable ]
    [ ]
    [
        [
            callable instance-check-quot [ dip ] curry %
            callable instance-check-quot %
            tuple-layout ,
            \ <tuple-boa> ,
        ] [ ] make
    ]
} cleave
( quot1 quot2 -- compose ) define-declared

! Sub-primitive words
: make-sub-primitive ( word vocab effect -- )
    [
        create-word
        dup t "primitive" set-word-prop
        dup 1quotation
    ] dip define-declared ;

{
    { "mega-cache-lookup" "generic.single.private" ( methods index cache -- ) }
    { "inline-cache-miss" "generic.single.private" ( generic methods index cache -- ) }
    { "inline-cache-miss-tail" "generic.single.private" ( generic methods index cache -- ) }
    { "drop" "kernel" ( x -- ) }
    { "2drop" "kernel" ( x y -- ) }
    { "3drop" "kernel" ( x y z -- ) }
    { "4drop" "kernel" ( w x y z -- ) }
    { "dup" "kernel" ( x -- x x ) }
    { "2dup" "kernel" ( x y -- x y x y ) }
    { "3dup" "kernel" ( x y z -- x y z x y z ) }
    { "4dup" "kernel" ( w x y z -- w x y z w x y z ) }
    { "rot" "kernel" ( x y z -- y z x ) }
    { "-rot" "kernel" ( x y z -- z x y ) }
    { "dupd" "kernel" ( x y -- x x y ) }
    { "swapd" "kernel" ( x y z -- y x z ) }
    { "nip" "kernel" ( x y -- y ) }
    { "2nip" "kernel" ( x y z -- z ) }
    { "over" "kernel" ( x y -- x y x ) }
    { "pick" "kernel" ( x y z -- x y z x ) }
    { "swap" "kernel" ( x y -- y x ) }
    { "eq?" "kernel" ( obj1 obj2 -- ? ) }
    { "tag" "kernel.private" ( object -- n ) }
    { "(execute)" "kernel.private" ( word -- ) }
    { "(call)" "kernel.private" ( quot -- ) }
    { "fpu-state" "kernel.private" ( -- ) }
    { "set-fpu-state" "kernel.private" ( -- ) }
    { "signal-handler" "kernel.private" ( -- ) }
    { "leaf-signal-handler" "kernel.private" ( -- ) }
    { "unwind-native-frames" "kernel.private" ( -- ) }
    { "set-callstack" "kernel.private" ( callstack -- * ) }
    { "lazy-jit-compile" "kernel.private" ( -- ) }
    { "c-to-factor" "kernel.private" ( -- ) }
    { "slot" "slots.private" ( obj m -- value ) }
    { "get-local" "locals.backend" ( n -- obj ) }
    { "load-local" "locals.backend" ( obj -- ) }
    { "drop-locals" "locals.backend" ( n -- ) }
    { "both-fixnums?" "math.private" ( x y -- ? ) }
    { "fixnum+fast" "math.private" ( x y -- z ) }
    { "fixnum-fast" "math.private" ( x y -- z ) }
    { "fixnum*fast" "math.private" ( x y -- z ) }
    { "fixnum-bitand" "math.private" ( x y -- z ) }
    { "fixnum-bitor" "math.private" ( x y -- z ) }
    { "fixnum-bitxor" "math.private" ( x y -- z ) }
    { "fixnum-bitnot" "math.private" ( x -- y ) }
    { "fixnum-mod" "math.private" ( x y -- z ) }
    { "fixnum-shift-fast" "math.private" ( x y -- z ) }
    { "fixnum/i-fast" "math.private" ( x y -- z ) }
    { "fixnum/mod-fast" "math.private" ( x y -- z w ) }
    { "fixnum+" "math.private" ( x y -- z ) }
    { "fixnum-" "math.private" ( x y -- z ) }
    { "fixnum*" "math.private" ( x y -- z ) }
    { "fixnum<" "math.private" ( x y -- ? ) }
    { "fixnum<=" "math.private" ( x y -- z ) }
    { "fixnum>" "math.private" ( x y -- ? ) }
    { "fixnum>=" "math.private" ( x y -- ? ) }
    { "string-nth-fast" "strings.private" ( n string -- ch ) }
    { "(set-context)" "threads.private" ( obj context -- obj' ) }
    { "(set-context-and-delete)" "threads.private" ( obj context -- * ) }
    { "(start-context)" "threads.private" ( obj quot -- obj' ) }
    { "(start-context-and-delete)" "threads.private" ( obj quot -- * ) }
} [ first3 make-sub-primitive ] each

! Primitive words
: make-primitive ( word vocab function effect -- )
    [
        [
            create-word
            dup reset-word
            dup t "primitive" set-word-prop
        ] dip
        ascii string>alien [ do-primitive ] curry
    ] dip define-declared ;

{
    { "<callback>" "alien" "primitive_callback" ( word return-rewind -- alien ) }
    { "<displaced-alien>" "alien" "primitive_displaced_alien" ( displacement c-ptr -- alien ) }
    { "alien-address" "alien" "primitive_alien_address" ( c-ptr -- addr ) }
    { "alien-cell" "alien.accessors" "primitive_alien_cell" ( c-ptr n -- value ) }
    { "alien-double" "alien.accessors" "primitive_alien_double" ( c-ptr n -- value ) }
    { "alien-float" "alien.accessors" "primitive_alien_float" ( c-ptr n -- value ) }
    { "alien-signed-1" "alien.accessors" "primitive_alien_signed_1" ( c-ptr n -- value ) }
    { "alien-signed-2" "alien.accessors" "primitive_alien_signed_2" ( c-ptr n -- value ) }
    { "alien-signed-4" "alien.accessors" "primitive_alien_signed_4" ( c-ptr n -- value ) }
    { "alien-signed-8" "alien.accessors" "primitive_alien_signed_8" ( c-ptr n -- value ) }
    { "alien-signed-cell" "alien.accessors" "primitive_alien_signed_cell" ( c-ptr n -- value ) }
    { "alien-unsigned-1" "alien.accessors" "primitive_alien_unsigned_1" ( c-ptr n -- value ) }
    { "alien-unsigned-2" "alien.accessors" "primitive_alien_unsigned_2" ( c-ptr n -- value ) }
    { "alien-unsigned-4" "alien.accessors" "primitive_alien_unsigned_4" ( c-ptr n -- value ) }
    { "alien-unsigned-8" "alien.accessors" "primitive_alien_unsigned_8" ( c-ptr n -- value ) }
    { "alien-unsigned-cell" "alien.accessors" "primitive_alien_unsigned_cell" ( c-ptr n -- value ) }
    { "set-alien-cell" "alien.accessors" "primitive_set_alien_cell" ( value c-ptr n -- ) }
    { "set-alien-double" "alien.accessors" "primitive_set_alien_double" ( value c-ptr n -- ) }
    { "set-alien-float" "alien.accessors" "primitive_set_alien_float" ( value c-ptr n -- ) }
    { "set-alien-signed-1" "alien.accessors" "primitive_set_alien_signed_1" ( value c-ptr n -- ) }
    { "set-alien-signed-2" "alien.accessors" "primitive_set_alien_signed_2" ( value c-ptr n -- ) }
    { "set-alien-signed-4" "alien.accessors" "primitive_set_alien_signed_4" ( value c-ptr n -- ) }
    { "set-alien-signed-8" "alien.accessors" "primitive_set_alien_signed_8" ( value c-ptr n -- ) }
    { "set-alien-signed-cell" "alien.accessors" "primitive_set_alien_signed_cell" ( value c-ptr n -- ) }
    { "set-alien-unsigned-1" "alien.accessors" "primitive_set_alien_unsigned_1" ( value c-ptr n -- ) }
    { "set-alien-unsigned-2" "alien.accessors" "primitive_set_alien_unsigned_2" ( value c-ptr n -- ) }
    { "set-alien-unsigned-4" "alien.accessors" "primitive_set_alien_unsigned_4" ( value c-ptr n -- ) }
    { "set-alien-unsigned-8" "alien.accessors" "primitive_set_alien_unsigned_8" ( value c-ptr n -- ) }
    { "set-alien-unsigned-cell" "alien.accessors" "primitive_set_alien_unsigned_cell" ( value c-ptr n -- ) }
    { "(dlopen)" "alien.libraries" "primitive_dlopen" ( path -- dll ) }
    { "(dlsym)" "alien.libraries" "primitive_dlsym" ( name dll -- alien ) }
    { "(dlsym-raw)" "alien.libraries" "primitive_dlsym_raw" ( name dll -- alien ) }
    { "dlclose" "alien.libraries" "primitive_dlclose" ( dll -- ) }
    { "dll-valid?" "alien.libraries" "primitive_dll_validp" ( dll -- ? ) }
    { "current-callback" "alien.private" "primitive_current_callback" ( -- n ) }
    { "<array>" "arrays" "primitive_array" ( n elt -- array ) }
    { "resize-array" "arrays" "primitive_resize_array" ( n array -- new-array ) }
    { "(byte-array)" "byte-arrays" "primitive_uninitialized_byte_array" ( n -- byte-array ) }
    { "<byte-array>" "byte-arrays" "primitive_byte_array" ( n -- byte-array ) }
    { "resize-byte-array" "byte-arrays" "primitive_resize_byte_array" ( n byte-array -- new-byte-array ) }
    { "<tuple-boa>" "classes.tuple.private" "primitive_tuple_boa" ( slots... layout -- tuple ) }
    { "<tuple>" "classes.tuple.private" "primitive_tuple" ( layout -- tuple ) }
    { "modify-code-heap" "compiler.units" "primitive_modify_code_heap" ( alist update-existing? reset-pics? -- ) }
    { "lookup-method" "generic.single.private" "primitive_lookup_method" ( object methods -- method ) }
    { "mega-cache-miss" "generic.single.private" "primitive_mega_cache_miss" ( methods index cache -- method ) }
    { "(exists?)" "io.files.private" "primitive_existsp" ( path -- ? ) }
    { "(fopen)" "io.streams.c" "primitive_fopen" ( path mode -- alien ) }
    { "fclose" "io.streams.c" "primitive_fclose" ( alien -- ) }
    { "fflush" "io.streams.c" "primitive_fflush" ( alien -- ) }
    { "fgetc" "io.streams.c" "primitive_fgetc" ( alien -- byte/f ) }
    { "fputc" "io.streams.c" "primitive_fputc" ( byte alien -- ) }
    { "fread-unsafe" "io.streams.c" "primitive_fread" ( n buf alien -- count ) }
    { "free-callback" "alien" "primitive_free_callback" ( alien -- ) }
    { "fseek" "io.streams.c" "primitive_fseek" ( alien offset whence -- ) }
    { "ftell" "io.streams.c" "primitive_ftell" ( alien -- n ) }
    { "fwrite" "io.streams.c" "primitive_fwrite" ( data length alien -- ) }
    { "(clone)" "kernel" "primitive_clone" ( obj -- newobj ) }
    { "<wrapper>" "kernel" "primitive_wrapper" ( obj -- wrapper ) }

    { "callstack>array" "kernel" "primitive_callstack_to_array" ( callstack -- array ) }
    { "die" "kernel" "primitive_die" ( -- ) }
    { "callstack-for" "kernel.private" "primitive_callstack_for" ( context -- array ) }
    { "datastack-for" "kernel.private" "primitive_datastack_for" ( context -- array ) }
    { "retainstack-for" "kernel.private" "primitive_retainstack_for" ( context -- array ) }
    { "(identity-hashcode)" "kernel.private" "primitive_identity_hashcode" ( obj -- code ) }
    { "become" "kernel.private" "primitive_become" ( old new -- ) }
    { "callstack-bounds" "kernel.private" "primitive_callstack_bounds" ( -- start end ) }
    { "check-datastack" "kernel.private" "primitive_check_datastack" ( array in# out# -- ? ) }
    { "compute-identity-hashcode" "kernel.private" "primitive_compute_identity_hashcode" ( obj -- ) }
    { "context-object" "kernel.private" "primitive_context_object" ( n -- obj ) }
    { "innermost-frame-executing" "kernel.private" "primitive_innermost_stack_frame_executing" ( callstack -- obj ) }
    { "innermost-frame-scan" "kernel.private" "primitive_innermost_stack_frame_scan" ( callstack -- n ) }
    { "set-context-object" "kernel.private" "primitive_set_context_object" ( obj n -- ) }
    { "set-datastack" "kernel.private" "primitive_set_datastack" ( array -- ) }
    { "set-innermost-frame-quotation" "kernel.private" "primitive_set_innermost_stack_frame_quotation" ( n callstack -- ) }
    { "set-retainstack" "kernel.private" "primitive_set_retainstack" ( array -- ) }
    { "set-special-object" "kernel.private" "primitive_set_special_object" ( obj n -- ) }
    { "special-object" "kernel.private" "primitive_special_object" ( n -- obj ) }
    { "strip-stack-traces" "kernel.private" "primitive_strip_stack_traces" ( -- ) }
    { "unimplemented" "kernel.private" "primitive_unimplemented" ( -- * ) }
    { "load-locals" "locals.backend" "primitive_load_locals" ( ... n -- ) }
    { "bits>double" "math" "primitive_bits_double" ( n -- x ) }
    { "bits>float" "math" "primitive_bits_float" ( n -- x ) }
    { "double>bits" "math" "primitive_double_bits" ( x -- n ) }
    { "float>bits" "math" "primitive_float_bits" ( x -- n ) }
    { "(format-float)" "math.parser.private" "primitive_format_float" ( n fill width precision format locale -- byte-array ) }
    { "bignum*" "math.private" "primitive_bignum_multiply" ( x y -- z ) }
    { "bignum+" "math.private" "primitive_bignum_add" ( x y -- z ) }
    { "bignum-" "math.private" "primitive_bignum_subtract" ( x y -- z ) }
    { "bignum-bit?" "math.private" "primitive_bignum_bitp" ( x n -- ? ) }
    { "bignum-bitand" "math.private" "primitive_bignum_and" ( x y -- z ) }
    { "bignum-bitnot" "math.private" "primitive_bignum_not" ( x -- y ) }
    { "bignum-bitor" "math.private" "primitive_bignum_or" ( x y -- z ) }
    { "bignum-bitxor" "math.private" "primitive_bignum_xor" ( x y -- z ) }
    { "bignum-log2" "math.private" "primitive_bignum_log2" ( x -- n ) }
    { "bignum-mod" "math.private" "primitive_bignum_mod" ( x y -- z ) }
    { "bignum-gcd" "math.private" "primitive_bignum_gcd" ( x y -- z ) }
    { "bignum-shift" "math.private" "primitive_bignum_shift" ( x y -- z ) }
    { "bignum/i" "math.private" "primitive_bignum_divint" ( x y -- z ) }
    { "bignum/mod" "math.private" "primitive_bignum_divmod" ( x y -- z w ) }
    { "bignum<" "math.private" "primitive_bignum_less" ( x y -- ? ) }
    { "bignum<=" "math.private" "primitive_bignum_lesseq" ( x y -- ? ) }
    { "bignum=" "math.private" "primitive_bignum_eq" ( x y -- ? ) }
    { "bignum>" "math.private" "primitive_bignum_greater" ( x y -- ? ) }
    { "bignum>=" "math.private" "primitive_bignum_greatereq" ( x y -- ? ) }
    { "bignum>fixnum" "math.private" "primitive_bignum_to_fixnum" ( x -- y ) }
    { "bignum>fixnum-strict" "math.private" "primitive_bignum_to_fixnum_strict" ( x -- y ) }
    { "fixnum-shift" "math.private" "primitive_fixnum_shift" ( x y -- z ) }
    { "fixnum/i" "math.private" "primitive_fixnum_divint" ( x y -- z ) }
    { "fixnum/mod" "math.private" "primitive_fixnum_divmod" ( x y -- z w ) }
    { "fixnum>bignum" "math.private" "primitive_fixnum_to_bignum" ( x -- y ) }
    { "fixnum>float" "math.private" "primitive_fixnum_to_float" ( x -- y ) }
    { "float*" "math.private" "primitive_float_multiply" ( x y -- z ) }
    { "float+" "math.private" "primitive_float_add" ( x y -- z ) }
    { "float-" "math.private" "primitive_float_subtract" ( x y -- z ) }
    { "float-u<" "math.private" "primitive_float_less" ( x y -- ? ) }
    { "float-u<=" "math.private" "primitive_float_lesseq" ( x y -- ? ) }
    { "float-u>" "math.private" "primitive_float_greater" ( x y -- ? ) }
    { "float-u>=" "math.private" "primitive_float_greatereq" ( x y -- ? ) }
    { "float/f" "math.private" "primitive_float_divfloat" ( x y -- z ) }
    { "float<" "math.private" "primitive_float_less" ( x y -- ? ) }
    { "float<=" "math.private" "primitive_float_lesseq" ( x y -- ? ) }
    { "float=" "math.private" "primitive_float_eq" ( x y -- ? ) }
    { "float>" "math.private" "primitive_float_greater" ( x y -- ? ) }
    { "float>=" "math.private" "primitive_float_greatereq" ( x y -- ? ) }
    { "float>bignum" "math.private" "primitive_float_to_bignum" ( x -- y ) }
    { "float>fixnum" "math.private" "primitive_float_to_fixnum" ( x -- y ) }
    { "all-instances" "memory" "primitive_all_instances" ( -- array ) }
    { "(code-blocks)" "tools.memory.private" "primitive_code_blocks" ( -- array ) }
    { "(code-room)" "tools.memory.private" "primitive_code_room" ( -- allocator-room ) }
    { "compact-gc" "memory" "primitive_compact_gc" ( -- ) }
    { "(callback-room)" "tools.memory.private" "primitive_callback_room" ( -- allocator-room ) }
    { "(data-room)" "tools.memory.private" "primitive_data_room" ( -- data-room ) }
    { "disable-gc-events" "tools.memory.private" "primitive_disable_gc_events" ( -- events ) }
    { "enable-gc-events" "tools.memory.private" "primitive_enable_gc_events" ( -- ) }
    { "gc" "memory" "primitive_full_gc" ( -- ) }
    { "minor-gc" "memory" "primitive_minor_gc" ( -- ) }
    { "size" "memory" "primitive_size" ( obj -- n ) }
    { "(save-image)" "memory.private" "primitive_save_image" ( path1 path2 then-die? -- ) }
    { "jit-compile" "quotations" "primitive_jit_compile" ( quot -- ) }
    { "quotation-code" "quotations" "primitive_quotation_code" ( quot -- start end ) }
    { "quotation-compiled?" "quotations" "primitive_quotation_compiled_p" ( quot -- ? ) }
    { "array>quotation" "quotations.private" "primitive_array_to_quotation" ( array -- quot ) }
    { "set-slot" "slots.private" "primitive_set_slot" ( value obj n -- ) }
    { "<string>" "strings" "primitive_string" ( n ch -- string ) }
    { "resize-string" "strings" "primitive_resize_string" ( n str -- newstr ) }
    { "set-string-nth-fast" "strings.private" "primitive_set_string_nth_fast" ( ch n string -- ) }
    { "(exit)" "system" "primitive_exit" ( n -- * ) }
    { "nano-count" "system" "primitive_nano_count" ( -- ns ) }
    { "(sleep)" "threads.private" "primitive_sleep" ( nanos -- ) }
    { "context-object-for" "threads.private" "primitive_context_object_for" ( n context -- obj ) }
    { "dispatch-stats" "tools.dispatch.private" "primitive_dispatch_stats" ( -- stats ) }
    { "reset-dispatch-stats" "tools.dispatch.private" "primitive_reset_dispatch_stats" ( -- ) }
    { "word-code" "words" "primitive_word_code" ( word -- start end ) }
    { "word-optimized?" "words" "primitive_word_optimized_p" ( word -- ? ) }
    { "(word)" "words.private" "primitive_word" ( name vocab hashcode -- word ) }
    { "profiling" "tools.profiler.sampling.private" "primitive_sampling_profiler" ( ? -- ) }
    { "(get-samples)" "tools.profiler.sampling.private" "primitive_get_samples" ( -- samples/f ) }
    { "(clear-samples)" "tools.profiler.sampling.private" "primitive_clear_samples" ( -- ) }
} [ first4 make-primitive ] each

! Bump build number
"build" "kernel" create-word build 1 + [ ] curry ( -- n ) define-declared

] with-compilation-unit
