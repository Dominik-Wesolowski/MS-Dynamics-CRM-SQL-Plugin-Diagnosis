-- SPDX-License-Identifier: MIT
-- Latest plugin exceptions (plugintracelog)
-- SQL 4 CDS / SSMS. Read-only. Params: @MinutesBack, @Top.

DECLARE @MinutesBack INT = 0;
DECLARE @TypeLike NVARCHAR(200) = N'XYZ.%';
DECLARE @Top INT = 100;

-- Default: always show top N results
IF ISNULL(@Top, 0) <= 0
    SET @Top = 100;

-- If MinutesBack > 0, calculate window start
DECLARE @StartUtc DATETIME = NULL;
IF ISNULL(@MinutesBack, 0) > 0
    SET @StartUtc = DATEADD(MINUTE, -@MinutesBack, GETUTCDATE());

-- Main query
SELECT TOP (@Top)
    p.createdon,
    p.correlationid,
    p.messagename,
    p.primaryentity,
    p.depth,
    LEFT(p.typename, 160) AS typename,
    LEFT(p.exceptiondetails, 2000) AS exception_snippet
FROM plugintracelog AS p
WHERE p.typename LIKE @TypeLike
  AND LEN(LTRIM(RTRIM(ISNULL(p.exceptiondetails, '')))) > 0
  AND (
        @StartUtc IS NULL        -- if MinutesBack = 0/null → show all
        OR p.createdon > @StartUtc
      )
ORDER BY p.createdon DESC;
