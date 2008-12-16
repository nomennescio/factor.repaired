;;; fuel-connection.el -- asynchronous comms with the fuel listener

;; Copyright (C) 2008 Jose Antonio Ortega Ruiz
;; See http://factorcode.org/license.txt for BSD license.

;; Author: Jose Antonio Ortega Ruiz <jao@gnu.org>
;; Keywords: languages, fuel, factor
;; Start date: Thu Dec 11, 2008 03:10

;;; Comentary:

;; Handling communications via a comint buffer running a factor
;; listener.

;;; Code:

(require 'fuel-log)
(require 'fuel-base)

(require 'comint)
(require 'advice)


;;; Default connection:

(make-variable-buffer-local
 (defvar fuel-con--connection nil))

(defun fuel-con--get-connection (buffer/proc)
  (if (processp buffer/proc)
      (fuel-con--get-connection (process-buffer buffer/proc))
    (with-current-buffer buffer/proc
      (or fuel-con--connection
          (setq fuel-con--connection
                (fuel-con--setup-connection buffer/proc))))))


;;; Request and connection datatypes:

(defun fuel-con--connection-queue-request (c r)
  (let ((reqs (assoc :requests c)))
    (setcdr reqs (append (cdr reqs) (list r)))))

(defun fuel-con--make-request (str cont &optional sender-buffer)
  (list :fuel-connection-request
        (cons :id (random))
        (cons :string str)
        (cons :continuation cont)
        (cons :buffer (or sender-buffer (current-buffer)))
        (cons :output "")))

(defsubst fuel-con--request-p (req)
  (and (listp req) (eq (car req) :fuel-connection-request)))

(defsubst fuel-con--request-id (req)
  (cdr (assoc :id req)))

(defsubst fuel-con--request-string (req)
  (cdr (assoc :string req)))

(defsubst fuel-con--request-continuation (req)
  (cdr (assoc :continuation req)))

(defsubst fuel-con--request-buffer (req)
  (cdr (assoc :buffer req)))

(defun fuel-con--request-output (req &optional suffix)
  (let ((cell (assoc :output req)))
    (when suffix (setcdr cell (concat (cdr cell) suffix)))
    (cdr cell)))

(defsubst fuel-con--request-deactivate (req)
  (setcdr (assoc :continuation req) nil))

(defsubst fuel-con--request-deactivated-p (req)
  (null (cdr (assoc :continuation req))))

(defsubst fuel-con--make-connection (buffer)
  (list :fuel-connection
        (cons :requests (list))
        (cons :current nil)
        (cons :completed (make-hash-table :weakness 'value))
        (cons :buffer buffer)
        (cons :timer nil)))

(defsubst fuel-con--connection-p (c)
  (and (listp c) (eq (car c) :fuel-connection)))

(defsubst fuel-con--connection-requests (c)
  (cdr (assoc :requests c)))

(defsubst fuel-con--connection-current-request (c)
  (cdr (assoc :current c)))

(defun fuel-con--connection-clean-current-request (c)
  (let* ((cell (assoc :current c))
         (req (cdr cell)))
    (when req
      (puthash (fuel-con--request-id req) req (cdr (assoc :completed c)))
      (setcdr cell nil))))

(defsubst fuel-con--connection-completed-p (c id)
  (gethash id (cdr (assoc :completed c))))

(defsubst fuel-con--connection-buffer (c)
  (cdr (assoc :buffer c)))

(defun fuel-con--connection-pop-request (c)
  (let ((reqs (assoc :requests c))
        (current (assoc :current c)))
    (setcdr current (prog1 (cadr reqs) (setcdr reqs (cddr reqs))))
    (if (and (cdr current)
             (fuel-con--request-deactivated-p (cdr current)))
        (fuel-con--connection-pop-request c)
      (cdr current))))

(defun fuel-con--connection-start-timer (c)
  (let ((cell (assoc :timer c)))
    (when (cdr cell) (cancel-timer (cdr cell)))
    (setcdr cell (run-at-time t 0.5 'fuel-con--process-next c))))

(defun fuel-con--connection-cancel-timer (c)
  (let ((cell (assoc :timer c)))
    (when (cdr cell) (cancel-timer (cdr cell)))))


;;; Connection setup:

(defun fuel-con--cleanup-connection (c)
  (fuel-con--connection-cancel-timer c))

(defun fuel-con--setup-connection (buffer)
  (set-buffer buffer)
  (fuel-con--cleanup-connection fuel-con--connection)
  (let ((conn (fuel-con--make-connection buffer)))
    (fuel-con--setup-comint)
    (prog1
        (setq fuel-con--connection conn)
      (fuel-con--connection-start-timer conn))))

(defconst fuel-con--prompt-regex "( .+ ) ")
(defconst fuel-con--eot-marker "EOT:")
(defconst fuel-con--init-stanza (format "USE: fuel %S write" fuel-con--eot-marker))

(defconst fuel-con--comint-finished-regex
  (format "%s%s" fuel-con--eot-marker fuel-con--prompt-regex))

(defun fuel-con--setup-comint ()
  (comint-redirect-cleanup)
  (add-hook 'comint-redirect-filter-functions
            'fuel-con--comint-redirect-filter t t)
  (add-hook 'comint-redirect-hook
            'fuel-con--comint-redirect-hook nil t))

(defadvice comint-redirect-setup (after fuel-con--advice activate)
  (setq comint-redirect-finished-regexp fuel-con--comint-finished-regex))


;;; Requests handling:

(defun fuel-con--process-next (con)
  (when (not (fuel-con--connection-current-request con))
    (let* ((buffer (fuel-con--connection-buffer con))
           (req (fuel-con--connection-pop-request con))
           (str (and req (fuel-con--request-string req))))
      (if (not (buffer-live-p buffer))
          (fuel-con--connection-cancel-timer con)
        (when (and buffer req str)
          (set-buffer buffer)
          (fuel-log--info "<%s>: %s" (fuel-con--request-id req) str)
          (comint-redirect-send-command (format "%s" str)
                                        (fuel-log--buffer) nil t))))))

(defun fuel-con--process-completed-request (req)
  (let ((str (fuel-con--request-output req))
        (cont (fuel-con--request-continuation req))
        (id (fuel-con--request-id req))
        (rstr (fuel-con--request-string req))
        (buffer (fuel-con--request-buffer req)))
    (if (not cont)
        (fuel-log--warn "<%s> Droping result for request %S (%s)"
                            id rstr str)
      (condition-case cerr
          (with-current-buffer (or buffer (current-buffer))
            (funcall cont str)
            (fuel-log--info "<%s>: processed\n\t%s" id str))
        (error (fuel-log--error "<%s>: continuation failed %S \n\t%s"
                                id rstr cerr))))))

(defvar fuel-con--debug-comint-p nil)

(defun fuel-con--comint-redirect-filter (str)
  (if (not fuel-con--connection)
      (fuel-log--error "No connection in buffer (%s)" str)
    (let ((req (fuel-con--connection-current-request fuel-con--connection)))
      (if (not req) (fuel-log--error "No current request (%s)" str)
        (fuel-con--request-output req str)
        (fuel-log--info "<%s>: in progress" (fuel-con--request-id req)))))
  (if fuel-con--debug-comint-p (fuel--shorten-str str 256) ""))

(defun fuel-con--comint-redirect-hook ()
  (if (not fuel-con--connection)
      (fuel-log--error "No connection in buffer")
    (let ((req (fuel-con--connection-current-request fuel-con--connection)))
      (if (not req) (fuel-log--error "No current request")
        (fuel-con--process-completed-request req)
        (fuel-con--connection-clean-current-request fuel-con--connection)))))


;;; Message sending interface:

(defun fuel-con--send-string (buffer/proc str cont &optional sender-buffer)
  (save-current-buffer
    (let ((con (fuel-con--get-connection buffer/proc)))
      (unless con
        (error "FUEL: couldn't find connection"))
      (let ((req (fuel-con--make-request str cont sender-buffer)))
        (fuel-con--connection-queue-request con req)
        (fuel-con--process-next con)
        req))))

(defvar fuel-connection-timeout 30000
  "Time limit, in msecs, blocking on synchronous evaluation requests")

(defun fuel-con--send-string/wait (buffer/proc str cont &optional timeout sbuf)
  (save-current-buffer
    (let* ((con (fuel-con--get-connection buffer/proc))
           (req (fuel-con--send-string buffer/proc str cont sbuf))
           (id (and req (fuel-con--request-id req)))
           (time (or timeout fuel-connection-timeout))
           (step 100)
           (waitsecs (/ step 1000.0)))
      (when id
        (condition-case nil
            (while (and (> time 0)
                        (not (fuel-con--connection-completed-p con id)))
              (accept-process-output nil waitsecs)
              (setq time (- time step)))
          (error (setq time 1)))
        (or (> time 0)
            (fuel-con--request-deactivate req)
            nil)))))


(provide 'fuel-connection)
;;; fuel-connection.el ends here
