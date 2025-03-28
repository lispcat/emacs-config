;;; my-programs.el --- programs

;;; Commentary:

;;; Code:


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; eat ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (+leader-bind
;;   "a" '(:ignore t))

(leaf eat
  :setq
  (eat-term-name . "xterm-256color")
  (eat-kill-buffer-on-exit . t)
  :defer-config
  (setq eat-shell (concat (or explicit-shell-file-name
                              (getenv "ESHELL")
                              shell-file-name)
                          " -c tmux"))
  :bind
  ("C-c a a" . eat)
  (eat-semi-char-mode-map
   ("M-o" . ace-window)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; eshell ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(leaf eshell :ensure nil
  :bind
  ("C-c a e" . eshell))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; magit ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(leaf magit
  :preface (elpaca transient) ; HACK: magit needs newer version
  :setq
  (magit-display-buffer-function . #'magit-display-buffer-same-window-except-diff-v1)
  :bind
  ("C-c v" . magit))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;; pdf-tools ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(leaf pdf-tools
  :config
  (pdf-loader-install)) ; On demand loading, leads to faster startup time


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; elfeed ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(leaf elfeed
  :defer-config
  ;; set `elfeed-feeds' to all files in `my/elfeed-feeds-dir'.
  (defvar my/elfeed-feeds-dir "~/feeds")
  (defun my/elfeed-feeds-update-var ()
    (interactive)
    (setq elfeed-feeds
          (mapcar (lambda (s) (concat "file:" s))
                  (directory-files my/elfeed-feeds-dir t
                                   directory-files-no-dot-files-regexp))))
  ;; run `my/elfeed-feeds-update-var' before running `elfeed-update'
  (advice-add #'elfeed-update :before #'my/elfeed-feeds-update-var))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; end ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(provide 'my-programs)
;;; my-programs.el ends here
