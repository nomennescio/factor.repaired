USING: accessors assocs biassocs kernel lexer prettyprint
sequences unicode ;

IN: unicode.flags

MEMO: flag-codes ( -- biassoc ) H{
    { CHAR: A CHAR: ๐ฆ }
    { CHAR: B CHAR: ๐ง }
    { CHAR: C CHAR: ๐จ }
    { CHAR: D CHAR: ๐ฉ }
    { CHAR: E CHAR: ๐ช }
    { CHAR: F CHAR: ๐ซ }
    { CHAR: G CHAR: ๐ฌ }
    { CHAR: H CHAR: ๐ญ }
    { CHAR: I CHAR: ๐ฎ }
    { CHAR: J CHAR: ๐ฏ }
    { CHAR: K CHAR: ๐ฐ }
    { CHAR: L CHAR: ๐ฑ }
    { CHAR: M CHAR: ๐ฒ }
    { CHAR: N CHAR: ๐ณ }
    { CHAR: O CHAR: ๐ด }
    { CHAR: P CHAR: ๐ต }
    { CHAR: Q CHAR: ๐ถ }
    { CHAR: R CHAR: ๐ท }
    { CHAR: S CHAR: ๐ธ }
    { CHAR: T CHAR: ๐น }
    { CHAR: U CHAR: ๐บ }
    { CHAR: V CHAR: ๐ป }
    { CHAR: W CHAR: ๐ผ }
    { CHAR: X CHAR: ๐ฝ }
    { CHAR: Y CHAR: ๐พ }
    { CHAR: Z CHAR: ๐ฟ }
} >biassoc ;

: unicode>flag ( country-code -- flag )
    >upper [ flag-codes from>> at ] map ;

: flag>unicode ( flag -- country-code )
    [ flag-codes to>> at ] map ;

! Random flags, England/Scotland/Wales, Refugee Nation Flag
CONSTANT: extra-flags { "๐" "๐ฉ" "๐" "๐ด" "๐ณ" "๐ณ๏ธโ๐" "๐ดโโ ๏ธ" "๐ด๓ ง๓ ข๓ ฅ๓ ฎ๓ ง๓ ฟ" "๐ด๓ ง๓ ข๓ ณ๓ ฃ๓ ด๓ ฟ" "๐ด๓ ง๓ ข๓ ท๓ ฌ๓ ณ๓ ฟ" "๐ณ๏ธโ๐งโโฌ๏ธโ๐ง" }

: explain-extra-flags ( -- )
    extra-flags [
        dup . [ dup char>name ] { } map>assoc .
    ] each ;


SYNTAX: FLAG: scan-token unicode>flag suffix! ;
