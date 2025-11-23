-- Swapper CRUD Queries
USE fithub;

-- 1. As a Swapper, I want to be able to upload clothing items as listings and list them as for a swap or a take.
INSERT INTO Items (Title, Category, Description, Size, `Type`, `Condition`, IsAvailable, OwnerID, ListedAt)
VALUES ('Nike Air Force 1', 'shoes', 'Classic white sneakers, barely worn', '9', 'Swap', 'Excellent', 1, 1, NOW());

INSERT INTO ItemTags (ItemID, TagID)
SELECT LAST_INSERT_ID(), TagID FROM Tags WHERE Title IN ('Streetwear', 'Basic');


-- 2. As a Swapper, I want to exchange my clothes by requesting to swap in exchange for one of my pieces.
SET @MyItemID = 5;
SET @TheirItemID = 2;
SET @MyUserID = 1;
SET @TheirUserID = 2;

INSERT INTO Orders (GivenByID, ReceiverID, CreatedAt, ShippingID)
VALUES (@MyUserID, @TheirUserID, NOW(), NULL);

INSERT INTO OrderItems (OrderID, ItemID)
VALUES (LAST_INSERT_ID(), @MyItemID), (LAST_INSERT_ID(), @TheirItemID);

UPDATE Items SET IsAvailable = 0 WHERE ItemID IN (@MyItemID, @TheirItemID);


-- 3. As a Swapper, I want to filter clothes listed as available for swap and filter by size, condition, style, and tags.
SET @SizeFilter = 'M';
SET @ConditionFilter = 'Good';
SET @TagFilter = 'Vintage';

SELECT DISTINCT i.ItemID, i.Title, i.Category, i.Description, i.Size, i.`Condition`, i.`Type`, u.Name AS OwnerName
FROM Items i
INNER JOIN Users u ON i.OwnerID = u.UserID
LEFT JOIN ItemTags it ON i.ItemID = it.ItemID
LEFT JOIN Tags t ON it.TagID = t.TagID
WHERE i.IsAvailable = 1
  AND i.`Type` = 'Swap'
  AND i.Size = @SizeFilter
  AND i.`Condition` = @ConditionFilter
  AND t.Title = @TagFilter;


-- 4. As a Swapper, I want to be able to cancel a swap and have my swapped clothing become available again.
SET @OrderIDToCancel = 1;
SET @MyUserID = 1;

UPDATE Items i
INNER JOIN OrderItems oi ON i.ItemID = oi.ItemID
SET i.IsAvailable = 1
WHERE oi.OrderID = @OrderIDToCancel
  AND i.OwnerID = @MyUserID;

-- Delete related records first (due to foreign key constraints)
DELETE FROM Feedback WHERE OrderID = @OrderIDToCancel;
DELETE FROM OrderItems WHERE OrderID = @OrderIDToCancel;
DELETE FROM Orders WHERE OrderID = @OrderIDToCancel AND (GivenByID = @MyUserID OR ReceiverID = @MyUserID);


-- 5. As a Swapper, I want to be able to track the status of my sending and receiving packages of my swap.
SET @MyUserID = 1;

SELECT 
    o.OrderID,
    CASE 
        WHEN o.GivenByID = @MyUserID THEN 'Sending'
        WHEN o.ReceiverID = @MyUserID THEN 'Receiving'
    END AS SwapDirection,
    s.Carrier,
    s.TrackingNum,
    s.DateShipped,
    s.DateArrived,
    CASE 
        WHEN s.DateArrived IS NOT NULL THEN 'Delivered'
        WHEN s.DateShipped IS NOT NULL THEN 'In Transit'
        ELSE 'Pending'
    END AS Status
FROM Orders o
LEFT JOIN Shippings s ON o.ShippingID = s.ShippingID
WHERE o.GivenByID = @MyUserID OR o.ReceiverID = @MyUserID
ORDER BY o.CreatedAt DESC;


-- 6. As a Swapper, I would want to be able to message other users so we can coordinate about the swapped items.
-- Send a message to another user (AnnouncementsReceived tracks the recipient)
SET @MyUserID = 1;
SET @OtherUserID = 2;
SET @MessageText = 'Hey! When can you ship the jeans? I can send mine out tomorrow.';

INSERT INTO Announcements (AnnouncerID, Message, AnnouncedAt)
VALUES (@MyUserID, @MessageText, NOW());

INSERT INTO AnnouncementsReceived (AnnouncementID, UserID)
VALUES (LAST_INSERT_ID(), @OtherUserID);

-- View messages between me and another user
SET @MyUserID = 1;
SET @OtherUserID = 2;

SELECT 
    a.AnnouncementID,
    a.AnnouncerID AS SenderID,
    u.Name AS SenderName,
    a.Message,
    a.AnnouncedAt AS SentAt,
    CASE 
        WHEN a.AnnouncerID = @MyUserID THEN 'Sent'
        ELSE 'Received'
    END AS MessageType
FROM Announcements a
INNER JOIN AnnouncementsReceived ar ON a.AnnouncementID = ar.AnnouncementID
INNER JOIN Users u ON a.AnnouncerID = u.UserID
WHERE (a.AnnouncerID = @MyUserID AND ar.UserID = @OtherUserID)
   OR (a.AnnouncerID = @OtherUserID AND ar.UserID = @MyUserID)
ORDER BY a.AnnouncedAt DESC;

