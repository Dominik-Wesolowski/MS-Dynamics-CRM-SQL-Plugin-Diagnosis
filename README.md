# Dynamics 365 / Dataverse Plugin Diagnostics

Five read-only queries for [SQL 4 CDS](https://github.com/MarkMpn/Sql4Cds) v9 or later in XrmToolBox, or SSMS with the SQL 4 CDS extension. Connect to the Dataverse environment you want to diagnose and run each file as a batch.

## Diagnose an incident

1. Open [Latest exceptions](SQL/SQL%20Plugin%20Latest%20exceptions.sql) to find a recent error. If you only have a record ID or text from a trace message, open [Trace search](SQL/SQL%20Plugin%20Trace%20search%20by%20substring%20%28messageblock%20LIKE%29.sql) and set `@Search`. The search treats wildcard characters literally and shows the text around the first match.
2. Copy the result's `correlationid` into [Debug](SQL/SQL%20Plugin%20Debug.sql). Replace `NULL` with the GUID in single quotes. The result shows all available trace entries for that correlation, their execution order and duration, and the stored trace and exception text.
3. For asynchronous work, paste the same GUID into [Async jobs](SQL/SQL%20Plugin%20Async%20jobs%20tied%20to%20a%20CorrelationId.sql). Check the status, retry count, timestamps, and error details. Jobs that were deleted or use a different correlation ID will be absent.

[Noisy plugins](SQL/SQL%20Plugin%20Noisy%20plugins%20%28run%20%26%20error%20count%20in%20window%29.sql) summarizes trace entries and exceptions by plugin step, message, and execution mode. Set `@SortByExceptions = 0` to rank by trace volume.

## Parameters and log coverage

- `@MinutesBack` defaults to 60. Use a shorter window on busy environments, especially when searching trace text or running the report.
- `@TypeLike` defaults to `N'%'` (all plugin types). A value such as `N'Contoso.Plugins.%'` filters by namespace.
- `@Top` controls the number of returned rows. Debug returns every available entry for the selected correlation.
- Plugin Trace Log reflects the environment's logging level and retention. In **Exceptions** mode, counts exclude successful executions. If a query returns nothing, check the time window, logging level, retention, and your access to the log or system jobs. See [Dataverse logging and tracing](https://learn.microsoft.com/en-us/power-apps/developer/data-platform/logging-tracing).

The SQL files carry the MIT SPDX identifier.
