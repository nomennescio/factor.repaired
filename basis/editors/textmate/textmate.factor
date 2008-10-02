USING: definitions io.launcher kernel math math.parser parser
namespaces prettyprint editors make ;

IN: editors.textmate

: textmate-location ( file line -- )
    [ "mate" , "-a" , "-l" , number>string , , ] { } make
    try-process ;

[ textmate-location ] edit-hook set-global
