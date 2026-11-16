# Org Formatting Implementation Plan

> **For agentic workers:** Use superpowers:executing-plans for inline execution.

**Goal:** Preserve Org formatting when pushing comments and descriptions.

**Architecture:** Share an Org-parser-based converter across write paths.
Convert supported Jira inline markup back to Org on rendering for repeat edits.

**Tech Stack:** Emacs Lisp, built-in org-element/org-table, ERT.

**Spec:** docs/superpowers/specs/2026-11-16-org-formatting-design.md

## Global Constraints

- No external dependencies; retain existing Jira REST v2 string payloads.
- Preserve literal code, URLs, Unicode, whitespace, and plain text.
- Keep low-level jiralib APIs accepting Jira markup.

## Review Focus

- Nested emphasis, formatted link labels, and formatting in table cells.
- Literal source blocks and inline code containing formatting characters.
- Refresh followed by another push must preserve formatting.

### Task 1: Convert Org text

- [x] Add ERT cases for inline formatting, links, tables, and code blocks.
- [x] Observe those cases fail before implementing `org-jira--org-to-jira`.
- [x] Implement conversion using parsed object positions and reverse edits.
- [x] Run targeted conversion tests.

### Task 2: Apply conversion and preserve refresh semantics

- [x] Add payload tests for new/edited comments, issue updates, and creation.
- [x] Add tests for supported Jira-to-Org markup and refresh/push round trips.
- [x] Observe failures, then integrate the shared converter and rendering inverse.
- [x] Document supported formatting in README.md.
- [x] Run `make test` and `git diff --check`; inspect the complete diff.

## Verification

86 ERT tests pass, including all five review findings. Literal masking prevents
code delimiters from closing surrounding emphasis; generated inline code is
validated; block bodies are escaped and unsupported macro options retained;
existing Org literals are protected; nested/table strikes restore Org syntax.
Byte compilation succeeds. Jira calls are replaced at the API boundary in tests.
