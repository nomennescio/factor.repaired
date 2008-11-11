USING: help.markup help.syntax io kernel math quotations
opengl.gl assocs vocabs.loader sequences accessors ;
IN: opengl

HELP: gl-color
{ $values { "color" "a color specifier" } }
{ $description "Wrapper for " { $link glColor4d } " taking a color specifier." } ;

HELP: gl-error
{ $description "If the most recent OpenGL call resulted in an error, print the error to " { $link output-stream } "." } ;

HELP: do-enabled
{ $values { "what" integer } { "quot" quotation } }
{ $description "Wraps a quotation in " { $link glEnable } "/" { $link glDisable } " calls." } ;

HELP: do-matrix
{ $values { "mode" { $link GL_MODELVIEW } " or " { $link GL_PROJECTION } } { "quot" quotation } }
{ $description "Saves and restores the matrix specified by " { $snippet "mode" } " before and after calling the quotation." } ;

HELP: gl-line
{ $values { "a" "a pair of integers" } { "b" "a pair of integers" } }
{ $description "Draws a line between two points." } ;

HELP: gl-fill-rect
{ $values { "loc" "a pair of integers" } { "ext" "a pair of integers" } }
{ $description "Draws a filled rectangle with top-left corner " { $snippet "loc" } " and bottom-right corner " { $snippet "ext" } "." } ;

HELP: gl-rect
{ $values { "loc" "a pair of integers" } { "ext" "a pair of integers" } }
{ $description "Draws the outline of a rectangle with top-left corner " { $snippet "loc" } " and bottom-right corner " { $snippet "ext" } "." } ;

HELP: gen-texture
{ $values { "id" integer } }
{ $description "Wrapper for " { $link glGenTextures } " to handle the common case of generating a single texture ID." } ;

HELP: gen-gl-buffer
{ $values { "id" integer } }
{ $description "Wrapper for " { $link glGenBuffers } " to handle the common case of generating a single buffer ID." } ;

HELP: delete-texture
{ $values { "id" integer } }
{ $description "Wrapper for " { $link glDeleteTextures } " to handle the common case of deleting a single texture ID." } ;

HELP: delete-gl-buffer
{ $values { "id" integer } }
{ $description "Wrapper for " { $link glDeleteBuffers } " to handle the common case of deleting a single buffer ID." } ;

{ gen-texture delete-texture } related-words
{ gen-gl-buffer delete-gl-buffer } related-words

HELP: bind-texture-unit
{ $values { "id" "The id of a texture object." } { "target" "The texture target (e.g., " { $snippet "GL_TEXTURE_2D" } ")" } { "unit" "The texture unit to bind (e.g., " { $snippet "GL_TEXTURE0" } ")" } }
{ $description "Binds texture " { $snippet "id" } " to texture target " { $snippet "target" } " of texture unit " { $snippet "unit" } ". Equivalent to " { $snippet "unit glActiveTexture target id glBindTexture" } "." } ;

HELP: set-draw-buffers
{ $values { "buffers" "A sequence of buffer words (e.g. " { $snippet "GL_BACK" } ", " { $snippet "GL_COLOR_ATTACHMENT0_EXT" } ")"} }
{ $description "Wrapper for " { $link glDrawBuffers } ". Sets up the buffers named in the sequence for simultaneous drawing." } ;

HELP: do-attribs
{ $values { "bits" integer } { "quot" quotation } }
{ $description "Wraps a quotation in " { $link glPushAttrib } "/" { $link glPopAttrib } " calls." } ;

HELP: sprite
{ $class-description "A sprite is an OpenGL texture together with a display list which renders a textured quad. Sprites are used to draw text in the UI. Sprites have the following slots:"
    { $list
        { { $snippet "dlist" } " - an OpenGL display list ID" }
        { { $snippet "texture" } " - an OpenGL texture ID" }
        { { $snippet "loc" } " - top-left corner of the sprite" }
        { { $snippet "dim" } " - dimensions of the sprite" }
        { { $snippet "dim2" } " - dimensions of the sprite, rounded up to the nearest powers of two" }
    }
} ;

HELP: gray-texture
{ $values { "sprite" sprite } { "pixmap" "an alien or byte array" } { "id" "an OpenGL texture ID" } }
{ $description "Creates a new OpenGL texture from a 1 byte per pixel image whose dimensions are equal to " { $snippet "dim2" } "." } ;

HELP: gen-dlist
{ $values { "id" integer } }
{ $description "Wrapper for " { $link glGenLists } " to handle the common case of generating a single display list ID." } ;

HELP: make-dlist
{ $values { "type" "one of " { $link GL_COMPILE } " or " { $link GL_COMPILE_AND_EXECUTE } } { "quot" quotation } { "id" "an OpenGL texture ID" } }
{ $description "Compiles the results of calling the quotation into a new OpenGL display list." } ;

HELP: gl-translate
{ $values { "point" "a pair of integers" } }
{ $description "Wrapper for " { $link glTranslated } " taking a point object." } ;

HELP: free-sprites
{ $values { "sprites" "a sequence of " { $link sprite } " instances" } }
{ $description "Deallocates native resources associated toa  sequence of sprites." } ;

HELP: with-translation
{ $values { "loc" "a pair of integers" } { "quot" quotation } }
{ $description "Calls the quotation with a translation by " { $snippet "loc" } " pixels applied to the current " { $link GL_MODELVIEW } " matrix, restoring the matrix when the quotation is done." } ;


ARTICLE: "gl-utilities" "OpenGL utility words"
"The " { $vocab-link "opengl" } " vocabulary implements some utility words to give OpenGL a more Factor-like feel."
$nl
"The " { $vocab-link "opengl.gl" } " and " { $vocab-link "opengl.glu" } " vocabularies have the actual OpenGL bindings."
{ $subsection "opengl-low-level" }
"Wrappers:"
{ $subsection gl-color }
{ $subsection gl-translate }
{ $subsection gen-texture }
{ $subsection bind-texture-unit }
"Combinators:"
{ $subsection do-enabled }
{ $subsection do-attribs }
{ $subsection do-matrix }
{ $subsection with-translation }
{ $subsection make-dlist }
"Rendering geometric shapes:"
{ $subsection gl-line }
{ $subsection gl-fill-rect }
{ $subsection gl-rect }
;

ABOUT: "gl-utilities"
