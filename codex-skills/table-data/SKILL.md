---
name: table-data
description: "Spreadsheet and table-data cleanup router. Use when the user asks to organize, clean, merge, normalize, deduplicate, validate, summarize, pivot, analyze, or reformat Excel, CSV, TSV, Google Sheets, or other tabular data. Triggers include 表格, 数据整理, Excel, xlsx, csv, tsv, Google Sheets, 去重, 合并表, 透视表, 清洗数据, and 数据汇总."
---

# Table Data

Use this skill as the first stop for spreadsheet and tabular-data work. It routes the task to the strongest available spreadsheet, Google Sheets, or data-analysis workflow, then keeps the output clean, auditable, and easy to reuse.

## Scope

Use this skill for:

- Cleaning Excel, CSV, TSV, or copied table data.
- Standardizing headers, dates, numbers, currency, percentages, categories, and empty values.
- Deduplicating rows and explaining duplicate rules.
- Merging, joining, splitting, reshaping, or normalizing tables.
- Creating summary sheets, pivot-style tables, checks, filters, validation columns, formulas, and charts.
- Preparing table data for later import into Google Sheets, dashboards, reports, or scripts.
- Inspecting an existing workbook or sheet to answer questions about its data quality.

Do not use this skill for unrelated prose documents, images, source-code tables, or database work unless the user explicitly wants the result as a spreadsheet/table artifact.

## Routing

1. Local spreadsheet files:
   - For `.xlsx`, `.xls`, `.csv`, `.tsv`, or spreadsheet artifacts, use the installed `spreadsheets:Spreadsheets` skill when available.
   - Preserve formulas and workbook structure unless the user asks for a flat cleaned export.
   - When creating or editing a workbook, verify key ranges, scan for formula errors, render a visual pass when formatting matters, and export a final `.xlsx`.

2. Existing Google Sheets:
   - Use the installed `google-drive:google-sheets` skill and Google Sheets connector workflow when available.
   - Confirm the exact spreadsheet URL/id and target tab/range before editing.
   - Read metadata and bounded ranges before writing.

3. New Google Sheets:
   - Build a local `.xlsx` with the spreadsheet workflow first, then import it as a native Google Sheet if the Google Drive connector is available.
   - Return the Google Sheet link as the final deliverable.

4. Analytical reports, dashboards, or charts:
   - Use the relevant `data-analytics:*` skill when the user asks for KPI design, report/dashboard output, trend analysis, visualizations, or business interpretation.
   - Keep the cleaned source table available as an audit trail.

5. Lightweight text-only table cleanup:
   - If the user pasted a small table and only wants a quick normalized Markdown/CSV result, answer directly.
   - If the rules are ambiguous, state the cleanup assumptions before returning the table.

## Default Workflow

1. Identify the source format, target output, and whether edits should preserve the original file.
2. Make a copy or new output artifact for destructive cleanup unless the user explicitly asks to overwrite.
3. Profile the data:
   - row and column counts
   - headers and inferred types
   - blanks, malformed values, duplicate keys, outliers, and mixed formats
4. Apply the smallest set of transformations that satisfies the request.
5. Add a `README`, `Notes`, `Checks`, or similar sheet when the cleanup is nontrivial and the output is a workbook.
6. Verify:
   - row counts before and after
   - duplicate handling
   - key totals or grouped counts
   - formula errors when formulas exist
   - visible layout if delivering a workbook
7. Final response should state what changed, where the cleaned artifact is, and any assumptions or unresolved data issues.

## Data Rules

- Do not silently drop rows. If rows are excluded, record the rule and count.
- Do not invent missing values. Fill blanks only when the rule is explicit or safely derived from adjacent/grouped records.
- Keep identifiers as text when leading zeros, long numeric ids, SKUs, phone-like values, or codes may be damaged by numeric conversion.
- Use stable, deterministic sort orders for final outputs.
- Keep original raw data in a separate sheet or file when the cleanup is substantial.
- Prefer formulas for workbook-visible derived fields and scripts for repeatable bulk cleanup.
- Treat tokens, emails, phone numbers, addresses, IDs, and customer records as sensitive. Minimize exposure in summaries.

## Common Deliverables

- Cleaned workbook: `Raw`, `Cleaned`, `Summary`, and optional `Checks` sheets.
- Cleaned CSV/TSV with a short assumptions note.
- Duplicate report with retained/dropped row counts and key examples.
- Merge report showing matched, unmatched-left, unmatched-right, and conflict counts.
- Summary table or chart with source row counts and calculation definitions.

## Deepseek Repository Note

This skill is shared through the Deepseek ops repository under `codex-skills/table-data`. Local copies under `~/.codex/skills/table-data` are derived state and should be refreshed from the repository setup/sync scripts.
