USING: classes.struct windows.types windows.kernel32
windows.directx.d3d9types alien.c-types ;
IN: windows.directx.d3d9caps

STRUCT: D3DVSHADERCAPS2_0
    { Caps                    DWORD }
    { DynamicFlowControlDepth INT   }
    { NumTemps                INT   }
    { StaticFlowControlDepth  INT   } ;

CONSTANT: D3DVS20CAPS_PREDICATION 1

CONSTANT: D3DVS20_MAX_DYNAMICFLOWCONTROLDEPTH  24
CONSTANT: D3DVS20_MIN_DYNAMICFLOWCONTROLDEPTH  0
CONSTANT: D3DVS20_MAX_NUMTEMPS    32
CONSTANT: D3DVS20_MIN_NUMTEMPS    12
CONSTANT: D3DVS20_MAX_STATICFLOWCONTROLDEPTH    4
CONSTANT: D3DVS20_MIN_STATICFLOWCONTROLDEPTH    1

STRUCT: D3DPSHADERCAPS2_0
    { Caps                    DWORD }
    { DynamicFlowControlDepth INT   }
    { NumTemps                INT   }
    { StaticFlowControlDepth  INT   }
    { NumInstructionSlots     INT   } ;

CONSTANT: D3DPS20CAPS_ARBITRARYSWIZZLE        1
CONSTANT: D3DPS20CAPS_GRADIENTINSTRUCTIONS    2
CONSTANT: D3DPS20CAPS_PREDICATION             4
CONSTANT: D3DPS20CAPS_NODEPENDENTREADLIMIT    8
CONSTANT: D3DPS20CAPS_NOTEXINSTRUCTIONLIMIT   16

CONSTANT: D3DPS20_MAX_DYNAMICFLOWCONTROLDEPTH    24
CONSTANT: D3DPS20_MIN_DYNAMICFLOWCONTROLDEPTH    0
CONSTANT: D3DPS20_MAX_NUMTEMPS    32
CONSTANT: D3DPS20_MIN_NUMTEMPS    12
CONSTANT: D3DPS20_MAX_STATICFLOWCONTROLDEPTH    4
CONSTANT: D3DPS20_MIN_STATICFLOWCONTROLDEPTH    0
CONSTANT: D3DPS20_MAX_NUMINSTRUCTIONSLOTS    512
CONSTANT: D3DPS20_MIN_NUMINSTRUCTIONSLOTS    96

CONSTANT: D3DMIN30SHADERINSTRUCTIONS 512
CONSTANT: D3DMAX30SHADERINSTRUCTIONS 32768

STRUCT: D3DOVERLAYCAPS
    { Caps                      UINT }
    { MaxOverlayDisplayWidth    UINT }
    { MaxOverlayDisplayHeight   UINT } ;

CONSTANT: D3DOVERLAYCAPS_FULLRANGERGB          0x00000001
CONSTANT: D3DOVERLAYCAPS_LIMITEDRANGERGB       0x00000002
CONSTANT: D3DOVERLAYCAPS_YCbCr_BT601           0x00000004
CONSTANT: D3DOVERLAYCAPS_YCbCr_BT709           0x00000008
CONSTANT: D3DOVERLAYCAPS_YCbCr_BT601_xvYCC     0x00000010
CONSTANT: D3DOVERLAYCAPS_YCbCr_BT709_xvYCC     0x00000020
CONSTANT: D3DOVERLAYCAPS_STRETCHX              0x00000040
CONSTANT: D3DOVERLAYCAPS_STRETCHY              0x00000080


STRUCT: D3DCONTENTPROTECTIONCAPS
    { Caps                      DWORD     }
    { KeyExchangeType           GUID      }
    { BufferAlignmentStart      UINT      }
    { BlockAlignmentSize        UINT      }
    { ProtectedMemorySize       ULONGLONG } ;

CONSTANT: D3DCPCAPS_SOFTWARE              0x00000001
CONSTANT: D3DCPCAPS_HARDWARE              0x00000002
CONSTANT: D3DCPCAPS_PROTECTIONALWAYSON    0x00000004
CONSTANT: D3DCPCAPS_PARTIALDECRYPTION     0x00000008
CONSTANT: D3DCPCAPS_CONTENTKEY            0x00000010
CONSTANT: D3DCPCAPS_FRESHENSESSIONKEY     0x00000020
CONSTANT: D3DCPCAPS_ENCRYPTEDREADBACK     0x00000040
CONSTANT: D3DCPCAPS_ENCRYPTEDREADBACKKEY  0x00000080
CONSTANT: D3DCPCAPS_SEQUENTIAL_CTR_IV     0x00000100
CONSTANT: D3DCPCAPS_ENCRYPTSLICEDATAONLY  0x00000200

STRUCT: D3DCAPS9
    { DeviceType                          D3DDEVTYPE        }
    { AdapterOrdinal                      UINT              }
    { Caps                                DWORD             }
    { Caps2                               DWORD             }
    { Caps3                               DWORD             }
    { PresentationIntervals               DWORD             }
    { CursorCaps                          DWORD             }
    { DevCaps                             DWORD             }
    { PrimitiveMiscCaps                   DWORD             }
    { RasterCaps                          DWORD             }
    { ZCmpCaps                            DWORD             }
    { SrcBlendCaps                        DWORD             }
    { DestBlendCaps                       DWORD             }
    { AlphaCmpCaps                        DWORD             }
    { ShadeCaps                           DWORD             }
    { TextureCaps                         DWORD             }
    { TextureFilterCaps                   DWORD             }
    { CubeTextureFilterCaps               DWORD             }
    { VolumeTextureFilterCaps             DWORD             }
    { TextureAddressCaps                  DWORD             }
    { VolumeTextureAddressCaps            DWORD             }
    { LineCaps                            DWORD             }
    { MaxTextureWidth                     DWORD             }
    { MaxTextureHeight                    DWORD             }
    { MaxVolumeExtent                     DWORD             }
    { MaxTextureRepeat                    DWORD             }
    { MaxTextureAspectRatio               DWORD             }
    { MaxAnisotropy                       DWORD             }
    { MaxVertexW                          float             }
    { GuardBandLeft                       float             }
    { GuardBandTop                        float             }
    { GuardBandRight                      float             }
    { GuardBandBottom                     float             }
    { ExtentsAdjust                       float             }
    { StencilCaps                         DWORD             }
    { FVFCaps                             DWORD             }
    { TextureOpCaps                       DWORD             }
    { MaxTextureBlendStages               DWORD             }
    { MaxSimultaneousTextures             DWORD             }
    { VertexProcessingCaps                DWORD             }
    { MaxActiveLights                     DWORD             }
    { MaxUserClipPlanes                   DWORD             }
    { MaxVertexBlendMatrices              DWORD             }
    { MaxVertexBlendMatrixIndex           DWORD             }
    { MaxPointSize                        float             }
    { MaxPrimitiveCount                   DWORD             }
    { MaxVertexIndex                      DWORD             }
    { MaxStreams                          DWORD             }
    { MaxStreamStride                     DWORD             }
    { VertexShaderVersion                 DWORD             }
    { MaxVertexShaderConst                DWORD             }
    { PixelShaderVersion                  DWORD             }
    { PixelShader1xMaxValue               float             }
    { DevCaps2                            DWORD             }
    { MaxNpatchTessellationLevel          float             }
    { Reserved5                           DWORD             }
    { MasterAdapterOrdinal                UINT              }
    { AdapterOrdinalInGroup               UINT              }
    { NumberOfAdaptersInGroup             UINT              }
    { DeclTypes                           DWORD             }
    { NumSimultaneousRTs                  DWORD             }
    { StretchRectFilterCaps               DWORD             }
    { VS20Caps                            D3DVSHADERCAPS2_0 }
    { PS20Caps                            D3DPSHADERCAPS2_0 }
    { VertexTextureFilterCaps             DWORD             }
    { MaxVShaderInstructionsExecuted      DWORD             }
    { MaxPShaderInstructionsExecuted      DWORD             }
    { MaxVertexShader30InstructionSlots   DWORD             }
    { MaxPixelShader30InstructionSlots    DWORD             } ;

CONSTANT: D3DCAPS_OVERLAY                 0x00000800
CONSTANT: D3DCAPS_READ_SCANLINE           0x00020000

CONSTANT: D3DCAPS2_FULLSCREENGAMMA        0x00020000
CONSTANT: D3DCAPS2_CANCALIBRATEGAMMA      0x00100000
CONSTANT: D3DCAPS2_RESERVED               0x02000000
CONSTANT: D3DCAPS2_CANMANAGERESOURCE      0x10000000
CONSTANT: D3DCAPS2_DYNAMICTEXTURES        0x20000000
CONSTANT: D3DCAPS2_CANAUTOGENMIPMAP       0x40000000

CONSTANT: D3DCAPS2_CANSHARERESOURCE       0x80000000

CONSTANT: D3DCAPS3_RESERVED               0x8000001f

CONSTANT: D3DCAPS3_ALPHA_FULLSCREEN_FLIP_OR_DISCARD   0x00000020

CONSTANT: D3DCAPS3_LINEAR_TO_SRGB_PRESENTATION 0x00000080

CONSTANT: D3DCAPS3_COPY_TO_VIDMEM         0x00000100
CONSTANT: D3DCAPS3_COPY_TO_SYSTEMMEM      0x00000200
CONSTANT: D3DCAPS3_DXVAHD                 0x00000400

CONSTANT: D3DPRESENT_INTERVAL_DEFAULT     0x00000000
CONSTANT: D3DPRESENT_INTERVAL_ONE         0x00000001
CONSTANT: D3DPRESENT_INTERVAL_TWO         0x00000002
CONSTANT: D3DPRESENT_INTERVAL_THREE       0x00000004
CONSTANT: D3DPRESENT_INTERVAL_FOUR        0x00000008
CONSTANT: D3DPRESENT_INTERVAL_IMMEDIATE   0x80000000

CONSTANT: D3DCURSORCAPS_COLOR             0x00000001
CONSTANT: D3DCURSORCAPS_LOWRES            0x00000002

CONSTANT: D3DDEVCAPS_EXECUTESYSTEMMEMORY  0x00000010
CONSTANT: D3DDEVCAPS_EXECUTEVIDEOMEMORY   0x00000020
CONSTANT: D3DDEVCAPS_TLVERTEXSYSTEMMEMORY 0x00000040
CONSTANT: D3DDEVCAPS_TLVERTEXVIDEOMEMORY  0x00000080
CONSTANT: D3DDEVCAPS_TEXTURESYSTEMMEMORY  0x00000100
CONSTANT: D3DDEVCAPS_TEXTUREVIDEOMEMORY   0x00000200
CONSTANT: D3DDEVCAPS_DRAWPRIMTLVERTEX     0x00000400
CONSTANT: D3DDEVCAPS_CANRENDERAFTERFLIP   0x00000800
CONSTANT: D3DDEVCAPS_TEXTURENONLOCALVIDMEM 0x00001000
CONSTANT: D3DDEVCAPS_DRAWPRIMITIVES2      0x00002000
CONSTANT: D3DDEVCAPS_SEPARATETEXTUREMEMORIES 0x00004000
CONSTANT: D3DDEVCAPS_DRAWPRIMITIVES2EX    0x00008000
CONSTANT: D3DDEVCAPS_HWTRANSFORMANDLIGHT  0x00010000
CONSTANT: D3DDEVCAPS_CANBLTSYSTONONLOCAL  0x00020000
CONSTANT: D3DDEVCAPS_HWRASTERIZATION      0x00080000
CONSTANT: D3DDEVCAPS_PUREDEVICE           0x00100000
CONSTANT: D3DDEVCAPS_QUINTICRTPATCHES     0x00200000
CONSTANT: D3DDEVCAPS_RTPATCHES            0x00400000
CONSTANT: D3DDEVCAPS_RTPATCHHANDLEZERO    0x00800000
CONSTANT: D3DDEVCAPS_NPATCHES             0x01000000

CONSTANT: D3DPMISCCAPS_MASKZ              0x00000002
CONSTANT: D3DPMISCCAPS_CULLNONE           0x00000010
CONSTANT: D3DPMISCCAPS_CULLCW             0x00000020
CONSTANT: D3DPMISCCAPS_CULLCCW            0x00000040
CONSTANT: D3DPMISCCAPS_COLORWRITEENABLE   0x00000080
CONSTANT: D3DPMISCCAPS_CLIPPLANESCALEDPOINTS 0x00000100
CONSTANT: D3DPMISCCAPS_CLIPTLVERTS        0x00000200
CONSTANT: D3DPMISCCAPS_TSSARGTEMP         0x00000400
CONSTANT: D3DPMISCCAPS_BLENDOP            0x00000800
CONSTANT: D3DPMISCCAPS_NULLREFERENCE      0x00001000
CONSTANT: D3DPMISCCAPS_INDEPENDENTWRITEMASKS     0x00004000
CONSTANT: D3DPMISCCAPS_PERSTAGECONSTANT   0x00008000
CONSTANT: D3DPMISCCAPS_FOGANDSPECULARALPHA   0x00010000
CONSTANT: D3DPMISCCAPS_SEPARATEALPHABLEND         0x00020000
CONSTANT: D3DPMISCCAPS_MRTINDEPENDENTBITDEPTHS    0x00040000
CONSTANT: D3DPMISCCAPS_MRTPOSTPIXELSHADERBLENDING 0x00080000
CONSTANT: D3DPMISCCAPS_FOGVERTEXCLAMPED           0x00100000

CONSTANT: D3DPMISCCAPS_POSTBLENDSRGBCONVERT       0x00200000

CONSTANT: D3DLINECAPS_TEXTURE             0x00000001
CONSTANT: D3DLINECAPS_ZTEST               0x00000002
CONSTANT: D3DLINECAPS_BLEND               0x00000004
CONSTANT: D3DLINECAPS_ALPHACMP            0x00000008
CONSTANT: D3DLINECAPS_FOG                 0x00000010
CONSTANT: D3DLINECAPS_ANTIALIAS           0x00000020

CONSTANT: D3DPRASTERCAPS_DITHER                 0x00000001
CONSTANT: D3DPRASTERCAPS_ZTEST                  0x00000010
CONSTANT: D3DPRASTERCAPS_FOGVERTEX              0x00000080
CONSTANT: D3DPRASTERCAPS_FOGTABLE               0x00000100
CONSTANT: D3DPRASTERCAPS_MIPMAPLODBIAS          0x00002000
CONSTANT: D3DPRASTERCAPS_ZBUFFERLESSHSR         0x00008000
CONSTANT: D3DPRASTERCAPS_FOGRANGE               0x00010000
CONSTANT: D3DPRASTERCAPS_ANISOTROPY             0x00020000
CONSTANT: D3DPRASTERCAPS_WBUFFER                0x00040000
CONSTANT: D3DPRASTERCAPS_WFOG                   0x00100000
CONSTANT: D3DPRASTERCAPS_ZFOG                   0x00200000
CONSTANT: D3DPRASTERCAPS_COLORPERSPECTIVE       0x00400000
CONSTANT: D3DPRASTERCAPS_SCISSORTEST            0x01000000
CONSTANT: D3DPRASTERCAPS_SLOPESCALEDEPTHBIAS    0x02000000
CONSTANT: D3DPRASTERCAPS_DEPTHBIAS              0x04000000
CONSTANT: D3DPRASTERCAPS_MULTISAMPLE_TOGGLE     0x08000000

CONSTANT: D3DPCMPCAPS_NEVER               0x00000001
CONSTANT: D3DPCMPCAPS_LESS                0x00000002
CONSTANT: D3DPCMPCAPS_EQUAL               0x00000004
CONSTANT: D3DPCMPCAPS_LESSEQUAL           0x00000008
CONSTANT: D3DPCMPCAPS_GREATER             0x00000010
CONSTANT: D3DPCMPCAPS_NOTEQUAL            0x00000020
CONSTANT: D3DPCMPCAPS_GREATEREQUAL        0x00000040
CONSTANT: D3DPCMPCAPS_ALWAYS              0x00000080

CONSTANT: D3DPBLENDCAPS_ZERO              0x00000001
CONSTANT: D3DPBLENDCAPS_ONE               0x00000002
CONSTANT: D3DPBLENDCAPS_SRCCOLOR          0x00000004
CONSTANT: D3DPBLENDCAPS_INVSRCCOLOR       0x00000008
CONSTANT: D3DPBLENDCAPS_SRCALPHA          0x00000010
CONSTANT: D3DPBLENDCAPS_INVSRCALPHA       0x00000020
CONSTANT: D3DPBLENDCAPS_DESTALPHA         0x00000040
CONSTANT: D3DPBLENDCAPS_INVDESTALPHA      0x00000080
CONSTANT: D3DPBLENDCAPS_DESTCOLOR         0x00000100
CONSTANT: D3DPBLENDCAPS_INVDESTCOLOR      0x00000200
CONSTANT: D3DPBLENDCAPS_SRCALPHASAT       0x00000400
CONSTANT: D3DPBLENDCAPS_BOTHSRCALPHA      0x00000800
CONSTANT: D3DPBLENDCAPS_BOTHINVSRCALPHA   0x00001000
CONSTANT: D3DPBLENDCAPS_BLENDFACTOR       0x00002000

CONSTANT: D3DPBLENDCAPS_SRCCOLOR2         0x00004000
CONSTANT: D3DPBLENDCAPS_INVSRCCOLOR2      0x00008000

CONSTANT: D3DPSHADECAPS_COLORGOURAUDRGB       0x00000008
CONSTANT: D3DPSHADECAPS_SPECULARGOURAUDRGB    0x00000200
CONSTANT: D3DPSHADECAPS_ALPHAGOURAUDBLEND     0x00004000
CONSTANT: D3DPSHADECAPS_FOGGOURAUD            0x00080000

CONSTANT: D3DPTEXTURECAPS_PERSPECTIVE         0x00000001
CONSTANT: D3DPTEXTURECAPS_POW2                0x00000002
CONSTANT: D3DPTEXTURECAPS_ALPHA               0x00000004
CONSTANT: D3DPTEXTURECAPS_SQUAREONLY          0x00000020
CONSTANT: D3DPTEXTURECAPS_TEXREPEATNOTSCALEDBYSIZE 0x00000040
CONSTANT: D3DPTEXTURECAPS_ALPHAPALETTE        0x00000080

CONSTANT: D3DPTEXTURECAPS_NONPOW2CONDITIONAL  0x00000100
CONSTANT: D3DPTEXTURECAPS_PROJECTED           0x00000400
CONSTANT: D3DPTEXTURECAPS_CUBEMAP             0x00000800
CONSTANT: D3DPTEXTURECAPS_VOLUMEMAP           0x00002000
CONSTANT: D3DPTEXTURECAPS_MIPMAP              0x00004000
CONSTANT: D3DPTEXTURECAPS_MIPVOLUMEMAP        0x00008000
CONSTANT: D3DPTEXTURECAPS_MIPCUBEMAP          0x00010000
CONSTANT: D3DPTEXTURECAPS_CUBEMAP_POW2        0x00020000
CONSTANT: D3DPTEXTURECAPS_VOLUMEMAP_POW2      0x00040000
CONSTANT: D3DPTEXTURECAPS_NOPROJECTEDBUMPENV  0x00200000

CONSTANT: D3DPTFILTERCAPS_MINFPOINT           0x00000100
CONSTANT: D3DPTFILTERCAPS_MINFLINEAR          0x00000200
CONSTANT: D3DPTFILTERCAPS_MINFANISOTROPIC     0x00000400
CONSTANT: D3DPTFILTERCAPS_MINFPYRAMIDALQUAD   0x00000800
CONSTANT: D3DPTFILTERCAPS_MINFGAUSSIANQUAD    0x00001000
CONSTANT: D3DPTFILTERCAPS_MIPFPOINT           0x00010000
CONSTANT: D3DPTFILTERCAPS_MIPFLINEAR          0x00020000

CONSTANT: D3DPTFILTERCAPS_CONVOLUTIONMONO     0x00040000

CONSTANT: D3DPTFILTERCAPS_MAGFPOINT           0x01000000
CONSTANT: D3DPTFILTERCAPS_MAGFLINEAR          0x02000000
CONSTANT: D3DPTFILTERCAPS_MAGFANISOTROPIC     0x04000000
CONSTANT: D3DPTFILTERCAPS_MAGFPYRAMIDALQUAD   0x08000000
CONSTANT: D3DPTFILTERCAPS_MAGFGAUSSIANQUAD    0x10000000

CONSTANT: D3DPTADDRESSCAPS_WRAP           0x00000001
CONSTANT: D3DPTADDRESSCAPS_MIRROR         0x00000002
CONSTANT: D3DPTADDRESSCAPS_CLAMP          0x00000004
CONSTANT: D3DPTADDRESSCAPS_BORDER         0x00000008
CONSTANT: D3DPTADDRESSCAPS_INDEPENDENTUV  0x00000010
CONSTANT: D3DPTADDRESSCAPS_MIRRORONCE     0x00000020

CONSTANT: D3DSTENCILCAPS_KEEP             0x00000001
CONSTANT: D3DSTENCILCAPS_ZERO             0x00000002
CONSTANT: D3DSTENCILCAPS_REPLACE          0x00000004
CONSTANT: D3DSTENCILCAPS_INCRSAT          0x00000008
CONSTANT: D3DSTENCILCAPS_DECRSAT          0x00000010
CONSTANT: D3DSTENCILCAPS_INVERT           0x00000020
CONSTANT: D3DSTENCILCAPS_INCR             0x00000040
CONSTANT: D3DSTENCILCAPS_DECR             0x00000080
CONSTANT: D3DSTENCILCAPS_TWOSIDED         0x00000100

CONSTANT: D3DTEXOPCAPS_DISABLE                    0x00000001
CONSTANT: D3DTEXOPCAPS_SELECTARG1                 0x00000002
CONSTANT: D3DTEXOPCAPS_SELECTARG2                 0x00000004
CONSTANT: D3DTEXOPCAPS_MODULATE                   0x00000008
CONSTANT: D3DTEXOPCAPS_MODULATE2X                 0x00000010
CONSTANT: D3DTEXOPCAPS_MODULATE4X                 0x00000020
CONSTANT: D3DTEXOPCAPS_ADD                        0x00000040
CONSTANT: D3DTEXOPCAPS_ADDSIGNED                  0x00000080
CONSTANT: D3DTEXOPCAPS_ADDSIGNED2X                0x00000100
CONSTANT: D3DTEXOPCAPS_SUBTRACT                   0x00000200
CONSTANT: D3DTEXOPCAPS_ADDSMOOTH                  0x00000400
CONSTANT: D3DTEXOPCAPS_BLENDDIFFUSEALPHA          0x00000800
CONSTANT: D3DTEXOPCAPS_BLENDTEXTUREALPHA          0x00001000
CONSTANT: D3DTEXOPCAPS_BLENDFACTORALPHA           0x00002000
CONSTANT: D3DTEXOPCAPS_BLENDTEXTUREALPHAPM        0x00004000
CONSTANT: D3DTEXOPCAPS_BLENDCURRENTALPHA          0x00008000
CONSTANT: D3DTEXOPCAPS_PREMODULATE                0x00010000
CONSTANT: D3DTEXOPCAPS_MODULATEALPHA_ADDCOLOR     0x00020000
CONSTANT: D3DTEXOPCAPS_MODULATECOLOR_ADDALPHA     0x00040000
CONSTANT: D3DTEXOPCAPS_MODULATEINVALPHA_ADDCOLOR  0x00080000
CONSTANT: D3DTEXOPCAPS_MODULATEINVCOLOR_ADDALPHA  0x00100000
CONSTANT: D3DTEXOPCAPS_BUMPENVMAP                 0x00200000
CONSTANT: D3DTEXOPCAPS_BUMPENVMAPLUMINANCE        0x00400000
CONSTANT: D3DTEXOPCAPS_DOTPRODUCT3                0x00800000
CONSTANT: D3DTEXOPCAPS_MULTIPLYADD                0x01000000
CONSTANT: D3DTEXOPCAPS_LERP                       0x02000000

CONSTANT: D3DFVFCAPS_TEXCOORDCOUNTMASK    0x0000ffff
CONSTANT: D3DFVFCAPS_DONOTSTRIPELEMENTS   0x00080000
CONSTANT: D3DFVFCAPS_PSIZE                0x00100000

CONSTANT: D3DVTXPCAPS_TEXGEN              0x00000001
CONSTANT: D3DVTXPCAPS_MATERIALSOURCE7     0x00000002
CONSTANT: D3DVTXPCAPS_DIRECTIONALLIGHTS   0x00000008
CONSTANT: D3DVTXPCAPS_POSITIONALLIGHTS    0x00000010
CONSTANT: D3DVTXPCAPS_LOCALVIEWER         0x00000020
CONSTANT: D3DVTXPCAPS_TWEENING            0x00000040
CONSTANT: D3DVTXPCAPS_TEXGEN_SPHEREMAP    0x00000100
CONSTANT: D3DVTXPCAPS_NO_TEXGEN_NONLOCALVIEWER   0x00000200

CONSTANT: D3DDEVCAPS2_STREAMOFFSET                        0x00000001
CONSTANT: D3DDEVCAPS2_DMAPNPATCH                          0x00000002
CONSTANT: D3DDEVCAPS2_ADAPTIVETESSRTPATCH                 0x00000004
CONSTANT: D3DDEVCAPS2_ADAPTIVETESSNPATCH                  0x00000008
CONSTANT: D3DDEVCAPS2_CAN_STRETCHRECT_FROM_TEXTURES       0x00000010
CONSTANT: D3DDEVCAPS2_PRESAMPLEDDMAPNPATCH                0x00000020
CONSTANT: D3DDEVCAPS2_VERTEXELEMENTSCANSHARESTREAMOFFSET  0x00000040

CONSTANT: D3DDTCAPS_UBYTE4     0x00000001
CONSTANT: D3DDTCAPS_UBYTE4N    0x00000002
CONSTANT: D3DDTCAPS_SHORT2N    0x00000004
CONSTANT: D3DDTCAPS_SHORT4N    0x00000008
CONSTANT: D3DDTCAPS_USHORT2N   0x00000010
CONSTANT: D3DDTCAPS_USHORT4N   0x00000020
CONSTANT: D3DDTCAPS_UDEC3      0x00000040
CONSTANT: D3DDTCAPS_DEC3N      0x00000080
CONSTANT: D3DDTCAPS_FLOAT16_2  0x00000100
CONSTANT: D3DDTCAPS_FLOAT16_4  0x00000200
