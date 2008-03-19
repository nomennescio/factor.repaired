! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax quotations kernel io math
calendar ;
IN: io.launcher

ARTICLE: "io.launcher.command" "Specifying a command"
"The " { $snippet "command" } " slot of a " { $link process } " can contain either a string or a sequence of strings. In the first case, the string is processed in an operating system-specific manner. In the second case, the first element is a program name and the remaining elements are passed to the program as command-line arguments." ;

ARTICLE: "io.launcher.detached" "Running processes in the background"
"By default, " { $link run-process } " waits for the process to complete. To run a process without waiting for it to finish, set the " { $snippet "detached" } " slot of a " { $link process } ", or use the following word:"
{ $subsection run-detached } ;

ARTICLE: "io.launcher.environment" "Setting environment variables"
"The " { $snippet "environment" } " slot of a " { $link process } " contains an association mapping environment variable names to values. The interpretation of environment variables is operating system-specific."
$nl
"The " { $snippet "environment-mode" } " slot controls how the environment of the current Factor instance is composed with the value of the " { $snippet "environment" } " slot:"
{ $subsection +prepend-environment+ }
{ $subsection +replace-environment+ }
{ $subsection +append-environment+ }
"The default value is " { $link +append-environment+ } "." ;

ARTICLE: "io.launcher.redirection" "Input/output redirection"
"On all operating systems except for Windows CE, the default input/output/error streams can be redirected."
$nl
"To specify redirection, set the " { $snippet "stdin" } ", " { $snippet "stdout" } " and " { $snippet "stderr" } " slots of a " { $link process } " to one of the following values:"
{ $list
    { { $link f } " - default value; the stream is either inherited from the current process, or is a " { $link <process-stream> } " pipe" }
    { { $link +inherit+ } " - the stream is inherited from the current process, overriding a " { $link <process-stream> } " pipe" }
    { { $link +closed+ } " - the stream is closed; reads will return end of file and writes will fails" }
    { { $link +stdout+ } " - a special value for the " { $snippet "stderr" } " slot only, indicating that the standard output and standard error streams should be merged" }
    { "a path name - the stream is sent to the given file, which must exist for input and is created automatically on output" }
    { "a file stream or a socket - the stream is connected to the given Factor stream, which cannot be used again from within Factor and must be closed after the process has been started" }
} ;

HELP: +closed+
{ $description "Possible value for the " { $snippet "stdin" } ", " { $snippet "stdout" } ", and " { $snippet "stderr" } " slots of a " { $link process } "." } ;

HELP: +inherit+
{ $description "Possible value for the " { $snippet "stdin" } ", " { $snippet "stdout" } ", and " { $snippet "stderr" } " slots of a " { $link process } "." } ;

HELP: +stdout+
{ $description "Possible value for the " { $snippet "stderr" } " slot of a " { $link process } "." } ;

HELP: +prepend-environment+
{ $description "Possible value of " { $snippet "environment-mode" } " slot of a " { $link process } "."
$nl
"If this value is set, the child process environment consists of the value of the " { $snippet "environment" } " slot together with the current environment, with entries from the current environment taking precedence."
$nl
"This is used in situations where you want to spawn a child process with some default environment variables set, but allowing the user to override these defaults by changing the environment before launching Factor." } ;

HELP: +replace-environment+
{ $description "Possible value of " { $snippet "environment-mode" } " slot of a " { $link process } "."
$nl
"The child process environment consists of the value of the " { $snippet "environment" } " slot."
$nl
"This is used in situations where you want full control over a child process environment, perhaps for security or testing." } ;

HELP: +append-environment+
{ $description "Possible value of " { $snippet "environment-mode" } " slot of a " { $link process } "."
$nl
"The child process environment consists of the current environment together with the value of the " { $snippet "environment" } " key, with entries from the " { $snippet "environment" } " key taking precedence."
$nl
"This is used in situations where you want a spawn child process with some overridden environment variables." } ;

ARTICLE: "io.launcher.timeouts" "Process run-time timeouts"
"The " { $snippet "timeout" } " slot of a " { $link process } " can be set to a " { $link duration } " specifying a maximum running time for the process. If " { $link wait-for-process } " is called and the process does not exit before the duration expires, it will be killed." ;

HELP: get-environment
{ $values { "process" process } { "env" "an association" } }
{ $description "Combines the current environment with the value of the " { $snippet "environment" } " slot of the " { $link process } " using the " { $snippet "environment-mode" } " slot." } ;

HELP: current-process-handle
{ $values { "handle" "a process handle" } }
{ $description "Returns the handle of the current process." } ;

HELP: run-process*
{ $values { "process" process } { "handle" "a process handle" } }
{ $contract "Launches a process." }
{ $notes "User code should call " { $link run-process } " instead." } ;

HELP: run-process
{ $values { "desc" "a launch descriptor" } { "process" process } }
{ $description "Launches a process. The object can either be a string, a sequence of strings or a " { $link process } ". See " { $link "io.launcher.descriptors" } " for details." }
{ $notes "The output value can be passed to " { $link wait-for-process } " to get an exit code." } ;

HELP: run-detached
{ $values { "desc" "a launch descriptor" } { "process" process } }
{ $contract "Launches a process without waiting for it to complete. The object can either be a string, a sequence of strings or a " { $link process } ". See " { $link "io.launcher.descriptors" } " for details." }
{ $notes
    "This word is functionally identical to passing a " { $link process } " to " { $link run-process } " having the " { $snippet "detached" } " slot set."
    $nl
    "The output value can be passed to " { $link wait-for-process } " to get an exit code."
} ;

HELP: process-failed
{ $values { "code" "an exit status" } }
{ $description "Throws a " { $link process-failed } " error." }
{ $error-description "Thrown by " { $link try-process } " if the process exited with a non-zero status code." } ;

HELP: try-process
{ $values { "desc" "a launch descriptor" } }
{ $description "Launches a process and waits for it to complete. If it exits with a non-zero status code, throws a " { $link process-failed } " error." } ;

HELP: kill-process
{ $values { "process" process } }
{ $description "Kills a running process. Does nothing if the process has already exited." } ;

HELP: kill-process*
{ $values { "handle" "a process handle" } }
{ $contract "Kills a running process." }
{ $notes "User code should call " { $link kill-process } " intead." } ;

HELP: process
{ $class-description "A class representing a process. Instances are created by calling " { $link <process> } "." } ;

HELP: <process>
{ $values { "process" process } }
{ $description "Creates a new, empty process. It must be filled in before being passed to " { $link run-process } "." } ;

HELP: process-stream
{ $class-description "A bidirectional stream for interacting with a running process. Instances are created by calling " { $link <process-stream> } ". The " { $link process-stream-process } " slot holds a " { $link process } " instance." } ;

HELP: <process-stream>
{ $values
  { "desc" "a launch descriptor" }
  { "encoding" "an encoding descriptor" }
  { "stream" "a bidirectional stream" } }
{ $description "Launches a process and redirects its input and output via a pair of pipes which may be read and written as a stream of the given encoding." } ;

HELP: with-process-stream
{ $values
  { "desc" "a launch descriptor" }
  { "quot" quotation }
  { "status" "an exit code" } }
{ $description "Calls " { $snippet "quot" } " in a dynamic scope where " { $link stdio } " is rebound to a " { $link process-stream } ". After the quotation returns, waits for the process to end and outputs the exit code." } ;

HELP: wait-for-process
{ $values { "process" process } { "status" integer } }
{ $description "If the process is still running, waits for it to exit, otherwise outputs the exit code immediately. Can be called multiple times on the same process." } ;

ARTICLE: "io.launcher.descriptors" "Launch descriptors"
"Words which launch processes can take either a command line string, a sequence of command line arguments, or a " { $link process } "."
$nl
"Strings and string arrays are wrapped in a new empty " { $link process } " with the " { $snippet "command" } " slot set. This covers basic use-cases where no launch parameters need to be set."
$nl
"A " { $link process } " instance can be created directly and passed to launching words for more control. It must be a fresh instance which has never been spawned before. To spawn a process several times from the same descriptor, " { $link clone } " the descriptor first." ;

ARTICLE: "io.launcher.lifecycle" "The process lifecycle"
"A freshly instantiated " { $link process } " represents a set of launch parameters."
{ $subsection process }
{ $subsection <process> }
"Words for launching processes take a fresh process which has never been started before as input, and output a copy as output."
{ $subsection process-started? }
"The " { $link process } " instance output by launching words contains all original slot values in addition to the " { $snippet "handle" } " slot, which indicates the process is currently running."
{ $subsection process-running? }
"It is possible to wait for a process to exit:"
{ $subsection wait-for-process }
"A running process can also be killed:"
{ $subsection kill-process } ;

ARTICLE: "io.launcher.launch" "Launching processes"
"Launching processes:"
{ $subsection run-process }
{ $subsection try-process }
"Redirecting standard input and output to a pipe:"
{ $subsection <process-stream> }
{ $subsection with-process-stream } ;

ARTICLE: "io.launcher.examples" "Launcher examples"
"Starting a command and waiting for it to finish:"
{ $code
    "\"ls /etc\" run-process"
}
"Starting a program in the background:"
{ $code
    "{ \"emacs\" \"foo.txt\" } run-detached"
}
"Running a command, throwing an exception if it exits unsuccessfully:"
{ $code
    "\"make clean all\" try-process"
}
"Running a command, throwing an exception if it exits unsuccessfully or if it takes too long to run:"
{ $code
    "<process>"
    "    \"make test\" >>command"
    "    5 minutes >>timeout"
    "try-process"
}
"Running a command, throwing an exception if it exits unsuccessfully, and redirecting output and error messages to a log file:"
{ $code
    "<process>"
    "    \"make clean all\" >>command"
    "    \"log.txt\" >>stdout"
    "    +stdout+ >>stderr"
    "try-process"
}
"Running a command, appending error messages to a log file, and reading the output for further processing:"
{ $code
    "\"log.txt\" <file-appender> ["
    "    <process>"
    "        swap >>stderr"
    "        \"report\" >>command"
    "    ascii <process-stream> lines sort reverse [ print ] each"
    "] with-disposal"
} ;

ARTICLE: "io.launcher" "Operating system processes"
"The " { $vocab-link "io.launcher" } " vocabulary implements cross-platform process launching."
{ $subsection "io.launcher.examples" }
{ $subsection "io.launcher.descriptors" }
{ $subsection "io.launcher.launch" }
"Advanced topics:"
{ $subsection "io.launcher.lifecycle" }
{ $subsection "io.launcher.command" }
{ $subsection "io.launcher.detached" }
{ $subsection "io.launcher.environment" }
{ $subsection "io.launcher.redirection" }
{ $subsection "io.launcher.timeouts" } ;

ABOUT: "io.launcher"
