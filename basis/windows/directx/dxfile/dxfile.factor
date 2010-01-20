USING: alien.syntax classes.struct windows.com
windows.com.syntax windows.kernel32 windows.ole32 windows.types ;
IN: windows.directx.dxfile

LIBRARY: d3dxof

TYPEDEF: DWORD DXFILEFORMAT

CONSTANT: DXFILEFORMAT_BINARY     0
CONSTANT: DXFILEFORMAT_TEXT       1
CONSTANT: DXFILEFORMAT_COMPRESSED 2

TYPEDEF: DWORD DXFILELOADOPTIONS

CONSTANT: DXFILELOAD_FROMFILE     0
CONSTANT: DXFILELOAD_FROMRESOURCE 1
CONSTANT: DXFILELOAD_FROMMEMORY   2
CONSTANT: DXFILELOAD_FROMSTREAM   4
CONSTANT: DXFILELOAD_FROMURL      8

STRUCT: DXFILELOADRESOURCE
    { hModule HMODULE }
    { lpName  LPCTSTR }
    { lpType  LPCTSTR } ;
TYPEDEF: DXFILELOADRESOURCE* LPDXFILELOADRESOURCE

STRUCT: DXFILELOADMEMORY
    { lpMemory LPVOID }
    { dSize    DWORD  } ;
TYPEDEF: DXFILELOADMEMORY* LPDXFILELOADMEMORY

C-TYPE: IDirectXFile
TYPEDEF: IDirectXFile* LPDIRECTXFILE
TYPEDEF: IDirectXFile** LPLPDIRECTXFILE
C-TYPE: IDirectXFileEnumObject
TYPEDEF: IDirectXFileEnumObject* LPDIRECTXFILEENUMOBJECT
TYPEDEF: IDirectXFileEnumObject** LPLPDIRECTXFILEENUMOBJECT
C-TYPE: IDirectXFileSaveObject
TYPEDEF: IDirectXFileSaveObject* LPDIRECTXFILESAVEOBJECT
TYPEDEF: IDirectXFileSaveObject** LPLPDIRECTXFILESAVEOBJECT
C-TYPE: IDirectXFileObject
TYPEDEF: IDirectXFileObject* LPDIRECTXFILEOBJECT
TYPEDEF: IDirectXFileObject** LPLPDIRECTXFILEOBJECT
C-TYPE: IDirectXFileData
TYPEDEF: IDirectXFileData* LPDIRECTXFILEDATA
TYPEDEF: IDirectXFileData** LPLPDIRECTXFILEDATA
C-TYPE: IDirectXFileDataReference
TYPEDEF: IDirectXFileDataReference* LPDIRECTXFILEDATAREFERENCE
TYPEDEF: IDirectXFileDataReference** LPLPDIRECTXFILEDATAREFERENCE
C-TYPE: IDirectXFileBinary
TYPEDEF: IDirectXFileBinary* LPDIRECTXFILEBINARY
TYPEDEF: IDirectXFileBinary** LPLPDIRECTXFILEBINARY

FUNCTION: HRESULT DirectXFileCreate ( LPDIRECTXFILE* lplpDirectXFile ) ;

COM-INTERFACE: IDirectXFile IUnknown {3d82ab40-62da-11cf-ab39-0020af71e433}
    HRESULT CreateEnumObject ( LPVOID v, DXFILELOADOPTIONS y,
                               LPDIRECTXFILEENUMOBJECT* z )
    HRESULT CreateSaveObject ( LPCSTR v, DXFILEFORMAT y,
                                 LPDIRECTXFILESAVEOBJECT* z )
    HRESULT RegisterTemplates ( LPVOID x, DWORD y ) ;

COM-INTERFACE: IDirectXFileEnumObject IUnknown {3d82ab41-62da-11cf-ab39-0020af71e433}
    HRESULT GetNextDataObject ( LPDIRECTXFILEDATA* x )
    HRESULT GetDataObjectById ( REFGUID x, LPDIRECTXFILEDATA* y )
    HRESULT GetDataObjectByName ( LPCSTR x, LPDIRECTXFILEDATA* y ) ;

COM-INTERFACE: IDirectXFileSaveObject IUnknown {3d82ab42-62da-11cf-ab39-0020af71e433}
    HRESULT SaveTemplates ( DWORD x, GUID** y )
    HRESULT CreateDataObject ( REFGUID x, LPCSTR y, GUID* z,
                               DWORD a, LPVOID b, LPDIRECTXFILEDATA* c )
    HRESULT SaveData ( LPDIRECTXFILEDATA x ) ;

COM-INTERFACE: IDirectXFileObject IUnknown {3d82ab43-62da-11cf-ab39-0020af71e433}
    HRESULT GetName ( LPSTR x, LPDWORD y )
    HRESULT GetId ( LPGUID y ) ;

COM-INTERFACE: IDirectXFileData IDirectXFileObject {3d82ab44-62da-11cf-ab39-0020af71e433}
    HRESULT GetData          ( LPCSTR x, DWORD* y, void** z )
    HRESULT GetType          ( GUID** x )
    HRESULT GetNextObject    ( LPDIRECTXFILEOBJECT* x )
    HRESULT AddDataObject    ( LPDIRECTXFILEDATA y )
    HRESULT AddDataReference ( LPCSTR x, GUID* y )
    HRESULT AddBinaryObject  ( LPCSTR x, GUID* y, LPCSTR z, LPVOID a, DWORD b ) ;

COM-INTERFACE: IDirectXFileDataReference IDirectXFileObject {3d82ab45-62da-11cf-ab39-0020af71e433}
    HRESULT Resolve ( LPDIRECTXFILEDATA* x ) ;

COM-INTERFACE: IDirectXFileBinary IDirectXFileObject {3d82ab46-62da-11cf-ab39-0020af71e433}
    HRESULT GetSize      ( DWORD* x )
    HRESULT GetMimeType  ( LPCSTR* x )
    HRESULT Read         ( LPVOID x, DWORD y, LPDWORD z ) ;

CONSTANT: DXFILE_OK   0
                               
CONSTANT: DXFILEERR_BADOBJECT                 HEX: 88760352
CONSTANT: DXFILEERR_BADVALUE                  HEX: 88760353
CONSTANT: DXFILEERR_BADTYPE                   HEX: 88760354
CONSTANT: DXFILEERR_BADSTREAMHANDLE           HEX: 88760355
CONSTANT: DXFILEERR_BADALLOC                  HEX: 88760356
CONSTANT: DXFILEERR_NOTFOUND                  HEX: 88760357
CONSTANT: DXFILEERR_NOTDONEYET                HEX: 88760358
CONSTANT: DXFILEERR_FILENOTFOUND              HEX: 88760359
CONSTANT: DXFILEERR_RESOURCENOTFOUND          HEX: 8876035A
CONSTANT: DXFILEERR_URLNOTFOUND               HEX: 8876035B
CONSTANT: DXFILEERR_BADRESOURCE               HEX: 8876035C
CONSTANT: DXFILEERR_BADFILETYPE               HEX: 8876035D
CONSTANT: DXFILEERR_BADFILEVERSION            HEX: 8876035E
CONSTANT: DXFILEERR_BADFILEFLOATSIZE          HEX: 8876035F
CONSTANT: DXFILEERR_BADFILECOMPRESSIONTYPE    HEX: 88760360
CONSTANT: DXFILEERR_BADFILE                   HEX: 88760361
CONSTANT: DXFILEERR_PARSEERROR                HEX: 88760362
CONSTANT: DXFILEERR_NOTEMPLATE                HEX: 88760363
CONSTANT: DXFILEERR_BADARRAYSIZE              HEX: 88760364
CONSTANT: DXFILEERR_BADDATAREFERENCE          HEX: 88760365
CONSTANT: DXFILEERR_INTERNALERROR             HEX: 88760366
CONSTANT: DXFILEERR_NOMOREOBJECTS             HEX: 88760367
CONSTANT: DXFILEERR_BADINTRINSICS             HEX: 88760368
CONSTANT: DXFILEERR_NOMORESTREAMHANDLES       HEX: 88760369
CONSTANT: DXFILEERR_NOMOREDATA                HEX: 8876036A
CONSTANT: DXFILEERR_BADCACHEFILE              HEX: 8876036B
CONSTANT: DXFILEERR_NOINTERNET                HEX: 8876036C
