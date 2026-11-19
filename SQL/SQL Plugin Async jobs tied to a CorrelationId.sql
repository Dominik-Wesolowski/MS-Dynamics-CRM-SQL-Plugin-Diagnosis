-- SPDX-License-Identifier: MIT
-- SQL 4 CDS | Check status, retries and errors for system jobs with the same CorrelationId.
-- A job can be absent if it has already been deleted or has a different CorrelationId.

DECLARE @CorrelationId UNIQUEIDENTIFIER = NULL; -- Replace NULL with a quoted GUID.
DECLARE @Top INT = 50;

IF @CorrelationId IS NULL
    THROW 50000, 'Set @CorrelationId to a GUID from the trace log.', 1;

SELECT TOP (@Top)
    a.createdon,
    a.asyncoperationid,
    a.correlationid,
    a.name,
    a.messagename,
    a.operationtypename,
    a.statecodename,
    a.statuscodename,
    a.retrycount,
    a.postponeuntil,
    a.startedon,
    a.completedon,
    a.errorcode,
    a.friendlymessage,
    a.message,
    a.regardingobjectid
FROM asyncoperation AS a
WHERE a.correlationid = @CorrelationId
ORDER BY a.createdon DESC, a.asyncoperationid DESC;
