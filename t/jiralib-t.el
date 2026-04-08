;;; jiralib-t.el --- ERT tests

;; Copyright (C) 2017 Matthew Carter <m@ahungry.com>
;;
;; Authors:
;; Matthew Carter <m@ahungry.com>
;;
;; Maintainer: Matthew Carter <m@ahungry.com>
;; URL: https://github.com/ahungry/org-jira
;; Version: 2.6.2
;; Keywords: ahungry jira org bug tracker
;; Package-Requires: ((emacs "24.5") (cl-lib "0.5") (request "0.2.0"))

;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see
;; <http://www.gnu.org/licenses/> or write to the Free Software
;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
;; 02110-1301, USA.

;;; Commentary:

;; This tests the extension to org-mode for syncing issues with JIRA
;; issue servers.

;;; News:

;;;; Changes since 0.0.0:
;; - Add some basic tests

;;; Code:

(require 'jiralib)
(require 'org-jira)

(ert-deftest jiralib-format-datetime-test ()
  (should
   (string= "2017-01-01T00:00:00.000+0000"
            (jiralib-format-datetime "2017-01-01 00:00:00"))))

(ert-deftest jiralib-do-jql-search-uses-compatible-search-post-endpoint ()
  (let (captured-api captured-args)
    (cl-letf (((symbol-function 'jiralib--rest-call-it)
               (lambda (api &rest args)
                 (setq captured-api api
                       captured-args args)
                 '((issues . [((key . "CDC-1234"))])))))
      (let ((jiralib-token t)
            (jiralib-issue-regexp ".")
            (jiralib-target-api-version 3))
        (should (equal '(((key . "CDC-1234")))
                       (jiralib-call "getIssuesFromJqlSearch" nil "key = \"CDC-1234\"" 50)))))
    (should (equal "/rest/api/2/search" captured-api))
    (should (equal "POST" (plist-get captured-args :type)))
    (should
     (equal "{\"jql\":\"key = \\\"CDC-1234\\\"\",\"maxResults\":50,\"fields\":[\"*all\"],\"expand\":[\"renderedFields\"]}"
            (plist-get captured-args :data)))))

(ert-deftest org-jira-get-issue-by-id-uses-key-jql-for-issue-keys ()
  (let (captured-jql)
    (cl-letf (((symbol-function 'jiralib-do-jql-search)
               (lambda (jql &optional _limit _callback)
                 (setq captured-jql jql)
                 nil)))
      (org-jira-get-issue-by-id "CDC-1234"))
    (should (equal "key = \"CDC-1234\"" captured-jql))))

(ert-deftest org-jira-get-issue-by-id-uses-id-jql-for-numeric-ids ()
  (let (captured-jql)
    (cl-letf (((symbol-function 'jiralib-do-jql-search)
               (lambda (jql &optional _limit _callback)
                 (setq captured-jql jql)
                 nil)))
      (org-jira-get-issue-by-id 1234))
    (should (equal "id = 1234" captured-jql))))

(provide 'jiralib-t)
;;; jiralib-t.el ends here
