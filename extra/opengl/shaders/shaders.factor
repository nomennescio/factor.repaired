! Copyright (C) 2008 Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel opengl.gl alien.c-types continuations namespaces
assocs alien libc opengl math sequences combinators.lib 
macros arrays ;
IN: opengl.shaders

: with-gl-shader-source-ptr ( string quot -- )
    swap string>char-alien malloc-byte-array [
        <void*> swap call
    ] keep free ; inline

: <gl-shader> ( source kind -- shader )
    glCreateShader dup rot
    [ 1 swap f glShaderSource ] with-gl-shader-source-ptr
    [ glCompileShader ] keep
    gl-error ;

: (gl-shader?) ( object -- ? )
    dup integer? [ glIsShader c-bool> ] [ drop f ] if ;

: gl-shader-get-int ( shader enum -- value )
    0 <int> [ glGetShaderiv ] keep *int ;

: gl-shader-ok? ( shader -- ? )
    GL_COMPILE_STATUS gl-shader-get-int c-bool> ;

: <vertex-shader> ( source -- vertex-shader )
    GL_VERTEX_SHADER <gl-shader> ; inline

: (vertex-shader?) ( object -- ? )
    dup (gl-shader?)
    [ GL_SHADER_TYPE gl-shader-get-int GL_VERTEX_SHADER = ]
    [ drop f ] if ;

: <fragment-shader> ( source -- fragment-shader )
    GL_FRAGMENT_SHADER <gl-shader> ; inline

: (fragment-shader?) ( object -- ? )
    dup (gl-shader?)
    [ GL_SHADER_TYPE gl-shader-get-int GL_FRAGMENT_SHADER = ]
    [ drop f ] if ;

: gl-shader-info-log-length ( shader -- log-length )
    GL_INFO_LOG_LENGTH gl-shader-get-int ; inline

: gl-shader-info-log ( shader -- log )
    dup gl-shader-info-log-length dup [
        [ 0 <int> swap glGetShaderInfoLog ] keep
        alien>char-string
    ] with-malloc ;

: check-gl-shader ( shader -- shader )
    dup gl-shader-ok? [ dup gl-shader-info-log throw ] unless ;

: delete-gl-shader ( shader -- ) glDeleteShader ; inline

PREDICATE: integer gl-shader (gl-shader?) ;
PREDICATE: gl-shader vertex-shader (vertex-shader?) ;
PREDICATE: gl-shader fragment-shader (fragment-shader?) ;

! Programs

: <gl-program> ( shaders -- program )
    glCreateProgram swap
    [ dupd glAttachShader ] each
    [ glLinkProgram ] keep
    gl-error ;
    
: (gl-program?) ( object -- ? )
    dup integer? [ glIsProgram c-bool> ] [ drop f ] if ;

: gl-program-get-int ( program enum -- value )
    0 <int> [ glGetProgramiv ] keep *int ;

: gl-program-ok? ( program -- ? )
    GL_LINK_STATUS gl-program-get-int c-bool> ;

: gl-program-info-log-length ( program -- log-length )
    GL_INFO_LOG_LENGTH gl-program-get-int ; inline

: gl-program-info-log ( program -- log )
    dup gl-program-info-log-length dup [
        [ 0 <int> swap glGetProgramInfoLog ] keep
        alien>char-string
    ] with-malloc ;

: check-gl-program ( program -- program )
    dup gl-program-ok? [ dup gl-program-info-log throw ] unless ;

: gl-program-shaders-length ( program -- shaders-length )
    GL_ATTACHED_SHADERS gl-program-get-int ; inline

: gl-program-shaders ( program -- shaders )
    dup gl-program-shaders-length [
        dup "GLuint" <c-array>
        [ 0 <int> swap glGetAttachedShaders ] keep
    ] keep c-uint-array> ;

: delete-gl-program-only ( program -- )
    glDeleteProgram ; inline

: detach-gl-program-shader ( program shader -- )
    glDetachShader ; inline

: delete-gl-program ( program -- )
    dup gl-program-shaders [
        2dup detach-gl-program-shader delete-gl-shader
    ] each delete-gl-program-only ;

: (with-gl-program) ( program quot -- )
    swap glUseProgram [ 0 glUseProgram ] [ ] cleanup ; inline

: (with-gl-program-uniforms) ( uniforms -- quot )
    [ [ swap , \ glGetUniformLocation , % ] [ ] make ]
    { } assoc>map ;
: (make-with-gl-program) ( uniforms quot -- q )
    [
        \ dup ,
        [ swap (with-gl-program-uniforms) , \ call-with , % ]
        [ ] make ,
        \ (with-gl-program) ,
    ] [ ] make ;

MACRO: with-gl-program ( uniforms quot -- )
    (make-with-gl-program) ;

PREDICATE: integer gl-program (gl-program?) ;

: <simple-gl-program> ( vertex-shader-source fragment-shader-source -- program )
    >r <vertex-shader> check-gl-shader
    r> <fragment-shader> check-gl-shader
    2array <gl-program> check-gl-program ;

