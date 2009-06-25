USING: accessors assocs arrays fry kernel make math.parser models
models.product namespaces sequences ui.frp.gadgets parser lexer
ui.gadgets ui.gadgets.books ui.gadgets.tracks vectors words
combinators ui.frp.signals monads sequences.extras ui.tools.inspector ;
QUALIFIED: make
IN: ui.frp.layout

TUPLE: layout gadget size ; C: <layout> layout
TUPLE: placeholder < gadget members ;
: <placeholder> ( -- placeholder ) placeholder new V{ } clone >>members ;

: (remove-members) ( placeholder members -- ) [ [ model? ] filter swap parent>> model>> [ remove-connection ] curry each ]
    [ nip [ gadget? ] filter [ unparent ] each ] 2bi ;

: remove-members ( placeholder -- ) dup members>> [ drop ] [ [ (remove-members) ] keep empty ] if-empty ;
: add-member ( obj placeholder -- ) over layout? [ [ gadget>> ] dip ] when members>> push ;

: , ( item -- ) make:, ;
: make* ( quot -- list ) { } make ; inline

DEFER: with-interface
: insertion-quot ( quot -- quot' ) <placeholder> dup , swap '[ [ _ , @ ] with-interface ] ;

SYNTAX: ,% scan string>number [ <layout> , ] curry over push-all ;
SYNTAX: ->% scan string>number '[ [ _ <layout> , ] [ output-model ] bi ] over push-all ;

GENERIC: -> ( uiitem -- model )
M: gadget -> dup , output-model ;
M: model -> dup , ;

: <spacer> ( -- ) <gadget> 1 <layout> , ;

: add-layout ( track layout -- track ) [ gadget>> ] [ size>> ] bi track-add ; inline
: layouts ( sized? gadgets -- layouts ) [ [ gadget? ] [ layout? ] bi or ] filter swap
   [ [ dup layout? [ f <layout> ] unless ] map ]
   [ [ dup gadget? [ gadget>> ] unless ] map ] if ;
: make-layout ( building sized? -- models layouts ) [ swap layouts ] curry
   [ make* [ [ model? ] filter ] ] dip bi ; inline
: <box> ( gadgets type -- track )
   [ t make-layout ] dip <track>
   swap [ add-layout ] each
   swap [ <product> >>model ] unless-empty ; inline
: <hbox> ( gadgets -- track ) horizontal <box> ; inline
: <vbox> ( gadgets -- track ) vertical <box> ; inline

: make-book ( models gadgets model -- book ) <book> swap [ "No models in books" throw ] unless-empty ;
: <frp-book> ( quot: ( -- model ) -- book ) f make-layout rot 0 >>value make-book ; inline
: <frp-book*> ( quot -- book ) f make-layout f make-book ; inline

SYNTAX: $ CREATE-WORD <placeholder>
    [ [ , ] curry (( -- )) define-declared "$" expect ]
    [ [ , ] curry ] bi over push-all ;

: insert-gadget ( number parent gadget -- ) -rot [ but-last insert-nth ] change-children drop ;
: insert-size ( number parent size -- ) -rot [ but-last insert-nth ] change-sizes drop ;
: insertion-point ( gadget placeholder -- number parent gadget ) dup parent>> [ children>> index ] keep rot ;

GENERIC# (insert-item) 1 ( item location -- )
M: gadget (insert-item) dup parent>> track? [ [ f <layout> ] dip (insert-item) ]
    [ insertion-point [ add-gadget ] keep insert-gadget ] if ;
M: layout (insert-item) insertion-point [ add-layout ] keep [ gadget>> insert-gadget ] [ size>> insert-size ] 3bi ;
M: model (insert-item) parent>> dup book? [ "No models in books" throw ]
   [ dup model>> dup product? [ nip swap add-connection ] [ drop [ 1array <product> ] dip (>>model) ] if ] if ;
: insert-item ( item location -- ) [ add-member ] 2keep (insert-item) ;

: insert-items ( makelist -- ) t swap [ dup placeholder?
    [ nip [ dup get [ drop ] [ remove-members ] if ] [ on ] [ ] tri ]
    [ over insert-item ] if ] each drop ;

: with-interface ( quot -- ) make* [ insert-items ] with-scope ; inline

M: model >>= [ swap insertion-quot <action> ] curry ;