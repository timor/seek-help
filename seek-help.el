;;; seek-help.el --- Seek Help Instead of This -*- lexical-binding: t -*-

;; Author: timor
;; Maintainer: timor
;; Version: 0.1
;; Package-Requires: ()
;; Homepage: homepage
;; Keywords:


;; This file is not part of GNU Emacs

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; For a full copy of the GNU General Public License
;; see <http://www.gnu.org/licenses/>.


;;; Commentary:

;; Use whatever brace style you prefer.
;;
;; But not this.
;;
;; Don't do this.
;;
;; Seek help instead of this.

;;; Code:

(defvar seek-help--before-string (propertize " " 'display '(space :align-to (- right-margin 8))))
(defvar seek-help--closing-regexp
  (rx bol (* space)
      (group (or ";" (syntax close-parenthesis))
             (* (or (syntax close-parenthesis)
                    ";"
                    whitespace eol))
             eol)))
(defvar seek-help--opening-regexp
  (rx (group (syntax open-parenthesis)
             (one-or-more (or (syntax open-parenthesis)
                              whitespace eol))
             eol)))

(defvar-local seek-help--overlays '())

(defun seek-help--make-overlay (beg end)
  (let ((o (make-overlay beg end nil t)))
   (overlay-put o 'evaporate t)
   (overlay-put o 'before-string seek-help--before-string)
   (push o seek-help--overlays)))

(defun seek-help-delete-overlays(&rest ignore)
  (loop for o in seek-help--overlays do (delete-overlay o)))

(defun seek-help-refresh-overlays(&rest ignore)
  (seek-help-delete-overlays)
  (setq seek-help--overlays '())
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward seek-help--opening-regexp nil t)
      (seek-help--make-overlay (match-beginning 1) (match-end 1)))
    (goto-char (point-min))
    (while (re-search-forward seek-help--closing-regexp nil t)
      (seek-help--make-overlay (match-beginning 1) (match-end 1)))))

(define-minor-mode seek-help-mode
  "Toggle insane Bracing style overlays.
Seek help instead of this."
  :lighter "Seek Help!"
  (if seek-help-mode
      (progn
        (seek-help-refresh-overlays)
        (add-hook 'after-change-functions 'seek-help-refresh-overlays))
    (seek-help-delete-overlays)
    (remove-hook 'after-change-functions 'seek-help-refresh-overlays)))

(provide 'seek-help)

;;; seek-help.el ends here
