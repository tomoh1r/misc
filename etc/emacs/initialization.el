;;
;; プラグイン読み込みなど初期化
;;

;; Package Manegement
(require 'package)

;;(add-to-list
;;    'package-archives
;;    '("melpa-stable" . "http://melpa-stable.milkbox.net/packages/")
;;    t)

(add-to-list
    'package-archives
    '("melpa" . "http://melpa.milkbox.net/packages/")
    t)

(add-to-list
    'package-archives
    '("marmalade" . "http://marmalade-repo.org/packages/"))

(package-initialize)

;; cask
(require 'cask "~/.cask/cask.el")
(cask-initialize)
(require 'pallet)

;; load-pathに追加
(my:add-to-load-path "elisp")
