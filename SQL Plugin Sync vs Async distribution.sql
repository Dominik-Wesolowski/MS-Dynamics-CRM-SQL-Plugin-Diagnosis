-- SPDX-License-Identifier: MIT
-- Sync vs Async distribution (plugintracelog)
-- SQL 4 CDS / SSMS. Read-only. Params: @MinutesBack.

DECLARE @MinutesBack INT = 10, @TypeLike NVARCHAR(200) = N'XYZ.%';
DECLARE @StartUtc DATETIME = DATEADD(MINUTE, -@MinutesBack, GETUTCDATE());

SELECT
  modename,
  LEFT(typename,160) AS typename,
  messagename,
  COUNT(*) AS run_count,
  SUM(CASE WHEN LEN(LTRIM(RTRIM(ISNULL(exceptiondetails,'')))) > 0 THEN 1 ELSE 0 END) AS error_count
FROM plugintracelog
WHERE createdon > @StartUtc
  AND typename LIKE @TypeLike
GROUP BY modename, typename, messagename
ORDER BY modename, run_count DESC;
