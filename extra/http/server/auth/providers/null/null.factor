! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: http.server.auth.providers kernel ;
IN: http.server.auth.providers.null

TUPLE: no-users ;

: no-users T{ no-users } ;

M: no-users get-user 2drop f ;

M: no-users new-user 2drop f ;

M: no-users update-user 2drop ;
