USE elevatelabs;  // uses elevatelabs
CREATE TABLE Users (      //starts defination of new table named users
    user_id INT AUTO_INCREMENT PRIMARY KEY, // auto_incremented and uses user_id as primary key
    full_name VARCHAR(100) NOT NULL, // full_name should not be null
    email VARCHAR(100) UNIQUE NOT NULL, // must be unique
    password VARCHAR(100) NOT NULL, //password stores text (up to 100 chars).Important security note: in production you should store a hashed password, not plaintext.
    join_date DATE  //stores calendar date, it can be null
);

//inserting values into users table
INSERT INTO Users (full_name, email, password, join_date) VALUES
('Amit Sharma', 'amit@example.com', 'amit123', '2024-01-15'),
('Priya Verma', 'priya@example.com', 'priya123', '2024-03-12'),
('Rahul Singh', 'rahul@example.com', 'rahul123', '2024-05-20');

SELECT * FROM Users;  //selects user table

CREATE TABLE Mobiles (  //start defination of the Mobiles Tables
    mobile_id INT AUTO_INCREMENT PRIMARY KEY,  //unique ID for each mobile, auto incremented
    user_id INT, //integer column intended to link to Users.user_id (foreign key). It can be NULL if left unspecified.
    device_name VARCHAR(100) NOT NULL, //required human-readable device name/model.
    os_type VARCHAR(50),                 -- e.g., Android, iOS
    os_version VARCHAR(50), //
    FOREIGN KEY (user_id) REFERENCES Users(user_id)  //creates a foreign key constraint: user_id in Mobiles must match an existing user_id in Users (or be NULL if allowed).
       ON DELETE CASCADE //if the referenced Users row is deleted, any Mobiles rows referencing that user are automatically deleted too (keeps referential integrity).
);

// inserting values into Mobiles table
INSERT INTO Mobiles (user_id, device_name, os_type, os_version) VALUES
(1, 'Samsung Galaxy S22', 'Android', '13.0'),
(1, 'iPad Air', 'iOS', '16.0'),
(2, 'iPhone 14', 'iOS', '16.5'),
(3, 'OnePlus 10 Pro', 'Android', '13.1'),
(3, 'Redmi Note 12', 'Android', '13.0');
SELECT * FROM Mobiles; // retrive data from mobiles table

CREATE TABLE Subscriptions (  //starts defination of subscriptions table
    sub_id INT AUTO_INCREMENT PRIMARY KEY, // primary key, auto incremented subscription id
    user_id INT, //foreign key defined below. Can be NULL if not provided.
    plan_name VARCHAR(50) NOT NULL,  //subscription name required.
    start_date DATE NOT NULL, // subscription start date is required.
    end_date DATE, //subscription end date, nullable
    status VARCHAR(20) DEFAULT 'Active',   //status column; default value is 'Active' when not specified.
    FOREIGN KEY (user_id) REFERENCES Users(user_id) //enforces referential integrity with Users.
        ON DELETE CASCADE   //deleting a Users row automatically deletes related Subscriptions.
);

//inserting values into subscription table
INSERT INTO Subscriptions (user_id, plan_name, start_date, end_date, status) VALUES
(1, 'Premium', '2024-01-15', '2025-01-15', 'Active'),
(2, 'Super',   '2024-03-12', '2025-03-12', 'Active'),
(3, 'Premium', '2024-05-20', '2024-11-20', 'Expired');
SELECT * FROM Subscriptions;  //returns all rows from subscriptions.

CREATE VIEW UserSubscriptionSummary AS   //Creates a view (a saved, reusable virtual table) named UserSubscriptionSummary. A view stores the SELECT query; querying the view runs the query. Views help reuse complex logic and can be used to restrict columns for security.
SELECT    //begins the projection: which columns/expressions the view will return.
    u.user_id,   //Select the user_id column from the Users table (aliased as u). This identifies the user.
    u.full_name,  //Select the user’s full name.
    u.email,  //Select the user’s email (this view exposes email — be mindful of privacy/security).
    COUNT(m.mobile_id) AS total_devices,  //COUNT(...) is an aggregate that counts non-NULL m.mobile_id values for each group. The result is aliased total_devices.
    s.plan_name, //Select the subscription plan name from Subscriptions (alias s). Because you group by subscription columns (see GROUP BY), this view will show one row per user + subscription combination (not strictly one row per user).
    s.status,  //The subscription status (e.g., Active, Expired).
    s.start_date,  //Subscription start date.
    s.end_date  //Subscription end date.
FROM Users u  //Users is the driving table, aliased as u. Starting point for the joins.
LEFT JOIN Mobiles m     //Left-join Mobiles (alias m) to include mobile info. LEFT JOIN means all users are kept; if a user has no mobiles then m.* columns are NULL.
    ON u.user_id = m.user_id   //Join condition: match Users.user_id to Mobiles.user_id.
LEFT JOIN Subscriptions s   //Left-join Subscriptions (alias s) so users without subscriptions still appear (with subscription columns NULL).
    ON u.user_id = s.user_id   //Join condition: match Users.user_id to Subscriptions.user_id.
GROUP BY   //GROUP BY u.user_id, u.full_name, u.email, s.plan_name, s.status, s.start_date, s.end_date
    u.user_id, u.full_name, u.email, 
    s.plan_name, s.status, s.start_date, s.end_date  //Because you used COUNT(...) (an aggregate), you must group by every non-aggregated column selected. This grouping produces one aggregated row per unique combination of the grouped columns — in practice that means one row per user per subscription.
HAVING COUNT(m.mobile_id) >= 0;   //HAVING is like WHERE but operates after aggregation. It filters groups.
                                  //COUNT(m.mobile_id) >= 0 is always true (count is 0 or positive), so this specific HAVING is redundant and has no effect. Perhaps it was added as a placeholder. If you wanted to only keep users with at least one device you’d use HAVING COUNT(m.mobile_id) > 0. If you wanted to remove rows with no subscription you’d use WHERE s.user_id IS NOT NULL (before grouping) or a HAVING condition on s.plan_name.

SELECT * FROM UserSubscriptionSummary;  //SELECT * FROM UserSubscriptionSummary; — query the view; the DB executes the underlying SELECT and returns the results.



CREATE VIEW PublicUserView AS  //Creates another view named PublicUserView. This view is intended to expose only non-sensitive, public-facing columns.
SELECT //Selects only the user's full name and subscription info — email and password are intentionally omitted (helps with abstraction/security).
    u.full_name,  
    s.plan_name,
    s.status
FROM Users u  //users are the base table.
LEFT JOIN Subscriptions s  //Left join ensures every user appears even if they don’t have a subscription (subscription columns will be NULL for those users).
    ON u.user_id = s.user_id;  //This view still returns a row per subscription per user if there are multiple subscriptions. If you want only the latest subscription per user, you’d need to add logic (e.g., join on a subquery that finds the latest start_date per user).

SELECT * FROM PublicUserView;  //returns rows from the PublicUserView (executing its SELECT).




