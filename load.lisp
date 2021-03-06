(in-package #:hextml)

(defvar *load-package* (make-package '#:hextml-i18n-load))

(defun load-i18n-file (file &key (package *load-package*))
  (labels ((recurse (thing)
	     (etypecase thing
	       ((and symbol (not keyword))
		  `(env ,(string-downcase (symbol-name thing))))
	       (cons (cons (car thing) (mapcar #'recurse (cdr thing))))
	       (t thing))))
    (let ((*package* package))
      (with-open-file (in file)
	(collecting
	  (let (spec)
	    (while* (setf spec (read in nil nil))
	      (collect (eval `(cons ',(flet ((convert (thing)
					       (string-downcase (symbol-name thing))))
					(let ((name (car spec)))
					  (etypecase name
					    (symbol (convert name))
					    (cons (mapcar #'convert name)))))
				    (build-html (list ,@(mapcar #'recurse (cdr spec))))))))))))))
