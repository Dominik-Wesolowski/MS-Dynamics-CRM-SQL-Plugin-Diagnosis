-- SPDX-License-Identifier: MIT
-- SQL 4 CDS | Find a literal substring in recent trace messages.
-- Copy correlationid to SQL Plugin Debug.sql to see the remaining entries.

DECLARE @Search NVARCHAR(200) = N''; -- Paste a record ID or a fragment of a trace message.
DECLARE @MinutesBack INT = 60;
DECLARE @TypeLike NVARCHAR(200) = N'%'; -- Enter a class or namespace prefix. A trailing % is added if needed.
DECLARE @Top INT = 100;
DECLARE @StartUtc DATETIME = DATEADD(MINUTE, -@MinutesBack, GETUTCDATE());
DECLARE @TypePattern NVARCHAR(201) =
    CASE WHEN RIGHT(@TypeLike, 1) = N'%' THEN @TypeLike ELSE @TypeLike + N'%' END;

IF @Search IS NULL OR LEN(LTRIM(RTRIM(@Search))) = 0
    THROW 50000, 'Set @Search to a non-empty trace fragment.', 1;

SELECT TOP (@Top)
    t.createdon,
    t.correlationid,
    t.plugintracelogid,
    t.typename,
    t.modename,
    t.messagename,
    t.primaryentity,
    SUBSTRING(
        t.messageblock,
        CASE WHEN t.match_position > 120 THEN t.match_position - 120 ELSE 1 END,
        500
    ) AS trace_snippet
FROM (
    SELECT
        p.createdon,
        p.correlationid,
        p.plugintracelogid,
        p.typename,
        p.modename,
        p.messagename,
        p.primaryentity,
        p.messageblock,
        CHARINDEX(@Search, p.messageblock) AS match_position
    FROM plugintracelog AS p
    WHERE p.createdon >= @StartUtc
      AND p.typename LIKE @TypePattern
      AND p.messageblock IS NOT NULL
) AS t
WHERE t.match_position > 0
ORDER BY t.createdon DESC, t.plugintracelogid DESC;
