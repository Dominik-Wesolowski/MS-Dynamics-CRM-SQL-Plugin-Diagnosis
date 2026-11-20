-- SPDX-License-Identifier: MIT
-- SQL 4 CDS | Browse recent stored plugin traces, including skips and normal completions.
-- Copy correlationid into SQL Plugin Debug.sql to see the other entries for that execution.

DECLARE @MinutesBack INT = 60;
DECLARE @TypeLike NVARCHAR(200) = N'%'; -- Enter a class or namespace prefix. A trailing % is added if needed.
DECLARE @Top INT = 100;
DECLARE @StartUtc DATETIME = DATEADD(MINUTE, -@MinutesBack, GETUTCDATE());
DECLARE @TypePattern NVARCHAR(201) =
    CASE WHEN RIGHT(@TypeLike, 1) = N'%' THEN @TypeLike ELSE @TypeLike + N'%' END;

SELECT TOP (@Top)
    p.createdon,
    p.correlationid,
    p.plugintracelogid,
    p.typename,
    p.modename,
    p.messagename,
    p.primaryentity,
    p.depth,
    p.performanceexecutionduration AS execution_ms,
    p.messageblock,
    p.exceptiondetails
FROM plugintracelog AS p
WHERE p.createdon >= @StartUtc
  AND p.typename LIKE @TypePattern
ORDER BY p.createdon DESC, p.plugintracelogid DESC;
