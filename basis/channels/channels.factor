! Copyright (C) 2007 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
!
! Channels - based on ideas from newsqueak
USING: kernel sequences threads continuations
random math accessors random ;
IN: channels

TUPLE: channel receivers senders ;

: <channel> ( -- channel )
    V{ } clone V{ } clone channel boa ;

GENERIC: to ( value channel -- )
GENERIC: from ( channel -- value )

<PRIVATE

: wait ( channel -- )
    [ senders>> push ] curry
    "channel send" suspend drop ;

: (to) ( value receivers -- )
    delete-random resume-with yield ;

: notify ( continuation channel -- channel )
    [ receivers>> push ] keep ;

: (from) ( senders -- )
    delete-random resume ;

PRIVATE>

M: channel to ( value channel -- )
    dup receivers>>
    [ dup wait to ] [ nip (to) ] if-empty ;

M: channel from ( channel -- value )
    [
        notify senders>>
        [ (from) ] unless-empty
    ] curry "channel receive" suspend ;
