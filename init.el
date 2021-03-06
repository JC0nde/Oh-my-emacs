;;; init.el --- Conde's Emacs configuration file

;; Copyright (c) 2019 Jonathan Conde

;; Author: Jonathan Conde <mail@jonathanconde.com>
;; URL: https://github.com/JC0nde/.emacs.d/

;; This file is not part of GNU Emacs.

;;; Commentary:

;; This is my personal Emacs configuration.  Nothing more, nothing less.

;;; License

;; Permission is granted to copy, distribute and/or modify this document
;; under the terms of the GNU Free Documentation License, Version 1.3
;; or any later version published by the Free Software Foundation;
;; with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.

;; Code in this document is free software: you can redistribute it
;; and/or modify it under the terms of the GNU General Public
;; License as published by the Free Software Foundation, either
;; version 3 of the License, or (at your option) any later version.

;; This code is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;;; Code:

;;; Package configs
(require 'package)
(setq package-enable-at-startup nil)
(setq package-archives '(("org"   . "http://orgmode.org/elpa/")
                         ("gnu"   . "http://elpa.gnu.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")))
(package-initialize)

;;; No splash screen please ... jeez
(setq inhibit-startup-buffer-menu t)
(setq inhibit-startup-screen t)
(setq initial-buffer-choice t)
(setq initial-scratch-message nil)

;; Disable certain byte compiler warnings
(setq byte-compile-warnings '(not free-vars unresolved noruntime lexical make-local))

;;; Set Fonts
(set-face-attribute 'default nil
                    :family "Source Code Pro" :height 110)

;;; Minimal UI
(scroll-bar-mode -1)
(tool-bar-mode   -1)
(tooltip-mode    -1)
(menu-bar-mode   -1)
(global-linum-mode 1)
(blink-cursor-mode -1)
(add-hook 'org-mode-hook (lambda () (linum-mode 0)))
(global-set-key (kbd "<f5>") 'revert-buffer)
(global-hl-line-mode t)
(fset 'yes-or-no-p 'y-or-n-p)
(setq-default indent-tabs-mode nil)

;; Nicer scrolling
(setq scroll-margin 0
      scroll-conservatively 100000
      scroll-preserve-screen-position 1)

;;; UTF-8 everywhere, forever
(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(when (display-graphic-p)
  (setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING)))

;; Don't quit Emacs on C-x C-c
(when (daemonp)
  (global-set-key (kbd "C-x C-c") 'kill-buffer-and-window))

;; Newline at end of file
(setq require-final-newline t)

;;; Bootstrap `use-package'
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package-ensure)
(setq use-package-always-ensure t)
(use-package use-package-ensure-system-package)

;; up-to-date packages
(use-package auto-package-update
  :config
  (setq auto-package-update-delete-old-versions t)
  (setq auto-package-update-hide-results t)
  (auto-package-update-maybe))

;; (use-package material-theme
;;   :config (load-theme 'material t))

(use-package solarized-theme
  :init
  (setq x-underline-at-descent-line t)
  :config
  (load-theme 'solarized-dark t))

;; Remeber last position
(use-package saveplace
  :unless noninteractive
  :config (save-place-mode))

;; jump to char word or line
;;; flashes the cursor's line when you scroll
(use-package beacon
  :config
  (beacon-mode 1))

(use-package linum-relative
  :config
  (linum-relative-mode)
  (setq linum-relative-current-symbol "")
  )

;;; deletes all the whitespace when you hit backspace or delete
(use-package hungry-delete
  :config
  (global-hungry-delete-mode))

(setq save-interprogram-paste-before-kill t)

;;; Set path to dependencies
(setq settings-dir
      (expand-file-name "settings" user-emacs-directory))

;;; Set up load path
(add-to-list 'load-path settings-dir)

;; Backup
(setq create-lockfiles nil)
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))
(setq vc-make-backup-files t)
(setq make-backup-files t
      backup-by-copying t
      version-control t
      delete-old-versions t
      kept-old-versions 6 
      kept-new-versions 9
      )

;;; Vim mode
(use-package evil
  :config
  (evil-mode 1))

(use-package evil-escape
  :init
  (setq-default evil-escape-key-sequence "fd")
  :config
  (evil-escape-mode 1))

(use-package evil-surround
  :config
  (global-evil-surround-mode 1))

(use-package evil-org
  :after org
  :config
  (add-hook 'org-mode-hook 'evil-org-mode)
  (add-hook 'evil-org-mode-hook
            (lambda ()
              (evil-org-set-key-theme)))
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

;; Tramp
(use-package tramp
  :defer t
  :config
  (setq tramp-default-method "ssh")

  ;; Only for debugging slow tramp connections
  ;;(setq tramp-verbose 7)

  ;; Skip version control for tramp files
  (setq vc-ignore-dir-regexp
        (format "\\(%s\\)\\|\\(%s\\)"
                vc-ignore-dir-regexp
                tramp-file-name-regexp))

  ;; Use ControlPath from .ssh/config
  (setq tramp-ssh-controlmaster-options "")

  ;; Backup tramp files like local files and don't litter the remote
  ;; file system with my emacs backup files
  (setq tramp-backup-directory-alist backup-directory-alist)

  ;; See https://www.gnu.org/software/tramp/#Ad_002dhoc-multi_002dhops
  ;; For all hosts, except my local one, first connect via ssh, and then apply sudo -u root:
  (dolist (tramp-proxies '((nil "\\`root\\'" "/ssh:%h:")
                           ((regexp-quote (system-name)) nil nil)
                           ("localhost" nil nil)))
    (add-to-list 'tramp-default-proxies-alist tramp-proxies)))

;;; Helm
(use-package helm
  :init
  (setq helm-M-x-fuzzy-match t
        helm-mode-fuzzy-match t
        helm-buffers-fuzzy-matching t
        helm-recentf-fuzzy-match t
        helm-locate-fuzzy-match t
        helm-semantic-fuzzy-match t
        helm-imenu-fuzzy-match t
        helm-completion-in-region-fuzzy-match t
        helm-candidate-number-list 150
        helm-split-window-in-side-p t
        helm-move-to-line-cycle-in-source t
        helm-echo-input-in-header-line t
        helm-autoresize-max-height 0
        helm-autoresize-min-height 30)
  (global-set-key (kbd "C-x b") #'helm-mini)
  (global-set-key (kbd "M-x") #'helm-M-x)
  (global-set-key (kbd "C-x r b") #'helm-filtered-bookmarks)
  (global-set-key (kbd "C-x C-f") #'helm-find-files)
  :config
  ;; keep follow-mode in between helm sessions once activated
  (setq helm-follow-mode-persistent t)
  ;; Don't show details in helm-mini for tramp buffers
  (setq helm-buffer-skip-remote-checking t)
  (helm-mode 1))

(use-package epa
  :config
  (require 'epa-file)
  (epa-file-enable)
  ;; Always replace encrypted text with plain text version
  (setq epa-file-cache-passphrase-for-symmetric-encryption t)
  (setq epa-replace-original-text t))

(use-package epg
  :config
  ;; Let Emacs query the passphrase through the minibuffer
  (setq epg-pinentry-mode 'loopback))


;;; Hydras
(use-package hydra
  :ensure hydra
  :bind
  ("C-c g" . hydra-git-gutter/body)
  ("C-c f" . hydra-flycheck/body)
  ("C-c ." . hydra-web/body)
  :config
  (defhydra hydra-git-gutter (:body-pre (git-gutter+-mode 1)
                                        :hint nil)
    "
^
^Git gutter^
^───────────────────────────────────────────────────────────
_j_: next hunk        _s_tage hunk     _q_uit
_k_: previous hunk    _r_evert hunk    _Q_uit and deactivate git-gutter
^^                    _p_opup hunk     ^^
_h_: first hunk
_l_: last hunk        set start _R_evision
^^                    ^^               ^^
"
    ("j" git-gutter+-next-hunk)
    ("k" git-gutter+-previous-hunk)
    ("h" (progn (goto-char (point-min))
                (git-gutter+-next-hunk 1)))
    ("l" (progn (goto-char (point-min))
                (git-gutter+-previous-hunk 1)))
    ("s" git-gutter+-stage-hunk)
    ("r" git-gutter+-revert-hunk)
    ("p" git-gutter+-popup-hunk)
    ("R" git-gutter+-set-start-revision)
    ("q" nil :color blue)
    ("Q" (progn (git-gutter+-mode -1)
                ;; git-gutter-fringe doesn't seem to
                ;; clear the markup right away
                (sit-for 0.1)
                (git-gutter+-clear))
     :color blue))

  (defhydra hydra-flycheck (:color pink :hint nil)
    "
^
^Flycheck^          ^Errors^            ^Checker^
^────────^──────────^──────^────────────^───────^───────────
_q_ quit            _k_ previous        _?_ describe
_m_ manual          _j_ next            _d_ disable
_v_ verify setup    _f_ check           _s_ select
^^                  _l_ list            ^^
^^                  ^^                  ^^
"
    ("q" nil)
    ("k" flycheck-previous-error)
    ("j" flycheck-next-error)
    ("?" flycheck-describe-checker :color blue)
    ("d" flycheck-disable-checker :color blue)
    ("f" flycheck-buffer)
    ("l" flycheck-list-errors :color blue)
    ("m" flycheck-manual :color blue)
    ("s" flycheck-select-checker :color blue)
    ("v" flycheck-verify-setup :color blue))

  (defhydra hydra-web (:color pink :hint nil)
    "
^
^Web-mode^
^───────────────────────────────────────────────────────────
_q_ quit            _h_ parent       _c_ clone 
_m_ manual          _j_ next         _d_ delete
^^                  _k_ previous     _r_ rename
^^                  _l_ child        _w_ wrap
^^                  ^^               ^^
"
    ("q" nil)
    ("m" flycheck-manual :color blue)
    ("h" web-mode-element-parent)
    ("j" web-mode-element-next)
    ("k" web-mode-element-previous)
    ("l" web-mode-element-child)
    ("c" web-mode-element-clone :color blue)
    ("d" web-mode-element-vanish :color blue)
    ("r" web-mode-element-rename :color blue)
    ("w" web-mode-element-wrap :color blue)
    ))

;;; Smartparens
(use-package smartparens
  :hook ((
          emacs-lisp-mode lisp-mode hy-mode go-mode cc-mode
          python-mode typescript-mode javascript-mode java-mode
          ) . smartparens-strict-mode)
  :custom
  (sp-escape-quotes-after-insert nil)
  :config
  (show-smartparens-global-mode +1)
  (setq blink-matching-paren nil)
  (setq sp-base-key-bindings 'paredit)
  (setq sp-autoskip-closing-pair 'always)
  (require 'smartparens-config)
  (smartparens-global-mode t))

(use-package no-littering
  :demand t
  :config
  ;; /etc is version controlled and I want to store mc-lists in git
  (setq mc/list-file (no-littering-expand-etc-file-name "mc-list.el"))
  ;; Put the auto-save files in the var directory to the other data files
  (setq auto-save-file-name-transforms
        `((".*" ,(no-littering-expand-var-file-name "auto-save/") t))))

(use-package recentf
  :config
  (add-to-list 'recentf-exclude "^/\\(?:ssh\\|su\\|sudo\\)?:")
  (add-to-list 'recentf-exclude no-littering-var-directory)
  (add-to-list 'recentf-exclude no-littering-etc-directory)

  (setq recentf-max-saved-items 500
        recentf-max-menu-items 15
        recentf-auto-cleanup 'never)

  (recentf-mode))

;;; Which Key
(use-package which-key
  :init
  (setq which-key-separator " → ")
  (setq which-key-prefix-prefix "+")
  :config
  (which-key-mode 1))

;;; Try package
(use-package try)

;;; Undo Tree
(use-package undo-tree
  :config
  (setq undo-tree-visualizer-timestamps t)
  (setq undo-tree-history-directory-alist
        `((".*" . ,temporary-file-directory)))
  (setq undo-tree-auto-save-history t)
  ;; Keep region when undoing in region
  (defadvice undo-tree-undo (around keep-region activate)
    (if (use-region-p)
        (let ((m (set-marker (make-marker) (mark)))
              (p (set-marker (make-marker) (point))))
          ad-do-it
          (goto-char p)
          (set-mark m)
          (set-marker p nil)
          (set-marker m nil))
      ad-do-it))

  (global-undo-tree-mode))

;;; OrgMode setup
(use-package org
  :pin org
  :config
  ;; Some characters to choose from: …, ⤵, ▼, ↴, ⬎, ⤷, and ⋱
  (setq org-ellipsis "⤵"))

(use-package org-bullets
  :config
  (add-hook 'org-mode-hook (lambda ()(org-bullets-mode 1))))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(css-indent-offset 2)
 '(org-confirm-babel-evaluate nil)
 '(org-default-notes-file (concat org-directory "/refile.org"))
 '(org-directory "~/Org")
 '(org-export-html-postamble nil)
 '(org-hide-leading-stars t)
 '(org-src-fontify-natively t)
 '(org-startup-folded (quote overview))
 '(org-startup-indented t)
 '(package-selected-packages
   (quote
    (telephone-line helm-rg rg vlf logview ibuffer-projectile apache-mode evil-mu4e evil-org helm-mu mu4e-alert org-mime aggressive-indent linum-relative org-pdfview pdf-tools iedit magit hungry-delete beacon all-the-icons projectile general which-key helm evil-escape evil use-package)))
 '(safe-local-variable-values
   (quote
    ((eval progn
           (set
            (make-local-variable
             (quote org-time-clocksum-format))
            (quote
             (:hours "%d" :require-hours t :minutes ":%02d" :require-minutes t)))
           (setq org-latex-tables-centered nil org-latex-default-table-environment "longtable")
           (local-set-key
            (kbd "<f6>")
            (lambda nil
              (interactive)
              (beginning-of-buffer)
              (re-search-forward "Invoice number: \\([0-9]+\\)")
              (let
                  ((n
                    (string-to-number
                     (match-string 1))))
                (kill-region
                 (match-beginning 1)
                 (match-end 1))
                (insert
                 (format "%d"
                         (1+ n))))
              (beginning-of-buffer)
              (re-search-forward "Invoice date: *")
              (kill-region
               (point)
               (save-excursion
                 (end-of-line)
                 (point)))
              (org-insert-time-stamp
               (current-time)
               nil t)
              (beginning-of-buffer)
              (search-forward "#+BEGIN: clocktable")
              (unwind-protect
                  (progn
                    (defadvice org-table-goto-column
                        (before always-make-new-columns
                                (n &optional on-delim force)
                                activate)
                      "always adds new columns when we move to them"
                      (setq force t))
                    (org-clocktable-shift
                     (quote right)
                     1))
                (ad-deactivate
                 (quote org-table-goto-column)))
              (beginning-of-buffer)
              (search-forward "| totaltarget")
              (org-table-recalculate t))))
     (eval progn
           (set
            (make-local-variable
             (quote org-time-clocksum-format))
            (quote
             (:hours "%d" :require-hours t :minutes ":%02d" :require-minutes t)))
           (setq org-latex-tables-centered nil org-latex-default-table-environment "longtable")
           (local-set-key
            (kbd "<f6>")
            (lambda nil
              (interactive)
              (beginning-of-buffer)
              (re-search-forward "Facture numéro: \\([0-9]+\\)")
              (let
                  ((n
                    (string-to-number
                     (match-string 1))))
                (kill-region
                 (match-beginning 1)
                 (match-end 1))
                (insert
                 (format "%d"
                         (1+ n))))
              (beginning-of-buffer)
              (re-search-forward "Date de facturation: *")
              (kill-region
               (point)
               (save-excursion
                 (end-of-line)
                 (point)))
              (org-insert-time-stamp
               (current-time)
               nil t)
              (beginning-of-buffer)
              (search-forward "#+BEGIN: clocktable")
              (unwind-protect
                  (progn
                    (defadvice org-table-goto-column
                        (before always-make-new-columns
                                (n &optional on-delim force)
                                activate)
                      "always adds new columns when we move to them"
                      (setq force t))
                    (org-clocktable-shift
                     (quote right)
                     1))
                (ad-deactivate
                 (quote org-table-goto-column)))
              (beginning-of-buffer)
              (search-forward "| totaltarget")
              (org-table-recalculate t))))))))

(setq browse-url-browser-function 'browse-url-generic
      browse-url-generic-program "chromium")

(add-hook 'org-mode-hook
          '(lambda ()
             (setq org-file-apps
                   '((auto-mode . emacs)
                     ("\\.mm\\'" . default)
                     ("\\.x?html?\\'" . default)
                     ("\\.pdf\\'" . "zathura %s")))))

(global-set-key "\C-ca" 'org-agenda)
(setq org-agenda-start-on-weekday nil)
(setq org-agenda-custom-commands
      '(("c" "Simple agenda view"
         ((agenda "")
          (alltodo "")))))

(global-set-key (kbd "C-c c") 'org-capture)

;; Adds automatically all .org files in specified directory to the agenda
(setq org-agenda-files (directory-files-recursively "~/Org" "\.org$"))

(setq org-use-fast-todo-selection t)
(setq org-treat-S-cursor-todo-selection-as-state-change nil)

(setq org-todo-keywords
      (quote ((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d)")
              (sequence "WAITING(w@/!)" "HOLD(h@/!)" "|" "CANCELLED(c@/!)" "PHONE" "MEETING"))))

(setq org-todo-state-tags-triggers
      (quote (("CANCELLED" ("CANCELLED" . t))
              ("WAITING" ("WAITING" . t))
              ("HOLD" ("WAITING") ("HOLD" . t))
              (done ("WAITING") ("HOLD"))
              ("TODO" ("WAITING") ("CANCELLED") ("HOLD"))
              ("NEXT" ("WAITING") ("CANCELLED") ("HOLD"))
              ("DONE" ("WAITING") ("CANCELLED") ("HOLD")))))

;; Capture templates for: TODO tasks, Notes, appointments, phone calls, meetings, and org-protocol
(setq org-capture-templates
      (quote (("t" "À faire" entry (file "~/Org/refile.org")
               "* TODO %?\n%U\n%a\n" :prepend t)
              ("r" "Rendez-vous" entry (file  "~/Org/gcal.org" )
               "* %?\n\n%^T\n\n:PROPERTIES:\n\n:END:\n\n")
              ("e" "E-mail" entry (file "~/Org/refile.org")
               "* NEXT Reponds à %? sur %:subject\n%U\n%a\n" :clock-in t :clock-resume t :prepend t)
              ("n" "Note" entry (file "~/Org/refile.org")
               "* %? :NOTE:\n%U\n%a\n" :clock-in t :clock-resume t :prepend t)
              ("j" "Journal" entry (file+datetree "~/Org/diary.org")
               "* %?\n%U\n" :prepend t)
              ("w" "org-protocol" entry (file "~/Org/refile.org")
               "* TODO Review %c\n%U\n" :immediate-finish t :prepend t)
              ("m" "Réunion" entry (file "~/Org/refile.org")
               "* MEETING with %? :MEETING:\n%U" :clock-in t :clock-resume t :prepend t)
              ("p" "appel téléphonique" entry (file "~/Org/refile.org")
               "* PHONE %? :PHONE:\n%U" :clock-in t :clock-resume t :prepend t)
              ("h" "Habitude" entry (file "~/Org/refile.org")
               "* NEXT %?\n%U\n%a\nSCHEDULED: %(format-time-string \"%<<%Y-%m-%d %a .+1d/3d>>\")\n:PROPERTIES:\n:STYLE: habit\n:REPEAT_TO_STATE: NEXT\n:END:\n" :prepend t))))

;; Targets include this file and any file contributing to the agenda - up to 9 levels deep
(setq org-refile-targets (quote ((nil :maxlevel . 9)
                                 (org-agenda-files :maxlevel . 9))))

;; Use full outline paths for refile targets - we file directly with IDO
(setq org-refile-use-outline-path t)
(setq org-outline-path-complete-in-steps nil)
(setq org-refile-allow-creating-parent-nodes (quote confirm))
;; Do not dim blocked tasks
(setq org-agenda-dim-blocked-tasks nil)

;; Do not dim blocked tasks
(setq org-agenda-dim-blocked-tasks nil)
;; Compact the block agenda view
(setq org-agenda-compact-blocks t)

(setq org-ditaa-jar-path "/usr/share/ditaa/ditaa.jar")
(setq org-cycle-separator-lines 0)
(setenv "BROWSER" "firefox")

;; skip multiple timestamps for the same entry
(setq org-agenda-skip-additional-timestamps-same-entry t)
;; Overwrite the current window with the agenda
(setq org-agenda-window-setup 'current-window)
(setq org-cycle-include-plain-lists t)
(setq org-alphabetical-lists t)

;; Reveal.js
(use-package ox-reveal
  :ensure ox-reveal)

(setq org-reveal-root "http://cdn.jsdelivr.net/reveal.js/3.0.0/")
(setq org-reveal-mathjax t)

(use-package htmlize)

(defun comment-or-uncomment-region-or-line ()
  "Comments or uncomments the region or the current line if there's no active region."
  (interactive)
  (let (beg end)
    (if (region-active-p)
        (setq beg (region-beginning) end (region-end))
      (setq beg (line-beginning-position) end (line-end-position)))
    (comment-or-uncomment-region beg end)
    (next-logical-line)))

;;; Custom keybinding
(use-package general
  :config (general-define-key
           :states '(normal visual insert emacs)
           :prefix "SPC"
           :non-normal-prefix "M-SPC"
           "TAB" '(switch-to-prev-buffer :which-key "previous buffer")
           "SPC" '(helm-M-x :which-key "M-x")
           "<f1>" '(helm-apropos :which-key "à propos")
           "bb" '(helm-mini :which-key "helm mini")
           "fed" '(myinit :which-key "init file")
           "fer" '(myinitR :which-key "init file")
           "ff" '(helm-find-files :which-key "find files")
           "fr" '(helm-recentf :which-key "recent files")
           "fs" '(save-buffer :which-key "save file")
           "fS" '(save-some-buffers :which-key "save all")
           "xw" '(write-file :which-key "write file name")
           "y" '(helm-show-kill-ring :which-key "kill ring")
           "m" '(mu4e :which-key "mu4e")
           "cl" '(comment-or-uncomment-region-or-line :which-key "comment line or region")
           ;; Projectile
           "pf"  '(helm-projectile-find-file :which-key "find files")
           "pF"  '(helm-projectile-find-file-dwim :which-key "find files dwim")
           "pd"  '(helm-projectile-find-dir :which-key "find directory")
           "pp"  '(helm-projectile-switch-project :which-key "switch project")
           "pb"  '(helm-projectile-switch-to-buffer :which-key "switch to buffer")
           "ph"  '(helm-projectile :which-key "helm-projectile")
           "pr"  '(helm-projectile-recentf :which-key "recent files")
           "pg"  '(helm-projectile-grep :which-key "grep")
           
           ;; Buffers
           "bb"  '(helm-buffers-list :which-key "buffers list")

           ;; Window
           "wl"  '(windmove-right :which-key "move right")
           "wh"  '(windmove-left :which-key "move left")
           "wk"  '(windmove-up :which-key "move up")
           "wj"  '(windmove-down :which-key "move bottom")
           "w/"  '(split-window-right :which-key "split right")
           "w-"  '(split-window-below :which-key "split bottom")
           "wo"  '(other-window :which-key "other window")
           "wx"  '(delete-window :which-key "delete window")
           "qz"  '(delete-frame :which-key "delete frame")
           "qq"  '(kill-emacs :which-key "quit")

           ;; Magit
           "gs"  '(magit-status : whick-key "git status")
           ;; Others
           "t"  '(ansi-term :which-key "open terminal")
           ))
(use-package pdf-tools)
(use-package org-pdfview)

(require 'pdf-tools)
(require 'org-pdfview)

;;; Load init file
(defun myinit ()
  "Go to init file."
  (interactive)
  (find-file "~/.emacs.d/init.el"))

;;; Reload init file

(defun myinitR ()
  "Reload to init file."
  (interactive)
  (load-file "~/.emacs.d/init.el"))

;;; mark and edit all copies of the marked region simultaniously.
(use-package iedit)

;;; if you're windened, narrow to the region, if you're narrowed, widen
;;; bound to C-x n
(defun narrow-or-widen-dwim (p)
  "If the buffer is narrowed,  it widens.  Otherwise,  it narrows intelligently.
Intelligently means: region, org-src-block, org-subtree, or defun,
whichever applies first.
Narrowing to org-src-block actually calls `org-edit-src-code'.

With prefix P, don't widen, just narrow even if buffer is already
narrowed."
  (interactive "P")
  (declare (interactive-only))
  (cond ((and (buffer-narrowed-p) (not p)) (widen))
        ((region-active-p)
         (narrow-to-region (region-beginning) (region-end)))
        ((derived-mode-p 'org-mode)
         ;; `org-edit-src-code' is not a real narrowing command.
         ;; Remove this first conditional if you don't want it.
         (cond ((ignore-errors (org-edit-src-code))
                (delete-other-windows))
               ((org-at-block-p)
                (org-narrow-to-block))
               (t (org-narrow-to-subtree))))
        (t (narrow-to-defun))))

;; (define-key endless/toggle-map "n" #'narrow-or-widen-dwim)
;; This line actually replaces Emacs' entire narrowing keymap, that's
;; how much I like this command. Only copy it if that's what you want.
(define-key ctl-x-map "n" #'narrow-or-widen-dwim)

;;; Flycheck
(use-package flycheck
  :init
  (global-flycheck-mode))

;; Yasnippet
(use-package yasnippet
  :defer 10
  :mode (("\\.yasnippet\\'" . snippet-mode))
  :bind (:map yas-minor-mode-map
              ("\C-c TAB" . yas-expand))
  :config
  (yas-global-mode 1))

;; babel stuff
(org-babel-do-load-languages
 'org-babel-load-languages
 '((python . t)
   (emacs-lisp . t)
   (shell . t)
   (C . t)
   (js . t)
   (ditaa . t)
   (dot . t)
   (org . t)
   (latex . t )
   (sass . t)
   ))

;;; Projectile
(use-package projectile
  :bind ("C-c p" . projectile-command-map)
  :config
  (projectile-mode 1)
  (setq projectile-completion-system 'helm))


;;; Helm Projectile
(use-package helm-projectile
  :init
  (setq helm-projectile-fuzzy-match t)
  :config
  (helm-projectile-on))

;;; All The Icons
(use-package all-the-icons)

;;; Show matching parens
(setq show-paren-delay 0)
(show-paren-mode 1)

;; ;;; Powerline
(use-package telephone-line
  :init
  (setq telephone-line-lhs
        '((evil   . (telephone-line-evil-tag-segment))
          (accent . (telephone-line-vc-segment
                     telephone-line-erc-modified-channels-segment
                     telephone-line-process-segment))
          (nil    . (telephone-line-buffer-segment))))
  (setq telephone-line-rhs
        '((nil    . (telephone-line-misc-info-segment))
          (accent . (telephone-line-major-mode-segment))
          (evil   . (telephone-line-airline-position-segment))))
  :config
  (telephone-line-mode t))

;;; Company
(use-package company
  :bind (:map company-active-map
              ([return] . nil)
              ("RET" . nil)
              ("TAB" . company-select-next)
              ([tab] . company-select-next)
              ("S-TAB" . company-select-previous)
              ([backtab] . company-select-previous)
              ("C-j" . company-complete-selection))
  :config
  ;; company-tng (tab and go) allows you to use TAB to both select a
  ;; completion candidate from the list and to insert it into the
  ;; buffer.
  ;;
  ;; It cycles the candidates like `yank-pop' or `dabbrev-expand' or
  ;; Vim: Pressing TAB selects the first item in the completion menu and
  ;; inserts it in the buffer. Pressing TAB again selects the second
  ;; item and replaces the inserted item with the second one. This can
  ;; continue as long as the user wishes to cycle through the menu.
  (setq company-selection-wrap-around t)
  (add-to-list 'company-backends 'company-tern)
  (require 'company-tng)
  (setq company-frontends '(company-tng-frontend
                            company-pseudo-tooltip-frontend
                            company-echo-metadata-frontend)))

(setq company-idle-delay 0)
(setq company-tooltip-limit 10)
(setq company-minimum-prefix-length 1)
;; Aligns annotation to the right hand side
(setq company-tooltip-align-annotations t)
;;(setq company-dabbrev-downcase nil)
;; invert the navigation direction if the the completion popup-isearch-match
;; is displayed on top (happens near the bottom of windows)
;;(setq company-tooltip-flip-when-above t)
;; start autocompletion only after typing
(setq company-begin-commands '(self-insert-command))
(global-company-mode 1)

(use-package magit
  :init
  (progn
    (bind-key "C-x g" 'magit-status)))

(use-package fringe-helper)

(use-package git-gutter-fringe+
  :init
  (global-git-gutter+-mode +1))

(use-package git-timemachine)

;;; ibuffer
(global-set-key (kbd "C-x C-b") 'ibuffer)
(setq ibuffer-saved-filter-groups
      (quote (("default"
               ("dired" (mode . dired-mode))
               ("org" (name . "^.*org$"))

               ("web" (or (mode . web-mode) (mode . js2-mode)))
               ("shell" (or (mode . eshell-mode) (mode . shell-mode)))
               ("mu4e" (name . "\*mu4e\*"))
               ("programming" (or
                               (mode . python-mode)
                               (mode . c++-mode)))
               ("emacs" (or
                         (name . "^\\*scratch\\*$")
                         (name . "^\\*Messages\\*$")))
               ))))
(add-hook 'ibuffer-mode-hook
          (lambda ()
            (ibuffer-auto-mode 1)
            (ibuffer-switch-to-saved-filter-groups "default")))

(use-package ibuffer-projectile
  :hook (ibuffer . ibuffer-projectile-init)
  :commands ibuffer-projectile-init
  :config
  (defun ibuffer-projectile-init()
    (ibuffer-projectile-set-filter-groups)
    (unless (eq ibuffer-sorting-mode 'alphabetic)
      (ibuffer-do-sort-by-alphabetic))))

;; don't show these
                                        ;(add-to-list 'ibuffer-never-show-predicates "zowie")
;; Don't show filter groups if there are no buffers in that group
(setq ibuffer-show-empty-filter-groups nil)

;; Don't ask for confirmation to delete marked buffers
(setq ibuffer-expert t)

;;; Emmet
(use-package emmet-mode
  :hook (web-mode sgml-mode css-mode)
  :config
  (setq emmet-move-cursor-between-quotes t)
  (setq emmet-move-cursor-after-expanding t))

(use-package rainbow-mode
  :hook (css-mode scss-mode sass-mode emacs-lisp-mode hy-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Language Supports ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;

;;; JavaScript
(use-package js2-mode
  :ensure ac-js2
  :mode ("\\.js\\'" "\\.pac\\'" "\\.node\\'")
  :init
  (add-hook 'js2-mode-hook (lambda ()
                             (setq mode-name "JS2")))
  :config
  ;; Don't warn about trailing commas
  ;;(setq js2-strict-trailing-comma-warning nil)

  (setq js2-basic-offset 2)  ; set javascript indent to 2 spaces
  )

(use-package js2-refactor
  :config
  (progn
    (js2r-add-keybindings-with-prefix "C-c C-m")
    ;; eg. extract function with `C-c C-m ef`.
    (add-hook 'js2-mode-hook #'js2-refactor-mode)))

(setenv "PATH" (concat (getenv "PATH") ":/usr/local/bin"))
(setq exec-path (append exec-path '("/usr/local/bin")))

(use-package tern
  :commands tern-mode
  :init (add-hook 'js-mode-hook 'tern-mode)
  :config
  (use-package company-tern
    :config
    (setq company-tern-property-marker "")
    (add-to-list 'company-backends 'company-tern)))

;; turn on flychecking globally
(add-hook 'after-init-hook #'global-flycheck-mode)

;; disable jshint since we prefer eslint checking
(setq-default flycheck-disabled-checkers
              (append flycheck-disabled-checkers
                      '(javascript-jshint)))

;; customize flycheck temp file prefix
(setq-default flycheck-temp-prefix ".flycheck")

;;; web-mode
(use-package web-mode
  :config
  (add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.twig?\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.jsx$" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.vue?\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.php\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
  (setq web-mode-engines-alist
        '(("php"    . "\\.phtml\\'")
          ("blade"  . "\\.blade\\.")))

  (setq web-mode-ac-sources-alist
        '(("css" . (ac-source-css-property))
          ("vue" . (ac-source-words-in-buffer ac-source-abbrev))
          ("html" . (ac-source-words-in-buffer ac-source-abbrev))))

  (setq web-mode-enable-auto-closing t)
  (setq web-mode-enable-auto-quoting t) ; this fixes the quote problem I mentioned
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-script-padding 0)
  (setq web-mode-style-padding 0))

(use-package aggressive-indent
  :config
  (global-aggressive-indent-mode 1)
  ;;(add-to-list 'aggressive-indent-excluded-modes 'html-mode)
  )

;; Mu
(add-to-list 'load-path "~/mu/mu4e")
(require 'mu4e)
(require 'smtpmail)

(setq mu4e-get-mail-command "mbsync -c ~/.emacs.d/.mbsyncrc -a"
      mu4e-maildir (expand-file-name "~/.email")
      mu4e-update-interval 180
      mu4e-headers-skip-duplicates t
      mu4e-confirm-quit nil
      mu4e-compose-signature-auto-include nil
      mu4e-view-show-images t
      mu4e-view-show-addresses t
      mu4e-attachment-dir "~/Downloads"
      mu4e-use-fancy-chars t
      message-signature-file "~/.emacs.d/.signature"
      mu4e-compose-signature-auto-include nil
      message-kill-buffer-on-exit t
      mu4e-change-filenames-when-moving t
      message-send-mail-function 'smtpmail-send-it
      starttls-use-gnutls t
      smtpmail-stream-type 'starttls
      mu4e-sent-messages-behavior 'sent
      ;;mu4e-html2text-command "w3m -T text/html"
      )
(setq mail-user-agent 'mu4e-user-agent)
(setq mu4e-context-policy 'pick-first)
(setq mu4e-compose-context-policy 'always-ask)
(setq mu4e-contexts
      (list
       (make-mu4e-context
        :name "personnel"
        :enter-func (lambda () (mu4e-message "Entering personal context"))
        :leave-func (lambda () (mu4e-message "Leaving personal context"))
        :match-func (lambda (msg)
                      (when msg
                        (mu4e-message-contact-field-matches
                         msg '(:to) "mail@jonathanconde.com")))
        :vars '((user-mail-address . "mail@jonathanconde.com")
                (user-full-name . "Jonathan Conde")
                (mu4e-sent-folder . "/work/Sent")
                (mu4e-drafts-folder . "/work/Drafts")
                (mu4e-trash-folder . "/work/Trash")
                (mu4e-refile-folder . "/work/Archives")
                (smtpmail-queue-dir . "~/.email/gmail/queue/cur")
                (smtpmail-smtp-user . "mail@jonathanconde.com")
                (smtpmail-starttls-credentials . (("mail.infomaniak.com" 587 nil nil)))
                (smtpmail-auth-credentials . (expand-file-name "~/.authinfo.gpg"))
                (smtpmail-default-smtp-server . "mail.infomaniak.com")
                (smtpmail-smtp-server . "mail.infomaniak.com")
                (mu4e-sent-messages-behavior . sent)
                (smtpmail-smtp-service . 587)
                (mu4e-maildir-shortcuts . ( ("/work/INBOX"    . ?i)
                                            ("/work/Sent"     . ?s)
                                            ("/work/Trash"    . ?t)
                                            ("/work/Archives" . ?a)
                                            ("/work/Drafts"   . ?d)
                                            ))))

       (make-mu4e-context
        :name "gmail"
        :enter-func (lambda () (mu4e-message "Entering gmail context"))
        :leave-func (lambda () (mu4e-message "Leaving gmail context"))
        :match-func (lambda (msg)
                      (when msg
                        (mu4e-message-contact-field-matches
                         msg '(:to) "jonathan.conde.g@gmail.com")))
        :vars '((user-mail-address . "jonathan.conde.g@gmail.com")
                (user-full-name . "Jonathan Conde")
                (mu4e-sent-folder . "/gmail/[Gmail]/Messages envoy&AOk-s")
                (mu4e-drafts-folder . "/gmail/[Gmail]/Brouillons")
                (mu4e-trash-folder . "/gmail/[Gmail]/Corbeille")
                (mu4e-refile-folder . "/gmail/[Gmail]/Tous les messages")
                (smtpmail-queue-dir . "~/.email/gmail/queue/cur")
                (smtpmail-smtp-user . "jonathan.conde.g@gmail.com")
                (smtpmail-starttls-credentials . (("smtp.gmail.com" 587 nil nil)))
                (smtpmail-auth-credentials . (expand-file-name "~/.authinfo.gpg"))
                (smtpmail-default-smtp-server . "smtp.gmail.com")
                (smtpmail-smtp-server . "smtp.gmail.com")
                (smtpmail-smtp-service . 587)
                (mu4e-sent-messages-behavior . delete)
                (mu4e-maildir-shortcuts . ( ("/gmail/INBOX"                        . ?i)
                                            ("/gmail/[Gmail]/Messages envoy&AOk-s" . ?s)
                                            ("/gmail/[Gmail]/Corbeille"            . ?t)
                                            ("/gmail/[Gmail]/Tous les messages"    . ?a)
                                            ("/gmail/[Gmail]/Brouillons"           . ?d)
                                            ))))))

;; don't save messages to Sent Messages, Gmail/IMAP takes care of this

;;; Bookmarks
(setq mu4e-bookmarks
      `(
        ("flag:unread AND NOT flag:trashed" "Unread messages" ?u)
        ("flag:unread" "new messages" ?n)
        ("date:today..now" "Today's messages" ?t)
        ("date:7d..now" "Last 7 days" ?w)
        ("mime:image/*" "Messages with images" ?p)
        ))

(require 'org-mu4e)
(setq-default org-mu4e-convert-to-html t)
(defalias 'org-mail 'org-mu4e-compose-org-mode)
(setq-default org-export-with-toc nil)
(setq-default org-mu4e-link-query-in-headers-mode nil)

(use-package org-mime
  :commands (org-mime-htmlize org-mime-org-buffer-htmlize org-mime-org-subtree-htmlize)
  :bind (:map message-mode-map ("C-c M-o" . org-mime-htmlize)
              :map org-mode-map ("C-c M-o" . org-mime-org-subtree-htmlize))
  :config
  (setq org-mime-export-options '(:section-numbers nil
                                                   :with-author nil
                                                   :with-toc nil)))

;; this seems to fix the babel file saving thing
(defun org~mu4e-mime-replace-images (str current-file)
  "Replace images in html files with cid links."
  (let (html-images)
    (cons
     (replace-regexp-in-string ;; replace images in html
      "src=\"\\([^\"]+\\)\""
      (lambda (text)
        (format
         "src=\"./:%s\""
         (let* ((url (and (string-match "src=\"\\([^\"]+\\)\"" text)
                          (match-string 1 text)))
                (path (expand-file-name
                       url (file-name-directory current-file)))
                (ext (file-name-extension path))
                (id (replace-regexp-in-string "[\/\\\\]" "_" path)))
           (add-to-list 'html-images
                        (org~mu4e-mime-file
                         (concat "image/" ext) path id))
           id)))
      str)
     html-images)))

;; Alerts
(use-package mu4e-alert)

(mu4e-alert-set-default-style 'libnotify)
(add-hook 'after-init-hook #'mu4e-alert-enable-notifications)
(add-hook 'after-init-hook #'mu4e-alert-enable-mode-line-display)

;;need this for hash access
(require 'subr-x)

;; we seem to need this to fix the org-store-link issue
(org-link-set-parameters "mu4e" :follow #'org-mu4e-open :store 
                         #'org-mu4e-store-link)

(load-file "~/.emacs.d/lisp/evil-mu4e.el")
(require 'evil-mu4e)

(use-package helm-mu
  :config
  (require 'helm-config))

(define-key mu4e-main-mode-map "s" 'helm-mu)
(define-key mu4e-headers-mode-map "s" 'helm-mu)
(define-key mu4e-view-mode-map "s" 'helm-mu)

;; spell check for mu4e
(add-hook 'mu4e-compose-mode-hook
          (defun my-do-compose-stuff ()
            "My settings for message composition."
            (visual-line-mode)
            ;;(org-mu4e-compose-org-mode)
            (use-hard-newlines -1)
            (flyspell-mode)))

(use-package apache-mode
  :mode ("\\.htaccess\\'" "httpd\\.conf\\'" "srm\\.conf\\'" "access\\.conf\\'"))

(use-package vlf
  :defer t
  :pin melpa)

;; Logview provides syntax highlighting, filtering and other features for various log files
(use-package logview
  :defer t
  :config
  (setq logview-additional-submodes
        '(("Logback4me"
           (format . "TIMESTAMP [THREAD] {} LEVEL NAME -")
           (levels . "SLF4J")))))

(use-package rg
  :ensure-system-package rg
  :config (rg-enable-default-bindings))

(setq rg-align-position-numbers t)
(setq rg-align-line-number-field-length 3)
(setq rg-align-column-number-field-length 3)
(setq rg-align-line-column-separator "#")
(setq rg-align-position-content-separator "|")

;;;;;;;;;;;;;;;;;;;;;;;
;;; Live dev setup  ;;;
;;;;;;;;;;;;;;;;;;;;;;;
;;
;; (use-package simple-httpd
;;   :config
;;   (setq httpd-root "~/LocalDev/")
;;   (httpd-start))

;; (use-package skewer-mode
;;   :config
;;   (add-hook 'js2-mode-hook 'skewer-mode)
;;   (add-hook 'css-mode-hook 'skewer-css-mode)
;;   (add-hook 'html-mode-hook 'skewer-html-mode)
;;   (add-hook 'web-mode-hook 'skewer-html-mode))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(font-lock-keyword-face ((t (:slant italic))))
 '(font-lock-preprocessor-face ((t (:inherit bold :slant italic :weight normal)))))

(provide 'init)

;;; init.el ends here
