! Copyright (C) 2009 Jeremy Hughes.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.inline.compiler alien.inline.types
alien.libraries alien.marshall alien.parser arrays assocs
combinators effects fry generalizations grouping io.files
io.files.info io.files.temp kernel lexer locals math math.order
math.ranges multiline namespaces quotations sequences splitting
strings system vocabs.loader vocabs.parser words ;
IN: alien.inline

<PRIVATE
SYMBOL: c-library
SYMBOL: library-is-c++
SYMBOL: compiler-args
SYMBOL: c-strings

: annotate-effect ( types effect -- types effect' )
    [ in>> ] [ out>> ] bi [
        zip
        [ over pointer-to-primitive? [ ">" prepend ] when ]
        assoc-map unzip
    ] dip <effect> ;


: function-types-effect ( -- function types effect )
    scan scan swap ")" parse-tokens
    [ "(" subseq? not ] filter swap parse-arglist ;

: types-effect>params-return ( types effect -- params return )
    [ in>> zip ]
    [ nip out>> dup length 0 > [ first ] [ drop "void" ] if ]
    2bi ;

: arg-list ( types -- params )
    CHAR: a swap length CHAR: a + [a,b]
    [ 1string ] map ;

: factor-function ( function types effect -- word quot effect )
    annotate-effect [ c-library get ] 3dip
    [ [ factorize-type ] map ] dip
    types-effect>params-return factorize-type -roll
    concat make-function ;

:: marshalled-function ( function types effect -- word quot effect )
    function types effect annotate-effect factor-function
    [ in>> ]
    [ out>> types [ pointer-to-primitive? ] filter append ]
    bi <effect>
    [
        types [ marshaller ] map \ spread rot
        types length \ nkeep
        types [ out-arg-unmarshaller ] map \ spread
        7 narray >quotation
    ] dip ;

: prototype-string ( function types effect -- str )
    [ [ cify-type ] map ] dip
    types-effect>params-return cify-type -rot
    [ " " join ] map ", " join
    "(" prepend ")" append 3array " " join
    library-is-c++ get [ "extern \"C\" " prepend ] when ;

: prototype-string' ( function types return -- str )
    [ dup arg-list ] <effect> prototype-string ;

: append-function-body ( prototype-str -- str )
    " {\n" append parse-here append "\n}\n" append ;


: library-path ( -- str )
    "lib" c-library get library-suffix
    3array concat temp-file ;

: compile-library? ( -- ? )
    library-path dup exists? [
        current-vocab vocab-source-path
        [ file-info modified>> ] bi@ <=> +lt+ =
    ] [ drop t ] if ;

: compile-library ( -- )
    library-is-c++ get [ C++ ] [ C ] if
    compiler-args get
    c-strings get "\n" join
    c-library get compile-to-library ;
PRIVATE>

: define-c-library ( name -- )
    c-library set
    V{ } clone c-strings set
    V{ } clone compiler-args set ;

: compile-c-library ( -- )
    compile-library? [ compile-library ] when
    c-library get library-path "cdecl" add-library ;

: define-c-function ( function types effect -- prototype )
    [ factor-function define-declared ] 3keep prototype-string ;

: define-c-function' ( function effect -- prototype )
    [ in>> ] keep [ factor-function define-declared ] 3keep
    out>> prototype-string' ;

: define-c-marshalled ( function types effect -- prototype )
    [ marshalled-function define-declared ] 3keep
    prototype-string ;

: define-c-marshalled' ( function effect -- prototype )
    [ in>> ] keep [ marshalled-function define-declared ] 3keep
    out>> prototype-string' ;

: define-c-link ( str -- )
    "-l" prepend compiler-args get push ;

: define-c-framework ( str -- )
    "-framework" swap compiler-args get '[ _ push ] bi@ ;

: define-c-link/framework ( str -- )
    os macosx? [ define-c-framework ] [ define-c-link ] if ;

: define-c-include ( str -- )
    "#include " prepend c-strings get push ;

SYNTAX: C-LIBRARY: scan define-c-library ;

SYNTAX: COMPILE-AS-C++ t library-is-c++ set ;

SYNTAX: C-LINK: scan define-c-link ;

SYNTAX: C-FRAMEWORK: scan define-c-framework ;

SYNTAX: C-LINK/FRAMEWORK: scan define-c-link/framework ;

SYNTAX: C-INCLUDE: scan define-c-include ;

SYNTAX: C-FUNCTION:
    function-types-effect define-c-function
    append-function-body c-strings get push ;

SYNTAX: C-MARSHALLED:
    function-types-effect define-c-marshalled
    append-function-body c-strings get push ;

SYNTAX: ;C-LIBRARY compile-c-library ;
