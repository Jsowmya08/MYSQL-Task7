USE elevatelabs;
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(100) NOT NULL,
    join_date DATE  
);
INSERT INTO Users (full_name, email, password, join_date) VALUES
('Amit Sharma', 'amit@example.com', 'amit123', '2024-01-15'),
('Priya Verma', 'priya@example.com', 'priya123', '2024-03-12'),
('Rahul Singh', 'rahul@example.com', 'rahul123', '2024-05-20');

SELECT * FROM Users;
CREATE TABLE Mobiles (
    mobile_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    device_name VARCHAR(100) NOT NULL,
    os_type VARCHAR(50),                 -- e.g., Android, iOS
    os_version VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
       ON DELETE CASCADE
);
INSERT INTO Mobiles (user_id, device_name, os_type, os_version) VALUES
(1, 'Samsung Galaxy S22', 'Android', '13.0'),
(1, 'iPad Air', 'iOS', '16.0'),
(2, 'iPhone 14', 'iOS', '16.5'),
(3, 'OnePlus 10 Pro', 'Android', '13.1'),
(3, 'Redmi Note 12', 'Android', '13.0');
SELECT * FROM Mobiles;

CREATE TABLE Subscriptions (
    sub_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    plan_name VARCHAR(50) NOT NULL,      --  Super, Premium
    start_date DATE NOT NULL,
    end_date DATE,
    status VARCHAR(20) DEFAULT 'Active', -- Active / Expired / Cancelled
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
        ON DELETE CASCADE
);
INSERT INTO Subscriptions (user_id, plan_name, start_date, end_date, status) VALUES
(1, 'Premium', '2024-01-15', '2025-01-15', 'Active'),
(2, 'Super',   '2024-03-12', '2025-03-12', 'Active'),
(3, 'Premium', '2024-05-20', '2024-11-20', 'Expired');
SELECT * FROM Subscriptions;

CREATE VIEW UserSubscriptionSummary AS
SELECT 
    u.user_id,
    u.full_name,
    u.email,
    COUNT(m.mobile_id) AS total_devices,
    s.plan_name,
    s.status,
    s.start_date,
    s.end_date
FROM Users u
LEFT JOIN Mobiles m 
    ON u.user_id = m.user_id
LEFT JOIN Subscriptions s
    ON u.user_id = s.user_id
GROUP BY 
    u.user_id, u.full_name, u.email, 
    s.plan_name, s.status, s.start_date, s.end_date
HAVING COUNT(m.mobile_id) >= 0;

SELECT * FROM UserSubscriptionSummary;


CREATE VIEW PublicUserView AS
SELECT 
    u.full_name,
    s.plan_name,
    s.status
FROM Users u
LEFT JOIN Subscriptions s
    ON u.user_id = s.user_id;
    
   SELECT * FROM PublicUserView;

