;;; my-modes.el --- Modes -*- lexical-binding: t; -*-

;;; Commentary:
;;; Code:

(use-package log-edit
  :defer t
  :hook
  (log-edit-mode . (lambda () (buffer-face-set 'variable-pitch))))

(use-package info
  :hook
  (Info-mode . my-info-setup)
  :config
  (defun my-info-setup ()
    (buffer-face-set 'variable-pitch)))

(use-package c-ts-mode
  :ensure nil
  :mode ("\\.cuh?\\'" . c++-ts-mode))

(use-package markdown-ts-mode
  :mode ("\\.\\(?:md\\|markdown\\|mdown\\|mkd\\)\\'" . markdown-ts-mode)
  :custom
  (markdown-ts-hide-markup t)
  (markdown-ts-inline-images t)
  (markdown-ts-image-max-width 'window)
  (markdown-ts-fontify-code-blocks-natively t)
  (markdown-ts-enable-code-block-context-mode t)
  (markdown-ts-enable-table-mode t)
  (markdown-ts-default-folding 'show-all)
  (markdown-ts-unordered-list-marker '(("∙ " . "* "))) ; ⋅
  (markdown-ts-checked-checkbox '("✔ " . "+ "))
  (markdown-ts-unchecked-checkbox '("⬦ " . "- "))
  :hook
  (markdown-ts-mode . my-markdown-writing-setup)
  :bind
  (:map markdown-ts-mode-map ("C-c x" . markdown-ts-toggle-hide-markup))
  :config
  (defun my-markdown-sync-line-numbers (&rest _)
    (display-line-numbers-mode (if markdown-ts-hide-markup -1 1)))
  (advice-add 'markdown-ts-toggle-hide-markup
              :after #'my-markdown-sync-line-numbers)
  (defun my-markdown-writing-setup ()
    "Configure Markdown."
    (buffer-face-set 'variable-pitch)
    (font-lock-add-keywords
     nil
     '(("^\\([ \t]+\\)" (1 'fixed-pitch prepend)))
     'append)
    (my-markdown-sync-line-numbers)
    (electric-pair-local-mode 1)))

(use-package treesit-x
  :ensure nil
  :demand t
  :config
  (define-treesit-generic-mode just-ts-mode
    "Tree-sitter mode for Justfiles."
    :lang 'just
    :auto-mode "\\(?:^\\|/\\)[Jj]ustfile\\'"
    :parent #'prog-mode
    :name "Just"
    (setq-local comment-start "# ")
    (setq-local comment-end ""))

  (define-treesit-generic-mode nix-ts-mode
    "Tree-sitter mode for Nix expressions."
    :lang 'nix
    :auto-mode "\\.nix\\'"
    :parent #'prog-mode
    :name "Nix"
    (setq-local comment-start "# ")
    (setq-local comment-end ""))

  (define-treesit-generic-mode typst-ts-mode
    "Tree-sitter mode for Typst documents."
    :lang 'typst
    :auto-mode "\\.typ\\'"
    :parent #'text-mode
    :name "Typst"
    (setq-local comment-start "// ")
    (setq-local comment-end "")))

(provide 'my-modes)
;;; my-modes.el ends here
