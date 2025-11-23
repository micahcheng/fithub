-- FitHub Admin CRUD Queries
-- 1. #As an admin, I want to review reported listings so that I can remove inappropriate content  or resolve problems quickly.
SELECT ReportID, Note, Severity, ReportedItem
FROM Reports
WHERE Resolved = 0;

-- 2.
#As an admin, I want to update user roles so that moderators have correct permissions.
UPDATE Users
SET Role = 'Moderator'
WHERE UserID = 3;

-- 3. As an admin, I want to deactivate inactive or spam users so that the database stays efficient & reliable.

UPDATE Users
SET IsSuspended = 1, IsActive = 0
WHERE LastLoginAt < DATE_SUB(CURDATE(), INTERVAL 90 DAY);

-- 4. As an admin, I want to add system announcements so that users are informed of updates.


INSERT INTO Announcements (AnnouncerID, Message, AnnouncedAt)
VALUES (4, 'Maintenance scheduled for tonight at 11 PM.', NOW());-- 5. As an admin, I want to track analytics on users & listings so I can monitor system health.

SELECT
    (SELECT COUNT(*) FROM Users) AS TotalUsers,
    (SELECT COUNT(*) FROM Items) AS TotalListings,
    (SELECT COUNT(*) FROM Reports WHERE Resolved = 0) AS OpenReports;
-- 6. As an admin, I want to remove or flag duplicate or spam listings so that the platform remains trustworthy.

UPDATE Items
SET IsFlagged = 1, FlagReason = 'Admin flagged: suspected duplicate'
WHERE ItemID = 1;





#As an admin, I want to remove or flag duplicate or spam listings so that the platform remains trustworthy.
