USING: accessors sequences assocs kernel quotations namespaces
xml.data xml.utilities combinators macros parser lexer words ;
IN: xmode.utilities

: implies >r not r> or ; inline

: child-tags ( tag -- seq ) children>> [ tag? ] filter ;

: map-find ( seq quot -- result elt )
    f -rot
    [ nip ] swap [ dup ] 3compose find
    >r [ drop f ] unless r> ; inline

: tag-init-form ( spec -- quot )
    {
        { [ dup quotation? ] [ [ object get tag get ] prepose ] }
        { [ dup length 2 = ] [
            first2 [
                >r >r tag get children>string
                r> [ execute ] when* object get r> execute
            ] 2curry
        ] }
        { [ dup length 3 = ] [
            first3 [
                >r >r tag get at
                r> [ execute ] when* object get r> execute
            ] 3curry
        ] }
    } cond ;

: with-tag-initializer ( tag obj quot -- )
    [ object set tag set ] prepose with-scope ; inline

MACRO: (init-from-tag) ( specs -- )
    [ tag-init-form ] map concat [ ] like
    [ with-tag-initializer ] curry ;

: init-from-tag ( tag tuple specs -- tuple )
    over >r (init-from-tag) r> ; inline

SYMBOL: tag-handlers
SYMBOL: tag-handler-word

: <TAGS:
    CREATE tag-handler-word set
    H{ } clone tag-handlers set ; parsing

: (TAG:) ( name quot -- ) swap tag-handlers get set-at ;

: TAG:
    scan parse-definition
    (TAG:) ; parsing

: TAGS>
    tag-handler-word get
    tag-handlers get >alist [ >r dup main>> r> case ] curry
    define ; parsing
