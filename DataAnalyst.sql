-- Data Analyst CRUD Queries
-- 1. As a Senior Data Analyst, I want to view available listings with their posting dates,
so I can monitor listing performance.
SELECT
    ItemID,ListedAt, COUNT(*) OVER () AS TotalAvailable
FROM Items
WHERE IsAvailable = 1;


-- 2. As a Senior Data Analyst, I want to see user counts by age and gender, so I can identify growth
-- opportunities.
SET @GenderInput = 'Female';
SET @AgeMinInput = 18;
SET @AgeMaxInput = 30;

SELECT
    UserID,
    Gender,
    DATE_FORMAT(FROM_DAYS(DATEDIFF(CURDATE(), DOB)), '%Y') + 0 AS Age
FROM Users
WHERE Gender = @GenderInput
  AND (DATE_FORMAT(FROM_DAYS(DATEDIFF(CURDATE(), DOB)), '%Y') + 0)
    BETWEEN @AgeMinInput AND @AgeMaxInput;


-- 3. As a Senior Data Analyst, I want to count how many
-- listings are in each category(pants, shirts, tanks) so I can find what users need more of.
SELECT
    Category,
    COUNT(ItemID) AS AvailableListings
FROM Items
WHERE IsAvailable = 1
GROUP BY Category;


-- 4. As a Senior Data Analyst, I want to track swaps and takes per user, so I can measure engagement.
SELECT
    u.UserID,
    COUNT(o_received.OrderID) AS OrdersReceived,
    COUNT(o_given.OrderID) AS OrdersGiven
FROM `Users` u
         LEFT JOIN Orders o_received
                   ON u.UserID = o_received.ReceiverID
         LEFT JOIN Orders o_given
                   ON u.UserID = o_given.GivenByID
GROUP BY u.UserID;


-- 5. As a Senior Data Analyst, I want to track reported items by severity, so I can spot patterns.
SELECT
    r.Severity,
    r.ReportedItem AS ItemID,
    COUNT(r.ReportID) AS NumberOfReports
FROM Reports r
GROUP BY r.Severity, r.ReportedItem
ORDER BY r.Severity, NumberOfReports DESC;

-- 6. As a Senior Data Analyst, I want to see shipments with above-average delivery times
-- (excluding those still in transit), so I can flag carriers with delays.
SELECT
    s.ShippingID,
    s.DateShipped,
    s.DateArrived,
    DATEDIFF(s.DateArrived, s.DateShipped) AS DeliveryTime
FROM Shippings s
WHERE s.DateArrived IS NOT NULL
  AND DATEDIFF(s.DateArrived, s.DateShipped) > (
    SELECT AVG(DATEDIFF(DateArrived, DateShipped))
    FROM Shippings
    WHERE DateArrived IS NOT NULL
);


