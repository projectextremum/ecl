/*
    file.d -- File interface.
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

/*
	IMPLEMENTATION-DEPENDENT

	The file contains code to reclaim the I/O buffer
	by accessing the FILE structure of C.
*/

#include <ecls.h>

#if defined(BSD) && !defined(MSDOS)
#include <sys/ioctl.h>
#endif

/******************************* EXPORTS ******************************/
cl_object Vstandard_input;
cl_object Vstandard_output;
cl_object Verror_output;
cl_object Vquery_io;
cl_object Vdebug_io;
cl_object Vterminal_io;
cl_object Vtrace_output;

cl_object Kabort;
cl_object Kdirection;
cl_object Kinput;
cl_object Koutput;
cl_object Kio;
cl_object Kprobe;
cl_object Kelement_type;
cl_object Kdefault;
cl_object Kif_exists;
cl_object Kerror;
cl_object Knew_version;
cl_object Krename;
cl_object Krename_and_delete;
cl_object Koverwrite;
cl_object Kappend;
cl_object Ksupersede;
cl_object Kcreate;
cl_object Kprint;
cl_object Kif_does_not_exist;
cl_object Kset_default_pathname;

/******************************* ------- ******************************/

static cl_object terminal_io;

cl_object siVignore_eof_on_terminal_io;

static bool
feof1(FILE *fp)
{
	if (!feof(fp))
		return(FALSE);
	if (fp == terminal_io->stream.object0->stream.file) {
		if (Null(symbol_value(siVignore_eof_on_terminal_io)))
			return(TRUE);
#ifdef unix
		fp = freopen("/dev/tty", "r", fp);
#endif
		if (fp == NULL)
			error("can't reopen the console");
		return(FALSE);
	}
	return(TRUE);
}

#undef  feof
#define feof    feof1

/*----------------------------------------------------------------------
 *	Input_stream_p(strm) answers
 *	if stream strm is an input stream or not.
 *	It does not check if it really is possible to read
 *	from the stream,
 *	but only checks the mode of the stream (sm_mode).
 *----------------------------------------------------------------------
 */
bool
input_stream_p(cl_object strm)
{
BEGIN:
	switch ((enum smmode)strm->stream.mode) {
	case smm_closed:
		closed_stream(strm);
		break;

	case smm_io:
	case smm_input:
	case smm_concatenated:
	case smm_two_way:
	case smm_echo:
	case smm_string_input:
		return(TRUE);

	case smm_output:
	case smm_probe:
	case smm_string_output:
	case smm_broadcast:
		return(FALSE);

	case smm_synonym:
		strm = symbol_value(strm->stream.object0);
		if (type_of(strm) != t_stream)
			FEwrong_type_argument(Sstream, strm);
		goto BEGIN;

	default:
		error("illegal stream mode");
	}
}

/*----------------------------------------------------------------------
 *	Output_stream_p(strm) answers
 *	if stream strm is an output stream.
 *	It does not check if it really is possible to write
 *	to the stream,
 *	but only checks the mode of the stream (sm_mode).
 *----------------------------------------------------------------------
 */
bool
output_stream_p(cl_object strm)
{
BEGIN:
	switch ((enum smmode)strm->stream.mode) {
	case smm_closed:
		closed_stream(strm);
		return(FALSE);

	case smm_input:
	case smm_probe:
	case smm_concatenated:
	case smm_string_input:
		return(FALSE);

	case smm_output:
	case smm_io:
	case smm_two_way:
	case smm_echo:
	case smm_broadcast:
	case smm_string_output:
		return(TRUE);

	case smm_synonym:
		strm = symbol_value(strm->stream.object0);
		if (type_of(strm) != t_stream)
			FEwrong_type_argument(Sstream, strm);
		goto BEGIN;

	default:
		error("illegal stream mode");
	}
}

cl_object
stream_element_type(cl_object strm)
{
	cl_object x;

BEGIN:
	switch ((enum smmode)strm->stream.mode) {
	case smm_closed:
		closed_stream(strm);
		return(FALSE);

	case smm_input:
	case smm_output:
	case smm_io:
	case smm_probe:
		return(strm->stream.object0);

	case smm_synonym:
		strm = symbol_value(strm->stream.object0);
		if (type_of(strm) != t_stream)
			FEwrong_type_argument(Sstream, strm);
		goto BEGIN;

	case smm_broadcast:
		x = strm->stream.object0;
		if (endp(x))
			return(Ct);
		return(stream_element_type(CAR(x)));

	case smm_concatenated:
		x = strm->stream.object0;
		if (endp(x))
			return(Ct);
		return(stream_element_type(CAR(x)));

	case smm_two_way:
	case smm_echo:
		return(stream_element_type(strm->stream.object0));

	case smm_string_input:
	case smm_string_output:
		return(Sbase_char);

	default:
		error("illegal stream mode");
	}
}

/*----------------------------------------------------------------------
 *	Error messages
 *----------------------------------------------------------------------
 */

static void cannot_create(cl_object fn) __attribute__((noreturn));
static void cannot_read(cl_object fn) __attribute__((noreturn));
static void cannot_write(cl_object fn) __attribute__((noreturn));
static void internal_stream_error(const char *routine, cl_object strm) __attribute__((noreturn));

static void
cannot_create(cl_object fn)
{
	FEerror("Cannot create the file ~A.", 1, fn);
}

static void
cannot_read(cl_object strm)
{
	FEerror("Cannot read the stream ~S.", 1, strm);
}

static void
cannot_write(cl_object strm)
{
	FEerror("Cannot write to the stream ~S.", 1, strm);
}

static void
internal_stream_error(const char *routine, cl_object strm)
{
	FEerror("~A : internal error, closed stream ~S without smm_mode flag.",
		2, make_simple_string(routine), strm);
}

void
closed_stream(cl_object strm)
{
	FEerror("The stream ~S is already closed.", 1, strm);
}

/*----------------------------------------------------------------------
 *	Open_stream(fn, smm, if_exists, if_does_not_exist)
 *	opens file fn with mode smm.
 *	Fn is a pathname designator.
 *----------------------------------------------------------------------
 */
cl_object
open_stream(cl_object fn, enum smmode smm, cl_object if_exists,
	    cl_object if_does_not_exist)
{
	cl_object x;
	FILE *fp;
	char *fname = coerce_to_filename(fn)->string.self;

	if (smm == smm_input || smm == smm_probe) {
		fp = fopen(fname, OPEN_R);
		if (fp == NULL) {
			if (if_does_not_exist == Kerror)
				FEcannot_open(fn);
			else if (if_does_not_exist == Kcreate) {
				fp = fopen(fname, OPEN_W);
				if (fp == NULL)
					cannot_create(fn);
				fclose(fp);
				fp = fopen(fname, OPEN_R);
				if (fp == NULL)
					FEcannot_open(fn);
			} else if (Null(if_does_not_exist))
				return(Cnil);
			else
			 FEerror("~S is an illegal IF-DOES-NOT-EXIST option.",
				 1, if_does_not_exist);
		}
	} else if (smm == smm_output || smm == smm_io) {
		if (if_exists == Knew_version && if_does_not_exist == Kcreate)
			goto CREATE;
		fp = fopen(fname, OPEN_R);
		if (fp != NULL) {
			fclose(fp);
			if (if_exists == Kerror)
				FEerror("The file ~A already exists.", 1, fn);
			else if (if_exists == Krename) {
				fp = backup_fopen(fname, (smm == smm_output)
						  ? OPEN_W
						  : OPEN_RW);
				if (fp == NULL)
					cannot_create(fn);
			} else if (if_exists == Krename_and_delete ||
				   if_exists == Knew_version ||
				   if_exists == Ksupersede) {
				fp = fopen(fname, (smm == smm_output)
					   ? OPEN_W
					   : OPEN_RW);
				if (fp == NULL)
					cannot_create(fn);
			} else if (if_exists == Koverwrite) {
				fp = fopen(fname, OPEN_RW);
				if (fp == NULL)
					FEcannot_open(fn);
			} else if (if_exists == Kappend) {
				fp = fopen(fname, (smm == smm_output)
					   ? OPEN_A
					   : OPEN_RA);
				if (fp == NULL)
				FEerror("Cannot append to the file ~A.",1,fn);
			} else if (Null(if_exists))
				return(Cnil);
			else
				FEerror("~S is an illegal IF-EXISTS option.",
					1, if_exists);
		} else {
			if (if_does_not_exist == Kerror)
				FEerror("The file ~A does not exist.", 1, fn);
			else if (if_does_not_exist == Kcreate) {
			CREATE:
				fp = fopen(fname, (smm == smm_output)
					   ? OPEN_W
					   : OPEN_RW);
				if (fp == NULL)
					cannot_create(fn);
			} else if (Null(if_does_not_exist))
				return(Cnil);
			else
			 FEerror("~S is an illegal IF-DOES-NOT-EXIST option.",
				 1, if_does_not_exist);
		}
	} else
		error("illegal stream mode");
	x = alloc_object(t_stream);
	x->stream.mode = (short)smm;
	x->stream.file = fp;
	x->stream.object0 = Sbase_char;
	x->stream.object1 = fn;
	x->stream.int0 = x->stream.int1 = 0;
#if !defined(GBC_BOEHM)
	fp->_IO_buf_base = NULL; /* BASEFF; */
	setbuf(fp, x->stream.buffer = alloc(BUFSIZ));
#endif
	return(x);
}


/*----------------------------------------------------------------------
 *	Close_stream(strm, abort_flag) closes stream strm.
 *	The abort_flag is not used now.
 *----------------------------------------------------------------------
 */
void
close_stream(cl_object strm, bool abort_flag)        /*  Not used now!  */
{
	FILE *fp;

	fp = strm->stream.file;
	switch ((enum smmode)strm->stream.mode) {
	case smm_closed:
	  /* It is permissible to close a closed stream, although the output
	     is unspecified in those cases. */
		break;

	case smm_output:
	    if (fp == stdout)
	      FEerror("Cannot close the standard output.", 0);
	    if (fp == NULL)
	      internal_stream_error("close_stream", strm);
	    fflush(fp);
	    fclose(fp);
#if !defined(GBC_BOEHM)
	    dealloc(strm->stream.buffer, BUFSIZ);
	    strm->stream.buffer = NULL;
#endif
	    strm->stream.file = NULL;
	    break;

	case smm_input:
		if (fp == stdin)
			FEerror("Cannot close the standard input.", 0);

	case smm_io:
	case smm_probe:
	    if (fp == NULL)
	      internal_stream_error("close_stream", strm);
	    fclose(fp);
#if !defined(GBC_BOEHM)
	    dealloc(strm->stream.buffer, BUFSIZ);
	    strm->stream.file = NULL;
#endif
	    break;
#if 0
	case smm_synonym:
		strm = symbol_value(strm->stream.object0);
		if (type_of(strm) != t_stream)
			FEwrong_type_argument(Sstream, strm);
		goto BEGIN;

	case smm_broadcast:
		for (x = strm->stream.object0; !endp(x); x = CDR(x))
			close_stream(CAR(x), abort_flag);
		strm->stream.object0 = Cnil;
		break;

	case smm_concatenated:
		for (x = strm->stream.object0; !endp(x); x = CDR(x))
			close_stream(CAR(x), abort_flag);
		break;

	case smm_two_way:
		close_stream(strm->stream.object0, abort_flag);
		close_stream(strm->stream.object1, abort_flag);
		break;

	case smm_echo:
		close_stream(strm->stream.object0, abort_flag);
		close_stream(strm->stream.object1, abort_flag);
		break;

	case smm_string_input:
		break;          /*  There is nothing to do.  */

	case smm_string_output:
		break;          /*  There is nothing to do.  */
#else
	case smm_synonym:
	case smm_broadcast:
	case smm_concatenated:
	case smm_two_way:
	case smm_echo:
	case smm_string_input:
	case smm_string_output:
	  /* The elements of a composite stream are not closed. For
	     composite streams we zero object1. For files we do not,
	     as it might contain an useful pathname */
		strm->stream.object1 = OBJNULL;
		break;
#endif
	default:
		error("illegal stream mode");
	}
	strm->stream.mode = smm_closed;
	strm->stream.file = NULL;
	strm->stream.object0 = OBJNULL;
}

cl_object
make_two_way_stream(cl_object istrm, cl_object ostrm)
{
	cl_object strm;

	strm = alloc_object(t_stream);
	strm->stream.mode = (short)smm_two_way;
	strm->stream.file = NULL;
	strm->stream.object0 = istrm;
	strm->stream.object1 = ostrm;
	strm->stream.int0 = strm->stream.int1 = 0;
	return(strm);
}

cl_object
make_echo_stream(cl_object istrm, cl_object ostrm)
{
	cl_object strm;

	strm = make_two_way_stream(istrm, ostrm);
	strm->stream.mode = (short)smm_echo;
	return(strm);
}

cl_object
make_string_input_stream(cl_object strng, cl_index istart, cl_index iend)
{
	cl_object strm;

	strm = alloc_object(t_stream);
	strm->stream.mode = (short)smm_string_input;
	strm->stream.file = NULL;
	strm->stream.object0 = strng;
	strm->stream.object1 = OBJNULL;
	strm->stream.int0 = istart;
	strm->stream.int1 = iend;
	return(strm);
}

cl_object
make_string_output_stream(cl_index line_length)
{
	cl_object strng, strm;

	line_length++;
	strng = alloc_object(t_string);
	strng->string.hasfillp = TRUE;
	strng->string.adjustable = TRUE;
	strng->string.displaced = Cnil;
	strng->string.dim = line_length;
	strng->string.fillp = 0;
	strng->string.self = NULL; /*  For GC sake  */
	strng->string.self = alloc(line_length);
	strng->string.self[0] = '\0';
	strm = alloc_object(t_stream);
	strm->stream.mode = (short)smm_string_output;
	strm->stream.file = NULL;
	strm->stream.object0 = strng;
	strm->stream.object1 = OBJNULL;
	strm->stream.int0 = strm->stream.int1 = 0;
	return(strm);
}

cl_object
get_output_stream_string(cl_object strm)
{
	cl_object strng;

	strng = copy_simple_string(strm->stream.object0);
	strm->stream.object0->string.fillp = 0;
	return(strng);
}



#ifdef TK
bool no_input = FALSE;

StdinEnableEvents()
{
  no_input = TRUE;
}

StdinResume()
{
  no_input = FALSE;
}
# define GETC(c, fp)	{ if (fp == stdin) \
			   while (no_input) Tk_DoOneEvent(0); \
			  c = getc(fp); \
			  no_input = !FILE_CNT(fp); }
# define UNGETC(c, fp)	{ if (fp == stdin) no_input = FALSE; ungetc(c, fp); }
#else
# define GETC(c, fp)	c = getc(fp)
# define UNGETC(c, fp)	ungetc(c, fp)
#endif

int
readc_stream(cl_object strm)
{
	int c;
	FILE *fp;

BEGIN:
	fp = strm->stream.file;
	switch ((enum smmode)strm->stream.mode) {
	case smm_closed:
		closed_stream(strm);
		break;

	case smm_input:
	case smm_io:
		if (fp == NULL)
			internal_stream_error("readc_stream",strm);
		GETC(c, fp);
/*		c &= 0377; */
		if (feof(fp))
			FEend_of_file(strm);
/* 		strm->stream.int0++; useless in smm_io, Beppe */
		return(c);

	case smm_synonym:
		strm = symbol_value(strm->stream.object0);
		if (type_of(strm) != t_stream)
			FEwrong_type_argument(Sstream, strm);
		goto BEGIN;

	case smm_concatenated:
		{ cl_object strmi = strm->stream.object0;
		  while (!endp(strmi)) {
		    if (!stream_at_end(CAR(strmi)))
		      return(readc_stream(CAR(strmi)));
		    strm->stream.object0 = strmi = CDR(strmi);
		  }
		  FEend_of_file(strm);
		}

	case smm_two_way:
#ifdef unix
		if (strm == terminal_io)                                /**/
			flush_stream(terminal_io->stream.object1);       /**/
#endif
		strm->stream.int1 = 0;
		strm = strm->stream.object0;
		goto BEGIN;

	case smm_echo:
		c = readc_stream(strm->stream.object0);
		if (strm->stream.int0 == 0)
			writec_stream(c, strm->stream.object1);
		else		/* don't echo twice if it was unread */
			--(strm->stream.int0);
		return(c);

	case smm_string_input:
		if (strm->stream.int0 >= strm->stream.int1)
			FEend_of_file(strm);
		return(strm->stream.object0->string.self[strm->stream.int0++]);

	case smm_output:
	case smm_probe:
	case smm_broadcast:
	case smm_string_output:
		cannot_read(strm);

	default:
		error("illegal stream mode");
	}
}

void
unreadc_stream(int c, cl_object strm)
{
	FILE *fp;

BEGIN:
	fp = strm->stream.file;
	switch ((enum smmode)strm->stream.mode) {
	case smm_closed:
		closed_stream(strm);
		break;

	case smm_input:
	case smm_io:
		if (fp == NULL)
			internal_stream_error("unreadc_stream",strm);
		UNGETC(c, fp);
/*		--strm->stream.int0; useless in smm_io, Beppe */
		break;

	case smm_synonym:
		strm = symbol_value(strm->stream.object0);
		if (type_of(strm) != t_stream)
			FEwrong_type_argument(Sstream, strm);
		goto BEGIN;

	case smm_concatenated:
		if (endp(strm->stream.object0))
			goto UNREAD_ERROR;
		strm = CAR(strm->stream.object0);
		goto BEGIN;

	case smm_two_way:
		strm = strm->stream.object0;
		goto BEGIN;

	case smm_echo:
		unreadc_stream(c, strm->stream.object0);
		(strm->stream.int0)++;
		break;

	case smm_string_input:
		if (strm->stream.int0 <= 0)
			goto UNREAD_ERROR;
		--strm->stream.int0;
		break;

	case smm_output:
	case smm_probe:
	case smm_broadcast:
	case smm_string_output:
		goto UNREAD_ERROR;

	default:
		error("illegal stream mode");
	}
	return;

UNREAD_ERROR:
	FEerror("Cannot unread the stream ~S.", 1, strm);
}

int
writec_stream(int c, cl_object strm)
{
	cl_object x;
	unsigned char *p;
	cl_index i;
	FILE *fp;

BEGIN:
	fp = strm->stream.file;
	switch ((enum smmode)strm->stream.mode) {
	case smm_closed:
		closed_stream(strm);
		break;

	case smm_output:
	case smm_io:
/*		strm->stream.int0++; useless in smm_io, Beppe */
		if (c == '\n')
			strm->stream.int1 = 0;
		else if (c == '\t')
			strm->stream.int1 = (strm->stream.int1&~07) + 8;
		else
			strm->stream.int1++;
		if (fp == NULL)
			internal_stream_error("writec",strm);
		putc(c, fp);
		break;

	case smm_synonym:
		strm = symbol_value(strm->stream.object0);
		if (type_of(strm) != t_stream)
			FEwrong_type_argument(Sstream, strm);
		goto BEGIN;

	case smm_broadcast:
		for (x = strm->stream.object0; !endp(x); x = CDR(x))
			writec_stream(c, CAR(x));
		break;

	case smm_two_way:
		strm->stream.int0++;
		if (c == '\n')
			strm->stream.int1 = 0;
		else if (c == '\t')
			strm->stream.int1 = (strm->stream.int1&~07) + 8;
		else
			strm->stream.int1++;
		strm = strm->stream.object1;
		goto BEGIN;

	case smm_echo:
		strm = strm->stream.object1;
		goto BEGIN;

	case smm_string_output:
		strm->stream.int0++;
		if (c == '\n')
			strm->stream.int1 = 0;
		else if (c == '\t')
			strm->stream.int1 = (strm->stream.int1&~07) + 8;
		else
			strm->stream.int1++;
		x = strm->stream.object0;
		if (x->string.fillp >= x->string.dim) {
			if (!x->string.adjustable)
				FEerror("The string ~S is not adjustable.",
					1, x);
#ifdef THREADS
			start_critical_section(); /* avoid losing p */
#endif THREADS
			p = alloc(x->string.dim * 2 + 16);
			for (i = 0;  i < x->string.dim;  i++)
				p[i] = x->string.self[i];
			i = x->string.dim * 2 + 16;
#define ADIMLIM         16*1024*1024
			if (i >= ADIMLIM)
				FEerror("Can't extend the string.", 0);
			x->string.dim = i;
			adjust_displaced(x, p - x->string.self);
#ifdef THREADS
			end_critical_section();
#endif THREADS
		}
		x->string.self[x->string.fillp++] = c;
		break;

	case smm_input:
	case smm_probe:
	case smm_concatenated:
	case smm_string_input:
		cannot_write(strm);

	default:
		error("illegal stream mode");
	}
	return(c);
}

void
writestr_stream(const char *s, cl_object strm)
{
	while (*s != '\0')
		writec_stream(*s++, strm);
}

void
flush_stream(cl_object strm)
{
	cl_object x;
	FILE *fp;

BEGIN:
	fp = strm->stream.file;
	switch ((enum smmode)strm->stream.mode) {
	case smm_closed:
		closed_stream(strm);
		break;

	case smm_output:
	case smm_io:
		if (fp == NULL)
			internal_stream_error("flush_stream",strm);
		fflush(fp);
		break;

	case smm_synonym:
		strm = symbol_value(strm->stream.object0);
		if (type_of(strm) != t_stream)
			FEwrong_type_argument(Sstream, strm);
		goto BEGIN;

	case smm_broadcast:
		for (x = strm->stream.object0; !endp(x); x = CDR(x))
			flush_stream(CAR(x));
		break;

	case smm_two_way:
	case smm_echo:
		strm = strm->stream.object1;
		goto BEGIN;

	case smm_string_output: {
	  	cl_object strng = strm->stream.object0;
		strng->string.self[strng->string.fillp] = '\0';
		break;
	      }
	case smm_input:
	case smm_probe:
	case smm_concatenated:
	case smm_string_input:
		FEerror("Cannot flush the stream ~S.", 1, strm);

	default:
		error("illegal stream mode");
	}
}

void
clear_input_stream(cl_object strm)
{
	cl_object x;
	FILE *fp;

BEGIN:
	fp = strm->stream.file;
	switch ((enum smmode)strm->stream.mode) {
	case smm_closed:
		closed_stream(strm);
		break;

	case smm_input:
		if (fp == NULL)
			internal_stream_error("clear_input_stream",strm);
		fseek(fp, 0L, 2);
		break;

	case smm_synonym:
		strm = symbol_value(strm->stream.object0);
		if (type_of(strm) != t_stream)
			FEwrong_type_argument(Sstream, strm);
		goto BEGIN;

	case smm_broadcast:
		for (x = strm->stream.object0; !endp(x); x = CDR(x))
			flush_stream(CAR(x));
		break;

	case smm_two_way:
	case smm_echo:
		strm = strm->stream.object0;
		goto BEGIN;

	case smm_string_output:
	  break;

	case smm_io:
	case smm_output:
	case smm_probe:
	case smm_concatenated:
	case smm_string_input:
	  FEerror("Cannot clear the input of the stream ~S.", 1, strm);
	  break;

	default:
		error("illegal stream mode");
	}
}

void
clear_output_stream(cl_object strm)
{
	cl_object x;
	FILE *fp;

BEGIN:
	fp = strm->stream.file;
	switch ((enum smmode)strm->stream.mode) {
	case smm_closed:
		closed_stream(strm);
		break;

	case smm_output:
		if (fp == NULL)
			internal_stream_error("clear_output_stream",strm);
		fseek(fp, 0L, 2);
		break;

	case smm_synonym:
		strm = symbol_value(strm->stream.object0);
		if (type_of(strm) != t_stream)
			FEwrong_type_argument(Sstream, strm);
		goto BEGIN;

	case smm_broadcast:
		for (x = strm->stream.object0; !endp(x); x = CDR(x))
			flush_stream(CAR(x));
		break;

	case smm_two_way:
	case smm_echo:
		strm = strm->stream.object1;
		goto BEGIN;

	case smm_string_output:
	  break;

	case smm_io:
	case smm_input:
	case smm_probe:
	case smm_concatenated:
	case smm_string_input:
	  FEerror("Cannot clear the output of the stream ~S.", 1, strm);
	  break;

	default:
		error("illegal stream mode");
	}
}

bool
stream_at_end(cl_object strm)
{
	int c;
	FILE *fp;

#ifdef CLOS
	if (type_of(strm) == t_instance)
	  return(FALSE);
#endif

BEGIN:
	fp = strm->stream.file;
	switch ((enum smmode)strm->stream.mode) {
	case smm_closed:
		closed_stream(strm);
		return(TRUE);

	case smm_io:
	case smm_input:
		if (fp == NULL)
			closed_stream(strm);
		GETC(c, fp);
		if (feof(fp))
			return(TRUE);
		else {
			UNGETC(c, fp);
			return(FALSE);
		}

	case smm_output:
	case smm_probe:
	case smm_broadcast:
	case smm_string_output:
		return(FALSE);

	case smm_synonym:
		strm = symbol_value(strm->stream.object0);
		if (type_of(strm) != t_stream)
			FEwrong_type_argument(Sstream, strm);
		goto BEGIN;

	case smm_concatenated:
		{ cl_object strmi = strm->stream.object0;
		  while (!endp(strmi)) {
		    if (!stream_at_end(CAR(strmi)))
		      return(FALSE);
		    strm->stream.object0 = strmi = CDR(strmi);
		  }
		  return(TRUE);
		}

	case smm_two_way:
#ifdef unix
		if (strm == terminal_io)                                /**/
			flush_stream(terminal_io->stream.object1);       /**/
#endif
		strm = strm->stream.object0;
		goto BEGIN;

	case smm_echo:
		strm = strm->stream.object0;
		goto BEGIN;

	case smm_string_input:
		if (strm->stream.int0 >= strm->stream.int1)
			return(TRUE);
		else
			return(FALSE);

	default:
		error("illegal stream mode");
	}
}

bool
listen_stream(cl_object strm)
{
	FILE *fp;

BEGIN:
	switch ((enum smmode)strm->stream.mode) {
	case smm_closed:
		closed_stream(strm);
		return(FALSE);

	case smm_input:
	case smm_io:
		fp = strm->stream.file;
		if (fp == NULL)
			internal_stream_error("listen_stream",strm);
		if (feof(fp))
		  return(FALSE);
		if (FILE_CNT(fp) > 0)
		  return(TRUE);
#ifdef FIONREAD
		{ long c = 0;
		  ioctl(fileno(fp), FIONREAD, &c);
		  if (c <= 0)
		    return(FALSE);
		}
#endif FIONREAD
		return(TRUE);

	case smm_synonym:
		strm = symbol_value(strm->stream.object0);
		if (type_of(strm) != t_stream)
			FEwrong_type_argument(Sstream, strm);
		goto BEGIN;

	case smm_concatenated:
		if (endp(strm->stream.object0))
			return(FALSE);
		strm = CAR(strm->stream.object0);        /* Incomplete! */
		goto BEGIN;

	case smm_two_way:
	case smm_echo:
		strm = strm->stream.object0;
		goto BEGIN;

	case smm_string_input:
		return(strm->stream.int0 < strm->stream.int1);

	case smm_output:
	case smm_probe:
	case smm_broadcast:
	case smm_string_output:
		FEerror("Can't listen to ~S.", 1, strm);

	default:
		error("illegal stream mode");
	}
}

long
file_position(cl_object strm)
{
	FILE *fp;

BEGIN:
	switch ((enum smmode)strm->stream.mode) {
	case smm_closed:
		closed_stream(strm);
		return(-1);

	case smm_input:
	case smm_output:
	case smm_io:
		/*  return(strm->stream.int0);  */
		fp = strm->stream.file;
		if (fp == NULL)
			internal_stream_error("file_position",strm);
		return(ftell(fp));

	case smm_string_output:
		return(strm->stream.object0->string.fillp);

	case smm_synonym:
		strm = symbol_value(strm->stream.object0);
		if (type_of(strm) != t_stream)
			FEwrong_type_argument(Sstream, strm);
		goto BEGIN;

	case smm_probe:
	case smm_broadcast:
	case smm_concatenated:
	case smm_two_way:
	case smm_echo:
	case smm_string_input:
		return(-1);

	default:
		error("illegal stream mode");
	}
}

long
file_position_set(cl_object strm, long disp)
{
	FILE *fp;

BEGIN:
	switch ((enum smmode)strm->stream.mode) {
	case smm_closed:
		closed_stream(strm);
		return(-1);

	case smm_input:
	case smm_output:
	case smm_io:
		fp = strm->stream.file;
		if (fp == NULL)
			internal_stream_error("file_position_set",strm);
		if (fseek(fp, disp, 0) < 0)
			return(-1);
/*		strm->stream.int0 = disp; useless in smm_io, Beppe */
		return(0);

	case smm_string_output:
		if (disp < strm->stream.object0->string.fillp) {
			strm->stream.object0->string.fillp = disp;
			strm->stream.int0 = disp;
		} else {
			disp -= strm->stream.object0->string.fillp;
			while (disp-- > 0)
				writec_stream(' ', strm);
		}
		return(0);

	case smm_synonym:
		strm = symbol_value(strm->stream.object0);
		if (type_of(strm) != t_stream)
			FEwrong_type_argument(Sstream, strm);
		goto BEGIN;

	case smm_probe:
	case smm_broadcast:
	case smm_concatenated:
	case smm_two_way:
	case smm_echo:
	case smm_string_input:
		return(-1);

	default:
		error("illegal stream mode");
	}
}

long
file_length(cl_object strm)
{
	FILE *fp;

BEGIN:
	switch ((enum smmode)strm->stream.mode) {
	case smm_closed:
		closed_stream(strm);
		return(-1);

	case smm_input:
	case smm_output:
	case smm_io:
		fp = strm->stream.file;
		if (fp == NULL)
			internal_stream_error("file_length",strm);
		return(file_len(fp));

	case smm_synonym:
		strm = symbol_value(strm->stream.object0);
		if (type_of(strm) != t_stream)
			FEwrong_type_argument(Sstream, strm);
		goto BEGIN;

	/* FIXME! Should signal an error of type-error */
	case smm_probe:
	case smm_broadcast:
	case smm_concatenated:
	case smm_two_way:
	case smm_echo:
	case smm_string_input:
	case smm_string_output:
		return(-1);

	default:
		error("illegal stream mode");
	}
}

int
file_column(cl_object strm)
{

BEGIN:
	switch ((enum smmode)strm->stream.mode) {
	case smm_closed:
		closed_stream(strm);
		return(-1);

	case smm_output:
	case smm_io:
	case smm_two_way:
	case smm_string_output:
		return(strm->stream.int1);

	case smm_synonym:
		strm = symbol_value(strm->stream.object0);
		if (type_of(strm) != t_stream)
			FEwrong_type_argument(Sstream, strm);
		goto BEGIN;

	case smm_echo:
		strm = strm->stream.object1;
		goto BEGIN;

	case smm_input:
	case smm_probe:
	case smm_string_input:
		return(-1);

	case smm_concatenated:
		if (endp(strm->stream.object0))
			return(-1);
		strm = CAR(strm->stream.object0);
		goto BEGIN;

	case smm_broadcast:
		{
		  int i;
		  cl_object x;

		  for (x = strm->stream.object0; !endp(x); x = CDR(x)) {
		    i = file_column(CAR(x));
		    if (i >= 0)
		      return(i);
		  }
		  return(-1);
		}
	default:
		error("illegal stream mode");
	}
}

@(defun make_synonym_stream (sym)
	cl_object x;
@
	assert_type_symbol(sym);
	x = alloc_object(t_stream);
	x->stream.mode = (short)smm_synonym;
	x->stream.file = NULL;
	x->stream.object0 = sym;
	x->stream.object1 = OBJNULL;
	x->stream.int0 = x->stream.int1 = 0;
	@(return x)
@)


@(defun make_broadcast_stream (&rest ap)
	cl_object x, streams;
	int i;
@
	streams = Cnil;
	for (i = 0; i < narg; i++) {
		x = va_arg(ap, cl_object);
		if (type_of(x) != t_stream || !output_stream_p(x))
			cannot_write(x);
		streams = CONS(x, streams);
	}
	x = alloc_object(t_stream);
	x->stream.mode = (short)smm_broadcast;
	x->stream.file = NULL;
	x->stream.object0 = nreverse(streams);
	x->stream.object1 = OBJNULL;
	x->stream.int0 = x->stream.int1 = 0;
	@(return x)
@)

@(defun make_concatenated_stream (&rest ap)
	cl_object x, streams;
	int i;
@
	streams = Cnil;
	for (i = 0; i < narg; i++) {
		x = va_arg(ap, cl_object);
		if (type_of(x) != t_stream || !input_stream_p(x))
			cannot_read(x);
		streams = CONS(x, streams);
	}
	x = alloc_object(t_stream);
	x->stream.mode = (short)smm_concatenated;
	x->stream.file = NULL;
	x->stream.object0 = nreverse(streams);
	x->stream.object1 = OBJNULL;
	x->stream.int0 = x->stream.int1 = 0;
	@(return x)
@)

@(defun make_two_way_stream (strm1 strm2)
@
	if (type_of(strm1) != t_stream || !input_stream_p(strm1))
		cannot_read(strm1);
	if (type_of(strm2) != t_stream || !output_stream_p(strm2))
		cannot_write(strm2);
	@(return make_two_way_stream(strm1, strm2))
@)

@(defun make_echo_stream (strm1 strm2)
@
	if (type_of(strm1) != t_stream || !input_stream_p(strm1))
		cannot_read(strm1);
	if (type_of(strm2) != t_stream || !output_stream_p(strm2))
		cannot_write(strm2);
	@(return make_echo_stream(strm1, strm2))
@)

@(defun make_string_input_stream (strng &o istart iend)
	cl_index s, e;
@
	assert_type_string(strng);
	if (Null(istart))
		s = 0;
	else if (!FIXNUMP(istart) || FIXNUM_MINUSP(istart))
		goto E;
	else
		s = (cl_index)fix(istart);
	if (Null(iend))
		e = strng->string.fillp;
	else if (!FIXNUMP(iend) || FIXNUM_MINUSP(iend))
		goto E;
	else
		e = (cl_index)fix(iend);
	if (e > strng->string.fillp || s > e)
		goto E;
	@(return `make_string_input_stream(strng, s, e)`)

E:
	FEerror("~S and ~S are illegal as :START and :END~%\
for the string ~S.",
		3, istart, iend, strng);
@)

@(defun make_string_output_stream ()
@
	@(return make_string_output_stream(64))
@)

@(defun get_output_stream_string (strm)
@
	if (type_of(strm) != t_stream ||
	    (enum smmode)strm->stream.mode != smm_string_output)
		FEerror("~S is not a string-output stream.", 1, strm);
	@(return get_output_stream_string(strm))
@)

/*----------------------------------------------------------------------
 *	(SI:OUTPUT-STREAM-STRING string-output-stream)
 *
 *		extracts the string associated with the given
 *		string-output-stream.
 *----------------------------------------------------------------------
 */
@(defun si::output_stream_string (strm)
@
	if (type_of(strm) != t_stream ||
	    (enum smmode)strm->stream.mode != smm_string_output)
		FEerror("~S is not a string-output stream.", 1, strm);
	@(return strm->stream.object0)
@)

@(defun streamp (strm)
@
	@(return ((type_of(strm) == t_stream) ? Ct : Cnil))
@)

@(defun input_stream_p (strm)
@
	assert_type_stream(strm);
	@(return (input_stream_p(strm) ? Ct : Cnil))
@)

@(defun output_stream_p (strm)
@
	assert_type_stream(strm);
	@(return (output_stream_p(strm) ? Ct : Cnil))
@)

@(defun stream_element_type (strm)
@
	assert_type_stream(strm);
	@(return stream_element_type(strm))
@)

@(defun close (strm &key abort)
@
	assert_type_stream(strm);
	close_stream(strm, abort != Cnil);
	@(return Ct)
@)

@(defun open (filename
	      &key (direction Kinput)
		   (element_type Sbase_char)
		   (if_exists Cnil iesp)
		   (if_does_not_exist Cnil idnesp)
	      &aux strm)
	enum smmode smm;
@
	/* INV: open_stream() checks types */
	if (direction == Kinput) {
		smm = smm_input;
		if (!idnesp)
			if_does_not_exist = Kerror;
	} else if (direction == Koutput) {
		smm = smm_output;
		if (!iesp)
			if_exists = Knew_version;
		if (!idnesp) {
			if (if_exists == Koverwrite ||
			    if_exists == Kappend)
				if_does_not_exist = Kerror;
			else
				if_does_not_exist = Kcreate;
		}
	} else if (direction == Kio) {
		smm = smm_io;
		if (!iesp)
			if_exists = Knew_version;
		if (!idnesp) {
			if (if_exists == Koverwrite ||
			    if_exists == Kappend)
				if_does_not_exist = Kerror;
			else
				if_does_not_exist = Kcreate;
		}
	} else if (direction == Kprobe) {
		smm = smm_probe;
		if (!idnesp)
			if_does_not_exist = Cnil;
	} else
		FEerror("~S is an illegal DIRECTION for OPEN.",
			1, direction);
	strm = open_stream(filename, smm, if_exists, if_does_not_exist);
	@(return strm)
@)

@(defun file_position (file_stream &o position)
	int i;
@
	assert_type_stream(file_stream);
	if (Null(position)) {
		i = file_position(file_stream);
		if (i < 0)
			@(return Cnil)
		@(return `MAKE_FIXNUM(i)`)
	} else {
		if (position == Kstart)
			i = 0;
		else if (position == Kend)
			i = file_length(file_stream);
		else if (!FIXNUMP(position) ||
		    (i = fix((position))) < 0)
			FEerror("~S is an illegal file position~%\
for the file-stream ~S.",
				2, position, file_stream);
		if (file_position_set(file_stream, i) < 0)
			@(return Cnil)
		@(return Ct)
	}       
@)

@(defun file_length (strm)
	int i;
@
	assert_type_stream(strm);
	i = file_length(strm);
	@(return ((i < 0) ? Cnil : MAKE_FIXNUM(i)))
@)

@(defun open_stream_p (strm)
@
	assert_type_stream(strm);
	/* ANSI and Cltl2 specify that open-stream-p should work
	   on closed streams, and that a stream is only closed
	   when #'close has been applied on it */
	@(return (strm->stream.mode != smm_closed ? Ct : Cnil))
@)

@(defun si::get_string_input_stream_index (strm)
@
	assert_type_stream(strm);
	if ((enum smmode)strm->stream.mode != smm_string_input)
		FEerror("~S is not a string-input stream.", 1, strm);
	@(return MAKE_FIXNUM(strm->stream.int0))
@)

@(defun si::make_string_output_stream_from_string (strng)
	cl_object strm;
@
	if (type_of(strng) != t_string || !strng->string.hasfillp)
		FEerror("~S is not a string with a fill-pointer.", 1, strng);
	strm = alloc_object(t_stream);
	strm->stream.mode = (short)smm_string_output;
	strm->stream.file = NULL;
	strm->stream.object0 = strng;
	strm->stream.object1 = OBJNULL;
	strm->stream.int0 = strng->string.fillp;
	strm->stream.int1 = 0;
	@(return strm)
@)

@(defun si::copy_stream (in out)
@
	assert_type_stream(in);
	assert_type_stream(out);
	while (!stream_at_end(in))
		writec_stream(readc_stream(in), out);
	flush_stream(out);
	@(return Ct)
@)

void
init_file(void)
{
	cl_object standard_input;
	cl_object standard_output;
	cl_object standard;
	cl_object x;

	standard_input = alloc_object(t_stream);
	standard_input->stream.mode = (short)smm_input;
	standard_input->stream.file = stdin;
	standard_input->stream.object0 = Sbase_char;
	standard_input->stream.object1 = make_simple_string("stdin");
	standard_input->stream.int0 = 0;
	standard_input->stream.int1 = 0;

	standard_output = alloc_object(t_stream);
	standard_output->stream.mode = (short)smm_output;
	standard_output->stream.file = stdout;
	standard_output->stream.object0 = Sbase_char;
	standard_output->stream.object1= make_simple_string("stdout");
	standard_output->stream.int0 = 0;
	standard_output->stream.int1 = 0;

	terminal_io = standard
	= make_two_way_stream(standard_input, standard_output);
	register_root(&terminal_io);

	SYM_VAL(Vterminal_io) = standard;

	x = alloc_object(t_stream);
	x->stream.mode = (short)smm_synonym;
	x->stream.file = NULL;
	x->stream.object0 = Vterminal_io;
	x->stream.object1 = OBJNULL;
	x->stream.int0 = x->stream.int1 = 0;
	standard = x;

	SYM_VAL(Vstandard_input)  = standard;
	SYM_VAL(Vstandard_output) = standard;
	SYM_VAL(Verror_output) = standard;

	SYM_VAL(Vquery_io) = standard;
	SYM_VAL(Vdebug_io) = standard;
	SYM_VAL(Vtrace_output) = standard;

	SYM_VAL(siVignore_eof_on_terminal_io) = Cnil;
}
