USING: compiler.cfg.instructions compiler.cfg.rpo
compiler.cfg.stack-frame compiler.cfg.stacks.local compiler.tree
cpu.x86.assembler.operands help.markup help.syntax kernel math
namespaces sequences vectors words ;
IN: compiler.cfg

HELP: basic-block
{ $class-description
  "Factors representation of a basic block in the Call Flow Graph (CFG). A basic block is a sequence of instructions that always are executed sequentially and doesn't contain any internal branching. It has the following slots:"
  { $table
    {
        { $slot "number" }
        { "The blocks sequence number. Generated by calling " { $link number-blocks } "." }
    }
    {
        { $slot "successors" }
        { "A " { $link vector } " of basic blocks that may be executed directly after this block. Most blocks only have one successor but a block that checks where an if-condition should branch to would have two for example." }
    }
    {
        { $slot "predecessors" }
        { "The opposite of successors -- a " { $link vector } " of basic blocks from which the execution may have arrived into this block." }
    }
    {
        { $slot "instructions" }
        { "A " { $link vector } " of " { $link insn } " tuples which form the instructions of the basic block." }
    }
    {
        { $slot "kill-block?" }
        { "The first and the last block in a cfg and all blocks containing " { $link call## } " instructions are kill blocks. Kill blocks can't be optimized so they are omitted from certain optimization steps." }
    }
    {
        { $slot "height" }
        "Block's height as a " { $link height-state } ". What the heights of the block was at entry and how much they were increased in the block."
    }
    {
        { $slot "replaces" }
        { "Used by " { $vocab-link "compiler.cfg.stacks.local" } " for local stack analysis." }
    }
    {
        { $slot "peeks" }
        { "Used by " { $vocab-link "compiler.cfg.stacks.local" } " for local stack analysis." }
    }
    {
        { $slot "kills" }
        { "Used by " { $vocab-link "compiler.cfg.stacks.local" } " for local stack analysis." }
    }
  }
}
{ $notes "A basic-block is an " { $link identity-tuple } " because it is used as a hash table key by the compiler." } ;

HELP: <basic-block>
{ $values { "bb" basic-block } }
{ $description "Creates a new empty basic block. The " { $slot "id" } " slot is initialized with the value of the basic-block " { $link counter } "." } ;

HELP: <cfg>
{ $values { "word" word } { "label" "label" } { "entry" basic-block } { "cfg" cfg } }
{ $description "Constructor for " { $link cfg } ". " { $slot "spill-area-size" } " and " { $slot "spill-area-align" } " are set to default values." } ;


HELP: cfg
{ $class-description
  "Call flow graph. It has the following slots:"
  { $table
    { { $slot "entry" } { "Root " { $link basic-block } " of the graph." } }
    { { $slot "word" } { "The " { $link word } " the cfg is produced from." } }
    { { $slot "post-order" } { "The blocks of the cfg in a post order traversal " { $link sequence } "." } }
    { { $slot "stack-frame" } { { $link stack-frame } " of the cfg." } }
    { { $slot "frame-pointer?" } { "Whether the cfg needs a frame pointer. Only cfgs generated for " { $link alien-callback# } " nodes does need it. If the slot is " { $link t } ", then the frame pointer register (" { $link RBP } " on x86.64 archs) will not be clobbered by register allocation. See " { $vocab-link "compiler.cfg.linear-scan" } " for details." } }
  }
}
{ $see-also <cfg> post-order } ;

HELP: cfg-changed
{ $values { "cfg" cfg } }
{ $description "Resets all \"calculated\" slots in the cfg which forces them to be recalculated." }
{ $see-also predecessors-changed } ;

HELP: spill-offset
{ $values { "n" integer } { "offset" integer } }
{ $description "Offset in the current " { $link stack-frame } " to byte at index 'n' in the spill area." } ;

ARTICLE: "compiler.cfg" "Control Flow Graph IR"
"The compiler.cfg vocab and subvocabs implements the part of the optimizing compiler that analyzes code in the CFG format. The vocab " { $vocab-link "compiler.cfg.builder" } " defines words for building the CFG from SSA IR and the rest of the vocabs in the hierarchy optimization steps that are then applied to it. The graph is then passed to the " { $vocab-link "compiler.codegen" } " vocab which emits machine code."
$nl
"The main datatype in the vocab is the " { $link cfg } " tuple. It represents the CFG of a Factor word. The cfg tuple has a slot 'entry' pointing to a " { $link basic-block } ". This block in turn points to other basic blocks, and together they form the call flow graph of the word." ;

ABOUT: "compiler.cfg"
