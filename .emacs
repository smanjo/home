(let ((minimum-version "24.5.1"))
  (when (version< emacs-version minimum-version)
    (error (concat "Emacs version [" emacs-version "]"
                   " is below minimum version expected [" minimum-version "]"
                   " for this ,emacs config"))))

(add-to-list 'load-path "~/.emacs.d/lisp/")

(defvar backup-dir (concat user-emacs-directory "backups"))
(defvar autosave-dir (concat user-emacs-directory "auto-saves"))

(if (not (file-exists-p backup-dir))
    (make-directory backup-dir t))
(if (not (file-exists-p autosave-dir))
    (make-directory autosave-dir t))

(setq backup-directory-alist
      `(("." . ,backup-dir)))

; Move auto-save files (ie. "myfile#") to a central dir,
; but leave the REMOTE FILES as default (/tmp)
(add-to-list 'auto-save-file-name-transforms
             `(".*" ,(concat autosave-dir "/\\1") t) 'append)


(setq make-backup-files t
      backup-by-copying t
      version-control t
      delete-old-versions t
      delete-by-moving-to-trash t
      kept-old-versions 4
      kept-new-versions 16
      auto-save-default t
      auto-save-timeout 15
      auto-save-interval 150
      auto-save-list-file-prefix nil
      )

(setq-default inhibit-startup-screen t)
(setq inhibit-splash-screen t)
(setq inhibit-startup-message t)
(setq initial-scratch-message "")
(setq initial-major-mode 'fundamental-mode)

(global-display-line-numbers-mode)
(setq-default column-number-mode t)
(size-indication-mode)

(add-hook 'before-save-hook 'delete-trailing-whitespace)
(setq-default indent-tabs-mode nil)

(require 'whitespace)
(setq-default whitespace-style '(face trailing lines empty indentation::space))
(setq-default whitespace-line-column 100)
(global-whitespace-mode 1)

(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.[agj]sp\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.css?\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.scss?\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.xml?\\'" . web-mode))
(setq web-mode-engines-alist
      '(("ninja2" . "\\.html\\'")))
(defun my-web-mode-hook ()
  "Hooks for Web mode."
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-enable-auto-pairing t)
  (setq web-mode-enable-css-colorization t)
  (setq web-mode-enable-current-element-highlight t)
  (setq web-mode-enable-current-column-highlight t)
)
(add-hook 'web-mode-hook  'my-web-mode-hook)

;; fxbois' theme: see http://web-mode.org
;;(set-face-attribute 'default            nil :background "grey14" :foreground "ivory1")
;;(set-face-attribute 'fringe             nil :background "grey20")
;;(set-face-attribute 'highlight          nil :background "grey16")
;;(set-face-attribute 'mode-line          nil :box nil :background "grey26" :foreground "grey50")
;;(set-face-attribute 'mode-line-inactive nil :background "grey40")

(set-face-attribute 'web-mode-html-tag-face          nil :foreground "#777777")
(set-face-attribute 'web-mode-html-tag-custom-face   nil :foreground "#8a9db4")
(set-face-attribute 'web-mode-html-tag-bracket-face  nil :foreground "#aaaaaa")
(set-face-attribute 'web-mode-html-attr-name-face    nil :foreground "#aaaaaa")
(set-face-attribute 'web-mode-html-attr-equal-face   nil :foreground "#eeeeee")
(set-face-attribute 'web-mode-html-attr-value-face   nil :foreground "RosyBrown")
(set-face-attribute 'web-mode-html-attr-custom-face  nil :foreground "#8a9db4")
(set-face-attribute 'web-mode-html-attr-engine-face  nil :foreground "#00f5ff")
(set-face-attribute 'web-mode-comment-face           nil :foreground "Firebrick")
(set-face-attribute 'web-mode-constant-face          nil :foreground "aquamarine")
(set-face-attribute 'web-mode-css-at-rule-face       nil :foreground "plum4")
(set-face-attribute 'web-mode-css-selector-face      nil :foreground "orchid3")
(set-face-attribute 'web-mode-css-pseudo-class-face  nil :foreground "plum2")
(set-face-attribute 'web-mode-css-property-name-face nil :foreground "Pink3")
(set-face-attribute 'web-mode-preprocessor-face      nil :foreground "DarkSeaGreen")
(set-face-attribute 'web-mode-block-delimiter-face   nil :foreground "DarkSeaGreen")
(set-face-attribute 'web-mode-block-control-face     nil :foreground "SeaGreen")
(set-face-attribute 'web-mode-variable-name-face     nil :foreground "Burlywood")
