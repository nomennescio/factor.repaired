! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.strings io.encodings.utf8
io.backend.unix kernel math sequences splitting unix strings
combinators.short-circuit grouping byte-arrays combinators
accessors math.parser fry assocs namespaces continuations
vocabs.loader system ;
IN: unix.users

TUPLE: passwd username password uid gid gecos dir shell ;

HOOK: new-passwd os ( -- passwd )
HOOK: passwd>new-passwd os ( passwd -- new-passwd )

<PRIVATE

M: unix new-passwd ( -- passwd )
    passwd new ;

M: unix passwd>new-passwd ( passwd -- seq )
    [ new-passwd ] dip
    {
        [ passwd-pw_name >>username ]
        [ passwd-pw_passwd >>password ]
        [ passwd-pw_uid >>uid ]
        [ passwd-pw_gid >>gid ]
        [ passwd-pw_gecos >>gecos ]
        [ passwd-pw_dir >>dir ]
        [ passwd-pw_shell >>shell ]
    } cleave ;

: with-pwent ( quot -- )
    [ endpwent ] [ ] cleanup ; inline

PRIVATE>

: all-users ( -- seq )
    [
        [ getpwent dup ] [ passwd>new-passwd ] [ drop ] produce
    ] with-pwent ;

SYMBOL: user-cache

: <user-cache> ( -- assoc )
    all-users [ [ uid>> ] keep ] H{ } map>assoc ;

: with-user-cache ( quot -- )
    [ <user-cache> user-cache ] dip with-variable ; inline

GENERIC: user-passwd ( obj -- passwd )

M: integer user-passwd ( id -- passwd/f )
    user-cache get
    [ at ] [ getpwuid passwd>new-passwd ] if* ;

M: string user-passwd ( string -- passwd/f )
    getpwnam dup [ passwd>new-passwd ] when ;

: username ( id -- string )
    user-passwd username>> ;

: user-id ( string -- id )
    user-passwd uid>> ;

: real-user-id ( -- id )
    getuid ; inline

: real-username ( -- string )
    real-user-id username ; inline

: effective-user-id ( -- id )
    geteuid ; inline

: effective-username ( -- string )
    effective-user-id username ; inline

GENERIC: set-real-user ( string/id -- )

GENERIC: set-effective-user ( string/id -- )

: with-real-user ( string/id quot -- )
    '[ _ set-real-user @ ]
    real-user-id '[ _ set-real-user ]
    [ ] cleanup ; inline

: with-effective-user ( string/id quot -- )
    '[ _ set-effective-user @ ]
    effective-user-id '[ _ set-effective-user ]
    [ ] cleanup ; inline

<PRIVATE

: (set-real-user) ( id -- )
    setuid io-error ; inline

: (set-effective-user) ( id -- )
    seteuid io-error ; inline

PRIVATE>

M: string set-real-user ( string -- )
    user-id (set-real-user) ;

M: integer set-real-user ( id -- )
    (set-real-user) ;

M: integer set-effective-user ( id -- )
    (set-effective-user) ; 

M: string set-effective-user ( string -- )
    user-id (set-effective-user) ;

os {
    { [ dup bsd? ] [ drop "unix.users.bsd" require ] }
    { [ dup linux? ] [ drop ] }
} cond
