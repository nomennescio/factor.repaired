! Copyright (C) 2005, 2008 Chris Double, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: concurrency.mailboxes
USING: dlists threads sequences continuations
namespaces random math quotations words kernel arrays assocs
init system concurrency.conditions ;

TUPLE: mailbox threads data ;

: <mailbox> ( -- mailbox )
    <dlist> <dlist> mailbox construct-boa ;

: mailbox-empty? ( mailbox -- bool )
    mailbox-data dlist-empty? ;

: mailbox-put ( obj mailbox -- )
    [ mailbox-data push-front ] keep
    mailbox-threads notify-all yield ;

: block-unless-pred ( mailbox timeout pred -- )
    pick mailbox-data over dlist-contains? [
        3drop
    ] [
        >r over mailbox-threads over "mailbox" wait r>
        block-unless-pred
    ] if ; inline

: block-if-empty ( mailbox timeout -- mailbox )
    over mailbox-empty? [
        over mailbox-threads over "mailbox" wait
        block-if-empty
    ] [
        drop
    ] if ;

: mailbox-peek ( mailbox -- obj )
    mailbox-data peek-back ;

: mailbox-get-timeout ( mailbox timeout -- obj )
    block-if-empty mailbox-data pop-back ;

: mailbox-get ( mailbox -- obj )
    f mailbox-get-timeout ;

: mailbox-get-all-timeout ( mailbox timeout -- array )
    block-if-empty
    [ dup mailbox-empty? ]
    [ dup mailbox-data pop-back ]
    [ ] unfold nip ;

: mailbox-get-all ( mailbox -- array )
    f mailbox-get-all-timeout ;

: while-mailbox-empty ( mailbox quot -- )
    over mailbox-empty? [
        dup >r swap slip r> while-mailbox-empty
    ] [
        2drop
    ] if ; inline

: mailbox-get-timeout? ( mailbox timeout pred -- obj )
    3dup block-unless-pred
    nip >r mailbox-data r> delete-node-if ; inline

: mailbox-get? ( mailbox pred -- obj )
    f swap mailbox-get-timeout? ; inline

TUPLE: linked-error thread ;

: <linked-error> ( error thread -- linked )
    { set-delegate set-linked-error-thread }
    linked-error construct ;

: ?linked dup linked-error? [ rethrow ] when ;

TUPLE: linked-thread supervisor ;

M: linked-thread error-in-thread
    [ <linked-error> ] keep
    linked-thread-supervisor mailbox-put ;

: <linked-thread> ( quot name mailbox -- thread' )
    >r <thread> linked-thread construct-delegate r>
    over set-linked-thread-supervisor ;

: spawn-linked-to ( quot name mailbox -- thread )
    <linked-thread> [ (spawn) ] keep ;
