-- SPDX-License-Identifier: MIT
-- Trace search by substring in message text (plugintracelog)
-- SQL 4 CDS / SSMS. Read-only. Params: @MinutesBack, @Search, @Top.

DECLARE @TypeLike NVARCHAR(200) = N'XYZ.%', @TraceLike NVARCHAR(200) = N'%TRACE%', @Top INT = 100;

SELECT TOP (@Top)
  p.createdon, LEFT(p.typename,160) AS typename, p.messagename,
  SUBSTRING(p.messageblock,1,4000) AS trace_snippet
FROM plugintracelog AS p
WHERE p.typename LIKE @TypeLike
  AND p.messageblock LIKE @TraceLike
ORDER BY p.createdon DESC;
