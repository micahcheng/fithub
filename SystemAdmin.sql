-- System Administrator CRUD Queries
USE fithub;
-- 1. As an admin, I want to review reported listings so that I can remove inappropriate content  or resolve problems quickly.
SELECT ReportID, Note, Severity, ReportedItem
FROM Reports
WHERE Resolved = 0;

-- 2. As an admin, I want to update user roles so that analysts/adminhave correct permissions.
UPDATE Users
SET Role = 'Analyst'
WHERE UserID = 3;
SELECT * FROM Users;

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
VALUES (4, 'Maintenance scheduled for tonight at 11 PM.', NOW());

-- Insert into AnnouncementsReceived for all active users (this is how recipients are tracked)
INSERT INTO AnnouncementsReceived (AnnouncementID, UserID)
SELECT LAST_INSERT_ID(), UserID FROM Users WHERE IsActive = 1;

-- 5. As an admin, I want to track analytics on users & listings so I can monitor system health.

SELECT
    (SELECT COUNT(*) FROM Users) AS TotalUsers,
    (SELECT COUNT(*) FROM Items) AS TotalListings,
    (SELECT COUNT(*) FROM Reports WHERE Resolved = 0) AS OpenReports;

-- 6. As an admin, I want to remove duplicate or spam listings so that the platform remains trustworthy.

-- First delete child rows (Images + ItemTags) to avoid FK errors


ALTER TABLE Images
DROP FOREIGN KEY Images_ibfk_1;

ALTER TABLE Images
ADD CONSTRAINT Images_ibfk_1
    FOREIGN KEY (ItemID)
    REFERENCES Items(ItemID)
    ON DELETE CASCADE;

-- 2) ItemTags → Items
ALTER TABLE ItemTags
DROP FOREIGN KEY ItemTags_ibfk_1;

ALTER TABLE ItemTags
ADD CONSTRAINT ItemTags_ibfk_1
    FOREIGN KEY (ItemID)
    REFERENCES Items(ItemID)
    ON DELETE CASCADE;

-- 3) OrderItems → Items
ALTER TABLE OrderItems
DROP FOREIGN KEY OrderItems_ibfk_1;

ALTER TABLE OrderItems
ADD CONSTRAINT OrderItems_ibfk_1
    FOREIGN KEY (ItemID)
    REFERENCES Items(ItemID)
    ON DELETE CASCADE;

-- 4) Reports → Items
ALTER TABLE Reports
DROP FOREIGN KEY Reports_ibfk_3;

ALTER TABLE Reports
ADD CONSTRAINT Reports_ibfk_3
    FOREIGN KEY (ReportedItem)
    REFERENCES Items(ItemID)
    ON DELETE CASCADE;


DELETE FROM Items
WHERE
    -- Duplicate items
    EXISTS (
        SELECT 1
        FROM (
            SELECT * FROM Items
        ) AS i1
        WHERE i1.Title = Items.Title
          AND i1.OwnerID = Items.OwnerID
          AND i1.ItemID < Items.ItemID
          AND i1.IsAvailable = 1
          AND Items.IsAvailable = 1
    )
    OR
    -- Spam or highly reported items
    Items.ItemID IN (
        SELECT ReportedItem
        FROM Reports
        WHERE ReportedItem IS NOT NULL AND Resolved = 0
        GROUP BY ReportedItem
        HAVING COUNT(*) >= 2 OR MAX(Severity) >= 4
    );
-- Resolve all reports for removed items
UPDATE Reports
SET Resolved = 1,
    ResolverID = 4,
    ResolvedAt = NOW()
WHERE ReportedItem NOT IN (SELECT ItemID FROM Items)
  AND Resolved = 0;
