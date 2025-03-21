;; [[file:../Config.org::*debugging][debugging:1]]
;; (advice-add 'switch-to-buffer :before (lambda (arg &optional a b) (message "DEBUG: switching to buffer: %s" arg)))
;; (debug-on-entry 'switch-to-buffer)
;; debugging:1 ends here

;; [[file:../Config.org::*buffer reverting and management][buffer reverting and management:1]]
;; revert buffer when its file is changed on the filesystem
(leaf autorevert :ensure nil
  :require t
  :diminish autorevert-mode
  :init
  (global-auto-revert-mode 1)
  :setq
  (global-auto-revert-non-file-buffers . t)
  (auto-revert-use-notify . nil)
  (auto-revert-interval . 5))

(+leader-bind
  "k" 'kill-current-buffer
  "b" '(:ignore t :which-key "buffer")
  "bk" 'kill-current-buffer
  "bn" 'next-buffer
  "bp" 'previous-buffer
  "bo" '(my/last-selected-buffer :which-key "last-buffer")
  "bb" 'switch-to-buffer
  "bs" 'save-buffer)

(defalias 'my/last-selected-buffer 'mode-line-other-buffer)
;; buffer reverting and management:1 ends here

;; [[file:../Config.org::*history and recents][history and recents:1]]
;; remember recent files
(leaf recentf :ensure nil
  :hook emacs-startup-hook)

;; go to previous location in file when reopening
(leaf saveplace :ensure nil
  :init
  (save-place-mode 1))

;; persist minibuffer history over restarts
(leaf savehist :ensure nil
  :init
  (savehist-mode 1))
;; history and recents:1 ends here

;; [[file:../Config.org::*window management][window management:1]]
(leaf ace-window
  :setq
  (aw-keys . '(?a ?o ?e ?u ?h ?t ?n ?s))
  (aw-scope . 'frame)
  (aw-background . nil)
  ;; (aw-dispatch-always . t)
  :bind
  ("M-o" . ace-window)
  :init
  (+leader-bind
    "w" '(:ignore t :which-key "window")
    "wd" 'delete-window
    "w+" 'balance-windows
    "wa" 'balance-windows-area
    ;; split window
    "wv" 'split-window-horizontally
    "ws" 'split-window-vertically
    ;; select window directionally
    "wp" '(windmove-up    :which-key "select up")
    "wn" '(windmove-down  :which-key "select down")
    "wf" '(windmove-right :which-key "select right")
    "wb" '(windmove-left  :which-key "select left")
    ;; misc
    "wm" 'switch-to-minibuffer))

;; (leaf eyebrowse
;;   :init
;;   (eyebrowse-mode 1))

;; (leaf bufler
;;   :bind
;;   ("C-x C-b" . bufler-list)
;;   :init
;;   (bufler-workspace-mode 1))
;; window management:1 ends here

;; [[file:../Config.org::*dired][dired:1]]
(defun my/open-my-emacs-src-dir ()
  "Open Dired in `my/emacs-src-dir'."
  (interactive)
  (dired my/emacs-src-dir))

(leaf dired :ensure nil
  :setq
  (dired-listing-switches . "-Ahl --group-directories-first -X")
  (dired-auto-revert-buffer . t)        ; auto update file changes
  :bind (dired-mode-map
         ("h" . dired-up-directory)
         ("s" . dired-find-file)
         ("r" . dired-sort-toggle-or-edit))
  :init
  (+leader-bind
    "d" '(:ignore t :which-key "dired")
    "dd" 'find-file
    "dj" 'dired-jump
    "f" '(:ignore t :which-key "files")
    "ff" 'find-file
    "fp" 'my/open-my-emacs-src-dir)
  :config
  ;; hide details by default
  (add-hook 'dired-mode-hook 'dired-hide-details-mode)
  ;; use trash if trash executable is found
  (when (executable-find "trash")
    (setq delete-by-moving-to-trash t)))

(leaf dired-launch
  :after dired
  :config
  (dired-launch-enable)
  :setq
  (dired-launch-extensions-map
   . '(("pptx" ("libreoffice"))
       ("docx" ("libreoffice"))
       ("odt"  ("libreoffice"))
       ("html" ("librewolf")))))
;; dired:1 ends here

;; [[file:../Config.org::*helpful][helpful:1]]
(leaf helpful
  :setq
  (counsel-describe-function-function . #'helpful-callable)
  (counsel-describe-variable-function . #'helpful-variable)
  :bind
  ([remap describe-function] . helpful-callable)
  ([remap describe-symbol] . helpful-symbol)
  ([remap describe-variable] . helpful-variable)
  ([remap describe-command] . helpful-command)
  ([remap describe-key] . helpful-key)
  ("C-h h" . helpful-at-point)
  ("C-h H" . view-hello-file)          ; command originally at "C-h h"
  ("C-h M" . which-key-show-major-mode)
  ("C-h E" . describe-keymap))
;; helpful:1 ends here

;; [[file:../Config.org::*sudoedit][sudoedit:1]]
;; sudoedit
(leaf auto-sudoedit
  :commands auto-sudoedit-sudoedit)
;; sudoedit:1 ends here

;; [[file:../Config.org::*profiler][profiler:1]]
(defun my/profiler-report ()
  "Profiler stop and report."
  (interactive)
  (profiler-stop)
  (profiler-report))

(+leader-bind
  "D" '(:ignore t :which-key "debug")
  "Ds" 'profiler-start
  "Dr" 'my/profiler-report)
;; profiler:1 ends here

;; [[file:../Config.org::*basic keybind tweaks][basic keybind tweaks:1]]
;; Actuates Meta key by default
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; Shorten yes/no prompts to y/n
(defalias 'yes-or-no-p 'y-or-n-p)

;; By default, Emacs thinks two spaces after a period is a sentence.
;; This changes that to just one space.
(setq sentence-end-double-space nil)

;; nice keybinds for navigation
(global-set-key (kbd "M-p") (kbd "M-- 1 C-v"))
(global-set-key (kbd "M-n") (kbd "M-- 1 M-v"))
;; basic keybind tweaks:1 ends here

;; [[file:../Config.org::*meow: modal editing][meow: modal editing:1]]
(defun my/meow-setup ()
  (setq meow-cheatsheet-layout meow-cheatsheet-layout-dvp)
  (meow-motion-overwrite-define-key
   ;; custom keybinding for motion state
   '("<escape>" . ignore)
   '("t" . "p") ;; improved solution? (access Motion "t" with "SPC t")
   )
  (meow-leader-define-key
   '("t" . "H-t")
   ;; '("p" . "H-p")
   ;; '("u" . ctl-x-map)
   '("1" . meow-digit-argument)
   '("2" . meow-digit-argument)
   '("3" . meow-digit-argument)
   '("4" . meow-digit-argument)
   '("5" . meow-digit-argument)
   '("6" . meow-digit-argument)
   '("7" . meow-digit-argument)
   '("8" . meow-digit-argument)
   '("9" . meow-digit-argument)
   '("0" . meow-digit-argument)
   '("/" . meow-keypad-describe-key)
   '("?" . meow-cheatsheet))
  (meow-normal-define-key
   ;; make S-<num> easier to hit with DVP by using symbols.
   '("*" . meow-expand-0)
   '("=" . meow-expand-9)
   '("!" . meow-expand-8)
   '("[" . meow-expand-7)
   '("]" . meow-expand-6)
   '("{" . meow-expand-5)
   '("+" . meow-expand-4)
   '("}" . meow-expand-3)
   '(")" . meow-expand-2)
   '("(" . meow-expand-1)
   '("1" . digit-argument)
   '("2" . digit-argument)
   '("3" . digit-argument)
   '("4" . digit-argument)
   '("5" . digit-argument)
   '("6" . digit-argument)
   '("7" . digit-argument)
   '("8" . digit-argument)
   '("9" . digit-argument)
   '("0" . digit-argument)
   ;; symbols
   '("-" . negative-argument)
   '(";" . meow-reverse)
   '(":" . meow-goto-line) ;; moved from "Q" and "E"
   '("," . meow-inner-of-thing)
   '("." . meow-bounds-of-thing)
   '("<" . meow-beginning-of-thing)
   '(">" . meow-end-of-thing)
   ;; basic letters
   '("a" . meow-append)
   '("A" . meow-open-below)
   '("b" . meow-back-word)
   '("B" . meow-back-symbol)
   '("c" . meow-change)
   ;; '("d" . ri/meow-delete-or-kill)
   '("d" . meow-delete) ; i want "d" to delete char after meow-prev/next-word, so dont use former
   '("D" . meow-backward-delete)
   '("e" . meow-line)
   ;; '("E" . meow-goto-line) ;; removed, since ":" for it works
   '("f" . meow-find)
   '("F" . meow-search) ;; moved from "s" ("s" is used for movement)
   '("g" . meow-cancel-selection)
   '("G" . meow-grab)
   ;; H Directional key moved to the bottom
   '("i" . meow-insert)
   '("I" . meow-open-above)
   '("j" . meow-join)
   '("k" . meow-kill)
   '("l" . meow-till)
   ;; '("m" . meow-mark-word) ;; swap with w, next-word (because "b"/"m" is easy for mvmnt)
   ;; '("M" . meow-mark-symbol) ;; swap with W, next-symbol (because "b"/"m" is easy for mvmnt)
   '("m" . meow-next-word)   ;; moved from "w", mark-word
   '("M" . meow-next-symbol) ;; moved from "W", mark-symbol
   ;; N Directional key moved to the bottom
   '("o" . meow-block)
   '("O" . meow-to-block)
   '("p" . meow-prev)
   '("P" . meow-prev-expand)
   '("q" . meow-quit)
   '("Q" . ri/quit-temp-window)
   ;; '("Q" . meow-goto-line) ;; move to " : "
   '("r" . meow-replace)
   '("R" . meow-swap-grab)
   ;; '("s" . meow-search) ;; move to F, replace with directional keys
   ;; S Directional key moved to the bottom
   ;; T Directional key moved to the bottom
   '("u" . meow-undo)
   '("U" . meow-undo-in-selection)
   '("v" . meow-visit)
   ;; '("w" . meow-next-word) ;; swap with m, mark-word/symbol
   ;; '("W" . meow-next-symbol)
   '("w" . meow-mark-word)   ;; moved from "m", mark-word
   '("W" . meow-mark-symbol) ;; moved from "M", mark-symbol
   '("x" . meow-save)
   '("X" . meow-sync-grab)
   '("y" . meow-yank)
   '("z" . meow-pop-selection)
   '("'" . repeat)
   '("/" . ri/scroll-down-half-page) ;; new keys
   '("?" . ri/scroll-up-half-page)   ;; new keys
   ;; '("<escape>" . ignore)

   '("@" . meow-universal-argument)

   ;; Directional keys:

   ;; <-  ^  v  ->
   '("h" . meow-left)
   '("H" . meow-left-expand)
   '("t" . meow-prev)
   '("T" . meow-prev-expand)
   '("n" . meow-next)
   '("N" . meow-next-expand)
   '("s" . meow-right)
   '("S" . meow-right-expand)

   ;; ^  <-  v  ->
   ;; '("h" . meow-prev)
   ;; '("H" . meow-prev-expand)
   ;; '("t" . meow-left)
   ;; '("T" . meow-left-expand)
   ;; '("n" . meow-next)
   ;; '("N" . meow-next-expand)
   ;; '("s" . meow-right)
   ;; '("S" . meow-right-expand)

   ;; ^  /  <-  ->  v
   ;; '("h" . meow-left)
   ;; '("H" . meow-left-expand)
   ;; '("t" . meow-right)
   ;; '("T" . meow-right-expand)
   ;; '("n" . meow-prev)
   ;; '("N" . meow-prev-expand)
   )

  (meow-global-mode 1))

(leaf meow
  :require t
  :setq
  (meow-use-cursor-position-hack . t)
  (meow-replace-state-name-list
   . '((normal . "<N>")
       (motion . "<M>")
       (keypad . "<K>")
       (insert . "<I>")
       (beacon . "<B>")))
  :config
  (my/meow-setup)

  (defun ri/meow-exit-all-and-save ()
    "When run, exit meow insert mode, exit snippet, then save buffer."
    (interactive)
    ;; (execute-kbd-macro (kbd "<escape>"))
    (meow-insert-exit)
    (when (buffer-modified-p (current-buffer))
      (save-buffer)))

  (defvar ri/meow-insert-default-modes
    '(vterm-mode
      eshell-mode)
    "Start these modes in meow-insert-mode.")

  ;; start certain modes in insert-mode
  (dolist (mode ri/meow-insert-default-modes)
    (add-to-list 'meow-mode-state-list `(,mode . insert)))

  (defvar ri/meow-SPC-ignore-list
    '(Info-mode
      gnus-summary-mode
      gnus-article-mode
      w3m-mode)
    "Disable meow-keypad in these modes.")

  (meow-define-keys 'insert
    ;; '("C-g" . ri/kbd-escape)
    '("C-g" . meow-insert-exit)
    ;; '("C-g" . "<escape>")
    '("C-M-g" . ri/meow-exit-all-and-save))

  ;; enter meow insert mode after creating new org heading
  (add-hook 'org-insert-heading-hook 'meow-insert)
  )
;; meow: modal editing:1 ends here

;; [[file:../Config.org::*avy: jumping][avy: jumping:1]]
;; avy
(leaf avy
  :init
  (+leader-bind
    "j" '(:ignore t :which-key "avy")
    "jj" 'avy-goto-char-timer
    "jc" 'avy-goto-char-2
    "jl" 'avy-goto-line)
  :config
  (setq avy-timeout-seconds 0.3)
  (setq avy-keys (mapcar (lambda (c)
                           (string-to-char c))
                         (split-string "a o e u h t n s k b"))))
;; avy: jumping:1 ends here

;; [[file:../Config.org::*jinx: auto-correct][jinx: auto-correct:1]]
;; spellchecking
(leaf jinx :ensure nil
  :hook org-mode-hook markdown-mode-hook text-mode-hook
  :bind
  (("M-$" . jinx-correct)
   ("C-M-$" . jinx-languages)))
;; jinx: auto-correct:1 ends here

;; [[file:../Config.org::*fontawesome][fontawesome:1]]
(leaf fontawesome
  :commands vertico-fontawesome fontawesome--construct-candidates
  :init
  ;; vertico variant
  (defun vertico-fontawesome ()
    (interactive)
    (require 'vertico)
    (insert
     (cdr
      (assoc
       (completing-read "Font awesome: " (fontawesome--construct-candidates))
       (fontawesome--construct-candidates))))))
;; fontawesome:1 ends here

;; [[file:../Config.org::*vertico][vertico:1]]
;; ? : corfu, kind-icon, wgrep?, consult-dir, cape
;; ^ more at ~/code/cloned/daviwil-dots/.emacs.d/modules/dw-interface.el
;; TODO: vim keybinds for vertico completion shit (work on later) (also daviwil)
;;
;; a framework for minibuffer completion
;; (https://github.com/minad/vertico)

(leaf vertico
  :init
  (vertico-mode 1)
  ;; :setq
  ;; (vertico-scroll-margin . 0) ; Different scroll margin
  ;; (vertico-count . 20) ; Show more candidates
  ;; (vertico-resize . t) ; Grow and shrink the Vertico minibuffer
  ;; (vertico-cycle . t) ; Enable cycling for `vertico-next/previous'
  )

;; A few more useful configurations...
(leaf emacs :ensure nil
  :init
  ;; Support opening new minibuffers from inside existing minibuffers.
  (setq enable-recursive-minibuffers t)
  ;;
  ;; Emacs 28 and newer: hide commands in M-x that do not work in the current mode.
  ;; (setq read-extended-command-predicate #'command-completion-default-include-p)
  ;;
  ;; Add prompt indicator to `completing-read-multiple'.
  ;; We display [CRM<separator>], e.g., [CRM,] if the separator is a comma.
  (defun crm-indicator (args)
    (cons (format "[CRM%s] %s"
                  (replace-regexp-in-string
                   "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
                   crm-separator)
                  (car args))
          (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)
  ;;
  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode))
;; vertico:1 ends here

;; [[file:../Config.org::*consult][consult:1]]
(leaf consult
  :bind (;; generic binds
         ("C-s" . consult-line)

         ;; C-c bindings in `mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ;; ("C-c )" . consult-kmacro)

         ;; C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command) ;; repeat-complex-command
         ("C-x b" . consult-buffer)            ;; switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame) ;; switch-to-buffer-other-frame
         ("C-x t b" . consult-buffer-other-tab) ;; switch-to-buffer-other-tab
         ("C-x r b" . consult-bookmark)         ;; bookmark-jump
         ("C-x p b" . consult-project-buffer) ;; project-switch-to-buffer
         ("C-x p C-b" . consult-project-buffer) ;; project-switch-to-buffer

         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-store)
         ;; ("C-M-#" . consult-register)
         ("C-M-#" . consult-register-load)

         ;; Other custom bindings
         ("M-y" . consult-yank-pop) ;; yank-pop
         ([remap Info-search] . consult-info)

         ;; M-g bindings in `goto-map'
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flymake) ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)   ;; goto-line
         ("M-g M-g" . consult-goto-line) ;; goto-line
         ("M-g o" . consult-outline) ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ("M-g O" . consult-org-heading)

         ;; M-s bindings in `search-map'
         ("M-s d" . consult-find) ;; Alternative: consult-fd
         ("M-s c" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ("M-s M" . consult-man)        ; T for terminal
         ("M-s I" . consult-info)

         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         (isearch-mode-map
          ("M-e" . consult-isearch-history)   ;; isearch-edit-string
          ("M-s e" . consult-isearch-history) ;; isearch-edit-string
          ("M-s l" . consult-line) ;; Needed by: consult-line to detect isearch
          ("M-s L" . consult-line-multi)) ;; Needed by: consult-line to detect isearch

         ;; Minibuffer history
         (minibuffer-local-map
          ("M-s" . consult-history) ;; next-matching-history-element
          ("M-r" . consult-history)) ;; previous-matching-history-element
         )
  :init
  (+leader-bind
    "s" search-map
    "Tt" 'consult-theme
    "bb" 'consult-buffer
    "fr" 'consult-recent-file
    "fm" 'consult-bookmark))

;; used to go to a file in a bookmarked dir n stuff (one ex)
(leaf consult-dir
  :init
  (+leader-bind
    "fd" 'consult-dir)
  :bind (("C-x C-d" . consult-dir)      ; default?
         (vertico-map
          ("C-x C-d" . consult-dir)
          ("C-x C-j" . consult-dir-jump-file)))
  ;; :custom
  ;; (consult-dir-project-list-function nil)
  )

;; TODO: do i even need to do this here?
;; - oh wait i do since the other module might overwrite...
;; - but the issue is that it never gets set if those modules
;; are never loaded...
;; - maybe in the other module files, only set those functions
;; if another bind isnt already there?
;; - is it possible to do eval-after-load 'thing OR after init?
;; and throw away the other autoload once one succeeds?

;; (defmacro mi/eval-now-and-after-load (feature &rest body)
;;   "Eval BODY, then if FEATURE is not loaded, eval BODY again after FEATURE loaded."
;;   (declare (indent defun))
;;   (let ((f (cadr feature)))
;;     `(progn
;;        ;; always eval now
;;        ,@body
;;        ;; if feature not loaded, eval again after load feature
;;        ,(unless (featurep f)
;;           `(eval-after-load ',f
;;              (lambda () ,@body))))))
;; consult:1 ends here

;; [[file:../Config.org::*embark][embark:1]]
(leaf embark
  :bind
  (("C-." . embark-act)
   ("C-;" . embark-dwim)
   ;; ("C-h B" . embark-bindings)
   )
  :init
  ;; use embark for showing command prefix help
  (setq prefix-help-command #'embark-prefix-help-command)

  ;; Show the Embark target at point via Eldoc. You may adjust the
  ;; Eldoc strategy, if you want to see the documentation from
  ;; multiple providers. Beware that using this can be a little
  ;; jarring since the message shown in the minibuffer can be more
  ;; than one line, causing the modeline to move up and down:

  ;; (add-hook 'eldoc-documentation-functions #'embark-eldoc-first-target)
  ;; (setq eldoc-documentation-strategy #'eldoc-documentation-compose-eagerly)
  :config
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))
;; embark:1 ends here

;; [[file:../Config.org::*embark-consult][embark-consult:1]]
(leaf embark-consult
  :after embark consult
  :hook (embark-collect-mode-hook . consult-preview-at-point-mode))
;; embark-consult:1 ends here

;; [[file:../Config.org::*orderless][orderless:1]]
(leaf orderless
  :require t
  :setq
  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (orderless-style-dispatchers . '(+orderless-consult-dispatch orderless-affix-dispatch))
  ;; (orderless-component-separator . #'orderless-escapable-split-on-space)
  (completion-styles . '(orderless basic))
  (completion-category-defaults . nil)
  (completion-category-overrides . '((file (styles partial-completion)))))
;; orderless:1 ends here

;; [[file:../Config.org::*marginalia][marginalia:1]]
(leaf marginalia
  :init
  (marginalia-mode 1)
  :bind ((minibuffer-local-map
          ("M-A" . marginalia-cycle))
         (completion-list-mode-map
          ("M-A" . marginalia-cycle))))
;; marginalia:1 ends here

;; [[file:../Config.org::*company][company:1]]
;; TODO: disable most backends by default add a bunch per mode (org should only have a few
(leaf company
  ;; :disabled t
  :require t
  :bind
  (company-active-map
   ("<return>" . nil)
   ("C-n" . nil)
   ("C-p" . nil)
   ("C-s" . company-filter-candidates))

  :config
  (company-tng-configure-default)
  (global-company-mode 1)

  (defun my/company-return-default-or-complete ()
    (interactive)
    ;; number if selected, nil if not
    (if company-selection
        (company-complete-selection)
      (company-abort)
      (execute-kbd-macro (kbd "<return>"))))
  (define-key company-tng-map (kbd "<return>") #'my/company-return-default-or-complete)

  (setq company-backends
        '(company-dabbrev company-files)) ; the default, overrides below
  (setq company-transformers nil)
  (setq lsp-completion-provider :none)
  (setq company-idle-delay 0.1)
  (setq company-selection-wrap-around t)
  (setq company-minimum-prefix-length 1)
  (setq company-dabbrev-downcase nil)
  (setq company-search-regexp-function 'company-search-words-in-any-order-regexp)

  ;; org-mode-specific backends

  (add-hook 'prog-mode-hook
            (lambda ()
              (setq-local company-backends
                          '((company-yasnippet :with company-capf)
                            company-dabbrev-code
                            company-files))
              (setq-local company-transformers '(company-sort-by-backend-importance))))

  (eval-after-load 'org
    '(add-hook 'org-mode-hook
               (lambda ()
                 (setq-local company-backends
                             '((company-dabbrev :with company-files))))))

  ;; separator for orderless completion:

  (defvar my/company-separator "&")

  (defun my/company-insert-separator ()
    "Insert `my/company-separator' during company completion."
    (interactive)
    (when (company-manual-begin)
      (insert my/company-separator)))

  (define-key company-active-map (kbd "M-SPC") #'my/company-insert-separator)

  (setq orderless-component-separator "[ &]")
  )

(leaf company-quickhelp
  :after company
  :bind ("C-c l h c" . company-quickhelp-mode)
  :setq
  (company-quickhelp-delay . 1)
  :config
  (company-quickhelp-mode 1))
;; company:1 ends here

;; [[file:../Config.org::*yasnippet][yasnippet:1]]
;; TODO: this is set up for eglot only, not lsp-mode

;; https://stackoverflow.com/questions/72601990/how-to-show-suggestions-for-yasnippets-when-using-eglot

(leaf yasnippet :ensure yasnippet-snippets
  :commands yas-reload-all
  :hook (prog-mode-hook . yas-minor-mode)
  :bind
  (yas-keymap
   ("RET" . yas-next-field-or-maybe-expand))
  :config
  (yas-reload-all))
;; yasnippet:1 ends here

;; [[file:../Config.org::*hippie-expand][hippie-expand:1]]
;; https://www.gnu.org/software/emacs/manual/html_node/autotype/Hippie-Expand.html

(global-set-key [remap dabbrev-expand] 'hippie-expand)
(add-to-list 'hippie-expand-try-functions-list #'yas-hippie-try-expand t)
;; hippie-expand:1 ends here

;; [[file:../Config.org::*isearch][isearch:1]]
(leaf isearch :ensure nil
  :bind
  ("C-M-s" . isearch-forward)
  ("C-M-r" . isearch-backward))
;; isearch:1 ends here

;; [[file:../Config.org::*corfu (disabled)][corfu (disabled):1]]
;;; CULPRIT OF HANGING, DISABLED.

;; (leaf corfu
;;   :require t
;;   :setq
;;   (corfu-cycle . t)        ;; Enable cycling through candidates
;;   (corfu-auto . t)         ;; Enable auto completion
;;   (corfu-auto-prefix . 1)  ;; Complete after typing 2 characters
;;   (corfu-auto-delay . 0.1) ;; Wait time before showing completions
;;   (corfu-preview-current . 'insert) ;; Preview first candidate
;;   (corfu-preselect . 'prompt)       ;; Preselect the prompt
;;   (corfu-on-exact-match . nil) ;; Don't auto-complete exact matches

;;   ;; Hide commands in M-x which do not apply to the current mode.  Corfu
;;   ;; commands are hidden, since they are not used via M-x. This setting is
;;   ;; useful beyond Corfu.
;;   (read-extended-command-predicate . #'command-completion-default-include-p)

;;   :bind (corfu-map
;;          ("TAB" . corfu-next)
;;          ([tab] . corfu-next)
;;          ("S-TAB" . corfu-previous)
;;          ([backtab] . corfu-previous)
;;          ("RET" . nil)
;;          ("C-n" . nil)
;;          ("C-p" . nil)
;;          ("C-RET" . corfu-insert))
;;   :init
;;   (global-corfu-mode))
;; corfu (disabled):1 ends here

;; [[file:../Config.org::*cape (disabled)][cape (disabled):1]]
;; (leaf cape
;;   ;; :disabled t
;;   :require t
;;   ;; Bind prefix keymap providing all Cape commands under a mnemonic key.
;;   ;; Press C-c p ? to for help.
;;   :bind ("M-+" . cape-prefix-map) ;; Alternative keys: M-p, M-+, ...
;;   ;; Alternatively bind Cape commands individually.
;;   ;; :bind (("C-c p d" . cape-dabbrev)
;;   ;;        ("C-c p h" . cape-history)
;;   ;;        ("C-c p f" . cape-file)
;;   ;;        ...)
;;   :init
;;   ;; Add to the global default value of `completion-at-point-functions' which is
;;   ;; used by `completion-at-point'.  The order of the functions matters, the
;;   ;; first function returning a result wins.  Note that the list of buffer-local
;;   ;; completion functions takes precedence over the global list.

;;   (add-hook 'completion-at-point-functions #'cape-dabbrev) ; current buffers
;;   (add-hook 'completion-at-point-functions #'cape-file)    ; file name
;;   ;; (add-hook 'completion-at-point-functions (cape-company-to-capf 'company-yasnippet))    ; file name
;;   ;; (add-hook 'completion-at-point-functions #'cape-elisp-block) ; code block (THE CULPRIT!!!!!)

;;   )

;; (leaf yasnippet-capf
;;   :after cape
;;   :config
;;   (defun my/capfs-add-yasnippet ()
;;     "Add yasnippet-capf to the front of completion-at-point-functions."
;;     ;; (add-to-list 'completion-at-point-functions #'yasnippet-capf)
;;     (setq-local completion-at-point-functions
;;                 (cons #'yasnippet-capf
;;                       completion-at-point-functions))
;;     )
;;   :hook (prog-mode-hook . my/capfs-add-yasnippet))

;; Configure Tempel
;; (use-package tempel
;;   ;; Require trigger prefix before template name when completing.
;;   ;; :custom
;;   ;; (tempel-trigger-prefix "<")

;;   :bind (("M-+" . tempel-complete) ;; Alternative tempel-expand
;;          ("M-*" . tempel-insert))

;;   :init

;;   ;; Setup completion at point
;;   (defun tempel-setup-capf ()
;;     ;; Add the Tempel Capf to `completion-at-point-functions'.
;;     ;; `tempel-expand' only triggers on exact matches. Alternatively use
;;     ;; `tempel-complete' if you want to see all matches, but then you
;;     ;; should also configure `tempel-trigger-prefix', such that Tempel
;;     ;; does not trigger too often when you don't expect it. NOTE: We add
;;     ;; `tempel-expand' *before* the main programming mode Capf, such
;;     ;; that it will be tried first.
;;     (setq-local completion-at-point-functions
;;                 (cons #'tempel-insert
;;                       completion-at-point-functions)))

;;   (add-hook 'conf-mode-hook 'tempel-setup-capf)
;;   (add-hook 'prog-mode-hook 'tempel-setup-capf)
;;   (add-hook 'text-mode-hook 'tempel-setup-capf)

;;   ;; Optionally make the Tempel templates available to Abbrev,
;;   ;; either locally or globally. `expand-abbrev' is bound to C-x '.
;;   ;; (add-hook 'prog-mode-hook #'tempel-abbrev-mode)
;;   ;; (global-tempel-abbrev-mode)
;;   )

;; Optional: Add tempel-collection.
;; The package is young and doesn't have comprehensive coverage.
;; (use-package tempel-collection)
;; cape (disabled):1 ends here

;; [[file:../Config.org::*abbrev (disabled)][abbrev (disabled):1]]
;; (leaf abbrev :ensure nil
;;   :bind (("C-c c a" . add-global-abbrev)
;;          ("C-c c -" . inverse-add-global-abbrev)
;;          ("C-c c e" . edit-abbrevs)))
;; abbrev (disabled):1 ends here

;; [[file:../Config.org::*generic tweaks for programming][generic tweaks for programming:1]]
(setq-default indent-tabs-mode nil)
(setq tab-always-indent t)

(leaf compile :ensure nil
  :setq
  (compilation-scroll-output . t))

(leaf flycheck
  :hook prog-mode-hook)
;; generic tweaks for programming:1 ends here

;; [[file:../Config.org::*lsp-mode][lsp-mode:1]]
(leaf lsp-mode
  :ensure lsp-ui
  :commands (lsp lsp-deferred)

  ;; bind "C-c l" to lsp-command-map
  :setq
  (lsp-keymap-prefix . "C-c l")
  ;; (lsp-ui-doc-show-with-cursor . t) ; def: nil
  ;; (lsp-ui-doc-side . 'right) ; def: right
  ;; (lsp-ui-doc-position . 'at-point)

  ;; problematic: https://github.com/emacs-lsp/lsp-mode/issues/4113
  (lsp-update-inlay-hints-on-scroll . nil)

  :bind-keymap
  ("C-c l" . lsp-command-map)

  :hook
  (lsp-mode-hook . lsp-enable-which-key-integration)
  ;; :config
  ;; (defface lsp-flycheck-warning-unnecessary '((t))
  ;;     "Face which apply to side line for symbols not used.
  ;; Possibly erroneously redundant of lsp-flycheck-info-unnecessary-face."
  ;;     :group 'lsp-ui-sideline)
  )

;;; lsp-booster
;; use lsp-doctor for testing
;; Steps:
;; - install emacs-lsp-booster
;; - use plist for deserialization (FOLLOW GUIDE)
(progn
  (setq read-process-output-max (* 1024 1024)) ;; 1mb
  (defun lsp-booster--advice-json-parse (old-fn &rest args)
    "Try to parse bytecode instead of json."
    (or
     (when (equal (following-char) ?#)
       (let ((bytecode (read (current-buffer))))
         (when (byte-code-function-p bytecode)
           (funcall bytecode))))
     (apply old-fn args)))
  (advice-add (if (progn (require 'json)
                         (fboundp 'json-parse-buffer))
                  'json-parse-buffer
                'json-read)
              :around
              #'lsp-booster--advice-json-parse)
  (defun lsp-booster--advice-final-command (old-fn cmd &optional test?)
    "Prepend emacs-lsp-booster command to lsp CMD."
    (let ((orig-result (funcall old-fn cmd test?)))
      (if (and (not test?) ;; for check lsp-server-present?
               (not (file-remote-p default-directory)) ;; see lsp-resolve-final-command, it would add extra shell wrapper
               lsp-use-plists
               (not (functionp 'json-rpc-connection)) ;; native json-rpc
               (executable-find "emacs-lsp-booster"))
          (progn
            (when-let ((command-from-exec-path (executable-find (car orig-result)))) ;; resolve command from exec-path (in case not found in $PATH)
              (setcar orig-result command-from-exec-path))
            (message "Using emacs-lsp-booster for %s!" orig-result)
            (cons "emacs-lsp-booster" orig-result))
        orig-result)))
  (advice-add 'lsp-resolve-final-command :around #'lsp-booster--advice-final-command))

;; TODO: move this to corfu ?
;; if corfu is installed
;; (https://github.com/minad/corfu/wiki#configuring-corfu-for-lsp-mode)
;; (use-package lsp-mode :ensure nil
;;   :commands (lsp lsp-deferred)
;;   :after corfu
;;   :custom
;;   (lsp-completion-provider :none) ; use corfu!
;;   :init
;;   (defun my/orderless-dispatch-flex-first (_pattern index _total)
;;     (and (eq index 0) 'orderless-flex))

;;   (defun my/lsp-mode-setup-completion ()
;;     (setf (alist-get 'styles (alist-get 'lsp-capf completion-category-defaults))
;;           '(orderless))
;;     ;; Optionally configure the first word as flex filtered.
;;     (add-hook 'orderless-style-dispatchers #'my/orderless-dispatch-flex-first nil 'local)
;;     ;; Optionally configure the cape-capf-buster.
;;     (setq-local completion-at-point-functions (list (cape-capf-buster #'lsp-completion-at-point))))

;;   :hook
;;   (lsp-completion-mode . my/lsp-mode-setup-completion))
;; lsp-mode:1 ends here

;; [[file:../Config.org::*project.el][project.el:1]]
(leaf project :ensure nil
  :bind-keymap ("C-c P" . project-prefix-map)
  :init
  (defun project-compile-interactive ()
    (declare (interactive-only compile))
    (interactive)
    (let ((current-prefix-arg '(4)))
      (call-interactively #'project-compile)))
  :bind
  (project-prefix-map
   ("C" . project-compile-interactive)))
;; project.el:1 ends here

;; [[file:../Config.org::*projectile][projectile:1]]
(leaf projectile
  :after
  :init
  (projectile-mode 1)
  :bind-keymap
  ("C-c p" . projectile-command-map))
;; projectile:1 ends here

;; [[file:../Config.org::*hex colors][hex colors:1]]
(leaf rainbow-mode
  :hook prog-mode-hook)
;; hex colors:1 ends here

;; [[file:../Config.org::*generic code settings][generic code settings:1]]
;; for non-programming too
(leaf elec-pair :ensure nil
  :require t
  :config
  ;; disable "<" pair expansion
  (defun my/disable-<-pair-expansion ()
    (setq-local electric-pair-inhibit-predicate
                `(lambda (c)
                   (if (char-equal c ?<)
                       t
                     (,electric-pair-inhibit-predicate c)))))
  (add-hook 'org-mode-hook #'my/disable-<-pair-expansion)
  ;; global
  (electric-pair-mode 1))
;; generic code settings:1 ends here

;; [[file:../Config.org::*settings for all lisps][settings for all lisps:1]]
(setq my/lisp-mode-hooks
      '(emacs-lisp-mode-hook
        scheme-mode-hook))

;; rainbow parens
(leaf rainbow-delimiters
  :hook `,@my/lisp-mode-hooks)

;; paredit
(leaf paredit
  :hook `,@my/lisp-mode-hooks)
;; settings for all lisps:1 ends here

;; [[file:../Config.org::*emacs-lisp][emacs-lisp:1]]
(leaf orglink
  :hook emacs-lisp-mode-hook)

;; other

(defun create-banner-comment (text &optional width)
  "Create a banner comment with TEXT centered between semicolons.
Optional WIDTH parameter determines total width (defaults to 70)."
  (interactive "sText: ")
  (let* ((width (or width 70))
         (text-len (length text))
         (semi-len (/ (- width text-len 2) 2)) ; -2 for spaces
         (left-semis (make-string semi-len ?\;))
         (right-semis (make-string
                       (if (cl-oddp (- width text-len))
                           (1+ semi-len)
                         semi-len)
                       ?\;)))
    (insert (format "%s %s %s\n"
                    left-semis
                    text
                    right-semis))))
;; emacs-lisp:1 ends here

;; [[file:../Config.org::*scheme][scheme:1]]
(leaf scheme-mode :ensure nil
  :disabled t
  :mode "\\.sld\\'" "\\.scm\\'")

(leaf geiser
  :disabled t
  :mode "\\.scm\\'"
  :setq
  (geiser-default-implementation . 'guile)
  (geiser-active-implementations . '(guile))
  (geiser-implementations-alist  . '(((regexp "\\.scm$") guile))))

(leaf geiser-guile
  :disabled t
  :after geiser)
;; scheme:1 ends here

;; [[file:../Config.org::*C][C:1]]
(leaf cc-mode :ensure nil
  :hook ((c-mode-hook . lsp)
         (c-mode-hook . (lambda ()
                          (setq-local lsp-idle-delay 0.1
                                      lsp-enable-indentation nil
                                      lsp-enable-on-type-formatting nil)
                          (c-set-offset 'case-label '+))))
  :config
  (add-to-list 'c-default-style '(c-mode . "cc-mode"))
  (define-key c-mode-map (kbd "<f8>") #'project-compile-interactive))
;; C:1 ends here

;; [[file:../Config.org::*java][java:1]]
(leaf lsp-java
  :disabled t
  :mode "\\.java\\'"
  :config
  (add-hook 'java-mode-hook #'lsp))
;; java:1 ends here

;; [[file:../Config.org::*markdown][markdown:1]]
(leaf markdown-mode
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode))
  :setq
  (markdown-fontify-code-blocks-natively . t)
  :config
  (defun my/setup-markdown-mode ()
    ;; (visual-fill-column-mode 1)
    (display-line-numbers-mode 0))

  ;; (setq markdown-command "marked")
  (add-hook 'markdown-mode-hook #'my/setup-markdown-mode))
;; markdown:1 ends here

;; [[file:../Config.org::*rust][rust:1]]
;; https://robert.kra.hn/posts/rust-emacs-setup

(leaf rustic
  :mode ("\\.rs\\'" . rustic-mode)
  :bind (rustic-mode-map
         ("C-c C-c M-r" . rustic-cargo-comint-run)
         ("C-c C-c l" . flycheck-list-errors)
         ("C-c C-c a" . lsp-execute-code-action)
         ("C-c C-c A" . rustic-cargo-add)
         ("C-c C-c r" . lsp-rename)
         ("C-c C-c R" . rustic-cargo-rm)
         ("C-c C-c q" . lsp-workspace-restart)
         ("C-c C-c Q" . lsp-workspace-shutdown)
         ("C-c C-c s" . lsp-rust-analyzer-status)
         ("C-c C-c h" . lsp-describe-thing-at-point))
  :config
  (setq rustic-cargo-use-last-stored-arguments t
        rustic-format-on-save t
        lsp-rust-analyzer-cargo-watch-command "clippy"
        lsp-rust-analyzer-display-lifetime-elision-hints-enable "skip_trivial"
        lsp-rust-analyzer-display-chaining-hints nil ; def: nil
        lsp-rust-analyzer-display-lifetime-elision-hints-use-parameter-names nil ; def: nil
        lsp-rust-analyzer-display-closure-return-type-hints t ; def: nil
        lsp-rust-analyzer-display-parameter-hints nil ; def: nil
        lsp-rust-analyzer-display-reborrow-hints t) ; def: never

  (add-hook 'rust-mode-hook #'my/rust-mode-hook)

  (defun my/rust-mode-hook ()
    (with-eval-after-load 'lsp-ui
      (setq-local lsp-ui-peek-always-show t
                  lsp-ui-sideline-delay 0.4
                  lsp-ui-doc-enable nil))
    (with-eval-after-load 'lsp-mode
      (setq-local lsp-idle-delay 0.4
                  lsp-inlay-hint-enable t
                  lsp-eldoc-render-all t))
    (with-eval-after-load 'company
      (setq-local company-idle-delay 0.4
                  company-minimum-prefix-length 1))))

;; rustowl
;; (straight-use-package
;;  `(rustowlsp
;;    :host github
;;    :repo "cordx56/rustowl"
;;    :files (:defaults "emacs/*")))
;; rust:1 ends here

;; [[file:../Config.org::*clojure][clojure:1]]
(leaf clojure-mode
  :disabled t)
;; clojure:1 ends here

;; [[file:../Config.org::*scala][scala:1]]
(leaf scala-mode
  :disabled t
  :interpreter "scala"
  :hook
  (lambda () (setq prettify-symbols-alist
                   scala-prettify-symbols-alist)))
;; scala:1 ends here

;; [[file:../Config.org::*zig][zig:1]]
(leaf zig-mode
  :disabled t
  ;; :config
  ;; (zig-format-on-save-mode 0)
  )
;; zig:1 ends here

;; [[file:../Config.org::*haskell][haskell:1]]
(leaf haskell-mode
  :mode "\\.hs\\'")
;; haskell:1 ends here

;; [[file:../Config.org::*nix][nix:1]]
(leaf nix-mode
  :mode "\\.nix\\'")
;; nix:1 ends here

;; [[file:../Config.org::*yaml][yaml:1]]
(leaf yaml-mode
  :mode "\\.yml\\'")
;; yaml:1 ends here

;; [[file:../Config.org::*direnv][direnv:1]]
(leaf direnv
  :init
  (direnv-mode 1))
;; direnv:1 ends here

;; [[file:../Config.org::*code-folding][code-folding:1]]
(leaf hideshow :ensure nil
  :hook
  (prog-mode-hook . hs-minor-mode)
  :config
  ;; new fold function
  (defun my/toggle-fold ()
    (interactive)
    (save-excursion
      (end-of-line)
      (hs-toggle-hiding)))
  ;; unset orig keymap from minor-mode
  (setf (alist-get 'hs-minor-mode minor-mode-map-alist) nil)
  ;; new custom keymap
  ;; (defvar my/hs-minor-mode-map
  ;;   (let ((map (make-sparse-keymap)))
  ;;     (define-key map (kbd "h") #'hs-hide-block)
  ;;     (define-key map (kbd "s") #'hs-show-block)
  ;;     (define-key map (kbd "a") #'hs-hide-all)
  ;;     (define-key map (kbd "r") #'hs-show-all)
  ;;     (define-key map (kbd "l") #'hs-hide-level)
  ;;     (define-key map (kbd "t") #'my/toggle-fold)
  ;;     map))
  ;; bind new keymap
  ;; (define-key global-map (kbd "C-c @") my/hs-minor-mode-map)
  ;; (with-eval-after-load 'lsp-mode
  ;;   (define-key lsp-command-map (kbd "t") my/hs-minor-mode-map))
  ;; hydra
  (defhydra hydra-folding (:color red)
    "Code folding"
    ("t" my/toggle-fold "toggle")
    ("l" hs-hide-level  "hide level")
    ("s" hs-show-block  "show block")
    ("h" hs-hide-block  "hide block")
    ("S" hs-show-all    "Show all")
    ("H" hs-hide-all    "Hide all")
    ("n" next-line      "next line")
    ("p" previous-line  "previous line")
    ("j" scroll-up-command "down")
    ("k" scroll-down-command "up")
    ("g" nil "quit")
    ("c" nil "close"))
  (+leader-bind
    "@" 'hydra-folding/body))
;; code-folding:1 ends here

;; [[file:../Config.org::*org-mode][org-mode:1]]
;; NOTE: ensure that the newest version of org is installed right after elpaca setup
(leaf org :ensure nil
  :setq
  (org-directory . "~/Notes/org")
  (org-tags-column . -55)          ; column where tags are indented to
  (org-startup-folded . 'showall)  ; default folding mode
  (org-startup-indented . t)       ; indent headings and its body
  (org-special-ctrl-a/e . t)
  (org-src-window-setup . 'current-window) ; edit code blocks in the same window
  (org-return-follows-link . t)            ; RET can open links
  (org-hide-emphasis-markers . t) ; hide formatting chars (* / ~ = etc)
  (org-src-preserve-indentation . t) ; remove annoying leading whitespace in code blocks
  (org-fontify-whole-heading-line . t)

  :init
  (+leader-bind
    "o" '(:ignore t :which-key "org"))

  :hook (org-mode-hook . indent-tabs-mode)

  :config
  (defun my/org-insert-subheading-respect-content ()
    "Insert new subheading after the current heading's body.
If in a list, inserts a new sublist after the current list."
    (interactive)
    (org-meta-return)
    (org-metaright))

  :bind (org-mode-map
         ("C-M-<return>"
          . my/org-insert-subheading-respect-content))

  :defer-config

  ;; set org font sizes
  (dolist (pair '((org-document-title :height 1.9 :weight bold)
                  (org-level-1 :height 1.7 :weight bold)
                  (org-level-2 :height 1.4 :weight bold)
                  (org-level-2 :height 1.1)
                  (org-level-3 :height 1.1)))
    (apply #'set-face-attribute (car pair) nil (cdr pair)))

  (require 'org-tempo)
  (add-to-list 'org-structure-template-alist '("sh" . "src shell"))
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist '("py" . "src python"))
  (add-to-list 'org-structure-template-alist '("gcc" . "src c"))
  (add-to-list 'org-structure-template-alist '("scm" . "src scheme"))
  (add-to-list 'org-structure-template-alist '("conf" . "src conf"))
  (add-to-list 'org-structure-template-alist '("java" . "src java"))
  (add-to-list 'org-structure-template-alist '("unix" . "src conf-unix"))
  (add-to-list 'org-structure-template-alist '("clang" . "src c"))

  )

(leaf org-download
  :after org
  :config
  (org-download-enable)
  :setq-default
  (org-download-image-dir . "_images"))

(leaf org-bullets
  :hook org-mode-hook
  :setq
  (org-bullets-bullet-list
   . '("◉"
       "●"
       "○"
       "■"
       "□"
       "✦"
       "✧"
       "✿")))

(leaf toc-org
  :hook org-mode-hook)

(leaf anki-editor
  :commands (anki-editor-push-note-at-point
             anki-editor-push-notes
             anki-editor-push-new-notes)
  :setq
  (anki-editor-latex-style . 'mathjax)
  :defer-config
  (defun my/ensure-anki-editor-mode (note)
    "Ensure `anki-editor-mode' is enabled before pushing notes."
    (unless anki-editor-mode
      (anki-editor-mode 1)))
  (advice-add #'anki-editor--push-note :before #'my/ensure-anki-editor-mode))

(use-package f :ensure (:wait f))
(leaf image-slicing :ensure nil
  :hook org-mode-hook
  :setq
  (image-slicing-newline-trailing-text . nil))
;; org-mode:1 ends here

;; [[file:../Config.org::*org-agenda][org-agenda:1]]
(leaf org-agenda :ensure nil
  :after org
  :init
  (+leader-bind
    "oa" 'org-agenda)

  :bind (org-agenda-mode-map
         (")" . 'org-agenda-todo))

  :config
  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)"
                    "|"
                    "DONE(d/!)")))
  (setq org-agenda-files
        (list "~/Notes/org/Inbox.org"
              "~/Notes/org/agenda.org"))
  (setq org-tag-alist
        '(;; Places
          ("@home"   . ?H)
          ("@school" . ?S)
          ;; ("@work" . ?W)
          ;; Activities
          ("@task" . ?t)
          ("@studying" . ?s)
          ("@errands"  . ?e)
          ("@tidy" . ?y)
          ("@creative" . ?c)
          ("@art" . ?a)
          ("@programming" . ?p)
          ("@today" . ?T)
          ;; ("@calls" . ?l)
          ;; Devices
          ("@phone" . ?P)
          ("@computer" . ?C)))
  (setq org-agenda-prefix-format
        `((agenda
           . ,(concat " %i "
                      "%?-12t"
                      "[%3(my/org-get-prop-effort)]    "
                      ;; "%3(my/org-get-prop-effort)  "
                      "% s"))
          (todo   . " %i ")
          (tags   . " %i %-12:c")
          ;; (search . " %i %-12:c")
          (search . " %c")
          ))

  (defun my/org-get-prop-effort ()
    (if (not (eq major-mode 'org-mode)) ""
      (let ((val (org-entry-get nil "EFFORT")))
        (if (not val) ""
          (format "%s" (string-trim val))))))

  (require 'org-habit)
  (add-to-list 'org-modules 'org-habit t))

(leaf org-super-agenda
  :after org-agenda
  :require t
  :config
  (org-super-agenda-mode 1)
  :setq
  (org-agenda-custom-commands
   . `(
       ("a" "main agenda"
        ((agenda ""
                 ((org-agenda-show-future-repeats nil)
                  ;; (org-agenda-start-on-weekday nil)
                  (org-agenda-span 'week)
                  (org-habit-show-habits nil)
                  (org-agenda-skip-deadline-if-done t)
                  (org-agenda-skip-scheduled-if-done t)))
         (todo "NEXT")
         (agenda ""
                 ((org-agenda-span 1)
                  (org-agenda-use-time-grid nil)
                  (org-super-agenda-groups
                   '((:name none
                            :habit t)
                     (:discard (:anything t)))))))))))

(leaf org-ql
  :after org)

(leaf org-pomodoro
  :after org)

(leaf org-noter
  :after org
  :bind (("C-c o n" . org-noter)
         ("C-c d n" . org-noter-start-from-dired))
  :setq
  (org-noter-doc-split-fraction . '(0.7 . 0.6)))
;; org-agenda:1 ends here

;; [[file:../Config.org::*org-capture][org-capture:1]]
(leaf org-capture :ensure nil
  :after org
  :init
  (+leader-bind
    "oc" 'org-capture)

  :config
  (defun my/get-org-agenda-denote-file (name)
    (let ((regex (format "^.*--%s__.*\\.org$" name)))
      (car (seq-filter
            (lambda (path)
              (string-match regex (file-name-nondirectory path)))
            org-agenda-files))))

  (setq org-capture-templates
        `(("t" "Tasks")

          ("td" "Todo with deadline" entry
           (file ,(my/get-org-agenda-denote-file "agenda"))
           "* TODO %^{Task}\nDEADLINE: %^{Deadline}t\n%?\n"
           :empty-lines 1
           :immediate-finish nil)

          ("tp" "Task" entry
           (file ,(my/get-org-agenda-denote-file "agenda"))
           "* TODO %?\n  %U\n  %a\n  %i" :empty-lines 1)

          ("n" "New note (with Denote)" plain
           (file denote-last-path)
           #'denote-org-capture :no-save t :immediate-finish nil
           :kill-buffer t :jump-to-captured t))))
;; org-capture:1 ends here

;; [[file:../Config.org::*org-latex][org-latex:1]]
;; TODO: implement one-time load after cdlatex loads, but before cdlatex is enabled
(leaf auctex
  :require t)

(leaf cdlatex
  :after auctex
  :hook (org-mode-hook . turn-on-org-cdlatex)
  :setq
  (org-preview-latex-default-process . 'dvisvgm)
  (org-latex-create-formula-image-program . 'dvisvgm)
  (org-latex-preview-ltxpng-directory . "_ltximg/")
  :config
  (defun org-try-cdlatex-tab ()
    "Check if it makes sense to execute `cdlatex-tab', and do it if yes.
It makes sense to do so if `org-cdlatex-mode' is active and if the cursor is
  - inside a LaTeX fragment, or
  - after the first word in a line, where an abbreviation expansion could
    insert a LaTeX environment."
    (when org-cdlatex-mode
      (cond
       ;; Before any word on the line: No expansion possible.
       ;; ((save-excursion (skip-chars-backward " \t") (bolp)) nil)
       ;; Just after first word on the line: Expand it.  Make sure it
       ;; cannot happen on headlines, though.
       ;; ((save-excursion
       ;;    (skip-chars-backward "a-zA-Z0-9*")
       ;;    (skip-chars-backward " \t")
       ;;    (and (bolp) (not (org-at-heading-p))))
       ;;  (cdlatex-tab) t)
       ((org-inside-LaTeX-fragment-p) (cdlatex-tab) t))))
  :init
  (defun my/org-latex-preview-buffer ()
    (interactive)
    (if (not (derived-mode-p 'org-mode))
        (message "Not in org-mode.")
      (org-latex-preview '(16))))
  (+leader-bind
    "ol" 'my/org-latex-preview-buffer))

(leaf org-fragtog
  :hook org-mode-hook)
;; org-latex:1 ends here

;; [[file:../Config.org::*org extras][org extras:1]]
(defun my/org-priority-to-anki ()
  (interactive)
  ;; check connection with anki
  (unless (or (boundp 'anki-editor-mode) anki-editor-mode)
    (anki-editor-mode 1))
  (anki-editor-api-check)
  ;; delete anki_note_type and/or anki_note_id for each w/o a priority
  (save-excursion
    (let ((points-no-priority
           (org-ql-query
             :select #'point-marker
             :from (current-buffer)
             :where
             '(and (not (priority))
                   (or (property "ANKI_NOTE_ID")
                       (property "ANKI_NOTE_TYPE"))))))
      (dolist (p (reverse points-no-priority))
        (goto-char p)
        (when (org-find-property "ANKI_NOTE_ID")
          (anki-editor-delete-note-at-point))
        (when (org-find-property "ANKI_NOTE_TYPE")
          (org-delete-property "ANKI_NOTE_TYPE")))))
  ;; ensure all priority headings have anki_note_type set
  (save-excursion
    (let ((points-yes-priority
           (org-ql-query
             :select #'point-marker
             :from (current-buffer)
             :where '(priority))))
      (dolist (p (reverse points-yes-priority))
        (goto-char p)
        (unless (org-entry-get nil "ANKI_NOTE_TYPE")
          (anki-editor-set-note-type nil "Basic"))))))

(defun my/org-clone-with-fraction (days time effort)
  "Clone subtree with time shifts, prefixing each subheading with fraction prefix."
  (interactive
   (list
    (read-number "How many days to complete it over?: ")
    (read-number "How many minutes do you expect this task to take?: ")
    (read-number "On a scale of 1-10, how much effort will this take?: ")))
  (setq days (1- days))
  ;; create clones
  (org-clone-subtree-with-time-shift days "-1d")
  (org-set-property "TIME" (format "%s" time))
  (org-set-property "EFFORT" (format "%s" effort))
  ;; adjust appropriately
  (save-excursion
    (org-next-visible-heading 1)
    ;; first, sort
    (cl-loop for depth from (1- days) downto 1 do
             (save-excursion
               ;; shift
               (dotimes (_ depth)
                 (org-metadown))))
    ;; add todo and demote
    (save-excursion
      (cl-loop repeat (1- days) do
               (org-next-visible-heading 1))
      (cl-loop for depth from (1- days) downto 0 do
               (let ((frac (format "%d/%d" (1+ depth) days))
                     (time-daily (/ time days)))
                 (org-demote)
                 (let ((org-special-ctrl-a/e t))
                   (org-beginning-of-line))
                 (insert (concat frac " "))
                 (org-set-property "FRACTION" frac)
                 (org-set-property "TIME" (format "%s" time-daily))
                 (org-set-property "EFFORT" (format "%s" effort))
                 (org-next-visible-heading -1))))))
;; org extras:1 ends here

;; [[file:../Config.org::*persp-mode][persp-mode:1]]
(leaf persp-mode
  ;; :disabled t
  :bind-keymap
  ("C-c w w" . persp-key-map)
  ("C-c ." . persp-key-map)
  ("C-c (" . persp-key-map)
  :setq
  (wg-morph-on . nil)
  (persp-autokill-buffer-on-remove . 'kill-weak)
  (persp-auto-resume-time . 1)
  ;; prevent issue with persp-special-last-buffer
  :hook
  (elpaca-after-init-hook . (lambda () (persp-mode 1)))
  ;; :init
  ;; (setq persp-is-ibc-as-f-supported nil)
  ;; (persp-mode)
  ;; (message "persp-mode enabled?")
  ;; (with-eval-after-load 'persp-mode
  ;;   (message "persp-mode enabled!!!"))
  ;; (add-to-list 'find-file-hook (lambda () (message "WOWWWW WHYYYY")))
  :commands
  persp-consult-source ;; defined below
  :config
  ;; dont save persp-nil to file
  (set-persp-parameter 'dont-save-to-file t nil)
  ;; consult-buffer integration
  (defvar persp-consult-source
    (list :name     "Perspective"
          :narrow   ?s
          :category 'buffer
          :state    #'consult--buffer-state
          :history  'buffer-name-history
          :default  t
          :items
          (lambda ()
            (let ((curr-persp (get-current-persp)))
              (consult--buffer-query
               :sort 'visibility
               :predicate (lambda (buf)
                            (if curr-persp
                                (persp-contain-buffer-p buf)
                              t))
               :as 'buffer-name)))))
  (with-eval-after-load 'consult
    (consult-customize consult--source-buffer :hidden t :default nil)
    (add-to-list 'consult-buffer-sources persp-consult-source)))

;; enable persp-mode-project-bridge mode

;; (when nil
;;   (with-eval-after-load "persp-mode"
;;     (defvar persp-mode-projectile-bridge-before-switch-selected-window-buffer nil)

;;     ;; (setq persp-add-buffer-on-find-file 'if-not-autopersp)

;;     (persp-def-auto-persp
;;      "projectile"
;;      :parameters '((dont-save-to-file . t)
;;                    (persp-mode-projectile-bridge . t))
;;      :hooks '(projectile-before-switch-project-hook
;;               projectile-after-switch-project-hook
;;               projectile-find-file-hook
;;               find-file-hook)
;;      :dyn-env '((after-switch-to-buffer-adv-suspend t))
;;      :switch 'frame
;;      :predicate
;;      #'(lambda (buffer &optional state)
;;          (if (eq 'projectile-before-switch-project-hook
;;                  (alist-get 'hook state))
;;              state
;;            (and
;;             projectile-mode
;;             (buffer-live-p buffer)
;;             (buffer-file-name buffer)
;;             ;; (not git-commit-mode)
;;             (projectile-project-p)
;;             (or state t))))
;;      :get-name
;;      #'(lambda (state)
;;          (if (eq 'projectile-before-switch-project-hook
;;                  (alist-get 'hook state))
;;              state
;;            (push (cons 'persp-name
;;                        (concat "[p] "
;;                                (with-current-buffer (alist-get 'buffer state)
;;                                  (projectile-project-name))))
;;                  state)
;;            state))
;;      :on-match
;;      #'(lambda (state)
;;          (let ((hook (alist-get 'hook state))
;;                (persp (alist-get 'persp state))
;;                (buffer (alist-get 'buffer state)))
;;            (pcase hook
;;              (projectile-before-switch-project-hook
;;               (let ((win (if (minibuffer-window-active-p (selected-window))
;;                              (minibuffer-selected-window)
;;                            (selected-window))))
;;                 (when (window-live-p win)
;;                   (setq persp-mode-projectile-bridge-before-switch-selected-window-buffer
;;                         (window-buffer win)))))

;;              (projectile-after-switch-project-hook
;;               (when (buffer-live-p
;;                      persp-mode-projectile-bridge-before-switch-selected-window-buffer)
;;                 (let ((win (selected-window)))
;;                   (unless (eq (window-buffer win)
;;                               persp-mode-projectile-bridge-before-switch-selected-window-buffer)
;;                     (set-window-buffer
;;                      win persp-mode-projectile-bridge-before-switch-selected-window-buffer)))))

;;              (find-file-hook
;;               (setcdr (assq :switch state) nil)))
;;            (if (pcase hook
;;                  (projectile-before-switch-project-hook nil)
;;                  (t t))
;;                (persp--auto-persp-default-on-match state)
;;              (setcdr (assq :after-match state) nil)))
;;          state)
;;      :after-match
;;      #'(lambda (state)
;;          (when (eq 'find-file-hook (alist-get 'hook state))
;;            (run-at-time 0.5 nil
;;                         #'(lambda (buf persp)
;;                             (when (and (eq persp (get-current-persp))
;;                                        (not (eq buf (window-buffer (selected-window)))))
;;                               ;; (switch-to-buffer buf)
;;                               (persp-add-buffer buf persp t nil)))
;;                         (alist-get 'buffer state)
;;                         (get-current-persp)))
;;          (persp--auto-persp-default-after-match state)))

;;     ;; (add-hook 'persp-after-load-state-functions
;;     ;;           #'(lambda (&rest args) (persp-auto-persps-pickup-buffers)) t)
;;     ))

;; Shows groups for all perspectives. But can't show same buffer in multiple groups.

;; (with-eval-after-load "ibuffer"

;;   (require 'ibuf-ext)

;;   (define-ibuffer-filter persp
;;       "Toggle current view to buffers of current perspective."
;;     (:description "persp-mode"
;;                   :reader (persp-prompt nil nil (safe-persp-name (get-frame-persp)) t))
;;     (find buf (safe-persp-buffers (persp-get-by-name qualifier))))

;;   (defun persp-add-ibuffer-group ()
;;     (let ((perspslist (mapcar #'(lambda (pn)
;;                                   (list pn (cons 'persp pn)))
;;                               (nconc
;;                                (cl-delete persp-nil-name
;;                                           (persp-names-current-frame-fast-ordered)
;;                                           :test 'string=)
;;                                (list persp-nil-name)))))
;;       (setq ibuffer-saved-filter-groups
;;             (cl-delete "persp-mode" ibuffer-saved-filter-groups
;;                        :test 'string= :key 'car))
;;       (push
;;        (cons "persp-mode" perspslist)
;;        ibuffer-saved-filter-groups)))

;;   (defun persp-ibuffer-visit-buffer ()
;;     (interactive)
;;     (let ((buf (ibuffer-current-buffer t))
;;           (persp-name (get-text-property
;;                        (line-beginning-position) 'ibuffer-filter-group)))
;;       (persp-switch persp-name)
;;       (switch-to-buffer buf)))

;;   (define-key ibuffer-mode-map (kbd "RET") 'persp-ibuffer-visit-buffer)

;;   (add-hook 'ibuffer-mode-hook
;;             #'(lambda ()
;;                 (persp-add-ibuffer-group)
;;                 (ibuffer-switch-to-saved-filter-groups "persp-mode"))))
;; persp-mode:1 ends here

;; [[file:../Config.org::*perspective (disabled)][perspective (disabled):1]]
;; (leaf perspective
;;   :init
;;   (persp-mode)
;;   ;; :custom
;;   ;; `(persp-mode-prefix-key . ,(kbd "C-c ."))
;;   :bind
;;   ("C-x C-b" . persp-list-buffers) ; or use a nicer switcher, see below
;;   ("C-c ." . perspective-map)
;;   (perspective-map
;;    ("S" . persp-state-save)
;;    ("M-s" . persp-state-save)
;;    ("C-s" . nil))
;;   :hook
;;   (kill-emacs-hook . persp-state-save)
;;   :config
;;   ;; default backup file
;;   (setq persp-state-default-file
;;         (file-name-concat persp-save-dir "persp-auto-save"))
;;   ;; prev/next buffers
;;   (setq switch-to-prev-buffer-skip
;;         (lambda (win buff bury-or-kill)
;;           (not (persp-is-current-buffer buff))))
;;   ;; consult-buffer
;;   (with-eval-after-load 'consult
;;     (setq my/persp-consult-source
;;           '(:name "Perspective"
;;                   :narrow 115           ; ?s
;;                   :category buffer
;;                   :state consult--buffer-state
;;                   :history buffer-name-history
;;                   :default t
;;                   :items #[0 "\300\301\302\303\304\305\306&\207"
;;                              [consult--buffer-query
;;                               :sort visibility
;;                               :predicate (lambda (buf)
;;                                            (persp-is-current-buffer buf t))
;;                               :as buffer-name]
;;                              7]))
;;     (consult-customize consult--source-buffer :hidden t :default nil)
;;     (add-to-list 'consult-buffer-sources my/persp-consult-source)))
;; perspective (disabled):1 ends here

;; [[file:../Config.org::*activities (disabled)][activities (disabled):1]]
;; (leaf activities
;;   :disabled t
;;   :init
;;   (activities-mode)
;;   ;; (activities-tabs-mode)
;;   ;; prevent edebug default bindings from interfering
;;   ;; (setq edebug-inhibit-emacs-lisp-mode-bindings t)

;;   (defvar activities-mode-map
;;     (let ((map (make-sparse-keymap)))
;;       (define-key map (kbd "n") #'activities-new)
;;       (define-key map (kbd "d") #'activities-define)
;;       (define-key map (kbd "a") #'activities-resume)
;;       (define-key map (kbd "s") #'activities-suspend)
;;       (define-key map (kbd "k") #'activities-kill)
;;       (define-key map (kbd "RET") #'activities-switch)
;;       (define-key map (kbd "b")   #'activities-switch-buffer)
;;       (define-key map (kbd "g")   #'activities-revert)
;;       (define-key map (kbd "l")   #'activities-list)
;;       ;; set up autoloads
;;       (let ((cmds (mapcar #'cdr (cdr map))))
;;         (dolist (c cmds)
;;           (unless (fboundp c)
;;             (autoload c "activities" nil t))))
;;       ;; return map
;;       map))
;;   ;; bind map
;;   (global-set-key (kbd "C-x C-a") activities-mode-map)
;;   (global-set-key (kbd "C-c .") activities-mode-map))
;; activities (disabled):1 ends here

;; [[file:../Config.org::*eat][eat:1]]
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
;; eat:1 ends here

;; [[file:../Config.org::*eshell][eshell:1]]
(leaf eshell :ensure nil
  :bind
  ("C-c a e" . eshell))
;; eshell:1 ends here

;; [[file:../Config.org::*magit][magit:1]]
(leaf magit
  :preface (elpaca transient) ; HACK: magit needs newer version
  :setq
  (magit-display-buffer-function . #'magit-display-buffer-same-window-except-diff-v1)
  :bind
  ("C-c v" . magit))
;; magit:1 ends here

;; [[file:../Config.org::*pdf][pdf:1]]
(leaf pdf-tools
  :config
  (pdf-loader-install)) ; On demand loading, leads to faster startup time
;; pdf:1 ends here

;; [[file:../Config.org::*elfeed][elfeed:1]]
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
;; elfeed:1 ends here

;; [[file:../Config.org::*fonts][fonts:1]]
(defvar my/font-alist
  `((hack . "Hack")
    (tamzenPL-16
     . "-Misc-TamzenForPowerline-regular-normal-normal-*-16-*-*-*-c-80-iso10646-1")
    (ttyp0-17   .   "-UW  -Ttyp0-regular-normal-normal-*-17-*-*-*-m-*-iso8859-1")
    (ttyp0-17-b .        "-UW-Ttyp0-bold-normal-normal-*-17-*-*-*-c-90-iso8859-1")
    (ttyp0-16   .   "-UW  -Ttyp0-regular-normal-normal-*-16-*-*-*-m-*-iso8859-1")
    (ttyp0-16-i .   "-UW  -Ttyp0-regular-italic-normal-*-16-*-*-*-m-*-iso10646-1")
    (gb-16 . "-AW-Greybeard 16px-regular-normal-normal-*-16-*-*-*-c-80-iso10646-1")))

(defun my/fontconfig ()
  "Set default font face."
  (set-face-attribute 'default nil :font (alist-get 'ttyp0-16 my/font-alist)))

(my/fontconfig)

;; HACK: fix bitmap fonts on emacsclient frames
(add-hook 'server-after-make-frame-hook #'my/fontconfig)
;; fonts:1 ends here

;; [[file:../Config.org::*themes][themes:1]]
;;; Function: `load-theme' but fixed theme-bleeding issue.

;;; obsolete, replaced with consult-theme.

;; (defun +load-theme (theme &optional no-confirm no-enable)
;;   "Prevent `load-theme' from having theme-bleeding issues.
;; The args THEME, NO-CONFIRM and NO-ENABLE are passed to `load-theme'."
;;   (interactive
;;    (list
;;     (intern (completing-read "Load custom theme: "
;;                              (mapcar #'symbol-name
;;                                      (custom-available-themes))))
;;     nil nil))
;;   ;; disable all enabled themes
;;   (mapc #'disable-theme custom-enabled-themes)
;;   ;; enable theme
;;   (if (custom-theme-p theme)
;;       (enable-theme theme)
;;     (load-theme theme :no-confirm))
;;   )


;;; Function: sets a random theme.

(defun my/set-random-theme ()
  "Set a random theme."
  (interactive)
  (let* ((available-themes (custom-available-themes))
         (current-theme (car custom-enabled-themes))
         (themes-except-current (remove current-theme available-themes))
         (chosen-theme (nth (random (length themes-except-current))
                            themes-except-current)))
    ;; disable all enabled themes
    (mapc #'disable-theme custom-enabled-themes)
    ;; enable randomly chosen theme
    (if (custom-theme-p chosen-theme)
        (enable-theme chosen-theme)
      (load-theme chosen-theme :no-confirm))
    ;; mesg
    (message "Enabled theme: %s" chosen-theme)))

;; Install themes

(leaf emacs :elpaca nil
  :preface
  (leaf kaolin-themes
    :require t)
  (leaf ef-themes
    :require t)
  (leaf doom-themes
    :require t
    :setq
    (doom-themes-enable-bold   . t) ; if nil, bold is universally disabled
    (doom-themes-enable-italic . t) ; if nil, italics is universally disabled
    )

  :leaf-defer nil
  :bind
  ("C-c T t" . consult-theme)
  ("C-c T r" . my/set-random-theme))

(leaf emacs :elpaca nil
  :after doom-themes kaolin-themes ef-themes
  :config
  (my/set-random-theme))
;; themes:1 ends here

;; [[file:../Config.org::*transparency][transparency:1]]
(defvar my/transparency-value 100)

(defun my/native-transparency-supported? ()
  "Whether native-transparency is supported on this version of Emacs."
  (if (version<= "29" emacs-version)
      t
    (message "Native transparency is not supported.")
    nil))

(defun my/toggle-transparency ()
  "Toggle transparency with `my/transparency-value'."
  (interactive)
  (when (my/native-transparency-supported?)
    (let ((alpha (frame-parameter nil 'alpha-background)))
      (set-frame-parameter
       nil 'alpha-background
       (if (eql (cond ((numberp alpha) alpha)
                      ((numberp (cdr alpha)) (cdr alpha))
                      ;; Also handle undocumented (<active> <inactive>) form.
                      ((numberp (cadr alpha)) (cadr alpha)))
                100)
           my/transparency-value
         100)))))

(defun my/set-transparency (value)
  "Set the transparency of the frame window to VALUE."
  (interactive "nTransparency Value 0 - 100 opaque: ")
  (when (my/native-transparency-supported?)
    (set-frame-parameter (selected-frame) 'alpha-background value)))
;; transparency:1 ends here

;; [[file:../Config.org::*line numbers][line numbers:1]]
;; list of programming modes to disable line-numbers on
(defvar my/display-line-numbers-exclude '())

;; enable line-numbers on programming modes
(add-hook 'prog-mode-hook
          (lambda ()
            (unless (memq major-mode my/display-line-numbers-exclude)
              (display-line-numbers-mode 1))))

(setq display-line-numbers-type 'relative)
;; line numbers:1 ends here

;; [[file:../Config.org::*line wrapping][line wrapping:1]]
(global-visual-line-mode 1)
(diminish 'visual-line-mode) ; hide "Wrap" in mode-line
;; line wrapping:1 ends here

;; [[file:../Config.org::*whitespace][whitespace:1]]
(leaf whitespace :ensure nil
  :hook ((prog-mode-hook . my/prog-mode-whitespace)
         (org-mode-hook  . my/prog-mode-whitespace)
         (text-mode-hook . my/prog-mode-whitespace))
  :init
  (defun my/prog-mode-whitespace ()
    (setq whitespace-style '(face trailing tabs tab-mark))
    (whitespace-mode 1)))
;; whitespace:1 ends here

;; [[file:../Config.org::*solaire][solaire:1]]
(leaf solaire-mode
  :config
  (defun real-buffer-p ()
    (or (solaire-mode-real-buffer-p)
        (equal (buffer-name) "*dashboard*")))
  (setq solaire-mode-real-buffer-fn #'real-buffer-p)

  (solaire-global-mode +1))
;; solaire:1 ends here

;; [[file:../Config.org::*mode-line][mode-line:1]]
;; show column # on modeline
(column-number-mode 1)

(leaf doom-modeline
  :config
  (doom-modeline-mode 1)
  ;; :config
  ;; (setq doom-modeline-modal-icon nil)
  )
;; mode-line:1 ends here

;; [[file:../Config.org::*scroll][scroll:1]]
;; Improve scroll
(leaf emacs :ensure nil
  :setq
  ;; (auto-window-vscroll nil) ; TODO: what does this do?
  (scroll-preserve-screen-position . t) ; keep point in same position while scrolling
  (scroll-conservatively . 101) ; dont move cursor to center while scrolling
  (scroll-margin . 2)           ; scroll margin of one line
  (mouse-wheel-scroll-amount
   . '(2                                      ; faster vscroll speed
       ((shift) . hscroll)                    ; S-<scroll> for hscroll
       ((meta) . nil)                         ; M-<scroll> for PgUp/PgDn
       ((control) . text-scale)               ; C-<scroll> for zoom
       ((control meta) . global-text-scale))) ; C-M-<scroll> for global zoom
  (mouse-wheel-scroll-amount-horizontal . 2)) ; faster hscroll speed
;; scroll:1 ends here

;; [[file:../Config.org::*dashboard][dashboard:1]]
(leaf dashboard
  :require t
  :config
  (setq dashboard-center-content t)
  (when (< (length command-line-args) 2)
    (add-hook 'window-size-change-functions #'dashboard-resize-on-hook 100)
    (add-hook 'window-setup-hook #'dashboard-resize-on-hook)
    (add-hook 'elpaca-after-init-hook
              (lambda ()
                (if (get-buffer "*Warnings*")
                    (setq initial-buffer-choice (lambda () (get-buffer "*Warnings*")))
                  (setq initial-buffer-choice (lambda () (get-buffer-create dashboard-buffer-name)))
                  (dashboard-insert-startupify-lists)
                  (dashboard-initialize))))))
;; dashboard:1 ends here

;; [[file:../Config.org::*prettify][prettify:1]]
(global-prettify-symbols-mode 1)
;; prettify:1 ends here

;; [[file:../Config.org::*server][server:1]]
(leaf server :ensure nil
  :doc "Autostarts an Emacs server. Connect to it using emacsclient."
  :require t
  :bind
  ("C-c q" . delete-frame)
  ("C-c Q" . save-buffers-kill-emacs)
  :config
  (defun my/start-server-if-not-running ()
    "Start the Emacs server if not running."
    (unless (or (processp server-process)
                (server-running-p))
      (server-start)
      (message "Emacsclient Server started!")))
  :hook
  (elpaca-after-init-hook . my/start-server-if-not-running))
;; server:1 ends here

;; [[file:../Config.org::*html][html:1]]
(leaf htmlize)

(leaf simple-httpd)

(leaf impatient-mode)
;; html:1 ends here

;; [[file:../Config.org::*denote][denote:1]]
;; Sample config:
;; https://protesilaos.com/emacs/denote#h:5d16932d-4f7b-493d-8e6a-e5c396b15fd6

;; TODO: to look into!!
;; - https://baty.blog/2022/keeping-my-org-agenda-updated
;; - https://forum.systemcrafters.net/t/bring-denote-into-org-agenda-with-prettyness/779
;; https://www.reddit.com/r/emacs/comments/1er9wj4/denote_and_agenda_practical_use/

;; Note:
;; - dired: "% m" then "t" then `k' to kill and filter down results

(leaf denote
  :init
  (+leader-bind
    "n" '(:ignore t :which-key "denote")
    "nn" 'denote
    "ns" 'denote-subdirectory
    ;; "nf" 'denote-open-or-create ;; moved to consult-notes

    ;; renaming
    "nr" '(:ignore t :which-key "rename file")
    "nrf" '(denote-rename-file :which-key "rename file")
    "nrt" '(denote-rename-file-title :which-key "rename title")
    "nrk" '(denote-rename-file-keywords :which-key "rename keywords")

    ;; dired
    "nd" '(:ignore t :which-key "dired")
    "ndj" '(my/denote-directory-jump :which-key "jump to denote dir")
    "ndr" '(denote-dired-rename-marked-files :which-key "marked rename")
    "ndk" '(denote-dired-rename-marked-files-add-keywords
            :which-key "marked add keywords")
    "ndK" '(denote-dired-rename-marked-files-remove-keywords
            :which-key "marked remove keywords")

    ;; links
    "nl" '(:ignore t :which-key "links")
    "nll" '(denote-find-link :which-key "find links in file")
    "nln" '(denote-link :which-key "new link")
    "nla" '(denote-add-links :which-key "add links for metanote")

    ;; backlinks
    "nb" '(:ignore t :which-key "backlinks")
    "nbb" '(denote-find-backlink :which-key "find backlinks")
    "nbl" '(denote-backlinks :which-key "list backlinks")

    ;; org-dblocks
    "no" '(:ignore t :which-key "org-dblocks")
    "nol" '(denote-org-extras-dblock-insert-links :which-key "dblock links")
    "nof" '(denote-org-extras-dblock-insert-files :which-key "dblock files")
    "nob" '(denote-org-extras-dblock-insert-backlinks :which-key "dblock backlinks")
    "noa" '(my/denote-insert-file-local-dblock-update-mode :which-key "insert file-local dblock mode")

    ;; journal
    "oj" '(denote-journal-extras-new-or-existing-entry :which-key "denote-journal")
    "nj" '(:ignore t :which-key "journal")
    "njj" '(denote-journal-extras-new-or-existing-entry :which-key "open today")
    "njo" '(denote-journal-extras-new-or-existing-entry :which-key "open today")
    "njn" '(denote-journal-extras-new-entry :which-key "new entry")
    "njl" '(denote-journal-extras-link-or-create-entry :which-key "link entry"))

  :config

  ;; variables
  (setq denote-directory (expand-file-name "~/Notes/denote"))
  (setq denote-known-keywords '("emacs" "meta"
                                "art" "hobbies" "ideas"
                                "class" "todo"
                                "calc1" "arthist"
                                "systemsoftware" "bio2"
                                "random"))
  (setq denote-prompts '(title keywords subdirectory))
  (setq denote-save-buffers t)
  (setq denote-excluded-directories-regexp
        (concat
         ;; (^|/) ... (/|$)
         "\\(^\\|/\\)" "[aA]rchived?" "\\(/\\|$\\)" "\\|"
         "\\(^\\|/\\)" "[eE]xcluded?" "\\(/\\|$\\)" "\\|"
         "\\(^\\|/\\)" "_.*"          "\\(/\\|$\\)"))

  ;; when renaming, don't prompt for modify-file-name
  (setq denote-rename-confirmations '(rewrite-front-matter))

  ;; prettify

  ;; rename buffer/mode-line
  (setq denote-rename-buffer-format "[D] %t%b  _%k")
  (denote-rename-buffer-mode 1)

  ;; dired fontify
  (add-hook 'dired-mode-hook #'denote-dired-mode)

  ;; links in text files
  (add-hook 'text-mode-hook #'denote-fontify-links-mode-maybe)

  ;; other

  (defun my/denote-directory-jump ()
    (interactive)
    (dired denote-directory))

  ;; org-capture

  (with-eval-after-load 'org-capture
    (add-to-list 'org-capture-templates
                 '("n" "New note (with Denote)" plain
                   (file denote-last-path)
                   #'denote-org-capture
                   :no-save t
                   :immediate-finish nil
                   :kill-buffer t
                   :jump-to-captured t)))

  ;; org-dblocks

  ;; (define-minor-mode org-dblock-update-minor-mode
  ;;   "A minor mode that automatically updates Org mode dynamic blocks before saving."
  ;;   :lighter " OrgDBlocks"
  ;;   :global nil
  ;;   (if (and org-dblock-update-minor-mode (eq major-mode 'org-mode))
  ;;    (add-hook 'before-save-hook #'org-update-all-dblocks nil t)
  ;;     (remove-hook 'before-save-hook #'org-update-all-dblocks t)))

  ;; (defun my/denote-insert-file-local-dblock-update-mode ()
  ;;   (interactive)
  ;;   (if (eq major-mode 'org-mode)
  ;;    (add-file-local-variable
  ;;     'eval
  ;;     '(org-dblock-update-minor-mode))
  ;;     (message "Not in an org-mode buffer")))

  ;; journal

  (require 'denote-journal-extras)
  (setq denote-journal-extras-directory
        (expand-file-name "journal" denote-directory)))


;; provides consult sources:
;; - "SPC D" for denote buffers
;; - "SPC S" for denote subdirectories
(leaf consult-denote
  :after consult-notes
  :config
  (consult-denote-mode 1))
;; TODO: write my own consult function for "SPC S".


;; Docs: https://github.com/mclear-tools/consult-notes
(leaf consult-notes
  :commands consult-notes consult-notes-search-in-all-notes
  :after org
  :bind ("M-s n" . consult-notes)
  :init
  (+leader-bind
    "nf" 'consult-notes
    "ng" 'consult-notes-search-in-all-notes)
  :config
  ;; denote keywords "_" fix
  (progn
    (setq consult-notes-denote-display-keywords-indicator "_")
    (defun consult-notes-denote--display-keywords (keywords)
      (format "%18s" (if keywords
                         (concat
                          consult-notes-denote-display-keywords-indicator
                          (mapconcat 'identity keywords "_"))
                       ""))))
  ;; custom printing format
  (progn
    (defun my/consult-notes--file-dir-annotate (name dir cand)
      "Annotate file CAND with its directory DIR, size, and modification time."
      (let* ((file  (concat (file-name-as-directory dir) cand))
             (dirs  (abbreviate-file-name dir))
             (attrs (file-attributes file))
             (fsize (file-size-human-readable (file-attribute-size attrs)))
             (ftime (consult-notes--time (file-attribute-modification-time attrs))))
        (message "DEBUGGGGG: %s %s %s" file name dirs)
        (put-text-property 0 (length name)  'face 'consult-notes-name name)
        (put-text-property 0 (length dirs)  'face 'consult-notes-name dirs)
        (put-text-property 0 (length fsize) 'face 'consult-notes-size fsize)
        (put-text-property 0 (length ftime) 'face 'consult-notes-time ftime)
        (format "%7s %8s  %12s  %8s" name fsize ftime dirs)))
    (setq consult-notes-file-dir-annotate-function #'my/consult-notes--file-dir-annotate))
  ;; enable for denote after load denote
  (with-eval-after-load 'denote
    (consult-notes-denote-mode 1)))

;; docs: https://lucidmanager.org/productivity/denote-explore/
(leaf denote-explore
  :after denote
  :init
  (+leader-bind
    "ne" '(:ignore t :which-key "explore")

    ;; random walks
    "new" '(:ignore t :which-key "random walks")
    "newl" '(denote-explore-random-link :which-key "random link")
    "newr" '(denote-explore-random-regex :which-key "random regex")
    "newk" '(denote-explore-random-keyword :which-key "random keyword")

    ;; janitor
    "nej" '(:ignore t :which-key "janitor")
    "nejj" '(denote-explore-sync-metadata :which-key "sync filenames from metadata")
    "nejm" '(denote-explore-sync-metadata :which-key "sync filenames from metadata")
    "nejs" '(denote-explore-sort-keywords :which-key "sort order of all keywords")
    "nejr" '(denote-explore-rename-keyword :which-key "rename keyword")
    "nej0" '(denote-explore-zero-keywords :which-key "0 keywords")
    "nej1" '(denote-explore-single-keywords :which-key "1 keywords")

    ;; visualize
    "nen" '(:ignore t :which-key "network")
    "nenn" '(denote-explore-network :which-key "network")
    "nenr" '(denote-explore-network-regenerate :which-key "network regenerate")
    "nend" '(denote-explore-degree-barchart :which-key "degree barchart")

    ;; stats
    "nes" '(:ignore t :which-key "stats")
    "nesk" '(denote-explore-barchart-keywords :which-key "barchart keywords")
    "nese" '(denote-explore-barchart-filetypes :which-key "barchart filetypes"))

  ;; :config
  ;; (setq denote-explore-network-format )
  ;; TODO: make denote-explore-network / browse-url-browser-function

  )

;; denote-menu
(leaf denote-menu
  :after denote
  :init
  (+leader-bind
    "nm" 'list-denotes)
  :bind (denote-menu-mode-map
         ("c" . denote-menu-clear-filters)
         ("r" . denote-menu-filter)
         ("k" . denote-menu-filter-by-keyword)
         ("o" . denote-menu-filter-out-keyword)
         ("/ r" . denote-menu-filter)
         ("/ k" . denote-menu-filter-by-keyword)
         ("/ o" . denote-menu-filter-out-keyword)
         ("e" . denote-menu-export-to-dired))
  :config
  (setq denote-menu-title-column-width 50))

;;; set common keys
;; (+leader-bind
;;   "nN" '(:ignore t :which-key "Favorites")
;;   "nNn" 'denote
;;   "")
;; denote:1 ends here

;; [[file:../Config.org::*emms][emms:1]]
;; no cover
;; (use-package listen)

;; emms extract metadata?
;; https://www.reddit.com/r/emacs/comments/981khz/emacs_music_player_with_emms/

;; TODO:
(leaf emms
  :config
  (emms-all)

  (setq emms-player-list '(
                           emms-player-mpd
                           ;; emms-player-mpv
                           ))

  ;; (require 'emms-player-mpv) ; disabled for mpd

  ;; variables

  (setq emms-source-file-default-directory "~/Music/library/")
  (setq emms-player-mpd-music-directory "~/Music/library/")

  ;; emms-player-mpv-parameters '("--no-audio-display=no"); broken
  (setq emms-browser-covers #'emms-browser-cache-thumbnail-async)
  ;; sort by natural order
  (setq emms-playlist-sort-function #'emms-playlist-sort-by-natural-order)
  ;; make streams update metadata
  (setq emms-player-mpv-update-metadata t)
  ;; playlist format use m3u
  (setq emms-source-playlist-default-format 'm3u)
  ;; show format
  (setq emms-show-format "NP: %s")
  ;; ;; sort album by natural order
  ;; ;; (setq  emms-browser-album-sort-function #'emms-playlist-sort-by-natural-order)
  ;; this actually sorts by natural order upon adding
  (add-hook 'emms-playlist-source-inserted-hook
            #'emms-playlist-sort-by-natural-order)

  ;; backends


  ;; get info from mpd
  ;; (add-to-list 'emms-info-functions 'emms-info-mpd)
  ;; ? show current song when next song starts?
  ;; (add-hook 'emms-player-started-hook #'emms-show)
  ;; connect to mpd
  ;; (setq emms-player-mpd-server-name "localhost")
  ;; (setq emms-player-mpd-server-port "6600")
  ;; (setq emms-player-mpd-music-directory "\~/Music/library")
  ;; (emms-player-mpd-connect)

  ;; persistent playlists
  ;; (require 'emms-history)
  (emms-history-load)

  ;; display
  (emms-mode-line-mode 0)

  ;; enable playerctl pausing

  ;; DISABLE LATER when using mpd-mpris service
  ;; (require 'emms-mpris)
  ;; (emms-mpris-enable) ;; (will make emacs hog mpris media playing active)

  ;; (setq emms-player-list '(emms-player-mpd))
  (add-to-list 'emms-info-functions 'emms-info-mpd)
  (add-to-list 'emms-player-list 'emms-player-mpd)

  ;; browser

  ;; TODO: add this function to emms-info-functions (hard to implement?)
  ;; (instead make my own function that runs ffprobe and gets info? might be better)
  (defun my/emms-show-album-cover-in-emacs ()
    (interactive)
    (if-let ((track (emms-playlist-current-selected-track))
             (song-path (emms-track-get track 'name))
             (cover-path "/tmp/emms-album-cover.jpg")) ;; is jpg fine?
        (if (not (file-exists-p song-path))
            (message "Error: cannot find path to currently playing song")
          (when (file-exists-p cover-path)
            (delete-file cover-path))
          (let ((exit-code
                 (shell-command
                  (message "extracting: %s"
                           (format "ffmpeg -i %s -an -vcodec copy %s -y"
                                   (shell-quote-argument song-path)
                                   (shell-quote-argument cover-path))))))
            (cond ((/= exit-code 0)
                   (message "Error: ffmpeg cover extraction failed with code %s"
                            exit-code))
                  ((file-exists-p cover-path)
                   (with-current-buffer (get-buffer-create "*Album Cover*")
                     (erase-buffer)
                     (insert-image (create-image cover-path))
                     (pop-to-buffer (current-buffer))))
                  (t
                   (message "Error: ffmpeg cover at cover-path not found.")))))
      (message "No song currently playing")))

  ;; Hook to display album cover in Emacs when the track changes
  ;; (add-hook 'emms-player-started-hook 'emms-show-album-cover-in-emacs)

  ;;;; Personal functions for features: ;;;;

  ;; Edit a playlist:
  ;; - steps:
  ;;   - create a new playlist buffer named "%s_real".
  ;;   - make modifications as needed.
  ;;   - command to write and delete buffer.
  ;; - create a function to reload the playlist from file, as well as write.
  ;; - indicator to show whether the playlist has been modified or not?
  ;;
  ;; Add a song to a playlist:
  ;; - steps:
  ;;   - create a new playlist buffer named "%s_real".
  ;;   - place the song at the bottom of the playlist.
  ;;   - make modifications as needed.
  ;;   - command to write and delete buffer.
  ;;
  ;;
  ;; workflow:
  ;; - idea: if playing a playlist (any) and i want to add a song from it to a specific playlist (regardless of if it's loaded or not), the process is to load the playlist from the file in a new buffer, make the change, save, then close. And for convenience, if that playlist i added the song in is loaded and i wanna see those changes be updated, run a function to reload the playlist from its source file.
  ;;
  ;; Ideas:
  ;; - playlist editing mode?
  ;; - edit one playlist at a time? bc need to preserve the source playlist file somewhere
  ;; - does a playlist file regenerate from the file when opened?
  ;; - command: `emms-playlist-editor-open-playlist'
  ;;   - emms-metaplaylist-mode-new-buffer (to create new buffer with buffer-name
  ;;   -
  ;;
  ;;
  ;; Implement:
  ;; - function: add a playlist file to a new playlist buffer ("%s_EDITING")

  ;;   (require 'cl-lib)

  ;;   (defvar emms-playlist-editor--buffer-name "EDITING"
  ;;     "The buffer name for editing.")

  ;;   (defvar emms-playlist-editor--current-path nil
  ;;     "The filepath to the current \"EDITING\" file.
  ;; Used in `emms-playlist-edit-open-playlist'.")

  ;;   (defun emms-playlist-editor-open-playlist ()
  ;;     (interactive)
  ;;     (let* ((buffer-name emms-playlist-editor--buffer-name)
  ;;         (buffer-real (get-buffer buffer-name)))
  ;;       ;; handle case if buffer already exists
  ;;       (when buffer-real
  ;;      (switch-to-buffer buffer-real)
  ;;      (if (yes-or-no-p (format "Buffer \"%s\" already exists. Delete and contiune?"
  ;;                               buffer-name))
  ;;          (kill-buffer buffer-name) ;; and continue...
  ;;        (message "aborting...")
  ;;        (return)))
  ;;       (let ((buf (get-buffer-create buffer-name)))
  ;;      ;; init new "EDITING" buffer as playlist buffer
  ;;      (with-current-buffer buf
  ;;        (emms-playlist-mode)
  ;;        (setq emms-playlist-buffer-p t))
  ;;      ;; update metaplaylist
  ;;      (emms-metaplaylist-mode-go)
  ;;      (emms-metaplaylist-mode-update)
  ;;      ;; go to new buffer
  ;;      (switch-to-buffer
  ;;       (emms-playlist-set-playlist-buffer buf))
  ;;      ;; select playlist file
  ;;      (let ((file (read-file-name "Playlist file: "
  ;;                                  emms-source-file-default-directory
  ;;                                  emms-source-file-default-directory
  ;;                                  t)))
  ;;        ;; add files
  ;;        (emms-add-playlist file)
  ;;        (setq emms-playlist-editor--current-path file)
  ;;        ))))

  ;;   (defun emms-playlist-editor-save-playlist ()
  ;;     (interactive)
  ;;     (let* ((buffer-name emms-playlist-editor--buffer-name)
  ;;         (buffer-real (get-buffer buffer-name))
  ;;         (path emms-playlist-editor--current-path))
  ;;       (if (not buffer-real)
  ;;        (message "Buffer \"%s\" doesn't exist, exiting..." buffer-name)
  ;;      (switch-to-buffer
  ;;       (emms-playlist-set-playlist-buffer buffer-real))
  ;;      ;; save to file
  ;;      (let ((format
  ;;             (emms-source-playlist-read-format)))
  ;;        (emms-playlist-save format path))


  ;;      )))

  ;; PLAYLISTS buffer, where i keep playlist files, autoload all

;;;;;;;;; YKW, fuck it, im just gonna tag everything in info-note (WORKS!)
  ;; filter by note with emms-playlist-limit-to-info-note
  ;; e.g. :nice:hardcore:

  ;; (emms-browser-add-category "note" 'info-note)
  (defun emms-browser-search-by-note ()
    (interactive)
    (emms-browser-search '(info-note)))

  ;;; As for playlists, i'll still be making it for, well, when i wanna make playlists,
  ;; but i wont need to rely on those special custom functions. i can suffice with just:
  ;; - `emms-add-playlist-file' (add playlist file) [maybe i should automate creating a PLAYLISTS buffer]
  ;; - `emms-playlist-mode-load-playlist' (expand playlist file in new playlist buffer)
  ;; - C-x C-s or `emms-playlist-save' (save playlist to file)
  ;; - `rename-buffer' (rename buffer to liking)
  ;;
  ;; TODO: bind the above to keybinds


  ;;; Holy shit writing my emacs config modules in a declarative org file is actually pretty realistic and doable!?!
  ;; It'll make everything so much nicer... documentation as well...

  (defvar emms-playlistedit-orig-path nil
    "A local var for playlist buffers with the path to its playlist file.")

  ;; emms-playlistedit-open : given a path to the playlist file, adds the playlist file to the "PLAYLISTS" buffer, load playlist in a new generic playlist buffer, with a buffer-local variable for orig path set (or maybe the playlist file?),
  ;; - simplify by adding the playlist file to a "PLAYLISTS" buffer, then loading it from there?
  (defun emms-playlistedit-playlist-file-edit ()
    "Given a loaded playlist file at point, load in a new playlist buffer for editing.
It's essentially the same as `emms-playlist-mode-load-playlist' but it also sets
a buffer-local variable `emms-playlistedit-orig-path'."
    (interactive)
    ;; load the playlist at point
    ;; (below is a copy of `emms-playlist-mode-load-playlist' (we want to use the `name' variable later)).
    (let* ((track (emms-playlist-track-at))
           (name (emms-track-get track 'name)))
      (emms-playlist-select (point))
      (run-hooks 'emms-player-stopped-hook)
      (switch-to-buffer
       (emms-playlist-set-playlist-buffer (emms-playlist-new)))
      (emms-add-playlist name)
      ;; let the buffer-local variable to be `name' and also rename.
      (let ((buf emms-playlist-buffer))
        (with-current-buffer buf
          (setq-local emms-playlistedit-orig-path name)
          (rename-buffer (concat (buffer-name)
                                 " : "
                                 name))))))

  ;; (defun emms-playlistedit-create-playlist-buffer (buffer-name)
  ;;     "Creates a new playlist buffer BUFFER-NAME.
  ;; Basically the same as `emms-metaplaylist-mode-new-buffer' but without switching
  ;; to the metaplaylist view."
  ;;     (interactive "sBuffer Name: ")
  ;;     (if (get-buffer buffer-name)
  ;;      (error "Buffer must not exist.")
  ;;       (let ((buf (get-buffer-create buffer-name)))
  ;;      (with-current-buffer buf
  ;;        (emms-playlist-mode)
  ;;        (setq emms-playlist-buffer-p t)))
  ;;       (emms-metaplaylist-mode-go)
  ;;       (emms-metaplaylist-mode-update)))

  ;; (defun emms-playlistedit-open-playlist-file ()
  ;;     "Creates a new playlist buffer from a playlist-file, saving the original path.
  ;; The original path is saved in a buffer-local variable."
  ;;     )

  ;; emms-playlistedit-goto-playlist-buffer : goes to the "PLAYLISTS" buffer. If not exist, create new then go to.

  ;;


  ;; - load playlist contents in a new playlist buffer
  ;;   - use a buffer-local variable for the origin path
  ;; - make changes
  ;; - emms-playlist-diff-and-save
  ;;   - if the buffer-local variable is nil, then just do emms-playlist-save as usual
  ;;   - if the buffer-local variable is set, then:
  ;;     - load the original playlist in "TMP-%s", and diff compare new and old playlists. (error if path to playlist invalid).
  ;;     - proceed?
  ;;       - if yes, overwrite playlist file with new changes, then delete "TMP-%s".
  ;;       - if no, delete "TMP-%s" and cancel.



  ;; maybe switch to mpv (mpd is too jank) (usempvScripts.mpris)


  :init
  (+leader-bind
    "e" '(:ignore t :which-key "emms")
    "e e" 'emms
    "e k" 'emms-playlist-current-kill

    ;; goto
    "e p" 'emms-playlist-mode-go
    "e m" 'emms-metaplaylist-mode-go

    ;; browse
    "e B" 'emms-smart-browse
    "e b" '(:ignore t :which-key "browse")
    "e b b" 'emms-browser
    "e b a" 'emms-browse-by-album
    "e b A" 'emms-browse-by-artist

    ;; control
    "e c" '(:ignore t :which-key "control")
    "e c P" 'emms-pause
    "e c n" 'emms-next
    "e c p" 'emms-previous
    "e c s" 'emms-seek-to

    ;; info
    "e i" '(:ignore t :which-key "info")
    "e i i" 'emms-show
    "e i a" 'emms-show-all
    "e i m" 'emms-player-mpd-show

    ;; sort
    "e S" '(:ignore t :which-key "sort")
    "e S n" 'emms-playlist-sort-by-natural-order
    "e S r" 'emms-playlist-sort-by-random
    "e S o" 'emms-playlist-sort-by-info-note))
;; emms:1 ends here

;; [[file:../Config.org::*ical][ical:1]]
;; https://www.reddit.com/r/emacs/comments/ioenk2/ical_import_in_emacs_calendar/

(require 'diary-lib)

(setq my/calendars
      (with-temp-buffer
        (insert-file-contents "~/Private/elisp/calendar-urls.el")
        (read (current-buffer))))

(defun my/ical-pull-all ()
  (interactive)
  (find-file diary-file)
  (erase-buffer)
  (message "Cleared diary file")
  (mapcar (lambda (url)
            (let ((tmpfile (url-file-local-copy url)))
              (message "Importing ")
              (icalendar-import-file tmpfile diary-file)
              (kill-buffer (car (last (split-string tmpfile "/"))))))
          my/calendars))
;; ical:1 ends here

;; [[file:../Config.org::*to-sort][to-sort:1]]
(leaf omni-quotes
  :init (omni-quotes-mode 1)
  :bind (("M-s q m" . omni-quotes-mode)
         ("M-s q p" . omni-quotes-prev-set)
         ("M-s q n" . omni-quotes-next-set)
         ("M-s q s" . omni-quotes-shuffle-current-set)
         ("M-s q q" . omni-quotes-display-random-quote))
  :setq
  (omni-quotes-idle-interval . 60)
  (omni-quotes-fading . t)
  (omni-quotes-fading-delay . 30)
  :config
  (omni-quotes-load-simple-quote-file "~/Notes/org/quotes.txt" "personal"))

;; (defvar eldoc-doc-buffer-separator
;;   (concat (propertize "\n" 'face '(:inherit separator-line :extend t)))
;;   "String used to separate items in Eldoc documentation buffer.")


;;; Packages to install (check source code for malware for each first):

;; bind-map

;; restart-emacs

;; golden-ratio

;; ws-butler

;; flycheck-package

;; org-present

;; emacs-purpose

;; origami

;; cask

;; tao-theme

;; emacs-color-themes

;; hydra !!! so good
;; https://github.com/abo-abo/hydra/wiki/Hydras-by-Topic

;; literate programming?

;; hl-todo

;; breadcrumb?

;; git-gutter?

;; hideshow-org?

;; wgrep

;; look into different window strengths, lower C-h e 's strength

;; undo-tree

;; hyperbole

;; tree sitter

;; eglot?
;; to-sort:1 ends here

;; [[file:../Config.org::*ending][ending:1]]
(provide 'main)
;; ending:1 ends here
