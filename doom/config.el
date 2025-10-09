
;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; -----------------------------
;; Basic Doom settings
;; -----------------------------

(setq doom-theme 'doom-one
      display-line-numbers-type t
      org-directory "~/.writing/"
	org-default-notes-file (concat org-directory "notes/inbox.org"))

(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; -----------------------------
;; YASnippet settings
;; -----------------------------

(after! yasnippet
  (add-to-list 'yas-snippet-dirs "~/.config/doom/snippets")
  (yas-reload-all))

;; -----------------------------
;; Org-mode settings
;; -----------------------------

;;; Templates

;;;; Blockquote with author attribution
(after! org
  (add-to-list 'org-structure-template-alist
               '("bq" . (lambda ()
                          (interactive)
                          (yas-expand-snippet
                           (with-temp-buffer
                             (insert-file-contents "~/.config/doom/snippets/org-mode/writing/bq")
                             (buffer-string)))))))

;; -----------------------------
;; Citar configuration
;; -----------------------------

(after! citar
  (setq! citar-bibliography  '("~/.writing/references.bib")
         citar-notes-paths   '("~/.writing/reference/notes")
         citar-library-paths '("~/.writing/reference/files")))

(use-package citar-org-roam
  :after org-roam
  :config
  (citar-org-roam-mode)
  (setq citar-org-roam-note-title-template "${author} - ${title}"))

;; -----------------------------
;; Org-roam
;; -----------------------------

(use-package! org-roam
  :ensure t
  :after org
  :init
  (setq org-roam-v2-ack t)
  :custom
  (org-roam-directory "~/.writing/roam")
  :bind (("C-c n f" . org-roam-node-find)
         ("C-c n r" . org-roam-node-random)
         (:map org-mode-map
               (("C-c n i" . org-roam-node-insert)
                ("C-c n o" . org-id-get-create)
                ("C-c n t" . org-roam-tag-add)
                ("C-c n a" . org-roam-alias-add)
                ("C-c n l" . org-roam-buffer-toggle))))
  :config
  (org-roam-setup))

;;; Templates

(setq org-roam-capture-templates
      '(("d" "default" plain "%?"
         :if-new
         (file+head "${slug}.org"
                    "#+title: ${title}\n#+date: %u\n#+lastmod: \n\n")
         :immediate-finish t))
      time-stamp-start "#\\+lastmod: [\t]*")

;; -----------------------------
;; Org-journal
;; -----------------------------

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

  ;; Ensure agenda directory exists
  (unless (file-exists-p "~/.writing/agenda")
    (make-directory "~/.writing/agenda" t))

  ;; -----------------------------
  ;; Copy H4 TODOs to agenda
  ;; -----------------------------

  (defun my/org-journal-copy-todos-to-agenda ()
    "Copy unfinished H4 TODOs from journal to agenda, avoiding duplicates."
    (interactive)
    (when (and buffer-file-name
               (string-prefix-p (expand-file-name "~/.writing/journal/") buffer-file-name))
      (let ((agenda-file "~/.writing/agenda/tasks.org"))
        (unless (file-exists-p agenda-file)
          (with-temp-buffer (write-file agenda-file)))
        (org-element-map (org-element-parse-buffer 'headline) 'headline
          (lambda (hl)
            (let ((level (org-element-property :level hl))
                  (todo (org-element-property :todo-keyword hl))
                  (state (org-element-property :todo-state hl))
                  (title (org-element-property :raw-value hl)))
              (when (and (= level 4)
                         (member todo '("TODO" "NEXT"))
                         (not (string= state "DONE")))
                (let ((begin (org-element-property :begin hl))
                      (end (org-element-property :end hl)))
                  (let ((content (buffer-substring-no-properties begin end)))
                    (with-current-buffer (find-file-noselect agenda-file)
                      (unless (save-excursion
                                (goto-char (point-min))
                                (re-search-forward (concat "^\\*+ " (regexp-quote title) "$") nil t))
                        (goto-char (point-max))
                        (unless (bolp) (insert "\n"))
                        (insert content "\n")
                        (org-schedule nil
                                      (format-time-string "%Y-%m-%d"
                                                          (time-add (current-time) (days-to-time 1))))
                        (org-entry-put (point) "CREATED"
                                       (or (org-entry-get (point) "CREATED")
                                           (format-time-string "[%Y-%m-%d %a]")))
                        (save-buffer))))))))))))

  (add-hook 'after-save-hook #'my/org-journal-copy-todos-to-agenda)

  ;; Remove scheduled date when DONE
  (defun my/org-remove-schedule-if-done ()
    (when (and (org-entry-is-done-p)
               (org-get-scheduled-time (point)))
      (org-schedule nil "")))
  (add-hook 'org-after-todo-state-change-hook #'my/org-remove-schedule-if-done)

  ;; Journal file header
  (defun org-journal-file-header-func (time)
    (concat
     (pcase org-journal-file-type
       (`daily "#+TITLE: Daily Journal\n#+STARTUP: showeverything")
       (`weekly "#+TITLE: Weekly Journal\n#+STARTUP: folded")
       (`monthly "#+TITLE: Monthly Journal\n#+STARTUP: folded")
       (`yearly "#+TITLE: Yearly Journal\n#+STARTUP: folded"))))
  (setq org-journal-file-header 'org-journal-file-header-func))

;; -----------------------------
;; YASnippet in Org-journal
;; -----------------------------

(after! org-journal
        (add-hook 'org-journal-mode-hook #'yas-minor-mode-on)

        (with-eval-after-load 'yasnippet
          (add-to-list 'yas-snippet-dirs "~/.config/doom/snippets/")
          (yas-reload-all)
          (add-hook 'org-journal-mode-hook
                    (lambda ()
                      (yas-activate-extra-mode 'org-mode)))))

;; -----------------------------
;; Org-super-agenda
;; -----------------------------

;; Scheduled tomorrow function
(defun my/org-scheduled-for-tomorrow-p ()
  (let* ((sched (org-get-scheduled-time (point)))
         (tomorrow (time-add (current-time) (days-to-time 1))))
    (and sched (= (time-to-days sched) (time-to-days tomorrow)))))

;; Unfinished checkboxes function
(defun my/org-has-unfinished-checkboxes-p ()
  (org-element-map (org-element-at-point) 'item
    (lambda (item)
      (not (member "done" (org-element-property :tags item))))
    nil t))

;; Indented subtasks function
(defun my/org-get-indented-subtasks ()
  (let ((parent-level (org-element-property :level (org-element-at-point)))
        (subtasks ""))
    (org-element-map (org-element-contents (org-element-at-point)) 'headline
      (lambda (hl)
        (let ((level (org-element-property :level hl))
              (todo (org-element-property :todo-keyword hl))
              (state (org-element-property :todo-state hl))
              (title (org-element-property :raw-value hl)))
          (when (and (member todo '("TODO" "NEXT"))
                     (not (string= state "DONE")))
            (let ((indent (make-string (* 2 (- level parent-level)) ?\s)))
              (setq subtasks (concat subtasks indent "- [ ] " title "\n")))))))
    subtasks))

(use-package! org-super-agenda
  :after org-agenda
  :init
  (setq org-agenda-skip-scheduled-if-done t
        org-agenda-skip-deadline-if-done t
        org-agenda-include-deadlines t
        org-agenda-block-separator nil
        org-agenda-compact-blocks t
        org-agenda-start-day nil
        org-agenda-span 1
        org-agenda-start-on-weekday nil
        org-agenda-show-inherited-todo t
        org-agenda-entry-types '(:headline :todo :checkbox))

  (setq org-agenda-custom-commands
        '(("c" "Super view"
           ((agenda ""
                    ((org-agenda-overriding-header "")
                     (org-super-agenda-groups
                      '((:name "Today"
                               :time-grid t
                               :date today
                               :order 1)))))
            (alltodo ""
                     ((org-agenda-overriding-header "")
                      (org-super-agenda-groups
                       `((:name "Next Day Planning"
                                :file-path "agenda/tasks\\.org"
                                :scheduled my/org-scheduled-for-tomorrow-p
                                :order 0)
                         (:name "Today's tasks"
                                :todo "TODO"
                                :order 1)
                         (:name "To refile"
                                :file-path "refile\\.org")
                         (:name "Next to do"
                                :todo "NEXT"
                                :order 2)
                         (:name "Important"
                                :priority "A"
                                :order 3)
                         (:name "Due Today"
                                :deadline today
                                :order 4)
                         (:name "Scheduled Soon"
                                :scheduled future
                                :order 5)
                         (:name "Overdue"
                                :deadline past
                                :order 6)
                         (:name "Meetings"
                                :and (:todo "MEET" :scheduled future)
                                :order 7)
                         (:discard (:not (:todo "TODO" :or (:checkbox my/org-has-unfinished-checkboxes-p)))))
                       :children t
                       :display-function
                       (lambda (entry)
                         (let ((subtasks (my/org-get-indented-subtasks)))
                           (if (> (length subtasks) 0)
                               (concat entry "\n" subtasks)
                             entry))))))))))
  :config
  (org-super-agenda-mode))

;; -----------------------------
;; Vterm settings
;; -----------------------------

(add-to-list 'display-buffer-alist
             '("\\*vterm.*\\*"
               (display-buffer-reuse-window display-buffer-in-side-window)
               (side . right)
               (slot . 0)
               (window-width . 0.5)
               (window-parameters . ((no-other-window . t)
                                     (no-delete-other-windows . t)))))

(defun my/vterm-right-single ()
  "Open or reuse a vterm buffer in a right-side vertical split, preventing bottom split."
  (interactive)
  (let ((right-win (or (window-in-direction 'right)
                       (split-window-right))))
    (select-window right-win)
    (let ((buf (or (get-buffer "*vterm*")
                   (generate-new-buffer "*vterm*"))))
      (set-window-buffer right-win buf)
      ;; Enable vterm-mode if not already active
      (unless (derived-mode-p 'vterm-mode)
        (with-current-buffer buf
          (vterm-mode)))
      (select-window right-win))))

(defun my/vterm-right-new ()
  "Create a new vterm buffer in a right-side vertical split, preventing bottom split."
  (interactive)
  (let ((right-win (or (window-in-direction 'right)
                       (split-window-right))))
    (select-window right-win)
    (let ((buf (generate-new-buffer "vterm")))
      (set-window-buffer right-win buf)
      (with-current-buffer buf
        (vterm-mode))
      (select-window right-win))))

(after! evil
  (map! :leader
        :n
        :desc "Vterm right single (reuse)"
        "t '" #'my/vterm-right-single
        :desc "Vterm right new (always new)"
        "t V" #'my/vterm-right-new))

(defun my/vterm-cleanup-on-kill ()
  "Kill the underlying vterm process only if Emacs is not quitting."
  (unless (bound-and-true-p noninteractive)
    (when (derived-mode-p 'vterm-mode)
      (let ((proc (get-buffer-process (current-buffer))))
        (when (and proc (process-live-p proc))
          (kill-process proc))))))

(add-hook 'kill-buffer-hook #'my/vterm-cleanup-on-kill)

;; Enable debug for errors
(setq debug-on-error t)

