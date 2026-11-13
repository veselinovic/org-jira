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

(ert-deftest jiralib-labels-unavailable-allows-manual-entry-test ()
  (let ((jiralib-url "https://example.com")
        (jiralib-token '("Authorization" . "test"))
        (jiralib-issue-regexp "test-[0-9]+")
        (jiralib-use-restapi t)
        (jiralib-labels-cache nil)
        (requests 0))
    (cl-letf (((symbol-function 'request)
               (lambda (url &rest settings)
                 (should (equal url "https://example.com/rest/api/2/label?startAt=0"))
                 (cl-incf requests)
                 (let ((response (make-request-response
                                  :status-code 404
                                  :data '((errorMessages . ["Not found"])))))
                   (funcall (plist-get settings :error)
                            :data nil :response response)
                   response)))
              ((symbol-function 'completing-read-multiple)
               (lambda (_prompt collection _predicate require-match &rest _args)
                 (should-not collection)
                 (should-not require-match)
                 '("new-label"))))
      (should (equal (org-jira-read-labels) '("new-label")))
      (should (= requests 1)))))

(ert-deftest jiralib-labels-pagination-and-cache-test ()
  (let ((jiralib-labels-cache nil)
        (pages '(((startAt . 0) (maxResults . 2) (isLast . :json-false)
                  (values . ["alpha" "beta"]))
                 ((startAt . 2) (maxResults . 2) (isLast . t)
                  (values . ["gamma"]))))
        (offsets nil))
    (cl-letf (((symbol-function 'jiralib-call)
               (lambda (method callback offset)
                 (should (equal method "getLabels"))
                 (should-not callback)
                 (push offset offsets)
                 (pop pages))))
      (should (equal (sort (copy-sequence (jiralib-get-labels)) #'string<)
                     '("alpha" "beta" "gamma")))
      (should (equal (jiralib-get-labels) jiralib-labels-cache))
      (should (equal (nreverse offsets) '(0 2))))))

(ert-deftest jiralib-labels-empty-response-does-not-crash-test ()
  (let ((jiralib-labels-cache nil))
    (cl-letf (((symbol-function 'jiralib-call) (lambda (&rest _args) nil)))
      (should-not (jiralib-get-labels)))))

(ert-deftest jiralib-rest-errors-remain-errors-test ()
  (let ((jiralib-url "https://example.com")
        (jiralib-complete-callback nil)
        (standard-output (get-buffer-create " *jiralib-test-errors*")))
    (dolist (case '(("/rest/api/2/label?startAt=0" 403 (404))
                    ("/rest/api/2/issue" 404 nil)))
      (cl-letf (((symbol-function 'request)
                 (lambda (_url &rest settings)
                   (let ((response (make-request-response :status-code (nth 1 case))))
                     (funcall (plist-get settings :error)
                              :data nil :response response)
                     response))))
        (should-error (jiralib--rest-call-it (car case)
                                           :allowed-status-codes (nth 2 case)))))))

(ert-deftest jiralib-rejected-creation-does-not-fetch-issue-test ()
  (let ((jiralib-token '("Authorization" . "test"))
        (jiralib-issue-regexp "test-[0-9]+")
        (jiralib-use-restapi t)
        (requests nil))
    (cl-letf (((symbol-function 'jiralib--rest-call-it)
               (lambda (api &rest _args)
                 (push api requests)
                 '((errorMessages . [])
                   (errors (assignee . "expected Object containing a name property"))))))
      (dolist (method '("createIssue" "createIssueWithParent"))
        (setq requests nil)
        (should-error (jiralib-call method nil '((fields (summary . "Upgrade")))))
        (should (equal requests '("/rest/api/2/issue")))))))

(provide 'jiralib-t)
;;; jiralib-t.el ends here
