/*
    load.d -- Binary loader (contains also open_fasl_data).
*/
/*
    Copyright (c) 1990, Giuseppe Attardi and William F. Schelter.
    Copyright (c) 2001, Juan Jose Garcia Ripoll.

    ECLS is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    See file '../Copyright' for full details.
*/


#include "ecls.h"
#include "ecls-inl.h"

#ifdef __mips
#include <sys/cachectl.h>
#endif __mips

/******************************* ------- ******************************/

cl_object Kverbose;
cl_object Vload_verbose;
cl_object Vload_print;
cl_object siVload_hooks;
#ifdef PDE
cl_object siVsource_pathname;
#endif PDE
#ifdef RSYM
cl_object siVsymbol_table;
#endif

@(defun si::load_binary (filename verbose print)
	cl_object block;
@
	block = alloc_object(t_codeblock);
	block->cblock.name = filename;
	dld(filename->string.self, &block->cblock.start, &block->cblock.size);

	if (!Null(verbose)) {
		write_str(";;; Address = ");
		PRINTescape = FALSE;
		write_addr(block->cblock.start);
		write_str("\n");
	}
	/* call the init_code function */
#ifdef __mips
	cacheflush(block->cblock.start, block->cblock.size, BCACHE);
#endif __mips
#ifdef __NeXT__
	asm("trap #2");		/* MC68040-specific */
#endif __NeXT__
	read_VV(block, block->cblock.start);
	@(return Ct)
@)

@(defun si::load_source (filename verbose print)
	cl_object x, strm;
	cl_object (*old_read_ch_fun)() = read_ch_fun;
@
	strm = open_stream(filename, smm_input, Cnil, Cnil);
	if (Null(strm))
		@(return Cnil)
	if (frs_push(FRS_PROTECT, Cnil)) {
		close_stream(strm, TRUE);
		frs_pop();
		unwind(nlj_fr, nlj_tag);
	}
	bds_bind(Vstandard_input, strm);
	for (;;) {
		preserving_whitespace_flag = FALSE;
		detect_eos_flag = TRUE;
		read_ch_fun = readc; /* setup for read. Beppe */
		x = read_object_non_recursive(strm);
		read_ch_fun = old_read_ch_fun;
		if (x == OBJNULL)
			break;
		{
			cl_object lex_old = lex_env;
			cl_object bytecodes = Cnil;

			lex_new();
			eval(x, &bytecodes);
			lex_env = lex_old;
		}
		if (print != Cnil) {
			setupPRINT(x, symbol_value(Vstandard_output));
			write_object(x, 0);
			write_str("\n");
			cleanupPRINT();
			flush_stream(PRINTstream);
		}
	}
	close_stream(strm, TRUE);
	frs_pop();
@)	

@(defun load (pathname
	      &key (verbose symbol_value(Vload_verbose))
		   (print symbol_value(Vload_print))
		   (if_does_not_exist Kerror)
	      &aux pntype hooks filename function defaults)
	bds_ptr old_bds_top;
@
	pathname = coerce_to_physical_pathname(pathname);
	defaults = symbol_value(Vdefault_pathname_defaults);
	defaults = coerce_to_physical_pathname(defaults);
	pathname = merge_pathnames(pathname, defaults, Knewest);
	pntype   = pathname->pathname.type;

	filename = Cnil;
	hooks = symbol_value(siVload_hooks);
	if (!Null(pntype) && (pntype != Kwild)) {
		/* If filename already has an extension, make sure
		   that the file exists */
		filename = coerce_to_filename(pathname);
		if (!file_exists(filename))
			FEcannot_open(filename);
		function = cdr(assoc(pathname->pathname.type, hooks));
	} else loop_for_in(hooks) {
		/* Otherwise try with known extensions until a matching
		   file is found */
		pathname->pathname.type = CAAR(hooks);
		filename = coerce_to_filename(pathname);
		function = CDAR(hooks);
		if (file_exists(filename))
			break;
		else
			filename = Cnil;
	} end_loop_for_in;
	if (Null(filename)) {
		if (Null(if_does_not_exist))
			@(return Cnil)
		else
			FEcannot_open(pathname);
	}

	if (verbose != Cnil) {
		setupPRINT(filename, symbol_value(Vstandard_output));
		if (file_column(PRINTstream) != 0)
			write_str("\n");
		write_str(";;; Loading ");
		PRINTescape = FALSE;
		write_object(filename, 0);
		write_str("\n");
		cleanupPRINT();
		flush_stream(PRINTstream);
	}
	old_bds_top = bds_top;
	bds_bind(Vpackage, symbol_value(Vpackage));
#ifdef PDE
	bds_bind(siVsource_pathname, filename);
#endif PDE
	if (frs_push(FRS_PROTECT, Cnil)) {
		frs_pop();
		bds_unwind(old_bds_top); /* Beppe says this is necessary */
		unwind(nlj_fr, nlj_tag);
	}
	if (Null(function))
		siLload_source(3, filename, verbose, print);
	else
		funcall(4, function, filename, verbose, print);
	frs_pop();
	bds_unwind(old_bds_top);
	if (print != Cnil) {
		setupPRINT(filename, symbol_value(Vstandard_output));
		if (file_column(PRINTstream) != 0)
			write_str("\n");
		write_str(";;; Finished loading ");
		PRINTescape = FALSE;
		write_object(filename, 0);
		write_str("\n");
		cleanupPRINT();
		flush_stream(PRINTstream);
	}
	@(return pathname)
@)


/* ----------------------------------------------------------------------
 * Binary file loader utilities
 * ----------------------------------------------------------------------
 */
#ifdef RSYM
static int symbol_table_built = 0;
extern int read_special_symbols(const char *);
void
build_symbol_table()
{
   cl_object file;
   const char *tmpfile;
   file = namestring(Lmerge_pathnames(2, SYM_VAL(siVsymbol_table),
				      SYM_VAL(siVsystem_directory)));
   tmpfile = file->string.self;
   if (!symbol_table_built)
     if (read_special_symbols(tmpfile) < 0)
       FEerror("Could not read symbol table from ~A", 1, make_string_copy(tmpfile));
}
#endif

const char *
system_directory()
{
  cl_object dir = SYM_VAL(siVsystem_directory);
  while (type_of(dir) != t_string)
    FEerror("The value of sys::*system-directory* is not a string, ~A", 1, dir);
  return dir->string.self;
}

/* ---------------------------------------------------------------------- */
#if 0

@(defun si::faslink (file lib)
	bds_ptr old_bds_top;
	cl_object package;
@
	check_type_string(&lib);
	/* INV: coerce_to_physical_pathname() checks types */
	file = coerce_to_filename(file);
	file->pathname.type = FASL_string;
	file = namestring(file);
	package = symbol_value(Vpackage);
	old_bds_top = bds_top;
	bds_bind(Vpackage, package);
	faslink(file, lib);
	bds_unwind(old_bds_top);
	@(return Cnil)
@)
#endif unix

void
init_load(void)
{
  cl_object load_source, load_binary;

  SYM_VAL(Vload_verbose) = Ct;
  SYM_VAL(Vload_print) = Cnil;
#ifdef PDE
  SYM_VAL(siVsource_pathname) = Cnil;
#endif PDE

  load_source = make_si_ordinary("LOAD-SOURCE");
  load_binary = make_si_ordinary("LOAD-BINARY");
  SYM_VAL(siVload_hooks) = list(4,
				CONS(make_simple_string("o"), load_binary),
				CONS(make_simple_string("lsp"), load_source),
				CONS(make_simple_string("lisp"), load_source),
				CONS(Cnil, load_source));

#ifdef RSYM
  SYM_VAL(siVsymbol_table) = make_simple_string("ecl.sym");
#endif
}
