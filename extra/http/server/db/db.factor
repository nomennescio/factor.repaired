! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: db http.server kernel new-slots accessors
continuations namespaces destructors combinators.cleave ;
IN: http.server.db

TUPLE: db-persistence responder db params ;

C: <db-persistence> db-persistence

: connect-db ( db-persistence -- )
    [ db>> ] [ params>> ] bi make-db
    [ db set ] [ db-open ] [ add-always-destructor ] tri ;

M: db-persistence call-responder
    [ connect-db ] [ responder>> call-responder ] bi ;
