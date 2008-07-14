! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces optimizer.backend optimizer.def-use
optimizer.known-words optimizer.math optimizer.allot
optimizer.control optimizer.collect optimizer.inlining
inference.class ;
IN: optimizer

: optimize-1 ( node -- newnode ? )
    [
        H{ } clone class-substitutions set
        H{ } clone literal-substitutions set
        H{ } clone value-substitutions set

        collect-label-infos
        compute-def-use
        kill-values
        detect-loops
        infer-classes

        optimizer-changed off
        optimize-nodes
        optimizer-changed get
    ] with-scope ;

: optimize ( node -- newnode )
    optimize-1 [ optimize ] when ;
