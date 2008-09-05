! Copyright (C) 2008 Bruno Deferrari
! See http://factorcode.org/license.txt for BSD license.
USING: kernel fry splitting ascii calendar accessors combinators qualified
       arrays classes.tuple math.order quotations ;
RENAME: join sequences => sjoin
EXCLUDE: sequences => join ;
IN: irc.messages

TUPLE: irc-message line prefix command parameters trailing timestamp ;
TUPLE: logged-in < irc-message name ;
TUPLE: ping < irc-message ;
TUPLE: join < irc-message ;
TUPLE: part < irc-message channel ;
TUPLE: quit < irc-message ;
TUPLE: nick < irc-message ;
TUPLE: privmsg < irc-message name ;
TUPLE: kick < irc-message channel who ;
TUPLE: roomlist < irc-message channel names ;
TUPLE: nick-in-use < irc-message asterisk name ;
TUPLE: notice < irc-message type ;
TUPLE: mode < irc-message channel mode ;
TUPLE: names-reply < irc-message who channel ;
TUPLE: unhandled < irc-message ;

: <irc-client-message> ( command parameters trailing -- irc-message )
    irc-message new now >>timestamp
    [ [ (>>trailing) ] [ (>>parameters) ] [ (>>command) ] tri ] keep ;

<PRIVATE

GENERIC: command-string>> ( irc-message -- string )

M: irc-message command-string>> ( irc-message -- string ) command>> ;
M: ping        command-string>> ( ping -- string )    drop "PING" ;
M: join        command-string>> ( join -- string )    drop "JOIN" ;
M: part        command-string>> ( part -- string )    drop "PART" ;
M: quit        command-string>> ( quit -- string )    drop "QUIT" ;
M: nick        command-string>> ( nick -- string )    drop "NICK" ;
M: privmsg     command-string>> ( privmsg -- string ) drop "PRIVMSG" ;
M: notice      command-string>> ( notice -- string )  drop "NOTICE" ;
M: mode        command-string>> ( mode -- string )    drop "MODE" ;
M: kick        command-string>> ( kick -- string )    drop "KICK" ;

GENERIC: command-parameters>> ( irc-message -- seq )

M: irc-message command-parameters>> ( irc-message -- seq ) parameters>> ;
M: ping        command-parameters>> ( ping -- seq )    drop { } ;
M: join        command-parameters>> ( join -- seq )    drop { } ;
M: part        command-parameters>> ( part -- seq )    channel>> 1array ;
M: quit        command-parameters>> ( quit -- seq )    drop { } ;
M: nick        command-parameters>> ( nick -- seq )    drop { } ;
M: privmsg     command-parameters>> ( privmsg -- seq ) name>> 1array ;
M: notice      command-parameters>> ( norice -- seq )  type>> 1array ;
M: kick command-parameters>> ( kick -- seq )
    [ channel>> ] [ who>> ] bi 2array ;
M: mode command-parameters>> ( mode -- seq )
    [ name>> ] [ channel>> ] [ mode>> ] tri 3array ;

GENERIC: (>>command-parameters) ( params irc-message -- )

M: irc-message (>>command-parameters) ( params irc-message -- ) 2drop ;
M: logged-in (>>command-parameters) ( params part -- )  >r first r> (>>name) ;
M: part    (>>command-parameters) ( params part -- )    >r first r> (>>channel) ;
M: privmsg (>>command-parameters) ( params privmsg -- ) >r first r> (>>name) ;
M: notice  (>>command-parameters) ( params notice -- )  >r first r> (>>type) ;
M: kick    (>>command-parameters) ( params kick -- )
    >r first2 r> [ (>>who) ] [ (>>channel) ] bi ;
M: mode    (>>command-parameters) ( params mode -- )
    >r first2 r> [ (>>mode) ] [ (>>channel) ] bi ; ! FIXME
M: names-reply (>>command-parameters) ( params names-reply -- )
    [ >r first r> (>>who) ] [ >r third r> (>>channel) ] 2bi ;

PRIVATE>

GENERIC: irc-message>client-line ( irc-message -- string )

M: irc-message irc-message>client-line ( irc-message -- string )
    [ command-string>> ]
    [ command-parameters>> " " sjoin ]
    [ trailing>> [ CHAR: : prefix ] [ "" ] if* ]
    tri 3array " " sjoin ;

GENERIC: irc-message>server-line ( irc-message -- string )

M: irc-message irc-message>server-line ( irc-message -- string )
   drop "not implemented yet" ;

<PRIVATE
! ======================================
! Message parsing
! ======================================

: split-at-first ( seq separators -- before after )
    dupd '[ , member? ] find
        [ cut 1 tail ]
        [ swap ]
    if ;

: remove-heading-: ( seq -- seq ) dup ":" head? [ 1 tail ] when ;

: parse-name ( string -- string )
    remove-heading-: "!" split-at-first drop ;

: split-prefix ( string -- string/f string )
    dup ":" head?
        [ remove-heading-: " " split1 ]
        [ f swap ]
    if ;

: split-trailing ( string -- string string/f )
    ":" split1 ;

: copy-contents ( origin dest -- )
    { [ >r parameters>> r> [ (>>command-parameters) ] [ (>>parameters) ] 2bi ]
      [ >r line>>       r> (>>line) ]
      [ >r prefix>>     r> (>>prefix) ]
      [ >r command>>    r> (>>command) ]
      [ >r trailing>>   r> (>>trailing) ]
      [ >r timestamp>>  r> (>>timestamp) ]
    } 2cleave ;

PRIVATE>

UNION: sender-in-prefix privmsg join part quit kick mode nick ;
GENERIC: irc-message-sender ( irc-message -- sender )
M: sender-in-prefix irc-message-sender ( sender-in-prefix -- sender )
    prefix>> parse-name ;

: string>irc-message ( string -- object )
    dup split-prefix split-trailing
    [ [ blank? ] trim " " split unclip swap ] dip
    now irc-message boa ;

: parse-irc-line ( string -- message )
    string>irc-message
    dup command>> {
        { "PING" [ ping new ] }
        { "NOTICE" [ notice new ] }
        { "001" [ logged-in new ] }
        { "433" [ nick-in-use new ] }
        { "353" [ names-reply new ] }
        { "JOIN" [ join new ] }
        { "PART" [ part new ] }
        { "NICK" [ nick new ] }
        { "PRIVMSG" [ privmsg new ] }
        { "QUIT" [ quit new ] }
        { "MODE" [ mode new ] }
        { "KICK" [ kick new ] }
        [ drop unhandled new ]
    } case
    [ copy-contents ] keep ;
