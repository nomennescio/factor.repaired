! Copyright (C) 2007, 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: cocoa cocoa.messages cocoa.application cocoa.nibs assocs
namespaces kernel kernel.private words compiler.units sequences
init vocabs ;
IN: tools.deploy.shaker.cocoa

: pool ( obj -- obj' ) \ pool get [ ] cache ;

: pool-array ( obj -- obj' ) [ pool ] map pool ;

: pool-keys ( assoc -- assoc' ) [ [ pool-array ] dip ] assoc-map ;

: pool-values ( assoc -- assoc' ) [ pool-array ] assoc-map ;

IN: cocoa.application

: objc-error ( error -- ) die ;

[ [ die ] 19 setenv ] "cocoa.application" add-init-hook

"stop-after-last-window?" get

H{ } clone \ pool [
    global [
        "stop-after-last-window?" "ui" lookup set

        "ui.cocoa" vocab [
            [ "MiniFactor.nib" load-nib ]
            "cocoa-init-hook" "ui.cocoa" lookup set-global
        ] when

        ! Only keeps those methods that we actually call
        sent-messages get super-sent-messages get assoc-union
        objc-methods [ assoc-intersect pool-values ] change

        sent-messages get
        super-sent-messages get
        [ keys [ objc-methods get at dup ] H{ } map>assoc ] bi@
        super-message-senders [ assoc-intersect pool-keys ] change
        message-senders [ assoc-intersect pool-keys ] change

        sent-messages off
        super-sent-messages off

        alien>objc-types off
        objc>alien-types off

        ! We need this for strip-stack-traces to work fully
        { message-senders super-message-senders }
        [ get values compile ] each
    ] bind
] with-variable
