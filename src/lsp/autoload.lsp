;;;;  Copyright (c) 1984, Taiichi Yuasa and Masami Hagiya.
;;;;  Copyright (c) 1990, Giuseppe Attardi.
;;;;
;;;;    This program is free software; you can redistribute it and/or
;;;;    modify it under the terms of the GNU Library General Public
;;;;    License as published by the Free Software Foundation; either
;;;;    version 2 of the License, or (at your option) any later version.
;;;;
;;;;    See file '../Copyright' for full details.



;;; Program Development Environment

(in-package "SYSTEM")

#+PDE
(progn
(setq *record-source-pathname-p* nil)
(defun record-source-pathname (symbol type)
  ;; type is either:
  ;; 1. a symbol, for single entry definitions (defun, defvar, defclass ..)
  ;; 2. a list (type . spec), for multiple entries (defmethod)
  (when (and *record-source-pathname-p*
	     *source-pathname*)
    (when (sys::setf-namep symbol)
       (setq symbol (get-sysprop (second symbol) 'setf-symbol)))
    (if (symbolp type)
	(put-sysprop symbol *source-pathname* type)
	(let* ((alist (get-sysprop symbol (car type)))
	       (spec (cdr type)))
	  (if alist
	      (let ((entry (assoc spec alist :test #'equal)))
		(if entry
		    (setf (cdr entry) *source-pathname*)
		    (push (cons spec *source-pathname*) alist)))
	      (setq alist (list (cons spec *source-pathname*))))
	  (put-sysprop symbol alist (car type))))))
)

(defun lisp-implementation-type ()
  "Args: ()
Returns the string \"ECL\"."
  "ECL")

;;; Compiler functions.

(defvar *compile-file-pathname* nil)

(defvar *compile-file-truename* nil)

(defun autoload (pathname &rest function-names)
  (dolist (fname function-names)
    (let ((thename fname))
      (fset fname #'(lambda (&rest args)
		      (load pathname)
		      (apply thename args))))))

(unless (fboundp 'compile)
(defun proclaim (d)
  "Args: (decl-spec)
Gives a global declaration.  See DECLARE for possible DECL-SPECs."
  (when (eq (car d) 'SPECIAL) (mapc #'sys::*make-special (cdr d))))

(autoload "SYS:cmp" 'compile-file 'compile 'compile-file-pathname 'disassemble)
)

(defmacro with-compilation-unit (options &rest body)
  `(progn ,@body))

;;; Editor.

(defun ed (&optional filename)
  "Args: (&optional filename)
Invokes the editor.  The action depends on the version of ECL.  See the ECL
Report for details."
  (si:system (format nil "~S ~A" (si::getenv "EDITOR") filename)))


;;; Allocator.

(defvar *type-list*
        '(cons
          ;; fixnum Beppe
	  fixnum char
	  bignum ratio short-float long-float complex
          symbol package hash-table
          array vector string bit-vector
          stream random-state readtable pathname
          bytecodes cfun cclosure
	  #-clos structure #+clos instance #+clos generic-function
	  #+threads cont #+threads thread))

#-boehm-gc
(defun room (&optional x)
  "Args: (&optional (x t))
Displays information about storage allocation in the following format.
	* for each type class
		* number of pages so-far allocated for the type class
		* maximum number of pages for the type class
		* percentage of used cells to cells so-far allocated
		* number of times the garbage collector has been called to
		  collect cells of the type class
		* implementation types that belongs to the type class
	* number of pages actually allocated for contiguous blocks
	* maximum number of pages for contiguous blocks
	* number of times the garbage collector has been called to collect
	  contiguous blocks
	* number of pages in the hole
	* total number of pages allocated for cells
	* total number of pages allocated
	* number of available pages
	* number of pages ECL can use.
The number of times the garbage collector has been called is not shown, if the
number is zero.  The optional X is simply ignored."
  (let* (npage info-list link-alist)
    (multiple-value-bind
	  (maxpage leftpage ncbpage maxcbpage ncb cbgbccount
		   holepage l)
	(sys::room-report)

      (do ((l l (nthcdr 5 l))
	   (tl *type-list* (cdr tl))
	   (i 0 (+ i (if (nth 2 l) (nth 2 l) 0))))
	  ((null l) (setq npage i))
	(let* ((typename (car tl))
	       (nused (nth 0 l))
	       (nfree (nth 1 l))
	       (npage (nth 2 l))
	       (maxpage (nth 3 l))
	       (gbccount (nth 4 l)))
	  (if nused
	      (push (list typename npage maxpage
			  (if (zerop (+ nused nfree))
			      0
			      (/ nused 0.01 (+ nused nfree)))
			  (if (zerop gbccount) nil gbccount))
		    info-list)
	      (let ((a (assoc (nth nfree *type-list*) link-alist)))
		(if a
		    (nconc a (list typename))
		    (push (list (nth nfree *type-list*) typename)
			  link-alist))))))
      (dolist (info (nreverse info-list))
	(apply #'format t "~4D/~D~10T~5,1F%~@[~3D~]~20T~{~A~^ ~}"
	       (append (cdr info)
		       (if  (assoc (car info) link-alist)
			    (list (assoc (car info) link-alist))
			    (list (list (car info))))))
	(terpri)
	)
      (terpri)
      (format t "~4D/~D~16T~@[~3D~]~20Tcontiguous (~D blocks)~%"
	      ncbpage maxcbpage (if (zerop cbgbccount) nil cbgbccount) ncb)
      (format t "~5T~D~20Thole~%" holepage)
      (format t "~5D pages for cells~%" npage)
      (format t "~5D total pages~%" (+ npage ncbpage holepage))
      (format t "~5D pages available~%" leftpage)
      (format t "~5D pages in heap but not gc'd + pages needed for gc marking~%"
	      (- maxpage (+ npage ncbpage holepage leftpage)))
      (format t "~5D maximum pages~%" maxpage)
      (values)
      )))


;;; Help.

(in-package "SYSTEM")

(defun help (&optional (symbol nil s))
  "Args: (&optional symbol)
ECL specific.
Prints the documentation associated with SYMBOL.  With no args, prints the
greeting message to ECL beginners."
  (if s (sys::print-doc symbol)
      (progn
        (princ "
Welcome to ECL. Here are the few functions you should learn first.

	(HELP symbol) prints the online documentation associated with the
	symbol.  For example, (HELP 'CONS) will print the useful information
	about the CONS function, the CONS data type, and so on.

	(HELP* string) prints the online documentation associated with those
	symbols whose print-names have the string as substring.  For example,
	(HELP* \"PROG\") will print the documentation of the symbols such as
	PROG, PROGN, and MULTIPLE-VALUE-PROG1.

	(BYE) ends the current ECL session.

For the precise language specification, refere to Guy Steele's \"Common Lisp,
the Language\" and our \"ECL Manual\".  \"ECL Dictionary\", the hard-copied
version of ECL online documentation, will be useful as a handbook.

Good luck!
")
        (values))))

(defun help* (string &optional (package (find-package "CL")))
  "Args: (string &optional (package-spec 'lisp))
ECL specific.
Prints the documentation associated with those symbols in the specified
package whose print names contain STRING as substring.  STRING may be a
symbol, in which case the print-name of that symbol is used.  If PACKAGE is
NIL, then all packages are searched."
  (sys::apropos-doc string package))

;;; Pretty-print-formats.
;;;
;;;	The number N as the property of a symbol SYMBOL indicates that,
;;;	in the form (SYMBOL f1 ... fN fN+1 ... fM), the subforms fN+1,...,fM
;;;	are the 'body' of the form and thus are treated in a special way by
;;;	the ECL pretty-printer.

;;; (At boot we don't have setf yet)

(mapc #'(lambda (x) (put-sysprop (first x) 'sys::pretty-print-format (second x)))
      '((block 1)
	(case 1)
	(catch 1)
	(ccase 1)
	(clines 0)
	(compiler-let 1)
	(cond 0)
	(ctypecase 1)
	(defcfun 2)
	(define-setf-method 2)
	(defla 2)
	(defmacro 2)
	(defsetf 3)
	(defstruct 1)
	(deftype 2)
	(defun 2)
	(do 2)
	(do* 2)
	(do-symbols 1)
	(do-all-symbols 1)
	(do-external-symbols 1)
	(dolist 1)
	(dotimes 1)
	(ecase 1)
	(etypecase 1)
	(eval-when 1)
	(flet 1)
	(labels 1)
	(lambda 1)
	(lambda-block 2)
	(let 1)
	(let* 1)
	(locally 0)
	(loop 0)
	(macrolet 1)
	(multiple-value-bind 2)
	(multiple-value-prog1 1)
	(prog 1)
	(prog* 1)
	(prog1 1)
	(prog2 2)
	(progn 0)
	(progv 2)
	(return 0)
	(return-from 1)
	(tagbody 0)
	(the 1)
	(throw 1)
	(typecase 1)
	(unless 1)
	(unwind-protect 0)
	(when 1)
	(with-input-from-string 1)
	(with-open-file 1)
	(with-open-stream 1)
	(with-output-to-string 1)
#+clos	(defclass 2)
#+clos	(defmethod 2)
#+clos	(symbol-macrolet 2)
#+clos	(with-accessors 2)
#+clos	(with-slots 2)))

;;; Import functions which are useful for user interaction

(in-package "CL-USER")
(import '(sys::help sys::help* #-boehm-gc sys::room sys::gc))
