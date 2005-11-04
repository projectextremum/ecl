;;;;  Copyright (c) 1984, Taiichi Yuasa and Masami Hagiya.
;;;;  Copyright (c) 1990, Giuseppe Attardi.
;;;;
;;;;    This program is free software; you can redistribute it and/or
;;;;    modify it under the terms of the GNU Library General Public
;;;;    License as published by the Free Software Foundation; either
;;;;    version 2 of the License, or (at your option) any later version.
;;;;
;;;;    See file '../Copyright' for full details.

(in-package "SYSTEM")

(defun   logical-pathname-translations (p) (si:pathname-translations p))
(defsetf logical-pathname-translations si:pathname-translations)

(defun load-logical-pathname-translations (host)
  "Search for a logical pathname named host, if not already defined. If already
   defined no attempt to find or load a definition is attempted and NIL is
   returned. If host is not already defined, but definition is found and loaded
   successfully, T is returned, else error."
  (declare (type string host)
           (values (member t nil)))
  (let ((*autoload-translations* nil))
    (unless (or (string-equal host "sys")
                (si::pathname-translations host))
      (with-open-file (in-str (make-pathname :defaults "sys:"
                                             :name (string-downcase host)
                                             :type "translations"))
        (if *load-verbose*
            (format *error-output*
                    ";; Loading pathname translations from ~A~%"
                    (namestring (truename in-str))))
        (setf (logical-pathname-translations host) (read in-str)))
      t)))

(defun do-time (closure)
  (let* ((real-start (get-internal-real-time))
	 (run-start (get-internal-run-time))
	 #-boehm-gc (gc-start (si::gc-time))
	 real-end
	 run-end
	 gc-end)
    (multiple-value-prog1
	(funcall closure)
      (setq run-end (get-internal-run-time)
	    real-end (get-internal-real-time))
      #-boehm-gc
      (setq gc-end (si::gc-end))
      (fresh-line *trace-output*)
      (format *trace-output*
       #-boehm-gc
             "real time : ~,3F secs~%~
              run time  : ~,3F secs~%~
              GC time   : ~,3F secs~%"
       #+boehm-gc
             "real time : ~,3F secs~%~
              run time  : ~,3F secs~%"
       (/ (- real-end real-start) internal-time-units-per-second)
       (/ (- run-end run-start) internal-time-units-per-second)
       #-boehm-gc(/ (- gc-end gc-start) internal-time-units-per-second)))))

(defmacro time (form)
  "Syntax: (time form)
Evaluates FORM, outputs the realtime and runtime used for the evaluation to
*TRACE-OUTPUT*, and then returns all values of FORM."
  `(do-time #'(lambda () ,form)))

(defun leap-year-p (y)
  (declare (si::c-local))
  (and (zerop (mod y 4))
       (or (not (zerop (mod y 100))) (zerop (mod y 400)))))

(defun number-of-days-from-1900 (y)
  (declare (si::c-local))
  (let ((y1 (1- y)))
    (+ (* (- y 1900) 365)
       (floor y1 4) (- (floor y1 100)) (floor y1 400)
       -460)))

(defconstant month-startdays #(0 31 59 90 120 151 181 212 243 273 304 334 365))

#-ecl-min
(ffi:clines "
#include <time.h>
")

#-ecl-min
(defun get-local-time-zone ()
  "Returns the number of hours West of Greenwich for the local time zone."
  (declare (si::c-local))
  (ffi::c-inline () () :object "
{
  cl_fixnum mw;
#ifdef HAVE_TZSET
  tzset();
  mw = timezone/60;
#else
  struct tm ltm, gtm;
  time_t when = 0L;

  ltm = *localtime(&when);
  gtm = *gmtime(&when);

  mw = (gtm.tm_min + 60 * gtm.tm_hour) - (ltm.tm_min + 60 * ltm.tm_hour);

  if ((gtm.tm_wday + 1) % 7 == ltm.tm_wday)
    mw -= 24*60;
  else if (gtm.tm_wday == (ltm.tm_wday + 1) % 7)
    mw += 24*60;
#endif
  @(return) = make_ratio(MAKE_FIXNUM(mw),MAKE_FIXNUM(60));
}"
		 :one-liner nil))

(defun recode-universal-time (sec min hour day month year tz dst)
  (declare (si::c-local))
  (let ((days (+ (if (and (leap-year-p year) (> month 2)) 1 0)
		 (1- day)
		 (svref month-startdays (1- month))
		 (number-of-days-from-1900 year))))
    (+ sec (* 60 (+ min (* 60 (+ tz dst hour (* 24 days))))))))

(defun daylight-saving-time-p (sec min hour day month year tz dst)
  "Returns T if Daylight Saving Time applies to the local time zone at
Universal Time UT, which defaults to the current time."
  (declare (si::c-local))
  (cond ((< 2004 year)
	 (setf year 2004))
	((< year 1970)
	 (setf year 1970)))
  #-ecl-min
  (ffi::c-inline ((recode-universal-time sec min hour day month year tz dst))
		 (:object) :bool "
{
	cl_object UTC = number_minus(#0, cl_core.Jan1st1970UT);
	time_t when = object_to_fixnum(UTC);
	struct tm *ltm = localtime(&when);
	@(return) = ltm->tm_isdst;
}"
		 :one-liner nil))

(defun decode-universal-time (orig-ut &optional (tz nil tz-p) &aux (dstp nil))
  "Args: (integer &optional (timezone (si::get-local-time-zone)))
Returns as nine values the day-and-time represented by INTEGER.  See GET-
DECODED-TIME."
(loop
  (let* ((ut orig-ut) sec min hour day month year dow days)
    (unless tz
      (setq tz (get-local-time-zone)))
    (decf ut (round (* (+ tz (if dstp -1 0)) 3600)))
    (multiple-value-setq (ut sec) (floor ut 60))
    (multiple-value-setq (ut min) (floor ut 60))
    (multiple-value-setq (days hour) (floor ut 24))
    (setq dow (mod days 7))
    (setq year (+ 1900 (floor days 366))) ; Guess!
    (do ((x))
        ((< (setq x (- days (number-of-days-from-1900 year)))
            (if (leap-year-p year) 366 365))
         (setq day (1+ x)))
      (incf year))
    (when (leap-year-p year)
      (cond ((= day 60) (setf month 2 day 29))
	    ((> day 60) (decf day))))
    (unless month
      (setq month (position day month-startdays :test #'<=)
	    day (- day (svref month-startdays (1- month)))))
    (if (and (not tz-p)
	     (daylight-saving-time-p sec min hour day month year tz -1))
	(setf tz-p t dstp t)
	(return (values sec min hour day month year dow dstp tz))))))

(defun encode-universal-time (sec min hour day month year &optional tz)
  "Args: (second minute hour date month year
       &optional (timezone (si::get-local-time-zone)))
Returns an integer that represents the given day-and-time.  See
GET-DECODED-TIME."
  (when (<= 0 year 99)
    ;; adjust to year in the century within 50 years of this year
    (multiple-value-bind (sec min hour day month this-year dow dstp tz)
	(get-decoded-time)
      (declare (ignore sec min hour day month dow dstp tz))
      (incf year (* 100 (ceiling (- this-year year 50) 100)))))
  (let ((dst 0))
    (unless tz
      (setq tz (rational (get-local-time-zone)))
      (when (daylight-saving-time-p sec min hour day month year tz -1)
	;; assume DST applies, and check if at corresponging UT it applies.
	;; There is an ambiguity between midnight and 1 o'clock on the day
	;; when time reverts from DST to solar:
	;; 12:01 on that day could be either 11:01 UT (before the switch) or
	;; 12:01 UT (after the switch). We opt for the former.
	(setf dst -1)))
    (recode-universal-time sec min hour day month year tz dst)))

(defun get-universal-time ()
  #-ecl-min
  (ffi:c-inline () () :object "
{
	cl_object utc = make_integer(time(0));
	@(return) = number_plus(utc, cl_core.Jan1st1970UT);
}"
		:one-liner nil))

(defun get-decoded-time ()
  "Args: ()
Returns the current day-and-time as nine values:
	second (0 - 59)
	minute (0 - 59)
	hour (0 - 23)
	date (1 - 31)
	month (1 - 12)
	year (Christian, not Japanese long-live-Emperor)
	day of week (0 for Mon, .. 6 for Sun)
	summer time or not (T or NIL)
	time zone (-9 in Japan)
Sunday is the *last* day of the week!!"
  (decode-universal-time (get-universal-time)))

(defun ensure-directories-exist (a-pathname &key verbose)
  (let* ((created nil)
	 d)
    (when (or (wild-pathname-p a-pathname :directory)
	      (wild-pathname-p a-pathname :host)
	      (wild-pathname-p a-pathname :device))
      (error 'file-error :pathname a-pathname))
    (dolist (item (pathname-directory a-pathname))
      (setf d (nconc d (list item)))
      (let ((p (make-pathname :name nil :type nil :directory d
			      :defaults a-pathname)))
	(unless (or (symbolp item) (si::file-kind p nil))
	  (setf created t)
	  (when verbose
	    (format t "~%;;; Making directory ~A" p))
	  (si::mkdir p #o777))))
    (values a-pathname created)))

(defmacro with-hash-table-iterator ((iterator package) &body body)
  `(let ((,iterator (hash-table-iterator ,package)))
    (macrolet ((,iterator () (list 'funcall ',iterator)))
      ,@body)))

(defun sharp-!-reader (stream subchar arg)
  (read-line stream)
  (values))

(set-dispatch-macro-character #\# #\! 'sharp-!-reader)

(defun si::simple-program-error (message &rest datum)
  (signal-simple-error 'program-error nil message datum))
