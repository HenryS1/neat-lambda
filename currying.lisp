(defpackage :currying
  (:use :cl)
  (:export :enable-currying-syntax :disable-currying-syntax))

(in-package :currying)

(defun curry-function (exp)
  (let ((name (car exp))
        (used-args (cdr exp))
        (remaining-args (gensym)))
    `(lambda (&rest ,remaining-args)
       (apply #',name ,@used-args ,remaining-args))))

(defun |#p-reader| (stream subchar arg)
  (declare (ignore subchar arg))
  (let ((exp (read stream)))
    (curry-function exp)))

(defmacro enable-currying-syntax ()
  `(eval-when (:compile-toplevel :load-toplevel :execute)
     (defvar *previous-readtables* nil)
     (push *readtable* *previous-readtables*)
     (set-dispatch-macro-character #\# #\p #'|#p-reader|)))

(defmacro disable-currying-syntax ()
  `(eval-when (:compile-toplevel :load-toplevel :execute)
     (setf *readtable* (pop *previous-readtables*))))
