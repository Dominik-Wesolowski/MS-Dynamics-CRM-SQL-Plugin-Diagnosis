-- SPDX-License-Identifier: MIT
-- Async jobs by CorrelationId (Dataverse asyncoperation)
-- Use in SQL 4 CDS / SSMS. Read-only. Params: @CorrelationId, @NameLike.

DECLARE @CorrelationId UNIQUEIDENTIFIER = 'PUT-YOUR-CID';
DECLARE @NameLike NVARCHAR(200) = N'XYZ.%';

SELECT TOP 50
  a.asyncoperationid, a.createdon, a.name, a.messagename,
  a.correlationid, a.regardingobjectid, a.regardingobjectidname
FROM asyncoperation AS a
WHERE a.correlationid = @CorrelationId
  AND a.name LIKE @NameLike
ORDER BY a.createdon DESC;
