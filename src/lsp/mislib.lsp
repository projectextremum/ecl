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

(eval-when (compile) (proclaim '(optimize (safety 2) (space 3))))

(defun   logical-pathname-translations (p) (si:pathname-translations p))
(defsetf logical-pathname-translations si:pathname-translations)

(defmacro time (form)
  (let ((real-start (gentemp))
	(real-end (gentemp))
	(run-start (gentemp))
	(run-end (gentemp))
	(gc-start (gentemp))
	(gc-end (gentemp))
	(x (gentemp)))
    `(let ((,real-start (get-internal-real-time))
	   (,run-start (get-internal-run-time))
	   #-boehm-gc(,gc-start (sys:gc-time))
	   ,real-end ,run-end ,gc-end ,x)
      (setq ,x (multiple-value-list ,form))
      (setq ,run-end (get-internal-run-time))
      (setq ,real-end (get-internal-real-time))
      #-boehm-gc(setq ,gc-end (sys:gc-time))
      (fresh-line *trace-output*)
      (format *trace-output*
       #-boehm-gc
             "real time : ~,3F secs~%~
              run time  : ~,3F secs~%~
              GC time   : ~,3F secs~%"
       #+boehm-gc
             "real time : ~,3F secs~%~
              run time  : ~,3F secs~%"
       (/ (- ,real-end ,real-start) internal-time-units-per-second)
       (/ (- ,run-end ,run-start) internal-time-units-per-second)
       #-boehm-gc(/ (- ,gc-end ,gc-start) internal-time-units-per-second))
      (values-list ,x))))


(defconstant seconds-per-day #.(* 24 3600))

(defun leap-year-p (y)
  (and (zerop (mod y 4))
       (or (not (zerop (mod y 100))) (zerop (mod y 400)))))

(defun number-of-days-from-1900 (y)
  (let ((y1 (1- y)))
    (+ (* (- y 1900) 365)
       (floor y1 4) (- (floor y1 100)) (floor y1 400)
       -460)))

(defconstant month-startdays #(0 31 59 90 120 151 181 212 243 273 304 334 365))

(defun decode-universal-time (ut &optional tz)
  (let (sec min hour day month year dow days dstp)
    (unless tz
      (setq tz (get-local-time-zone)
	    dstp (daylight-saving-time-p ut)))
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
      (when (= day 60)
	(return-from decode-universal-time
	  (values sec min hour 29 2 year dow dstp tz)))
      (when (> day 60) (decf day)))
    (setq month (position day month-startdays :test #'<=)
	  day (- day (svref month-startdays (1- month))))
    (values sec min hour day month year dow dstp tz)))

(defun encode-universal-time (sec min h d m y &optional tz)
  (when (<= 0 y 99)
    ;; adjust to year in the century within 50 years of this year
    (multiple-value-bind (sec min h d m this-year dow dstp tz)
	(get-decoded-time)
      (declare (ignore sec min h d m dow dstp tz))
      (incf y (* 100 (ceiling (- this-year y 50) 100)))))
  (when (and (leap-year-p y) (> m 2))
    (incf d))
  (let* ((hours (+ (* 24 (+ (number-of-days-from-1900 y)
			    (svref month-startdays (1- m)) (1- d))) h))
	 (dst 0))
    (unless tz
      (setq tz (rational (get-local-time-zone)))
      (when (daylight-saving-time-p
	     (+ sec (* 60 (+ min (* 60 (+ tz -1 hours))))))
	;; assume DST applies, and check if at corresponging UT it applies.
	;; There is an ambiguity between midnight and 1 o'clock on the day
	;; when time reverts from DST to solar:
	;; 12:01 on that day could be either 11:01 UT (before the switch) or
	;; 12:01 UT (after the switch). We opt for the former.
	(setq dst -1)))
    (+ sec (* 60 (+ min (* 60 (+ tz dst hours)))))))
