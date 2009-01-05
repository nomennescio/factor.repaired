;;; fuel-listener.el --- starting the fuel listener

;; Copyright (C) 2008, 2009  Jose Antonio Ortega Ruiz
;; See http://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages

;;; Commentary:

;; Utilities to maintain and switch to a factor listener comint
;; buffer, with an accompanying major fuel-listener-mode.

;;; Code:

(require 'fuel-stack)
(require 'fuel-completion)
(require 'fuel-xref)
(require 'fuel-eval)
(require 'fuel-connection)
(require 'fuel-syntax)
(require 'fuel-base)

(require 'comint)


;;; Customization:

(defgroup fuel-listener nil
  "Interacting with a Factor listener inside Emacs."
  :group 'fuel)

(defcustom fuel-listener-factor-binary "~/factor/factor"
  "Full path to the factor executable to use when starting a listener."
  :type '(file :must-match t)
  :group 'fuel-listener)

(defcustom fuel-listener-factor-image "~/factor/factor.image"
  "Full path to the factor image to use when starting a listener."
  :type '(file :must-match t)
  :group 'fuel-listener)

(defcustom fuel-listener-use-other-window t
  "Use a window other than the current buffer's when switching to
the factor-listener buffer."
  :type 'boolean
  :group 'fuel-listener)

(defcustom fuel-listener-window-allow-split t
  "Allow window splitting when switching to the fuel listener
buffer."
  :type 'boolean
  :group 'fuel-listener)


;;; Fuel listener buffer/process:

(defvar fuel-listener--buffer nil
  "The buffer in which the Factor listener is running.")

(defun fuel-listener--buffer ()
  (if (buffer-live-p fuel-listener--buffer)
      fuel-listener--buffer
    (with-current-buffer (get-buffer-create "*fuel listener*")
      (fuel-listener-mode)
      (setq fuel-listener--buffer (current-buffer)))))

(defun fuel-listener--start-process ()
  (let ((factor (expand-file-name fuel-listener-factor-binary))
        (image (expand-file-name fuel-listener-factor-image))
        (comint-redirect-perform-sanity-check nil))
    (unless (file-executable-p factor)
      (error "Could not run factor: %s is not executable" factor))
    (unless (file-readable-p image)
      (error "Could not run factor: image file %s not readable" image))
    (message "Starting FUEL listener ...")
    (pop-to-buffer (fuel-listener--buffer))
    (make-comint-in-buffer "fuel listener" (current-buffer) factor nil
                           "-run=listener" (format "-i=%s" image))
    (fuel-listener--wait-for-prompt 10000)
    (fuel-con--setup-connection (current-buffer))
    (fuel-con--send-string/wait (current-buffer)
                                fuel-con--init-stanza
                                '(lambda (s) (message "FUEL listener up and running!"))
                                20000)))

(defun fuel-listener--process (&optional start)
  (or (and (buffer-live-p (fuel-listener--buffer))
           (get-buffer-process (fuel-listener--buffer)))
      (if (not start)
          (error "No running factor listener (try M-x run-factor)")
        (fuel-listener--start-process)
        (fuel-listener--process))))

(setq fuel-eval--default-proc-function 'fuel-listener--process)

(defun fuel-listener--wait-for-prompt (timeout)
  (let ((p (point)) (seen))
    (while (and (not seen) (> timeout 0))
      (sleep-for 0.1)
      (setq timeout (- timeout 100))
      (goto-char p)
      (setq seen (re-search-forward comint-prompt-regexp nil t)))
    (goto-char (point-max))
    (unless seen (error "No prompt found!"))))

(defun fuel-listener-nuke ()
  (interactive)
  (comint-redirect-cleanup)
  (fuel-con--setup-connection fuel-listener--buffer))


;;; Interface: starting fuel listener

(defalias 'switch-to-factor 'run-factor)
(defalias 'switch-to-fuel-listener 'run-factor)
;;;###autoload
(defun run-factor (&optional arg)
  "Show the fuel-listener buffer, starting the process if needed."
  (interactive)
  (let ((buf (process-buffer (fuel-listener--process t)))
        (pop-up-windows fuel-listener-window-allow-split))
    (if fuel-listener-use-other-window
        (pop-to-buffer buf)
      (switch-to-buffer buf))))


;;; Completion support

(defsubst fuel-listener--current-vocab () nil)
(defsubst fuel-listener--usings () nil)

(defun fuel-listener--setup-completion ()
  (setq fuel-syntax--current-vocab-function 'fuel-listener--current-vocab)
  (setq fuel-syntax--usings-function 'fuel-listener--usings)
  (set-syntax-table fuel-syntax--syntax-table))


;;; Stack mode support

(defun fuel-listener--stack-region ()
  (fuel--region-to-string (if (zerop (fuel-syntax--brackets-depth))
                              (comint-line-beginning-position)
                            (1+ (fuel-syntax--brackets-start)))))

(defun fuel-listener--setup-stack-mode ()
  (setq fuel-stack--region-function 'fuel-listener--stack-region))


;;; Fuel listener mode:

(defun fuel-listener--bol ()
  (interactive)
  (when (= (point) (comint-bol)) (beginning-of-line)))

;;;###autoload
(define-derived-mode fuel-listener-mode comint-mode "Fuel Listener"
  "Major mode for interacting with an inferior Factor listener process.
\\{fuel-listener-mode-map}"
  (set (make-local-variable 'comint-prompt-regexp) fuel-con--prompt-regex)
  (set (make-local-variable 'comint-use-prompt-regexp) t)
  (set (make-local-variable 'comint-prompt-read-only) t)
  (set-syntax-table fuel-syntax--syntax-table)
  (fuel-listener--setup-completion)
  (fuel-listener--setup-stack-mode))

(define-key fuel-listener-mode-map "\C-cz" 'run-factor)
(define-key fuel-listener-mode-map "\C-c\C-z" 'run-factor)
(define-key fuel-listener-mode-map "\C-a" 'fuel-listener--bol)
(define-key fuel-listener-mode-map "\C-ca" 'fuel-autodoc-mode)
(define-key fuel-listener-mode-map "\C-ch" 'fuel-help)
(define-key fuel-listener-mode-map "\C-cs" 'fuel-stack-mode)
(define-key fuel-listener-mode-map "\C-cp" 'fuel-apropos)
(define-key fuel-listener-mode-map "\M-." 'fuel-edit-word-at-point)
(define-key fuel-listener-mode-map "\C-cv" 'fuel-edit-vocabulary)
(define-key fuel-listener-mode-map "\C-c\C-v" 'fuel-edit-vocabulary)
(define-key fuel-listener-mode-map "\C-ck" 'fuel-run-file)
(define-key fuel-listener-mode-map (kbd "TAB") 'fuel-completion--complete-symbol)


(provide 'fuel-listener)
;;; fuel-listener.el ends here
