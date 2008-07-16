USING: kernel tools.test accessors arrays sequences qualified
       io.streams.string io.streams.duplex namespaces threads
       calendar irc.client.private irc.client irc.messages.private
       concurrency.mailboxes classes assocs ;
EXCLUDE: irc.messages => join ;
RENAME: join irc.messages => join_
IN: irc.client.tests

! Utilities
: <test-stream> ( lines -- stream )
  "\n" join <string-reader> <string-writer> <duplex-stream> ;

: make-client ( lines -- irc-client )
   "someserver" irc-port "factorbot" f <irc-profile> <irc-client>
   swap [ 2nip <test-stream> f ] curry >>connect ;

: set-nick ( irc-client nickname -- )
     swap profile>> (>>nickname) ;

: with-dummy-client ( quot -- )
     rot with-variable ; inline

{ "" } make-client dup "factorbot" set-nick current-irc-client [
    { t } [ irc> profile>> nickname>> me? ] unit-test

    { "factorbot" } [ irc> profile>> nickname>> ] unit-test

    { "someuser" } [ "someuser!n=user@some.where" parse-name ] unit-test

    { "#factortest" } [ ":someuser!n=user@some.where PRIVMSG #factortest :hi"
                        parse-irc-line irc-message-origin ] unit-test

    { "someuser" } [ ":someuser!n=user@some.where PRIVMSG factorbot :hi"
                     parse-irc-line irc-message-origin ] unit-test
] with-variable

! Test login and nickname set
{ "factorbot" } [ { "NOTICE AUTH :*** Looking up your hostname..."
                    "NOTICE AUTH :*** Checking ident"
                    "NOTICE AUTH :*** Found your hostname"
                    "NOTICE AUTH :*** No identd (auth) response"
                    ":some.where 001 factorbot :Welcome factorbot"
                  } make-client
                  [ connect-irc ] keep 1 seconds sleep
                  profile>> nickname>> ] unit-test

{ join_ "#factortest" } [
           { ":factorbot!n=factorbo@some.where JOIN :#factortest"
             ":ircserver.net MODE #factortest +ns"
             ":ircserver.net 353 factorbot @ #factortest :@factorbot "
             ":ircserver.net 366 factorbot #factortest :End of /NAMES list."
             ":ircserver.net 477 factorbot #factortest :[ircserver-info] blah blah"
             } make-client dup "factorbot" set-nick
             [ connect-irc ] keep 1 seconds sleep
             join-messages>> 1 seconds mailbox-get-timeout
             [ class ] [ trailing>> ] bi ] unit-test

{ +join+ "somebody" } [
           { ":somebody!n=somebody@some.where JOIN :#factortest"
             } make-client dup "factorbot" set-nick
             [ listeners>> [ "#factortest" [ <irc-channel-listener> ] keep ] dip set-at ]
             [ connect-irc ]
             [ listeners>> [ "#factortest" ] dip at
               [ read-message drop ] [ read-message drop ] [ read-message ] tri ] tri
             [ action>> ] [ nick>> ] bi
             ] unit-test
! TODO: channel message
! ":somebody!n=somebody@some.where PRIVMSG #factortest :hello"
! TODO: direct private message
! ":somedude!n=user@isp.net PRIVMSG factorbot2 :hello"