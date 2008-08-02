! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: stack-checker.visitor kernel ;
IN: stack-checker.visitor.dummy

M: f child-visitor f ;
M: f #introduce, drop ;
M: f #call, 3drop ;
M: f #call-recursive, 3drop ;
M: f #push, 2drop ;
M: f #shuffle, 3drop ;
M: f #>r, 2drop ;
M: f #r>, 2drop ;
M: f #return, drop ;
M: f #enter-recursive, 3drop ;
M: f #return-recursive, 3drop ;
M: f #terminate, drop ;
M: f #if, 3drop ;
M: f #dispatch, 2drop ;
M: f #phi, drop drop drop drop drop ;
M: f #declare, drop ;
M: f #recursive, 2drop 2drop ;
M: f #copy, 2drop ;
M: f #drop, drop ;
