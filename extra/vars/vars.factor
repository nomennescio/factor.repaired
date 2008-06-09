! Copyright (C) 2005, 2006 Eduardo Cavazos

! Thanks to Mackenzie Straight for the idea

USING: kernel parser words namespaces sequences quotations ;

IN: vars

: define-var-getter ( word -- )
    [ word-name ">" append create-in ] [ [ get ] curry ] bi
    (( -- value )) define-declared ;

: define-var-setter ( word -- )
    [ word-name ">" prepend create-in ] [ [ set ] curry ] bi
    (( value -- )) define-declared ;

: define-var ( str -- )
    create-in
    [ define-symbol ]
    [ define-var-getter ]
    [ define-var-setter ] tri ;

: VAR: ! var
    scan define-var ; parsing

: define-vars ( seq -- )
    [ define-var ] each ;

: VARS: ! vars ...
    ";" parse-tokens define-vars ; parsing
