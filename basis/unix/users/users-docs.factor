! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax io.streams.string kernel quotations sequences strings math ;
IN: unix.users

HELP: all-users
{ $values
    
     { "seq" sequence } }
{ $description "Returns a sequence of high-level " { $link passwd } " tuples that are platform-dependent and field for field complete with the Unix " { $link passwd } " structure." } ;

HELP: effective-username
{ $values
    
     { "string" string } }
{ $description "Returns the effective username for the current user." } ;

HELP: effective-username-id
{ $values
    
     { "id" integer } }
{ $description "Returns the effective username id for the current user." } ;

HELP: new-passwd
{ $values
    
     { "passwd" passwd } }
{ $description "Creates a new passwd tuple dependent on the operating system." } ;

HELP: passwd
{ $description "A platform-specific tuple correspding to every field from the Unix passwd struct. BSD passwd structures have four extra slots: " { $slot "change" } ", " { $slot "class" } "," { $slot "expire" } ", " { $slot "fields" } "." } ;

HELP: passwd-cache
{ $description "A symbol storing passwd structures indexed by user-ids when within a " { $link with-passwd-cache } "." } ;

HELP: passwd>new-passwd
{ $values
     { "passwd" "a passwd struct" }
     { "new-passwd" "a passwd tuple" } }
{ $description "A platform-specific conversion routine from a passwd structure to a passwd tuple." } ;

HELP: real-username
{ $values
    
     { "string" string } }
{ $description "The real username of the current user." } ;

HELP: real-username-id
{ $values
    
     { "id" integer } }
{ $description "The real user id of the current user." } ;

HELP: set-effective-username
{ $values
     { "string/id" "a string or a user id" } }
{ $description "Sets the current effective username." } ;

HELP: set-real-username
{ $values
     { "string/id" "a string or a user id" } }
{ $description "Sets the current real username." } ;

HELP: user-passwd
{ $values
     { "obj" object }
     { "passwd" passwd } }
{ $description "Returns the passwd tuple given a username string or user id." } ;

HELP: username
{ $values
     { "id" integer }
     { "string" string } }
{ $description "Returns the username associated with the user id." } ;

HELP: username-id
{ $values
     { "string" string }
     { "id" integer } }
{ $description "Returns the user id associated with the username." } ;

HELP: with-effective-username
{ $values
     { "string/id" "a string or a uid" } { "quot" quotation } }
{ $description "Sets the effective username and calls the quotation. Restores the current username on success or on error after the call." } ;

HELP: with-passwd-cache
{ $values
     { "quot" quotation } }
{ $description "Iterates over the password file using library calls and creates a cache in the " { $link passwd-cache } " symbol. The cache is a hashtable indexed by user id. When looking up many users, this approach is much faster than calling system calls." } ;

HELP: with-real-username
{ $values
     { "string/id" "a string or a uid" } { "quot" quotation } }
{ $description "Sets the real username and calls the quotation. Restores the current username on success or on error after the call." } ;

{
    real-username real-username-id set-real-username
    effective-username effective-username-id          
    set-effective-username
} related-words

ARTICLE: "unix.users" "unix.users"
"The " { $vocab-link "unix.users" } " vocabulary contains words that return information about Unix users."
"Listing all users:"
{ $subsection all-users }
"Returning a passwd tuple:"
"Real user:"
{ $subsection real-username }
{ $subsection real-username-id }
{ $subsection set-real-username }
"Effective user:"
{ $subsection effective-username }
{ $subsection effective-username-id }
{ $subsection set-effective-username }
"Combinators to change users:"
{ $subsection with-real-username }
{ $subsection with-effective-username } ;

ABOUT: "unix.users"
