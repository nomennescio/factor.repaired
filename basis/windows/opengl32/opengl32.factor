! Copyright (C) 2005, 2006 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.syntax parser namespaces kernel
math math.bitwise windows.types init assocs splitting
sequences libc opengl.gl opengl.gl.extensions opengl.gl.windows ;
IN: windows.opengl32

CONSTANT: LPD_TYPE_RGBA        0
CONSTANT: LPD_TYPE_COLORINDEX  1

! wglSwapLayerBuffers flags
CONSTANT: WGL_SWAP_MAIN_PLANE     0x00000001
CONSTANT: WGL_SWAP_OVERLAY1       0x00000002
CONSTANT: WGL_SWAP_OVERLAY2       0x00000004
CONSTANT: WGL_SWAP_OVERLAY3       0x00000008
CONSTANT: WGL_SWAP_OVERLAY4       0x00000010
CONSTANT: WGL_SWAP_OVERLAY5       0x00000020
CONSTANT: WGL_SWAP_OVERLAY6       0x00000040
CONSTANT: WGL_SWAP_OVERLAY7       0x00000080
CONSTANT: WGL_SWAP_OVERLAY8       0x00000100
CONSTANT: WGL_SWAP_OVERLAY9       0x00000200
CONSTANT: WGL_SWAP_OVERLAY10      0x00000400
CONSTANT: WGL_SWAP_OVERLAY11      0x00000800
CONSTANT: WGL_SWAP_OVERLAY12      0x00001000
CONSTANT: WGL_SWAP_OVERLAY13      0x00002000
CONSTANT: WGL_SWAP_OVERLAY14      0x00004000
CONSTANT: WGL_SWAP_OVERLAY15      0x00008000
CONSTANT: WGL_SWAP_UNDERLAY1      0x00010000
CONSTANT: WGL_SWAP_UNDERLAY2      0x00020000
CONSTANT: WGL_SWAP_UNDERLAY3      0x00040000
CONSTANT: WGL_SWAP_UNDERLAY4      0x00080000
CONSTANT: WGL_SWAP_UNDERLAY5      0x00100000
CONSTANT: WGL_SWAP_UNDERLAY6      0x00200000
CONSTANT: WGL_SWAP_UNDERLAY7      0x00400000
CONSTANT: WGL_SWAP_UNDERLAY8      0x00800000
CONSTANT: WGL_SWAP_UNDERLAY9      0x01000000
CONSTANT: WGL_SWAP_UNDERLAY10     0x02000000
CONSTANT: WGL_SWAP_UNDERLAY11     0x04000000
CONSTANT: WGL_SWAP_UNDERLAY12     0x08000000
CONSTANT: WGL_SWAP_UNDERLAY13     0x10000000
CONSTANT: WGL_SWAP_UNDERLAY14     0x20000000
CONSTANT: WGL_SWAP_UNDERLAY15     0x40000000


LIBRARY: gl


! FUNCTION: int ReleaseDC ( HWND hWnd, HDC hDC ) ;
! FUNCTION: HDC ResetDC ( HDC hdc, DEVMODE* lpInitData ) ;
! FUNCTION: BOOL RestoreDC ( HDC hdc, int nSavedDC ) ;
! FUNCTION: int SaveDC( HDC hDC ) ;
! FUNCTION: HGDIOBJ SelectObject ( HDC hDC, HGDIOBJ hgdiobj ) ;

FUNCTION: HGLRC wglCreateContext ( HDC hDC )
FUNCTION: BOOL wglDeleteContext ( HGLRC hRC )
FUNCTION: BOOL wglMakeCurrent ( HDC hDC, HGLRC hglrc )

! WGL_ARB_extensions_string extension

GL-FUNCTION: c-string wglGetExtensionsStringARB { } ( HDC hDC )

! WGL_ARB_pixel_format extension

CONSTANT: WGL_NUMBER_PIXEL_FORMATS_ARB    0x2000
CONSTANT: WGL_DRAW_TO_WINDOW_ARB          0x2001
CONSTANT: WGL_DRAW_TO_BITMAP_ARB          0x2002
CONSTANT: WGL_ACCELERATION_ARB            0x2003
CONSTANT: WGL_NEED_PALETTE_ARB            0x2004
CONSTANT: WGL_NEED_SYSTEM_PALETTE_ARB     0x2005
CONSTANT: WGL_SWAP_LAYER_BUFFERS_ARB      0x2006
CONSTANT: WGL_SWAP_METHOD_ARB             0x2007
CONSTANT: WGL_NUMBER_OVERLAYS_ARB         0x2008
CONSTANT: WGL_NUMBER_UNDERLAYS_ARB        0x2009
CONSTANT: WGL_TRANSPARENT_ARB             0x200A
CONSTANT: WGL_TRANSPARENT_RED_VALUE_ARB   0x2037
CONSTANT: WGL_TRANSPARENT_GREEN_VALUE_ARB 0x2038
CONSTANT: WGL_TRANSPARENT_BLUE_VALUE_ARB  0x2039
CONSTANT: WGL_TRANSPARENT_ALPHA_VALUE_ARB 0x203A
CONSTANT: WGL_TRANSPARENT_INDEX_VALUE_ARB 0x203B
CONSTANT: WGL_SHARE_DEPTH_ARB             0x200C
CONSTANT: WGL_SHARE_STENCIL_ARB           0x200D
CONSTANT: WGL_SHARE_ACCUM_ARB             0x200E
CONSTANT: WGL_SUPPORT_GDI_ARB             0x200F
CONSTANT: WGL_SUPPORT_OPENGL_ARB          0x2010
CONSTANT: WGL_DOUBLE_BUFFER_ARB           0x2011
CONSTANT: WGL_STEREO_ARB                  0x2012
CONSTANT: WGL_PIXEL_TYPE_ARB              0x2013
CONSTANT: WGL_COLOR_BITS_ARB              0x2014
CONSTANT: WGL_RED_BITS_ARB                0x2015
CONSTANT: WGL_RED_SHIFT_ARB               0x2016
CONSTANT: WGL_GREEN_BITS_ARB              0x2017
CONSTANT: WGL_GREEN_SHIFT_ARB             0x2018
CONSTANT: WGL_BLUE_BITS_ARB               0x2019
CONSTANT: WGL_BLUE_SHIFT_ARB              0x201A
CONSTANT: WGL_ALPHA_BITS_ARB              0x201B
CONSTANT: WGL_ALPHA_SHIFT_ARB             0x201C
CONSTANT: WGL_ACCUM_BITS_ARB              0x201D
CONSTANT: WGL_ACCUM_RED_BITS_ARB          0x201E
CONSTANT: WGL_ACCUM_GREEN_BITS_ARB        0x201F
CONSTANT: WGL_ACCUM_BLUE_BITS_ARB         0x2020
CONSTANT: WGL_ACCUM_ALPHA_BITS_ARB        0x2021
CONSTANT: WGL_DEPTH_BITS_ARB              0x2022
CONSTANT: WGL_STENCIL_BITS_ARB            0x2023
CONSTANT: WGL_AUX_BUFFERS_ARB             0x2024

CONSTANT: WGL_NO_ACCELERATION_ARB         0x2025
CONSTANT: WGL_GENERIC_ACCELERATION_ARB    0x2026
CONSTANT: WGL_FULL_ACCELERATION_ARB       0x2027

CONSTANT: WGL_SWAP_EXCHANGE_ARB           0x2028
CONSTANT: WGL_SWAP_COPY_ARB               0x2029
CONSTANT: WGL_SWAP_UNDEFINED_ARB          0x202A

CONSTANT: WGL_TYPE_RGBA_ARB               0x202B
CONSTANT: WGL_TYPE_COLORINDEX_ARB         0x202C

GL-FUNCTION: BOOL wglGetPixelFormatAttribivARB { } (
        HDC hdc,
        int iPixelFormat,
        int iLayerPlane,
        UINT nAttributes,
        int* piAttributes,
        int* piValues
    )

GL-FUNCTION: BOOL wglGetPixelFormatAttribfvARB { } (
        HDC hdc,
        int iPixelFormat,
        int iLayerPlane,
        UINT nAttributes,
        int* piAttributes,
        FLOAT* pfValues
    )

GL-FUNCTION: BOOL wglChoosePixelFormatARB { } (
        HDC hdc,
        int* piAttribIList,
        FLOAT* pfAttribFList,
        UINT nMaxFormats,
        int* piFormats,
        UINT* nNumFormats
    )

! WGL_ARB_multisample extension

CONSTANT: WGL_SAMPLE_BUFFERS_ARB 0x2041
CONSTANT: WGL_SAMPLES_ARB        0x2042

! WGL_ARB_pixel_format_float extension

CONSTANT: WGL_TYPE_RGBA_FLOAT_ARB 0x21A0

! wgl extensions querying

: has-wglGetExtensionsStringARB? ( -- ? )
    "wglGetExtensionsStringARB" wglGetProcAddress >boolean ;

: wgl-extensions ( hdc -- extensions )
    has-wglGetExtensionsStringARB? [ wglGetExtensionsStringARB words ] [ drop { } ] if ;

: has-wgl-extensions? ( hdc extensions -- ? )
    swap wgl-extensions [ member? ] curry all? ;

: has-wgl-pixel-format-extension? ( hdc -- ? )
    { "WGL_ARB_pixel_format" } has-wgl-extensions? ;
