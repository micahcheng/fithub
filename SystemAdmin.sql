-- System Administrator CRUD Queries
USE fithub;
-- 1. #As an admin, I want to review reported listings so that I can remove inappropriate content  or resolve problems quickly.
SELECT ReportID, Note, Severity, ReportedItem
FROM Reports
WHERE Resolved = 0;

-- 2. As an admin, I want to update user roles so that moderators have correct permissions.
UPDATE Users
SET Role = 'Moderator'
WHERE UserID = 3;

-- 3. As an admin, I want to deactivate inactive or spam users so that the database stays efficient & reliable.
-- Deactivate users who haven't been involved in any orders (given or received) or listed items in the last 90 days
UPDATE Users u
LEFT JOIN (
    SELECT DISTINCT GivenByID AS UserID FROM Orders WHERE CreatedAt >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)
    UNION
    SELECT DISTINCT ReceiverID AS UserID FROM Orders WHERE CreatedAt >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)
    UNION
    SELECT DISTINCT OwnerID AS UserID FROM Items WHERE ListedAt >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)
) active_users ON u.UserID = active_users.UserID
SET u.IsActive = 0
WHERE u.IsActive = 1
  AND active_users.UserID IS NULL;

-- 4. As an admin, I want to add system announcements so that users are informed of updates.
INSERT INTO Announcements (AnnouncerID, Message, AnnouncedAt)
VALUES (4, 'Maintenance scheduled for tonight at 11 PM.', NOW());-- 5. As an admin, I want to track analytics on users & listings so I can monitor system health.

SELECT
    (SELECT COUNT(*) FROM Users) AS TotalUsers,
    (SELECT COUNT(*) FROM Items) AS TotalListings,
    (SELECT COUNT(*) FROM Reports WHERE Resolved = 0) AS OpenReports;

-- 6. As an admin, I want to remove duplicate or spam listings so that the platform remains trustworthy.
UPDATE Items
SET IsAvailable = 0
WHERE ItemID IN (
    SELECT ItemID FROM (
        SELECT i2.ItemID
        FROM Items i1
        INNER JOIN Items i2 ON i1.Title = i2.Title AND i1.OwnerID = i2.OwnerID AND i1.ItemID < i2.ItemID
        WHERE i1.IsAvailable = 1 AND i2.IsAvailable = 1
        UNION
        SELECT ReportedItem AS ItemID
        FROM Reports
        WHERE ReportedItem IS NOT NULL AND Resolved = 0
        GROUP BY ReportedItem
        HAVING COUNT(*) >= 2 OR MAX(Severity) >= 4
    ) AS to_remove
);

UPDATE Reports
SET Resolved = 1, ResolverID = 4, ResolvedAt = NOW()
WHERE ReportedItem IN (SELECT ItemID FROM Items WHERE IsAvailable = 0) AND Resolved = 0;