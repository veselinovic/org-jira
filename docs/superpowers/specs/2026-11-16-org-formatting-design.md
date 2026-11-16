# Org formatting in Jira comments and descriptions

Org markup currently reaches Jira unchanged, except for TODO description
tables. Convert supported Org markup to the Jira wiki syntax used by the
existing REST v2 integration, in every comment and description write path.

Use the built-in Org parser for inline emphasis, inline code, links, tables,
and source/example blocks. Preserve text layout, Unicode, URLs, and code
contents. Keep summaries and low-level jiralib string APIs unchanged.

Refresh must restore supported Jira inline markup to Org syntax so another
push does not reinterpret Jira italics as Org underline. Keep unsupported
Jira macros intact. No external exporter dependency or REST API migration.

Approaches considered: a separate exporter dependency adds installation and
compatibility work; global substitutions damage code and URLs. The existing
Org parser provides the syntax information needed for this focused fix.
