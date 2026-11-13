;;; org-jira-t.el --- ERT tests

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

(require 'org-jira)

(set-time-zone-rule t)

(ert-deftest org-jira-date-to-org-clock-test ()
  (should
   (string= "2017-01-01 Sun 00:00"
            (org-jira-date-to-org-clock "2017-01-01T00:00:00.000+0000")))
  (should
   (string= "2017-02-05 Sun 00:00"
            (org-jira-date-to-org-clock "2017-02-05T00:00:00.000+0000")))
  )

(ert-deftest org-jira-org-clock-to-date-test ()
  (should
   (string= "2017-01-01T00:00:00.000+0000"
            (org-jira-org-clock-to-date "2017-01-01 Sun 00:00")))
  )

(ert-deftest org-jira-time-stamp-to-org-clock-test ()
  (should
   (string= "2017-01-01 Sun 00:05"
            (org-jira-time-stamp-to-org-clock '(22632 18348))))
  )

(defvar org-jira-worklog-fixture-response
  '((startAt . 0)
    (maxResults . 2)
    (total . 2)
    (worklogs .
              [((self . "https://example.com/rest/api/2/issue/10402/worklog/10101")
                (author
                 (self . "https://example.com/rest/api/2/user?username=admin")
                 (name . "admin")
                 (key . "admin")
                 (accountId . "omitted")
                 (emailAddress . "m@example.com")
                 (avatarUrls
                  (48x48 . "https://avatar-cdn.atlassian.com/12345?s=48&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F12345%3Fd%3Dmm%26s%3D48%26noRedirect%3Dtrue")
                  (24x24 . "https://avatar-cdn.atlassian.com/12345?s=24&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F12345%3Fd%3Dmm%26s%3D24%26noRedirect%3Dtrue")
                  (16x16 . "https://avatar-cdn.atlassian.com/12345?s=16&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F12345%3Fd%3Dmm%26s%3D16%26noRedirect%3Dtrue")
                  (32x32 . "https://avatar-cdn.atlassian.com/12345?s=32&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F12345%3Fd%3Dmm%26s%3D32%26noRedirect%3Dtrue"))
                 (displayName . "Matthew Carter")
                 (active . t)
                 (timeZone . "America/New_York"))
                (updateAuthor
                 (self . "https://example.com/rest/api/2/user?username=admin")
                 (name . "admin")
                 (key . "admin")
                 (accountId . "omitted")
                 (emailAddress . "m@example.com")
                 (avatarUrls
                  (48x48 . "https://avatar-cdn.atlassian.com/12345?s=48&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F12345%3Fd%3Dmm%26s%3D48%26noRedirect%3Dtrue")
                  (24x24 . "https://avatar-cdn.atlassian.com/12345?s=24&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F12345%3Fd%3Dmm%26s%3D24%26noRedirect%3Dtrue")
                  (16x16 . "https://avatar-cdn.atlassian.com/12345?s=16&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F12345%3Fd%3Dmm%26s%3D16%26noRedirect%3Dtrue")
                  (32x32 . "https://avatar-cdn.atlassian.com/12345?s=32&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F12345%3Fd%3Dmm%26s%3D32%26noRedirect%3Dtrue"))
                 (displayName . "Matthew Carter")
                 (active . t)
                 (timeZone . "America/New_York"))
                (comment . "Some comment here")
                (created . "2017-02-27T23:47:04.261+0000")
                (updated . "2017-02-27T23:47:04.261+0000")
                (started . "2017-02-26T00:08:00.000+0000")
                (timeSpent . "1h")
                (timeSpentSeconds . 3600)
                (id . "10101")
                (issueId . "10402"))
               ((self . "https://example.com/rest/api/2/issue/10402/worklog/10200")
                (author
                 (self . "https://example.com/rest/api/2/user?username=admin")
                 (name . "admin")
                 (key . "admin")
                 (accountId . "omitted")
                 (emailAddress . "m@example.com")
                 (avatarUrls
                  (48x48 . "https://avatar-cdn.atlassian.com/12345?s=48&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F12345%3Fd%3Dmm%26s%3D48%26noRedirect%3Dtrue")
                  (24x24 . "https://avatar-cdn.atlassian.com/12345?s=24&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F12345%3Fd%3Dmm%26s%3D24%26noRedirect%3Dtrue")
                  (16x16 . "https://avatar-cdn.atlassian.com/12345?s=16&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F12345%3Fd%3Dmm%26s%3D16%26noRedirect%3Dtrue")
                  (32x32 . "https://avatar-cdn.atlassian.com/12345?s=32&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F12345%3Fd%3Dmm%26s%3D32%26noRedirect%3Dtrue"))
                 (displayName . "Matthew Carter")
                 (active . t)
                 (timeZone . "America/New_York"))
                (updateAuthor
                 (self . "https://example.com/rest/api/2/user?username=admin")
                 (name . "admin")
                 (key . "admin")
                 (accountId . "omitted")
                 (emailAddress . "m@example.com")
                 (avatarUrls
                  (48x48 . "https://avatar-cdn.atlassian.com/12345?s=48&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F12345%3Fd%3Dmm%26s%3D48%26noRedirect%3Dtrue")
                  (24x24 . "https://avatar-cdn.atlassian.com/12345?s=24&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F12345%3Fd%3Dmm%26s%3D24%26noRedirect%3Dtrue")
                  (16x16 . "https://avatar-cdn.atlassian.com/12345?s=16&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F12345%3Fd%3Dmm%26s%3D16%26noRedirect%3Dtrue")
                  (32x32 . "https://avatar-cdn.atlassian.com/12345?s=32&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2F12345%3Fd%3Dmm%26s%3D32%26noRedirect%3Dtrue"))
                 (displayName . "Matthew Carter")
                 (active . t)
                 (timeZone . "America/New_York"))
                (comment . "Add 32 minutes")
                (created . "2017-03-16T23:25:45.396+0000")
                (updated . "2017-03-16T23:25:45.396+0000")
                (started . "2017-03-16T22:25:00.000+0000")
                (timeSpent . "32m")
                (timeSpentSeconds . 1920)
                (id . "10200")
                (issueId . "10402"))]))
  "A sample response, as served from the #'jiralib-get-worklogs call.")

(ert-deftest org-jira-worklogs-to-org-clocks-test ()
  (let ((result (org-jira-worklogs-to-org-clocks
                 (cdr (assoc 'worklogs org-jira-worklog-fixture-response)))))
    (should
     (string= "2017-02-26 Sun 00:08"
              (caar result)))
    (should
     (string= "2017-02-26 Sun 01:08"
              (cadar result)))
    (should
     (string= "2017-03-16 Thu 22:25"
              (caadr result)))
    (should
     (string= "2017-03-16 Thu 22:57"
              (cadadr result)))
    ))

(ert-deftest org-jira-format-clock-test ()
    (should
     (string= "CLOCK: [2017-02-26 Sun 00:08]--[2017-02-26 Sun 01:08]"
              (org-jira-format-clock '("2017-02-26 Sun 00:08" "2017-02-26 Sun 01:08")))))

(ert-deftest org-jira-org-clock-to-jira-worklog-test ()
  (let ((result
         (org-jira-org-clock-to-jira-worklog
          "[2017-04-05 Wed 01:00]--[2017-04-05 Wed 01:46] =>  0:46"
          "  :id: 10101
  Success!
CLOCK:")))
    (should (string= "10101" (cdr (assoc 'worklog-id result))))
    (should (string= "Success!" (cdr (assoc 'comment result))))
    (should (string= "2017-04-05T01:00:00.000+0000" (cdr (assoc 'started result))))
    (should (= 2760.0 (cdr (assoc 'time-spent-seconds result))))
    ))

(ert-deftest org-jira-org-clock-to-jira-worklog-no-id-test ()
  (let ((result
         (org-jira-org-clock-to-jira-worklog
          "[2017-04-05 Wed 01:00]--[2017-04-05 Wed 01:46] =>  0:46"
          "My sweet comment!
CLOCK:")))
    (should (equal nil (cdr (assoc 'worklog-id result))))
    (should (string= "My sweet comment!" (cdr (assoc 'comment result))))
    (should (string= "2017-04-05T01:00:00.000+0000" (cdr (assoc 'started result))))
    (should (= 2760.0 (cdr (assoc 'time-spent-seconds result))))
    ))

(ert-deftest org-jira-sort-org-clocks-test ()
  (let* ((clocks '(("2017-02-26 Sun 00:08" "2017-02-26 Sun 01:08" "Some comment here" "10101")
                     ("2017-03-16 Thu 22:25" "2017-03-16 Thu 22:57" "Add 32 minutes" "10200"))
                   )
         (result (org-jira-sort-org-clocks clocks)))

    (should (string= "2017-03-16 Thu 22:25" (car (car result))))
    ))

;;  This test sort of sucks, as its just confirming we get back some strings.
(ert-deftest org-jira-decode-test ()
  (should (string= "" (org-jira-decode nil)))
  (should (string= "dog" (org-jira-decode "dog"))))

(ert-deftest org-jira-t-get-org-priority-string ()
  (let ((org-jira-priority-to-org-priority-omit-default-priority nil)
        (org-default-priority ?B))
    (should (string= "[#B] " (org-jira-get-org-priority-string ?B)))
    (setq org-jira-priority-to-org-priority-omit-default-priority t)
    (should (string= "" (org-jira-get-org-priority-string ?B)))
    (should (string= "" (org-jira-get-org-priority-string nil)))
    )
  )

(ert-deftest org-jira-t-strip-priority-tags ()
  (should (string= "good and clean" (org-jira-strip-priority-tags "[#C] good and clean")))
  (should (string= "food and clean" (org-jira-strip-priority-tags "  [#C] [#D] food and clean ")))
  )

(defun org-jira-t--issue-data ()
  '((key . "AHU-39")
    (id . "10402")
    (fields . ((assignee . ((displayName . "Unassigned")))
               (components . [])
               (labels . [])
               (created . "2026-06-01")
               (description . "Rendered description")
               (duedate . "")
               (project . ((key . "AHU")))
               (status . ((name . "To Do")))
               (summary . "Rendered story title")
               (issuetype . ((name . "Story")
                             (id . "10001")))
               (updated . "2026-06-01")))))

(ert-deftest org-jira-issue-id-at-point-test ()
  (with-temp-buffer
    (org-mode)
    (insert "See AHU-39 for details")
    (goto-char (point-min))
    (search-forward "HU")
    (should (string= "AHU-39" (org-jira--issue-id-at-point)))))

(ert-deftest org-jira-get-issue-here-renders-level-one-at-point-test ()
  (let ((jiralib-url "https://example.atlassian.net")
        (org-jira-download-comments nil)
        (org-jira-worklog-sync-p nil)
        (org-jira-deadline-duedate-sync-p nil)
        (org-tags-column -80)
        requested-id)
    (with-temp-buffer
      (org-mode)
      (insert "* Existing\n\n* Next\n")
      (goto-char (point-min))
      (search-forward "\n\n")
      (cl-letf (((symbol-function 'jiralib-get-issue)
                 (lambda (id &optional _callback)
                   (setq requested-id id)
                   (org-jira-t--issue-data))))
        (org-jira-get-issue-here "AHU-39"))
      (should (string= "AHU-39" requested-id))
      (should (string-match-p
               (regexp-quote
                "* TODO [[https://example.atlassian.net/browse/AHU-39][Rendered story title]]")
               (buffer-string)))
      (should (string-match-p
               "\\[Rendered story title\\]\\]  +:AHU_39:"
               (buffer-string)))
      (should (string-match-p
               (regexp-quote "** description:\n  Rendered description")
               (buffer-string)))
      (should (string-match-p
               (regexp-quote "* Existing\n\n* TODO")
               (buffer-string)))
      (should-not (string-match-p
                   (regexp-quote "** TODO [[https://example.atlassian.net/browse/AHU-39][Rendered story title]]")
                   (buffer-string))))))

(ert-deftest org-jira-refresh-issue-in-place-test ()
  (let ((jiralib-url "https://example.atlassian.net")
        (jiralib-token t)
        (org-jira-download-comments nil)
        (org-jira-worklog-sync-p nil)
        (org-jira-deadline-duedate-sync-p nil)
        callback)
    (with-temp-buffer
      (org-mode)
      (insert "* Personal\n** TODO Old title\n:PROPERTIES:\n:ID: AHU-39\n:filename: personal\n:MY_NOTE: keep\n:END:\n"
              "*** description:\nOld description\n*** Notes\nKeep these notes\n* Unrelated\nKeep this too\n")
      (goto-char (point-min))
      (search-forward "Old description")
      (cl-letf (((symbol-function 'jiralib-get-issue)
                 (lambda (id &optional cb)
                   (should (equal id "AHU-39"))
                   (setq callback cb)))
                ((symbol-function 'org-jira--get-project-buffer)
                 (lambda (&rest _) (ert-fail "Opened a project buffer"))))
        (org-jira-refresh-issue)
        (goto-char (point-max))
        (progn
          (with-temp-buffer
            (org-mode)
            (insert "* Other buffer\n:PROPERTIES:\n:ID: AHU-39\n:END:\n")
            (let ((before (buffer-string)))
              (funcall callback :data (org-jira-t--issue-data))
              (should (equal before (buffer-string)))))
          (should (= (point) (point-max)))))
      (goto-char (point-min))
      (let ((position (org-find-entry-with-id "AHU-39")))
        (should position)
        (goto-char position)
        (should (= (org-outline-level) 2))
        (should (equal (org-entry-get nil "filename") "personal"))
        (should (equal (org-entry-get nil "MY_NOTE") "keep"))
        (should (string-match-p "Rendered story title" (org-get-heading))))
      (should (string-prefix-p "* Personal\n** TODO" (buffer-string)))
      (should (string-match-p "\\*\\*\\* description:\n  Rendered description" (buffer-string)))
      (should (string-match-p "\\*\\*\\* Notes\nKeep these notes" (buffer-string)))
      (should (string-suffix-p "* Unrelated\nKeep this too\n" (buffer-string)))
      (should (= 1 (length (org-map-entries nil "ID=\"AHU-39\"")))))))

(ert-deftest org-jira-update-issue-refreshes-source-entry-in-place-test ()
  (dolist (level '(1 2 3))
    (let ((jiralib-url "https://example.atlassian.net")
          (jiralib-token t)
          (jiralib-use-restapi t)
          (jiralib-users-cache '(((displayName . "Ada") (name . "ada"))))
          (org-jira-users nil)
          (jiralib-update-issue-fields-exclude-list nil)
          (org-jira-download-comments nil)
          (org-jira-worklog-sync-p nil)
          (org-jira-deadline-duedate-sync-p nil)
          (org-jira-property-overrides nil)
          update-fields update-callback refresh-callback)
      (with-temp-buffer
        (org-mode)
        (dotimes (parent (1- level))
          (insert (make-string (1+ parent) ?*) " Parent\n"))
        (insert (make-string level ?*)
                " TODO [[https://example.atlassian.net/browse/AHU-39][Edited title]]\n"
                ":PROPERTIES:\n:ID: AHU-39\n:filename: personal\n:MY_NOTE: keep\n"
                ":assignee: Unassigned\n:reporter: Unassigned\n:type: Story\n"
                ":type-id: 10001\n:priority: Minor\n:labels:\n:components:\n:END:\n"
                (make-string (1+ level) ?*) " description:\nEdited description\n"
                (make-string (1+ level) ?*) " Notes\nKeep these notes\n"
                "* Unrelated\nKeep this too\n")
        (goto-char (point-min))
        (search-forward "Edited description")
        (cl-letf (((symbol-function 'jiralib-get-components) (lambda (_project) nil))
                  ((symbol-function 'jiralib-get-priorities) (lambda () '(("4" . "Minor"))))
                  ((symbol-function 'jiralib-call)
                   (lambda (method callback &rest args)
                     (should (equal (car args) "AHU-39"))
                     (cond ((equal method "updateIssue")
                            (setq update-fields (cadr args)
                                  update-callback callback))
                           ((equal method "getIssue")
                            (setq refresh-callback callback))
                           (t (ert-fail (format "Unexpected Jira method: %s" method))))))
                  ((symbol-function 'org-jira--get-project-buffer)
                   (lambda (&rest _) (ert-fail "Opened a project buffer"))))
          (let ((org-jira-property-overrides '(("status" . "JIRA_STATUS"))))
            (org-jira-update-issue))
          (should (equal (alist-get 'summary update-fields) "Edited title"))
          (should (equal (org-trim (alist-get 'description update-fields))
                         "Edited description"))
          (should update-callback)
          (goto-char (point-max))
          (with-temp-buffer
            (org-mode)
            (insert "* Other copy\n:PROPERTIES:\n:ID: AHU-39\n:END:\n")
            (let ((before (buffer-string))
                  (position (point)))
              ;; A successful REST update has an empty response body.
              (funcall update-callback :data nil :symbol-status 'success)
              (should refresh-callback)
              (funcall refresh-callback :data (org-jira-t--issue-data))
              (should (equal before (buffer-string)))
              (should (= (point) position))))
          (should (= (point) (point-max))))
        (goto-char (org-find-entry-with-id "AHU-39"))
        (should (= (org-outline-level) level))
        (should (equal (org-get-heading t t t t)
                       "[[https://example.atlassian.net/browse/AHU-39][Rendered story title]]"))
        (should (equal (org-entry-get nil "filename") "personal"))
        (should (equal (org-entry-get nil "MY_NOTE") "keep"))
        (should (equal (org-entry-get nil "JIRA_STATUS") "To Do"))
        (should-not (org-entry-get nil "status"))
        (should (string-match-p "Rendered description" (buffer-string)))
        (should (string-match-p "Keep these notes" (buffer-string)))
        (should (string-suffix-p "* Unrelated\nKeep this too\n" (buffer-string)))
        (should (= 1 (length (org-map-entries nil "ID=\"AHU-39\""))))))))

(ert-deftest org-jira-update-issue-failure-preserves-local-edits-test ()
  (dolist (result '((:error-thrown (error . "Connection failed"))
                    (:symbol-status error)
                    (:status-code 400)))
    (let ((jiralib-token t)
          (jiralib-use-restapi t)
          (jiralib-users-cache '(((displayName . "Ada") (name . "ada"))))
          (org-jira-users nil)
          (org-jira-worklog-sync-p nil)
          (org-jira-deadline-duedate-sync-p nil)
          callback)
      (with-temp-buffer
        (org-mode)
        (insert "* TODO Edited title\n:PROPERTIES:\n:ID: AHU-39\n:filename: personal\n"
                ":assignee: Unassigned\n:reporter: Unassigned\n:type: Story\n"
                ":type-id: 10001\n:priority: Minor\n:labels:\n:components:\n:END:\n"
                "** description:\nEdited description\n")
        (goto-char (point-min))
        (let ((before (buffer-string)))
          (cl-letf (((symbol-function 'jiralib-get-components) (lambda (_project) nil))
                    ((symbol-function 'jiralib-get-priorities) (lambda () '(("4" . "Minor"))))
                    ((symbol-function 'jiralib-call)
                     (lambda (method cb &rest _args)
                       (should (equal method "updateIssue"))
                       (setq callback cb))))
            (org-jira-update-issue)
            (should callback)
            (apply callback
                   :data '((errors (summary . "Invalid")))
                   :response (make-request-response
                              :status-code (or (plist-get result :status-code) 204))
                   result))
          (should (equal before (buffer-string))))))))

(ert-deftest org-jira-update-issue-does-not-reinsert-deleted-entry-test ()
  (dolist (pending '(update refresh))
    (let ((jiralib-url "https://example.atlassian.net")
          (jiralib-token t)
          (jiralib-use-restapi t)
          (jiralib-users-cache '(((displayName . "Ada") (name . "ada"))))
          (jiralib-components-cache '(("AHU")))
          (jiralib-priority-codes-cache '(("4" . "Minor")))
          (org-jira-users nil)
          (org-jira-download-comments nil)
          (org-jira-worklog-sync-p nil)
          (org-jira-deadline-duedate-sync-p nil)
          update-callback refresh-callback)
      (with-temp-buffer
        (org-mode)
        (org-jira--render-issue-here
         (org-jira-sdk-create-issue-from-data (org-jira-t--issue-data)))
        (goto-char (org-find-entry-with-id "AHU-39"))
        (org-entry-put nil "priority" "Minor")
        (org-entry-put nil "reporter" "Unassigned")
        (cl-letf (((symbol-function 'jiralib-call)
                   (lambda (method callback &rest _args)
                     (cond ((equal method "updateIssue") (setq update-callback callback))
                           ((equal method "getIssue") (setq refresh-callback callback))
                           (t (ert-fail (format "Unexpected Jira method: %s" method))))))
                  ((symbol-function 'org-jira--get-project-buffer)
                   (lambda (&rest _) (ert-fail "Opened a project buffer"))))
          (org-jira-update-issue)
          (should update-callback)
          (when (eq pending 'refresh)
            (funcall update-callback :data nil :symbol-status 'success)
            (should refresh-callback))
          (erase-buffer)
          (with-temp-buffer
            (org-mode)
            (insert "* Other copy\n:PROPERTIES:\n:ID: AHU-39\n:END:\n")
            (let ((before (buffer-string)))
              (if (eq pending 'update)
                  (progn
                    (funcall update-callback :data nil :symbol-status 'success)
                    (should-not refresh-callback))
                (funcall refresh-callback :data (org-jira-t--issue-data)))
              (should (equal before (buffer-string)))))
          (should (equal (buffer-string) "")))))))

(ert-deftest org-jira-update-issue-logs-in-before-async-request-test ()
  (let ((jiralib-token nil)
        (jiralib-issue-regexp "ahu-[0-9]+")
        (jiralib-use-restapi t)
        (jiralib-complete-callback nil)
        (jiralib-url "https://example.atlassian.net")
        (jiralib-users-cache '(((displayName . "Ada") (name . "ada"))))
        (jiralib-components-cache '(("AHU")))
        (jiralib-priority-codes-cache '(("4" . "Minor")))
        (org-jira-users nil)
        (org-jira-download-comments nil)
        (org-jira-worklog-sync-p nil)
        (org-jira-deadline-duedate-sync-p nil))
    (with-temp-buffer
      (org-mode)
      (insert "* TODO Edited title\n:PROPERTIES:\n:ID: AHU-39\n:filename: personal\n"
              ":assignee: Unassigned\n:reporter: Unassigned\n:type: Story\n"
              ":type-id: 10001\n:priority: Minor\n:labels:\n:components:\n:END:\n"
              "** description:\nEdited description\n")
      (goto-char (point-min))
      (cl-letf (((symbol-function 'jiralib-login)
                 (lambda () (interactive) (setq jiralib-token '("Authorization" . "test"))))
                ((symbol-function 'request)
                 (lambda (_url &rest settings)
                   (let* ((update-p (equal (plist-get settings :type) "PUT"))
                          (data (unless update-p (org-jira-t--issue-data)))
                          (response (make-request-response
                                     :status-code (if update-p 204 200) :data data)))
                     (when (plist-get settings :complete)
                       (funcall (plist-get settings :complete)
                                :response response :data data :symbol-status 'success))
                     response)))
                ((symbol-function 'org-jira--get-project-buffer)
                 (lambda (&rest _) (ert-fail "Opened a project buffer"))))
        (org-jira-update-issue))
      (goto-char (org-find-entry-with-id "AHU-39"))
      (should (equal (org-get-heading t t t t)
                     "[[https://example.atlassian.net/browse/AHU-39][Rendered story title]]")))))

(ert-deftest org-jira-refresh-description-does-not-duplicate-test ()
  (dolist (heading '("description:" "description: [[https://example.atlassian.net/browse/AHU-39][AHU-39]]"))
    (let ((jiralib-url "https://example.atlassian.net")
          (jiralib-token t)
          (org-jira-download-comments nil)
          (org-jira-worklog-sync-p nil)
          (org-jira-deadline-duedate-sync-p nil))
      (with-temp-buffer
        (org-mode)
        (insert "* Other issue\n:PROPERTIES:\n:ID: AHU-40\n:END:\n** description:\nOther description\n"
                "* TODO Story\n:PROPERTIES:\n:ID: AHU-39\n:filename: personal\n:END:\n** " heading "\nOld description\n"
                "** description:\nDuplicated description\n** Notes\nKeep these notes\n* Next\n")
        (cl-letf (((symbol-function 'jiralib-get-issue)
                   (lambda (_id &optional cb) (funcall cb :data (org-jira-t--issue-data)))))
          (dotimes (_ 3)
            (goto-char (org-find-entry-with-id "AHU-39"))
            (org-jira-refresh-issue)))
        (should (string-match-p "Other description" (buffer-string)))
        (should (string-match-p "Keep these notes" (buffer-string)))
        (should (string-suffix-p "* Next\n" (buffer-string)))
        (goto-char (org-find-entry-with-id "AHU-39"))
        (org-narrow-to-subtree)
        (should (= 1 (length (org-map-entries nil "ITEM={^description:}"))))
        (should-not (string-match-p "Old description" (buffer-string)))
        (should-not (string-match-p "Duplicated description" (buffer-string)))
        (should (= 1 (how-many "Rendered description" (point-min) (point-max))))))))

(ert-deftest org-jira-refresh-comments-use-issue-subtree-test ()
  (let ((jiralib-url "https://example.atlassian.net")
        (jiralib-token t)
        (org-jira-download-comments t)
        (org-jira-worklog-sync-p nil)
        (org-jira-deadline-duedate-sync-p nil))
    (with-temp-buffer
      (org-mode)
      ;; A comment may also have been copied elsewhere in the Org file.
      (insert "* Copied comment\n:PROPERTIES:\n:ID: 20001\n:END:\nKeep the copy\n"
              "* TODO Story\n:PROPERTIES:\n:ID: AHU-39\n:filename: personal\n:END:\n"
              "** description:\nOld description\n** Comment: Ada\n:PROPERTIES:\n:ID: 20001\n:END:\nOld comment\n"
              "** Comment: Ada\n:PROPERTIES:\n:ID: 20001\n:END:\nDuplicated comment\n* Next\n")
      (cl-letf (((symbol-function 'jiralib-get-issue)
                 (lambda (_id &optional cb) (funcall cb :data (org-jira-t--issue-data))))
                ((symbol-function 'jiralib-get-comments)
                 (lambda (_id &optional cb)
                   (with-temp-buffer
                     (funcall cb :data '((comments . [((id . "20001")
                                                       (author . ((displayName . "Ada")))
                                                       (body . "Updated comment")
                                                       (created . "2026-06-02")
                                                       (updated . "2026-06-02"))])))))))
        (dotimes (_ 3)
          (goto-char (org-find-entry-with-id "AHU-39"))
          (org-jira-refresh-issue)))
      (should (string-match-p "Keep the copy" (buffer-string)))
      (should (string-suffix-p "* Next\n" (buffer-string)))
      (goto-char (org-find-entry-with-id "AHU-39"))
      (org-narrow-to-subtree)
      (should (= 1 (length (org-map-entries nil "ID=\"20001\""))))
      (should-not (string-match-p "Old comment" (buffer-string)))
      (should-not (string-match-p "Duplicated comment" (buffer-string)))
      (should (= 1 (how-many "Updated comment" (point-min) (point-max)))))))

(ert-deftest org-jira-refresh-issue-without-filename-test ()
  (let ((jiralib-url "https://example.atlassian.net")
        (jiralib-token t)
        (org-jira-download-comments nil)
        (org-jira-worklog-sync-p nil)
        (org-jira-deadline-duedate-sync-p nil))
    (with-temp-buffer
      (org-mode)
      (insert "* TODO Story\n:PROPERTIES:\n:ID: AHU-39\n:END:\n** description:\nOld\n")
      (goto-char (point-min))
      (search-forward "Old")
      (org-back-to-heading t)
      (org-narrow-to-subtree)
      (cl-letf (((symbol-function 'jiralib-get-issue)
                 (lambda (_id &optional cb) (funcall cb :data (org-jira-t--issue-data)))))
        (org-jira-refresh-issue))
      (should (buffer-narrowed-p))
      (widen)
      (should (string-match-p "Rendered description" (buffer-string))))))

(ert-deftest org-jira-refresh-issue-worklogs-stay-in-source-buffer-test ()
  (let ((jiralib-url "https://example.atlassian.net")
        (jiralib-token t)
        (org-jira-download-comments nil)
        (org-jira-worklog-sync-p t)
        (org-jira-deadline-duedate-sync-p nil)
        callback)
    (with-temp-buffer
      (org-mode)
      (insert "* TODO Story\n:PROPERTIES:\n:ID: AHU-39\n:filename: personal\n:END:\n"
              ":LOGBOOK:\nCLOCK: [2026-06-01 Mon 10:00]--[2026-06-01 Mon 10:30] =>  0:30\n:END:\n"
              "** description:\nOld description\n* Next\n")
      (goto-char (point-min))
      (cl-letf (((symbol-function 'jiralib-get-issue)
                 (lambda (_id &optional cb) (funcall cb :data (org-jira-t--issue-data))))
                ((symbol-function 'jiralib-get-worklogs)
                 (lambda (_id &optional cb) (setq callback cb)))
                ((symbol-function 'org-jira--get-project-file-name)
                 (lambda (&rest _) (ert-fail "Opened a project file"))))
        (org-jira-refresh-issue)
        (with-temp-buffer
          (funcall callback :error-thrown '(error . "HTTP 500") :symbol-status 'error))
        (should (string-match-p "CLOCK:" (buffer-string)))
        (with-temp-buffer
          (funcall callback :data '((worklogs . [])))))
      (should-not (string-match-p "CLOCK:" (buffer-string)))
      (should (string-suffix-p "* Next\n" (buffer-string))))))

(ert-deftest org-jira-refresh-issue-comments-in-place-test ()
  (let ((jiralib-url "https://example.atlassian.net")
        (jiralib-token t)
        (org-jira-download-comments t)
        (org-jira-worklog-sync-p nil)
        (org-jira-deadline-duedate-sync-p nil)
        callback)
    (with-temp-buffer
      (org-mode)
      (insert "* Personal\n** Group\n*** TODO Story\n:PROPERTIES:\n:ID: AHU-39\n:filename: personal\n:END:\n"
              "**** description:\nOld\n* Next\n")
      (goto-char (point-min))
      (search-forward "Old")
      (cl-letf (((symbol-function 'jiralib-get-issue)
                 (lambda (_id &optional cb) (funcall cb :data (org-jira-t--issue-data))))
                ((symbol-function 'jiralib-get-comments)
                 (lambda (_id &optional cb) (setq callback cb)))
                ((symbol-function 'org-jira--get-project-file-name)
                 (lambda (&rest _) (ert-fail "Opened a project file"))))
        (org-jira-refresh-issue)
        (with-temp-buffer
          (funcall callback :data '((comments . [((id . "20001")
                                                 (author . ((displayName . "Ada")))
                                                 (body . "Fetched comment")
                                                 (created . "2026-06-02")
                                                 (updated . "2026-06-02"))]))))
        (goto-char (org-find-entry-with-id "20001"))
        (should (= 4 (org-outline-level)))
        (should (org-up-heading-safe))
        (should (equal (org-entry-get nil "ID") "AHU-39"))
        ;; A late comment response must not recreate a deleted source issue.
        (erase-buffer)
        (insert "* Replacement\n")
        (with-temp-buffer
          (funcall callback :data '((comments . [((id . "20002")
                                                 (author . ((displayName . "Ada")))
                                                 (body . "Late comment")
                                                 (created . "2026-06-02")
                                                 (updated . "2026-06-02"))]))))
        (should (equal (buffer-string) "* Replacement\n"))))))

(ert-deftest org-jira-custom-jql-renders-in-source-buffer-at-top-level-test ()
  (let ((jiralib-url "https://example.atlassian.net")
        (org-jira-deadline-duedate-sync-p nil)
        (org-jira-proj-key-override nil)
        (org-jira-custom-jqls
         '((:jql "first\nquery" :limit 2 :filename "first-results")
           (:jql "second query" :limit 1 :filename "second-results")))
        pending-callback)
    (with-temp-buffer
      (org-mode)
      (insert "* Before\n\n* After\n")
      (goto-char (point-min))
      (search-forward "\n\n")
      (cl-letf (((symbol-function 'jiralib-do-jql-search)
                 (lambda (_jql _limit callback)
                   (setq pending-callback callback)))
                ((symbol-function 'org-jira--get-project-buffer)
                 (lambda (&rest _args) (ert-fail "Opened a project buffer"))))
        (org-jira-get-issues-from-custom-jql)
        ;; A response can arrive after the user moves point or switches buffers.
        (goto-char (point-max))
        (with-temp-buffer
          (funcall pending-callback
                   :data `((issues . ,(vector (org-jira-t--issue-data)
                                             (let ((issue (copy-tree (org-jira-t--issue-data))))
                                               (setcdr (assq 'key issue) "AHU-40")
                                               issue))))))
        (with-temp-buffer
          (funcall pending-callback
                   :data `((issues . ,(vector
                                      (let ((issue (copy-tree (org-jira-t--issue-data))))
                                        (setcdr (assq 'key issue) "AHU-41")
                                        issue)))))))
      (goto-char (point-min))
      (let ((headings (org-map-entries
                       (lambda () (list (org-outline-level)
                                        (org-entry-get nil "ID"))))))
        (should (equal headings '((1 nil) (1 "AHU-39") (2 nil)
                                 (1 "AHU-40") (2 nil)
                                 (1 "AHU-41") (2 nil) (1 nil)))))
      (should (string-prefix-p "* Before\n\n* TODO" (buffer-string)))
      (should (string-suffix-p "* After\n" (buffer-string)))
      (should-not org-jira-proj-key-override))))

(ert-deftest org-jira-custom-jql-requires-org-buffer-test ()
  (with-temp-buffer
    (cl-letf (((symbol-function 'jiralib-do-jql-search)
               (lambda (&rest _args) (ert-fail "Requested issues outside Org"))))
      (should-error (org-jira-get-issues-from-custom-jql) :type 'user-error))))

(ert-deftest org-jira-add-comment-to-get-issue-here-issue-test ()
  (let ((jiralib-url "https://example.atlassian.net")
        (org-jira-working-dir (make-temp-file "org-jira-test" t))
        (org-jira-download-comments nil)
        (org-jira-worklog-sync-p nil)
        (org-jira-deadline-duedate-sync-p nil)
        (org-tags-column -80)
        added-issue-id
        added-comment
        fetched-comments-for)
    (unwind-protect
        (with-temp-buffer
          (org-mode)
          (cl-letf (((symbol-function 'jiralib-get-issue)
                     (lambda (_id &optional _callback)
                       (org-jira-t--issue-data)))
                    ((symbol-function 'read-string)
                     (lambda (prompt &rest _args)
                       (should (string= "Comment (AHU-39): " prompt))
                       "Added from here"))
                    ((symbol-function 'jiralib-add-comment)
                     (lambda (issue-id comment &optional callback)
                       (setq added-issue-id issue-id)
                       (setq added-comment comment)
                       (when callback
                         (with-temp-buffer
                           (funcall callback :data nil)))))
                    ((symbol-function 'jiralib-get-comments)
                     (lambda (issue-id &optional callback)
                       (setq fetched-comments-for issue-id)
                       (when callback
                         (with-temp-buffer
                           (funcall callback
                                    :data
                                    '((comments .
                                                 [((id . "20001")
                                                   (author . ((displayName . "Ada Lovelace")))
                                                   (body . "Added from here")
                                                   (created . "2026-06-02")
                                                   (updated . "2026-06-02"))]))))))))
            (org-jira-get-issue-here "AHU-39")
            (goto-char (point-min))
            (search-forward "Rendered description")
            (call-interactively #'org-jira-add-comment))
          (should (string= "AHU-39" added-issue-id))
          (should (string= "Added from here" added-comment))
          (should (string= "AHU-39" fetched-comments-for))
          (should (string-match-p
                   (regexp-quote "** Comment: Ada Lovelace")
                   (buffer-string)))
          (should (string-match-p
                   (regexp-quote "  Added from here")
                   (buffer-string))))
      (delete-directory org-jira-working-dir t))))

(ert-deftest org-jira-get-issue-val-from-org-finds-ancestor-test ()
  (dolist (level '(1 2 3))
    (with-temp-buffer
      (org-mode)
      (insert (make-string level ?*) " TODO Issue title\n"
              ":PROPERTIES:\n:ID: AHU-39\n:filename: AHU\n:END:\n"
              (make-string (1+ level) ?*) " description:\nDescription body\n"
              (make-string (+ level 2) ?*) " Comment: Ada\n"
              ":PROPERTIES:\n:ID: 20001\n:END:\nComment body\n")
      (goto-char (point-min))
      (search-forward "Issue title")
      (should (string= "AHU-39" (org-jira-get-issue-val-from-org 'id)))
      (search-forward "Description body")
      (should (string= "AHU-39" (org-jira-get-issue-val-from-org 'key)))
      (search-forward "Comment body")
      (org-narrow-to-subtree)
      (let ((original-point (point))
            (original-min (point-min))
            (original-max (point-max)))
        (should (string= "AHU-39" (org-jira-get-issue-val-from-org 'id)))
        (should (string= "AHU" (org-jira-filename)))
        (should (string= "Issue title"
                         (org-jira-get-issue-val-from-org 'summary)))
        (should (= original-point (point)))
        (should (= original-min (point-min)))
        (should (= original-max (point-max)))))))

(ert-deftest org-jira-get-issue-val-from-org-rejects-unrelated-heading-test ()
  (with-temp-buffer
    (org-mode)
    (insert "* AHU-Tickets\n** TODO Issue title\n"
            ":PROPERTIES:\n:ID: AHU-39\n:END:\n"
            "* Notes\nUnrelated text\n")
    (goto-char (point-max))
    (should-error (org-jira-get-issue-val-from-org 'id))))

(ert-deftest org-jira-render-issue-links-key-in-heading-test ()
  (let* ((org-jira-working-dir (make-temp-file "org-jira-test" t))
         (jiralib-url "https://example.atlassian.net")
         (org-jira-download-comments nil)
         (org-jira-worklog-sync-p nil)
         (org-jira-deadline-duedate-sync-p nil)
         (org-tags-column -80)
         (issue (make-instance 'org-jira-sdk-issue
                               :assignee "Unassigned"
                               :components ""
                               :labels ""
                               :feature-link nil
                               :created "2026-06-01"
                               :description "Rendered description"
                               :duedate ""
                               :filename "AHU"
                               :headline "Rendered story title"
                               :id "AHU-39"
                               :issue-id "AHU-39"
                               :issue-id-int "10402"
                               :priority nil
                               :proj-key "AHU"
                               :reporter nil
                               :resolution nil
                               :sprint nil
                               :start-date nil
                               :status "To Do"
                               :story-points nil
                               :summary "Rendered story title"
                               :type "Story"
                               :type-id "10001"
                               :updated "2026-06-01")))
    (unwind-protect
        (progn
          (org-jira--render-issue issue)
          (with-current-buffer (find-buffer-visiting
                                (expand-file-name "AHU.org" org-jira-working-dir))
            (should (string-match-p
                     (regexp-quote
                      "** TODO [[https://example.atlassian.net/browse/AHU-39][Rendered story title]]")
                     (buffer-string)))
            (should (string-match-p
                     "\\[Rendered story title\\]\\]  +:AHU_39:"
                     (buffer-string)))
            (should (string-match-p
                     (regexp-quote "*** description:\n  Rendered description")
                     (buffer-string)))
            (should-not (string-match-p
                         (regexp-quote "description: [[https://example.atlassian.net/browse/AHU-39][AHU-39]]")
                         (buffer-string)))
            (goto-char (point-min))
            (search-forward "Rendered story title")
            (should (string= "Rendered story title"
                             (org-jira-get-issue-val-from-org 'summary)))))
      (when-let ((buffer (find-buffer-visiting
                          (expand-file-name "AHU.org" org-jira-working-dir))))
        (kill-buffer buffer))
      (delete-directory org-jira-working-dir t))))

(ert-deftest org-jira-update-worklogs-from-org-clocks-uses-current-buffer-test ()
  (let ((org-jira-working-dir (make-temp-file "org-jira-test" t))
        (jiralib-url "https://example.atlassian.net")
        (org-jira-verbosity nil)
        added-worklog)
    (unwind-protect
        (with-temp-buffer
          (org-mode)
          (insert "* AHU-Tickets\n"
                  "** TODO [[https://example.atlassian.net/browse/AHU-39][Rendered story title]] :AHU_39:\n"
                  ":PROPERTIES:\n"
                  ":filename: AHU\n"
                  ":ID:       AHU-39\n"
                  ":CUSTOM_ID: AHU-39\n"
                  ":END:\n"
                  ":LOGBOOK:\n"
                  "CLOCK: [2017-04-05 Wed 01:00]--[2017-04-05 Wed 01:46] =>  0:46\n"
                  "  New local worklog\n"
                  ":END:\n")
          (goto-char (point-min))
          (search-forward "Rendered story title")
          (cl-letf (((symbol-function 'jiralib-get-worklogs)
                     (lambda (_issue-id &optional _callback)
                       '((worklogs . []))))
                    ((symbol-function 'jiralib-add-worklog)
                     (lambda (issue-id started time-spent-seconds comment &optional _callback)
                       (setq added-worklog
                             (list issue-id started time-spent-seconds comment))))
                    ((symbol-function 'org-jira-update-worklogs-for-issue)
                     (lambda (&rest _args))))
            (org-jira-update-worklogs-from-org-clocks))
          (should (equal added-worklog
                         '("AHU-39"
                           "2017-04-05T01:00:00.000+0000"
                           2760.0
                           "New local worklog"))))
      (delete-directory org-jira-working-dir t))))

(ert-deftest org-jira-update-worklogs-from-org-clocks-syncs-finished-and-preserves-open-test ()
  (let ((org-jira-working-dir (make-temp-file "org-jira-test" t))
        (jiralib-url "https://example.atlassian.net")
        (org-jira-verbosity nil)
        added-worklogs)
    (unwind-protect
        (with-temp-buffer
          (org-mode)
          (insert "* AHU-Tickets\n"
                  "** TODO [[https://example.atlassian.net/browse/AHU-39][Rendered story title]] :AHU_39:\n"
                  ":PROPERTIES:\n"
                  ":filename: AHU\n"
                  ":ID:       AHU-39\n"
                  ":CUSTOM_ID: AHU-39\n"
                  ":END:\n"
                  ":LOGBOOK:\n"
                  "CLOCK: [2026-06-24 Wed 10:20]\n"
                  "  Open local worklog\n"
                  "CLOCK: [2026-06-23 Tue 14:04]--[2026-06-23 Tue 14:42] =>  0:38\n"
                  "  :id: 1199613\n"
                  ":END:\n")
          (goto-char (point-min))
          (search-forward "Rendered story title")
          (cl-letf (((symbol-function 'jiralib-get-worklogs)
                     (lambda (_issue-id &optional callback)
                       (let ((response
                              '((worklogs .
                                          [((started . "2026-06-23T14:04:00.000+0000")
                                            (timeSpentSeconds . 2280)
                                            (comment . nil)
                                            (id . "1199613"))]))))
                         (if callback
                             (funcall callback :data response)
                           '((worklogs . []))))))
                    ((symbol-function 'jiralib-add-worklog)
                     (lambda (issue-id started time-spent-seconds comment &optional _callback)
                       (push (list issue-id started time-spent-seconds comment)
                             added-worklogs))))
            (org-jira-update-worklogs-from-org-clocks))
          (should (equal added-worklogs nil))
          (should (string-match-p
                   (regexp-quote "  :id: 1199613")
                   (buffer-string)))
          (should (string-match-p
                   (regexp-quote "CLOCK: [2026-06-24 Wed 10:20]
  Open local worklog
CLOCK: [2026-06-23 Tue 14:04]--[2026-06-23 Tue 14:42] =>  0:38
  :id: 1199613")
                   (buffer-string))))
      (delete-directory org-jira-working-dir t))))

(ert-deftest org-jira-update-worklogs-from-org-clocks-uses-issue-in-current-file-test ()
  (let ((org-jira-working-dir (make-temp-file "org-jira-test" t))
        (jiralib-url "https://example.atlassian.net")
        (org-jira-verbosity nil)
        org-file
        buffer
        added-worklog)
    (unwind-protect
        (progn
          (setq org-file (expand-file-name "fixit.org" org-jira-working-dir))
          (with-temp-file org-file
            (insert "* AHU-Tickets\n"
                    "** TODO [[https://example.atlassian.net/browse/AHU-39][Rendered story title]] :AHU_39:\n"
                    ":PROPERTIES:\n"
                    ":filename: AHU\n"
                    ":ID:       AHU-39\n"
                    ":CUSTOM_ID: AHU-39\n"
                    ":END:\n"
                    ":LOGBOOK:\n"
                    "CLOCK: [2017-04-05 Wed 01:00]--[2017-04-05 Wed 01:46] =>  0:46\n"
                    "  New local worklog\n"
                    ":END:\n"))
          (setq buffer (find-file-noselect org-file))
          (with-current-buffer buffer
            (org-mode)
            (goto-char (point-min))
            (cl-letf (((symbol-function 'jiralib-get-worklogs)
                       (lambda (_issue-id &optional _callback)
                         '((worklogs . []))))
                      ((symbol-function 'jiralib-add-worklog)
                       (lambda (issue-id started time-spent-seconds comment &optional _callback)
                         (setq added-worklog
                               (list issue-id started time-spent-seconds comment))))
                      ((symbol-function 'org-jira-update-worklogs-for-issue)
                       (lambda (&rest _args))))
              (org-jira-update-worklogs-from-org-clocks))
            (should (equal added-worklog
                           '("AHU-39"
                             "2017-04-05T01:00:00.000+0000"
                             2760.0
                             "New local worklog")))))
      (when (and buffer (buffer-live-p buffer))
        (kill-buffer buffer))
      (delete-directory org-jira-working-dir t))))


(ert-deftest org-jira-create-issue-assignee-format-test ()
  (dolist (case '((auto ((displayName . "Ranko") (name . "ranko")) "Ranko"
                       ((name . "ranko")))
                  (auto ((displayName . "Ranko") (accountId . "cloud-123")) "Ranko"
                        ((accountId . "cloud-123")))
                  (name ((displayName . "Ranko") (name . "ranko")
                         (accountId . "legacy-id")) "Ranko" ((name . "ranko")))
                  (auto ((displayName . "Ranko") (name . "ranko")) "Unassigned"
                        ((name)))))
    (let ((jiralib-user-identifier-field (nth 0 case))
          (jiralib-users-cache (list (nth 1 case)))
          (org-jira-users nil)
          (jiralib-priority-codes-cache '(("1" . "Major")))
          (jiralib-issue-types-by-project-cache '(("CDC" ("10007" . "Task")))))
      (cl-letf (((symbol-function 'jiralib-get-components) (lambda (_project) nil))
                ((symbol-function 'completing-read)
                 (lambda (prompt &rest _args)
                   (if (equal prompt "Assignee: ") (nth 2 case) "Major")))
                ((symbol-function 'completing-read-multiple)
                 (lambda (&rest _args) '("SOAR")))
                ((symbol-function 'jiralib-get-labels) (lambda () nil)))
        (let* ((issue (org-jira-get-issue-struct "CDC" "Task" "Upgrade" "Details"))
               (fields (alist-get 'fields issue)))
          (should (equal (alist-get 'assignee fields) (nth 3 case)))
          (should (equal (alist-get 'labels fields) '("SOAR"))))))))

(ert-deftest org-jira-assign-issue-user-format-test ()
  (dolist (case '((auto ((displayName . "Ada") (name . "ada")) "Ada" name "ada")
                  (auto ((displayName . "Ada") (name . "ada")) "ada" name "ada")
                  (auto ((displayName . "Ada") (accountId . "cloud-123"))
                        "Ada" accountId "cloud-123")
                  (name ((displayName . "Ada") (name . "ada")
                         (accountId . "legacy")) "Ada" name "ada")))
    (let ((jiralib-user-identifier-field (nth 0 case))
          (jiralib-token t)
          (jiralib-users-cache (list (nth 1 case)))
          (jiralib-use-restapi t)
          (jiralib-update-issue-fields-exclude-list nil)
          (org-jira-users nil)
          (org-jira-worklog-sync-p nil)
          (org-jira-deadline-duedate-sync-p nil)
          (org-jira-update-issue-details-include-reporter t)
          update-fields)
      (with-temp-buffer
        (org-mode)
        (insert "* TODO Story\n:PROPERTIES:\n:ID: AHU-39\n:filename: AHU\n"
                ":assignee: Ada\n:reporter: Ada\n:type: Story\n:type-id: 10001\n"
                ":priority: Minor\n:labels: SOAR\n:components:\n:END:\n"
                "** description:\n  Details\n")
        (goto-char (point-min))
        (cl-letf (((symbol-function 'completing-read)
                   (lambda (&rest _args) (nth 2 case)))
                  ((symbol-function 'jiralib-get-components) (lambda (_project) nil))
                  ((symbol-function 'jiralib-get-priorities) (lambda () '(("4" . "Minor"))))
                  ((symbol-function 'jiralib-call)
                   (lambda (method _callback &rest args)
                     (should (equal method "updateIssue"))
                     (should (equal (car args) "AHU-39"))
                     (setq update-fields (cadr args)))))
          (org-jira-assign-issue)
          (should (equal (alist-get 'assignee update-fields)
                         (list (cons (nth 3 case) (nth 4 case)))))
          (should (equal (alist-get 'reporter update-fields)
                         (list (cons (nth 3 case) (nth 4 case)))))
          (org-jira-set-issue-reporter)
          (should (equal (alist-get 'reporter update-fields)
                         (list (cons (nth 3 case) (nth 4 case)))))
          (org-jira-unassign-issue)
          (should (equal (alist-get 'assignee update-fields)
                         (list (cons (nth 3 case) nil)))))))))

(ert-deftest org-jira-user-reference-rejects-unknown-user-test ()
  (let ((jiralib-users-cache '(((displayName . "Ada") (name . "ada"))))
        (org-jira-users nil))
    (should-error (org-jira--user-reference "AHU" "Unknown user")
                  :type 'user-error)))

(ert-deftest org-jira-org-tables-to-jira-test ()
  (dolist (case
           '(("Before\n\n| Release | Changes |\n|---------+---------|\n| 26.5.3 | Fixes |\n\nAfter\n"
              "Before\n\n||Release||Changes||\n|26.5.3|Fixes|\n\nAfter\n")
             ("| One | Two |\n| Three | Four |\n"
              "|One|Two|\n|Three|Four|\n")
             ("| A | B |\n|---+---|\n| 1 | 2 |"
              "||A||B||\n|1|2|")
             ("  | A | B |\n  |---+---|\n  | 1 | 2 |\n"
              "||A||B||\n|1|2|\n")
             ("| A | B |\n|---+---|\n| 1 | 2 |\n\n| C | D |\n|---+---|\n| 3 | 4 |\n"
              "||A||B||\n|1|2|\n\n||C||D||\n|3|4|\n")
             ("#+begin_src text\n| A | B |\n|---+---|\n#+end_src\n"
              "#+begin_src text\n| A | B |\n|---+---|\n#+end_src\n")
             ("||Release||Changes||\n|26.5.3|Fixes|\n"
              "||Release||Changes||\n|26.5.3|Fixes|\n")
             ("Here’s a release — with no table.\n"
              "Here’s a release — with no table.\n")))
    (should (equal (org-jira--org-tables-to-jira (car case)) (cadr case)))))

(ert-deftest org-jira-todo-to-jira-converts-table-description-test ()
  (let ((jiralib-url "https://example.com")
        (org-jira-deadline-duedate-sync-p nil)
        created)
    (with-temp-buffer
      (org-mode)
      (insert "* TODO Upgrade\n| Release | Changes |\n|---------+---------|\n| 26.5.3 | Fixes |\n")
      (goto-char (point-min))
      (cl-letf (((symbol-function 'org-jira-read-project) (lambda () "CDC"))
                ((symbol-function 'org-jira-read-issue-type) (lambda (&optional _project) "Task"))
                ((symbol-function 'org-jira-get-issue-struct)
                 (lambda (project type summary description &rest _extra)
                   (setq created (list project type summary (org-trim description)))
                   '((fields (summary . "Upgrade")))))
                ((symbol-function 'jiralib-create-issue)
                 (lambda (_issue) (org-jira-t--issue-data))))
        (org-jira-todo-to-jira))
      (should (equal created '("CDC" "Task" "Upgrade"
                               "||Release||Changes||\n|26.5.3|Fixes|"))))))

(ert-deftest org-jira-create-issue-prompts-for-components-test ()
  (let ((jiralib-users-cache '(((displayName . "Ranko") (name . "ranko"))))
        (org-jira-users nil)
        (jiralib-priority-codes-cache '(("1" . "Major")))
        (jiralib-issue-types-by-project-cache '(("CDC" ("10007" . "Story")))))
    (dolist (selection '(("Platform" "Backend" "Done") ("Done")))
      (let ((answers (copy-sequence selection)))
        (cl-letf (((symbol-function 'jiralib-get-components)
                   (lambda (_project) '(("10" . "Platform") ("20" . "Backend"))))
                  ((symbol-function 'completing-read)
                   (lambda (prompt &rest _args)
                     (cond ((equal prompt "Assignee: ") "Unassigned")
                           ((equal prompt "Priority: ") "Major")
                           (t (or (pop answers) (ert-fail "Unexpected extra prompt"))))))
                  ((symbol-function 'org-jira-read-labels) (lambda () '("SOAR"))))
          (let* ((issue (org-jira-get-issue-struct "CDC" "Story" "Upgrade" "Details"))
                 (fields (alist-get 'fields issue)))
            (should (equal (alist-get 'components fields)
                           (if (equal selection '("Done")) []
                             [((id . "10")) ((id . "20"))])))
            (should-not answers)))))))

(ert-deftest org-jira-todo-to-jira-keeps-story-in-place-test ()
  (dolist (level '(1 2 3))
    (let ((jiralib-url "https://example.com")
          (org-jira-deadline-duedate-sync-p nil)
          source-buffer created)
      (with-temp-buffer
        (org-mode)
        (setq source-buffer (current-buffer))
        (insert "* Before\nContext before\n"
                (make-string level ?*) " TODO Upgrade :local:\n"
                ":PROPERTIES:\n:OWNER: Local owner\n:END:\nOriginal description\n"
                (make-string (1+ level) ?*) " Notes\nKeep this child note\n"
                "* After\nContext after\n")
        (goto-char (point-min))
        (search-forward "Original description")
        (cl-letf (((symbol-function 'org-jira-read-project) (lambda () "AHU"))
                  ((symbol-function 'org-jira-read-issue-type)
                   (lambda (&optional project)
                     (should (equal project "AHU"))
                     "Story"))
                  ((symbol-function 'org-jira-get-issue-struct)
                   (lambda (_project _type summary description &rest _extra)
                     (setq created (list summary (org-trim description)))
                     '((fields (summary . "Upgrade")))))
                  ((symbol-function 'jiralib-create-issue)
                   (lambda (_issue) (org-jira-t--issue-data)))
                  ((symbol-function 'org-jira--get-project-buffer)
                   (lambda (&rest _args) (ert-fail "Opened a project buffer"))))
          (org-jira-todo-to-jira))
        (should (equal created '("Upgrade" "Original description")))
        (should (eq (current-buffer) source-buffer))
        (should (string-match-p "\\`\\* Before\nContext before\n" (buffer-string)))
        (should (string-match-p "\\* After\nContext after\n\\'" (buffer-string)))
        (goto-char (point-min))
        (search-forward "Rendered story title")
        (org-back-to-heading)
        (should (= (org-outline-level) level))
        (should (equal (org-entry-get nil "ID") "AHU-39"))
        (should (equal (org-entry-get nil "OWNER") "Local owner"))
        (should (member "local" (org-get-tags nil t)))
        (should (equal (org-jira-get-issue-val-from-org 'description)
                       "Rendered description"))
        (should (string-match-p "Keep this child note" (buffer-string)))
        (should-not (string-match-p "Original description" (buffer-string)))))))

(ert-deftest org-jira-todo-to-jira-failure-preserves-entry-test ()
  (with-temp-buffer
    (org-mode)
    (insert "* TODO Upgrade\nOriginal description\n** Notes\nKeep notes\n")
    (goto-char (point-min))
    (let ((original (buffer-string)))
      (cl-letf (((symbol-function 'org-jira-read-project) (lambda () "AHU"))
                ((symbol-function 'org-jira-read-issue-type) (lambda (&optional _project) "Story"))
                ((symbol-function 'org-jira-get-issue-struct)
                 (lambda (&rest _args) '((fields (summary . "Upgrade")))))
                ((symbol-function 'jiralib-create-issue)
                 (lambda (_issue) (error "Jira rejected creation"))))
        (should-error (org-jira-todo-to-jira)))
      (should (equal (buffer-string) original)))))

(ert-deftest org-jira-todo-to-jira-rendering-failure-restores-entry-test ()
  (with-temp-buffer
    (org-mode)
    (insert "* TODO Upgrade :local:\nOriginal description\n** Notes\nKeep notes\n")
    (goto-char (point-min))
    (let ((original (buffer-string)))
      (cl-letf (((symbol-function 'org-jira-read-project) (lambda () "AHU"))
                ((symbol-function 'org-jira-read-issue-type) (lambda (&optional _project) "Story"))
                ((symbol-function 'org-jira-get-issue-struct)
                 (lambda (&rest _args) '((fields (summary . "Upgrade")))))
                ((symbol-function 'jiralib-create-issue)
                 (lambda (_issue) (org-jira-t--issue-data)))
                ((symbol-function 'org-jira--render-issue-in-current-buffer)
                 (lambda (&rest _args) (error "Rendering failed"))))
        (should-error (org-jira-todo-to-jira)))
      (should (equal (buffer-string) original)))))

(ert-deftest org-jira-todo-to-jira-linked-description-roundtrip-test ()
  (dolist (level '(1 2 3))
    (let ((jiralib-url "https://example.com")
          (org-jira-deadline-duedate-sync-p nil)
          created)
      (with-temp-buffer
        (org-mode)
        (insert (make-string level ?*)
                " TODO [[https://example.com/browse/CDC-9995][Upgrade]] :CDC_9995:local:\n"
                ":PROPERTIES:\n:OWNER: Local owner\n:END:\n"
                (make-string (1+ level) ?*) " Notes\nKeep notes\n"
                (make-string (1+ level) ?*) " description:\n"
                "  Release details\n\n  | Release | Changes |\n  |---+---|\n  | 26.5.3 | Fixes |\n"
                "* After\nKeep sibling\n")
        (goto-char (point-min))
        (cl-letf (((symbol-function 'org-jira-read-project) (lambda () "AHU"))
                  ((symbol-function 'org-jira-read-issue-type)
                   (lambda (&optional _project) "Story"))
                  ((symbol-function 'org-jira-get-issue-struct)
                   (lambda (_project _type summary description &rest _extra)
                     (setq created (list summary (org-trim description)))
                     `((fields (summary . ,summary) (description . ,description)))))
                  ((symbol-function 'jiralib-create-issue)
                   (lambda (ticket)
                     (let ((data (copy-tree (org-jira-t--issue-data))))
                       (setf (alist-get 'summary (alist-get 'fields data))
                             (alist-get 'summary (alist-get 'fields ticket))
                             (alist-get 'description (alist-get 'fields data))
                             (alist-get 'description (alist-get 'fields ticket)))
                       data))))
          (org-jira-todo-to-jira))
        (should (equal created '("Upgrade" "Release details\n\n||Release||Changes||\n|26.5.3|Fixes|")))
        (goto-char (point-min))
        (should (equal (org-get-heading t t)
                       "[[https://example.com/browse/AHU-39][Upgrade]]"))
        (should (equal (org-entry-get nil "OWNER") "Local owner"))
        (should (member "local" (org-get-tags nil t)))
        (should (string-match-p "Keep notes" (buffer-string)))
        (should (string-match-p "Keep sibling" (buffer-string)))
        (should (= 1 (how-many "^[*]+ description:" (point-min) (point-max))))
        (should (= 1 (how-many "Release details" (point-min) (point-max))))))))

(ert-deftest org-jira-todo-to-jira-prompts-for-security-service-and-company-test ()
  (dolist (company-schema '("option" "array" "string"))
    (let ((jiralib-url "https://example.com")
          (org-jira-deadline-duedate-sync-p nil)
          (jiralib-users-cache '(((displayName . "Ranko") (name . "ranko"))))
          (org-jira-users nil)
          (jiralib-priority-codes-cache '(("1" . "Major")))
          (jiralib-issue-types-by-project-cache '(("AHU" ("10001" . "Story")))))
      (with-temp-buffer
        (org-mode)
        (insert "* TODO Upgrade\nDetails\n")
        (goto-char (point-min))
        (cl-letf (((symbol-function 'org-jira-read-project) (lambda () "AHU"))
                  ((symbol-function 'org-jira-read-issue-type)
                   (lambda (&optional _project) "Story"))
                  ((symbol-function 'jiralib-get-components) (lambda (_project) nil))
                  ((symbol-function 'org-jira-read-labels) (lambda () nil))
                  ((symbol-function 'jiralib-call)
                   (lambda (method callback &rest args)
                     (should (equal method "getCreateFields"))
                     (should-not callback)
                     (should (equal args '("AHU" "10001")))
                     `(((fieldId . "customfield_123") (name . "Security Service")
                        (required . t) (schema (type . "option"))
                        (allowedValues . [((id . "10") (value . "SOAR"))]))
                       ((fieldId . "customfield_456") (name . "Company")
                        (required . t) (schema (type . ,company-schema) (items . "option"))
                        ,@(unless (equal company-schema "string")
                            '((allowedValues . [((id . "20") (value . "MGB"))])))))))
                  ((symbol-function 'completing-read)
                   (lambda (prompt collection &rest _args)
                     (cond ((equal prompt "Assignee: ") "Unassigned")
                           ((equal prompt "Priority: ") "Major")
                           ((equal prompt "Security Service: ")
                            (should (assoc "SOAR" collection)) "SOAR")
                           ((equal prompt "Company: ")
                            (should (assoc "MGB" collection)) "MGB")
                           (t (ert-fail (format "Unexpected prompt: %s" prompt))))))
                  ((symbol-function 'completing-read-multiple)
                   (lambda (prompt collection &rest _args)
                     (should (equal prompt "Company: "))
                     (should (assoc "MGB" collection))
                     '("MGB")))
                  ((symbol-function 'read-string)
                   (lambda (prompt &rest _args)
                     (should (equal prompt "Company: ")) "MGB"))
                  ((symbol-function 'jiralib-create-issue)
                   (lambda (ticket)
                     (let ((fields (alist-get 'fields ticket)))
                       (should (equal (alist-get 'customfield_123 fields) '((id . "10"))))
                       (should (equal (alist-get 'customfield_456 fields)
                                      (cond ((equal company-schema "array") [((id . "20"))])
                                            ((equal company-schema "string") "MGB")
                                            (t '((id . "20")))))))
                     (org-jira-t--issue-data))))
          (org-jira-todo-to-jira))
        (should (equal (org-entry-get nil "ID") "AHU-39"))))))

(ert-deftest org-jira-create-field-required-and-optional-test ()
  (dolist (type '("option" "array" "string"))
    (dolist (required '(t :json-false))
      (let ((field `((name . "Company") (required . ,required)
                     (schema (type . ,type))
                     ,@(unless (equal type "string")
                         '((allowedValues . [((id . "20") (value . "MGB"))]))))))
        (cl-letf (((symbol-function 'completing-read) (lambda (&rest _args) ""))
                  ((symbol-function 'completing-read-multiple) (lambda (&rest _args) nil))
                  ((symbol-function 'read-string) (lambda (&rest _args) "  ")))
          (if (eq required t)
              (should-error (org-jira--read-create-field field) :type 'user-error)
            (should-not (org-jira--read-create-field field))))))))

(ert-deftest org-jira-update-labels-from-child-test ()
  (dolist (override '(nil (("labels" . "JIRA_LABELS"))))
    (dolist (selection '(("new" "second") nil))
      (let ((org-jira-property-overrides override)
            (jiralib-token t)
            sent initial callback before)
        (with-temp-buffer
          (org-mode)
          (insert "* TODO Story\n:PROPERTIES:\n:ID: AHU-39\n:filename: AHU\n"
                  ":assignee: Ada\n:type: Story\n:type-id: 10001\n:priority: Minor\n:END:\n"
                  "** description:\nDetails\n")
          (goto-char (point-min))
          (org-jira-entry-put nil "labels" "old")
          (search-forward "Details")
          (setq before (buffer-string))
          (cl-letf (((symbol-function 'org-jira-read-labels)
                     (lambda (&optional current) (setq initial current) selection))
                    ((symbol-function 'jiralib-update-issue)
                     (lambda (id fields &optional cb)
                       (should (equal id "AHU-39"))
                       (setq sent fields callback cb))))
            (org-jira-update-issue-labels))
          (should (equal initial "old"))
          (should (equal sent (list (cons 'labels (or selection [])))))
          (should (equal (org-jira-get-issue-val-from-org 'labels) "old"))
          (with-temp-buffer (funcall callback :data nil))
          (let ((label-line "^:\\(?:labels\\|JIRA_LABELS\\):.*\n"))
            (should (equal (replace-regexp-in-string label-line "" (buffer-string))
                           (replace-regexp-in-string label-line "" before))))
          (should-not (org-entry-get nil (if override "JIRA_LABELS" "labels")))
          (goto-char (point-min))
          (should (equal (org-jira-get-issue-val-from-org 'labels)
                         (if selection "new, second" ""))))))))

(ert-deftest org-jira-update-feature-link-and-sprint-test ()
  (dolist (case '((org-jira-update-issue-feature-link "feature-link" "AHU-10"
                    ((customfield_11296 . "AHU-10")))
                  (org-jira-update-issue-sprint "sprint" "Sprint 7"
                    ((customfield_11294 . 7)))))
    (let ((org-jira-property-overrides '(("feature-link" . "FEATURE") ("sprint" . "ITERATION")))
          (jiralib-token t)
          sent)
      (with-temp-buffer
        (org-mode)
        (insert "* TODO Story\n:PROPERTIES:\n:ID: AHU-39\n:filename: AHU\n:END:\n"
                "** description:\nDetails\n")
        (goto-char (point-max))
        (cl-letf (((symbol-function 'read-string) (lambda (&rest _) "AHU-10"))
                  ((symbol-function 'org-jira-read-board) (lambda () '("Board" . 3)))
                  ((symbol-function 'org-jira-read-sprint)
                   (lambda (board) (should (= board 3)) '("Sprint 7" . 7)))
                  ((symbol-function 'jiralib-update-issue)
                   (lambda (id fields &optional callback)
                     (setq sent (list id fields))
                     (funcall callback :data nil))))
          (funcall (car case)))
        (should (equal sent (list "AHU-39" (nth 3 case))))
        (should (equal (org-jira-get-issue-val-from-org (nth 1 case)) (nth 2 case))))
      ;; A rejected update must leave the local properties intact.
      (with-temp-buffer
        (org-mode)
        (insert "* Story\n:PROPERTIES:\n:ID: AHU-39\n:END:\n")
        (goto-char (point-min))
        (org-jira-entry-put nil (nth 1 case) "original")
        (cl-letf (((symbol-function 'read-string) (lambda (&rest _) "AHU-10"))
                  ((symbol-function 'org-jira-read-board) (lambda () '("Board" . 3)))
                  ((symbol-function 'org-jira-read-sprint) (lambda (_) '("Sprint 7" . 7)))
                  ((symbol-function 'jiralib-update-issue) (lambda (&rest _) (error "Rejected"))))
          (should-error (funcall (car case))))
        (should (equal (org-jira-get-issue-val-from-org (nth 1 case)) "original"))))))

(ert-deftest org-jira-feature-link-delayed-callback-test ()
  (let ((org-jira-feature-link-field 'customfield_42)
        (jiralib-token t)
        (org-jira-property-overrides '(("feature-link" . "FEATURE")))
        callback)
    (with-temp-buffer
      (org-mode)
      (insert "* Story\n:PROPERTIES:\n:ID: AHU-39\n:FEATURE: AHU-1\n:END:\n")
      (goto-char (point-min))
      (cl-letf (((symbol-function 'read-string) (lambda (&rest _) ""))
                ((symbol-function 'jiralib-update-issue)
                 (lambda (id fields &optional cb)
                   (should (equal id "AHU-39"))
                   (should (equal (json-encode fields) "{\"customfield_42\":null}"))
                   (setq callback cb))))
        (org-jira-update-issue-feature-link))
      (should (equal (org-entry-get nil "FEATURE") "AHU-1"))
      (let ((org-jira-property-overrides nil))
        (with-temp-buffer (funcall callback :data nil)))
      (should (equal (org-entry-get nil "FEATURE") ""))
      (should-not (org-entry-get nil "feature-link")))))

(ert-deftest org-jira-configured-fields-import-test ()
  (let* ((org-jira-feature-link-field 'customfield_42)
         (org-jira-sprint-field 'customfield_43)
         (data (copy-tree (org-jira-t--issue-data))))
    (setf (alist-get 'customfield_42 (alist-get 'fields data)) "AHU-10"
          (alist-get 'customfield_43 (alist-get 'fields data))
          ["Sprint[id=7,name=Sprint 7,state=ACTIVE]"])
    (let ((issue (org-jira-sdk-create-issue-from-data data)))
      (should (equal (oref issue feature-link) "AHU-10"))
      (should (equal (oref issue sprint) "Sprint 7")))))

(ert-deftest org-jira-field-update-http-failure-preserves-property-test ()
  (let ((jiralib-token t))
    (with-temp-buffer
      (org-mode)
      (insert "* Story\n:PROPERTIES:\n:ID: AHU-39\n:feature-link: AHU-1\n:END:\n")
      (goto-char (point-min))
      (cl-letf (((symbol-function 'read-string) (lambda (&rest _) "AHU-10"))
                ((symbol-function 'jiralib-update-issue)
                 (lambda (_id _fields &optional callback)
                   (funcall callback :data '((errors (customfield_11296 . "Invalid")))
                            :error-thrown '(error . "HTTP 400")
                            :symbol-status 'error
                            :response (make-request-response :status-code 400)))))
        (org-jira-update-issue-feature-link))
      (should (equal (org-entry-get nil "feature-link") "AHU-1")))))

(ert-deftest org-jira-field-update-logs-in-before-async-request-test ()
  (let ((jiralib-token nil)
        (jiralib-issue-regexp "ahu-[0-9]+")
        (jiralib-use-restapi t)
        (jiralib-complete-callback nil)
        (jiralib-url "https://example.com"))
    (with-temp-buffer
      (org-mode)
      (insert "* Story\n:PROPERTIES:\n:ID: AHU-39\n:END:\n")
      (goto-char (point-min))
      (cl-letf (((symbol-function 'read-string) (lambda (&rest _) "AHU-10"))
                ((symbol-function 'jiralib-login)
                 (lambda () (interactive) (setq jiralib-token '("Authorization" . "test"))))
                ((symbol-function 'request)
                 (lambda (_url &rest settings)
                   (let ((response (make-request-response :status-code 204 :data nil)))
                     (when (plist-get settings :complete)
                       (funcall (plist-get settings :complete)
                                :response response :data nil :symbol-status 'success))
                     response))))
        (org-jira-update-issue-feature-link))
      (should (equal (org-entry-get nil "feature-link") "AHU-10")))))

(provide 'org-jira-t)
;;; org-jira-t.el ends here
