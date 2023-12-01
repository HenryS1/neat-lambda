(in-package :neat-lambda)

(defun find-arg-number (arg)
  (parse-integer (subseq (symbol-name arg) 1) :junk-allowed t))

(defun sort-by-number (a b) 
  (< (find-arg-number a)
     (find-arg-number b)))

(defun check-args-are-numbered (args)
  (loop for arg in args 
        when (not (find-arg-number arg))
          do (error "When multiple arguments are provided they must each start with a unique number. This argument doesn't: ~a" arg)))

(defun find-args (exp)
  (labels ((rec (e acc)
             (cond ((and (symbolp e) (char= (aref (symbol-name e) 0) #\%))
                    (adjoin e acc)) 
                   ((consp e)
                    (let ((args (rec (car e) acc)))
                      (rec (cdr e) args)))
                   (t (if (> (length acc) 1)
                          (progn (check-args-are-numbered acc)
                                 (sort acc #'sort-by-number))
                          acc)))))
      (rec exp nil)))

(defun expand-lambda (exp)
  (let ((args (find-args exp)))
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
