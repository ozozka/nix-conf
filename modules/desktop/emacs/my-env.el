;;; my-env.el --- Load direnv environments into buffers -*- lexical-binding: t; -*-

;;; Commentary:
;;; Code:

(require 'json)
(require 'subr-x)

(defgroup my-env nil
  "Buffer-local direnv integration."
  :group 'environment)

(defcustom my-env-direnv-program (executable-find "direnv")
  "Absolute path to the direnv executable."
  :type '(choice (const :tag "Unavailable" nil) file)
  :group 'my-env)

(defvar my-env-mode)

(defconst my-env--json-null (make-symbol "my-env-json-null"))
(defconst my-env--json-false (make-symbol "my-env-json-false"))

(defvar-local my-env-status 'inactive "Current direnv state for this buffer.")
(defvar-local my-env--base-process-environment nil)
(defvar-local my-env--base-exec-path nil)
(defvar-local my-env--process-environment-was-local nil)
(defvar-local my-env--exec-path-was-local nil)
(defvar-local my-env--base-captured-p nil)
(defvar-local my-env--environment-file nil)
(defvar-local my-env--disabled nil)

(put 'my-env--disabled 'permanent-local t)

(defun my-env--set-status (status)
  "Set the current buffer environment STATUS."
  (setq my-env-status status)
  (force-mode-line-update))

(defun my-env--lighter ()
  "Return the mode-line indicator for `my-env-mode'."
  (pcase my-env-status
    ('loading " Env...")
    ('ready " Env")
    ('error " Env!")
    ('none " Env-")
    (_ " Env")))

(defun my-env--envrc-file ()
  "Return the nearest local .envrc for the current buffer."
  (when (and (stringp default-directory)
             (not (file-remote-p default-directory)))
    (when-let* ((directory
                 (locate-dominating-file default-directory ".envrc")))
      (expand-file-name ".envrc" directory))))

(defun my-env--program ()
  "Return the configured direnv executable or signal an error."
  (unless (and (stringp my-env-direnv-program)
               (file-name-absolute-p my-env-direnv-program)
               (file-executable-p my-env-direnv-program))
    (error "my-env-direnv-program is not an executable absolute path"))
  my-env-direnv-program)

(defun my-env--run (environment directory &rest arguments)
  "Run direnv with ENVIRONMENT and DIRECTORY.

ARGUMENTS are passed directly to direnv.  Return a list containing
the exit status, standard output, and standard error."
  (let ((output-buffer (generate-new-buffer " *my-env-output*"))
        (error-file (make-temp-file "my-env-error-"))
        (process-environment (copy-sequence environment))
        (default-directory
         (file-name-as-directory (expand-file-name directory)))
        (coding-system-for-read 'utf-8-unix)
        (coding-system-for-write 'utf-8-unix))
    (unwind-protect
        (let ((status
               (apply #'process-file
                      (my-env--program)
                      nil
                      (list output-buffer error-file)
                      nil
                      arguments)))
          (list status
                (with-current-buffer output-buffer
                  (buffer-string))
                (with-temp-buffer
                  (insert-file-contents error-file)
                  (buffer-string))))
      (kill-buffer output-buffer)
      (delete-file error-file))))

(defun my-env--parse-export (output)
  "Parse and validate direnv JSON OUTPUT."
  (if (string-empty-p (string-trim output))
      (make-hash-table :test #'equal)
    (let ((environment
           (json-parse-string
            output
            :object-type 'hash-table
            :array-type 'list
            :null-object my-env--json-null
            :false-object my-env--json-false)))
      (unless (hash-table-p environment)
        (error "direnv export did not return a JSON object"))
      (maphash
       (lambda (name value)
         (unless (and (stringp name)
                      (not (string-empty-p name))
                      (not (string-match-p "[=\0]" name)))
           (error "direnv returned an invalid environment name"))
         (unless (or (stringp value)
                     (eq value my-env--json-null))
           (error "direnv returned an invalid value for %s" name)))
       environment)
      environment)))

(defun my-env--apply-export (output)
  "Apply direnv JSON OUTPUT to the current buffer's baseline."
  (let ((changes (my-env--parse-export output))
        (candidate
         (copy-sequence my-env--base-process-environment)))
    ;; Build the complete candidate first so malformed output cannot leave a
    ;; partially changed buffer environment.
    (let ((process-environment candidate))
      (maphash
       (lambda (name value)
         (setenv name
                 (unless (eq value my-env--json-null)
                   value)))
       changes)
      (setq candidate process-environment))
    (setq-local process-environment candidate)
    (let ((process-environment candidate))
      (setq-local exec-path
                  (append
                   (parse-colon-path (or (getenv "PATH") ""))
                   (list exec-directory))))))

(defun my-env--install-baseline ()
  "Install independent copies of the saved baseline in this buffer."
  (setq-local process-environment
              (copy-sequence my-env--base-process-environment))
  (setq-local exec-path
              (copy-sequence my-env--base-exec-path)))

(defun my-env--error-message (status error-output)
  "Return a concise direnv error for STATUS and ERROR-OUTPUT."
  (let ((detail
         (string-trim
          (replace-regexp-in-string "[\r\n]+" " " error-output))))
    (if (string-empty-p detail)
        (format "direnv exited with status %s" status)
      (truncate-string-to-width
       (format "direnv exited with status %s: %s" status detail)
       500 nil nil "..."))))

(defun my-env--reload ()
  "Synchronously reload direnv for the current buffer."
  (let ((envrc (my-env--envrc-file)))
    (setq my-env--environment-file envrc)
    (if (not envrc)
        (progn
          (my-env--restore-baseline)
          (setq my-env-mode nil))
      (my-env--set-status 'loading)
      (condition-case error-data
          (pcase-let* ((`(,status ,output ,error-output)
                        (my-env--run
                         my-env--base-process-environment
                         default-directory
                         "export" "json")))
            (if (and (integerp status) (zerop status))
                (progn
                  (my-env--apply-export output)
                  (my-env--set-status 'ready))
              (my-env--install-baseline)
              (my-env--set-status 'error)
              (display-warning
               'my-env
               (my-env--error-message status error-output)
               :warning)))
        (error
         (my-env--install-baseline)
         (my-env--set-status 'error)
         (display-warning
          'my-env
          (error-message-string error-data)
          :warning))
        (quit
         (my-env--install-baseline)
         (my-env--set-status 'error)
         (signal (car error-data) (cdr error-data)))))))

(defun my-env--capture-baseline ()
  "Save the current buffer's environment and variable locality."
  (unless my-env--base-captured-p
    (setq my-env--process-environment-was-local
          (local-variable-p 'process-environment)
          my-env--exec-path-was-local
          (local-variable-p 'exec-path)
          my-env--base-process-environment
          (copy-sequence process-environment)
          my-env--base-exec-path
          (copy-sequence exec-path)
          my-env--base-captured-p t)))

(defun my-env--restore-baseline ()
  "Restore the environment that preceded `my-env-mode'."
  (when my-env--base-captured-p
    (if my-env--process-environment-was-local
        (setq-local process-environment
                    (copy-sequence my-env--base-process-environment))
      (kill-local-variable 'process-environment))
    (if my-env--exec-path-was-local
        (setq-local exec-path
                    (copy-sequence my-env--base-exec-path))
      (kill-local-variable 'exec-path)))
  (setq my-env--base-process-environment nil
        my-env--base-exec-path nil
        my-env--process-environment-was-local nil
        my-env--exec-path-was-local nil
        my-env--base-captured-p nil
        my-env--environment-file nil)
  (my-env--set-status 'inactive))

(define-minor-mode my-env-mode
  "Use the nearest direnv environment in the current buffer."
  :init-value nil
  :lighter (:eval (my-env--lighter))
  :group 'my-env
  (if my-env-mode
      (progn
        (setq my-env--disabled nil)
        (my-env--capture-baseline)
        (my-env--reload))
    (my-env--restore-baseline)))

(defun my-env-disable ()
  "Disable automatic direnv loading in the current buffer."
  (interactive)
  (when my-env-mode
    (my-env-mode -1))
  (setq my-env--disabled t))

(defun my-env-reload ()
  "Synchronously reload direnv in the current buffer."
  (interactive)
  (if my-env-mode
      (my-env--reload)
    (my-env-mode 1)))

(defun my-env-allow ()
  "Allow the nearest .envrc and reload it in the current buffer."
  (interactive)
  (let ((envrc (my-env--envrc-file)))
    (unless envrc
      (user-error "No .envrc found for this buffer"))
    (unless (yes-or-no-p
             (format "Allow executable environment file %s? " envrc))
      (user-error "Environment was not allowed"))
    (pcase-let* ((environment
                  (if my-env--base-captured-p
                      my-env--base-process-environment
                    process-environment))
                 (`(,status ,_output ,error-output)
                  (my-env--run
                   environment
                   (file-name-directory envrc)
                   "allow" envrc)))
      (unless (and (integerp status) (zerop status))
        (user-error "%s" (my-env--error-message status error-output)))
      (if my-env-mode
          (my-env--reload)
        (my-env-mode 1)))))

(defun my-env--eligible-buffer-p ()
  "Return non-nil when the current buffer should load direnv."
  (and (not (minibufferp))
       (stringp default-directory)
       (not (file-remote-p default-directory))
       (or buffer-file-name
           (derived-mode-p 'dired-mode))))

(defun my-env--maybe-enable ()
  "Enable or update `my-env-mode' when appropriate."
  (when (my-env--eligible-buffer-p)
    (let ((envrc (my-env--envrc-file)))
      (cond
       ((and my-env-mode
             (not (equal envrc my-env--environment-file)))
        (my-env--reload))
       ((and envrc (not my-env-mode))
        (unless my-env--disabled
          (my-env-mode 1)))))))

(define-minor-mode my-env-global-mode
  "Automatically load direnv in local file and Dired buffers."
  :global t
  :group 'my-env
  (if my-env-global-mode
      (progn
        ;; This hook runs before mode-specific hooks such as
        ;; `eglot-ensure', keeping environment loading synchronous and ordered.
        (add-hook
         'change-major-mode-after-body-hook #'my-env--maybe-enable -100)
        (add-hook 'dired-after-readin-hook #'my-env--maybe-enable -100)
        (add-hook
         'after-set-visited-file-name-hook #'my-env--maybe-enable -100)
        (dolist (buffer (buffer-list))
          (with-current-buffer buffer
            (my-env--maybe-enable))))
    (remove-hook
     'change-major-mode-after-body-hook #'my-env--maybe-enable)
    (remove-hook 'dired-after-readin-hook #'my-env--maybe-enable)
    (remove-hook
     'after-set-visited-file-name-hook #'my-env--maybe-enable)
    (dolist (buffer (buffer-list))
      (with-current-buffer buffer
        (when my-env-mode
          (my-env-mode -1))))))

(my-env-global-mode 1)

(provide 'my-env)
;;; my-env.el ends here
