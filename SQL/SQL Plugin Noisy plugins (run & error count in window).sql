-- SPDX-License-Identifier: MIT
-- SQL 4 CDS | Rank stored trace entries by plugin step, message and execution mode.
-- Exceptions-only logging excludes successful executions from these counts.

DECLARE @MinutesBack INT = 60;
DECLARE @TypeLike NVARCHAR(200) = N'%'; -- Enter a class or namespace prefix. A trailing % is added if needed.
DECLARE @Top INT = 50;
DECLARE @SortByExceptions BIT = 1; -- 1: exceptions and trace errors first. 0: trace volume first.
DECLARE @StartUtc DATETIME = DATEADD(MINUTE, -@MinutesBack, GETUTCDATE());
DECLARE @TypePattern NVARCHAR(201) =
    CASE WHEN RIGHT(@TypeLike, 1) = N'%' THEN @TypeLike ELSE @TypeLike + N'%' END;

SELECT TOP (@Top)
    r.typename,
    r.pluginstepid,
    r.messagename,
    r.modename,
    r.trace_count,
    r.exception_count,
    r.trace_error_count
FROM (
    SELECT
        p.typename,
        p.pluginstepid,
        p.messagename,
        p.modename,
        COUNT(*) AS trace_count,
        SUM(CASE WHEN LEN(LTRIM(RTRIM(p.exceptiondetails))) > 0 THEN 1 ELSE 0 END) AS exception_count,
        SUM(CASE
                WHEN LEN(LTRIM(RTRIM(p.exceptiondetails))) > 0 THEN 0
                WHEN CHARINDEX(N'inner exception:', LOWER(p.messageblock)) > 0
                  OR CHARINDEX(N'an error occurred', LOWER(p.messageblock)) > 0
                  OR CHARINDEX(N'an error occured', LOWER(p.messageblock)) > 0 THEN 1
                ELSE 0
            END) AS trace_error_count
    FROM plugintracelog AS p
    WHERE p.createdon >= @StartUtc
      AND p.typename LIKE @TypePattern
    GROUP BY p.typename, p.pluginstepid, p.messagename, p.modename
) AS r
ORDER BY CASE WHEN @SortByExceptions = 1 THEN r.exception_count + r.trace_error_count
              ELSE r.trace_count END DESC,
         r.trace_count DESC, r.typename, r.pluginstepid, r.messagename, r.modename;
