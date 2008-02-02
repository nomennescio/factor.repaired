! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.backend kernel continuations namespaces sequences
assocs hashtables sorting arrays ;
IN: io.monitor

<PRIVATE

TUPLE: monitor queue closed? ;

: check-monitor ( monitor -- )
    monitor-closed? [ "Monitor closed" throw ] when ;

: (monitor) ( delegate -- monitor )
    H{ } clone {
        set-delegate
        set-monitor-queue
    } monitor construct ;

HOOK: fill-queue io-backend ( monitor -- assoc )

: changed-file ( changed path -- )
    namespace [ swap add ] change-at ;

: dequeue-change ( assoc -- path changes )
    delete-any prune natural-sort >array ;

PRIVATE>

HOOK: <monitor> io-backend ( path recursive? -- monitor )

: next-change ( monitor -- path changed )
    dup check-monitor
    dup monitor-queue dup assoc-empty? [
        drop dup fill-queue over set-monitor-queue next-change
    ] [ nip dequeue-change ] if ;

SYMBOL: +add-file+
SYMBOL: +remove-file+
SYMBOL: +modify-file+
SYMBOL: +rename-file+

: with-monitor ( path recursive? quot -- )
    >r <monitor> r> with-disposal ; inline
