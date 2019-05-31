;;; counsel-selected.el --- Ivy/counsel extension for selected.el  -*- lexical-binding: t; -*-
;; Copyright (C) 2019 Takaaki ISHIKAWA
;;
;; Author: Takaaki ISHIKAWA <takaxp at ieee dot org>
;; Keywords: extensions, convenience
;; Version: 0.9.0
;; Maintainer: Takaaki ISHIKAWA <takaxp at ieee dot org>
;; URL: https://github.com/takaxp/counsel-selected
;; Package-Requires: ((emacs "24.4") (ivy "0.11") (selected "1.01"))
;; Twitter: @takaxp

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This package provides an `ivy'/`counsel' extension for displaying candidates of associated command or action regarding `selected.el'.

;;; Code:
(eval-when-compile
  (require 'cl-lib))

(require 'ivy)
(require 'selected)

(defcustom counsel-selected-show-key-binding t
  "If non-nil, hide key binding when showing a command list."
  :type 'boolean
  :group 'counsel)

(defun counsel-selected--get-commands (keymap)
  "Create a list from the specified `KEYMAP'."
  (if (keymapp keymap)
      (cl-loop for i in (cdr keymap)
               when (consp i)
               unless (string= "counsel-selected" (format "%s" (cdr i)))
               collect (concat (format "%s" (cdr i))
                               (when counsel-selected-show-key-binding
                                 (format " (%s)"
                                         (propertize
                                          (let ((key (car i)))
                                            (if (characterp key)
                                                (string key) key))
                                          'face 'counsel-key-binding)))))
    (error "The argument is NOT keymap")))

(defun counsel-selected ()
  "Find a command for `selected'."
  (interactive)
  (if (require 'selected nil t)
      (ivy-read "Selected: "
                (counsel-selected--get-commands selected-keymap)
                :sort t
                :require-match t
                :action (lambda (l)
                          (with-ivy-window
                            (command-execute
                             (intern
                              (replace-regexp-in-string "\\s-(.+)$" "" l))
                             'record)))
                :caller 'counsel-selected)
    (user-error "`selected' is NOT installed")))

(provide 'counsel-selected)

;;; counsel-selected.el ends here
