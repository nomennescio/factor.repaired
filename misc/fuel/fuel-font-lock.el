;;; fuel-font-lock.el -- font lock for factor code

;; Copyright (C) 2008, 2009 Jose Antonio Ortega Ruiz
;; See http://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages, fuel, factor
;; Start date: Wed Dec 03, 2008 21:40

;;; Comentary:

;; Font lock setup for highlighting Factor code.

;;; Code:

(require 'fuel-syntax)
(require 'fuel-base)

(require 'font-lock)


;;; Faces:

(defgroup fuel-faces nil
  "Faces used by FUEL."
  :group 'fuel
  :group 'faces)

(defmacro fuel-font-lock--defface (face def group doc)
  `(defface ,face (face-default-spec ,def)
     ,(format "Face for %s." doc)
     :group ',group
     :group 'fuel-faces
     :group 'faces))

(put 'fuel-font-lock--defface 'lisp-indent-function 1)

(defmacro fuel-font-lock--make-face (prefix def-prefix group face def doc)
  (let ((face (intern (format "%s-%s" prefix face)))
        (def (intern (format "%s-%s-face" def-prefix def))))
    `(fuel-font-lock--defface ,face ,def ,group ,doc)))

(defmacro fuel-font-lock--define-faces (prefix def-prefix group faces)
  (let ((setup (make-symbol (format "%s--faces-setup" prefix))))
  `(progn
     (defmacro ,setup ()
       (cons 'progn
             (mapcar (lambda (f) (append '(fuel-font-lock--make-face
                                      ,prefix ,def-prefix ,group) f))
                     ',faces)))
     (,setup))))

(fuel-font-lock--define-faces
 factor-font-lock font-lock factor-mode
 ((comment comment "comments")
  (constructor type  "constructors (<foo>)")
  (constant constant  "constants and literal values")
  (number constant  "integers and floats")
  (ratio constant  "ratios")
  (declaration keyword "declaration words")
  (parsing-word keyword  "parsing words")
  (setter-word function-name "setter words (>>foo)")
  (getter-word function-name "getter words (foo>>)")
  (stack-effect comment "stack effect specifications")
  (string string "strings")
  (symbol variable-name "name of symbol being defined")
  (type-name type "type names")
  (vocabulary-name constant "vocabulary names")
  (word function-name "word, generic or method being defined")))


;;; Font lock:

(defconst fuel-font-lock--font-lock-keywords
  `((,fuel-syntax--parsing-words-regex . 'factor-font-lock-parsing-word)
    (,fuel-syntax--brace-words-regex 1 'factor-font-lock-parsing-word)
    ("\\(P\\|SBUF\\)\"" 1 'factor-font-lock-parsing-word)
    (,fuel-syntax--stack-effect-regex . 'factor-font-lock-stack-effect)
    (,fuel-syntax--vocab-ref-regexp  2 'factor-font-lock-vocabulary-name)
    (,fuel-syntax--declaration-words-regex . 'factor-font-lock-declaration)
    (,fuel-syntax--word-definition-regex 2 'factor-font-lock-word)
    (,fuel-syntax--alias-definition-regex (1 'factor-font-lock-word)
                                          (2 'factor-font-lock-word))
    (,fuel-syntax--int-constant-def-regex 2 'factor-font-lock-constant)
    (,fuel-syntax--integer-regex . 'factor-font-lock-number)
    (,fuel-syntax--float-regex . 'factor-font-lock-number)
    (,fuel-syntax--ratio-regex . 'factor-font-lock-ratio)
    (,fuel-syntax--type-definition-regex 2 'factor-font-lock-type-name)
    (,fuel-syntax--method-definition-regex (1 'factor-font-lock-type-name)
                                           (2 'factor-font-lock-word))
    (,fuel-syntax--parent-type-regex 2 'factor-font-lock-type-name)
    (,fuel-syntax--constructor-regex . 'factor-font-lock-constructor)
    (,fuel-syntax--setter-regex . 'factor-font-lock-setter-word)
    (,fuel-syntax--getter-regex . 'factor-font-lock-getter-word)
    (,fuel-syntax--symbol-definition-regex 2 'factor-font-lock-symbol))
  "Font lock keywords definition for Factor mode.")

(defun fuel-font-lock--font-lock-setup (&optional keywords no-syntax)
  (set (make-local-variable 'comment-start) "! ")
  (set (make-local-variable 'parse-sexp-lookup-properties) t)
  (set (make-local-variable 'font-lock-comment-face) 'factor-font-lock-comment)
  (set (make-local-variable 'font-lock-string-face) 'factor-font-lock-string)
  (set (make-local-variable 'font-lock-defaults)
       `(,(or keywords 'fuel-font-lock--font-lock-keywords)
         nil nil nil nil
         ,@(if no-syntax nil
             (list (cons 'font-lock-syntactic-keywords
                         fuel-syntax--syntactic-keywords))))))


;;; Fontify strings as Factor code:

(defvar fuel-font-lock--font-lock-buffer
  (let ((buffer (get-buffer-create " *fuel font lock*")))
    (set-buffer buffer)
    (set-syntax-table fuel-syntax--syntax-table)
    (fuel-font-lock--font-lock-setup)
    buffer))

(defun fuel-font-lock--factor-str (str)
  (save-current-buffer
    (set-buffer fuel-font-lock--font-lock-buffer)
    (erase-buffer)
    (insert str)
    (let ((font-lock-verbose nil)) (font-lock-fontify-buffer))
    (buffer-string)))


(provide 'fuel-font-lock)
;;; fuel-font-lock.el ends here
