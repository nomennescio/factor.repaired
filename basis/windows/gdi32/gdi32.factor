! FUNCTION: AbortDoc
! Copyright (C) 2005, 2006 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.syntax kernel windows.types ;
IN: windows.gdi32

! Stock Logical Objects
CONSTANT: WHITE_BRUSH         0
CONSTANT: LTGRAY_BRUSH        1
CONSTANT: GRAY_BRUSH          2
CONSTANT: DKGRAY_BRUSH        3
CONSTANT: BLACK_BRUSH         4
CONSTANT: NULL_BRUSH          5
ALIAS: HOLLOW_BRUSH        NULL_BRUSH
CONSTANT: WHITE_PEN           6
CONSTANT: BLACK_PEN           7
CONSTANT: NULL_PEN            8
CONSTANT: OEM_FIXED_FONT      10
CONSTANT: ANSI_FIXED_FONT     11
CONSTANT: ANSI_VAR_FONT       12
CONSTANT: SYSTEM_FONT         13
CONSTANT: DEVICE_DEFAULT_FONT 14
CONSTANT: DEFAULT_PALETTE     15
CONSTANT: SYSTEM_FIXED_FONT   16
CONSTANT: DEFAULT_GUI_FONT    17
CONSTANT: DC_BRUSH            18
CONSTANT: DC_PEN              19
                  
CONSTANT: BI_RGB        0
CONSTANT: BI_RLE8       1
CONSTANT: BI_RLE4       2
CONSTANT: BI_BITFIELDS  3

CONSTANT: DIB_RGB_COLORS 0
CONSTANT: DIB_PAL_COLORS 1

LIBRARY: gdi32

! FUNCTION: AbortPath
! FUNCTION: AddFontMemResourceEx
! FUNCTION: AddFontResourceA
! FUNCTION: AddFontResourceExA
! FUNCTION: AddFontResourceExW
! FUNCTION: AddFontResourceTracking
! FUNCTION: AddFontResourceW
! FUNCTION: AngleArc
! FUNCTION: AnimatePalette
! FUNCTION: AnyLinkedFonts
! FUNCTION: Arc
! FUNCTION: ArcTo
! FUNCTION: BeginPath
! FUNCTION: bInitSystemAndFontsDirectoriesW
! FUNCTION: BitBlt
! FUNCTION: bMakePathNameW
! FUNCTION: BRUSHOBJ_hGetColorTransform
! FUNCTION: BRUSHOBJ_pvAllocRbrush
! FUNCTION: BRUSHOBJ_pvGetRbrush
! FUNCTION: BRUSHOBJ_ulGetBrushColor
! FUNCTION: CancelDC
! FUNCTION: cGetTTFFromFOT
! FUNCTION: CheckColorsInGamut
FUNCTION: int ChoosePixelFormat ( HDC hDC, PFD* ppfd ) ;
! FUNCTION: Chord
! FUNCTION: ClearBitmapAttributes
! FUNCTION: ClearBrushAttributes
! FUNCTION: CLIPOBJ_bEnum
! FUNCTION: CLIPOBJ_cEnumStart
! FUNCTION: CLIPOBJ_ppoGetPath
! FUNCTION: CloseEnhMetaFile
! FUNCTION: CloseFigure
! FUNCTION: CloseMetaFile
! FUNCTION: ColorCorrectPalette
! FUNCTION: ColorMatchToTarget
! FUNCTION: CombineRgn
! FUNCTION: CombineTransform
! FUNCTION: CopyEnhMetaFileA
! FUNCTION: CopyEnhMetaFileW
! FUNCTION: CopyMetaFileA
! FUNCTION: CopyMetaFileW
! FUNCTION: CreateBitmap
! FUNCTION: CreateBitmapIndirect
! FUNCTION: CreateBrushIndirect
! FUNCTION: CreateColorSpaceA
! FUNCTION: CreateColorSpaceW
! FUNCTION: CreateCompatibleBitmap
FUNCTION: HDC CreateCompatibleDC ( HDC hdc ) ;
! FUNCTION: CreateDCA
! FUNCTION: CreateDCW
! FUNCTION: CreateDIBitmap
! FUNCTION: CreateDIBPatternBrush
! FUNCTION: CreateDIBPatternBrushPt
FUNCTION: HBITMAP CreateDIBSection ( HDC hdc, BITMAPINFO* pbmi, UINT iUsage, void** ppvBits, HANDLE hSection, DWORD dwOffset ) ;
! FUNCTION: CreateDiscardableBitmap
! FUNCTION: CreateEllipticRgn
! FUNCTION: CreateEllipticRgnIndirect
! FUNCTION: CreateEnhMetaFileA
! FUNCTION: CreateEnhMetaFileW
! FUNCTION: CreateFontA
! FUNCTION: CreateFontIndirectA
! FUNCTION: CreateFontIndirectExA
! FUNCTION: CreateFontIndirectExW
! FUNCTION: CreateFontIndirectW
! FUNCTION: CreateFontW
! FUNCTION: CreateHalftonePalette
! FUNCTION: CreateHatchBrush
! FUNCTION: CreateICA
! FUNCTION: CreateICW
! FUNCTION: CreateMetaFileA
! FUNCTION: CreateMetaFileW
! FUNCTION: CreatePalette
! FUNCTION: CreatePatternBrush
! FUNCTION: CreatePen
! FUNCTION: CreatePenIndirect
! FUNCTION: CreatePolygonRgn
! FUNCTION: CreatePolyPolygonRgn
FUNCTION: HRGN CreateRectRgn ( int x, int y, int w, int h ) ;
! FUNCTION: CreateRectRgnIndirect
! FUNCTION: CreateRoundRectRgn
! FUNCTION: CreateScalableFontResourceA
! FUNCTION: CreateScalableFontResourceW
! FUNCTION: CreateSolidBrush
! FUNCTION: DdEntry0
! FUNCTION: DdEntry1
! FUNCTION: DdEntry10
! FUNCTION: DdEntry11
! FUNCTION: DdEntry12
! FUNCTION: DdEntry13
! FUNCTION: DdEntry14
! FUNCTION: DdEntry15
! FUNCTION: DdEntry16
! FUNCTION: DdEntry17
! FUNCTION: DdEntry18
! FUNCTION: DdEntry19
! FUNCTION: DdEntry2
! FUNCTION: DdEntry20
! FUNCTION: DdEntry21
! FUNCTION: DdEntry22
! FUNCTION: DdEntry23
! FUNCTION: DdEntry24
! FUNCTION: DdEntry25
! FUNCTION: DdEntry26
! FUNCTION: DdEntry27
! FUNCTION: DdEntry28
! FUNCTION: DdEntry29
! FUNCTION: DdEntry3
! FUNCTION: DdEntry30
! FUNCTION: DdEntry31
! FUNCTION: DdEntry32
! FUNCTION: DdEntry33
! FUNCTION: DdEntry34
! FUNCTION: DdEntry35
! FUNCTION: DdEntry36
! FUNCTION: DdEntry37
! FUNCTION: DdEntry38
! FUNCTION: DdEntry39
! FUNCTION: DdEntry4
! FUNCTION: DdEntry40
! FUNCTION: DdEntry41
! FUNCTION: DdEntry42
! FUNCTION: DdEntry43
! FUNCTION: DdEntry44
! FUNCTION: DdEntry45
! FUNCTION: DdEntry46
! FUNCTION: DdEntry47
! FUNCTION: DdEntry48
! FUNCTION: DdEntry49
! FUNCTION: DdEntry5
! FUNCTION: DdEntry50
! FUNCTION: DdEntry51
! FUNCTION: DdEntry52
! FUNCTION: DdEntry53
! FUNCTION: DdEntry54
! FUNCTION: DdEntry55
! FUNCTION: DdEntry56
! FUNCTION: DdEntry6
! FUNCTION: DdEntry7
! FUNCTION: DdEntry8
! FUNCTION: DdEntry9
! FUNCTION: DeleteColorSpace
FUNCTION: BOOL DeleteDC ( HDC hdc ) ;
! FUNCTION: DeleteEnhMetaFile
! FUNCTION: DeleteMetaFile
FUNCTION: BOOL DeleteObject ( HGDIOBJ hObject ) ;
! FUNCTION: DescribePixelFormat
! FUNCTION: DeviceCapabilitiesExA
! FUNCTION: DeviceCapabilitiesExW
! FUNCTION: DPtoLP
! FUNCTION: DrawEscape
! FUNCTION: Ellipse
! FUNCTION: EnableEUDC
! FUNCTION: EndDoc
! FUNCTION: EndFormPage
! FUNCTION: EndPage
! FUNCTION: EndPath
! FUNCTION: EngAcquireSemaphore
! FUNCTION: EngAlphaBlend
! FUNCTION: EngAssociateSurface
! FUNCTION: EngBitBlt
! FUNCTION: EngCheckAbort
! FUNCTION: EngComputeGlyphSet
! FUNCTION: EngCopyBits
! FUNCTION: EngCreateBitmap
! FUNCTION: EngCreateClip
! FUNCTION: EngCreateDeviceBitmap
! FUNCTION: EngCreateDeviceSurface
! FUNCTION: EngCreatePalette
! FUNCTION: EngCreateSemaphore
! FUNCTION: EngDeleteClip
! FUNCTION: EngDeletePalette
! FUNCTION: EngDeletePath
! FUNCTION: EngDeleteSemaphore
! FUNCTION: EngDeleteSurface
! FUNCTION: EngEraseSurface
! FUNCTION: EngFillPath
! FUNCTION: EngFindResource
! FUNCTION: EngFreeModule
! FUNCTION: EngGetCurrentCodePage
! FUNCTION: EngGetDriverName
! FUNCTION: EngGetPrinterDataFileName
! FUNCTION: EngGradientFill
! FUNCTION: EngLineTo
! FUNCTION: EngLoadModule
! FUNCTION: EngLockSurface
! FUNCTION: EngMarkBandingSurface
! FUNCTION: EngMultiByteToUnicodeN
! FUNCTION: EngMultiByteToWideChar
! FUNCTION: EngPaint
! FUNCTION: EngPlgBlt
! FUNCTION: EngQueryEMFInfo
! FUNCTION: EngQueryLocalTime
! FUNCTION: EngReleaseSemaphore
! FUNCTION: EngStretchBlt
! FUNCTION: EngStretchBltROP
! FUNCTION: EngStrokeAndFillPath
! FUNCTION: EngStrokePath
! FUNCTION: EngTextOut
! FUNCTION: EngTransparentBlt
! FUNCTION: EngUnicodeToMultiByteN
! FUNCTION: EngUnlockSurface
! FUNCTION: EngWideCharToMultiByte
! FUNCTION: EnumEnhMetaFile
! FUNCTION: EnumFontFamiliesA
! FUNCTION: EnumFontFamiliesExA
! FUNCTION: EnumFontFamiliesExW
! FUNCTION: EnumFontFamiliesW
! FUNCTION: EnumFontsA
! FUNCTION: EnumFontsW
! FUNCTION: EnumICMProfilesA
! FUNCTION: EnumICMProfilesW
! FUNCTION: EnumMetaFile
! FUNCTION: EnumObjects
! FUNCTION: EqualRgn
! FUNCTION: Escape
! FUNCTION: EudcLoadLinkW
! FUNCTION: EudcUnloadLinkW
! FUNCTION: ExcludeClipRect
! FUNCTION: ExtCreatePen
! FUNCTION: ExtCreateRegion
! FUNCTION: ExtEscape
! FUNCTION: ExtFloodFill
! FUNCTION: ExtSelectClipRgn
! FUNCTION: ExtTextOutA
! FUNCTION: ExtTextOutW
! FUNCTION: FillPath
! FUNCTION: FillRgn
! FUNCTION: FixBrushOrgEx
! FUNCTION: FlattenPath
! FUNCTION: FloodFill
! FUNCTION: FontIsLinked
! FUNCTION: FONTOBJ_cGetAllGlyphHandles
! FUNCTION: FONTOBJ_cGetGlyphs
! FUNCTION: FONTOBJ_pfdg
! FUNCTION: FONTOBJ_pifi
! FUNCTION: FONTOBJ_pQueryGlyphAttrs
! FUNCTION: FONTOBJ_pvTrueTypeFontFile
! FUNCTION: FONTOBJ_pxoGetXform
! FUNCTION: FONTOBJ_vGetInfo
! FUNCTION: FrameRgn
! FUNCTION: GdiAddFontResourceW
! FUNCTION: GdiAddGlsBounds
! FUNCTION: GdiAddGlsRecord
! FUNCTION: GdiAlphaBlend
! FUNCTION: GdiArtificialDecrementDriver
! FUNCTION: GdiCleanCacheDC
! FUNCTION: GdiComment
! FUNCTION: GdiConsoleTextOut
! FUNCTION: GdiConvertAndCheckDC
! FUNCTION: GdiConvertBitmap
! FUNCTION: GdiConvertBitmapV5
! FUNCTION: GdiConvertBrush
! FUNCTION: GdiConvertDC
! FUNCTION: GdiConvertEnhMetaFile
! FUNCTION: GdiConvertFont
! FUNCTION: GdiConvertMetaFilePict
! FUNCTION: GdiConvertPalette
! FUNCTION: GdiConvertRegion
! FUNCTION: GdiConvertToDevmodeW
! FUNCTION: GdiCreateLocalEnhMetaFile
! FUNCTION: GdiCreateLocalMetaFilePict
! FUNCTION: GdiDeleteLocalDC
! FUNCTION: GdiDeleteSpoolFileHandle
! FUNCTION: GdiDescribePixelFormat
! FUNCTION: GdiDllInitialize
! FUNCTION: GdiDrawStream
! FUNCTION: GdiEndDocEMF
! FUNCTION: GdiEndPageEMF
! FUNCTION: GdiEntry1
! FUNCTION: GdiEntry10
! FUNCTION: GdiEntry11
! FUNCTION: GdiEntry12
! FUNCTION: GdiEntry13
! FUNCTION: GdiEntry14
! FUNCTION: GdiEntry15
! FUNCTION: GdiEntry16
! FUNCTION: GdiEntry2
! FUNCTION: GdiEntry3
! FUNCTION: GdiEntry4
! FUNCTION: GdiEntry5
! FUNCTION: GdiEntry6
! FUNCTION: GdiEntry7
! FUNCTION: GdiEntry8
! FUNCTION: GdiEntry9
! FUNCTION: GdiFixUpHandle
FUNCTION: BOOL GdiFlush ( ) ;
! FUNCTION: GdiFullscreenControl
! FUNCTION: GdiGetBatchLimit
! FUNCTION: GdiGetCharDimensions
! FUNCTION: GdiGetCodePage
! FUNCTION: GdiGetDC
! FUNCTION: GdiGetDevmodeForPage
! FUNCTION: GdiGetLocalBrush
! FUNCTION: GdiGetLocalDC
! FUNCTION: GdiGetLocalFont
! FUNCTION: GdiGetPageCount
! FUNCTION: GdiGetPageHandle
! FUNCTION: GdiGetSpoolFileHandle
! FUNCTION: GdiGetSpoolMessage
! FUNCTION: GdiGradientFill
! FUNCTION: GdiInitializeLanguagePack
! FUNCTION: GdiInitSpool
! FUNCTION: GdiIsMetaFileDC
! FUNCTION: GdiIsMetaPrintDC
! FUNCTION: GdiIsPlayMetafileDC
! FUNCTION: GdiPlayDCScript
! FUNCTION: GdiPlayEMF
! FUNCTION: GdiPlayJournal
! FUNCTION: GdiPlayPageEMF
! FUNCTION: GdiPlayPrivatePageEMF
! FUNCTION: GdiPlayScript
! FUNCTION: gdiPlaySpoolStream
! FUNCTION: GdiPrinterThunk
! FUNCTION: GdiProcessSetup
! FUNCTION: GdiQueryFonts
! FUNCTION: GdiQueryTable
! FUNCTION: GdiRealizationInfo
! FUNCTION: GdiReleaseDC
! FUNCTION: GdiReleaseLocalDC
! FUNCTION: GdiResetDCEMF
! FUNCTION: GdiSetAttrs
! FUNCTION: GdiSetBatchLimit
! FUNCTION: GdiSetLastError
! FUNCTION: GdiSetPixelFormat
! FUNCTION: GdiSetServerAttr
! FUNCTION: GdiStartDocEMF
! FUNCTION: GdiStartPageEMF
! FUNCTION: GdiSwapBuffers
! FUNCTION: GdiTransparentBlt
! FUNCTION: GdiValidateHandle
! FUNCTION: GetArcDirection
! FUNCTION: GetAspectRatioFilterEx
! FUNCTION: GetBitmapAttributes
! FUNCTION: GetBitmapBits
! FUNCTION: GetBitmapDimensionEx
! FUNCTION: GetBkColor
! FUNCTION: GetBkMode
! FUNCTION: GetBoundsRect
! FUNCTION: GetBrushAttributes
! FUNCTION: GetBrushOrgEx
! FUNCTION: GetCharABCWidthsA
! FUNCTION: GetCharABCWidthsFloatA
! FUNCTION: GetCharABCWidthsFloatW
! FUNCTION: GetCharABCWidthsI
! FUNCTION: GetCharABCWidthsW
! FUNCTION: GetCharacterPlacementA
! FUNCTION: GetCharacterPlacementW
! FUNCTION: GetCharWidth32A
! FUNCTION: GetCharWidth32W
! FUNCTION: GetCharWidthA
! FUNCTION: GetCharWidthFloatA
! FUNCTION: GetCharWidthFloatW
! FUNCTION: GetCharWidthI
! FUNCTION: GetCharWidthInfo
! FUNCTION: GetCharWidthW
! FUNCTION: GetClipBox
! FUNCTION: GetClipRgn
! FUNCTION: GetColorAdjustment
! FUNCTION: GetColorSpace
! FUNCTION: GetCurrentObject
! FUNCTION: GetCurrentPositionEx
! FUNCTION: GetDCBrushColor
! FUNCTION: GetDCOrgEx
! FUNCTION: GetDCPenColor
! FUNCTION: GetDeviceCaps
! FUNCTION: GetDeviceGammaRamp
! FUNCTION: GetDIBColorTable
! FUNCTION: GetDIBits
! FUNCTION: GetEnhMetaFileA
! FUNCTION: GetEnhMetaFileBits
! FUNCTION: GetEnhMetaFileDescriptionA
! FUNCTION: GetEnhMetaFileDescriptionW
! FUNCTION: GetEnhMetaFileHeader
! FUNCTION: GetEnhMetaFilePaletteEntries
! FUNCTION: GetEnhMetaFilePixelFormat
! FUNCTION: GetEnhMetaFileW
! FUNCTION: GetETM
! FUNCTION: GetEUDCTimeStamp
! FUNCTION: GetEUDCTimeStampExW
! FUNCTION: GetFontAssocStatus
! FUNCTION: GetFontData
! FUNCTION: GetFontLanguageInfo
! FUNCTION: GetFontResourceInfoW
! FUNCTION: GetFontUnicodeRanges
! FUNCTION: GetGlyphIndicesA
! FUNCTION: GetGlyphIndicesW
! FUNCTION: GetGlyphOutline
! FUNCTION: GetGlyphOutlineA
! FUNCTION: GetGlyphOutlineW
! FUNCTION: GetGlyphOutlineWow
! FUNCTION: GetGraphicsMode
! FUNCTION: GetHFONT
! FUNCTION: GetICMProfileA
! FUNCTION: GetICMProfileW
! FUNCTION: GetKerningPairs
! FUNCTION: GetKerningPairsA
! FUNCTION: GetKerningPairsW
! FUNCTION: GetLayout
! FUNCTION: GetLogColorSpaceA
! FUNCTION: GetLogColorSpaceW
! FUNCTION: GetMapMode
! FUNCTION: GetMetaFileA
! FUNCTION: GetMetaFileBitsEx
! FUNCTION: GetMetaFileW
! FUNCTION: GetMetaRgn
! FUNCTION: GetMiterLimit
! FUNCTION: GetNearestColor
! FUNCTION: GetNearestPaletteIndex
! FUNCTION: GetObjectA
! FUNCTION: GetObjectType
! FUNCTION: GetObjectW
! FUNCTION: GetOutlineTextMetricsA
! FUNCTION: GetOutlineTextMetricsW
! FUNCTION: GetPaletteEntries
! FUNCTION: GetPath
! FUNCTION: GetPixel
! FUNCTION: GetPixelFormat
! FUNCTION: GetPolyFillMode
! FUNCTION: GetRandomRgn
! FUNCTION: GetRasterizerCaps
! FUNCTION: GetRegionData
! FUNCTION: GetRelAbs
! FUNCTION: GetRgnBox
! FUNCTION: GetROP2
FUNCTION: HGDIOBJ GetStockObject ( int fnObject ) ;
! FUNCTION: GetStretchBltMode
! FUNCTION: GetStringBitmapA
! FUNCTION: GetStringBitmapW
! FUNCTION: GetSystemPaletteEntries
! FUNCTION: GetSystemPaletteUse
! FUNCTION: GetTextAlign
! FUNCTION: GetTextCharacterExtra
! FUNCTION: GetTextCharset
! FUNCTION: GetTextCharsetInfo
! FUNCTION: GetTextColor
! FUNCTION: GetTextExtentExPointA
! FUNCTION: GetTextExtentExPointI
! FUNCTION: GetTextExtentExPointW
! FUNCTION: GetTextExtentExPointWPri
! FUNCTION: GetTextExtentPoint32A
! FUNCTION: GetTextExtentPoint32W
! FUNCTION: GetTextExtentPointA
! FUNCTION: GetTextExtentPointI
! FUNCTION: GetTextExtentPointW
! FUNCTION: GetTextFaceA
! FUNCTION: GetTextFaceAliasW
! FUNCTION: GetTextFaceW
! FUNCTION: GetTextMetricsA
! FUNCTION: GetTextMetricsW
! FUNCTION: GetTransform
! FUNCTION: GetViewportExtEx
! FUNCTION: GetViewportOrgEx
! FUNCTION: GetWindowExtEx
! FUNCTION: GetWindowOrgEx
! FUNCTION: GetWinMetaFileBits
! FUNCTION: GetWorldTransform
! FUNCTION: HT_Get8BPPFormatPalette
! FUNCTION: HT_Get8BPPMaskPalette
! FUNCTION: IntersectClipRect
! FUNCTION: InvertRgn
! FUNCTION: IsValidEnhMetaRecord
! FUNCTION: IsValidEnhMetaRecordOffExt
! FUNCTION: LineDDA
! FUNCTION: LineTo
! FUNCTION: LPtoDP
! FUNCTION: MaskBlt
! FUNCTION: MirrorRgn
! FUNCTION: ModifyWorldTransform
! FUNCTION: MoveToEx
! FUNCTION: NamedEscape
! FUNCTION: OffsetClipRgn
! FUNCTION: OffsetRgn
! FUNCTION: OffsetViewportOrgEx
! FUNCTION: OffsetWindowOrgEx
! FUNCTION: PaintRgn
! FUNCTION: PatBlt
! FUNCTION: PATHOBJ_bEnum
! FUNCTION: PATHOBJ_bEnumClipLines
! FUNCTION: PATHOBJ_vEnumStart
! FUNCTION: PATHOBJ_vEnumStartClipLines
! FUNCTION: PATHOBJ_vGetBounds
! FUNCTION: PathToRegion
! FUNCTION: Pie
! FUNCTION: PlayEnhMetaFile
! FUNCTION: PlayEnhMetaFileRecord
! FUNCTION: PlayMetaFile
! FUNCTION: PlayMetaFileRecord
! FUNCTION: PlgBlt
! FUNCTION: PolyBezier
! FUNCTION: PolyBezierTo
! FUNCTION: PolyDraw
! FUNCTION: Polygon
! FUNCTION: Polyline
! FUNCTION: PolylineTo
! FUNCTION: PolyPatBlt
! FUNCTION: PolyPolygon
! FUNCTION: PolyPolyline
! FUNCTION: PolyTextOutA
! FUNCTION: PolyTextOutW
! FUNCTION: PtInRegion
! FUNCTION: PtVisible
! FUNCTION: QueryFontAssocStatus
! FUNCTION: RealizePalette
! FUNCTION: Rectangle
! FUNCTION: RectInRegion
! FUNCTION: RectVisible
! FUNCTION: RemoveFontMemResourceEx
! FUNCTION: RemoveFontResourceA
! FUNCTION: RemoveFontResourceExA
! FUNCTION: RemoveFontResourceExW
! FUNCTION: RemoveFontResourceTracking
! FUNCTION: RemoveFontResourceW
! FUNCTION: ResetDCA
! FUNCTION: ResetDCW
! FUNCTION: ResizePalette
! FUNCTION: RestoreDC
! FUNCTION: RoundRect
! FUNCTION: SaveDC
! FUNCTION: ScaleViewportExtEx
! FUNCTION: ScaleWindowExtEx
! FUNCTION: SelectBrushLocal
! FUNCTION: SelectClipPath
FUNCTION: int SelectClipRgn ( HDC hDC, HRGN hrgn ) ;
! FUNCTION: SelectFontLocal
FUNCTION: HGDIOBJ SelectObject ( HDC hdc, HGDIOBJ hgdiobj ) ;
! FUNCTION: SelectPalette
! FUNCTION: SetAbortProc
! FUNCTION: SetArcDirection
! FUNCTION: SetBitmapAttributes
! FUNCTION: SetBitmapBits
! FUNCTION: SetBitmapDimensionEx
! FUNCTION: SetBkColor
! FUNCTION: SetBkMode
! FUNCTION: SetBoundsRect
! FUNCTION: SetBrushAttributes
! FUNCTION: SetBrushOrgEx
! FUNCTION: SetColorAdjustment
! FUNCTION: SetColorSpace
! FUNCTION: SetDCBrushColor
! FUNCTION: SetDCPenColor
! FUNCTION: SetDeviceGammaRamp
! FUNCTION: SetDIBColorTable
! FUNCTION: SetDIBits
! FUNCTION: SetDIBitsToDevice
! FUNCTION: SetEnhMetaFileBits
! FUNCTION: SetFontEnumeration
! FUNCTION: SetGraphicsMode
! FUNCTION: SetICMMode
! FUNCTION: SetICMProfileA
! FUNCTION: SetICMProfileW
! FUNCTION: SetLayout
! FUNCTION: SetLayoutWidth
! FUNCTION: SetMagicColors
! FUNCTION: SetMapMode
! FUNCTION: SetMapperFlags
! FUNCTION: SetMetaFileBitsEx
! FUNCTION: SetMetaRgn
! FUNCTION: SetMiterLimit
! FUNCTION: SetPaletteEntries
! FUNCTION: SetPixel
FUNCTION: BOOL SetPixelFormat ( HDC hDC, int iPixelFormat, PFD* ppfd ) ;
! FUNCTION: SetPixelV
! FUNCTION: SetPolyFillMode
! FUNCTION: SetRectRgn
! FUNCTION: SetRelAbs
! FUNCTION: SetROP2
! FUNCTION: SetStretchBltMode
! FUNCTION: SetSystemPaletteUse
! FUNCTION: SetTextAlign
! FUNCTION: SetTextCharacterExtra
! FUNCTION: SetTextColor
! FUNCTION: SetTextJustification
! FUNCTION: SetViewportExtEx
! FUNCTION: SetViewportOrgEx
! FUNCTION: SetVirtualResolution
! FUNCTION: SetWindowExtEx
! FUNCTION: SetWindowOrgEx
! FUNCTION: SetWinMetaFileBits
! FUNCTION: SetWorldTransform
! FUNCTION: StartDocA
! FUNCTION: StartDocW
! FUNCTION: StartFormPage
! FUNCTION: StartPage
! FUNCTION: StretchBlt
! FUNCTION: StretchDIBits
! FUNCTION: STROBJ_bEnum
! FUNCTION: STROBJ_bEnumPositionsOnly
! FUNCTION: STROBJ_bGetAdvanceWidths
! FUNCTION: STROBJ_dwGetCodePage
! FUNCTION: STROBJ_vEnumStart
! FUNCTION: StrokeAndFillPath
! FUNCTION: StrokePath
FUNCTION: BOOL SwapBuffers ( HDC hDC ) ;
! FUNCTION: TextOutA
! FUNCTION: TextOutW
! FUNCTION: TranslateCharsetInfo
! FUNCTION: UnloadNetworkFonts
! FUNCTION: UnrealizeObject
! FUNCTION: UpdateColors
! FUNCTION: UpdateICMRegKeyA
! FUNCTION: UpdateICMRegKeyW
! FUNCTION: WidenPath
! FUNCTION: XFORMOBJ_bApplyXform
! FUNCTION: XFORMOBJ_iGetXform
! FUNCTION: XLATEOBJ_cGetPalette
! FUNCTION: XLATEOBJ_hGetColorTransform
! FUNCTION: XLATEOBJ_iXlate
! FUNCTION: XLATEOBJ_piVector
