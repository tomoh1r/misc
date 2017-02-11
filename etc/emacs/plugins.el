;;
;; 種々のプラグイン設定
;;

;;
;; unicode-fonts
;;
(require 'unicode-fonts)
(unicode-fonts-setup)

;;
;; evil
;;
;(require 'evil)
;(evil-mode 1)

;;
;; direx-el
;; (use popwin-el devloper ver.)
;; https://github.com/m2ym/direx-el
;; (require 'direx)
;;
(require 'popwin)
(require 'direx)
(require 'direx-project)
(setq
    display-buffer-function
    'popwin:display-buffer)
(setq
    direx:leaf-icon " "
    direx:open-icon "▾ "
    direx:closed-icon "▸ ")
(push
    '(direx:direx-mode :position left :width 25 :dedicated t)
    popwin:special-display-config)
(global-set-key
    (kbd "C-x j")
    'direx:jump-to-directory-other-window)
;(global-set-key
;    (kbd "C-x C-j")
;    'direx-project:jump-to-project-root-other-window)

;;
;; ibus
;;
(require 'ibus)
(add-hook 'after-init-hook 'ibus-mode-on)

;; C-SPC は Set Mark に使う
(ibus-define-common-key ?\C-\s nil)

;; IBusの状態によってカーソル色を変化させる
(setq ibus-cursor-color '("red" "blue" "limegreen"))

;; C-j で半角英数モードをトグルする
(ibus-define-common-key ?\C-j t)

;; カーソルの位置に予測候補を表示
(setq ibus-prediction-window-position t)

;; Undo の時に確定した位置まで戻る
(setq ibus-undo-by-committed-string t)

;; インクリメンタル検索中のカーソル形状を変更する
(setq ibus-isearch-cursor-type 'hollow)

;; 全てのバッファで IME の状態を共有
(setq ibus-mode-local nil)

;;
;; tabbar
;;
(require 'tabbar)
(tabbar-mode)
(global-set-key "\M-]" 'tabbar-forward)  ; 次のタブ
(global-set-key "\M-[" 'tabbar-backward) ; 前のタブ
;; タブ上でマウスホイールを使わない
(tabbar-mwheel-mode nil)
;; グループを使わない
(setq tabbar-buffer-groups-function nil)
;; 左側のボタンを消す
(dolist
    (btn '(
        tabbar-buffer-home-button
        tabbar-scroll-left-button
        tabbar-scroll-right-button))
    (set btn (cons (cons "" nil) (cons "" nil))))
;; 色設定
(when window-system
    (set-face-attribute ; バー自体の色
        'tabbar-default nil
        :background "white"
        :family "Migu 2M"
        :height 1.0))
(set-face-attribute ; アクティブなタブ
    'tabbar-selected nil
    :background "black"
    :foreground "white"
    :weight 'bold
    :box nil)
(set-face-attribute ; 非アクティブなタブ
    'tabbar-unselected nil
    :background "white"
    :foreground "black"
    :box nil)
;; * で始まるバッファーは表示しない
;(defun my-tabbar-buffer-list ()
;    (remove-if
;        (lambda (buffer)
;            (find (aref (buffer-name buffer) 0) "\*"))
;        (buffer-list)))
;(setq tabbar-buffer-list-function 'my:tabbar-buffer-list)
