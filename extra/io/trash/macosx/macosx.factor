! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: alien.c-types alien.strings alien.syntax classes.struct
core-foundation io.encodings.utf8 io.trash kernel system ;

IN: io.trash.macosx

<PRIVATE

STRUCT: FSRef
    { hidden UInt8[80] } ;

TYPEDEF: SInt32 OSStatus

TYPEDEF: UInt32 OptionBits

CONSTANT: noErr 0

CONSTANT: kFSFileOperationDefaultOptions HEX: 00
CONSTANT: kFSFileOperationOverwrite HEX: 01
CONSTANT: kFSFileOperationSkipSourcePermissionErrors HEX: 02
CONSTANT: kFSFileOperationDoNotMoveAcrossVolumes HEX: 04
CONSTANT: kFSFileOperationSkipPreflight HEX: 08

CONSTANT: kFSPathMakeRefDefaultOptions HEX: 00
CONSTANT: kFSPathMakeRefDoNotFollowLeafSymlink HEX: 01

FUNCTION: OSStatus FSMoveObjectToTrashSync (
    FSRef* source,
    FSRef* target,
    OptionBits options
) ;

FUNCTION: char* GetMacOSStatusCommentString (
    OSStatus err
) ;

FUNCTION: OSStatus FSPathMakeRefWithOptions (
    UInt8* path,
    OptionBits options,
    FSRef* ref,
    Boolean* isDirectory
) ;

: check-err ( err -- )
    dup noErr = [ drop ] [
        GetMacOSStatusCommentString utf8 alien>string throw
    ] if ;

! FIXME: check isDirectory?

: <fs-ref> ( path -- fs-ref )
    utf8 string>alien
    kFSPathMakeRefDoNotFollowLeafSymlink
    FSRef <struct>
    [ f FSPathMakeRefWithOptions check-err ] keep ;

PRIVATE>

M: macosx send-to-trash ( path -- )
    <fs-ref> f kFSFileOperationDefaultOptions
    FSMoveObjectToTrashSync check-err ;


