! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004 Slava Pestov.
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
USE: parser
USE: prettyprint
USE: stack
USE: stdio
USE: strings
USE: unparser
USE: words

: prettyprint-docs ( indent word -- indent )
    [
        stack-effect [
            <% CHAR: ( % % CHAR: ) % %> prettyprint-comment
            dup prettyprint-newline
        ] when*
    ] keep

    documentation [
        "\n" split [
            "#!" swap cat2 prettyprint-comment
            dup prettyprint-newline
        ] each
    ] when* ;

: see-compound ( word -- )
    0 swap
    [ dupd prettyprint-IN: prettyprint-: ] keep
    [ prettyprint-word prettyprint-space ] keep
    [ prettyprint-docs ] keep
    [ word-parameter prettyprint-list prettyprint-; ] keep
    prettyprint-plist prettyprint-newline ;

: see-primitive ( word -- )
    "PRIMITIVE: " write unparse print ;

: see-undefined ( word -- )
    drop "Not defined" print ;

: see ( name -- )
    #! Show a word definition.
    intern
    [
        [ compound? ] [ see-compound ]
        [ primitive? ] [ see-primitive ]
        [ drop t ] [ see-undefined ]
    ] cond ;
