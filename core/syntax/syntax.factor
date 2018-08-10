! Copyright (C) 2004, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs byte-arrays byte-vectors
classes.algebra.private classes.builtin classes.error
classes.intersection classes.maybe classes.mixin classes.parser
classes.predicate classes.singleton classes.tuple
classes.tuple.parser classes.union combinators compiler.units
definitions delegate delegate.private effects effects.parser factor
fry functors2 generic generic.hook generic.math generic.parser
generic.standard hash-sets hashtables hashtables.identity hints
init interpolate io.pathnames kernel lexer locals.errors
locals.parser locals.types macros math memoize multiline
namespaces parser quotations sbufs sequences slots source-files
splitting stack-checker strings strings.parser system typed
vectors vocabs.parser vocabs.platforms words words.alias
words.constant words.inlined words.symbol ;
IN: bootstrap.syntax

! These words are defined as a top-level form, instead of with
! defining parsing words, because during stage1 bootstrap, the
! "syntax" vocabulary is copied from the host. When stage1
! bootstrap completes, the host's syntax vocabulary is deleted
! from the target, then this top-level form creates the
! target's "syntax" vocabulary as one of the first things done
! in stage2.

: define-delimiter ( name -- )
    "syntax" lookup-word t "delimiter" set-word-prop ;

! Keep track of words defined by SYNTAX: as opposed to words
! merely generated by define-syntax.
: mark-top-level-syntax ( word -- word )
    dup t "syntax" set-word-prop ;

: define-core-syntax ( name quot -- )
    [
        dup "syntax" lookup-word [ ] [ no-word-error ] ?if
        mark-top-level-syntax
    ] dip
    define-syntax ;

: define-dummy-fry ( name -- word )
    "syntax" lookup-word
    [ "Only valid inside a fry" throw ] ( -- * )
    [ define-declared ] 3keep 2drop ;

: define-fry-specifier ( word words -- )
    [ \ word ] dip [ member-eq? ] curry define-predicate-class ;

: define-fry-specifiers ( names -- )
    [ define-dummy-fry ] map
    dup [ define-fry-specifier ] curry each ;

[
    {
        "]" "}" ";" ">>"
        "UNIX>" "MACOS>" "LINUX>" "WINDOWS>"
        "FACTOR>"
    } [ define-delimiter ] each

    "PRIMITIVE:" [
        current-vocab name>>
        scan-word scan-effect ensure-primitive
    ] define-core-syntax

    "CS{" [
        "Call stack literals are not supported" throw
    ] define-core-syntax

    "IN:" [ scan-token set-current-vocab ] define-core-syntax

    "<PRIVATE" [ begin-private ] define-core-syntax

    "PRIVATE>" [ end-private ] define-core-syntax

    "<UNIX" [
        "UNIX>" parse-multiline-string
        os unix? [ ".unix" parse-platform-section ] [ drop ] if
    ] define-core-syntax

    "<MACOS" [
        "MACOS>" parse-multiline-string
        os macosx? [ ".macos" parse-platform-section ] [ drop ] if
    ] define-core-syntax

    "<LINUX" [
        "LINUX>" parse-multiline-string
        os linux? [ ".linux" parse-platform-section ] [ drop ] if
    ] define-core-syntax

    "<WINDOWS" [
        "WINDOWS>" parse-multiline-string
        os windows? [ ".windows" parse-platform-section ] [ drop ] if
    ] define-core-syntax

    "<FACTOR" [
        "FACTOR>" parse-multiline-string "" parse-platform-section
    ] define-core-syntax

    "USE:" [ scan-token use-vocab ] define-core-syntax

    "UNUSE:" [ scan-token unuse-vocab ] define-core-syntax

    "USING:" [ ";" [ use-vocab ] each-token ] define-core-syntax

    "QUALIFIED:" [ scan-token dup add-qualified ] define-core-syntax

    "QUALIFIED-WITH:" [ scan-token scan-token add-qualified ] define-core-syntax

    "FROM:" [
        scan-token unescape-token
        "=>" expect ";" parse-tokens unescape-tokens add-words-from
    ] define-core-syntax

    "EXCLUDE:" [
        scan-token unescape-token
        "=>" expect ";" parse-tokens unescape-tokens add-words-excluding
    ] define-core-syntax

    "RENAME:" [
        scan-token unescape-token
        scan-token
        "=>" expect scan-token unescape-token add-renamed-word
    ] define-core-syntax

    "nan:" [ 16 scan-base <fp-nan> suffix! ] define-core-syntax

    "f" [ f suffix! ] define-core-syntax

    "char:" [
        lexer get parse-raw [ "token" throw-unexpected-eof ] unless*
        lookup-char suffix!
    ] define-core-syntax

    "\"" [ parse-string suffix! ] define-core-syntax

    "sbuf\"" [
        parse-string >sbuf suffix!
    ] define-core-syntax

    "path\"" [
        parse-string <pathname> suffix!
    ] define-core-syntax

    "[" [ parse-quotation suffix! ] define-core-syntax
    "{" [ \ } [ >array ] parse-literal ] define-core-syntax
    "V{" [ \ } [ >vector ] parse-literal ] define-core-syntax
    "B{" [ \ } [ >byte-array ] parse-literal ] define-core-syntax
    "BV{" [ \ } [ >byte-vector ] parse-literal ] define-core-syntax
    "H{" [ \ } [ parse-hashtable ] parse-literal ] define-core-syntax
    "T{" [ parse-tuple-literal suffix! ] define-core-syntax
    "TH{" [ parse-tuple-hash-literal suffix! ] define-core-syntax
    "W{" [ \ } [ first <wrapper> ] parse-literal ] define-core-syntax
    "HS{" [ \ } [ >hash-set ] parse-literal ] define-core-syntax

    "postpone:" [ scan-syntax-word suffix! ] define-core-syntax
    "\\" [ scan-word <wrapper> suffix! ] define-core-syntax
    "M\\\\" [ scan-object scan-object lookup-method <wrapper> suffix! ] define-core-syntax
    "inline" [ last-word make-inline ] define-core-syntax
    "private" [ last-word make-private ] define-core-syntax
    "recursive" [ last-word make-recursive ] define-core-syntax
    "foldable" [ last-word make-foldable ] define-core-syntax
    "flushable" [ last-word make-flushable ] define-core-syntax
    "delimiter" [ last-word t "delimiter" set-word-prop ] define-core-syntax
    "deprecated" [ last-word make-deprecated ] define-core-syntax

    "SYNTAX:" [
        scan-new-word
        mark-top-level-syntax
        parse-definition define-syntax
    ] define-core-syntax

    "BUILTIN:" [
        scan-word-name
        current-vocab lookup-word
        (parse-tuple-definition) 2drop check-builtin
    ] define-core-syntax

    "INITIALIZED-SYMBOL:" [
        scan-new-word [ define-symbol ] keep scan-object '[ _ _ initialize ] append!
    ] define-core-syntax

    "SYMBOL:" [
        scan-new-word define-symbol
    ] define-core-syntax

    "SYMBOLS:" [
        ";" [ create-word-in [ reset-generic ] [ define-symbol ] bi ] each-token
    ] define-core-syntax

    "STARTUP-HOOK:" [
        scan-new-word scan-object
        [ ( -- ) define-declared ]
        [ swap startup-hooks get set-at ] 2bi
    ] define-core-syntax

    "SHUTDOWN-HOOK:" [
        scan-new-word scan-object
        [ ( -- ) define-declared ]
        [ swap shutdown-hooks get set-at ] 2bi
    ] define-core-syntax

    "SINGLETONS:" [
        ";" [ create-class-in define-singleton-class ] each-token
    ] define-core-syntax

    "DEFER:" [
        scan-token current-vocab create-word
        [ fake-definition ] [ set-last-word ] [ undefined-def define ] tri
    ] define-core-syntax

    "ALIAS:" [
        scan-new-word scan-word define-alias
    ] define-core-syntax

    "CONSTANT:" [
        scan-new-word scan-object define-constant
    ] define-core-syntax

    ":" [
        (:) apply-inlined-effects define-declared
    ] define-core-syntax

    "GENERIC:" [
        [ simple-combination ] (GENERIC:)
    ] define-core-syntax

    "GENERIC#:" [
        [ scan-number <standard-combination> ] (GENERIC:)
    ] define-core-syntax

    "MATH:" [
        [ math-combination ] (GENERIC:)
    ] define-core-syntax

    "HOOK:" [
        [ scan-word <hook-combination> ] (GENERIC:)
    ] define-core-syntax

    "M:" [
        (M:) define
    ] define-core-syntax

    "UNION:" [
        scan-new-class parse-array-def define-union-class
    ] define-core-syntax

    "INTERSECTION:" [
        scan-new-class parse-array-def define-intersection-class
    ] define-core-syntax

    "MIXIN:" [
        scan-new-class define-mixin-class
    ] define-core-syntax

    "INSTANCE:" [
        location [
            scan-word scan-word 2dup add-mixin-instance
            <mixin-instance>
        ] dip remember-definition
    ] define-core-syntax

    "PREDICATE:" [
        scan-new-class
        "<" expect
        scan-class
        parse-definition define-predicate-class
    ] define-core-syntax

    "SINGLETON:" [
        scan-new-class define-singleton-class
    ] define-core-syntax

    "TUPLE:" [
        parse-tuple-definition define-tuple-class
    ] define-core-syntax

    "final" [
        last-word make-final
    ] define-core-syntax

    "SLOT:" [
        scan-token define-protocol-slot
    ] define-core-syntax

    "C:" [
        scan-new-word scan-word define-boa-word
    ] define-core-syntax

    "ERROR:" [
        parse-tuple-definition
        pick save-location
        define-error-class
    ] define-core-syntax

    "FORGET:" [
        scan-object forget
    ] define-core-syntax

    "(" [
        ")" parse-effect suffix!
    ] define-core-syntax

    "MAIN:" [
        scan-word
        dup ( -- ) check-stack-effect
        [ current-vocab main<< ]
        [ current-source-file get [ main<< ] [ drop ] if* ] bi
    ] define-core-syntax

    "<<" [
        [
            \ >> parse-until >quotation
        ] with-nested-compilation-unit call( -- )
    ] define-core-syntax

    "call-next-method" [
        current-method get [
            literalize suffix!
            \ (call-next-method) suffix!
        ] [
            not-in-a-method-error
        ] if*
    ] define-core-syntax

    "maybe{" [
        \ } [ <anonymous-union> <maybe> ] parse-literal
    ] define-core-syntax

    "not{" [
        \ } [ <anonymous-union> <anonymous-complement> ] parse-literal
    ] define-core-syntax

    "intersection{" [
         \ } [ <anonymous-intersection> ] parse-literal
    ] define-core-syntax

    "union{" [
        \ } [ <anonymous-union> ] parse-literal
    ] define-core-syntax

    "initial:" "syntax" lookup-word define-symbol

    "read-only" "syntax" lookup-word define-symbol

    "call(" [ \ call-effect parse-call-paren ] define-core-syntax

    "execute(" [ \ execute-effect parse-call-paren ] define-core-syntax

    "IH{" [ \ } [ >identity-hashtable ] parse-literal ] define-core-syntax

    "::" [ (::) apply-inlined-effects define-declared ] define-core-syntax
    "M::" [ (M::) define ] define-core-syntax
    "MACRO:" [ (:) apply-inlined-effects define-macro ] define-core-syntax
    "MACRO::" [ (::) apply-inlined-effects define-macro ] define-core-syntax
    "TYPED:" [ (:) apply-inlined-effects define-typed ] define-core-syntax
    "TYPED::" [ (::) apply-inlined-effects define-typed ] define-core-syntax
    "MEMO:" [ (:) apply-inlined-effects define-memoized ] define-core-syntax
    "MEMO::" [ (::) apply-inlined-effects define-memoized ] define-core-syntax
    "MEMO[" [ parse-quotation dup infer memoize-quot suffix! ] define-core-syntax
    "IDENTITY-MEMO:" [ (:) apply-inlined-effects define-identity-memoized ] define-core-syntax
    "IDENTITY-MEMO::" [ (::) apply-inlined-effects define-identity-memoized ] define-core-syntax

    "'[" [ parse-quotation fry append! ] define-core-syntax

    "':" [
        (:) [ fry '[ @ call ] ] [ apply-inlined-effects ] bi* define-declared
    ] define-core-syntax

    "PROTOCOL:" [
        scan-new-word parse-definition define-protocol
    ] define-core-syntax

    "CONSULT:" [
        scan-word scan-word parse-definition <consultation>
        [ save-location ] [ define-consult ] bi
    ] define-core-syntax

    "BROADCAST:" [
        scan-word scan-word parse-definition <broadcast>
        [ save-location ] [ define-consult ] bi
    ] define-core-syntax

    "SLOT-PROTOCOL:" [
        scan-new-word ";"
        [ [ reader-word ] [ writer-word ] bi 2array ]
        map-tokens concat define-protocol
    ] define-core-syntax

    "HINTS:" [
        scan-object dup wrapper? [ wrapped>> ] when
        [ changed-definition ]
        [ subwords [ changed-definition ] each ]
        [ parse-definition { } like set-specializer ] tri
    ] define-core-syntax

    { "_" "@" } define-fry-specifiers

    "factor[[" [ "]]" parse-multiline-string0 <factor> suffix! ] define-core-syntax
    "factor[=[" [ "]=]" parse-multiline-string0 <factor> suffix! ] define-core-syntax
    "factor[==[" [ "]==]" parse-multiline-string0 <factor> suffix! ] define-core-syntax
    "factor[===[" [ "]===]" parse-multiline-string0 <factor> suffix! ] define-core-syntax
    "factor[====[" [ "]====]" parse-multiline-string0 <factor> suffix! ] define-core-syntax
    "factor[=====[" [ "]=====]" parse-multiline-string0 <factor> suffix! ] define-core-syntax
    "factor[======[" [ "]======]" parse-multiline-string0 <factor> suffix! ] define-core-syntax

    "[[" [ "]]" parse-multiline-string0 suffix! ] define-core-syntax
    "[=[" [ "]=]" parse-multiline-string0 suffix! ] define-core-syntax
    "[==[" [ "]==]" parse-multiline-string0 suffix! ] define-core-syntax
    "[===[" [ "]===]" parse-multiline-string0 suffix! ] define-core-syntax
    "[====[" [ "]====]" parse-multiline-string0 suffix! ] define-core-syntax
    "[=====[" [ "]=====]" parse-multiline-string0 suffix! ] define-core-syntax
    "[======[" [ "]======]" parse-multiline-string0 suffix! ] define-core-syntax

    "![[" [ "]]" parse-multiline-string0 drop ] define-core-syntax
    "![=[" [ "]=]" parse-multiline-string0 drop ] define-core-syntax
    "![==[" [ "]==]" parse-multiline-string0 drop ] define-core-syntax
    "![===[" [ "]===]" parse-multiline-string0 drop ] define-core-syntax
    "![====[" [ "]====]" parse-multiline-string0 drop ] define-core-syntax
    "![=====[" [ "]=====]" parse-multiline-string0 drop ] define-core-syntax
    "![======[" [ "]======]" parse-multiline-string0 drop ] define-core-syntax

    "I[[" [ "]]" define-interpolate-syntax ] define-core-syntax
    "I[=[" [ "]=]" define-interpolate-syntax ] define-core-syntax
    "I[==[" [ "]==]" define-interpolate-syntax ] define-core-syntax
    "I[===[" [ "]===]" define-interpolate-syntax ] define-core-syntax
    "I[====[" [ "]====]" define-interpolate-syntax ] define-core-syntax
    "I[=====[" [ "]=====]" define-interpolate-syntax ] define-core-syntax
    "I[======[" [ "]======]" define-interpolate-syntax ] define-core-syntax

    ":>" [
        in-lambda? get [ :>-outside-lambda-error ] unless
        scan-token parse-def suffix!
    ] define-core-syntax

    "|[" [ parse-lambda append! ] define-core-syntax

    "let[" [ parse-let append! ] define-core-syntax
    "'let[" [
        H{ } clone (parse-lambda) [ fry call <let> ?rewrite-closures call ] curry append!
    ] define-core-syntax

    "FUNCTOR:" [
        scan-new-word scan-effect scan-object make-functor
    ] define-core-syntax

    "VARIABLES-FUNCTOR:" [
        scan-new-word scan-effect scan-object scan-object make-variable-functor
    ] define-core-syntax
] with-compilation-unit
