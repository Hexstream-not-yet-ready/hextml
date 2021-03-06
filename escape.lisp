(in-package #:hextml)

;;;; Code stolen from CL-WHO!

(defparameter *escape-char-p*
  #'(lambda (char)
      (or (find char "<>&'\"")
          (> (char-code char) 127)))
  "Used by ESCAPE-STRING to test whether a character should be escaped.")


(defun escape-string (string &key (test *escape-char-p*))
  (declare (optimize speed))
  "Escape all characters in STRING which pass TEST. This function is
not guaranteed to return a fresh string.  Note that you can pass NIL
for STRING which'll just be returned."
  (let ((first-pos (position-if test string))
        ;(format-string (if (eq *html-mode* :xml) "&#x~x;" "&#~d;"))
	(format-string "&#~d;"))
    (if (not first-pos)
      ;; nothing to do, just return STRING
      string
      (with-output-to-string (s)
        (loop with len = (length string)
              for old-pos = 0 then (1+ pos)
              for pos = first-pos
                  then (position-if test string :start old-pos)
              ;; now the characters from OLD-POS to (excluding) POS
              ;; don't have to be escaped while the next character has to
              for char = (and pos (char string pos))
              while pos
              do (write-sequence string s :start old-pos :end pos)
                 (case char
                   ((#\<)
                     (write-sequence "&lt;" s))
                   ((#\>)
                     (write-sequence "&gt;" s))
                   ((#\&)
                     (write-sequence "&amp;" s))
                   ((#\')
                     (write-sequence "&#039;" s))
                   ((#\")
                     (write-sequence "&quot;" s))
                   (otherwise
                     (format s format-string (char-code char))))
              while (< (1+ pos) len)
              finally (unless pos
                        (write-sequence string s :start old-pos)))))))

(defun escape-string-minimal (string)
  "Escape only #\<, #\>, and #\& in STRING."
  (escape-string string :test #'(lambda (char) (find char "<>&"))))

(defun escape-string-minimal-plus-quotes (string)
  "Like ESCAPE-STRING-MINIMAL but also escapes quotes."
  (escape-string string :test #'(lambda (char) (find char "<>&'\""))))

(defun escape-string-iso-8859-1 (string)
  "Escapes all characters in STRING which aren't defined in
ISO-8859-1."
  (escape-string string :test #'(lambda (char)
                                  (or (find char "<>&'\"")
                                      (> (char-code char) 255)))))

(defun escape-string-all (string)
  "Escapes all characters in STRING which aren't in the 7-bit ASCII
character set."
  (escape-string string :test #'(lambda (char)
                                  (or (find char "<>&'\"")
                                      (> (char-code char) 127)))))