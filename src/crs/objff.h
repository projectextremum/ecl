/*
    Copyright (c) 1990, Giuseppe Attardi and William F. Schelter.

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    See file '../Copyright' for full details.
*/

/* format of a rsyms output file:

   struct lsymbol_table	(gives number of symbols, and sum of length of strings)
   addr, char[], addr, char[], ...
   This can be read since the addr is sizeof(int) and the char[] is null
   terminated, immediately followed by and addr...
   There are tab.n_symbols pairs occurring.

*/

struct lsymbol_table {
  unsigned int n_symbols;
  unsigned int tot_leng;
};

#ifdef COFF

# ifdef MSDOS
#  include <coff.h>
# else
#  include <filehdr.h>
#  include <aouthdr.h>
#  include <scnhdr.h>
#  include <syms.h>
#  include <reloc.h>
# endif MSDOS

# ifndef FILHDR
#  define FILHDR	struct header
# endif FILHDR

# undef N_BADMAG	/* checks AOUTHDR instead of FILHDR */

# ifdef __i386__
#  define N_BADMAG(x)	I386BADMAG(x)
# elif defined(hpux)
#  define N_BADMAG(x)	!(ISCOFF(x.a_magic))
# else
#  define N_BADMAG(x)	!(ISCOFF(x.f_magic))
# endif

# ifdef ECOFF
#  undef N_TXTOFF
# endif

# define N_TXTOFF(p)	section[0].s_scnptr
# define N_SYMOFF(x)	(x).f_symptr
# define NSYMS(x)	(x).f_nsyms

# ifdef apollo
#  define EXT_and_TEXT_BSS_DAT(p) \
 ((1 <= (p)->n_scnum) && ((p)->n_scnum <= 5) && (p)->n_sclass == C_EXT)
# elif defined(ECOFF)
#  define EXT_and_TEXT_BSS_DAT(p) 1
# else
#  define EXT_and_TEXT_BSS_DAT(p) \
 ((1 <= (p)->n_scnum) && ((p)->n_scnum <= 3) && (p)->n_sclass == C_EXT)
# endif apollo


# ifdef ECOFF
#  define SYMENT EXTR
#  define SYMESZ sizeof(SYMENT)
#  define SYM_VALUE(sym)	(sym).asym.value
#  define SYM_TYPE(psym)	(psym)->asym.st
#  define SYM_NAME(psym)	&string_table[(psym)->asym.iss]

/* 
  We must distinguish the following kind of symbols:

  External (ouside function bodies)
  	Defined (in this file)
		Static (declared static)
		Exported (non declared static)
	Undefined

  Unfortunately AS and GAS produce different symbol tables, so we find
  a common denominator as follows:

  External:			stNil || stGlobal || stProc || stStaticProc
	Undefined:		stGblobal || (stProc && scUndefined)
  	Defined:		!Undefined
		Static:		stNil || stStatic || stStaticProc
		Exported:	!Static
*/

#  define C_STAT	stNil: case stStatic: case stStaticProc
#  define C_EXT	stGlobal: case stProc
#  define EXT_UNDEF(p)   (SYM_TYPE(p) == stGlobal || \
			(SYM_TYPE(p) == stProc && (p)->asym.sc == scUndefined))
#  define EXT_EXPORTED(p) (SYM_TYPE(p) == stProc)
#  define NUM_AUX(p)	0

# else				/* !ECOFF */

#  define SYM_VALUE(sym)	(sym).n_value
#  define SYM_TYPE(psym)	(psym)->n_sclass
#  define SYM_NAME(psym) \
  (((psym)->n_zeroes == 0) ? \
	    &string_table[(psym)->n_offset] : \
               ((psym)->n_name[SYMNMLEN -1] ? \
		(strncpy(tem, (psym)->n_name, SYMNMLEN), (char *)tem) : \
		(psym)->n_name))

#  define EXT_UNDEF(p)	(((p)->n_scnum == 0) && (p)->n_sclass == C_EXT)

#  define NUM_AUX(p)	(p)->n_numaux

# endif ECOFF

# ifdef __GO32__
#  define n_name	e.e_name
#  define n_numaux	e_numaux
#  define n_offset	e.e.e_offset
#  define n_sclass	e_sclass
#  define n_scnum	e_scnum
#  define n_type	e_type
#  define n_value	e_value
#  define n_zeroes	e.e.e_zeroes
#  define SYMNMLEN	E_SYMNMLEN

#  define R_ABS		0
#  define R_RELBYTE	017
#  define R_RELWORD	020
#  define R_RELLONG	021
#  define R_PCRBYTE	022
#  define R_PCRWORD	023
#  define R_PCRLONG	024

#  define R_DIR32	06

# endif __GO32__

#endif COFF

/************************************************************************/

#ifdef ELF
# define ELF_TARGET_ALL
# include <elf.h>
# define FILHDR	Elf32_Ehdr
# define PRGHDR	Elf32_Phdr
# define SCNHDR	Elf32_Shdr
# define SYMENT	Elf32_Sym
#ifdef __NetBSD__
# define RELOC	Elf32_RelA
#else
# define RELOC  Elf32_Rela
#endif
# define N_BADMAG(h)	(ELFMAG0 != h.e_ident[0])
# ifdef __mips
# define EXT_and_TEXT_BSS_DAT(p) ((ELF32_ST_BIND(p->st_info) == STB_GLOBAL) \
				 && (p->st_shndx == text_index \
				     || p->st_shndx == data_index\
				     || p->st_shndx == bss_index \
				     || p->st_shndx == 0xff00 \
				     || p->st_shndx == STN_UNDEF))
# else
# define EXT_and_TEXT_BSS_DAT(p) ((ELF32_ST_BIND(p->st_info) == STB_GLOBAL \
				   || ELF32_ST_BIND(p->st_info) == STB_WEAK) \
				  && (p->st_shndx == text_index \
				      || p->st_shndx == data_index\
				      || p->st_shndx == bss_index \
				      || p->st_shndx == SHN_UNDEF))
# endif
# define SYM_NAME(p) string_table+(p->st_name)
# define SYM_VALUE(p) (p).st_value
#endif ELF


/************************************************************************/
#ifdef AOUT

# include AOUT

# define FILHDR		struct exec

# ifndef AIX
#  define SYMENT	struct nlist
# endif AIX

# ifdef hpux
#  define nlist nlist_
typedef struct syment {
	long	n_value;
	unsigned char	n_type;
	unsigned char	n_length;
	short	n_almod;
	short	n_unused;
	union { long n_strx;} n_un;
} SYMENT;
# endif hpux

# ifndef SYMENT
#  define SYMENT	struct syment
# endif SYMENT

# ifndef SYMESZ  
#  define SYMESZ	(sizeof(SYMENT))
# endif SYMESZ

# define SYM_VALUE(sym)	(sym).n_value

# ifndef SYMNMLEN
#  define SYMNMLEN	0	/* no symbols are directly in the table */
# endif SYMNMLEN

# ifdef hpux
#  define RELOC	struct r_info
# elif defined(__sparc__)
#  define RELOC	struct reloc_info_sparc
# else
#  define RELOC	struct relocation_info
# endif hpux

# ifdef hpux
#  define NSYMS(hdr)	count_symbols(&hdr, fp)
#  define N_SYMOFF(x)	LESYM_OFFSET(x)
#  define N_TRELOCOFF(x) RTEXT_OFFSET(x)
# else
#  define NSYMS(f)	((unsigned int)((f).a_syms/(sizeof(struct nlist))))
#  define N_TRELOCOFF(x) (N_TXTOFF(x) + (x).a_text + (x).a_data)
# endif hpux

# define EXT_UNDEF(p)	((p)->n_type == N_EXT)
# define EXT_and_TEXT_BSS_DAT(p) (((p)->n_type & N_EXT) && \
				 ((p)->n_type & (N_TEXT | N_DATA | N_BSS))) 
# define NUM_AUX(p)	0
# define SYM_TYPE(sym)	((sym)->n_type & N_TYPE)
# define N_SECTION(sym)	(SYM_TYPE(sym) & ~N_EXT)
# define SYM_NAME(x)	(string_table + (x)->n_un.n_strx)
# define C_EXT		N_UNDF
# define RELSZ		sizeof(RELOC)
# ifndef N_MAGIC
#  define N_MAGIC(x)	(x).a_magic
# endif
#endif AOUT
