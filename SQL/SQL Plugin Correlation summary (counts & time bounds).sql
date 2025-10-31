-- SPDX-License-Identifier: MIT
-- Correlation summary: counts and first/last timestamps (plugintracelog)
-- SQL 4 CDS / SSMS. Read-only. Params: @MinutesBack, @Top.

DECLARE @MinutesBack INT = 10, @TypeLike NVARCHAR(200) = N'XYZ.%';
DECLARE @StartUtc DATETIME = DATEADD(MINUTE, -@MinutesBack, GETUTCDATE());

SELECT
  t.correlationid,
  COUNT(*) AS trace_count,
  SUM(CASE WHEN LEN(LTRIM(RTRIM(ISNULL(t.exceptiondetails,'')))) > 0 THEN 1 ELSE 0 END) AS error_count,
  MIN(t.createdon) AS first_seen,
  MAX(t.createdon) AS last_seen
FROM (
  SELECT createdon, correlationid, exceptiondetails
  FROM plugintracelog
  WHERE createdon > @StartUtc AND typename LIKE @TypeLike
) AS t
GROUP BY t.correlationid
ORDER BY error_count DESC, trace_count DESC, last_seen DESC;
