;;; maxibuffer.el --- Request user input with a temporary buffer.
;;
;; Copyright (C) 2018 Trevor Bentley
;;
;; Author: Trevor Bentley <trevor@trevorbentley.com>
;; Created: 29 April 2018
;; Keywords: input
;; Version: 0.1.0
;;
;; This file is not part of GNU Emacs.
;;
;; maxibuffer.el is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; maxibuffer.el is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>
;;
;;
;;; Commentary:
;;
;; maxibuffer provides a way to request user input in a temporary buffer,
;; similar to the temporary buffers used by org-capture, org-src-edit, and magit
;; commit buffers.  Sometimes you want to ask the user for plenty of input, and
;; let them write it in a real buffer with whichever modes they prefer, and get
;; the results back asynchronously.  That's what maxibuffer is for.
;;
;; A maxibuffer can be spawned empty, or pre-filled with some text.
;;
;; Depending on how `maxibuffer-open` is called, when a maxibuffer is
;; saved-and-closed (with `C-c C-c` by default) the contents of the buffer are
;; either inserted at the point where the cursor was when the maxibuffer was
;; spawned, or passed to a provided callback function.
;;
;; A maxibuffer can be killed without saving with `C-c C-k` by default.
;;
;; Key bindings can be changed or extended by customizing `maxibuffer-mode-map`.
;;
;; Examples:
;;
;;   `(maxibuffer-open)` -- Opens an empty maxibuffer.  When the buffer is
;;      saved, the contents of the buffer are inserted at the point where the
;;      cursor was when the maxibuffer was opened.
;;
;;   `(maxibuffer-open "His name is Robert Paulson." 'cb-fn)` -- Opens a
;;      maxibuffer pre-populated with a string.  When it is saved, the `cb-fn`
;;      function is called with the entire contents of the maxibuffer.
;;
;; As a text, you can execute this line then type `C-c C-c` in the spawned
;; window.  You should see this message, with any modifications you made,
;; printed in the echo area.
;;
;; (maxibuffer-open "This is a test" 'message)
;;
;;; Code:

(define-minor-mode maxibuffer-mode
  "Minor mode for text input buffers spawned by maxibuffer.
Provides a keymap with default keys for saving and killing the
maxibuffer.

Add your own keybindings to `maxibuffer-mode-map`"
  nil " maxi")

(defvar maxibuffer-mode-map (make-sparse-keymap))
(define-key maxibuffer-mode-map (kbd "C-c C-c") 'maxibuffer-save-buffer)
(define-key maxibuffer-mode-map (kbd "C-c C-k") 'maxibuffer-kill-buffer)

(defvar maxibuffer-mark-begin nil
  "Saved maxibuffer mark.
Saves a mark at wherever the cursor was when the maxibuffer
was spawned, so cursor position can be restored and text from
maxibuffer can be inserted.")

(defvar maxibuffer-window-config nil
  "Saved maxibuffer window config.
Saves window configuration at the time the maxibuffer was
spawned, so it can be restored when the maxibuffer is closed.")

(defvar maxibuffer-save-callback nil
  "Saved maxibuffer callback function.
Saves callback function that is called with the contents of
the maxibuffer when it is saved and closed.")

(defun maxibuffer-save-buffer ()
  "Save maxibuffer and return contents to caller."
  (interactive)
  (let ((cur-buffer (current-buffer))
        (contents (buffer-substring (point-min) (point-max))))
    (switch-to-buffer-other-frame (marker-buffer maxibuffer-mark-begin))
    (goto-char maxibuffer-mark-begin)
    (if maxibuffer-save-callback
        (funcall maxibuffer-save-callback contents)
      (insert-buffer-substring cur-buffer))
    (kill-buffer cur-buffer)
    (set-window-configuration maxibuffer-window-config)))

(defun maxibuffer-kill-buffer ()
  "Kill maxibuffer and discard its contents."
  (interactive)
  (let ((cur-buffer (current-buffer))
        (contents (buffer-substring (point-min) (point-max))))
    (switch-to-buffer-other-frame (marker-buffer maxibuffer-mark-begin))
    (goto-char maxibuffer-mark-begin)
    (kill-buffer cur-buffer)
    (set-window-configuration maxibuffer-window-config)))

;;;###autoload
(defun maxibuffer-open (&optional text cb)
  "Open a new maxibuffer.
Opens a new maxibuffer buffer in another window, and moves focus
to it.  The user can edit the buffer however is desired, and
eventually save and close it with
`maxibuffer-save-buffer` (default: `\\maxibuffer-mode-map &
\\[maxibuffer-save-buffer]`), which sends the contents of the
buffer back to the caller.

`TEXT` -- Optional initial contents of the maxibuffer.  `CB` --
Optional function to call with contents of maxibuffer when it is
saved."
  (interactive)
  ;; Only open the buffer if it is not already open, or the user confirms that
  ;; it can be destroyed.
  (if (or (not (get-buffer "*Maxibuffer*"))
          (yes-or-no-p "Maxibuffer already open.  Destroy and relaunch it? "))
      (let ((mark (make-marker)))
        ;; Save current cursor position
        (setq mark (move-marker mark (point)))
        (setq maxibuffer-mark-begin mark)
        ;; Save current window layout
        (setq maxibuffer-window-config (current-window-configuration))
        (delete-other-windows)
        ;; Open maxibuffer in another window
        (pop-to-buffer (get-buffer-create "*Maxibuffer*"))
        (erase-buffer)
        (let ((text text)
              (cb cb))
          ;; Add initialization text, if provided
          (if text (insert text))
          ;; Save the callback, if provided
          (if cb (setq maxibuffer-save-callback cb)
            (setq maxibuffer-save-callback nil)))
        ;; Display key shortcuts at top of buffer
        (setq header-line-format
              (substitute-command-keys
               (concat "Save & Exit: \\<maxibuffer-mode-map><\\[maxibuffer-save-buffer]>"
                       " / Abort: <\\[maxibuffer-kill-buffer]>")))
        (maxibuffer-mode))))

(provide 'maxibuffer)

;;; maxibuffer.el ends here
