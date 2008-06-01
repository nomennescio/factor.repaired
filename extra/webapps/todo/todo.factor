! Copyright (c) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences namespaces
db db.types db.tuples validators hashtables urls
html.components
html.templates.chloe
furnace.sessions
furnace.boilerplate
furnace.auth
furnace.actions
furnace.db
furnace.auth.login
http.server ;
IN: webapps.todo

TUPLE: todo uid id priority summary description ;

todo "TODO"
{
    { "uid" "UID" { VARCHAR 256 } +not-null+ }
    { "id" "ID" +db-assigned-id+ }
    { "priority" "PRIORITY" INTEGER +not-null+ }
    { "summary" "SUMMARY" { VARCHAR 256 } +not-null+ }
    { "description" "DESCRIPTION" { VARCHAR 256 } }
} define-persistent

: init-todo-table todo ensure-table ;

: <todo> ( id -- todo )
    todo new
        swap >>id
        uid >>uid ;

: <view-action> ( -- action )
    <page-action>
        [
            validate-integer-id
            "id" value <todo> select-tuple from-object
        ] >>init
        
        "$todo-list/view-todo" >>template ;

: validate-todo ( -- )
    {
        { "summary" [ v-one-line ] }
        { "priority" [ v-integer 0 v-min-value 10 v-max-value ] }
        { "description" [ v-required ] }
    } validate-params ;

: <new-action> ( -- action )
    <page-action>
        [ 0 "priority" set-value ] >>init

        "$todo-list/new-todo" >>template

        [ validate-todo ] >>validate

        [
            f <todo>
                dup { "summary" "priority" "description" } deposit-slots
            [ insert-tuple ]
            [
                <url>
                    "$todo-list/view" >>path
                    swap id>> "id" set-query-param
                <redirect>
            ]
            bi
        ] >>submit ;

: <edit-action> ( -- action )
    <page-action>
        [
            validate-integer-id
            "id" value <todo> select-tuple from-object
        ] >>init

        "$todo-list/edit-todo" >>template

        [
            validate-integer-id
            validate-todo
        ] >>validate

        [
            f <todo>
                dup { "id" "summary" "priority" "description" } deposit-slots
            [ update-tuple ]
            [
                <url>
                    "$todo-list/view" >>path
                    swap id>> "id" set-query-param
                <redirect>
            ]
            bi
        ] >>submit ;

: <delete-action> ( -- action )
    <action>
        [ validate-integer-id ] >>validate

        [
            "id" get <todo> delete-tuples
            URL" $todo-list/list" <redirect>
        ] >>submit ;

: <list-action> ( -- action )
    <page-action>
        [ f <todo> select-tuples "items" set-value ] >>init
        "$todo-list/todo-list" >>template ;

TUPLE: todo-list < dispatcher ;

: <todo-list> ( -- responder )
    todo-list new-dispatcher
        <list-action>   "list"   add-main-responder
        <view-action>   "view"   add-responder
        <new-action>    "new"    add-responder
        <edit-action>   "edit"   add-responder
        <delete-action> "delete" add-responder
    <boilerplate>
        "$todo-list/todo" >>template
    f <protected> ;
