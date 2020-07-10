;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-term-color-vector
   [unspecified "#FFFFFF" "#d15120" "#5f9411" "#d2ad00" "#6b82a7" "#a66bab" "#6b82a7" "#505050"] t)
 '(custom-safe-themes
   (quote
    ("7675ffd2f5cb01a7aab53bcdd702fa019b56c764900f2eea0f74ccfc8e854386" "13d20048c12826c7ea636fbe513d6f24c0d43709a761052adbca052708798ce3" "ed0b4fc082715fc1d6a547650752cd8ec76c400ef72eb159543db1770a27caa7" "021720af46e6e78e2be7875b2b5b05344f4e21fad70d17af7acfd6922386b61e" "42b9d85321f5a152a6aef0cc8173e701f572175d6711361955ecfb4943fe93af" "a24c5b3c12d147da6cef80938dca1223b7c7f70f2f382b26308eba014dc4833a" "7366916327c60fdf17b53b4ac7f565866c38e1b4a27345fe7facbf16b7a4e9e8" "b050365105e429cb517d98f9a267d30c89336e36b109a1723d95bc0f7ce8c11d" "3fa81193ab414a4d54cde427c2662337c2cab5dd4eb17ffff0d90bca97581eb6" "8cb818e0658f6cc59928a8f2b2917adc36d882267bf816994e00c5b8fcbf6933" "eae43024404a1e3c4ea853a9cf7f6f2ad5f091d17234ec3478a23591f25802eb" "c1390663960169cd92f58aad44ba3253227d8f715c026438303c09b9fb66cdfb" "732b807b0543855541743429c9979ebfb363e27ec91e82f463c91e68c772f6e3" "5dc0ae2d193460de979a463b907b4b2c6d2c9c4657b2e9e66b8898d2592e3de5" "98cc377af705c0f2133bb6d340bf0becd08944a588804ee655809da5d8140de6" "628278136f88aa1a151bb2d6c8a86bf2b7631fbea5f0f76cba2a0079cd910f7d" "82d2cac368ccdec2fcc7573f24c3f79654b78bf133096f9b40c20d97ec1d8016" "06f0b439b62164c6f8f84fdda32b62fb50b6d00e8b01c2208e55543a6337433a" "bb08c73af94ee74453c90422485b29e5643b73b05e8de029a6909af6a3fb3f58" "1b8d67b43ff1723960eb5e0cba512a2c7a2ad544ddb2533a90101fd1852b426e" "8db4b03b9ae654d4a57804286eb3e332725c84d7cdab38463cb6b97d5762ad26" default)))
)

;; make sure use-package is installed
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))

(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

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

(use-package delight :ensure t)

(use-package helm
  :ensure t
  :delight
  :config
  (require 'helm-config)
  (helm-mode 1)
  (global-set-key (kbd "M-x") 'helm-M-x)
  (global-set-key (kbd "C-x C-f") 'helm-find-files)
  (global-set-key (kbd "C-x b") 'helm-buffers-list)
  (global-set-key (kbd "M-w") 'copy-region-as-kill)
  (global-set-key (kbd "C-s") 'helm-occur)
  (setq helm-mode-fuzzy-match t)
  (setq helm-gtags-path-style (quote relative))
  (setq helm-gtags-auto-update t)
  (setq helm-gtags-ignore-case t)
  )

(use-package helm-ag :ensure t :after helm)

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

(use-package helm-projectile
  :ensure t
  :after (helm projectile)
  :config
  (helm-projectile-on)
  (global-set-key (kbd "C-c p p") 'helm-projectile)
  )

(use-package python-mode
  :bind (:map python-mode-map
	      ("C-c >" . python-indent-shift-right)
	      ("C-c <" . python-indent-shift-left))
  :config
  (add-hook 'python-mode-hook '(lambda () (setq fill-column 110)))
  )

(use-package company-lsp
  :ensure t
  :after (company lsp-mode)
  :config
  (add-to-list 'company-backends 'company-lsp)
  )

;; pip install 'python-language-server[all]'
(when (executable-find "pyls")
  (add-hook 'python-mode-hook #'company-mode)
  (add-hook 'python-mode-hook #'lsp))

(use-package flycheck
  :ensure t
  :after helm
  :bind (:map flycheck-mode-map
	      ("C-c ! h" . helm-flycheck))
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
  ;; (define-key flycheck-mode-map (kbd "C-c ! h") 'helm-flycheck)
  )

(use-package flycheck-mypy
  :after flycheck
  :ensure t
  :config
  (setq flycheck-python-mypy-args "--py2"))

;; autocomplete
(use-package auto-complete
  :ensure t
  :bind (:map ac-completing-map
	 ("C-:" . ac-complete-with-helm)
	 :map ac-complete-mode-map
	 ("C-:" . ac-complete-with-helm)
	 :map ac-mode-map
	 ("C-:" . ac-complete-with-helm))
  :config
  (require 'auto-complete-config)
  )

(use-package ac-helm
  :ensure t
  :after (helm auto-complete)
  :config
  (global-set-key (kbd "C-:") 'ac-complete-with-helm)
  (define-key ac-completing-map (kbd "C-:") 'ac-complete-with-helm))

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
  (load-theme 'moe-light))


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

;; (setq cb/go-autocomplete-file (file-if-exists (substitute-in-file-name "$GOPATH/src/github.com/nsf/gocode/emacs/go-autocomplete.el")))

;; (use-package go-autocomplete
;;   :if cb/go-autocomplete-file
;;   :after yasnippet
;;   :init
;;   (require 'go-autocomplete)
;;   (require 'auto-complete-config)
;;   :load-path (lambda () (file-name-directory cb/go-autocomplete-file))
;;   :hook ((go-mode . auto-complete-mode)
;; 	 (go-mode . yas-minor-mode))
;;   :config
;;   (setq ac-go-expand-arguments-into-snippets t)
;;   )

(unless (executable-find "gocode") "Gocode not found, autocomplete not available in go-mode. Please run go get -u github.com/nsf/gocode")

;; both this and the autocomplete one require gocode (go get -u github.com/nsf/gocode)
(use-package company-go
  :ensure t
  :if (executable-find "gocode")
  :after (company go-mode)
  :hook ((go-mode . company-mode))
  :config
  (add-to-list 'company-backends 'company-go)
  )

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

(use-package helm-go-package
  :ensure t
  :after (helm go-mode)
  :config
  (eval-after-load 'go-mode
    '(substitute-key-definition 'go-import-add 'helm-go-package go-mode-map)))

(use-package go-eldoc
  :after go-mode
  :ensure t
  :hook ((go-mode . go-eldoc-setup))
  )

(use-package diminish :ensure t)
(diminish 'eldoc-mode)
(diminish 'auto-revert-mode)

(use-package helm-company
  :ensure t
  :after (company helm)
  :bind (:map company-mode-map
	      ("C-:" . helm-company)
	      :map company-active-map
	      ("C-:" . helm-company)
	      ))

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
;; 	      ("TAB" . company-indent-or-complete-common))
;;   :hook ((rust-mode . company-mode)
;; 	 (rust-mode . racer-mode)
;; 	 (racer-mode . eldoc-mode)
;; 	 )
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
	 (python-mode . lsp))
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
  :config
  (add-to-list 'auto-mode-alist '("Dockerfile\\'" . dockerfile-mode))
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
  (put 'var 'safe-local-variable #'github-review-host)
  )

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

(use-package "helm-gtags"
  :ensure t
  :bind (:map helm-gtags-mode-map
	      ("M-." . helm-gtags-dwim)
	      ("M-t" . helm-gtags-find-tag)
	      ("M-r" . helm-gtags-find-rtag)
	      ("M-s" . helm-gtags-find-symbol)
	      ("M-g M-p" . helm-gtags-parse-file)
	      ("C-c <" . helm-gtags-previous-history)
	      ("C-c >" . helm-gtags-next-history)
	      ("M-," . helm-gtags-pop-stack))
  :hook
  (((c-mode c++-mode asm-mode python-mode) . helm-gtags-mode)))

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
(setq org-src-preserve-indentation nil)
(setq org-src-tab-acts-natively t)
(add-hook 'org-mode-hook (lambda () (setq indent-tabs-mode nil)))
(setq org-src-fontify-natively t)
(use-package ob-async :ensure t)
(use-package ob-restclient :ensure t)
(use-package ob-rust :ensure t)
(use-package ob-go :ensure t)
(require 'org)
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
  (emms-standard)
  (emms-default-players))

(use-package fic-mode
  :ensure t
  :config
  (add-hook 'prog-mode-hook 'fic-mode))

(use-package git-link
  :ensure t
  ;; :config
  ;; (add-to-list 'git-link-remote-alist '("github.corporate.network" git-link-github))
  ;; (add-to-list 'git-link-commit-remote-alist '("github.corporate.network" git-link-commit-github))
  )

(use-package ox-gfm :ensure t)

(use-package w3m
  :ensure t
  :config
  (setq browse-url-browser-function 'w3m-browse-url))
;;'(browse-url-browser-function (quote browse-url-w3))

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
  :config
  (setq weechat-host-default "204.48.29.163")
  (setq weechat-port-default 9090))

(use-package helm-rg
  :after (helm)
  :ensure t)

(use-package emacsshot
  :ensure t
  :bind (("<XF86Launch6>" . 'emacsshot-snap-frame)
	 ("<XF86Launch5>" . 'emacsshot-snap-window))
  :config
  (setq emacsshot-with-timestamp t))

(use-package org-present :ensure t)

(use-package md4rd :ensure t
  :config
  (setq md4rd-subs-active '(rust emacs golang)))
(use-package twittering-mode :ensure t)
(use-package helm-lobsters
  :after helm
  :ensure t)

(use-package pulseaudio-control :ensure t
  :config
  (pulseaudio-control-default-keybindings))

(use-package magit-todos
  :ensure t
  :after magit
  :config
  (setq magit-todos-exclude-globs '("**/vendor/*")))

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
;; 	'(
;; 	  (
;; 	   :jql " project = MINE AND labels in (team-blades) AND status not in ('Ready to Release', done)"
;; 		:limit 50
;; 		:filename "team-blades"
;; 		)
	  
;; 	  ))
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

;; (server-start)
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(put 'downcase-region 'disabled nil)
(put 'narrow-to-region 'disabled nil)
