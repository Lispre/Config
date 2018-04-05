;;; private/my/+bindings.el -*- lexical-binding: t; -*-

(define-inline +my/prefix-M-x (prefix)
  (inline-quote
   (lambda () (interactive)
     (setq unread-command-events (string-to-list ,prefix))
     (call-interactively #'execute-extended-command))))

(define-inline +my/simulate-key (key)
  (inline-quote
   (lambda () (interactive)
     (setq prefix-arg current-prefix-arg)
     (setq unread-command-events (listify-key-sequence (read-kbd-macro ,key))))))

(map!
 ;; localleader
 :m ","    nil

 (:map prog-mode-map
   ;; Override default :n < >
   :nm "<" #'lispyville-previous-opening
   :nm ">" #'lispyville-next-closing

   :n "H"  #'lsp-ui-peek-jump-backward
   :n "L"  #'lsp-ui-peek-jump-forward
   )

 :n "M-u" (+my/simulate-key "[")
 :n "M-i" (+my/simulate-key "]")
 :m "M-h"  #'smart-up
 :m "M-l"  #'smart-down
 :n "M-."  #'+lookup/definition
 :n "M-j"  #'+my/find-definitions

 :n "C-c a" #'org-agenda
 :n "C-s"  #'swiper
 :n "C-,"  #'+my/find-references
 :n ";"    (λ! (avy-goto-char-timer) (+my/find-definitions))
 ;; :n "s"    #'avy-goto-char-timer

 :n "ga"   #'lsp-ui-find-workspace-symbol
 :n "gf"   #'+my/ffap
 :n "go"   (λ! (message "%S" (text-properties-at (point))))

 (:leader
   :n "SPC" #'+ivy/switch-workspace-buffer
   :n "M-u" (+my/simulate-key "SPC [")
   :n "M-i" (+my/simulate-key "SPC ]")
   (:desc "app" :prefix "a"
     :n "g" (λ! (shell-command-on-region (point-min) (point-max) "genhdr" t t))
     :n "G" (λ! (shell-command-on-region (point-min) (point-max) "genhdr windows" t t))
     )
   (:prefix "b"
     :desc "Last buffer" :n "b" #'evil-switch-to-windows-last-buffer
     :n "l" #'ivy-switch-buffer
     )
   (:desc "error" :prefix "e"
     :n "n" #'flycheck-next-error
     :n "p" #'flycheck-previous-error
     )
   (:prefix "f"
     :n "p" #'treemacs-projectile-toggle
     :n "P" #'treemacs-projectile
     :n "C-p" #'+default/find-in-config
     :n "C-S-p" #'+default/browse-config
     :n "t" #'treemacs-toggle
     :n "T" #'treemacs
     )
   (:prefix "g"
     :n "*" (+my/prefix-M-x "magit-")
     )
   (:prefix "h"
     :n "C" #'helpful-command
     )
   :desc "lispyville" :n "l" (+my/prefix-M-x "lispyville ")
   (:prefix "o"
     :n "ee" #'+eshell/open
     :n "el" #'+eshell/open-last
     :n "ej" #'+eshell/next
     :n "ek" #'+eshell/previous
     :n "es" #'+eshell/switch
     :n "s" #'+eshell/open-popup
     )
   (:prefix "p"
     :n "e" #'projectile-run-eshell
     :n "f" #'counsel-projectile-find-file
     :n "*" (+my/prefix-M-x "projectile-")
     )
   (:prefix "r"
     :n "l" #'ivy-resume
     )

   ;; Rebind to "S"
   (:desc "snippets" :prefix "S"
     :desc "New snippet"            :n  "n" #'yas-new-snippet
     :desc "Insert snippet"         :nv "i" #'yas-insert-snippet
     :desc "Find snippet for mode"  :n  "s" #'yas-visit-snippet-file
     :desc "Find snippet"           :n  "S" #'+default/find-in-snippets)

   (:desc "search" :prefix "s"
     :n "b" #'swiper-all
     :desc "Directory"              :nv "d" (λ! (+ivy/project-search t))
     :desc "Project"                :nv "s" #'+ivy/project-search
     :desc "Symbols"                :nv "i" #'imenu
     :desc "Symbols across buffers" :nv "I" #'imenu-anywhere
     :desc "Online providers"       :nv "o" #'+lookup/online-select
     )

   (:desc "toggle" :prefix "t"
     :n "d" #'doom/toggle-debug-mode
     :n "D" #'+my/realtime-elisp-doc
     )
   )

 :n "x" nil
 (:desc "xref" :prefix "x"
   :n "SPC" #'ccls/random
   :n ";" (λ! (avy-goto-char-timer) (+my/find-references))
   :n "b" #'ccls/base
   :n "d" #'ccls/derived
   :n "e" #'ccls/callers
   ;; caller hierarchy
   :n "c" #'ccls-call-hierarchy
   ;; callee hierarchy
   :n "C" (λ! (ccls-call-hierarchy t))
   ;; derived hierarchy
   :n "i" (λ! (ccls-inheritance-hierarchy t))
   ;; base hierarchy
   :n "I" #'ccls-inheritance-hierarchy
   :n "l" #'ccls-code-lens-mode
   :n "m" #'ccls-member-hierarchy
   :n "n" #'lsp-goto-implementation
   :n "t" #'lsp-goto-type-definition
   :n "v" #'ccls/vars
   :n "x" #'evil-delete-char
   )

 ;; ivy
 (:after ivy
   :map ivy-minibuffer-map
   "<tab>" #'ivy-call-and-recenter
   "C-;"   #'ivy-avy
   )

 (:after company
   (:map company-active-map
     ;; Don't interfere with `evil-delete-backward-word' in insert mode
     "C-v"        #'company-next-page
     "M-v"        #'company-previous-page
     "C-i"        #'company-complete-selection
     "SPC"        nil)))