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

(ert-deftest jiralib-format-datetime-test ()
  (should
   (string= "2017-01-01T00:00:00.000+0000"
            (jiralib-format-datetime "2017-01-01 00:00:00"))))

(ert-deftest jiralib-worklog-import-filter-apply-uses-enabled-custom-filters-test ()
  (let* ((ranko-worklog '((id . "mine")
                          (author
                           (emailAddress . "foo@bar.com"))))
         (other-worklog '((id . "other")
                          (author
                           (emailAddress . "someone.else@mgb.ch"))))
         (jiralib-worklog-import--filters-alist
          (list
           (list t "Ranko worklogs only"
                 (lambda (worklog)
                   (when (string= "foo@bar.com"
                                  (cdr (assoc 'emailAddress
                                              (cdr (assoc 'author worklog)))))
                     worklog)))))
         (result (jiralib-worklog-import--filter-apply
                  (vector ranko-worklog other-worklog))))
    (should (equal (append result nil) (list ranko-worklog)))))

(ert-deftest jiralib-worklog-import-filter-apply-honors-explicit-predicates-test ()
  (let* ((ranko-worklog '((id . "mine")
                          (author
                           (emailAddress . "foo@bar.com"))))
         (other-worklog '((id . "other")
                          (author
                           (emailAddress . "someone.else@mgb.ch"))))
         (result
          (jiralib-worklog-import--filter-apply
           (vector ranko-worklog other-worklog)
           (list
            (lambda (worklog)
              (when (string= "foo@bar.com"
                             (cdr (assoc 'emailAddress
                                         (cdr (assoc 'author worklog)))))
                worklog))))))
    (should (equal (append result nil) (list ranko-worklog)))))

(provide 'jiralib-t)
;;; jiralib-t.el ends here
