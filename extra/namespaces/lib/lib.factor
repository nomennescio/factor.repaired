
! USING: kernel quotations namespaces sequences assocs.lib ;

USING: kernel namespaces namespaces.private quotations sequences
       assocs.lib ;

IN: namespaces.lib

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: save-namestack ( quot -- ) namestack >r call r> set-namestack ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: make* ( seq -- seq ) [ dup quotation? [ call ] [ ] if ] map ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: set* ( val var -- ) namestack* set-assoc-stack ;
