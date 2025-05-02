;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!
(setq doom-font (font-spec :size 14))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
;;
;; 为了在多台电脑之间共享配置文件，但是设置不同的本地目录，使用环境变量的方法处理。
;;
;; 统一路径检测函数
(defun my/ensure-directory (path default)
  "确保 PATH 是有效目录，否则使用 DEFAULT 路径，并自动创建默认目录"
  
  (let* ((expanded-path (if path (expand-file-name path) ""))
         (expanded-default (expand-file-name default))
         (final-path (cond
                      ((and path
                            (stringp path)
                            (not (string-empty-p path))
                            (file-directory-p expanded-path))
                       expanded-path)
                      ((file-directory-p expanded-default)
                       expanded-default)
                      (t
                       (error "Both path and default are invalid")))))
    (condition-case err
        (progn
          (unless (file-directory-p final-path)
            (make-directory final-path t))
          (file-name-as-directory final-path))
      (error
       (message "Directory error: %s" (error-message-string err))
       (file-name-as-directory expanded-default)))))

(let ((local-org-dir "~/Documents/Notes/ObsidianDefaultVault/emacs-org/org-notes")
      (local-org-roam-dir "~/Documents/Notes/ObsidianDefaultVault/emacs-org/org-roam-notes"))

  ;; 动态设置 org-directory
  (setq org-directory
        (my/ensure-directory
         (getenv "ORG_DIR") ; 环境变量名称
         local-org-dir)) ; 默认路径（兼容多设备）

  ;; 动态设置 org-roam-directory（与 org-directory 关联）
  (setq org-roam-directory
        (my/ensure-directory
         (getenv "ORG_ROAM_DIR") ; 环境变量名称
         local-org-roam-dir))
  )


;; (make-directory "~/org/org-notes" t)
;; (setq org-directory (file-truename "~/org/org-notes"))
;;
;; (make-directory "~/org/org-roam-notes" t)
;; (setq org-roam-directory (file-truename "~/org/org-roam-notes"))


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
