
USING: kernel namespaces threads sequences calendar
       combinators.cleave combinators.lib ;

IN: raptor.cron

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: when minute hour day-of-month month day-of-week ;

C: <when> when

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: slot-match? ( now-slot when-slot -- ? ) dup f = [ 2drop t ] [ member? ] if ;

: minute-match? ( now when -- ? )
  [ timestamp-minute ] [ when-minute ] bi* slot-match? ;

: hour-match? ( now when -- ? )
  [ timestamp-hour ] [ when-hour ] bi* slot-match? ;

: day-of-month-match? ( now when -- ? )
  [ timestamp-day ] [ when-day-of-month ] bi* slot-match? ;

: month-match? ( now when -- ? )
  [ timestamp-month ] [ when-month ] bi* slot-match? ;

: day-of-week-match? ( now when -- ? )
  [ day-of-week ] [ when-day-of-week ] bi* slot-match? ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: when=now? ( when -- ? )
  now swap
  { [ minute-match? ]
    [ hour-match? ]
    [ day-of-month-match? ]
    [ month-match? ]
    [ day-of-week-match? ] }
  <--&& ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: recurring-job ( when quot -- )
  [ swap when=now? [ call ] [ drop ] if 60000 sleep ] [ recurring-job ] 2bi ;

: schedule ( when quot -- ) [ recurring-job ] curry curry in-thread ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: cron-jobs-hourly
SYMBOL: cron-jobs-daily
SYMBOL: cron-jobs-weekly
SYMBOL: cron-jobs-monthly

: schedule-cron-jobs ( -- )
  { 17 } f f f f         <when> [ cron-jobs-hourly  get call ] schedule
  { 25 } { 6 } f f f     <when> [ cron-jobs-daily   get call ] schedule
  { 47 } { 6 } f f { 7 } <when> [ cron-jobs-weekly  get call ] schedule
  { 52 } { 6 } { 1 } f f <when> [ cron-jobs-monthly get call ] schedule ;

