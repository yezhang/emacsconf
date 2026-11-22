;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

;; 在这里声明额外安装的包，改完后需运行 'doom sync'。
;; 用法示例见 'SPC h d h' 的 Doom 文档。

;; 解决中文表格对齐问题
(package! valign)

;; D2 绘图语言：tree-sitter major mode（Emacs 30.1+）
(package! d2-ts-mode)

;; Org-babel 中嵌入 D2 图
(package! ob-d2)
