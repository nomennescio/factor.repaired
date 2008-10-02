! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences db.tuples alarms calendar db fry
furnace.db
furnace.cache
furnace.asides
furnace.referrer
furnace.sessions
furnace.conversations
furnace.auth.providers
furnace.auth.login.permits ;
IN: furnace.alloy

: state-classes { session aside conversation permit } ; inline

: init-furnace-tables ( -- )
    state-classes ensure-tables
    user ensure-table ;

: <alloy> ( responder db params -- responder' )
    [ [ init-furnace-tables ] with-db ]
    [
        [
            <asides>
            <conversations>
            <sessions>
        ] 2dip
        <db-persistence>
        <check-form-submissions>
    ] 2bi ;

: start-expiring ( db params -- )
    '[
        _ _ [ state-classes [ expire-state ] each ] with-db
    ] 5 minutes every drop ;
