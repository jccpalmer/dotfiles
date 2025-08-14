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

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/.writing/")

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

;; Citar configuration

(after! citar
  (setq! citar-bibliography  '("~/.writing/references.bib")
         citar-notes-paths   '("~/.writing/reference/notes")
         citar-library-paths '("~/.writing/reference/files"))
)

;; Org-roam UI

(use-package! websocket
  :after org-roam)

(use-package! org-roam-ui
  :after org-roam
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start t))



;; Org-journal settings

(use-package! org-journal
  :ensure t
  :defer t
  :init
  (setq org-journal-prefix-key "C-c j")
  :config
  (setq org-journal-dir "~/.writing/journal/"
        org-journal-date-format "%d %B %Y"
        org-journal-carryover-items "TODO=\"TODO\"|TODO=\"NEXT\""
        org-agenda-files '("~/.writing/agenda")
        org-journal-find-file 'find-file)

  ;;; Ensure agenda directory exists
  (unless (file-exists-p "~/.writing/agenda")
    (make-directory "~/.writing/agenda" t))

  ;;; -----------------------------
  ;;; Function: copy H4 TODOs to agenda
  ;;; -----------------------------

  (defun my/org-journal-copy-todos-to-agenda ()
    "Copy unfinished H4 TODOs from the current journal file to the agenda file, avoiding duplicates.
Only runs if visiting a journal file."
    (interactive)
    (when (and buffer-file-name
               (string-prefix-p (expand-file-name "~/.writing/journal/") buffer-file-name))
      (let ((agenda-file "~/.writing/agenda/tasks.org"))
        ;;; Ensure agenda file exists
        (unless (file-exists-p agenda-file)
          (with-temp-buffer
            (write-file agenda-file)))
        ;;; Parse the current buffer headlines
        (org-element-map (org-element-parse-buffer 'headline) 'headline
          (lambda (hl)
            (let ((level (org-element-property :level hl))
                  (todo (org-element-property :todo-keyword hl))
                  (state (org-element-property :todo-state hl))
                  (title (org-element-property :raw-value hl)))
              ;;; Only H4 TODO/NEXT, not DONE
              (when (and (= level 4)
                         (member todo '("TODO" "NEXT"))
                         (not (string= state "DONE")))
                ;;; Copy the headline and children
                (let ((begin (org-element-property :begin hl))
                      (end (org-element-property :end hl)))
                  (let ((content (buffer-substring-no-properties begin end)))
                    (with-current-buffer (find-file-noselect agenda-file)
                      ;;; Avoid duplicates by checking title
                      (unless (save-excursion
                                (goto-char (point-min))
                                (re-search-forward (concat "^\\*+ " (regexp-quote title) "$") nil t))
                        (goto-char (point-max))
                        (unless (bolp) (insert "\n"))
                        (insert content "\n")
                        ;;; Schedule for tomorrow
                        (org-schedule nil
                                      (format-time-string "%Y-%m-%d"
                                                          (time-add (current-time) (days-to-time 1))))
                        ;;; Add CREATED property if missing
                        (org-entry-put (point) "CREATED"
                                       (or (org-entry-get (point) "CREATED")
                                           (format-time-string "[%Y-%m-%d %a]")))
                        (save-buffer))))))))))))

  ;;; Attach hook safely after function exists
  (add-hook 'after-save-hook #'my/org-journal-copy-todos-to-agenda)

  ;;; Remove scheduled date when marking DONE
  (defun my/org-remove-schedule-if-done ()
    "Remove scheduled date when a task is marked DONE."
    (when (and (org-entry-is-done-p)
               (org-get-scheduled-time (point)))
      (org-schedule nil "")))
  (add-hook 'org-after-todo-state-change-hook #'my/org-remove-schedule-if-done)

  ;;; -----------------------------
  ;;; Journal file header
  ;;; -----------------------------

  (defun org-journal-file-header-func (time)
    "Custom function to create journal header."
    (concat
     (pcase org-journal-file-type
       (`daily "#+TITLE: Daily Journal\n#+STARTUP: showeverything")
       (`weekly "#+TITLE: Weekly Journal\n#+STARTUP: folded")
       (`monthly "#+TITLE: Monthly Journal\n#+STARTUP: folded")
       (`yearly "#+TITLE: Yearly Journal\n#+STARTUP: folded"))))
  (setq org-journal-file-header 'org-journal-file-header-func))

