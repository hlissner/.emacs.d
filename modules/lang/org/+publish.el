;;; lang/org/+publish.el -*- lexical-binding: t; -*-

;; Created by: Matthew Graybosch (public@matthewgraybosch.com)
;; Created on: 26 June 2017
;; Released under the MIT license.

;; The following is a basic org-publish configuration for generating
;; a static HTML5 website and blog with RSS feed from a directory of
;; org-mode files, HTML partials, and static assets.

;; To use this configuration, the user should create a private module
;; under ~/.emacs.d/modules/private/$USERNAME and set the following
;; variables inside an init.el file.

;; (setq user-website "https://www.matthewgraybosch.com")
;; (setq org-publish-source "~/work/website/")
;; (setq org-publish-partials "~/work/website/partials/")
;; (setq org-publish-target "~/public_html/")

;; Code to read HTML partials from external files based on code located at
;; https://github.com/howardabrams/dot-files/blob/master/emacs-blog.org
(defun org-mode-head-partial (options)
  (let ((default-directory "~/work/website/partials"))
    (org-babel-with-temp-filebuffer (expand-file-name "head.html") (buffer-string))))

(defun org-mode-head-extra-partial (options)
  (let ((default-directory "~/work/website/partials"))
    (org-babel-with-temp-filebuffer (expand-file-name "head-extra.html") (buffer-string))))

(defun org-mode-preamble-partial (options)
  (let ((default-directory "~/work/website/partials"))
    (org-babel-with-temp-filebuffer (expand-file-name "preamble.html") (buffer-string))))

(defun org-mode-postamble-partial (options)
  (let ((default-directory "~/work/website/partials"))
    (org-babel-with-temp-filebuffer (expand-file-name "postamble.html") (buffer-string))))

;; We need this hook to make sure the config function below loads on startup.
(add-hook '+org-init-hook #'+org|init-publish t)

;; Now the fun begins...
(defun +org|init-publish ()
  ;; Set this to true if you want incremental exports. Chances are you do.
  (setq org-publish-use-timestamps-flag nil)

  ;; Set default settings outside of publish to reduce redundancy.
  ;; Users can override these on a per-file basis.
  (setq org-export-with-inlinetasks nil
        org-export-with-section-numbers nil
        org-export-with-smart-quotes t
        org-export-with-statistics-cookies nil
        org-export-with-tasks nil)

  ;; HTML settings
  (setq org-html-divs '((preamble "header" "top")
                        (content "main" "content")
                        (postamble "footer" "postamble"))
        org-html-container-element "section"
        org-html-metadata-timestamp-format "%Y-%m-%d"
        org-html-checkbox-type 'html
        org-html-html5-fancy t
        org-html-htmlize-output-type 'css
        org-html-head-include-default-style t
        org-html-head-include-scripts t
        org-html-doctype "html5"
        org-html-home/up-format "%s\n%s\n")

  ;; Project Definition
  (setq org-publish-project-alist
        `(("website"
           :components ("pages" "posts" "assets" "feed"))
          ("pages"
           :base-directory ,org-publish-source
           :base-extension "org"
           :publishing-directory ,org-publish-target
           :publishing-function org-html-publish-to-html
           :section-numbers nil
           :with-toc nil
           :recursive t
           :html-head org-mode-head-partial
           :html-head-extra org-mode-head-extra-partial
           :html-preamble org-mode-preamble-partial
           :html-postamble org-mode-postamble-partial
          ("posts"
           :base-directory ,(concat org-publish-source "posts/")
           :base-extension "org"
           :publishing-directory ,org-publish-target
           :publishing-function org-html-publish-to-html
           :section-numbers nil
           :with-toc t
           :recursive t
           :html-head org-mode-head-partial
           :html-head-extra org-mode-head-extra-partial
           :html-preamble org-mode-preamble-partial
           :html-postamble org-mode-postamble-partial
          ("assets"
           :base-directory ,(concat org-publish-source "assets/")
           :base-extension "txt\\|css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg"
           :publishing-directory ,org-publish-target
           :publishing-function org-publish-attachment
           :recursive t)
          ("feed"
           :base-directory ,(concat org-publish-source "posts/")
           :base-extension "org"
           :exclude ".*"
           :exclude-tags ("noexport" "norss")
           :include ("index.org")
           :html-link-home ,user-website
           :html-link-use-abs-url t
           :publishing-directory ,(concat org-publish-target "/feed/")
           :publishing-function org-rss-publish-to-rss))))))
