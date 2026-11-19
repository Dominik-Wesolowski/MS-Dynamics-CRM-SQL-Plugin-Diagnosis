-- SPDX-License-Identifier: MIT
-- SQL 4 CDS | All available trace entries for one CorrelationId.
-- Copy a GUID from Latest exceptions or Trace search. For async, check Async jobs too.

DECLARE @CorrelationId UNIQUEIDENTIFIER = NULL; -- Replace NULL with a quoted GUID.

IF @CorrelationId IS NULL
    THROW 50000, 'Set @CorrelationId to a GUID from the trace log.', 1;

SELECT
    p.correlationid,
    p.plugintracelogid,
    p.requestid,
    p.createdon,
    p.performanceexecutionstarttime AS execution_started_on,
    p.performanceexecutionduration AS execution_ms,
    p.depth,
    p.modename,
    p.messagename,
    p.primaryentity,
    p.typename,
    p.pluginstepid,
    CASE
        WHEN LEN(LTRIM(RTRIM(p.exceptiondetails))) > 0 THEN 'exceptiondetails'
        WHEN CHARINDEX(N'inner exception:', LOWER(p.messageblock)) > 0
          OR CHARINDEX(N'an error occurred', LOWER(p.messageblock)) > 0
          OR CHARINDEX(N'an error occured', LOWER(p.messageblock)) > 0 THEN 'trace_error'
    END AS error_source,
    p.messageblock,
    p.exceptiondetails
FROM plugintracelog AS p
WHERE p.correlationid = @CorrelationId
ORDER BY COALESCE(p.performanceexecutionstarttime, p.createdon),
         p.createdon, p.depth, p.plugintracelogid;
