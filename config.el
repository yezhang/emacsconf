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


;;; ──────────────────────────────────────────────────────────────
;;; org-roam 捕获模板与日记模板
;;; ──────────────────────────────────────────────────────────────
;; 用法：SPC n r n 弹出模板选择（按字母）；SPC n r f / SPC n r i 默认走第一个模板。
(after! org-roam
  (setq org-roam-capture-templates
        '(
          ;; 1. 永久笔记：自己的想法、概念（SPC n r f/i/n 默认路径）
          ("d" "永久笔记" plain "%?"
           :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+filetags: :permanent:\n#+date: %U\n")
           :unnarrowed t)

          ;; 2. 网页摘录：博客/文档里的观点，ROAM_REFS 记出处 URL
          ;;    从 eww 捕获（eww 里按 C）时 URL 自动带入；手动捕获时提示输入
          ("w" "网页摘录" plain "* 摘录\n#+begin_quote\n%i\n#+end_quote\n\n* 我的转述\n%?\n\n* 关联\n"
           :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+filetags: :webclip:\n#+date: %U\n:PROPERTIES:\n:ROAM_REFS: %(or (my/eww-capture-url) (read-string \"URL: \"))\n:END:\n")
           :unnarrowed t)

          ;; 3. 文献笔记：论文/书籍，核心论点 + 我的评价两段式
          ("l" "文献笔记" plain "* 核心论点\n%?\n\n* 我的评价\n"
           :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+filetags: :literature:\n#+date: %U\n:PROPERTIES:\n:ROAM_REFS: %^{引用键或URL}\n:END:\n")
           :unnarrowed t)

          ;; 4. 人物：合作者、领域专家
          ("p" "人物" plain "* 背景\n%?\n\n* 相关讨论\n"
           :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+filetags: :person:\n#+date: %U\n")
           :unnarrowed t)

          ;; 5. 浏览器 bookmarklet 专用（由 org-protocol roam-ref 触发，勿手动选用）
          ;;    标题自动取网页标题，URL 自动写入 ROAM_REFS，选中文字进摘录块
          ("b" "浏览器捕获" plain "* 原文摘录\n#+begin_quote\n%i\n#+end_quote\n\n* 我的转述\n%?\n"
           :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+filetags: :webclip:\n#+date: %U\n")
           :unnarrowed t)))

  ;; 日记：闪念统一落到当天 daily/YYYY-MM-DD.org 的"闪念"小节下
  (setq org-roam-dailies-capture-templates
        '(("d" "闪念" entry "* %U %?"
           :target (file+head+olp "daily/%<%Y-%m-%d>.org"
                                  "#+title: %<%Y-%m-%d>\n#+filetags: :daily:\n"
                                  ("闪念")))
          ("t" "任务线索" entry "* TODO %?"
           :target (file+head+olp "daily/%<%Y-%m-%d>.org"
                                  "#+title: %<%Y-%m-%d>\n#+filetags: :daily:\n"
                                  ("闪念"))))))


;;; ──────────────────────────────────────────────────────────────
;;; 博客阅读：给定网址 → eww 净化阅读 → org-roam 阅读笔记
;;; ──────────────────────────────────────────────────────────────
;; 使用流程：
;;   1. SPC o w 输入文章网址，eww 打开原始网页（保留公式和排版）
;;   2. 阅读中按 C 一键捕获为 roam 笔记（自动带原文链接到 ROAM_REFS）
;;      页面太乱时按 R 手动净化（会丢 LaTeX 公式和样式，慎用）
;;   3. 之后 SPC n r f 检索、roam 反向链接自动呈现文章间关联

;;; --- 阅读入口 ---
(defun my/read-url (url)
  "输入网址，用 eww 打开并开始阅读（默认保留网页原始格式）。"
  (interactive "M网址: ")
  (eww url))

(map! :leader :desc "打开网址开始阅读" "o w" #'my/read-url)

;;; --- eww 阅读体验 ---
(after! eww
  (require 'ol-eww)                       ; 让 org-store-link 支持 eww 页面
  (setq shr-max-image-proportion 0.4      ; 图片高度不超过窗口 40%
        shr-use-colors t                  ; 保留网页原始配色与样式
        shr-indentation 2
        shr-width 72)                     ; 行宽限制，接近纸质书阅读体验

  (add-hook 'eww-after-render-hook #'visual-line-mode)

  ;; 默认展示原始网页：eww-readable 会丢失 LaTeX 公式和排版样式，
  ;; 只在广告/导航干扰严重时按 R 手动净化。
  ;; 想恢复自动净化，把下面 nil 改为 t 即可。
  (defvar my/eww-auto-readable nil)
  (defun my/eww-auto-readable ()
    (when (and my/eww-auto-readable (derived-mode-p 'eww-mode))
      (eww-readable)))
  (add-hook 'eww-after-render-hook #'my/eww-auto-readable)

  (map! :map eww-mode-map
        :n "R" #'eww-readable                       ; 手动净化/还原
        :n "C" #'my/eww-roam-capture                ; 捕获为阅读笔记（见下）
        :n "E" #'eww-browse-with-external-browser   ; 复杂页面去外部浏览器
        :n "L" #'org-store-link))                   ; 只存链接，稍后记

;;; --- eww → org-roam 阅读笔记 ---
;; 从 eww 捕获时暂存页面 URL（一次性使用，避免手动捕获时误带旧链接）
(defvar my/eww--pending-url nil
  "从 eww 触发捕获时暂存的页面 URL。")

(defun my/eww-capture-url ()
  "取出暂存的 eww 页面 URL 并清空；没有则返回 nil。
供 org-roam 捕获模板在 ROAM_REFS 中调用。"
  (prog1 my/eww--pending-url
    (setq my/eww--pending-url nil)))

(defun my/eww-roam-capture ()
  "把当前 eww 文章捕获为 org-roam 网页摘录笔记（复用 w 模板）。
URL 自动写入 ROAM_REFS，选中的文字进摘录块。"
  (interactive)
  (unless (derived-mode-p 'eww-mode)
    (user-error "当前不在 eww 缓冲区"))
  (org-store-link nil t)                ; 静默 store-link，填入链接 plist
  (setq my/eww--pending-url
        (and (boundp 'org-store-link-plist)
             (plist-get org-store-link-plist :link)))
  (org-roam-capture nil "w"))
