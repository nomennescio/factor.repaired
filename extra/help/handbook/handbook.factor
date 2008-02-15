USING: help help.markup help.syntax help.topics
namespaces words sequences classes assocs vocabs kernel
arrays prettyprint.backend kernel.private io tools.browser
generic math tools.profiler system ui strings sbufs vectors
byte-arrays bit-arrays float-arrays quotations help.lint ;
IN: help.handbook

ARTICLE: "conventions" "Conventions"
"Various conventions are used throughout the Factor documentation and source code."
{ $heading "Documentation conventions" }
"Factor documentation consists of two distinct bodies of text. There is a hierarchy of articles, much like this one, and there is word documentation. Help articles reference word documentation, and vice versa, but not every documented word is referenced from some help article."
$nl
"Every article has links to parent articles at the top. These can be persued if the article is too specific."
$nl
"Some generic words have " { $strong "Description" } " headings, and others have " { $strong "Contract" } " headings. A distinction is made between words which are not intended to be extended with user-defined methods, and those that are."
{ $heading "Vocabulary naming conventions" }
"A vocabulary name ending in " { $snippet ".private" } " contains words which are either implementation detail, unsafe, or both. For example, the " { $snippet "sequence.private" } " vocabulary contains words which access sequence elements without bounds checking (" { $link "sequences-unsafe" } ")."
$nl
"You should should avoid using internal words from the Factor library unless absolutely necessary. Similarly, your own code can place words in internal vocabularies if you do not want other people to use them unless they have a good reason."
{ $heading "Word naming conventions" }
"These conventions are not hard and fast, but are usually a good first step in understanding a word's behavior:"
{ $table
    { "General form" "Description" "Examples" }
    { { $snippet { $emphasis "foo" } "?" } "outputs a boolean" { { $link empty? } } }
    { { $snippet "?" { $emphasis "foo" } } { "conditionally performs " { $snippet { $emphasis "foo" } } } { { $links ?nth } } }
    { { $snippet "<" { $emphasis "foo" } ">" } { "creates a new " { $snippet "foo" } } { { $link <array> } } }
    { { $snippet { $emphasis "foo" } "*" } { "alternative form of " { $snippet "foo" } ", or a generic word called by " { $snippet "foo" } } { { $links at* pprint* } } }
    { { $snippet "(" { $emphasis "foo" } ")" } { "implementation detail word used by " { $snippet "foo" } } { { $link (clone) } } }
    { { $snippet "set-" { $emphasis "foo" } } { "sets " { $snippet "foo" } " to a new value" } { $links set-length } }
    { { $snippet { $emphasis "foo" } "-" { $emphasis "bar" } } { "(tuple accessors) outputs the value of the " { $snippet "bar" } " slot of the " { $snippet "foo" } " at the top of the stack" } { } }
    { { $snippet "set-" { $emphasis "foo" } "-" { $emphasis "bar" } } { "(tuple mutators) sets the value of the " { $snippet "bar" } " slot of the " { $snippet "foo" } " at the top of the stack" } { } }
    { { $snippet "with-" { $emphasis "foo" } } { "performs some kind of initialization and cleanup related to " { $snippet "foo" } ", usually in a new dynamic scope" } { $links with-scope with-stream } }
    { { $snippet "$" { $emphasis "foo" } } { "help markup" } { $links $heading $emphasis } }
}
{ $heading "Stack effect conventions" }
"Stack effect conventions are documented in " { $link "effect-declaration" } "."
{ $heading "Glossary of terms" }
"Common terminology and abbreviations used throughout Factor and its documentation:"
{ $table
    { "Term" "Definition" }
    { "alist" { "an association list. See " { $link "alists" } } }
    { "assoc" "an associative mapping" }
    { "associative mapping" { "an object whose class implements the " { $link "assocs-protocol" } } }
    { "boolean"               { { $link t } " or " { $link f } } }
    { "class"                 { "a set of objects identified by a " { $emphasis "class word" } " together with a discriminating predicate. See " { $link "classes" } } }
    { "definition specifier"  { "a " { $link word } ", " { $link method-spec } ", " { $link link } ", vocabulary specifier, or any other object whose class implements the " { $link "definition-protocol" } } }
    { "generalized boolean"   { "an object interpreted as a boolean; a value of " { $link f } " denotes false and anything else denotes true" } }
    { "generic word"          { "a word whose behavior depends can be specialized on the class of one of its inputs. See " { $link "generic" } } }
    { "method"                { "a specialized behavior of a generic word on a class. See " { $link "generic" } } }
    { "object"                { "any datum which can be identified" } }
    { "pathname string"       { "an OS-specific pathname which identifies a file" } }
    { "sequence" { "an object whose class implements the " { $link "sequence-protocol" } } }
    { "slot"                  { "a component of an object which can store a value" } }
    { "stack effect"          { "a pictorial representation of a word's inputs and outputs, for example " { $snippet "+ ( x y -- z )" } ". See " { $link "effects" } } }
    { "true value"            { "any object not equal to " { $link f } } }
    { "vocabulary" { "a named set of words. See " { $link "vocabularies" } } }
    { "vocabulary specifier"  { "a " { $link vocab } ", " { $link vocab-link } " or a string naming a vocabulary" } }
    { "word"                  { "the basic unit of code, analogous to a function or procedure in other programming languages. See " { $link "words" } } }
} ;

ARTICLE: "evaluator" "Evaluation semantics"
{ $link "quotations" } " are evaluated sequentially from beginning to end. When the end is reached, the quotation returns to its caller. As each object in the quotation is evaluated in turn, an action is taken based on its type:"
{ $list
    { "a " { $link word } " - the word's definition quotation is called. See " { $link "words" } }
    { "a " { $link wrapper } " - the wrapped object is pushed on the data stack. Wrappers are used to push word objects directly on the stack when they would otherwise execute. See the " { $link POSTPONE: \ } " parsing word." }
    { "All other types of objects are pushed on the data stack." }
}
"If the last action performed is the execution of a word, the current quotation is not saved on the call stack; this is known as " { $snippet "tail-recursion" } " and allows iterative algorithms to execute without incurring unbounded call stack usage."
$nl
"There are various ways of implementing these evaluation semantics. See " { $link "compiler" } " and " { $link "meta-interpreter" } "." ;

ARTICLE: "dataflow" "Data and control flow"
{ $subsection "evaluator" }
{ $subsection "words" }
{ $subsection "effects" }
{ $subsection "shuffle-words" }
{ $subsection "booleans" }
{ $subsection "conditionals" }
{ $subsection "basic-combinators" }
{ $subsection "combinators" }
{ $subsection "continuations" }
{ $subsection "threads" } ;

ARTICLE: "objects" "Objects"
"An " { $emphasis "object" } " is any datum which may be identified. All values are objects in Factor. Each object carries type information, and types are checked at runtime; Factor is dynamically typed."
{ $subsection "equality" }
{ $subsection "classes" }
{ $subsection "tuples" }
{ $subsection "generic" }
{ $subsection "mirrors" } ;

USE: random

ARTICLE: "numbers" "Numbers"
{ $subsection "arithmetic" }
{ $subsection "math-constants" }
{ $subsection "math-functions" }
{ $subsection "number-strings" }
{ $subsection "random-numbers" }
"Number implementations:"
{ $subsection "integers" }
{ $subsection "rationals" }
{ $subsection "floats" }
{ $subsection "complex-numbers" }
"Advanced features:"
{ $subsection "math-vectors" }
{ $subsection "math-intervals" }
{ $subsection "math-bitfields" } ;

USE: io.buffers

ARTICLE: "collections" "Collections" 
{ $heading "Sequences" }
{ $subsection "sequences" }
"Fixed-length sequences:"
{ $subsection "arrays" }
{ $subsection "quotations" }
"Fixed-length specialized sequences:"
{ $subsection "strings" }
{ $subsection "bit-arrays" }
{ $subsection "byte-arrays" }
{ $subsection "float-arrays" }
"Resizable sequence:"
{ $subsection "vectors" }
"Resizable specialized sequences:"
{ $subsection "sbufs" }
{ $subsection "bit-vectors" }
{ $subsection "byte-vectors" }
{ $subsection "float-vectors" }
{ $heading "Associative mappings" }
{ $subsection "assocs" }
{ $subsection "namespaces" }
"Implementations:"
{ $subsection "hashtables" }
{ $subsection "alists" }
{ $heading "Other collections" }
{ $subsection "dlists" }
{ $subsection "heaps" }
{ $subsection "graphs" }
{ $subsection "buffers" } ;

USING: io.sockets io.launcher io.mmap io.monitors ;

ARTICLE: "io" "Input and output" 
{ $subsection "streams" }
"External streams:"
{ $subsection "file-streams" }
{ $subsection "network-streams" }
"Wrapper streams:"
{ $subsection "io.streams.duplex" }
{ $subsection "io.streams.lines" }
{ $subsection "io.streams.plain" }
{ $subsection "io.streams.string" }
"Stream utilities:"
{ $subsection "stream-binary" }
{ $subsection "styles" }
"Advanced features:"
{ $subsection "io.launcher" }
{ $subsection "io.mmap" }
{ $subsection "io.monitors" }
{ $subsection "io.timeouts" } ;

ARTICLE: "tools" "Developer tools"
"Exploratory tools:"
{ $subsection "editor" }
{ $subsection "tools.crossref" }
{ $subsection "inspector" }
"Debugging tools:"
{ $subsection "tools.annotations" }
{ $subsection "tools.test" }
{ $subsection "meta-interpreter" }
"Performance tools:"
{ $subsection "tools.memory" }
{ $subsection "profiling" }
{ $subsection "timing" }
{ $subsection "tools.disassembler" }
"Deployment tools:"
{ $subsection "tools.deploy" } ;

ARTICLE: "article-index" "Article index"
{ $index [ articles get keys ] } ;

ARTICLE: "primitive-index" "Primitive index"
{ $index [ all-words [ primitive? ] subset ] } ;

ARTICLE: "error-index" "Error index"
{ $index [ all-errors ] } ;

ARTICLE: "type-index" "Type index"
{ $index [ builtins get [ ] subset ] } ;

ARTICLE: "class-index" "Class index"
{ $index [ classes ] } ;

ARTICLE: "program-org" "Program organization"
{ $subsection "definitions" }
{ $subsection "vocabularies" }
{ $subsection "parser" }
{ $subsection "vocabs.loader" } ;

USING: help.cookbook help.tutorial ;

ARTICLE: "handbook" "Factor documentation"
"Welcome to Factor. Factor is dynamically-typed, stack-based, and very expressive. It is one of the most powerful and flexible programming languages ever invented. Have fun with Factor!"
{ $heading "Starting points" }
{ $subsection "cookbook" }
{ $subsection "first-program" }
{ $subsection "vocab-index" }
{ $subsection "changes" }
{ $heading "Language reference" }
{ $subsection "conventions" }
{ $subsection "syntax" }
{ $subsection "dataflow" }
{ $subsection "objects" }
{ $subsection "program-org" }
{ $heading "Library reference" }
{ $subsection "numbers" }
{ $subsection "collections" }
{ $subsection "io" }
{ $subsection "os" }
{ $subsection "alien" }
{ $heading "Environment reference" }
{ $subsection "cli" }
{ $subsection "images" }
{ $subsection "prettyprint" }
{ $subsection "tools" }
{ $subsection "help" }
{ $subsection "inference" }
{ $subsection "compiler" }
{ $heading "User interface" }
{ $about "ui" }
{ $about "ui.tools" }
{ $heading "Index" }
{ $subsection "primitive-index" }
{ $subsection "error-index" }
{ $subsection "type-index" }
{ $subsection "class-index" } ;


USING: io.files io.sockets float-arrays inference ;

ARTICLE: "changes" "Changes in the latest release"
{ $heading "Factor 0.91" }
{ $subheading "Performance" }
{ $list
    { "Continuations are now supported by the static stack effect system. This means that the " { $link infer } " word and the optimizing compiler now both support code which uses continuations." }
    { "Many words which previously ran in the interpreter, such as error handling and I/O, are now compiled to optimized machine code." }
    { "A non-optimizing, just-in-time compiler replaces the interpreter with no loss in functionality or introspective ability." }
    { "The non-optimizing compiler compiles quotations the first time they are called, generating a series of stack pushes and subroutine calls. It offers a 33%-50% performance increase over the interpreter." }
    { "The optimizing compiler now performs some more representation inference. Alien pointers are unboxed where possible. This improves performance of the " { $vocab-link "ogg.player" } " Ogg Theora video player." }
    { "The queue of sleeping tasks is now a sorted priority queue. This reduces overhead for workloads involving large numbers of sleeping threads (Doug Coleman)" }
    { "Improved hash code algorithm for sequences" }
    { "New, efficient implementations of " { $link bit? } " and " { $link log2 } " runs in constant time for large bignums" }
    { "New " { $link big-random } " word for generating large random numbers quickly" }
    { "Improved profiler no longer has to be explicitly enabled and disabled with a full recompile; instead, the " { $link profile } " word can be used at any time, and it dynamically patches words to increment call counts. There is no overhead when the profiler is not in use." }
    { "Calls to " { $link member? } " with a literal sequence are now open-coded. If there are four or fewer elements, a series of conditionals are generated; if there are more than four elements, there is a hash dispatch followed by conditionals in each branch." }
}
{ $subheading "IO" }
{ $list
    { "More robust Windows CE native I/O" }
    { "New " { $link os-envs } " word to get the current set of environment variables" }
    { "Redesigned " { $vocab-link "io.launcher" } " supports passing environment variables to the child process" }
    { { $link <process-stream> } " implemented on Windows (Doug Coleman)" }
    { "Updated " { $vocab-link "io.mmap" } " for new module system, now supports Windows CE (Doug Coleman)" }
    { { $vocab-link "io.sniffer" } " - packet sniffer library (Doug Coleman, Elie Chaftari)" }
    { { $vocab-link "io.server" } " - improved logging support, logs to a file by default" }
    { { $vocab-link "io.files" } " - several new file system manipulation words added" }
    { { $vocab-link "tar" } " - tar file extraction in pure Factor (Doug Coleman)" }
    { { $vocab-link "unix.linux" } ", " { $vocab-link "raptor" } " - ``Raptor Linux'', a set of alien bindings to low-level Linux features, such as network interface configuration, file system mounting/unmounting, etc, together with experimental boot scripts intended to entirely replace " { $snippet "/sbin/init" } ", " { $snippet "/etc/inittab" } " and " { $snippet "/etc/init.d/" } " (Eduardo Cavazos)." }
}
{ $subheading "Tools" }
{ $list
    { "Graphical deploy tool added - see " { $link "ui.tools.deploy" } }
    { "The deploy tool now supports Windows" }
    { { $vocab-link "network-clipboard" } " - clipboard synchronization with a simple TCP/IP protocol" }
}
{ $subheading "UI" }
{ $list
    { { $vocab-link "cairo" } " - updated for new module system, new features (Sampo Vuori)" }
    { { $vocab-link "springies" } " - physics simulation UI demo (Eduardo Cavazos)" }
    { { $vocab-link "ui.gadgets.buttons" } " - added check box and radio button gadgets" }
    { "Double- and triple-click-drag now supported in the editor gadget to select words or lines at a time" }
    { "Windows can be closed on request now using " { $link close-window } }
    { "New icons (Elie Chaftari)" }
}
{ $subheading "Libraries" }
{ $list
    { "The " { $snippet "queues" } " vocabulary has been removed because its functionality is a subset of " { $vocab-link "dlists" } }
    { "The " { $vocab-link "webapps.cgi" } " vocabulary implements CGI support for the Factor HTTP server." }
    { "The optimizing compiler no longer depends on the number tower and it is possible to bootstrap a minimal image by just passing " { $snippet "-include=compiler" } " to stage 2 bootstrap." }
    { { $vocab-link "benchmark.knucleotide" } " - new benchmark (Eric Mertens)" }
    { { $vocab-link "channels" } " - concurrent message passing over message channels" }
    { { $vocab-link "destructors" } " - deterministic scope-based resource deallocation (Doug Coleman)" }
    { { $vocab-link "dlists" } " - various updates (Doug Coleman)" }
    { { $vocab-link "editors.emeditor" } " - EmEditor integration (Doug Coleman)" }
    { { $vocab-link "editors.editplus" } " - EditPlus integration (Aaron Schaefer)" }
    { { $vocab-link "editors.notepadpp" } " - Notepad++ integration (Doug Coleman)" }
    { { $vocab-link "editors.ted-notepad" } " - TED Notepad integration (Doug Coleman)" }
    { { $vocab-link "editors.ultraedit" } " - UltraEdit integration (Doug Coleman)" }
    { { $vocab-link "globs" } " - simple Unix shell-style glob patterns" }
    { { $vocab-link "heaps" } " - updated for new module system and cleaned up (Doug Coleman)" }
    { { $vocab-link "peg" } " - Parser Expression Grammars, a new appoach to parser construction, similar to parser combinators (Chris Double)" }
    { { $vocab-link "regexp" } " - revived from " { $snippet "unmaintained/" } " and completely redesigned (Doug Coleman)" }
    { { $vocab-link "rss" } " - add Atom feed generation (Daniel Ehrenberg)" }
    { { $vocab-link "tuples.lib" } " - some utility words for working with tuples (Doug Coleman)" }
    { { $vocab-link "webapps.pastebin" } " - improved appearance, add Atom feed generation, add syntax highlighting using " { $vocab-link "xmode" } }
    { { $vocab-link "webapps.planet" } " - add Atom feed generation" }
}
{ $heading "Factor 0.90" }
{ $subheading "Core" }
{ $list
    { "New module system; see " { $link "vocabs.loader" } ". (Eduardo Cavazos)" }
    { "Tuple constructors are defined differently now; see " { $link "tuple-constructors" } "." }
    { "Mixin classes implemented; these are essentially extensible unions. See " { $link "mixins" } "."  }
    { "New " { $link float-array } " data type implements a space-efficient sequence of floats." }
    { "Moved " { $link <file-appender> } ", " { $link delete-file } ", " { $link make-directory } ", " { $link delete-directory } " words from " { $snippet "libs/io" } " into the core, and fixed them to work on more platforms." }
    { "New " { $link host-name } " word." }
    { "The " { $link directory } " word now outputs an array of pairs, with the second element of each pair indicating if that entry is a subdirectory. This saves an unnecessary " { $link stat } " call when traversing directory hierarchies, which speeds things up." }
    { "IPv6 is now supported, along with Unix domain sockets (the latter on Unix systems only). The stack effects of " { $link <client> } " and " { $link <server> } " have changed, since they now take generic address specifiers; see " { $link "network-streams" } "." }
    { "The stage 2 bootstrap process is more flexible, and various subsystems such as help, tools and the UI can be omitted by supplying command line switches; see " { $link "bootstrap-cli-args" } "." }
    { "The " { $snippet "-shell" } " command line switch has been replaced by a " { $snippet "-run" } " command line switch; see " { $link "standard-cli-args" } "." }
    { "Variable usage inference has been removed; the " { $link infer } " word no longer reports this information." }

}
{ $subheading "Tools" }
{ $list
    { "Stand-alone image deployment; see " { $link "tools.deploy" } "." }
    { "Stand-alone application bundle deployment on Mac OS X; see " { $vocab-link "tools.deploy.app" } "." }
    { "New vocabulary browser tool in the UI." }
    { "New profiler tool in the UI." }
}
{ $subheading "Extras" }
"Most existing libraries were improved when ported to the new module system; the most notable changes include:"
{ $list
    { { $vocab-link "asn1" } ": ASN1 parser and writer. (Elie Chaftari)" }
    { { $vocab-link "benchmark" } ": new set of benchmarks." }
    { { $vocab-link "cfdg" } ": Context-free design grammar implementation; see " { $url "http://www.chriscoyne.com/cfdg/" } ". (Eduardo Cavazos)" }
    { { $vocab-link "cryptlib" } ": Cryptlib library binding. (Elie Chaftari)" }
    { { $vocab-link "cryptlib.streams" } ": Streams which perform SSL encryption and decryption. (Matthew Willis)" }
    { { $vocab-link "hints" } ": Give type specialization hints to the compiler." }
    { { $vocab-link "inverse" } ": Invertible computation and concatenative pattern matching. (Daniel Ehrenberg)" }
    { { $vocab-link "ldap" } ": OpenLDAP library binding. (Elie Chaftari)" }
    { { $vocab-link "locals" } ": Efficient lexically scoped locals, closures, and local words." }
    { { $vocab-link "mortar" } ": Experimental message-passing object system. (Eduardo Cavazos)" }
    { { $vocab-link "openssl" } ": OpenSSL library binding. (Elie Chaftari)" }
    { { $vocab-link "pack" } ": Utility for reading and writing binary data. (Doug Coleman)" }
    { { $vocab-link "pdf" } ": Haru PDF library binding. (Elie Chaftari)" }
    { { $vocab-link "qualified" } ": Refer to words from another vocabulary without adding the entire vocabulary to the search path. (Daniel Ehrenberg)" }
    { { $vocab-link "roman" } ": Reading and writing Roman numerals. (Doug Coleman)" }
    { { $vocab-link "scite" } ": SciTE editor integration. (Clemens Hofreither)" }
    { { $vocab-link "smtp" } ": SMTP client with support for CRAM-MD5 authentication. (Elie Chaftari, Dirk Vleugels)" }
    { { $vocab-link "tuple-arrays" } ": Space-efficient packed tuple arrays. (Daniel Ehrenberg)" }
    { { $vocab-link "unicode" } ": major new functionality added. (Daniel Ehrenberg)" }
}
{ $subheading "Performance" }
{ $list
    { "The " { $link curry } " word now runs in constant time, and curried quotations can be called from compiled code; this allows for abstractions and idioms which were previously impractical due to performance issues. In particular, words such as " { $snippet "each-with" } " and " { $snippet "map-with" } " are gone; " { $snippet "each-with" } " can now be written as " { $snippet "with each" } ", and similarly for other " { $snippet "-with" } " combinators." }
    "Improved generational promotion strategy in garbage collector reduces the amount of junk which makes its way into tenured space, which in turn reduces the frequency of full garbage collections."
    "Faster generic word dispatch and union membership testing."
    { "Alien memory accessors (" { $link "reading-writing-memory" } ") are compiled as intrinsics where possible, which improves performance in code which iteroperates with C libraries." }
}
{ $subheading "Platforms" }
{ $list
    "Networking support added for Windows CE. (Doug Coleman)"
    "UDP/IP networking support added for all Windows platforms. (Doug Coleman)"
    "Solaris/x86 fixes. (Samuel Tardieu)"
    "Linux/AMD64 port works again."
} ;

{ <array> <string> <sbuf> <vector> <byte-array> <bit-array> <float-array> }
related-words

{ >array >quotation >string >sbuf >vector >byte-array >bit-array >float-array }
related-words
