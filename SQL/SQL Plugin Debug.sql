-- SPDX-License-Identifier: MIT
-- Plugin Trace Log ad‑hoc explorer (plugintracelog)
-- SQL 4 CDS / SSMS. Read-only. Params: @MinutesBack, @TypeLike, @Top, ...

DECLARE @MinutesBack INT = 10;
DECLARE @NamespaceFilter NVARCHAR(128) = N'XYZ.';  -- Set to N'' to disable
DECLARE @CorrelationId UNIQUEIDENTIFIER = '';

DECLARE @StartUtc DATETIME = DATEADD(MINUTE, -@MinutesBack, GETUTCDATE());
DECLARE @TypeLike NVARCHAR(140) =
    CASE WHEN NULLIF(@NamespaceFilter, N'') IS NULL THEN N'%' ELSE @NamespaceFilter + N'%' END;

SELECT
    CONVERT(VARCHAR(23), p.createdon, 121) AS ts_utc,
    p.correlationid,
    p.depth,
    p.modename,
    p.messagename,
    p.primaryentity,
    LEFT(p.typename, 160) AS typename,
    LEFT(p.messageblock, 400) AS message_preview,
    CASE
        WHEN LEN(LTRIM(RTRIM(ISNULL(p.exceptiondetails, '')))) > 0 THEN N'⚠️ ERR'
        ELSE N''
    END AS status
FROM plugintracelog AS p
WHERE p.createdon > @StartUtc
  AND p.typename LIKE @TypeLike
ORDER BY p.createdon DESC, p.plugintracelogid DESC;

-- Full execution chain for a specific CorrelationId
SELECT
    CONVERT(VARCHAR(23), p.createdon, 121) AS ts_utc,
    p.depth,
    p.modename,
    p.messagename,
    p.primaryentity,
    LEFT(p.typename, 160) AS typename,
    LEFT(p.messageblock, 2000) AS message
FROM plugintracelog AS p
WHERE p.correlationid = @CorrelationId
  AND p.typename LIKE @TypeLike
ORDER BY p.createdon, p.depth, p.plugintracelogid;

-- Additionally: only errors for the selected CorrelationId (ignoring empty/whitespace)
SELECT
    CONVERT(VARCHAR(23), p.createdon, 121) AS ts_utc,
    LEFT(p.typename, 160) AS typename,
    p.exceptiondetails
FROM plugintracelog AS p
WHERE p.correlationid = @CorrelationId
  AND p.exceptiondetails IS NOT NULL
  AND LEN(LTRIM(RTRIM(p.exceptiondetails))) > 0
ORDER BY p.createdon, p.plugintracelogid;
