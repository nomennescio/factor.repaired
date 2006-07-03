#ifdef __APPLE__

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <signal.h>

#include <mach/mach.h>
#include <mach/mach_error.h>
#include <mach/thread_status.h>
#include <mach/exception.h>
#include <mach/task.h>
#include <pthread.h>

/* For MacOSX.  */
#ifndef SS_DISABLE
#define SS_DISABLE SA_DISABLE
#endif

/* This is not defined in any header, although documented.  */

/* http://web.mit.edu/darwin/src/modules/xnu/osfmk/man/exc_server.html says:
   The exc_server function is the MIG generated server handling function
   to handle messages from the kernel relating to the occurrence of an
   exception in a thread. Such messages are delivered to the exception port
   set via thread_set_exception_ports or task_set_exception_ports. When an
   exception occurs in a thread, the thread sends an exception message to its
   exception port, blocking in the kernel waiting for the receipt of a reply.
   The exc_server function performs all necessary argument handling for this
   kernel message and calls catch_exception_raise, catch_exception_raise_state
   or catch_exception_raise_state_identity, which should handle the exception.
   If the called routine returns KERN_SUCCESS, a reply message will be sent,
   allowing the thread to continue from the point of the exception; otherwise,
   no reply message is sent and the called routine must have dealt with the
   exception thread directly.  */
extern boolean_t
       exc_server (mach_msg_header_t *request_msg,
                   mach_msg_header_t *reply_msg);


/* http://web.mit.edu/darwin/src/modules/xnu/osfmk/man/catch_exception_raise.html
   These functions are defined in this file, and called by exc_server.
   FIXME: What needs to be done when this code is put into a shared library? */
kern_return_t
catch_exception_raise (mach_port_t exception_port,
                       mach_port_t thread,
                       mach_port_t task,
                       exception_type_t exception,
                       exception_data_t code,
                       mach_msg_type_number_t code_count);
kern_return_t
catch_exception_raise_state (mach_port_t exception_port,
                             exception_type_t exception,
                             exception_data_t code,
                             mach_msg_type_number_t code_count,
                             thread_state_flavor_t *flavor,
                             thread_state_t in_state,
                             mach_msg_type_number_t in_state_count,
                             thread_state_t out_state,
                             mach_msg_type_number_t *out_state_count);
kern_return_t
catch_exception_raise_state_identity (mach_port_t exception_port,
                                      mach_port_t thread,
                                      mach_port_t task,
                                      exception_type_t exception,
                                      exception_data_t code,
                                      mach_msg_type_number_t codeCnt,
                                      thread_state_flavor_t *flavor,
                                      thread_state_t in_state,
                                      mach_msg_type_number_t in_state_count,
                                      thread_state_t out_state,
                                      mach_msg_type_number_t *out_state_count);

#ifdef __i386__
	#define SIGSEGV_EXC_STATE_TYPE i386_exception_state_t
	#define SIGSEGV_EXC_STATE_FLAVOR i386_EXCEPTION_STATE
	#define SIGSEGV_EXC_STATE_COUNT i386_EXCEPTION_STATE_COUNT
	#define SIGSEGV_THREAD_STATE_TYPE i386_thread_state_t
	#define SIGSEGV_THREAD_STATE_FLAVOR i386_THREAD_STATE
	#define SIGSEGV_THREAD_STATE_COUNT i386_THREAD_STATE_COUNT
	#define SIGSEGV_STACK_POINTER(thr_state) (thr_state).esp
	#define SIGSEGV_PROGRAM_COUNTER(thr_state) (thr_state).eip
#else
	#define SIGSEGV_EXC_STATE_TYPE ppc_exception_state_t
	#define SIGSEGV_EXC_STATE_FLAVOR ppc_EXCEPTION_STATE
	#define SIGSEGV_EXC_STATE_COUNT ppc_EXCEPTION_STATE_COUNT
	#define SIGSEGV_THREAD_STATE_TYPE ppc_thread_state_t
	#define SIGSEGV_THREAD_STATE_FLAVOR PPC_THREAD_STATE
	#define SIGSEGV_THREAD_STATE_COUNT PPC_THREAD_STATE_COUNT
	#define SIGSEGV_STACK_POINTER(thr_state) (thr_state).r1
	#define SIGSEGV_PROGRAM_COUNTER(thr_state) (thr_state).srr0
#endif

int mach_initialize ();

#endif
