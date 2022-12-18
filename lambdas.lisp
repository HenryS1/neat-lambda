(in-package :neat-lambda)

(defun sort-by-number (a b) 
  (< (parse-integer (subseq (symbol-name a) 1) :junk-allowed t)
     (parse-integer (subseq (symbol-name b) 1) :junk-allowed t)))

(defun find-args (exp)
  (labels ((rec (e acc)
             (cond ((and (symbolp e) (char= (aref (symbol-name e) 0) #\%))
                    (adjoin e acc)) 
                   ((consp e)
                    (let ((args (rec (car e) acc)))
                      (rec (cdr e) args)))
                   (t (if (> (length acc) 1)
                          (sort acc #'sort-by-number)
                          acc)))))
      (rec exp nil)))

(defmacro expand-lambda (exp)
  `(let ((args (find-args ,exp)))
    `(lambda ,args ,exp)))

(defun |#l-reader| (stream subchar arg)
  (declare (ignore subchar arg))
  (let ((exp (read stream)))
    (expand-lambda exp)))

(defmacro enable-lambda-syntax ()
  `(eval-when (:compile-toplevel :load-toplevel :execute)
     (defvar *previous-readtables* nil)
     (push *readtable* *previous-readtables*)
     (set-dispatch-macro-character #\# #\l #'|#l-reader|)))

(defmacro disable-lambda-syntax ()
  `(eval-when (:compile-toplevel :load-toplevel :execute)
     (setf *readtable* (pop *previous-readtables*))))
