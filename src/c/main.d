/*
    main.c --
*/
/*
    Copyright (c) 1984, Taiichi Yuasa and Masami Hagiya.
    Copyright (c) 1990, Giuseppe Attardi.
    Copyright (c) 2001, Juan Jose Garcia Ripoll.

    ECLS is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    See file '../Copyright' for full details.
*/

/*		********  WARNING ********
    Do not insert any data definitions before data_start!
    Since this is the first file linked, the address of the following
    variable should correspond to the start of initialized data space.
    On some systems this is a constant that is independent of the text
    size for shared executables.  On others, it is a function of the
    text size. In short, this seems to be the most portable way to
    discover the start of initialized data space dynamically at runtime,
    for either shared or unshared executables, on either swapping or
    virtual systems.  It only requires that the linker allocate objects
    in the order encountered, a reasonable model for most Unix systems.
      Fred Fish, UniSoft Systems Inc.  */

/*  On SGI one could use extern _fdata[] instead */

int data_start = (int)&data_start;

/******************************** IMPORTS *****************************/

#include "ecls.h"
#ifdef HAVE_SYS_UTSNAME_H
# include <sys/utsname.h>
#endif
#ifdef TK
# include "tk.h"
#endif

/******************************* EXPORTS ******************************/

cl_object Vfeatures;
cl_object siVsystem_directory;
const char *ecl_self;

/******************************* ------- ******************************/

static int	ARGC;
static char	**ARGV;

#ifdef THREADS
static cl_object siVthread_top;
#endif THREADS
static cl_object siStop_level;

#if !defined(GBC_BOEHM)
static char stdin_buf[BUFSIZ];
static char stdout_buf[BUFSIZ];
#endif

int
main(int argc, char **argv)
{
#if !defined(GBC_BOEHM)
	setbuf(stdin,  stdin_buf);
	setbuf(stdout, stdout_buf);
#endif

	ARGC = argc;
	ARGV = argv;
	ecl_self = argv[0];

	init_alloc();
	alloc_stacks(&argc);

#ifndef MSDOS
	ecl_self = expand_pathname(ecl_self);
#endif MSDOS

	/*ihs_push(Cnil, lex);*/
	lex_new();

	/* Initialize library */
	init_lisp();

	/* Jump to top level */
	SYM_VAL(Vpackage) = user_package;
	enable_interrupt();
	siLcatch_bad_signals(0);
#ifdef THREADS
	enable_lwp();
#endif THREADS
#ifdef TK
	if (getenv("DISPLAY")) {
	  Tk_main(FALSE, /* sync */
		  "ECL/Tk", /* name */
		  NULL, /* file */
		  getenv("DISPLAY"), /* Xdisplay */
		  NULL); /* geometry */
	}
#endif
	ihs_push(_intern("TOP-LEVEL", system_package), Cnil);
	funcall(1, siStop_level);
	return(0);
}

@(defun quit (&optional (code MAKE_FIXNUM(0)))
	cl_fixnum i;
@
	if (!FIXNUMP(code))
		FEerror("Illegal exit code: ~S.", 1, code);
	i = fix(code);
#ifdef THREADS
	if (clwp != &main_lpd) {
	  VALUES(0) = Cnil;
	  NValues = 0;
	  throw(siVthread_top);
	  /* never reached */
	}
#endif THREADS
	printf("Bye.\n");
	exit(i);
@)

@(defun si::argc ()
@
	@(return MAKE_FIXNUM(ARGC))
@)

@(defun si::argv (index)
	cl_fixnum i;
@
	if (!FIXNUMP(index) || (i = fix(index)) < 0 || i >= ARGC)
		FEerror("Illegal argument index: ~S.", 1, index);
	@(return make_string_copy(ARGV[i]))
@)

@(defun si::getenv (var)
	char name[256], *value;
	cl_index i;
@
	assert_type_string(var);
	if (var->string.fillp >= 256)
		FEerror("Too long name: ~S.", 1, var);
	for (i = 0;  i < var->string.fillp;  i++)
		name[i] = var->string.self[i];
	name[i] = '\0';
	value = getenv(name);
	@(return ((value == NULL)? Cnil : make_string_copy(value)))
@)

@(defun si::address (x)
@
	@(return MAKE_FIXNUM((int)x))
@)

#ifdef HAVE_SYS_UTSNAME_H
@(defun machine_instance ()
	struct utsname uts;
@
	uname(&uts);
	@(return make_string_copy(uts.nodename))
@)

@(defun machine_version ()
	struct utsname uts;
@
	uname(&uts);
	@(return make_string_copy(uts.machine))
@)

@(defun software_type ()
	struct utsname uts;
@
	uname (&uts);
	@(return make_string_copy(uts.sysname))
@)

@(defun software_version ()
	struct utsname uts;
@
	uname (&uts);
	@(return make_string_copy(uts.release))
@)
#endif

void
init_main(void)
{
	siStop_level=make_si_ordinary("TOP-LEVEL");
	register_root(&siStop_level);

	make_ordinary("LISP-IMPLEMENTATION-VERSION");

	SYM_VAL(siVsystem_directory) = make_simple_string("./");

	{ cl_object features;
	  features =
	    CONS(make_keyword("ECLS"),
		 CONS(make_keyword("COMMON"), Cnil));

#define ADD_FEATURE(name)	features = CONS(make_keyword(name),features)

#if defined(GBC_BOEHM)
	 ADD_FEATURE("BOEHM-GC");
#endif

#ifdef LOCATIVE
	 ADD_FEATURE("LOCATIVE");
#endif LOCATIVE

#ifdef THREADS
	 ADD_FEATURE("THREADS");
#endif THREADS
	
#ifdef CLOS
	 ADD_FEATURE("CLOS");
#endif CLOS

	 ADD_FEATURE("ANSI-CL");

#ifdef PDE
	 ADD_FEATURE("PDE");
#endif PDE

/* ---------- Operating System ---------- */
#ifdef unix
	 ADD_FEATURE("UNIX");
#endif
#ifdef BSD
	 ADD_FEATURE("BSD");
#endif
#ifdef SYSV
	 ADD_FEATURE("SYSTEM-V");
#endif
#ifdef MSDOS
	 ADD_FEATURE("MS-DOS");
#endif

	 ADD_FEATURE(ARCHITECTURE);
	 ADD_FEATURE(BRAND);

#ifdef IEEEFLOAT
	 ADD_FEATURE("IEEE-FLOATING-POINT");
#endif

	 SYM_VAL(Vfeatures) = features;
       }
#ifdef THREADS
	siVthread_top = make_si_ordinary("THREAD-TOP");
#endif THREADS

	make_si_constant("+OBJNULL+", OBJNULL);
}
