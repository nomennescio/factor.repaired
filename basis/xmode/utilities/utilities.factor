USING: accessors sequences assocs kernel quotations namespaces
xml.data xml.traversal combinators macros parser lexer words fry ;
IN: xmode.utilities

: implies ( x y -- z ) [ not ] dip or ; inline

: map-find ( seq quot -- result elt )
    [ f ] 2dip
    '[ nip @ dup ] find
    [ [ drop f ] unless ] dip ; inline

: tag-init-form ( spec -- quot )
    {
        { [ dup quotation? ] [ [ object get tag get ] prepose ] }
        { [ dup length 2 = ] [
            first2 '[
                tag get children>string
                _ [ execute ] when* object get _ execute
            ]
        ] }
        { [ dup length 3 = ] [
            first3 '[
                tag get _ attr
                _ [ execute ] when* object get _ execute
            ]
        ] }
    } cond ;

: with-tag-initializer ( tag obj quot -- )
    [ object set tag set ] prepose with-scope ; inline

MACRO: (init-from-tag) ( specs -- )
    [ tag-init-form ] map concat [ ] like
    [ with-tag-initializer ] curry ;

: init-from-tag ( tag tuple specs -- tuple )
    over [ (init-from-tag) ] dip ; inline
