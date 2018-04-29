# emacs-maxibuffer (maxibuffer.el)

## Description

maxibuffer provides a way to request user input in a temporary buffer,
similar to the temporary buffers used by org-capture, org-src-edit, and magit
commit buffers.  Sometimes you want to ask the user for plenty of input, and
let them write it in a real buffer with whichever modes they prefer, and get
the results back asynchronously.  That's what maxibuffer is for.

A maxibuffer can be spawned empty, or pre-filled with some text.

Depending on how `maxibuffer-open` is called, when a maxibuffer is
saved-and-closed (with `C-c C-c` by default) the contents of the buffer are
either inserted at the point where the cursor was when the maxibuffer was
spawned, or passed to a provided callback function.

A maxibuffer can be killed without saving with `C-c C-k` by default.

Key bindings can be changed or extended by customizing `maxibuffer-mode-map`.

Examples:

  `(maxibuffer-open)` -- Opens an empty maxibuffer.  When the buffer is
     saved, the contents of the buffer are inserted at the point where the
     cursor was when the maxibuffer was opened.

  `(maxibuffer-open "His name is Robert Paulson." 'cb-fn)` -- Opens a
     maxibuffer pre-populated with a string.  When it is saved, the `cb-fn`
     function is called with the entire contents of the maxibuffer.

As a text, you can execute this line then type `C-c C-c` in the spawned
window.  You should see this message, with any modifications you made,
printed in the echo area.

(maxibuffer-open "This is a test" 'message)

## Screenshots

### Insert into buffer:

<center><img src="https://github.com/mrmekon/emacs-maxibuffer/blob/master/screenshots/maxibuffer1.gif?raw=true" width="600"></center>

### Send to function:

<center><img src="https://github.com/mrmekon/emacs-maxibuffer/blob/master/screenshots/maxibuffer2.gif?raw=true" width="600"></center>

## Installation


1. Clone repo in your `~/.emacs.d/` folder:
```
$ cd ~/.emacs.d/ && git clone https://github.com/mrmekon/emacs-maxibuffer.git
```
2. Add it to your `~/.emacs` config:
```
(add-to-list 'load-path "~/.emacs.d/emacs-maxibuffer/")
(require 'maxibuffer)
```

## Contributing

Make a pull request, or send an e-mail.

## Author

Trevor Bentley (trevor@trevorbentley.com)

## License

GPLv3
