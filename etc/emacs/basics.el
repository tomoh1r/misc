;;
;; 種々の基本設定
;;

;; Language.
(set-language-environment 'Japanese)

;; Coding system.
(set-default-coding-systems 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-buffer-file-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

;; global なフォント設定
(when window-system
    (add-to-list 'default-frame-alist '(font . "Migu 2M")))
(when window-system
    (set-face-attribute 'default t :font "Migu 2M" ))

;; ime nn で ん にする
(setq quail-japanese-use-double-n t)

;; theme
(load-theme 'tango t)

;; バックアップファイルの保存先ディレクトリの変更
(setq backup-directory-alist
    (cons (cons ".*" (expand-file-name "~/.emacs.d/backup"))
        backup-directory-alist))

;; 自動保存ファイルの保存先ディレクトリの変更
(setq auto-save-file-name-transforms
    `((".*", (expand-file-name "~/.emacs.d/backup/") t)))

;; 起動時に、Welcome to GNU Emacs... というメッセージが出るのを抑制
(setq inhibit-startup-message t)
;; 空っぽの scratch buffer にする
(setq initial-scratch-message nil)
