/*
    stacks.c -- Binding/History/Frame stacks.
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


#include "ecls.h"
#ifdef HAVE_SYS_RESOURCE_H
# include <sys/time.h>
# include <sys/resource.h>
#endif

#ifndef THREADS
size_t bds_size;
bds_ptr bds_org;
bds_ptr bds_limit;
bds_ptr bds_top;

size_t ihs_size;
ihs_ptr ihs_org;
ihs_ptr ihs_limit;
ihs_ptr ihs_top;

size_t frs_size;
frame_ptr frs_org;
frame_ptr frs_limit;
frame_ptr frs_top;
frame_ptr nlj_fr;
cl_object nlj_tag;

int *cs_org;
int *cs_limit;
size_t cssize;

int NValues;
cl_object Values[VSSIZE];
#endif

cl_object Kcatch, Kcatchall, Kprotect;

/********************* BINDING STACK ************************/

void
bds_overflow(void)
{
	--bds_top;
	if (bds_limit > bds_org + bds_size)
		error("bind stack overflow.");
	bds_limit += BDSGETA;
	FEerror("Bind stack overflow.", 0);
}

void
bds_unwind(bds_ptr new_bds_top)
{       register bds_ptr bds = bds_top;
	for (;  bds > new_bds_top;  bds--)
		SYM_VAL(bds->bds_sym) = bds->bds_val;
	bds_top = new_bds_top;
}

static bds_ptr
get_bds_ptr(cl_object x)
{
	bds_ptr p;

	if (FIXNUMP(x)) {
	  p = bds_org + fix(x);
	  if (bds_org <= p && p <= bds_top)
	    return(p);
	}
	FEerror("~S is an illegal bds index.", 1, x);
}

@(defun si::bds_top ()
@
	@(return MAKE_FIXNUM(bds_top - bds_org))
@)

@(defun si::bds_var (arg)
@
	@(return get_bds_ptr(arg)->bds_sym)
@)

@(defun si::bds_val (arg)
@
	@(return get_bds_ptr(arg)->bds_val)
@)

/******************** INVOCATION STACK **********************/

void
ihs_overflow(void)
{
	--ihs_top;
	if (ihs_limit > ihs_org + ihs_size)
		error("invocation history stack overflow.");
	ihs_limit += IHSGETA;
	FEerror("Invocation history stack overflow.", 0);
}

cl_object
ihs_function_name(cl_object x)
{
	cl_object y;

	switch (type_of(x)) {
	case t_symbol:
		return(x);

	case t_bytecodes:
		y = x->bytecodes.data[0];
		if (Null(y))
			return(Slambda);
		else
			return y;

	case t_cfun:
		return(x->cfun.name);

	default:
		return(Cnil);
	}
}

cl_object
ihs_top_function_name(void)
{
	cl_object x;
	ihs_ptr h = ihs_top;

	while (h >= ihs_org) {
		x = ihs_function_name(h->ihs_function);
		if (x != Cnil)
			return(x);
		h--;
	}
	return(Cnil);
}

/*
	Lisp interface to IHS
*/

static ihs_ptr
get_ihs_ptr(cl_object x)
{
	ihs_ptr p;

	if (FIXNUMP(x)) {
	  p = ihs_org + fix(x);
	  if (ihs_org <= p && p <= ihs_top)
	    return(p);
	}
	FEerror("~S is an illegal ihs index.", 1, x);
}

@(defun si::ihs_top ()
@
	@(return MAKE_FIXNUM(ihs_top - ihs_org))
@)

@(defun si::ihs_fun (arg)
@
	@(return get_ihs_ptr(arg)->ihs_function)
@)

@(defun si::ihs_env (arg)
	cl_object lex;
@
	lex = get_ihs_ptr(arg)->ihs_base;
	@(return CONS(car(lex),cdr(lex)))
@)

/********************** FRAME STACK *************************/

static int frame_id = 0;

cl_object
new_frame_id(void)
{
  return(MAKE_FIXNUM(frame_id++));
}

int
frs_overflow(void)		/* used as condition in list.d */
{
	--frs_top;
	if (frs_limit > frs_org + frs_size)
		error("frame stack overflow.");
	frs_limit += FRSGETA;
	FEerror("Frame stack overflow.", 0);
}

frame_ptr
_frs_push(register enum fr_class class, register cl_object val)
{
	if (++frs_top >= frs_limit) frs_overflow();
	frs_top->frs_lex = lex_env;
	frs_top->frs_bds_top = bds_top;
	frs_top->frs_class = class;
	frs_top->frs_val = val;
	frs_top->frs_ihs = ihs_top;
	frs_top->frs_sp = stack->vector.fillp;
	return frs_top;
}

void
unwind(frame_ptr fr, cl_object tag)
{
	nlj_fr = fr;
	nlj_tag = tag;
	while (frs_top != fr
		&& frs_top->frs_class == FRS_CATCH)
	  --frs_top;
	lex_env = frs_top->frs_lex;
	ihs_top = frs_top->frs_ihs;
	bds_unwind(frs_top->frs_bds_top);
	stack->vector.fillp = frs_top->frs_sp;
	ecls_longjmp(frs_top->frs_jmpbuf, 1);
	/* never reached */
}

frame_ptr
frs_sch (cl_object frame_id)
{
	frame_ptr top;

	for (top = frs_top;  top >= frs_org;  top--)
		if (top->frs_val == frame_id && top->frs_class == FRS_CATCH)
			return(top);
	return(NULL);
}

frame_ptr
frs_sch_catch(cl_object frame_id)
{
	frame_ptr top;

	for(top = frs_top;  top >= frs_org  ;top--)
	  if ((top->frs_val == frame_id && top->frs_class == FRS_CATCH)
	      || top->frs_class == FRS_CATCHALL)
	    return(top);
	return(NULL);
}

static frame_ptr
get_frame_ptr(cl_object x)
{
	frame_ptr p;

	if (FIXNUMP(x)) {
	  p = frs_org + fix(x);
	  if (frs_org <= p && p <= frs_top)
	    return(p);
	}
	FEerror("~S is an illegal frs index.", 1, x);
}

@(defun si::frs_top ()
@
	@(return MAKE_FIXNUM(frs_top - frs_org))
@)

@(defun si::frs_bds (arg)
@
	@(return MAKE_FIXNUM(get_frame_ptr(arg)->frs_bds_top - bds_org))
@)

@(defun si::frs_class (arg)
	enum fr_class c;
	cl_object output;
@
	c = get_frame_ptr(arg)->frs_class;
	if (c == FRS_CATCH) output = Kcatch;
	else if (c == FRS_PROTECT) output = Kprotect;
	else if (c == FRS_CATCHALL) output = Kcatchall;
	else FEerror("Unknown frs class was detected.", 0);
	@(return output)
@)

@(defun si::frs_tag (arg)
@
	@(return get_frame_ptr(arg)->frs_val)
@)

@(defun si::frs_ihs (arg)
@
	@(return MAKE_FIXNUM(get_frame_ptr(arg)->frs_ihs - ihs_org))
@)

@(defun si::sch_frs_base (fr ihs)
	frame_ptr x;
	ihs_ptr y;
@
	y = get_ihs_ptr(ihs);
	for (x = get_frame_ptr(fr); x <= frs_top && x->frs_ihs < y; x++);
	@(return ((x > frs_top) ? Cnil : MAKE_FIXNUM(x - frs_org)))
@)

/********************* INITIALIZATION ***********************/

@(defun si::reset_stack_limits ()
@
	if (bds_top < bds_org + (bds_size - 2*BDSGETA))
		bds_limit = bds_org + (bds_size - 2*BDSGETA);
	else
		error("can't reset bds_limit.");
	if (frs_top < frs_org + (bds_size - 2*FRSGETA))
		frs_limit = frs_org + (frs_size - 2*FRSGETA);
	else
		error("can't reset frs_limit.");
	if (ihs_top < ihs_org + (ihs_size - 2*IHSGETA))
		ihs_limit = ihs_org + (ihs_size - 2*IHSGETA);
	else
		error("can't reset ihs_limit.");
#ifdef DOWN_STACK
	if (&narg > cs_org - cssize + 16)
		cs_limit = cs_org - cssize;
#else
	if (&narg < cs_org + cssize - 16)
		cs_limit = cs_org + cssize;
#endif
	else
		error("can't reset cs_limit.");

	@(return Cnil)
@)

void
alloc_stacks(int *new_cs_org)
{
#ifdef THREADS
	Values = main_lpd.lwp_Values;
#endif

	frs_size = FRSSIZE + 2*FRSGETA;
	frs_org = alloc(frs_size * sizeof(*frs_org));
	frs_top = frs_org-1;
	frs_limit = &frs_org[frs_size - 2*FRSGETA];
	bds_size = BDSSIZE + 2*BDSGETA;
	bds_org = alloc(bds_size * sizeof(*bds_org));
	bds_top = bds_org-1;
	bds_limit = &bds_org[bds_size - 2*BDSGETA];
	ihs_size = IHSSIZE + 2*IHSGETA;
	ihs_org = alloc(ihs_size * sizeof(*ihs_org));
  	ihs_top = ihs_org-1;
	ihs_limit = &ihs_org[ihs_size - 2*IHSGETA];

	cs_org = new_cs_org;
#if defined(HAVE_SYS_RESOURCE_H) && defined(RLIMIT_STACK)
	{
	  struct rlimit rl;
	  getrlimit(RLIMIT_STACK, &rl);
	  cssize = rl.rlim_cur/4 - 4*CSGETA;
	}
#else
	cssize = CSSIZE;
#endif
#ifdef DOWN_STACK
	cs_limit = cs_org - cssize; /* in THREADS I'm assigning to the main thread clwp */
#else
	cs_limit = cs_org + cssize;
#endif
}
