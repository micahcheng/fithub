DROP DATABASE IF EXISTS fithub;
CREATE DATABASE fithub;
USE fithub;


-- USERS TABLE
CREATE TABLE Users (
UserID INT AUTO_INCREMENT PRIMARY KEY,
Name VARCHAR(100) NOT NULL,
Email VARCHAR(255) NOT NULL UNIQUE,
Phone VARCHAR(20) NOT NULL,
Address VARCHAR(255) NOT NULL,
DOB DATE NOT NULL,
Gender VARCHAR(20) NOT NULL,
IsActive BOOLEAN NOT NULL,
Role VARCHAR(100) NOT NULL
);


-- ANNOUNCEMENTS
CREATE TABLE Announcements (
AnnouncementID INT AUTO_INCREMENT PRIMARY KEY,
AnnouncerID INT NOT NULL,
Message TEXT NOT NULL,
AnnouncedAt DATETIME NOT NULL,
FOREIGN KEY (AnnouncerID) REFERENCES Users(UserID)
);


CREATE TABLE AnnouncementsReceived (
AnnouncementID INT NOT NULL,
UserID INT NOT NULL,
PRIMARY KEY (AnnouncementID, UserID),
FOREIGN KEY (AnnouncementID) REFERENCES Announcements(AnnouncementID),
FOREIGN KEY (UserID) REFERENCES Users(UserID)
);


-- ITEMS
CREATE TABLE Items (
ItemID INT AUTO_INCREMENT PRIMARY KEY,
Title VARCHAR(255) NOT NULL,
Category VARCHAR(100) NOT NULL,
Description TEXT NOT NULL,
Size VARCHAR(10) NOT NULL,
`Condition` VARCHAR(100) NOT NULL,
IsAvailable BOOLEAN NOT NULL,
OwnerID INT NOT NULL,
ListedAt DATETIME NOT NULL,
`Type` VARCHAR(10) NOT NULL,
FOREIGN KEY (OwnerID) REFERENCES Users(UserID)
);


-- REPORTS
CREATE TABLE Reports (
ReportID INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
Note TEXT NOT NULL,
Severity INT NOT NULL,
Resolved BOOLEAN NOT NULL,
ReporterID INT NOT NULL,
ReportedUser INT NULL,
ReportedItem INT NULL,
ResolverID INT NULL,
ResolvedAt DATETIME NULL,
FOREIGN KEY (ReporterID) REFERENCES Users(UserID),
FOREIGN KEY (ReportedUser) REFERENCES Users(UserID),
FOREIGN KEY (ReportedItem) REFERENCES Items(ItemID),
FOREIGN KEY (ResolverID) REFERENCES Users(UserID)
);


-- IMAGES
CREATE TABLE Images (
ImageID INT AUTO_INCREMENT PRIMARY KEY,
ItemID INT NOT NULL,
ImageURL TEXT NOT NULL,
ImageOrderNum INT NOT NULL,
FOREIGN KEY (ItemID) REFERENCES Items(ItemID)
);


-- TAGS
CREATE TABLE Tags (
TagID INT AUTO_INCREMENT PRIMARY KEY,
Title VARCHAR(100) NOT NULL
);


CREATE TABLE ItemTags (
ItemID INT NOT NULL,
TagID INT NOT NULL,
PRIMARY KEY (ItemID, TagID),
FOREIGN KEY (ItemID) REFERENCES Items(ItemID),
FOREIGN KEY (TagID) REFERENCES Tags(TagID)
);

-- SHIPPING
CREATE TABLE Shippings (
ShippingID INT AUTO_INCREMENT PRIMARY KEY,
Carrier VARCHAR(100) NOT NULL,
TrackingNum VARCHAR(255) NOT NULL,
DateShipped DATE NOT NULL,
DateArrived DATE NULL
);


-- ORDERS
CREATE TABLE Orders (
OrderID INT AUTO_INCREMENT PRIMARY KEY,
GivenByID INT NOT NULL,
ReceiverID INT NOT NULL,
CreatedAt DATETIME NOT NULL,
ShippingID INT NULL,
FOREIGN KEY (GivenByID) REFERENCES Users(UserID),
FOREIGN KEY (ReceiverID) REFERENCES Users(UserID),
FOREIGN KEY (ShippingID) REFERENCES Shippings(ShippingID)
);


CREATE TABLE OrderItems (
OrderID INT NOT NULL,
ItemID INT NOT NULL,
PRIMARY KEY (OrderID, ItemID),
FOREIGN KEY (ItemID) REFERENCES Items(ItemID),
FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);


-- FEEDBACK
CREATE TABLE Feedback (
FeedbackID INT AUTO_INCREMENT PRIMARY KEY,
OrderID INT NOT NULL,
Rating INT NOT NULL,
Comment TEXT NOT NULL,
CreatedAt DATETIME NOT NULL,
CreatedByID INT NOT NULL,
FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
FOREIGN KEY (CreatedByID) REFERENCES Users(UserID),
CHECK (Rating BETWEEN 1 AND 5)
);


INSERT INTO Users (Name, Email, Phone, Address, DOB, Gender, IsActive, Role)
VALUES
('Lena Park', 'lena@example.com', '5551112222','12 Willow Lane, Brooklyn, NY','1998-06-15','Female',1,'User'),
('Marcus Lee','marcus@example.com','5552223333','89 Cedar St, Seattle, WA','1995-03-02','Male',1,'Analyst'),
('Jade Alvarez','jade@example.com','5553334444','301 Sunset Blvd, Los Angeles, CA','2000-11-20','Female',1,'User'),
('Michael Dunkin','dunkindonutes@gmail.com','4928482938','3958 Sailing Ave, Pittsburgh, PA','1996-05-29','Male',1,'Admin'),
('Test Moderator','mod@test.com','5559998888','123 Test Ln','1990-01-01','Other',1,'Analyst'),
('Spam Bot','spam@bot.com','0000000000','Unknown','2000-01-01','N/A',0,'User'),
('Alex Chen','alex@example.com','5554445555','456 Oak Ave, San Francisco, CA','1997-08-12','Male',1,'User'),
('Samira Patel','samira@example.com','5555556666','789 Pine St, Austin, TX','1999-04-25','Female',1,'User'),
('Jordan Kim','jordan@example.com','5556667777','321 Elm Dr, Portland, OR','1994-11-08','Non-binary',1,'User');





INSERT INTO Announcements (AnnouncerID, Message, AnnouncedAt)
VALUES
-- System announcements (sent to all users via AnnouncementsReceived)
(1,'Welcome to FitHub! List your pre-loved fits and swap with the community.','2025-02-01 09:00:00'),
(2,'Pro tip: Use aesthetic tags like Y2K, Coquette, or Streetwear.','2025-02-02 15:30:00'),
(3,'Weekend challenge: Swap at least one item and leave feedback for your partner.','2025-02-03 18:45:00'),
(4,'Maintenance scheduled for tomorrow at 2 PM.','2025-02-10 10:00:00'),
-- Direct messages (recipients tracked in AnnouncementsReceived)
(1,'Hey! When can you ship the jeans? I can send mine out tomorrow.','2025-02-13 14:30:00'),
(2,'I can ship them today! What''s your tracking number?','2025-02-13 15:00:00'),
(7,'Love the denim jacket! Can we swap for my Nike Air Force 1?','2025-02-13 16:20:00'),
(8,'Absolutely! They look great. Let''s do it!','2025-02-13 16:45:00'),
(9,'The track pants arrived! They fit perfectly, thanks!','2025-02-16 10:15:00');


-- ANNOUNCEMENTS RECEIVED DATA (Direct messages between users)
INSERT INTO AnnouncementsReceived (AnnouncementID, UserID)
VALUES
-- System announcements (sent to all users)
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7), (1, 8), (1, 9),
(2, 1), (2, 2), (2, 3), (2, 4), (2, 5), (2, 6), (2, 7), (2, 8), (2, 9),
(3, 1), (3, 2), (3, 3), (3, 4), (3, 5), (3, 6), (3, 7), (3, 8), (3, 9),
(4, 1), (4, 2), (4, 3), (4, 4), (4, 5), (4, 6), (4, 7), (4, 8), (4, 9),
-- Direct messages: User 1 to User 2
(5, 2),
-- Direct messages: User 2 to User 1
(6, 1),
-- Direct messages: User 7 to User 8
(7, 8),
-- Direct messages: User 8 to User 7
(8, 7),
-- Direct messages: User 9 to User 7
(9, 7);




INSERT INTO Items (Title, Category, Description, Size, `Type`, `Condition`, IsAvailable, OwnerID, ListedAt)
VALUES
('Brandy Melville Baby Tee','t-shirt','y2k white baby tee...', 'S','Swap','Very good',0,1,'2025-02-04 11:00:00'),
('Levi''s 501 Straight Jeans','jeans','vintage light wash...', 'M','Swap','Good',0,2,'2025-02-04 13:20:00'),
('Zara Oversized Hoodie','hoodie','charcoal gray oversized...', 'L','Take','Excellent',0,3,'2025-02-05 10:15:00'),
('American Eagle Maxi Skirt','skirt','boho floral maxi skirt...', 'M','Take','Good',0,1,'2025-02-05 16:40:00'),
('Nike Air Force 1','shoes','Classic white sneakers, barely worn', '9','Swap','Excellent',0,7,'2025-02-12 10:00:00'),
('Vintage Denim Jacket','jacket','90s denim jacket with patches', 'M','Swap','Good',0,8,'2025-02-12 11:30:00'),
('Adidas Track Pants','pants','Black track pants, comfortable fit', 'L','Swap','Very good',0,9,'2025-02-12 14:20:00'),
('H&M Crop Top','t-shirt','Pink crop top, perfect for summer', 'S','Swap','Excellent',0,7,'2025-02-13 09:15:00'),
('Converse Chuck Taylor','shoes','Red high tops, some wear', '8','Take','Good',1,8,'2025-02-13 16:45:00'),
('Vintage Band Tee','t-shirt','Nirvana concert tee from 90s', 'M','Swap','Good',0,9,'2025-02-14 10:30:00'),
('Leather Moto Jacket','jacket','Black leather jacket, slightly worn', 'L','Swap','Very good',0,7,'2025-02-14 13:00:00'),
('Floral Midi Dress','dress','Spring floral pattern, never worn', 'M','Swap','Excellent',0,8,'2025-02-15 11:20:00');




INSERT INTO Reports (Note, Severity, Resolved, ReporterID, ReportedItem)
VALUES
('Small stain near hem...',1,1,2,1),
('Jeans arrived more faded...',2,0,3,2),
('Hoodie had a loose thread...',1,1,1,3),
('Admin flagged due to inappropriate content.',5,0,4,2),
('Duplicate listing issue.',2,0,2,1);



INSERT INTO Images (ItemID, ImageURL, ImageOrderNum)
VALUES
(1,'https://example.com/tee.jpg',1),
(2,'https://example.com/jeans.jpg',1),
(3,'https://example.com/hoodie.jpg',1),
(4,'https://example.com/skirt.jpg',1),
(5,'https://example.com/nike-af1.jpg',1),
(6,'https://example.com/denim-jacket.jpg',1),
(7,'https://example.com/track-pants.jpg',1),
(8,'https://example.com/crop-top.jpg',1),
(9,'https://example.com/converse.jpg',1),
(10,'https://example.com/nirvana-tee.jpg',1),
(11,'https://example.com/leather-jacket.jpg',1),
(12,'https://example.com/floral-dress.jpg',1);


-- TAGS DATA
INSERT INTO Tags (Title)
VALUES
('Y2K'),
('Vintage'),
('Clean Girl'),
('Streetwear'),
('Coquette'),
('Basic'),
('Grunge'),
('Athletic'),
('Casual'),
('Formal');


-- ITEMTAGS DATA
INSERT INTO ItemTags (ItemID, TagID)
VALUES
(1, 1), (1, 5),
(2, 2), (2, 4),
(3, 4), (3, 6),
(4, 1), (4, 3),
(5, 4), (5, 6), (5, 8),
(6, 2), (6, 4),
(7, 4), (7, 8), (7, 9),
(8, 1), (8, 5),
(9, 2), (9, 4),
(10, 2), (10, 7),
(11, 2), (11, 4),
(12, 3), (12, 5);


-- SHIPPING DATA
INSERT INTO Shippings (Carrier, TrackingNum, DateShipped, DateArrived)
VALUES
('USPS', 'USPS9400111899223000000001', '2025-02-06', '2025-02-08'),
('UPS',  '1ZSWAP000000000001',        '2025-02-06', '2025-02-09'),
('FedEx','FEDEXTRADE123456789',       '2025-02-07', '2025-02-09'),
('USPS', 'USPS9400111899223000000002', '2025-02-13', '2025-02-15'),
('UPS',  '1ZSWAP000000000002',        '2025-02-14', NULL),
('FedEx','FEDEXTRADE123456790',       '2025-02-15', NULL),
('USPS', 'USPS9400111899223000000003', '2025-02-16', NULL);


-- ORDERS DATA
INSERT INTO Orders (GivenByID, ReceiverID, CreatedAt, ShippingID)
VALUES
(2, 1, '2025-02-06 12:00:00', 1),
(1, 3, '2025-02-06 14:30:00', 2),
(3, 2, '2025-02-07 09:45:00', 3),
(3, 1, '2025-02-11 13:30:00', NULL),
(7, 8, '2025-02-13 10:30:00', 4),
(8, 9, '2025-02-14 15:00:00', 5),
(9, 7, '2025-02-15 11:20:00', 6),
(1, 8, '2025-02-16 09:45:00', 7);


-- ORDERITEMS DATA
INSERT INTO OrderItems (OrderID, ItemID)
VALUES
(1, 2),
(2, 1),
(3, 3),
(4, 1),
(5, 5), (5, 6),
(6, 7), (6, 8),
(7, 10), (7, 11),
(8, 1), (8, 12);


-- FEEDBACK DATA
INSERT INTO Feedback (OrderID, Rating, Comment, CreatedAt, CreatedByID)
VALUES
(1, 5, 'Jeans fit perfectly.', '2025-02-09 18:00:00', 1),
(2, 4, 'Baby tee very cute.', '2025-02-10 11:20:00', 3),
(3, 5, 'Hoodie is insanely soft.', '2025-02-10 20:45:00', 2),
(4, 2, 'Helpful seller, quick responses.', '2025-02-12 09:30:00', 1),
(5, 5, 'Great swap! Sneakers are exactly as described.', '2025-02-16 14:00:00', 8),
(5, 4, 'Denim jacket is awesome, thanks!', '2025-02-16 15:30:00', 7);