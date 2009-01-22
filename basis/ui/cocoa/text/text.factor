! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs accessors alien core-graphics.types core-text kernel
hashtables namespaces sequences ui.gadgets.worlds ui.text
ui.text.private opengl opengl.gl destructors combinators core-foundation
core-foundation.strings io.styles memoize math math.vectors ;
IN: ui.cocoa.text

SINGLETON: core-text-renderer

CONSTANT: font-names
    H{
        { "monospace" "Monaco" }
        { "sans-serif" "Helvetica" }
        { "serif" "Times" }
    }

: font-name ( string -- string' )
    font-names at-default ;

: (bold) ( x -- y ) kCTFontBoldTrait bitor ; inline

: (italic) ( x -- y ) kCTFontItalicTrait bitor ; inline

: font-traits ( style -- mask )
    [ 0 ] dip {
        { plain [ ] }
        { bold [ (bold) ] }
        { italic [ (italic) ] }
        { bold-italic [ (bold) (italic) ] }
    } case ;

: apply-font-traits ( font style -- font' )
    [ drop ] [ [ 0.0 f ] dip font-traits dup ] 2bi
    CTFontCreateCopyWithSymbolicTraits
    dup [ [ CFRelease ] dip ] [ drop ] if ;

MEMO: cache-font ( font -- open-font )
    [
        [
            [ first font-name <CFString> &CFRelease ] [ third ] bi
            f CTFontCreateWithName
        ] [ second ] bi apply-font-traits
    ] with-destructors ;

M: core-text-renderer open-font
    dup alien? [ cache-font ] unless ;

M: core-text-renderer string-dim
    [ " " string-dim { 0 1 } v* ] [ swap cached-line dim>> ] if-empty ;

TUPLE: line-texture line texture age disposed ;

: <line-texture> ( line -- texture )
    dup [ dim>> ] [ bitmap>> ] bi GL_RGBA make-texture
    0 f \ line-texture boa ;

M: line-texture dispose* texture>> delete-texture ;

: line-texture ( string open-font -- texture )
    world get fonts>> [ cached-line <line-texture> ] 2cache ;

: draw-line-texture ( line-texture -- )
    GL_TEXTURE_2D [
        GL_TEXTURE_BIT [
            GL_TEXTURE_COORD_ARRAY [
                GL_TEXTURE_2D over texture>> glBindTexture
                init-texture rect-texture-coords
                line>> dim>> fill-rect-vertices (gl-fill-rect)
                GL_TEXTURE_2D 0 glBindTexture
            ] do-enabled-client-state
        ] do-attribs
    ] do-enabled ;

M: core-text-renderer draw-string ( font string loc -- )
    [ swap open-font line-texture draw-line-texture ] with-translation ;

M: core-text-renderer x>offset ( x font string -- n )
    [ 2drop 0 ] [
        swap open-font cached-line line>>
        swap 0 <CGPoint> CTLineGetStringIndexForPosition
    ] if-empty ;

M: core-text-renderer offset>x ( n font string -- x )
    swap open-font cached-line line>> swap f CTLineGetOffsetForStringIndex ;

M: core-text-renderer free-fonts ( fonts -- )
    values dispose-each ;

core-text-renderer font-renderer set-global