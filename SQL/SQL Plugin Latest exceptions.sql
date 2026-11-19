-- SPDX-License-Identifier: MIT
-- SQL 4 CDS | Find recent platform exceptions and recognizable errors written to the trace.
-- trace_error is inferred from messageblock. Copy correlationid into SQL Plugin Debug.sql.

-- Set a CorrelationId to bypass the time window, type filter and result cap.
DECLARE @CorrelationId UNIQUEIDENTIFIER = NULL;
DECLARE @MinutesBack INT = 60;
DECLARE @TypeLike NVARCHAR(200) = N'%'; -- Enter a class or namespace prefix. A trailing % is added if needed.
DECLARE @Top INT = 100;
DECLARE @StartUtc DATETIME = DATEADD(MINUTE, -@MinutesBack, GETUTCDATE());

DECLARE @ResultLimit INT = CASE WHEN @CorrelationId IS NULL THEN @Top ELSE 2147483647 END;

DECLARE @TypePattern NVARCHAR(201) = CASE WHEN RIGHT(@TypeLike, 1) = N'%' THEN @TypeLike ELSE @TypeLike + N'%' END;

SELECT TOP (@ResultLimit)
    t.createdon,
    t.correlationid,
    t.plugintracelogid,
    t.typename,
    t.modename,
    t.messagename,
    t.primaryentity,
    t.depth,
    CASE WHEN t.has_exception = 1 THEN 'exceptiondetails' ELSE 'trace_error' END AS error_source,
    CASE
        WHEN t.has_exception = 1 THEN LEFT(t.exceptiondetails, 2000)
        ELSE SUBSTRING(t.messageblock, t.trace_error_position, 500)
    END AS error_snippet
FROM (
    SELECT
        p.createdon,
        p.correlationid,
        p.plugintracelogid,
        p.typename,
        p.modename,
        p.messagename,
        p.primaryentity,
        p.depth,
        p.exceptiondetails,
        p.messageblock,
        CASE WHEN LEN(LTRIM(RTRIM(p.exceptiondetails))) > 0 THEN 1 ELSE 0 END AS has_exception,
        COALESCE(
            NULLIF(CHARINDEX(N'inner exception:', LOWER(p.messageblock)), 0),
            NULLIF(CHARINDEX(N'an error occurred', LOWER(p.messageblock)), 0),
            NULLIF(CHARINDEX(N'an error occured', LOWER(p.messageblock)), 0)
        ) AS trace_error_position
    FROM plugintracelog AS p
    WHERE (@CorrelationId IS NOT NULL AND p.correlationid = @CorrelationId)
       OR (@CorrelationId IS NULL AND p.createdon >= @StartUtc AND p.typename LIKE @TypePattern)
) AS t
WHERE t.has_exception = 1
   OR t.trace_error_position IS NOT NULL
ORDER BY t.createdon DESC, t.plugintracelogid DESC;
