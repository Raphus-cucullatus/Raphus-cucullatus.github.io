(setq org-html-validation-link nil
      org-export-with-author nil
      org-export-time-stamp-file nil)

;; htmlize
(add-to-list 'load-path "./config/emacs-htmlize/")
(require 'htmlize)
