;;
;; init.el
;;

(defconst my:user-init-dir
    (cond
        ((boundp 'user-emacs-directory) user-emacs-directory)
        ((boundp 'user-init-directory) user-init-directory)
        (t "~/.emacs.d/")))

(defun my:load-user-file (file)
    (interactive "f")
    "Load a file in current user's configuration directory"
    (load-file (expand-file-name file my:user-init-dir)))

;; 関数定義
(my:load-user-file "def.el")

;; プラグイン初期化
(my:load-user-file "initialization.el")

;; 基礎設定
(my:load-user-file "basics.el")

;; プラグイン設定
(my:load-user-file "plugins.el")
