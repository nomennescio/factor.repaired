! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences accessors combinators namespaces
compiler.cfg.tco
compiler.cfg.predecessors
compiler.cfg.useless-blocks
compiler.cfg.stack-analysis
compiler.cfg.alias-analysis
compiler.cfg.value-numbering
compiler.cfg.dce
compiler.cfg.write-barrier
compiler.cfg.liveness
compiler.cfg.rpo
compiler.cfg.phi-elimination
compiler.cfg.checker ;
IN: compiler.cfg.optimizer

SYMBOL: check-optimizer?

: ?check ( cfg -- cfg' )
    check-optimizer? get [
        dup check-cfg
    ] when ;

: optimize-cfg ( cfg -- cfg' )
    [
        optimize-tail-calls
        compute-predecessors
        ! delete-useless-blocks
        delete-useless-conditionals
        stack-analysis
        compute-liveness
        alias-analysis
        value-numbering
        eliminate-dead-code
        eliminate-write-barriers
        eliminate-phis
        ?check
    ] with-scope ;
