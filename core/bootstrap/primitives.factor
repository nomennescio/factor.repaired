! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays byte-arrays generic hashtables
hashtables.private io kernel math math.order namespaces parser
sequences strings vectors words quotations assocs layouts
classes classes.builtin classes.tuple classes.tuple.private
kernel.private vocabs vocabs.loader source-files definitions
slots classes.union classes.intersection classes.predicate
compiler.units bootstrap.image.private io.files accessors combinators ;
IN: bootstrap.primitives

"Creating primitives and basic runtime structures..." print flush

crossref off

H{ } clone sub-primitives set

"resource:core/bootstrap/syntax.factor" parse-file

"resource:core/cpu/" architecture get {
    { "x86.32" "x86/32" }
    { "x86.64" "x86/64" }
    { "linux-ppc" "ppc/linux" }
    { "macosx-ppc" "ppc/macosx" }
    { "arm" "arm" }
} at "/bootstrap.factor" 3append parse-file

"resource:core/bootstrap/layouts/layouts.factor" parse-file

! Now we have ( syntax-quot arch-quot layouts-quot ) on the stack

! Bring up a bare cross-compiling vocabulary.
"syntax" vocab vocab-words bootstrap-syntax set
H{ } clone dictionary set
H{ } clone new-classes set
H{ } clone changed-definitions set
H{ } clone forgotten-definitions set
H{ } clone root-cache set
H{ } clone source-files set
H{ } clone update-map set
H{ } clone implementors-map set
init-caches

! Vocabulary for slot accessors
"accessors" create-vocab drop

! Trivial recompile hook. We don't want to touch the code heap
! during stage1 bootstrap, it would just waste time.
[ drop { } ] recompile-hook set

call
call
call

! After we execute bootstrap/layouts
num-types get f <array> builtins set

bootstrapping? on

! Create some empty vocabs where the below primitives and
! classes will go
{
    "alien"
    "alien.accessors"
    "arrays"
    "byte-arrays"
    "byte-vectors"
    "classes.private"
    "classes.tuple"
    "classes.tuple.private"
    "classes.predicate"
    "compiler.units"
    "continuations.private"
    "generator"
    "growable"
    "hashtables"
    "hashtables.private"
    "io"
    "io.files"
    "io.files.private"
    "io.streams.c"
    "kernel"
    "kernel.private"
    "math"
    "math.private"
    "memory"
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
    "tools.profiler.private"
    "words"
    "words.private"
    "vectors"
    "vectors.private"
} [ create-vocab drop ] each

! Builtin classes
: define-builtin-predicate ( class -- )
    dup class>type [ builtin-instance? ] curry define-predicate ;

: lookup-type-number ( word -- n )
    global [ target-word ] bind type-number ;

: register-builtin ( class -- )
    [ dup lookup-type-number "type" set-word-prop ]
    [ dup "type" word-prop builtins get set-nth ]
    [ f f f builtin-class define-class ]
    tri ;

: prepare-slots ( slots -- slots' )
    [ [ dup pair? [ first2 create ] when ] map ] map ;

: define-builtin-slots ( class slots -- )
    prepare-slots 1 make-slots
    [ "slots" set-word-prop ] [ define-accessors ] 2bi ;

: define-builtin ( symbol slotspec -- )
    >r [ define-builtin-predicate ] keep
    r> define-builtin-slots ;

"fixnum" "math" create register-builtin
"bignum" "math" create register-builtin
"tuple" "kernel" create register-builtin
"ratio" "math" create register-builtin
"float" "math" create register-builtin
"complex" "math" create register-builtin
"f" "syntax" lookup register-builtin
"array" "arrays" create register-builtin
"wrapper" "kernel" create register-builtin
"callstack" "kernel" create register-builtin
"string" "strings" create register-builtin
"quotation" "quotations" create register-builtin
"dll" "alien" create register-builtin
"alien" "alien" create register-builtin
"word" "words" create register-builtin
"byte-array" "byte-arrays" create register-builtin
"tuple-layout" "classes.tuple.private" create register-builtin

! For predicate classes
"predicate-instance?" "classes.predicate" create drop

! We need this before defining c-ptr below
"f" "syntax" lookup { } define-builtin

"f" "syntax" create [ not ] "predicate" set-word-prop
"f?" "syntax" vocab-words delete-at

! Some unions
"integer" "math" create
"fixnum" "math" lookup
"bignum" "math" lookup
2array
define-union-class

"rational" "math" create
"integer" "math" lookup
"ratio" "math" lookup
2array
define-union-class

"real" "math" create
"rational" "math" lookup
"float" "math" lookup
2array
define-union-class

"c-ptr" "alien" create [
    "alien" "alien" lookup ,
    "f" "syntax" lookup ,
    "byte-array" "byte-arrays" lookup ,
] { } make define-union-class

! A predicate class used for declarations
"array-capacity" "sequences.private" create
"fixnum" "math" lookup
0 bootstrap-max-array-capacity <fake-bignum> [ between? ] 2curry
define-predicate-class

! Catch-all class for providing a default method.
"object" "kernel" create
[ f f { } intersection-class define-class ]
[ [ drop t ] "predicate" set-word-prop ]
bi

"object?" "kernel" vocab-words delete-at

! Class of objects with object tag
"hi-tag" "kernel.private" create
builtins get num-tags get tail define-union-class

! Empty class with no instances
"null" "kernel" create
[ f { } f union-class define-class ]
[ [ drop f ] "predicate" set-word-prop ]
bi

"null?" "kernel" vocab-words delete-at

"fixnum" "math" create { } define-builtin
"fixnum" "math" create ">fixnum" "math" create 1quotation "coercer" set-word-prop

"bignum" "math" create { } define-builtin
"bignum" "math" create ">bignum" "math" create 1quotation "coercer" set-word-prop

"ratio" "math" create {
    { "numerator" { "integer" "math" } read-only }
    { "denominator" { "integer" "math" } read-only }
} define-builtin

"float" "math" create { } define-builtin
"float" "math" create ">float" "math" create 1quotation "coercer" set-word-prop

"complex" "math" create {
    { "real" { "real" "math" } read-only }
    { "imaginary" { "real" "math" } read-only }
} define-builtin

"array" "arrays" create { } define-builtin

"wrapper" "kernel" create {
    { "wrapped" read-only }
} define-builtin

"string" "strings" create {
    { "length" { "array-capacity" "sequences.private" } read-only }
    "aux"
} define-builtin

"quotation" "quotations" create {
    { "array" { "array" "arrays" } read-only }
    { "compiled" read-only }
} define-builtin

"dll" "alien" create {
    { "path" { "byte-array" "byte-arrays" } read-only }
} define-builtin

"alien" "alien" create {
    { "underlying" { "c-ptr" "alien" } read-only }
    "expired"
} define-builtin

"word" "words" create {
    { "hashcode" { "fixnum" "math" } }
    "name"
    "vocabulary"
    { "def" { "quotation" "quotations" } initial: [ ] }
    "props"
    { "compiled" read-only }
    { "counter" { "fixnum" "math" } }
    { "sub-primitive" read-only }
} define-builtin

"byte-array" "byte-arrays" create { } define-builtin

"callstack" "kernel" create { } define-builtin

"tuple-layout" "classes.tuple.private" create {
    { "hashcode" { "fixnum" "math" } read-only }
    { "class" { "word" "words" } initial: t read-only }
    { "size" { "fixnum" "math" } read-only }
    { "superclasses" { "array" "arrays" } initial: { } read-only }
    { "echelon" { "fixnum" "math" } read-only }
} define-builtin

"tuple" "kernel" create {
    [ { } define-builtin ]
    [ { "delegate" } "slot-names" set-word-prop ]
    [ define-tuple-layout ]
    [
        { "delegate" }
        [ drop ] [ generate-tuple-slots ] 2bi
        [ "slots" set-word-prop ]
        [ define-accessors ]
        2bi
    ]
} cleave

! Create special tombstone values
"tombstone" "hashtables.private" create
tuple
{ } define-tuple-class

"((empty))" "hashtables.private" create
"tombstone" "hashtables.private" lookup f
2array >tuple 1quotation define-inline

"((tombstone))" "hashtables.private" create
"tombstone" "hashtables.private" lookup t
2array >tuple 1quotation define-inline

! Some tuple classes
"curry" "kernel" create
tuple
{
    { "obj" read-only }
    { "quot" read-only }
} prepare-slots define-tuple-class

"curry" "kernel" lookup
[ f "inline" set-word-prop ]
[ ]
[ tuple-layout [ <tuple-boa> ] curry ] tri
(( obj quot -- curry )) define-declared

"compose" "kernel" create
tuple
{
    { "first" read-only }
    { "second" read-only }
} prepare-slots define-tuple-class

"compose" "kernel" lookup
[ f "inline" set-word-prop ]
[ ]
[ tuple-layout [ <tuple-boa> ] curry ] tri
(( quot1 quot2 -- compose )) define-declared

! Sub-primitive words
: make-sub-primitive ( word vocab -- )
    create
    dup reset-word
    dup 1quotation define ;

{
    { "(execute)" "words.private" }
    { "(call)" "kernel.private" }
    { "fixnum+fast" "math.private" }
    { "fixnum-fast" "math.private" }
    { "fixnum*fast" "math.private" }
    { "fixnum-bitand" "math.private" }
    { "fixnum-bitor" "math.private" }
    { "fixnum-bitxor" "math.private" }
    { "fixnum-bitnot" "math.private" }
    { "fixnum<" "math.private" }
    { "fixnum<=" "math.private" }
    { "fixnum>" "math.private" }
    { "fixnum>=" "math.private" }
    { "drop" "kernel" }
    { "2drop" "kernel" }
    { "3drop" "kernel" }
    { "dup" "kernel" }
    { "2dup" "kernel" }
    { "3dup" "kernel" }
    { "rot" "kernel" }
    { "-rot" "kernel" }
    { "dupd" "kernel" }
    { "swapd" "kernel" }
    { "nip" "kernel" }
    { "2nip" "kernel" }
    { "tuck" "kernel" }
    { "over" "kernel" }
    { "pick" "kernel" }
    { "swap" "kernel" }
    { ">r" "kernel" }
    { "r>" "kernel" }
    { "eq?" "kernel" }
    { "tag" "kernel.private" }
    { "slot" "slots.private" }
} [ make-sub-primitive ] assoc-each

! Primitive words
: make-primitive ( word vocab n -- )
    >r create dup reset-word r>
    [ do-primitive ] curry [ ] like define ;

{
    { "bignum>fixnum" "math.private" }
    { "float>fixnum" "math.private" }
    { "fixnum>bignum" "math.private" }
    { "float>bignum" "math.private" }
    { "fixnum>float" "math.private" }
    { "bignum>float" "math.private" }
    { "<ratio>" "math.private" }
    { "string>float" "math.private" }
    { "float>string" "math.private" }
    { "float>bits" "math" }
    { "double>bits" "math" }
    { "bits>float" "math" }
    { "bits>double" "math" }
    { "<complex>" "math.private" }
    { "fixnum+" "math.private" }
    { "fixnum-" "math.private" }
    { "fixnum*" "math.private" }
    { "fixnum/i" "math.private" }
    { "fixnum-mod" "math.private" }
    { "fixnum/mod" "math.private" }
    { "fixnum-shift" "math.private" }
    { "fixnum-shift-fast" "math.private" }
    { "bignum=" "math.private" }
    { "bignum+" "math.private" }
    { "bignum-" "math.private" }
    { "bignum*" "math.private" }
    { "bignum/i" "math.private" }
    { "bignum-mod" "math.private" }
    { "bignum/mod" "math.private" }
    { "bignum-bitand" "math.private" }
    { "bignum-bitor" "math.private" }
    { "bignum-bitxor" "math.private" }
    { "bignum-bitnot" "math.private" }
    { "bignum-shift" "math.private" }
    { "bignum<" "math.private" }
    { "bignum<=" "math.private" }
    { "bignum>" "math.private" }
    { "bignum>=" "math.private" }
    { "bignum-bit?" "math.private" }
    { "bignum-log2" "math.private" }
    { "byte-array>bignum" "math" }
    { "float=" "math.private" }
    { "float+" "math.private" }
    { "float-" "math.private" }
    { "float*" "math.private" }
    { "float/f" "math.private" }
    { "float-mod" "math.private" }
    { "float<" "math.private" }
    { "float<=" "math.private" }
    { "float>" "math.private" }
    { "float>=" "math.private" }
    { "<word>" "words" }
    { "word-xt" "words" }
    { "getenv" "kernel.private" }
    { "setenv" "kernel.private" }
    { "(exists?)" "io.files.private" }
    { "(directory)" "io.files.private" }
    { "gc" "memory" }
    { "gc-stats" "memory" }
    { "save-image" "memory" }
    { "save-image-and-exit" "memory" }
    { "datastack" "kernel" }
    { "retainstack" "kernel" }
    { "callstack" "kernel" }
    { "set-datastack" "kernel" }
    { "set-retainstack" "kernel" }
    { "set-callstack" "kernel" }
    { "exit" "system" }
    { "data-room" "memory" }
    { "code-room" "memory" }
    { "os-env" "system" }
    { "millis" "system" }
    { "modify-code-heap" "compiler.units" }
    { "dlopen" "alien" }
    { "dlsym" "alien" }
    { "dlclose" "alien" }
    { "<byte-array>" "byte-arrays" }
    { "<displaced-alien>" "alien" }
    { "alien-signed-cell" "alien.accessors" }
    { "set-alien-signed-cell" "alien.accessors" }
    { "alien-unsigned-cell" "alien.accessors" }
    { "set-alien-unsigned-cell" "alien.accessors" }
    { "alien-signed-8" "alien.accessors" }
    { "set-alien-signed-8" "alien.accessors" }
    { "alien-unsigned-8" "alien.accessors" }
    { "set-alien-unsigned-8" "alien.accessors" }
    { "alien-signed-4" "alien.accessors" }
    { "set-alien-signed-4" "alien.accessors" }
    { "alien-unsigned-4" "alien.accessors" }
    { "set-alien-unsigned-4" "alien.accessors" }
    { "alien-signed-2" "alien.accessors" }
    { "set-alien-signed-2" "alien.accessors" }
    { "alien-unsigned-2" "alien.accessors" }
    { "set-alien-unsigned-2" "alien.accessors" }
    { "alien-signed-1" "alien.accessors" }
    { "set-alien-signed-1" "alien.accessors" }
    { "alien-unsigned-1" "alien.accessors" }
    { "set-alien-unsigned-1" "alien.accessors" }
    { "alien-float" "alien.accessors" }
    { "set-alien-float" "alien.accessors" }
    { "alien-double" "alien.accessors" }
    { "set-alien-double" "alien.accessors" }
    { "alien-cell" "alien.accessors" }
    { "set-alien-cell" "alien.accessors" }
    { "(throw)" "kernel.private" }
    { "alien-address" "alien" }
    { "set-slot" "slots.private" }
    { "string-nth" "strings.private" }
    { "set-string-nth" "strings.private" }
    { "resize-array" "arrays" }
    { "resize-string" "strings" }
    { "<array>" "arrays" }
    { "begin-scan" "memory" }
    { "next-object" "memory" }
    { "end-scan" "memory" }
    { "size" "memory" }
    { "die" "kernel" }
    { "fopen" "io.streams.c" }
    { "fgetc" "io.streams.c" }
    { "fread" "io.streams.c" }
    { "fputc" "io.streams.c" }
    { "fwrite" "io.streams.c" }
    { "fflush" "io.streams.c" }
    { "fclose" "io.streams.c" }
    { "<wrapper>" "kernel" }
    { "(clone)" "kernel" }
    { "<string>" "strings" }
    { "array>quotation" "quotations.private" }
    { "quotation-xt" "quotations" }
    { "<tuple>" "classes.tuple.private" }
    { "<tuple-layout>" "classes.tuple.private" }
    { "profiling" "tools.profiler.private" }
    { "become" "kernel.private" }
    { "(sleep)" "threads.private" }
    { "<tuple-boa>" "classes.tuple.private" }
    { "callstack>array" "kernel" }
    { "innermost-frame-quot" "kernel.private" }
    { "innermost-frame-scan" "kernel.private" }
    { "set-innermost-frame-quot" "kernel.private" }
    { "call-clear" "kernel" }
    { "(os-envs)" "system.private" }
    { "set-os-env" "system" }
    { "unset-os-env" "system" }
    { "(set-os-envs)" "system.private" }
    { "resize-byte-array" "byte-arrays" }
    { "dll-valid?" "alien" }
    { "unimplemented" "kernel.private" }
    { "gc-reset" "memory" }
}
[ >r first2 r> make-primitive ] each-index

! Bump build number
"build" "kernel" create build 1+ 1quotation define
