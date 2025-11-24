USE fithub;


SELECT
   i.ItemID, i.Title, i.Category, i.Description, i.Size, i.Condition, u.Name as OwnerName,
   GROUP_CONCAT(t.Title SEPARATOR ', ') as Tags,
   i.ListedAt
FROM Items i
JOIN Users u ON i.OwnerID = u.UserID
LEFT JOIN ItemTags it ON i.ItemID = it.ItemID
LEFT JOIN Tags t ON it.TagID = t.TagID
WHERE i.IsAvailable = 1
GROUP BY i.ItemID, i.Title, i.Category, i.Description, i.Size, i.Condition, u.Name, i.ListedAt
ORDER BY i.ListedAt DESC;


-- 4.2) As a Taker, I want to see listing that are labeled as up for grabs and filter by size, condition, and tags, so I can find items that suit me
SELECT
   i.itemID, i.title, i.category, i.description, i.size, i.condition,u.name as ownerName,
   GROUP_CONCAT(t.Title SEPARATOR ', ') as Tags,
   i.ListedAt


FROM Items i
JOIN Users u ON i.OwnerID = u.UserID
LEFT JOIN ItemTags it ON i.ItemID = it.ItemID
LEFT JOIN Tags t ON it.TagID = t.TagID
WHERE i.IsAvailable = 1
 AND i.size = 'M'
 AND i.condition IN ('Excellent', 'Very good')
 AND (t.Title IN ('Vintage', 'Y2K', 'Basic') OR t.Title IS NULL)
GROUP BY i.itemID, i.title, i.category, i.description, i.size, i.Condition, u.name, i.ListedAt
ORDER BY i.ListedAt DESC;


-- 4.3) As a Taker, I want to be able to cancel take requests that I changed my mind on.
DELETE from OrderItems
Where OrderID = 1
   And OrderID IN (
       SELECT OrderID
       From Orders
       Where ReceiverID = 3
           AND ShippingID IS NULL
   );


-- 4.4) As a taker, I want to receive notifications when a new item that matches my order history styles and sizes is posted as a 'take', so I can quickly request popular items
SELECT
   i.ItemID, i.Title, i.Category, i.Size,u.Name as OwnerName
FROM Items i
JOIN Users u ON i.OwnerID = u.UserID
WHERE i.IsAvailable = 1
 AND i.ListedAt >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
 AND i.Size = 'M'
ORDER BY i.ListedAt DESC;


-- 4.5) As a taker, I want to be able to track the status of my incoming package
SELECT
   o.OrderID, i.Title, o.CreatedAt as RequestDate, s.Carrier, s.TrackingNum, s.DateShipped, s.DateArrived
FROM Orders o
JOIN OrderItems oi ON o.OrderID = oi.OrderID
JOIN Items i ON oi.ItemID = i.ItemID
LEFT JOIN Shippings s ON o.ShippingID = s.ShippingID
WHERE o.ReceiverID = 3
ORDER BY o.CreatedAt DESC;


-- 4.6) As a taker, I would want to be able to message the users so we can coordinate about the skipped times
INSERT INTO Announcements(AnnouncerID, Message, AnnouncedAt)
VALUES (3, 'Where is the most convenient pickup location for you?', NOW());
