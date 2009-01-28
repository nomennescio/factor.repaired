! Copyright (C) 2009 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test xml.interpolate multiline kernel assocs
sequences accessors xml.writer xml.interpolate.private
locals splitting urls xml.data ;
IN: xml.interpolate.tests

[ "a" "c" { "a" "c" f } ] [
    "<?xml version='1.0'?><x><-a-><b val=<-c->/><-></x>"
    string>doc
    [ second var>> ]
    [ fourth "val" attr var>> ]
    [ extract-variables ] tri
] unit-test

[ {" <?xml version="1.0" encoding="UTF-8"?>
<x>
  one
  <b val="two"/>
  y
  <foo/>
</x>"} ] [
    [let* | a [ "one" ] c [ "two" ] x [ "y" ]
           d [ [XML <-x-> <foo/> XML] ] |
        <XML
            <x> <-a-> <b val=<-c->/> <-d-> </x>
        XML> pprint-xml>string
    ]
] unit-test

[ {" <?xml version="1.0" encoding="UTF-8"?>
<doc>
  <item>
    one
  </item>
  <item>
    two
  </item>
  <item>
    three
  </item>
</doc>"} ] [
    "one two three" " " split
    [ [XML <item><-></item> XML] ] map
    <XML <doc><-></doc> XML> pprint-xml>string
] unit-test

[ {" <?xml version="1.0" encoding="UTF-8"?>
<x number="3" url="http://factorcode.org/" string="hello" word="drop"/>"} ]
[ 3 f URL" http://factorcode.org/" "hello" \ drop
  <XML <x number=<-> false=<-> url=<-> string=<-> word=<->/> XML>
  pprint-xml>string  ] unit-test

[ "<x>3</x>" ] [ 3 [XML <x><-></x> XML] xml-chunk>string ] unit-test
[ "<x></x>" ] [ f [XML <x><-></x> XML] xml-chunk>string ] unit-test

\ parse-def must-infer
[ "" interpolate-chunk ] must-infer
[ [XML <foo><-></foo> <bar val=<->/> XML] ] must-infer
