! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2003, 2004 Slava Pestov.
! 
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice,
!    this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
! 
! THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
! INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
! DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
! WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
! OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
! ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

IN: prettyprint
USE: combinators
USE: lists
USE: math
USE: prettyprint
USE: stack
USE: stdio
USE: unparser
USE: words

: prettyprint-:; ( indent word list -- indent )
    over >r >r dup
    >r dupd prettyprint-IN: prettyprint-: r>
    prettyprint-word prettyprint-space
    r>
    prettyprint-list prettyprint-; r> prettyprint-plist ;

: prettyprint-~<< ( indent -- indent )
    "~<<" write prettyprint-space
    tab-size + ;

: prettyprint->>~ ( indent -- indent )
    ">>~" write
    tab-size - ;

: prettyprint-~<<>>~ ( indent word list -- indent )
    [ [ prettyprint-~<< ] dip prettyprint-word " " write ] dip
    [ write " " write ] each
    prettyprint->>~ ;

: see ( word -- )
    0 swap
    intern dup worddef
    [
        [ compound-or-compiled? ] [ word-parameter prettyprint-:; ]
        [ shuffle? ] [ word-parameter prettyprint-~<<>>~ ]
        [ primitive? ] [ "PRIMITIVE: " write unparse write drop ]
        [ drop t ] [ 2drop "Not defined" write ]
    ] cond prettyprint-newline ;
