
USING: kernel combinators quotations arrays sequences assocs
       locals generalizations macros fry ;

IN: combinators.short-circuit

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: n&&-rewrite ( quots N -- quot )
   quots
     [ '[ drop N ndup @ dup not ] [ drop N ndrop f ] 2array ]
   map
   [ t ] [ N nnip ] 2array suffix
   '[ f _ cond ] ;

MACRO: 0&& ( quots -- quot ) 0 n&&-rewrite ;
MACRO: 1&& ( quots -- quot ) 1 n&&-rewrite ;
MACRO: 2&& ( quots -- quot ) 2 n&&-rewrite ;
MACRO: 3&& ( quots -- quot ) 3 n&&-rewrite ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: n||-rewrite ( quots N -- quot )
   quots
     [ '[ drop N ndup @ dup ] [ N nnip ] 2array ]
   map
   [ drop N ndrop t ] [ f ] 2array suffix
   '[ f _ cond ] ;

MACRO: 0|| ( quots -- quot ) 0 n||-rewrite ;
MACRO: 1|| ( quots -- quot ) 1 n||-rewrite ;
MACRO: 2|| ( quots -- quot ) 2 n||-rewrite ;
MACRO: 3|| ( quots -- quot ) 3 n||-rewrite ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
