;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

;; customizations are now session-local
(setq custom-file (make-temp-file "emacs-custom"))

;; make sure use-package is installed
(require 'package)
(setq package-archives
      '(("org" . "http://orgmode.org/elpa/")
       ("melpa" . "https://melpa.org/packages/")
       ("gnu" . "https://elpa.gnu.org/packages/")
       ))

(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package)
  (eval-when-compile (require 'use-package)))

;; increase GC threshold for startup
(setq gc-cons-threshold 10000000)

;; Restore after startup
(add-hook 'after-init-hook
	  (lambda ()
	    (setq gc-cons-threshold 1000000)
	    (message "gc-cons-threshold restored to %S"
		     gc-cons-threshold)))

;; my settings broken out into their own packages
(add-to-list 'load-path (expand-file-name (concat user-emacs-directory "extras")))

;; utility!
(defun cb/read-lines (filePath)
  "Return a list of lines from the file at filePath"
  (with-temp-buffer
    (insert-file-contents filePath)
    (split-string (buffer-string) "\n" t)))

(defun cb/read-lines-or-nil (filePath)
  "Return list of lines from the file at filePath, or nil if it's unreadable"
  (when (file-readable-p filePath)
    (cb/read-lines filePath)))

(defun file-if-exists (filename) "return file if it exists, else nil" nil
       (if (file-exists-p filename)
	   filename
	 nil))

(global-set-key (kbd "<select>") 'move-end-of-line) ;; weirdness with keyboard over ssh

;; useful if you're on a mac keyboard, useless otherwise
;; TODO figure out how to detect this situation to make this conditional
;; (setq x-alt-keysym 'meta)
;; (setq x-meta-keysym 'super)

(scroll-bar-mode -1)
(tool-bar-mode -1)
(menu-bar-mode -1)
(setq inhibit-startup-screen t)
(display-time-mode t)
(column-number-mode t)
(setq display-time-mail-string "")
(setq ring-bell-function 'ignore)
(defalias 'yes-or-no-p 'y-or-n-p) ;; shorten yes/no prompts to y/n

(use-package counsel
  :after ivy
  :ensure t
  :config (counsel-mode 1))

(use-package ivy
  :ensure t
  :bind (("C-c C-r" . ivy-resume)
         ("C-x B" . ivy-switch-buffer-other-window))
  :custom
  (ivy-count-format "(%d/%d) ")
  (ivy-use-virtual-buffers t)
  :config (ivy-mode 1))

(use-package ivy-rich
  :after counsel
  :ensure t
  :init
  (setq ivy-rich-path-style 'abbrev
	ivy-virtual-abbreviate 'full)
  :config
  (ivy-rich-mode 1)
  )

(use-package swiper
  :ensure t
  :after ivy
  :bind (("C-s" . swiper)
         ("C-r" . swiper)))

(use-package counsel-gtags
  :ensure t
  :after counsel
  :bind (:map counsel-gtags-mode-map
	      ("M-t" . counsel-gtags-find-definition)
	      ("M-r" . counsel-gtags-find-reference)
	      ("M-s" . counsel-gtags-find-symbol)
	      ("M-," . counsel-gtags-go-backward))
  :hook
  (((c-mode c++-mode asm-mode python-mode) . counsel-gtags-mode)))

(use-package counsel-jq
  :ensure t
  :after counsel
  )

(use-package counsel-projectile
  :ensure t
  :after (counsel projectile)
  :config
  (counsel-projectile-mode 1)
  )

(use-package ivy-avy
  :ensure t
  :after (ivy avy))

(use-package projectile
  :ensure t
  :delight '(:eval (concat " p[" (projectile-project-name) "]"))
  :config
  (projectile-global-mode)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  )

(use-package projectile-ripgrep
  :ensure t
  :after (projectile))

(use-package python-mode
  :bind (:map python-mode-map
	      ("C-c >" . python-indent-shift-right)
	      ("C-c <" . python-indent-shift-left))
  :config
  (add-hook 'python-mode-hook '(lambda () (setq fill-column 110)))
  )

;; pip install 'python-language-server[all]'
(when (executable-find "pyls")
  (add-hook 'python-mode-hook #'company-mode)
  (add-hook 'python-mode-hook #'lsp))

(use-package flycheck
  :ensure t
  :config
  (setq flycheck-flake8-error-level-alist
	(quote (("^E9.*$" . error)
		("^F82.*$" . error)
		("^F83.*$" . error)
		("^D.*$" . info)
		("^N.*$" . info)
		("^E501$" . info))))
  (setq flycheck-flake8rc ".flake8")
  (setq flycheck-flake8-maximum-complexity 10)
  (setq flycheck-flake8-maximum-line-length 120)
  (add-hook 'python-mode-hook 'flycheck-mode)
  (add-to-list 'flycheck-disabled-checkers 'python-flake8)
  (add-to-list 'flycheck-disabled-checkers 'python-pylint)
  )

(use-package flycheck-mypy
  :after flycheck
  :ensure t
  :config
  (setq flycheck-python-mypy-args "--py2"))

(global-set-key (kbd "<f10>") 'org-agenda)
(global-set-key (kbd "<XF86Eject>") 'org-agenda)
(global-set-key (kbd "C-c r") 'revert-buffer)
(dolist (key '("\C-z" "\C-x\C-z")) (global-unset-key key)) ;; I don't want/need a shortcut for suspend-frame

;; Disable pesky auto-fill-mode
(auto-fill-mode -1)
(turn-off-auto-fill)
(remove-hook 'text-mode-hook #'turn-on-auto-fill)

;; Replace selection when you start typing
(delete-selection-mode t)

;; Write backup files to their own directory
(setq backup-directory-alist
      `(("." . ,(expand-file-name
		 (concat user-emacs-directory "backups")))))

(use-package moe-theme
  :ensure t
  :config
  (moe-dark))

;; Git-Gutter
(use-package git-gutter
  :ensure t
  :delight
  :config
  (global-git-gutter-mode t))

;; display remaining battery life
(display-battery-mode 1)

;; lisps
(use-package rainbow-delimiters
  :ensure t
  :hook
  (((lisp-mode emacs-lisp-mode clojure-mode common-lisp-mode go-mode rust-mode) . rainbow-delimiters-mode))
  )

(use-package paredit
  :ensure t
  :delight
  :hook
  (((lisp-mode emacs-lisp-mode clojure-mode common-lisp-mode) . paredit-mode))
  )

(use-package company
  :ensure t
  :delight " co"
  :hook
  (((emacs-lisp-mode rust-mode) . company-mode))
  :config
  (add-to-list 'company-backends 'company-elisp)
  )

;; (setq cb/enterprise-github "github.corporate.network")
;; (when-let (file-if-exists (substitute-in-file-name )))
;; (string-join '("$GOPATH/src" "$GOPATH/src/github.com/" (concat "$GOPATH/src/" cb/enterprise-github)) ":")

;;golang
(use-package go-mode
  :ensure t
  :init
  (setenv "PATH" "$GOPATH/bin:$PATH" t)
  (setenv "CDPATH" ".:$GOPATH/src/github.com/:$GOPATH/src" t)
  (add-hook 'go-mode-hook '(lambda () (local-set-key (kbd "RET") 'newline-and-indent)))
  (add-hook 'go-mode-hook '(lambda () (setq tab-width 4)))
  (add-hook 'before-save-hook #'gofmt-before-save)
  :config
  (setq gofmt-command "goimports") ;; use goimports for more better gofmting
  ;; (setq gofmt-args '("-local" "github.corporate.network"))
  (put 'go-play-buffer 'disabled t)
  (put 'go-play-region 'disabled t)
  )

(use-package yasnippet :ensure t)

(use-package go-impl :ensure t :after (go-mode))

(use-package go-rename :ensure t :after (go-mode))

(use-package go-guru
  :ensure t
  :after (go-mode)
  :hook ((go-mode . go-guru-hl-identifier-mode))
  :config
  (setq go-guru-build-tags '("servicetest")))

(use-package go-scratch :ensure t :after go-mode)

(use-package flycheck-gometalinter
  :ensure t
  :after (go-mode flycheck)
  :hook
  ((flycheck-mode . flycheck-gometalinter-setup)
   (go-mode . flycheck-mode))
  :config
  (setq flycheck-gometalinter-vendor t)
  (setq flycheck-gometalinter-fast t)
  (setq flycheck-gometalinter-tests t)
  )

(use-package go-eldoc
  :after go-mode
  :ensure t
  :hook ((go-mode . go-eldoc-setup))
  )

(use-package diminish :ensure t)
(diminish 'eldoc-mode)
(diminish 'auto-revert-mode)

(use-package rust-mode
  :ensure t
  :config
  (add-hook 'rust-mode-hook #'rust-enable-format-on-save)
  (setq rust-format-on-save t))

(use-package rust-playground
  :ensure t
  :after (rust-mode))

(use-package flycheck-rust
  :ensure t
  :after (rust-mode flycheck)
  :config
  (add-hook 'flycheck-mode-hook #'flycheck-rust-setup)
  (add-hook 'rust-mode-hook #'flycheck-mode))

;; rustup component add rust-{src,analysis}
;; (might also need to rustup component add --toolchain {nightly,beta} rust-{src,analysis} )
;; (use-package racer
;;   :ensure t
;;   :after (rust-mode company)
;;   :bind (:map rust-mode-map
;;	      ("TAB" . company-indent-or-complete-common))
;;   :hook ((rust-mode . company-mode)
;;	 (rust-mode . racer-mode)
;;	 (racer-mode . eldoc-mode)
;;	 )
;;   )

(use-package use-package-ensure-system-package :ensure t)

(use-package cargo
  :ensure t
  :after (rust-mode))

;; rustup component add rls
(use-package lsp-mode
  :ensure t
  :hook ((rust-mode . lsp)
	 (go-mode . lsp)
	 (python-mode . lsp)
	 (js-mode . lsp)
	 (php-mode . lsp)
	 (c++-mode . lsp)
	 )
  :config
  ; (setq lsp-clients-go-imports-local-prefix "github.corporate.network")
  ; LSP will watch all files in the project
  ; directory by default, so we eliminate some
  ; of the irrelevant ones here, most notable
  ; the .direnv folder which will contain *a lot*
  ; of Nix-y noise we don't want indexed.
  (setq lsp-file-watch-ignored '(
    "[/\\\\]\\.direnv$"
    ; SCM tools
    "[/\\\\]\\.git$"
    "[/\\\\]\\.hg$"
    "[/\\\\]\\.bzr$"
    "[/\\\\]_darcs$"
    "[/\\\\]\\.svn$"
    "[/\\\\]_FOSSIL_$"
    ; IDE tools
    "[/\\\\]\\.idea$"
    "[/\\\\]\\.ensime_cache$"
    "[/\\\\]\\.eunit$"
    "[/\\\\]node_modules$"
    "[/\\\\]vendor$"
    "[/\\\\]\\.fslckout$"
    "[/\\\\]\\.tox$"
    "[/\\\\]\\.stack-work$"
    "[/\\\\]\\.bloop$"
    "[/\\\\]\\.metals$"
    "[/\\\\]target$"
    ; Autotools output
    "[/\\\\]\\.deps$"
    "[/\\\\]build-aux$"
    "[/\\\\]autom4te.cache$"
    "[/\\\\]\\.reference$"))
  )
(use-package lsp-ui
  :ensure t
  :after (lsp-mode)
  :hook ((lsp-mode . lsp-ui-mode)
	 (lsp-mode . flycheck-mode))
  :config
  (setq lsp-prefer-flymake nil)
  )

(use-package default-text-scale
  :ensure t
  :config
  (global-set-key (kbd "C-M-=") 'default-text-scale-increase)
  (global-set-key (kbd "C-M--") 'default-text-scale-decrease))

;; yaml
(use-package yaml-mode
  :ensure t
  :bind (:map yaml-mode-map
	 ("\C-m" . newline-and-indent))
  :config
  (add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode))
  (add-to-list 'auto-mode-alist '("\\.yaml.tmpl\\'" . yaml-mode))
  (add-to-list 'auto-mode-alist '("\\.yml.tmpl\\'" . yaml-mode))
  )

;; toml
(add-to-list 'auto-mode-alist '("\\.toml\\'" . conf-unix-mode))

;; c
(add-hook 'c-mode-hook
	  (lambda ()
	    (add-to-list 'ac-sources 'ac-source-c-headers)
	    (add-to-list 'ac-sources 'ac-source-c-header-symbols t)))

;; docker
(use-package dockerfile-mode
  :ensure t
  :mode "Dockerfile\\'"
  )

(defconst cb/fourspace-protobuf-style
  '((c-basic-offset . 4)
    (indent-tabs-mode . nil)))

;; protobuf
(use-package protobuf-mode
  :ensure t
  :config
  (add-hook 'protobuf-mode-hook
	    (lambda () (c-add-style "four-space" cb/fourspace-protobuf-style t)))
  (add-hook 'protobuf-mode-hook #'flycheck-mode)
  )

;; magithub
;;
;; create a personal access token https://github.corporate.network/settings/tokens
;; add an entry to ~/.authinfo.gpg
;;
;; machine github.corporate.network/api/v3 login USERNAME^magithub password TOKEN
;;
;; do the following in EACH repo you want to use magithub
;;
;; git config github.host github.corporate.network/api/v3; git config github.corporate.network/api/v3.user USERNAME
;; (use-package magithub
;;   :ensure t
;;   :after magit
;;   :config
;;   (magithub-feature-autoinject t)
;;   (setq magithub-github-hosts '("github.corporate.network" "github.com"))
;;   )


;; magit
(use-package magit :ensure t)

;; create a personal access token https://github.corporate.network/settings/tokens
;; add an entry to ~/.authinfo.gpg
;;
;; machine github.corporate.network/api/v3 login USERNAME^forge password TOKEN
;;
;; do the following in EACH repo you want to use magithub
;;
;; git config github.host github.corporate.network/api/v3; git config github.corporate.network/api/v3.user USERNAME
(use-package forge
  :ensure t
  :after magit
  :config
  ;; (add-to-list 'forge-alist '("github.corporate.network" "github.corporate.network/api/v3" "github.corporate.network" forge-github-repository))
  (add-to-list 'magit-status-sections-hook 'forge-insert-assigned-pullreqs)
  (add-to-list 'magit-status-sections-hook 'forge-insert-topic-review-requests)
  )

;; needs a personal access token
;; entry in ~/.authinfo.gpg
;;
;; machine github.corporate.network/api/v3 login USERNAME^github-review password TOKEN
(use-package github-review
  :ensure t
  :after forge
  :config
  ; (setq github-review-host "github.corporate.network/api/v3")
  ;; don't ask me about this for dirlocals
  (put 'github-review-host 'safe-local-variable 'stringp)
  )

;; reasonable things to set in dirlocals
;;
;; home-manager makes init.el immutable, so having these set is
;; convenient considering the alternative is emacs getting irate over
;; not being able to save changes to init.el
(put 'js-indent-level 'safe-local-variable 'integerp)
(put 'c-basic-offset 'safe-local-variable 'integerp)

(use-package vdiff
  :ensure t
  :config
  (setq vdiff-diff-algorithm 'git-diff-patience)
  (define-key vdiff-mode-map (kbd "C-c") vdiff-mode-prefix-map)
  (define-key vdiff-3way-mode-map (kbd "C-c") vdiff-mode-prefix-map)
  )

(use-package vdiff-magit
  :ensure t
  :after (magit vdiff)
  :bind (:map magit-mode-map
	("e" . vdiff-magit-dwim)
	("E" . vdiff-magit))
  :config
  (transient-suffix-put 'magit-dispatch "e" :description "vdiff (dwim)")
  (transient-suffix-put 'magit-dispatch "e" :command 'vdiff-magit-dwim)
  (transient-suffix-put 'magit-dispatch "E" :description "vdiff")
  (transient-suffix-put 'magit-dispatch "E" :command 'vdiff-magit)
  )

;; (setq ediff-merge-split-window-function 'split-window-vertically)
(setq ediff-window-setup-function 'ediff-setup-windows-plain) ;; no popout frame plz!

(use-package sphinx-doc
  :ensure t
  :config
  (add-hook 'python-mode-hook 'sphinx-doc-mode))

;; haskell
(use-package haskell-mode
  :ensure t
  :init
  (setenv "PATH" "$HOME/.ghcup/bin:$PATH" t)
  (add-to-list 'exec-path  (substitute-in-file-name "$HOME/.ghcup/bin"))
  )
(use-package flycheck-haskell
  :ensure t
  :after (flycheck haskell-mode)
  :hook
  ((flycheck-mode . flycheck-haskell-setup)
   (haskell-mode . flycheck-mode))
  )

(use-package intero
  :ensure t
  :config
  (add-hook 'haskell-mode-hook 'intero-mode))

(use-package hl-todo
  :ensure t
  :config
  (global-hl-line-mode)
  (global-hl-todo-mode t)
  (define-key hl-todo-mode-map (kbd "C-c C-t p") 'hl-todo-previous)
  (define-key hl-todo-mode-map (kbd "C-c C-t n") 'hl-todo-next)
  (define-key hl-todo-mode-map (kbd "C-c C-t o") 'hl-todo-occur))

;;;;;;;;;;;;;;;;;;
;; key bindings ;;
;;;;;;;;;;;;;;;;;;

(use-package multiple-cursors
  :ensure t
  :bind
  (("H-d" . mc/mark-next-like-this)
   ("C->" . mc/mark-next-like-this)
   ("C-<" . mc/mark-previous-like-this)
   ("C-c C-<" . mc/mark-all-like-this)
   ("C-S-c C-S-c" . mc/edit-lines)
   ("C-c m l" . mc/edit-lines)
   ("s-d" . mc/mark-next-like-this)))

;; (require 'multi-cursor-keybindings)

;; Scroll faster without a mouse
(global-set-key (kbd "C-c C-p") (lambda () (interactive) (next-line -20)))
(global-set-key (kbd "C-c C-n") (lambda () (interactive) (next-line 20)))

(use-package company-shell
  :ensure t
  :hook ((sh-mode . company-mode))
  :config
  (add-to-list 'company-backends 'company-shell))

(use-package jq-mode
  :ensure t
  :config
  (add-to-list 'auto-mode-alist '("\\.jq$" . jq-mode))
  (with-eval-after-load "json-mode"
    (define-key json-mode-map (kbd "C-c C-j") #'jq-interactively)))

;; org-mode
(use-package org
  :ensure org-plus-contrib
  :config
  (setq org-src-preserve-indentation nil)
  (setq org-src-tab-acts-natively t)
  (add-hook 'org-mode-hook (lambda () (setq indent-tabs-mode nil)))
  (setq org-src-fontify-natively t)
  )

(use-package ob-async :ensure t)
(use-package ob-restclient :ensure t)
(use-package ob-rust :ensure t)
(use-package ob-go :ensure t)
(require 'ob-python)
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
     (python . t)
     (sql . t)
     (haskell . t)
     (dot . t)
     (ditaa . t)
     (rust . t)
     (restclient . t)
     (shell . t)
     (go . t)
     (jq . t)
     (plantuml . t)
     ))
(setq org-confirm-babel-evaluate t)
(setq org-ditaa-jar-path "/usr/share/ditaa/ditaa.jar")

(define-key global-map "\C-cc" 'org-capture)
(setq org-capture-templates
      '(("t" "Todo" entry (file+headline "~/org/agenda.org" "Tasks")
	 "* TODO %?\n  %i\n  %a")
	("j" "Journal" entry (file+datetree "~/org/journal.org")
	 "* %?\nEntered on %U\n  %i\n  %a")
	("J" "Jenkins" entry (file+datetree "~/org/jenkins_shenanigans.org")
	 "* Today, Jenkins %? :jenkins:\n  %t\n  %i\n"
	 )
	("m" "TODO from mail" entry (file+headline "~/org/agenda.org" "Email")
	 "* TODO %?\nref: %a")
	))

;; block templates
(require 'org-tempo)
(add-to-list 'org-modules 'org-tempo)


;; use minted for better source blocks in latex export
(setq org-latex-listings 'minted
      org-latex-packages-alist '(("" "minted"))
      org-latex-pdf-process
      '("pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"
	"pdflatex -shell-escape -interaction nonstopmode -output-directory %o %f"))
(setq org-latex-minted-options '(("breaklines" "true")
				 ("breakanywhere" "true")))

(use-package ox-pandoc :ensure t)
(use-package ox-jira :ensure t)
(use-package ox-hugo :ensure t)

(use-package ox-html5slide
  :ensure t)

(use-package ox-ioslide
  :ensure t)

(use-package beacon
  :ensure t
  :config
  (beacon-mode 1))

(use-package markdown-mode
  :ensure t
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
	 ("\\.md\\'" . markdown-mode)
	 ("\\.markdown\\'" . markdown-mode)))

(use-package groovy-mode
  :ensure t
  :mode (("Jenkinsfile" . groovy-mode)))

(use-package plantuml-mode
  :ensure t
  :config
  (setq org-plantuml-jar-path "~/bin/plantuml.jar"))

(use-package emms
  :ensure t
  :config
  ;; (emms-standard)
  ;; (emms-default-players)
  (require 'emms-player-mpd)
  (emms-all)
  (setq emms-player-list '(emms-player-mpd))
  (setq emms-info-functions '(emms-info))
  (setq emms-player-mpd-server-name "localhost")
  (setq emms-player-mpd-server-port "6600")
  (setq mpc-host "localhost:6600")
  (emms-player-set emms-player-mpd 'regex
                 "\\.ogg\\|\\.mp3\\|\\.wma\\|\\.ogm\\|\\.asf\\|\\.mkv\\|http://\\|mms://\\|\\.rmvb\\|\\.flac\\|\\.vob\\|\\.m4a\\|\\.ape\\|\\.mpc\\|\\.opus")
  )

(use-package fic-mode
  :ensure t
  :config
  (add-hook 'prog-mode-hook 'fic-mode))

(use-package git-link
  ;; :config
  ;; (add-to-list 'git-link-remote-alist '("github.corporate.network" git-link-github))
  ;; (add-to-list 'git-link-commit-remote-alist '("github.corporate.network" git-link-commit-github))
  )

(use-package ox-gfm :ensure t)

(use-package w3m
  :ensure t
  :config
  ;; (setq browse-url-browser-function 'w3m-browse-url)
  )

(use-package string-inflection
  :ensure t)

(use-package figlet :ensure t)

(use-package yasnippet
  :ensure t
  :config
  (yas-global-mode))

(add-hook 'prog-mode-hook '(lambda() (add-hook 'before-save-hook 'copyright-update)))
(setq copyright-year-ranges t)

(use-package graphviz-dot-mode :ensure t)

(use-package weechat
  :ensure t
  :init
  (defvar weechat-formatting-regex
    (rx-let ((attr (in "*!/_|"))   ;NOTE:  is not documented
	     (std  (= 2 digit))
	     (astd (seq attr (= 2 digit)))
	     (ext  (seq "@" (= 5 digit)))
	     (aext (seq "@" attr (= 5 digit))))
	    (rx
	     (or (seq ""
		      (or std
			  ext
			  (seq "F" (or std astd ext aext))
			  (seq "B" (or std ext))
			  (seq "*" (or std
				       astd
				       ext
				       aext
				       (seq (or std astd ext aext)
					    ","
					    (or std astd ext aext))))
			  (seq "b" (in "-FDB#_il"))
			  ""))
		 (seq "" attr)
		 (seq "" attr)
		 ""))))
  :config
  (setq weechat-host-default "204.48.29.163")
  (setq weechat-port-default 9090)
  (setq weechat-mode-default "ssl")
  )

(use-package emacsshot
  :ensure t
  :bind (("<XF86Launch6>" . 'emacsshot-snap-frame)
	 ("<XF86Launch5>" . 'emacsshot-snap-window))
  :config
  (setq emacsshot-with-timestamp t))

(use-package org-present :ensure t)

(use-package twittering-mode :ensure t)

(use-package pulseaudio-control :ensure t
  :config
  (pulseaudio-control-default-keybindings))

(use-package magit-todos
  :ensure t
  :after magit
  :config
  (setq magit-todos-exclude-globs '("**/vendor/*")))

;; terraform
(use-package terraform-mode
  :ensure t
  :config
  (add-hook 'terraform-mode-hook #'terraform-format-on-save-mode)
  )

(use-package terraform-doc :ensure t)

(use-package company-terraform
  :ensure t
  :after (terraform-mode)
  :hook ((terraform-mode . company-mode))
  )

;;php
(use-package php-mode
  :ensure t
  :config
  (add-hook 'php-mode-hook #'company-mode)
  (add-hook 'php-mode-hook #'lsp)
  )

;; javascript
(use-package nodejs-repl :ensure t)
(use-package purescript-mode :ensure t)
(use-package json-mode :ensure t)

(use-package nix-mode :ensure t)

(when (window-system)
  (set-frame-font "Fira Code"))

;; gpg pinentry in the minibuffer
(setq epa-pinentry-mode 'loopback)
(when (= emacs-major-version 25) (pinentry-start))
(setq epg-gpg-program "/usr/local/bin/gpg2")

;; high contrast html rendering in gnus
(setq shr-color-visible-distance-min 60)
(setq shr-color-visible-luminance-min 80)

;; contact harvesting from emails
(use-package bbdb
  :ensure t
  :config
  (setq bbdb/news-auto-create-p t)
  (add-hook 'gnus-startup-hook 'bbdb-insinuate-gnus)
  )

;; org-jira
;; (use-package org-jira
;;   :ensure t
;;   :config
;;   (setq jiralib-url "https://jira.corporate.network")
;;   (setq org-jira-custom-jqls
;;	'(
;;	  (
;;	   :jql " project = MINE AND labels in (team-blades) AND status not in ('Ready to Release', done)"
;;		:limit 50
;;		:filename "team-blades"
;;		)

;;	  ))
;;   )

(setq org-agenda-files '("~/org/agenda.org"))

(use-package undo-tree
  :ensure t
  :delight
  :config
  (global-undo-tree-mode))

(use-package fish-mode :ensure t)

(use-package direnv
  :ensure t
  :hook
  ((prog-mode) . direnv-update-environment)
  :config (direnv-mode t)
  )

;; backslash (\) as escape character in sql
(add-hook 'sql-mode-hook
	 (lambda ()
	   (modify-syntax-entry ?\\ "\\" sql-mode-syntax-table)))

(use-package mastodon :ensure t)
(use-package dhall-mode
  :ensure t
  :mode "\\.dhall\\'"
  )

(use-package which-key :ensure t
  :config
  (which-key-mode))

(use-package notmuch
  :ensure t
  :config
  (setq notmuch-search-oldest-first nil)
  (setq notmuch-tagging-keys
	'(("a" notmuch-archive-tags "Archive")
	  ("u" notmuch-show-mark-read-tags "Mark read")
	  ("f" ("+flagged") "Flag")
	  ("s" ("+spam" "-inbox" "-new") "Spam")
	  ("d" ("+deleted" "+trash" "-new") "Delete")))
  (setq sendmail-program "gmi")
  (setq message-sendmail-extra-arguments '("send" "--quiet" "-t" "-C" "~/Maildir/gmail"))
  (setq message-send-mail-function 'message-send-mail-with-sendmail)
  (setq notmuch-fcc-dirs nil)
  )

;; (server-start)
(put 'downcase-region 'disabled nil)
(put 'narrow-to-region 'disabled nil)

(use-package avy
  :ensure t
  :bind (("C-z" . avy-goto-char)))
