# 🧩 Dynamics 365 / Dataverse Plugin Diagnostics (SQL Toolkit)

This repository contains a curated collection of **read-only SQL scripts** designed to help engineers **analyze, troubleshoot, and optimize plugin executions** in Microsoft Dynamics 365 / Power Platform environments.

Each script targets the **Dataverse TDS endpoint** and can be executed using:
- [SQL 4 CDS](https://github.com/MarkMpn/Sql4Cds) (recommended for XrmToolBox)

All queries are **non-destructive** - they only `SELECT` data from system tables such as `plugintracelog` and `asyncoperation`.

---

## 📊 Overview

| Script | Purpose | Input (Params) | Output (Selected columns) |
|--------|----------|----------------|----------------------------|
| **SQL Plugin Async jobs tied to a CorrelationId.sql** | Lists async/system jobs spawned under a given `CorrelationId`. Useful for tracing background plugin chains or triggered flows. | `@CorrelationId`, `@NameLike` | `asyncoperationid`, `createdon`, `name`, `messagename`, `correlationid`, `regardingobjectid` |
| **SQL Plugin Correlation summary (counts & time bounds).sql** | Summarizes Plugin Trace Log entries by `CorrelationId` with count and time range. Helps detect long or chatty executions. | `@MinutesBack`, `@TypeLike` | `correlationid`, `trace_count`, `error_count`, `first_seen`, `last_seen` |
| **SQL Plugin Debug.sql** | Ad-hoc browser for `plugintracelog` to inspect messages, errors, and stack traces for a time window. | `@MinutesBack`, `@NamespaceFilter`, `@CorrelationId` | `createdon`, `correlationid`, `messagename`, `typename`, `messageblock` |
| **SQL Plugin Frequent error fingerprints (dedup noisy stacks).sql** | Groups repeated exceptions by fingerprint to identify distinct recurring errors. | `@MinutesBack`, `@TypeLike` | `typename`, `messagename`, `ex_fingerprint`, `occurrences` |
| **SQL Plugin Latest exceptions.sql** | Displays the latest plugin exceptions for quick triage of failing components. | `@MinutesBack`, `@Top`, `@TypeLike` | `createdon`, `correlationid`, `messagename`, `typename`, `exception_snippet` |
| **SQL Plugin Noisy plugins (run & error count in window).sql** | Ranks plugins by execution and error counts to locate hotspots. | `@MinutesBack`, `@TypeLike` | `typename`, `messagename`, `run_count`, `error_count` |
| **SQL Plugin Sync vs Async distribution.sql** | Compares synchronous vs asynchronous executions to understand load split. | `@MinutesBack`, `@TypeLike` | `modename`, `typename`, `messagename`, `run_count`, `error_count` |
| **SQL Plugin Trace search by substring (messageblock LIKE).sql** | Searches trace messages by substring to locate relevant traces or keywords. | `@TypeLike`, `@TraceLike`, `@Top` | `createdon`, `typename`, `messagename`, `trace_snippet` |

---

## ⚙️ How to Use

1. **Connect** to your Dataverse environment using SQL 4 CDS or SSMS.
2. **Open** any `.sql` file from this repository.  
3. **Adjust parameters** at the top (e.g., `@MinutesBack`, `@CorrelationId`, `@Top`).  
4. **Run** the query – results will appear immediately.

> 🧠 Tip: `CorrelationId` lets you trace the entire execution chain across multiple plugins, async operations, and Power Automate flows triggered by the same transaction.

---

## 🛡️ Safety Notes

- All queries are **read-only** (`SELECT` statements only).  
- Do **not** add `UPDATE` or `DELETE` clauses unless you fully understand the impact.  
- Timestamps in results are **UTC**.  
- No data modification or writes occur when running these scripts.

---

## 💡 Typical Use Cases

- 🔍 Investigate a specific **plugin failure** by its `CorrelationId`.  
- 🧵 Trace a **synchronous → asynchronous** hand-off chain.  
- 📈 Identify **noisy or error-prone plugins**.  
- 🪶 Detect **duplicate error stacks** for grouping and triage.  
- 🧭 Search logs for a keyword (e.g., custom trace messages).

---

## 🧱 Repository Structure

/sql
```
├─ SQL Plugin Async jobs tied to a CorrelationId.sql
├─ SQL Plugin Correlation summary (counts & time bounds).sql
├─ SQL Plugin Debug.sql
├─ SQL Plugin Frequent error fingerprints (dedup noisy stacks).sql
├─ SQL Plugin Latest exceptions.sql
├─ SQL Plugin Noisy plugins (run & error count in window).sql
├─ SQL Plugin Sync vs Async distribution.sql
├─ SQL Plugin Trace search by substring (messageblock LIKE).sql
└─ README.md
```


---

## 🧾 License

All scripts are released under the [MIT License](LICENSE).  
You are free to use, modify, and redistribute them - please retain the SPDX header in each file.

---

## 🤝 Contributing

Pull requests are welcome!  
If you have useful plugin diagnostics, add your `.sql` file with:
- clear parameter declarations,
- safe, read-only logic,
- and a short 2–4 line header comment (as in existing scripts).

---
