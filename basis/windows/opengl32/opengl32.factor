! Copyright (C) 2005, 2006 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.syntax parser namespaces kernel
math math.bitwise windows.types init assocs
sequences libc opengl.gl ;
IN: windows.opengl32

! PIXELFORMATDESCRIPTOR flags
CONSTANT: PFD_DOUBLEBUFFER            HEX: 00000001
CONSTANT: PFD_STEREO                  HEX: 00000002
CONSTANT: PFD_DRAW_TO_WINDOW          HEX: 00000004
CONSTANT: PFD_DRAW_TO_BITMAP          HEX: 00000008
CONSTANT: PFD_SUPPORT_GDI             HEX: 00000010
CONSTANT: PFD_SUPPORT_OPENGL          HEX: 00000020
CONSTANT: PFD_GENERIC_FORMAT          HEX: 00000040
CONSTANT: PFD_NEED_PALETTE            HEX: 00000080
CONSTANT: PFD_NEED_SYSTEM_PALETTE     HEX: 00000100
CONSTANT: PFD_SWAP_EXCHANGE           HEX: 00000200
CONSTANT: PFD_SWAP_COPY               HEX: 00000400
CONSTANT: PFD_SWAP_LAYER_BUFFERS      HEX: 00000800
CONSTANT: PFD_GENERIC_ACCELERATED     HEX: 00001000
CONSTANT: PFD_SUPPORT_DIRECTDRAW      HEX: 00002000

! PIXELFORMATDESCRIPTOR flags for use in ChoosePixelFormat only
CONSTANT: PFD_DEPTH_DONTCARE          HEX: 20000000
CONSTANT: PFD_DOUBLEBUFFER_DONTCARE   HEX: 40000000
CONSTANT: PFD_STEREO_DONTCARE         HEX: 80000000

! pixel types
CONSTANT: PFD_TYPE_RGBA        0
CONSTANT: PFD_TYPE_COLORINDEX  1
 
! layer types
CONSTANT: PFD_MAIN_PLANE       0
CONSTANT: PFD_OVERLAY_PLANE    1
CONSTANT: PFD_UNDERLAY_PLANE   -1

CONSTANT: LPD_TYPE_RGBA        0
CONSTANT: LPD_TYPE_COLORINDEX  1

! wglSwapLayerBuffers flags
CONSTANT: WGL_SWAP_MAIN_PLANE     HEX: 00000001
CONSTANT: WGL_SWAP_OVERLAY1       HEX: 00000002
CONSTANT: WGL_SWAP_OVERLAY2       HEX: 00000004
CONSTANT: WGL_SWAP_OVERLAY3       HEX: 00000008
CONSTANT: WGL_SWAP_OVERLAY4       HEX: 00000010
CONSTANT: WGL_SWAP_OVERLAY5       HEX: 00000020
CONSTANT: WGL_SWAP_OVERLAY6       HEX: 00000040
CONSTANT: WGL_SWAP_OVERLAY7       HEX: 00000080
CONSTANT: WGL_SWAP_OVERLAY8       HEX: 00000100
CONSTANT: WGL_SWAP_OVERLAY9       HEX: 00000200
CONSTANT: WGL_SWAP_OVERLAY10      HEX: 00000400
CONSTANT: WGL_SWAP_OVERLAY11      HEX: 00000800
CONSTANT: WGL_SWAP_OVERLAY12      HEX: 00001000
CONSTANT: WGL_SWAP_OVERLAY13      HEX: 00002000
CONSTANT: WGL_SWAP_OVERLAY14      HEX: 00004000
CONSTANT: WGL_SWAP_OVERLAY15      HEX: 00008000
CONSTANT: WGL_SWAP_UNDERLAY1      HEX: 00010000
CONSTANT: WGL_SWAP_UNDERLAY2      HEX: 00020000
CONSTANT: WGL_SWAP_UNDERLAY3      HEX: 00040000
CONSTANT: WGL_SWAP_UNDERLAY4      HEX: 00080000
CONSTANT: WGL_SWAP_UNDERLAY5      HEX: 00100000
CONSTANT: WGL_SWAP_UNDERLAY6      HEX: 00200000
CONSTANT: WGL_SWAP_UNDERLAY7      HEX: 00400000
CONSTANT: WGL_SWAP_UNDERLAY8      HEX: 00800000
CONSTANT: WGL_SWAP_UNDERLAY9      HEX: 01000000
CONSTANT: WGL_SWAP_UNDERLAY10     HEX: 02000000
CONSTANT: WGL_SWAP_UNDERLAY11     HEX: 04000000
CONSTANT: WGL_SWAP_UNDERLAY12     HEX: 08000000
CONSTANT: WGL_SWAP_UNDERLAY13     HEX: 10000000
CONSTANT: WGL_SWAP_UNDERLAY14     HEX: 20000000
CONSTANT: WGL_SWAP_UNDERLAY15     HEX: 40000000

: windowed-pfd-dwFlags ( -- n )
    { PFD_DRAW_TO_WINDOW PFD_SUPPORT_OPENGL PFD_DOUBLEBUFFER } flags ;
: offscreen-pfd-dwFlags ( -- n )
    { PFD_DRAW_TO_BITMAP PFD_SUPPORT_OPENGL } flags ;

! TODO: compare to http://www.nullterminator.net/opengl32.html
: make-pfd ( flags bits -- pfd )
    "PIXELFORMATDESCRIPTOR" <c-object>
    "PIXELFORMATDESCRIPTOR" heap-size over set-PIXELFORMATDESCRIPTOR-nSize
    1 over set-PIXELFORMATDESCRIPTOR-nVersion
    rot over set-PIXELFORMATDESCRIPTOR-dwFlags
    PFD_TYPE_RGBA over set-PIXELFORMATDESCRIPTOR-iPixelType
    [ set-PIXELFORMATDESCRIPTOR-cColorBits ] keep
    16 over set-PIXELFORMATDESCRIPTOR-cDepthBits
    PFD_MAIN_PLANE over set-PIXELFORMATDESCRIPTOR-dwLayerMask ;


LIBRARY: gl


! FUNCTION: int ReleaseDC ( HWND hWnd, HDC hDC ) ;
! FUNCTION: HDC ResetDC ( HDC hdc, DEVMODE* lpInitData ) ;
! FUNCTION: BOOL RestoreDC ( HDC hdc, int nSavedDC ) ;
! FUNCTION: int SaveDC( HDC hDC ) ;
! FUNCTION: HGDIOBJ SelectObject ( HDC hDC, HGDIOBJ hgdiobj ) ;

FUNCTION: HGLRC wglCreateContext ( HDC hDC ) ;
FUNCTION: BOOL wglDeleteContext ( HGLRC hRC ) ;
FUNCTION: BOOL wglMakeCurrent ( HDC hDC, HGLRC hglrc ) ;

FUNCTION: HGLRC wglGetCurrentContext ( ) ;
FUNCTION: void* wglGetProcAddress ( char* name ) ;
