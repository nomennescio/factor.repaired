! Copyright (C) 2013 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.syntax assocs
classes.struct combinators continuations destructors
io.encodings.string io.encodings.utf8 kernel libc locals make
math namespaces prettyprint sequences strings yaml.ffi ;
IN: yaml

: yaml-assert-ok ( n -- ) 0 = [ "yaml error" throw ] when ;
: event>scalar ( event -- obj ) data>> scalar>> [ value>> ] [ length>> ] bi memory>byte-array utf8 decode ;
: ?scalar-value ( event -- scalar/f f/type )
  dup type>> YAML_SCALAR_EVENT = [ event>scalar f ] [ type>> clone f swap ] if ;

! Must not reuse the event struct before with-destructors scope ends
: next-event ( parser event -- event )
    [ yaml_parser_parse yaml-assert-ok ] [ &yaml_event_delete ] bi ;

DEFER: parse-sequence
DEFER: parse-mapping
: next-complex-value ( parser event type -- obj )
  {
    { YAML_SEQUENCE_START_EVENT [ parse-sequence ] }
    { YAML_MAPPING_START_EVENT [ parse-mapping ] }
    [ throw ]
  } case ;
:: next-value ( parser event -- obj )
  parser event [ next-event ?scalar-value ] with-destructors
  [ [ drop parser event ] dip next-complex-value ] when* ;

:: parse-mapping ( parser event -- map ) [
  f :> done!
  [ done ] [ [
    parser event next-event type>>
    YAML_MAPPING_END_EVENT = [
      t done! f f
    ] [
      event event>scalar t
    ] if
  ] with-destructors [ parser event next-value swap ,, ] [ drop ] if ] until
] H{ } make ;
:: parse-sequence ( parser event -- seq ) [
  f :> done!
  [ done ] [ [
    parser event next-event type>>
    YAML_SEQUENCE_END_EVENT = [
      t done! f
    ] [
      event ?scalar-value dup [ nip ] [ [ , ] dip ] if
    ] if
  ] with-destructors [ [ parser event ] dip next-complex-value , ] when* ] until
] { } make ;

: expect-event ( parser event type -- )
[
  [ next-event type>> ] dip =
  [ "wrong event" throw ] unless
] with-destructors ;


:: yaml> ( str -- obj )
[
yaml_parser_t (malloc-struct) &free :> parser
parser yaml_parser_initialize yaml-assert-ok
parser &yaml_parser_delete drop

str utf8 encode [ malloc-byte-array &free ] [ length ] bi :> ( input length )
parser input length yaml_parser_set_input_string

yaml_event_t (malloc-struct) &free :> event

parser event YAML_STREAM_START_EVENT expect-event
parser event YAML_DOCUMENT_START_EVENT expect-event

parser event next-value

parser event YAML_DOCUMENT_END_EVENT expect-event
parser event YAML_STREAM_END_EVENT expect-event

] with-destructors

;

! TODO We can also pass some data when registering the write handler,
! use this to have several buffers if it can be interrupted.
! For now, only do operations on strings that are in memory
! so we don't need to be reentrant.
SYMBOL: yaml-write-buffer
: yaml-write-handler ( -- alien )
  [
    memory>byte-array yaml-write-buffer get-global
    push-all drop 1
  ] yaml_write_handler_t ;

GENERIC: emit-value ( emitter event obj -- )
M:: string emit-value ( emitter event string -- )
[
  string utf8 encode [ malloc-byte-array &free ] [ length ] bi :> ( value length )
  "tag:yaml.org,2002:str" utf8 malloc-string &free :> tag
  event f tag value length 0 0 0 yaml_scalar_event_initialize yaml-assert-ok
  emitter event yaml_emitter_emit yaml-assert-ok
] with-destructors ;
:: emit-sequence-start ( emitter event -- )
[
  "tag:yaml.org,2002:seq" utf8 malloc-string &free :> tag
  event f tag 0 0 yaml_sequence_start_event_initialize yaml-assert-ok
  emitter event yaml_emitter_emit yaml-assert-ok
] with-destructors ;
: emit-sequence-end ( emitter event -- )
  dup yaml_sequence_end_event_initialize yaml-assert-ok
  yaml_emitter_emit yaml-assert-ok ;

: emit-sequence ( emitter event seq -- )
  [ emit-value ] with with each ;

M: sequence emit-value ( emitter event seq -- )
  [ drop emit-sequence-start ] [ emit-sequence ] [ drop emit-sequence-end ] 3tri ;

:: emit-assoc-start ( emitter event -- )
[
  "tag:yaml.org,2002:map" utf8 malloc-string &free :> tag
  event f tag 0 0 yaml_mapping_start_event_initialize yaml-assert-ok
  emitter event yaml_emitter_emit yaml-assert-ok
] with-destructors ;
: emit-assoc-end ( emitter event -- )
  dup yaml_mapping_end_event_initialize yaml-assert-ok
  yaml_emitter_emit yaml-assert-ok ;

: emit-assoc ( emitter event assoc -- )
  [ [ emit-value ] with with bi@ ] with with assoc-each ;

M: assoc emit-value ( emitter event seq -- )
  [ drop emit-assoc-start ] [ emit-assoc ] [ drop emit-assoc-end ] 3tri ;

:: >yaml ( obj -- str )
[
yaml_emitter_t (malloc-struct) &free :> emitter
emitter yaml_emitter_initialize yaml-assert-ok
emitter &yaml_emitter_delete drop

BV{ } clone :> output
output yaml-write-buffer set-global
emitter yaml-write-handler f yaml_emitter_set_output

yaml_event_t (malloc-struct) &free :> event

event YAML_UTF8_ENCODING yaml_stream_start_event_initialize yaml-assert-ok
emitter event yaml_emitter_emit yaml-assert-ok
event f f f 0 yaml_document_start_event_initialize yaml-assert-ok
emitter event yaml_emitter_emit yaml-assert-ok

emitter event obj emit-value

event 0 yaml_document_end_event_initialize yaml-assert-ok
emitter event yaml_emitter_emit yaml-assert-ok
event yaml_stream_end_event_initialize yaml-assert-ok
emitter event yaml_emitter_emit yaml-assert-ok

emitter yaml_emitter_flush yaml-assert-ok
yaml-write-buffer get utf8 decode

] with-destructors

;
