USING: generic generic.single generic.standard help.markup help.syntax sequences math
math.parser effects ;
IN: generic.hook

HELP: hook-combination
{ $class-description
    "Performs hook method combination . See " { $link postpone: \HOOK: } "."
} ;

{ standard-combination hook-combination } related-words
