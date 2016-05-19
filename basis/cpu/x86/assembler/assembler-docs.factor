USING: compiler.codegen.labels cpu.x86.assembler.private help.markup
help.syntax kernel math sequences ;
IN: cpu.x86.assembler

HELP: 1-operand
{ $values { "operand" "operand" } { "reg,rex.w,opcode" sequence } }
{ $description "Used for encoding some instructions with one operand." } ;

HELP: DEC
{ $values { "dst" "register" } }
{ $description "Emits a DEC instruction." } ;

HELP: INC
{ $values { "dst" "register" } }
{ $description "Emits an INC instruction." } ;

HELP: JE
{ $values { "dst" "destination address or " { $link label } } }
{ $description "Emits a conditional jump instruction to the given address relative to the current code offset." }
{ $examples
  { $unchecked-example
    "USING: cpu.x86.assembler make ;"
    "[ 0x0 JE ] B{ } make disassemble"
    "000000e9fcc71fe0: 0f8400000000  jz dword 0xe9fcc71fe6"
  }
} ;

HELP: MOV
{ $values { "dst" "destination" "src" "source" } }
{ $description "Moves a value from one place to another." } ;

HELP: (MOV-I)
{ $values { "dst" "destination" } { "src" "immediate value" } }
{ $description "MOV where 'src' is immediate. If dst is a 64-bit register and the 'src' value fits in 32 bits, then zero extension is taken advantage of by downgrading 'dst' to a 32-bit register. That way, the instruction gets a shorter encoding." } ;

HELP: zero-extendable?
{ $values { "imm" integer } { "?" boolean } }
{ $description "All positive 32-bit numbers are zero extendable except for 0 which is the value used for relocations." } ;

ARTICLE: "cpu.x86.assembler" "X86 assembler"
"This vocab implements an assembler for x86 architectures."
$nl
"Instructions:"
{ $subsections MOV } ;

ABOUT: "cpu.x86.assembler"
