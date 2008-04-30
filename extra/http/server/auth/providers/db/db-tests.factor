IN: http.server.auth.providers.db.tests
USING: http.server.auth.providers
http.server.auth.providers.db tools.test
namespaces db db.sqlite db.tuples continuations
io.files accessors kernel ;

users-in-db "provider" set

[ "auth-test.db" temp-file delete-file ] ignore-errors

"auth-test.db" temp-file sqlite-db [

    init-users-table

    [ t ] [
        "slava" <user>
            "foobar" >>password
            "slava@factorcode.org" >>email
            H{ } clone >>profile
            "provider" get new-user
            username>> "slava" =
    ] unit-test

    [ f ] [
        "slava" <user>
            H{ } clone >>profile
        "provider" get new-user
    ] unit-test

    [ f ] [ "fdasf" "slava" "provider" get check-login >boolean ] unit-test

    [ ] [ "foobar" "slava" "provider" get check-login "user" set ] unit-test

    [ t ] [ "user" get >boolean ] unit-test

    [ ] [ "user" get "fdasf" >>password drop ] unit-test

    [ ] [ "user" get "provider" get update-user ] unit-test

    [ t ] [ "fdasf" "slava" "provider" get check-login >boolean ] unit-test

    [ f ] [ "foobar" "slava" "provider" get check-login >boolean ] unit-test
] with-db
