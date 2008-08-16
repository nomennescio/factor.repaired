! Copyright (C) 2007, 2008 Elie CHAFTARI, Dirk Vleugels,
! Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces io io.timeouts kernel logging io.sockets
sequences combinators sequences.lib splitting assocs strings
math.parser random system calendar io.encodings.ascii
calendar.format accessors sets ;
IN: smtp

SYMBOL: smtp-domain
SYMBOL: smtp-server     "localhost" "smtp" <inet> smtp-server set-global
SYMBOL: read-timeout    1 minutes read-timeout set-global
SYMBOL: esmtp           t esmtp set-global

LOG: log-smtp-connection NOTICE ( addrspec -- )

: with-smtp-connection ( quot -- )
    smtp-server get
    dup log-smtp-connection
    ascii [
        smtp-domain [ host-name or ] change
        read-timeout get timeouts
        call
    ] with-client ; inline

: crlf ( -- ) "\r\n" write ;

: command ( string -- ) write crlf flush ;

: helo ( -- )
    esmtp get "EHLO " "HELO " ? host-name append command ;

: validate-address ( string -- string' )
    #! Make sure we send funky stuff to the server by accident.
    dup "\r\n>" intersect empty?
    [ "Bad e-mail address: " prepend throw ] unless ;

: mail-from ( fromaddr -- )
    "MAIL FROM:<" swap validate-address ">" 3append command ;

: rcpt-to ( to -- )
    "RCPT TO:<" swap validate-address ">" 3append command ;

: data ( -- )
    "DATA" command ;

: validate-message ( msg -- msg' )
    "." over member? [ "Message cannot contain . on a line by itself" throw ] when ;

: send-body ( body -- )
    string-lines
    validate-message
    [ write crlf ] each
    "." command ;

: quit ( -- )
    "QUIT" command ;

LOG: smtp-response DEBUG

ERROR: smtp-error message ;
ERROR: smtp-server-busy < smtp-error ;
ERROR: smtp-syntax-error < smtp-error ;
ERROR: smtp-command-not-implemented < smtp-error ;
ERROR: smtp-bad-authentication < smtp-error ;
ERROR: smtp-mailbox-unavailable < smtp-error ;
ERROR: smtp-user-not-local < smtp-error ;
ERROR: smtp-exceeded-storage-allocation < smtp-error ;
ERROR: smtp-bad-mailbox-name < smtp-error ;
ERROR: smtp-transaction-failed < smtp-error ;

: check-response ( response -- )
    dup smtp-response
    {
        { [ dup "bye" head? ] [ drop ] }
        { [ dup "220" head? ] [ drop ] }
        { [ dup "235" swap subseq? ] [ drop ] }
        { [ dup "250" head? ] [ drop ] }
        { [ dup "221" head? ] [ drop ] }
        { [ dup "354" head? ] [ drop ] }
        { [ dup "4" head? ] [ smtp-server-busy ] }
        { [ dup "500" head? ] [ smtp-syntax-error ] }
        { [ dup "501" head? ] [ smtp-command-not-implemented ] }
        { [ dup "50" head? ] [ smtp-syntax-error ] }
        { [ dup "53" head? ] [ smtp-bad-authentication ] }
        { [ dup "550" head? ] [ smtp-mailbox-unavailable ] }
        { [ dup "551" head? ] [ smtp-user-not-local ] }
        { [ dup "552" head? ] [ smtp-exceeded-storage-allocation ] }
        { [ dup "553" head? ] [ smtp-bad-mailbox-name ] }
        { [ dup "554" head? ] [ smtp-transaction-failed ] }
        [ smtp-error ]
    } cond ;

: multiline? ( response -- boolean )
    ?fourth CHAR: - = ;

: process-multiline ( multiline -- response )
    >r readln r> 2dup " " append head? [
        drop dup smtp-response
    ] [
        swap check-response process-multiline
    ] if ;

: receive-response ( -- response )
    readln
    dup multiline? [ 3 head process-multiline ] when ;

: get-ok ( -- ) receive-response check-response ;

: validate-header ( string -- string' )
    dup "\r\n" intersect empty?
    [ "Invalid header string: " prepend throw ] unless ;

: write-header ( key value -- )
    swap
    validate-header write
    ": " write
    validate-header write
    crlf ;

: write-headers ( assoc -- )
    [ write-header ] assoc-each ;

TUPLE: email from to subject headers body ;

M: email clone
    call-next-method [ clone ] change-headers ;

: (send) ( email -- )
    [
        helo get-ok
        dup from>> mail-from get-ok
        dup to>> [ rcpt-to get-ok ] each
        data get-ok
        dup headers>> write-headers
        crlf
        body>> send-body get-ok
        quit get-ok
    ] with-smtp-connection ;

: extract-email ( recepient -- email )
    #! This could be much smarter.
    " " last-split1 swap or "<" ?head drop ">" ?tail drop ;

: message-id ( -- string )
    [
        "<" %
        64 random-bits #
        "-" %
        millis #
        "@" %
        smtp-domain get [ host-name ] unless* %
        ">" %
    ] "" make ;

: set-header ( email value key -- email )
    pick headers>> set-at ;

: prepare ( email -- email )
    clone
    dup from>> "From" set-header
    [ extract-email ] change-from
    dup to>> ", " join "To" set-header
    [ [ extract-email ] map ] change-to
    dup subject>> "Subject" set-header
    now timestamp>rfc822 "Date" set-header
    message-id "Message-Id" set-header ;

: <email> ( -- email )
    email new
    H{ } clone >>headers ;

: send-email ( email -- )
    prepare (send) ;

! Dirk's old AUTH CRAM-MD5 code. I don't know anything about
! CRAM MD5, and the old code didn't work properly either, so here
! it is in case anyone wants to fix it later.
!
! check-response used to have this clause:
! { [ dup "334" head? ] [ " " split 1 swap nth base64> challenge set ] }
!
! and the rest of the code was as follows:
! : (cram-md5-auth) ( -- response )
!     swap challenge get 
!     string>md5-hmac hex-string 
!     " " prepend append 
!     >base64 ;
! 
! : cram-md5-auth ( key login  -- )
!     "AUTH CRAM-MD5\r\n" get-ok 
!     (cram-md5-auth) "\r\n" append get-ok ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
