(in-package "SYSTEM")
(proclaim '(FUNCTION DEFMACRO* (T T T) T))
(proclaim '(FUNCTION DM-VL (T T T) T))
(proclaim '(FUNCTION DM-V (T T) T))
(proclaim '(FUNCTION DM-NTH (T T) T))
(proclaim '(FUNCTION DM-NTH-CDR (T T) T))
(proclaim '(FUNCTION DM-BAD-KEY (T) T))
(proclaim '(FUNCTION DM-KEY-NOT-ALLOWED (T) T))
;(proclaim '(FUNCTION FIND-DOC (T T) T))
;(proclaim '(FUNCTION FIND-DECLARATIONS (T) T))
(proclaim '(FUNCTION CLEAR-COMPILER-PROPERTIES (T) T))
(proclaim '(FUNCTION TERMINAL-INTERRUPT (T) T))
(proclaim '(FUNCTION BREAK-LEVEL (T T) T))
(proclaim '(FUNCTION TPL-MAKE-COMMAND (T T) T))
(proclaim '(FUNCTION TPL-PARSE-STRINGS (T) T))
(proclaim '(FUNCTION TPL-PRINT (T) T))
(proclaim '(FUNCTION TPL-UNKNOWN-COMMAND (T) T))
(proclaim '(FUNCTION TPL-GO (T) T))
(proclaim '(FUNCTION PRINT-IHS (T) T))
(proclaim '(FUNCTION PRINT-FRS (T) T))
(proclaim '(FUNCTION FRS-KIND (T) T))
(proclaim '(FUNCTION TPL-HIDE (T) T))
(proclaim '(FUNCTION TPL-UNHIDE (T) T))
(proclaim '(FUNCTION TPL-UNHIDE-PACKAGE (T) T))
(proclaim '(FUNCTION TPL-HIDE-PACKAGE (T) T))
(proclaim '(FUNCTION IHS-VISIBLE (T) T))
(proclaim '(FUNCTION IHS-FNAME (T) T))
(proclaim '(FUNCTION IHS-COMPILED-P (T) T))
(proclaim '(FUNCTION SUPER-GO (T T) T))
(proclaim '(FUNCTION TPL-BACKWARD-SEARCH (T) T))
(proclaim '(FUNCTION TPL-FORWARD-SEARCH (T) T))
(proclaim '(FUNCTION PROVIDE (T) T))
(proclaim '(FUNCTION DOCUMENTATION (T T) T))
(proclaim '(FUNCTION FIND-DOCUMENTATION (T) T))
(proclaim '(FUNCTION SIMPLE-ARRAY-P (T) T))
(proclaim '(FUNCTION TYPEP (T T) T))
(proclaim '(FUNCTION SUBCLASSP (T T) T))
(proclaim '(FUNCTION NORMALIZE-TYPE (T) T))
(proclaim '(FUNCTION KNOWN-TYPE-P (T) T))
(proclaim '(FUNCTION SUBTYPEP (T T) T))
(proclaim '(FUNCTION SUB-INTERVAL-P (T T) T))
(proclaim '(FUNCTION IN-INTERVAL-P (T T) T))
(proclaim '(FUNCTION MATCH-DIMENSIONS (T T) T))
(proclaim '(FUNCTION COERCE (T T) T))
(proclaim '(FUNCTION CLEAR-COMPILER-PROPERTIES (T) T))
(proclaim '(FUNCTION GET-SETF-METHOD (T) T))
(proclaim '(FUNCTION GET-SETF-METHOD-MULTIPLE-VALUE (T) T))
(proclaim '(FUNCTION SETF-EXPAND-1 (T T T) T))
(proclaim '(FUNCTION SETF-EXPAND (T T) T))
(proclaim '(FUNCTION INCREMENT-CURSOR (T T) T))
(proclaim '(FUNCTION SEQUENCE-CURSOR (T T) T))
(proclaim '(FUNCTION ARRAY-DIMENSIONS (T) T))
(proclaim '(FUNCTION VECTOR-PUSH (T T) T))
(proclaim '(FUNCTION VECTOR-POP (T) T))
(proclaim '(FUNCTION ASK-FOR-FORM (T) T))
(proclaim '(FUNCTION TYPECASE-ERROR-STRING (T T T) T))
(proclaim '(FUNCTION TYPECASE-ERROR-STRINGS (T) T))
(proclaim '(FUNCTION BOIN-P (T) T))
(proclaim '(FUNCTION MAKE-ACCESS-FUNCTION (T T T T T T T T T) T))
(proclaim '(FUNCTION MAKE-CONSTRUCTOR (T T T T T) T))
(proclaim '(FUNCTION MAKE-COPIER (T T T T) T))
(proclaim '(FUNCTION MAKE-PREDICATE (T T T T T) T))
(proclaim '(FUNCTION PARSE-SLOT-DESCRIPTION (T T) T))
(proclaim '(FUNCTION OVERWRITE-SLOT-DESCRIPTIONS (T T) T))
(proclaim '(FUNCTION SHARP-S-READER (T T T) T))
(proclaim '(FUNCTION READ-INSPECT-COMMAND (T T T) T))
(proclaim '(FUNCTION INSPECT-SYMBOL (T) T))
(proclaim '(FUNCTION INSPECT-PACKAGE (T) T))
(proclaim '(FUNCTION INSPECT-CHARACTER (T) T))
(proclaim '(FUNCTION INSPECT-NUMBER (T) T))
(proclaim '(FUNCTION INSPECT-CONS (T) T))
(proclaim '(FUNCTION INSPECT-STRING (T) T))
(proclaim '(FUNCTION INSPECT-VECTOR (T) T))
(proclaim '(FUNCTION INSPECT-ARRAY (T) T))
(proclaim '(FUNCTION INSPECT-OBJECT (T) T))
(proclaim '(FUNCTION DESCRIBE (T) T))
(proclaim '(FUNCTION INSPECT (T) T))
(proclaim '(FUNCTION ARG-LIST (T) T))
(proclaim '(FUNCTION PRIN1-TO-STRING (T) T))
(proclaim '(FUNCTION PRINC-TO-STRING (T) T))
(proclaim '(FUNCTION SHARP-A-READER (T T T) T))
(proclaim '(FUNCTION SHARP-S-READER-SI (T T T) T))
(proclaim '(FUNCTION LEAP-YEAR-P (T) T))
(proclaim '(FUNCTION NUMBER-OF-DAYS-FROM-1900 (T) T))
(proclaim '(FUNCTION ISQRT (T) T))
(proclaim '(FUNCTION ABS (T) T))
(proclaim '(FUNCTION PHASE (T) T))
(proclaim '(FUNCTION SIGNUM (T) T))
(proclaim '(FUNCTION CIS (T) T))
(proclaim '(FUNCTION ASIN (T) T))
(proclaim '(FUNCTION ACOS (T) T))
(proclaim '(FUNCTION SINH (T) T))
(proclaim '(FUNCTION COSH (T) T))
(proclaim '(FUNCTION TANH (T) T))
(proclaim '(FUNCTION ASINH (T) T))
(proclaim '(FUNCTION ACOSH (T) T))
(proclaim '(FUNCTION ATANH (T) T))
(proclaim '(FUNCTION RATIONAL (T) T))
(proclaim '(FUNCTION RATIONALIZE (T) T))
(proclaim '(FUNCTION RATIONALIZE-FLOAT (T T) T))
(proclaim '(FUNCTION LOGNAND (T T) T))
(proclaim '(FUNCTION LOGNOR (T T) T))
(proclaim '(FUNCTION LOGANDC1 (T T) T))
(proclaim '(FUNCTION LOGANDC2 (T T) T))
(proclaim '(FUNCTION LOGORC1 (T T) T))
(proclaim '(FUNCTION LOGORC2 (T T) T))
(proclaim '(FUNCTION LOGNOT (T) T))
(proclaim '(FUNCTION LOGTEST (T T) T))
(proclaim '(FUNCTION BYTE (T T) T))
(proclaim '(FUNCTION BYTE-SIZE (T) T))
(proclaim '(FUNCTION BYTE-POSITION (T) T))
(proclaim '(FUNCTION LDB (T T) T))
(proclaim '(FUNCTION LDB-TEST (T T) T))
(proclaim '(FUNCTION MASK-FIELD (T T) T))
(proclaim '(FUNCTION DPB (T T T) T))
(proclaim '(FUNCTION DEPOSIT-FIELD (T T T) T))
(proclaim '(FUNCTION FIND-ALL-SYMBOLS (T) T))
(proclaim '(FUNCTION SUBSTRINGP (T T) T))
(proclaim '(FUNCTION PRINT-SYMBOL-APROPOS (T) T))
(proclaim '(FUNCTION SEQTYPE (T) T))
(proclaim '(FUNCTION CALL-TEST (T T T T) T))
(proclaim '(FUNCTION CHECK-SEQ-TEST (T T) T))
(proclaim '(FUNCTION CHECK-SEQ-START-END (T T) T))
(proclaim '(FUNCTION CHECK-SEQ-ARGS (T T T T) T))
(proclaim '(FUNCTION LIST-MERGE-SORT (T T T) T))
(proclaim '(FUNCTION QUICK-SORT (T FIXNUM FIXNUM T T) T))
(proclaim '(FUNCTION TRACE* (T) T))
(proclaim '(FUNCTION UNTRACE* (T) T))
(proclaim '(FUNCTION TRACE-ONE (T) T))
(proclaim '(FUNCTION UNTRACE-ONE (T) T))
(proclaim '(FUNCTION TRACING-BODY (T) T))
(proclaim '(FUNCTION STEP* (T) T))
(proclaim '(FUNCTION LOOP-TEQUAL (T T) T))
(proclaim '(FUNCTION LOOP-TMEMBER (T T) T))
(proclaim '(FUNCTION LOOP-TASSOC (T T) T))
(proclaim '(FUNCTION LOOP-NAMED-VARIABLE (T) T))
(proclaim '(FUNCTION PARSE-TYPE (T) T))
(proclaim '(FUNCTION LV-BIND (T T T) T))
(proclaim '(FUNCTION LV-SET (T) T))
(proclaim '(FUNCTION MERGE-INF (T T) T))
(proclaim '(FUNCTION SET-ITERATION (T) T))
(proclaim '(FUNCTION PARSE-FOR1 (T T T T T T) T))
(proclaim '(FUNCTION PARSE-LOOP-PATH (T) T))
(proclaim '(FUNCTION GET-ACC (T) T))
(proclaim '(FUNCTION PARSE-WHEN (T) T))
