-- SPDX-License-Identifier: MIT
-- Frequent error fingerprints (dedup stacks) from plugintracelog
-- SQL 4 CDS / SSMS. Read-only. Params: @MinutesBack, @Top.

DECLARE @MinutesBack INT = 10, @TypeLike NVARCHAR(200) = N'XYZ.%';
DECLARE @StartUtc DATETIME = DATEADD(MINUTE, -@MinutesBack, GETUTCDATE());

WITH errs AS (
  SELECT
    LEFT(typename,160) AS typename,
    messagename,
    LEFT(REPLACE(REPLACE(REPLACE(exceptiondetails, CHAR(10),' '), CHAR(13),' '), CHAR(9),' '), 300) AS ex_fingerprint
  FROM plugintracelog
  WHERE createdon > @StartUtc
    AND typename LIKE @TypeLike
    AND LEN(LTRIM(RTRIM(ISNULL(exceptiondetails,'')))) > 0
)
SELECT typename, messagename, ex_fingerprint, COUNT(*) AS occurrences
FROM errs
GROUP BY typename, messagename, ex_fingerprint
ORDER BY occurrences DESC;
