;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; 字体与主题
(setq doom-font (font-spec :size 16))
(setq doom-theme 'doom-one)
(setq display-line-numbers-type t)

;; 加载私密配置（笔记目录等多机差异信息），不存在则跳过
(when (file-exists-p (expand-file-name "secrets.el" doom-user-dir))
  (load! "secrets"))

;;; Org 目录（支持用环境变量做多机切换，未设置时回落到默认路径）

(defun my/ensure-directory (path default)
  "PATH 指向有效目录时使用之，否则使用 DEFAULT；目录不存在时自动创建。"
  (let ((dir (expand-file-name
              (if (and path
                       (not (string-empty-p path))
                       (file-directory-p (expand-file-name path)))
                  path
                default))))
    (unless (file-directory-p dir)
      (make-directory dir t))
    (file-name-as-directory dir)))

(setq org-directory
      (my/ensure-directory (getenv "ORG_DIR")
                           "~/Documents/Notes/ObsidianDefaultVault/emacs-org/org-notes")
      org-roam-directory
      (my/ensure-directory (getenv "ORG_ROAM_DIR")
                           "~/Documents/Notes/ObsidianDefaultVault/emacs-org/org-roam-notes"))

;; 解决中文下表格对齐问题
(use-package! valign
  :hook (org-mode . valign-mode))

;;; ──────────────────────────────────────────────────────────────
;;; D2 绘图语言支持
;;; ──────────────────────────────────────────────────────────────

;; d2-ts-mode：基于 tree-sitter 的 D2 major mode（.d2 文件关联由包自动注册）
;; 快捷键（在 .d2 buffer 中）：
;;   C-c C-c 编译当前文件    C-c C-b 编译 buffer    C-c C-r 编译选中区域
;;   C-c C-w 开启 watch 实时预览    C-c C-q 停止 watch    C-c C-p Emacs 内预览
(use-package! d2-ts-mode
  :config
  (setq d2-ts-mode-d2-executable "/opt/homebrew/bin/d2"
        d2-ts-mode-output-format "svg"
        d2-ts-mode-indent-offset 2
        ;; watch 预览开在 Emacs 侧边窗口；想改用浏览器可设为 'browser
        d2-ts-mode-watch-method 'emacs))

;; ob-d2：在 Org 文件中嵌入 D2 图（Doom 会按代码块语言名自动懒加载）
;; 用法：
;;   #+begin_src d2 :file images/demo.svg :theme 200
;;   用户 -> 网关: 请求
;;   #+end_src
;; 光标在代码块上按 C-c C-c 即生成图片
(use-package! ob-d2
  :after org
  :config
  (setq ob-d2-command "/opt/homebrew/bin/d2"))

;; 用 C-c ' 编辑 d2 代码块时启用 d2-ts-mode 高亮
(after! org-src
  (add-to-list 'org-src-lang-modes '("d2" . d2-ts)))
