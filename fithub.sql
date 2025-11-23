DROP DATABASE IF EXISTS fithub;
CREATE DATABASE fithub;
USE fithub;

CREATE TABLE Users (
                      UserID      INT AUTO_INCREMENT PRIMARY KEY,
                      Name        VARCHAR(100) NOT NULL,
                      Email       VARCHAR(255) NOT NULL UNIQUE,
                      Phone       VARCHAR(20) NOT NULL,
                      Address     VARCHAR(255) NOT NULL,
                      DOB         DATE NOT NULL,
                      Gender      VARCHAR(20) NOT NULL,
                      IsActive    BOOLEAN NOT NULL
);

CREATE TABLE Announcements (
                               AnnouncementID INT AUTO_INCREMENT PRIMARY KEY,
                               AnnouncerID    INT NOT NULL,
                               Message        TEXT NOT NULL,
                               AnnouncedAt    DATETIME NOT NULL,
                               FOREIGN KEY (AnnouncerID) REFERENCES Users(UserID)
);

CREATE TABLE AnnouncementsReceived (
                                       AnnouncementID INT NOT NULL,
                                       UserID         INT NOT NULL,
                                       PRIMARY KEY (AnnouncementID, UserID),
                                       FOREIGN KEY (AnnouncementID) REFERENCES Announcements(AnnouncementID),
                                       FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

CREATE TABLE Items (
                       ItemID       INT AUTO_INCREMENT PRIMARY KEY,
                       Title        VARCHAR(255) NOT NULL,
                       Category     VARCHAR(100) NOT NULL,
                       Description  TEXT NOT NULL,
                       Size         VARCHAR(10) NOT NULL,
                       `Condition`  VARCHAR(100) NOT NULL,
                       IsAvailable  BOOLEAN NOT NULL,
                       OwnerID      INT NOT NULL,
                       ListedAt     DATETIME NOT NULL,
                       Type         VARCHAR(10) NOT NULL,
                       FOREIGN KEY (OwnerID) REFERENCES Users(UserID)
);

CREATE TABLE Reports (
                         ReportID     INT AUTO_INCREMENT PRIMARY KEY,
                         Note         TEXT NOT NULL,
                         Severity     INT NOT NULL,
                         Resolved     BOOLEAN NOT NULL,
                         ReporterID   INT NOT NULL,
                         ReportedUser INT NULL,
                         ReportedItem INT NULL,
                         ResolverID   INT NULL,
                         FOREIGN KEY (ReporterID) REFERENCES Users(UserID),
                         FOREIGN KEY (ReportedUser) REFERENCES Users(UserID),
                         FOREIGN KEY (ReportedItem) REFERENCES Items(ItemID),
                         FOREIGN KEY (ResolverID) REFERENCES Users(UserID)
);

CREATE TABLE Images (
                        ImageID        INT AUTO_INCREMENT PRIMARY KEY,
                        ItemID         INT NOT NULL,
                        ImageURL       TEXT NOT NULL,
                        ImageOrderNum  INT NOT NULL,
                        FOREIGN KEY (ItemID) REFERENCES Items(ItemID)
);

CREATE TABLE Tags (
                      TagID     INT AUTO_INCREMENT PRIMARY KEY,
                      Title     VARCHAR(100) NOT NULL
);

CREATE TABLE ItemTags (
                          ItemID INT NOT NULL,
                          TagID  INT NOT NULL,
                          PRIMARY KEY (ItemID, TagID),
                          FOREIGN KEY (ItemID) REFERENCES Items(ItemID),
                          FOREIGN KEY (TagID) REFERENCES Tags(TagID)
);

CREATE TABLE Shippings (
                           ShippingID   INT AUTO_INCREMENT PRIMARY KEY,
                           Carrier      VARCHAR(100) NOT NULL,
                           TrackingNum  VARCHAR(255) NOT NULL,
                           DateShipped  DATE NOT NULL,
                           DateArrived  DATE NULL
);

CREATE TABLE Orders (
                        OrderID    INT AUTO_INCREMENT PRIMARY KEY,
                        GivenByID  INT NOT NULL,
                        ReceiverID INT NOT NULL,
                        CreatedAt  DATETIME NOT NULL,
                        ShippingID INT NULL,
                        FOREIGN KEY (GivenByID)   REFERENCES Users(UserID),
                        FOREIGN KEY (ReceiverID)  REFERENCES Users(UserID),
                        FOREIGN KEY (ShippingID)  REFERENCES Shippings(ShippingID)
);

CREATE TABLE OrderItems (
                            OrderID INT NOT NULL,
                            ItemID  INT NOT NULL,
                            PRIMARY KEY (OrderID, ItemID),
                            FOREIGN KEY (ItemID) REFERENCES Items(ItemID),
                            FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

CREATE TABLE Feedback (
                          FeedbackID  INT AUTO_INCREMENT PRIMARY KEY,
                          OrderID     INT NOT NULL,
                          Rating      INT NOT NULL,
                          Comment     TEXT NOT NULL,
                          CreatedAt   DATETIME NOT NULL,
                          CreatedByID INT NOT NULL,
                          FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
                          FOREIGN KEY (CreatedByID) REFERENCES Users(UserID),
                          CHECK (Rating BETWEEN 1 AND 5)
);

-- Users
INSERT INTO Users(Name, Email, Phone, Address, DOB, Gender, IsActive)
VALUES('Lena Park',    'lena@example.com',    '5551112222','12 Willow Lane, Brooklyn, NY', '1998-06-15', 'Female', 1),
      ('Marcus Lee',   'marcus@example.com',  '5552223333','89 Cedar St, Seattle, WA',    '1995-03-02', 'Male',   1),
      ('Jade Alvarez', 'jade@example.com',    '5553334444','301 Sunset Blvd, Los Angeles, CA', '2000-11-20', 'Female', 1);

-- Announcements
INSERT INTO Announcements(AnnouncerID, Message, AnnouncedAt)
VALUES (1, 'Welcome to FitHub! List your pre-loved fits and swap with the community.', '2025-02-01 09:00:00'),
       (2, 'Pro tip: Use aesthetic tags like Y2K, Coquette, or Streetwear so people can find your vibe.', '2025-02-02 15:30:00'),
       (3, 'Weekend challenge: Swap at least one item and leave feedback for your partner.', '2025-02-03 18:45:00');

-- Items
INSERT INTO Items(Title, Category, Description, Size, Type, `Condition`, IsAvailable, OwnerID, ListedAt)
VALUES('Brandy Melville Baby Tee', 't-shirt','y2k white baby tee with tiny blue graphic, super cropped and super cute', 'S', 'Swap', 'Very good', 1, 1, '2025-02-04 11:00:00'),
      ('Levi''s 501 Straight Jeans', 'jeans', 'vintage light wash levi''s 501 straight leg, perfect everyday denim','M', 'Swap', 'Good', 1, 2, '2025-02-04 13:20:00'),
      ('Zara Oversized Hoodie', 'hoodie','charcoal gray oversized hoodie, cozy streetwear essential, fleece inside','L', 'Take', 'Excellent', 1, 3, '2025-02-05 10:15:00'),
      ('American Eagle Maxi Skirt', 'skirt','boho floral maxi skirt, soft fabric, elastic waist, very flowy', 'M', 'Take', 'Good', 0, 1, '2025-02-05 16:40:00');

-- Reports
INSERT INTO Reports(note, severity, resolved, ReporterID, ReportedItem)
VALUES
    ('Small stain near hem that wasn''t mentioned, still wearable though.', 1, 1, 2, 1),
    ('Jeans arrived slightly more faded than pictured but still cute.', 2, 0, 3, 2),
    ('Hoodie had a loose thread on cuff, not a big deal.', 1, 1, 1, 3);

-- Images
INSERT INTO Images(ItemID, ImageURL, ImageOrderNum)
VALUES
    (1, 'https://example.com/images/brandy_baby_tee_front.jpg', 1),
    (2, 'https://example.com/images/levis_501_full.jpg',        1),
    (3, 'https://example.com/images/zara_hoodie_flatlay.jpg',   1),
    (4, 'https://example.com/images/ae_maxi_skirt_hanger.jpg',  1);

-- Tags
INSERT INTO Tags(Title)
VALUES
    ('Y2K'),
    ('Vintage'),
    ('Clean Girl'),
    ('Streetwear'),
    ('Coquette'),
    ('Basic');

-- ItemTags
INSERT INTO ItemTags(ItemID, TagID)
VALUES
    (1, 1), (1, 5),
    (2, 2), (2, 4),
    (3, 4), (3, 6),
    (4, 1), (4, 3);

-- Shippings
INSERT INTO Shippings(Carrier, TrackingNum, DateShipped, DateArrived)
VALUES
    ('USPS', 'USPS9400111899223000000001', '2025-02-06', '2025-02-08'),
    ('UPS',  '1ZSWAP000000000001',        '2025-02-06', '2025-02-09'),
    ('FedEx','FEDEXTRADE123456789',       '2025-02-07', '2025-02-09');

-- Orders
INSERT INTO Orders(GivenByID, ReceiverID, CreatedAt, ShippingID)
VALUES
    (2, 1, '2025-02-06 12:00:00', 1),
    (1, 3, '2025-02-06 14:30:00', 2),
    (3, 2, '2025-02-07 09:45:00', 3);

-- OrderItems
INSERT INTO OrderItems(OrderID, ItemID)
VALUES
    (1, 2),
    (2, 1),
    (3, 3);

-- Feedback
INSERT INTO Feedback(OrderID, Rating, Comment, CreatedAt, CreatedByID)
VALUES
    (1, 5, 'Jeans fit perfectly, exactly the vintage vibe I wanted. Would swap again!', '2025-02-09 18:00:00', 1),
    (2, 4, 'Baby tee is so cute and very Y2K. Slightly more cropped than expected but still love it.', '2025-02-10 11:20:00', 3),
    (3, 5, 'Hoodie is insanely soft, looks just like photos. Great communication too.', '2025-02-10 20:45:00', 2);