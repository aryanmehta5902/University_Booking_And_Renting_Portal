DROP DATABASE if exists dbms_project;

create database if not exists dbms_project;
use dbms_project;


drop table if exists user_roombooking;
create table user_roombooking(
user_id varchar(10) PRIMARY KEY,
username varchar(100) UNIQUE,
password VARCHAR(100) NOT NULL,
firstname VARCHAR(100) NOT NULL,
lastname varchar(100) NOT NULL,
email varchar(150) UNIQUE,
phone_no VARCHAR(10) NOT NULL,
address_street_no INT NOT NULL,
address_street_name VARCHAR(255) NOT NULL,
address_city VARCHAR(100) NOT NULL,
address_state VARCHAR(100) NOT NULL,
address_country VARCHAR(100) NOT NULL,
penalty_received double,
user_role enum ('Staff','Student','Faculty','Admin') Not Null
);


DELIMITER $$
drop trigger if exists before_insert_user_id$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER before_insert_user_id
BEFORE INSERT ON user_roombooking
FOR EACH ROW
BEGIN
    DECLARE max_code INT;
    SELECT CAST(SUBSTRING_INDEX(MAX(user_id), 'NU', -1) AS UNSIGNED) INTO max_code FROM user_roombooking;

    IF max_code IS NULL THEN
        SET NEW.user_id = 'NU00001';
    ELSE
        SET NEW.user_id = CONCAT('NU', LPAD(max_code + 1, 5, '0'));
    END IF;
END$$

DELIMITER ;


DELIMITER $$
drop trigger if exists before_insert_username_email_check$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER before_insert_username_email_check
BEFORE INSERT ON user_roombooking
FOR EACH ROW
BEGIN
    -- Check if the username already exists
    IF EXISTS (SELECT 1 FROM user_roombooking WHERE username = NEW.username) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Username already exists. Please choose a different username.';
    END IF;

    -- Check if the email already exists
    IF EXISTS (SELECT 1 FROM user_roombooking WHERE email = NEW.email) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email already exists. Please use a different email address.';
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER before_update_username_email_check
BEFORE UPDATE ON user_roombooking
FOR EACH ROW
BEGIN
    -- Check if the new username already exists in another record
    IF EXISTS (
        SELECT 1 
        FROM user_roombooking 
        WHERE username = NEW.username AND user_id != OLD.user_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Username already exists. Please choose a different username.';
    END IF;

    -- Check if the new email already exists in another record
    IF EXISTS (
        SELECT 1 
        FROM user_roombooking 
        WHERE email = NEW.email AND user_id != OLD.user_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email already exists. Please use a different email address.';
    END IF;
END$$

DELIMITER ;

drop table if exists building;
CREATE TABLE building (
    building_id varchar(4) PRIMARY KEY, 
    department_name VARCHAR(255) NOT NULL,      
    no_of_floors INT NOT NULL,                  
    no_of_rooms INT NOT NULL
);

DELIMITER $$
DROP TRIGGER if exists before_insert_building_id$$
DELIMETER;

DELIMITER $$

CREATE TRIGGER before_insert_building_id
BEFORE INSERT ON building
FOR EACH ROW
BEGIN
    DECLARE max_code INT;
    DECLARE dept_exists INT;

    -- Check if the department_name already exists
    SELECT COUNT(*) INTO dept_exists 
    FROM building 
    WHERE department_name = NEW.department_name;

    IF dept_exists > 0 THEN
        -- If the department_name exists, raise an error
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'The department_name already exists. Insertion is not allowed.';
    END IF;

    -- Extract numeric part from the building_id (after 'B'), and convert it to an integer
    SELECT CAST(SUBSTRING(MAX(building_id), 2) AS UNSIGNED) INTO max_code FROM building;

    IF max_code IS NULL THEN
        -- If no records exist, set the first building_id to 'B001'
        SET NEW.building_id = 'B001';
    ELSE
        -- If there are existing records, increment the last number of the building_id
        SET NEW.building_id = CONCAT('B', LPAD(max_code + 1, 3, '0'));
    END IF;
END$$

DELIMITER ;

drop table if exists room;
CREATE TABLE room (
    room_id VARCHAR(4) PRIMARY KEY,
    room_no INT NOT NULL,
    capacity INT NOT NULL,
    room_type ENUM('Study Room', 'Meeting Room', 'Computer Lab') NOT NULL,
    availability_status BOOLEAN NOT NULL DEFAULT TRUE,
    building_id VARCHAR(4),
    CONSTRAINT building_fk1 FOREIGN KEY (building_id)
        REFERENCES building (building_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

DELIMITER $$
DROP trigger if exists before_insert_room_id$$
DELIMITER;

DELIMITER $$

CREATE TRIGGER before_insert_room_id
BEFORE INSERT ON room
FOR EACH ROW
BEGIN
    DECLARE max_code INT;
    DECLARE valid_building INT;
    DECLARE duplicate_room INT;

    -- Step 1: Check if the building_id is valid (exists in the building table)
    SELECT COUNT(*) INTO valid_building 
    FROM building 
    WHERE building_id = NEW.building_id;
    
    IF valid_building = 0 THEN
        -- If the building_id doesn't exist in the building table, raise an error
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid building_id. Please enter a valid building ID.';
    END IF;

    -- Step 2: Check if the room_no already exists in the same building
    SELECT COUNT(*) INTO duplicate_room 
    FROM room 
    WHERE room_no = NEW.room_no 
      AND building_id = NEW.building_id;

    IF duplicate_room > 0 THEN
        -- If a duplicate room_no exists in the same building, raise an error
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Duplicate room_no detected for the given building_id. Room insertion not allowed.';
    END IF;

    -- Step 3: Generate the room_id dynamically
    SELECT CAST(SUBSTRING(MAX(room_id), 2) AS UNSIGNED) INTO max_code 
    FROM room;

    IF max_code IS NULL THEN
        -- If no records exist, set the first room_id to 'R001'
        SET NEW.room_id = 'R001';
    ELSE
        -- If there are existing records, increment the last number of the room_id
        SET NEW.room_id = CONCAT('R', LPAD(max_code + 1, 3, '0'));
    END IF;

    -- Step 4: Increment the no_of_rooms in the building table
    UPDATE building 
    SET no_of_rooms = no_of_rooms + 1 
    WHERE building_id = NEW.building_id;
END$$

DELIMITER ;

-- CALL insert_into_table(
--     'room',
--     'room_no, capacity, room_type, building_id',
--     '102, 10, "Meeting Room", "B004"'
-- );


CREATE TABLE room_schedule (
    day_of_week ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday') NOT NULL,
    open_time TIME NOT NULL,
    close_time TIME NOT NULL,
    room_id VARCHAR(4),
    CONSTRAINT room_fk1 FOREIGN KEY (room_id)
        REFERENCES room (room_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

DELIMITER $$
DROP trigger if exists before_insert_room_schedule$$
DELIMITER;

DELIMITER $$

CREATE TRIGGER before_insert_room_schedule
BEFORE INSERT ON room_schedule
FOR EACH ROW
BEGIN
    DECLARE valid_room INT;

    -- Check if the room_id exists in the room table
    SELECT COUNT(*) INTO valid_room FROM room WHERE room_id = NEW.room_id;

    IF valid_room = 0 THEN
        -- If room_id does not exist in the room table, raise an error
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid room_id. Please enter a valid room_id.';
    END IF;
END$$

DELIMITER ;

DELIMITER $$
-- Drop existing trigger if exists
DROP TRIGGER IF EXISTS after_insert_room$$
DELIMITER ;


DELIMITER $$

-- AFTER INSERT trigger on room table to insert random schedules into room_schedule
CREATE TRIGGER after_insert_room
AFTER INSERT ON room
FOR EACH ROW
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE random_open_time TIME;
    DECLARE random_close_time TIME;
    DECLARE open_hour INT;
    DECLARE close_hour INT;

    -- Insert random schedules for the new room for each day of the week
    WHILE i <= 7 DO
        -- Generate random opening time between 8 AM and 3 PM (using hours 8 to 15)
        SET open_hour = FLOOR(RAND() * 8) + 8;  -- Random hour between 8 and 15
        SET random_open_time = SEC_TO_TIME(open_hour * 3600);  -- Convert hour to TIME format

        -- Generate random closing time between 9 AM and 4 PM (using hours 9 to 16)
        SET close_hour = open_hour + FLOOR(RAND() * (16 - open_hour)) + 1; -- Closing time after open time, between open_hour + 1 and 16
        SET random_close_time = SEC_TO_TIME(close_hour * 3600);  -- Convert hour to TIME format

        -- Insert the generated schedule into room_schedule table
        INSERT INTO room_schedule (day_of_week, open_time, close_time, room_id)
        VALUES (
            CASE i
                WHEN 1 THEN 'Monday'
                WHEN 2 THEN 'Tuesday'
                WHEN 3 THEN 'Wednesday'
                WHEN 4 THEN 'Thursday'
                WHEN 5 THEN 'Friday'
                WHEN 6 THEN 'Saturday'
                WHEN 7 THEN 'Sunday'
            END,
            random_open_time,
            random_close_time,
            NEW.room_id
        );

        SET i = i + 1; -- Increment the counter
    END WHILE;
END$$

DELIMITER ;




drop table if exists feedback;
CREATE TABLE feedback (
    feedback_id INT AUTO_INCREMENT PRIMARY KEY,
    user_comment TEXT,
    user_id VARCHAR(10),
    CONSTRAINT user_fk1 FOREIGN KEY (user_id)
        REFERENCES user_roombooking (user_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

DELIMITER $$

-- Ensure the combination of user_id and user_comment is unique
CREATE TRIGGER before_insert_feedback
BEFORE INSERT ON feedback
FOR EACH ROW
BEGIN
    DECLARE duplicate_count INT;

    -- Check for duplicate user_id and user_comment
    SELECT COUNT(*) INTO duplicate_count
    FROM feedback
    WHERE user_id = NEW.user_id AND user_comment = NEW.user_comment;

    IF duplicate_count > 0 THEN
        -- If duplicate exists, raise an error
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Duplicate feedback entry: the same user_id and user_comment already exist.';
    END IF;
END$$

DELIMITER ;

drop table if exists feedback_room;
CREATE TABLE feedback_room (
    feedback_id INT,
    room_id VARCHAR(4),
    PRIMARY KEY (feedback_id , room_id),
    CONSTRAINT fk_feedback FOREIGN KEY (feedback_id)
        REFERENCES feedback (feedback_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_room FOREIGN KEY (room_id)
        REFERENCES room (room_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);


drop table if exists payment;
CREATE TABLE payment (
    payment_id VARCHAR(6) PRIMARY KEY,
    amount INT NOT NULL,
    payment_date DATE NOT NULL,
    payment_method TEXT NOT NULL
);


DELIMITER $$
drop trigger if exists before_insert_payment_id$$
DELIMITER;

DELIMITER $$
CREATE TRIGGER before_insert_payment_id
BEFORE INSERT ON payment
FOR EACH ROW
BEGIN
    DECLARE max_code INT;
    SELECT CAST(SUBSTRING(MAX(payment_id), 2) AS UNSIGNED) INTO max_code FROM payment;

    IF max_code IS NULL THEN
        SET NEW.payment_id = 'P00001';
    ELSE
        SET NEW.payment_id = CONCAT('P', LPAD(max_code + 1, 5, '0'));
    END IF;
END$$

DELIMITER ;


drop table if exists resources;

CREATE TABLE resources (
    resource_id VARCHAR(10) PRIMARY KEY,
    resource_name VARCHAR(255) NOT NULL,
    availability_status BOOLEAN NOT NULL,
    quantity_required INT NOT NULL
);

drop table if exists resources_details;
CREATE TABLE resources_details (
    resource_id VARCHAR(10) PRIMARY KEY,
    brand VARCHAR(255),
    device_type VARCHAR(255),
    model_number VARCHAR(50),
    device_condition VARCHAR(50),
    warranty_status BOOLEAN,
    date_purchased DATE,
    author VARCHAR(255),
    description VARCHAR(1000),
    language VARCHAR(50),
    hardware_flag BOOLEAN NOT NULL DEFAULT FALSE,
    books_flag BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT resources_deatils_fk FOREIGN KEY (resource_id)
        REFERENCES resources (resource_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

drop table if exists resources_feedback;
CREATE TABLE resources_feedback (
    resource_id VARCHAR(10),
    feedback_id INT,
    PRIMARY KEY (resource_id , feedback_id),
    CONSTRAINT fk1_feedback FOREIGN KEY (feedback_id)
        REFERENCES feedback (feedback_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT resources_fk1 FOREIGN KEY (resource_id)
        REFERENCES resources (resource_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

drop table if exists room_user;
CREATE TABLE room_user (
    start_time TIME,
    end_time TIME,
    reservation_date DATE,
    reservation_status BOOLEAN,
    user_id VARCHAR(10),
    room_id VARCHAR(10),
    CONSTRAINT fk_room1 FOREIGN KEY (room_id)
        REFERENCES room (room_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT user_fk2 FOREIGN KEY (user_id)
        REFERENCES user_roombooking (user_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);



CREATE TABLE room_policy (
    policy_id INT AUTO_INCREMENT PRIMARY KEY,
    policy_text TEXT
);

drop table if exists rents;
CREATE TABLE rents (
    reservation_date DATE,
    return_date DATE,
    resource_id VARCHAR(10) NOT NULL,
    payment_id VARCHAR(6) NOT NULL,
    user_id VARCHAR(10) NOT NULL,
    PRIMARY KEY (resource_id , payment_id , user_id),
    CONSTRAINT user_fk4 FOREIGN KEY (user_id)
        REFERENCES user_roombooking (user_id)
        ON UPDATE CASCADE,
    CONSTRAINT resource_fk1 FOREIGN KEY (resource_id)
        REFERENCES resources (resource_id)
        ON UPDATE CASCADE,
    CONSTRAINT payment_fk1 FOREIGN KEY (payment_id)
        REFERENCES payment (payment_id)
        ON UPDATE CASCADE
);



DELIMITER $$
Drop procedure if exists insert_resource_details$$
DELIMITER;

DELIMITER $$

CREATE PROCEDURE insert_resource_details(
    IN p_resource_name VARCHAR(255),
    IN p_availability_status BOOLEAN,
    IN p_quantity_required INT,
    IN p_resource_type ENUM('hardware', 'books'),
    IN p_device_type VARCHAR(255),
    IN p_model_number VARCHAR(50),
    IN p_device_condition VARCHAR(50),
    IN p_warranty_status BOOLEAN,
    IN p_date_purchased DATE,
    IN p_author VARCHAR(255),
    IN p_description VARCHAR(1000),
    IN p_language VARCHAR(50)
)
BEGIN
    DECLARE new_resource_id VARCHAR(10);

    -- Generate resource_id
    SET new_resource_id = CONCAT('RES', LPAD(COALESCE((SELECT COUNT(*) + 1 FROM resources), 1), 7, '0'));

    -- Insert into the resources table
    INSERT INTO resources (resource_id, resource_name, availability_status, quantity_required)
    VALUES (new_resource_id, p_resource_name, p_availability_status, p_quantity_required);

    -- Insert a placeholder row into resources_details
    INSERT INTO resources_details (resource_id)
    VALUES (new_resource_id);

    -- Update the resources_details table based on resource_type
    IF p_resource_type = 'hardware' THEN
        UPDATE resources_details
        SET brand = p_resource_name, 
            device_type = p_device_type, 
            model_number = p_model_number, 
            device_condition = p_device_condition, 
            warranty_status = p_warranty_status, 
            date_purchased = p_date_purchased, 
            hardware_flag = TRUE
        WHERE resource_id = new_resource_id;
    ELSEIF p_resource_type = 'books' THEN
        UPDATE resources_details
        SET author = p_author, 
            description = p_description,
            language = p_language, 
            books_flag = TRUE
        WHERE resource_id = new_resource_id;
    END IF;
END $$

DELIMITER ;

DELIMITER $$
Drop procedure if exists get_all_resources$$
DELIMITER;

DELIMITER $$

CREATE PROCEDURE get_all_resources()
BEGIN
    SELECT 
        r.resource_id,
        r.resource_name,
        r.availability_status,
        r.quantity_required,
        CASE
            WHEN rd.hardware_flag THEN 'hardware'
            WHEN rd.books_flag THEN 'books'
            ELSE 'unknown'
        END AS resource_type,
        -- Fields specific to hardware
        rd.device_type,
        rd.model_number,
        rd.device_condition,
        rd.warranty_status,
        rd.date_purchased,
        -- Fields specific to books
        rd.author,
        rd.description,
        rd.language
    FROM 
        resources r
    LEFT JOIN 
        resources_details rd
    ON 
        r.resource_id = rd.resource_id;
END $$

DELIMITER ;


DELIMITER $$
drop procedure if exists insert_into_table$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE insert_into_table(
    IN table_name VARCHAR(255),
    IN columns VARCHAR(255),
    IN valuess VARCHAR(255)
)
BEGIN
    SET @insert_query = CONCAT('INSERT INTO ', table_name, ' (', columns, ') VALUES (', valuess, ');');

    -- Prepare and execute the dynamic SQL
    PREPARE stmt FROM @insert_query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END $$

DELIMITER ;

-- CALL insert_generic('room', 'room_id, room_no, capacity, room_type, availability_status, building_id', 
--  "'R001', 221, 4, 'Study Room', 1, 'B001'");


DELIMITER $$
drop procedure if exists update_table$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE update_table(
    IN table_name VARCHAR(255),
    IN columns VARCHAR(255),
    IN valuess VARCHAR(255),
    IN conditionn VARCHAR(255)
)
BEGIN
    -- Declare variables to hold the dynamic SQL parts
    DECLARE column_value_pairs TEXT DEFAULT '';
    DECLARE i INT DEFAULT 1;
    DECLARE column_part VARCHAR(255);
    DECLARE value_part VARCHAR(255);

    -- Loop through columns and values and build the SET clause
    WHILE i <= LENGTH(columns) - LENGTH(REPLACE(columns, ',', '')) + 1 DO
        SET column_part = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(columns, ',', i), ',', -1));
        SET value_part = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(valuess, ',', i), ',', -1));
        SET column_value_pairs = CONCAT(column_value_pairs, column_part, ' = ', value_part);
        
        -- If not the last pair, add a comma to separate
        IF i < LENGTH(columns) - LENGTH(REPLACE(columns, ',', '')) + 1 THEN
            SET column_value_pairs = CONCAT(column_value_pairs, ', ');
        END IF;
        
        SET i = i + 1;
    END WHILE;

    -- Create the dynamic update query
    SET @update_query = CONCAT('UPDATE ', table_name, ' SET ', column_value_pairs, ' WHERE ', conditionn);

    -- Prepare and execute the dynamic SQL
    PREPARE stmt FROM @update_query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END $$

DELIMITER ;

-- CALL update_table(
--     'room', 
--     'room_no, capacity', 
--     '322, 5', 
--     'room_id = "R007"'
-- );


DELIMITER $$
drop procedure if exists delete_from_table$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE delete_from_table(
    IN table_name VARCHAR(255),
    IN conditionn VARCHAR(255)
)
BEGIN
    -- Create the dynamic delete query
    SET @delete_query = CONCAT('DELETE FROM ', table_name, ' WHERE ', conditionn);

    -- Prepare and execute the dynamic SQL
    PREPARE stmt FROM @delete_query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END $$

DELIMITER ;

-- call delete_from_table('resources','resource_id = "RES0000015"');


DELIMITER $$
drop procedure if exists read_from_table$$
DELIMITER ;
DELIMITER $$

CREATE PROCEDURE read_from_table(
    IN table_name VARCHAR(255),
    IN columns VARCHAR(255),
    IN conditionn VARCHAR(255)
)
BEGIN
    -- Create the dynamic select query
    SET @select_query = CONCAT('SELECT ', columns, ' FROM ', table_name, ' WHERE ', conditionn);

    -- Print the generated query for debugging
    -- SELECT @select_query AS generated_query;

    -- Prepare and execute the dynamic SQL
    PREPARE stmt FROM @select_query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END $$

DELIMITER ;

-- CALL read_from_table(
--     'room', 
--     'room_no, capacity', 
--     'room_id = "R007"'
-- );


DELIMITER $$
drop procedure if exists check_user_credentials$$
DELIMITER ;
DELIMITER $$

CREATE PROCEDURE check_user_credentials(
    IN p_email VARCHAR(150),
    IN p_password VARCHAR(100)
)
BEGIN
    DECLARE user_count INT;

    -- Check if the email exists in the user_roombooking table
    SELECT COUNT(*) INTO user_count
    FROM user_roombooking
    WHERE email = p_email AND password = p_password;

    -- If the user count is 0, the credentials are incorrect
    IF user_count = 0 THEN
        SELECT 'Invalid email or password' AS message;
    ELSE
        SELECT user_id,username,password,firstname,lastname,user_role from user_roombooking where email = p_email AND password = p_password ;
    END IF;
END $$

DELIMITER ;

-- CALL check_user_credentials('john.doe@example.com', 'passdfsword123');


DELIMITER $$
drop procedure if exists get_feedback_rooms$$
DELIMITER ;
DELIMITER $$

CREATE PROCEDURE get_feedback_rooms()
BEGIN
    SELECT 
		f.feedback_id,
        f.user_comment,
        u.username,
        r.room_no
    FROM feedback f
    JOIN user_roombooking u ON f.user_id = u.user_id
    JOIN feedback_room fr ON f.feedback_id = fr.feedback_id
    JOIN room r ON fr.room_id = r.room_id;
END $$

DELIMITER ;

-- call get_feedback_rooms();

DELIMITER $$
drop procedure if exists insert_feedback_room$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE insert_feedback_room(
    IN input_user_id VARCHAR(10),
    IN input_user_comment TEXT,
    IN input_room_id VARCHAR(10)
)
BEGIN
    DECLARE new_feedback_id INT;

    -- Use the insert_into_table procedure to insert into feedback table
    CALL insert_into_table(
        'feedback',
        'user_comment, user_id',
        CONCAT('"', input_user_comment, '", "', input_user_id, '"')
    );

    -- Get the ID of the newly inserted feedback
    SET new_feedback_id = LAST_INSERT_ID();

    -- Use the insert_into_table procedure to insert into feedback_room table
    CALL insert_into_table(
        'feedback_room',
        'feedback_id, room_id',
        CONCAT(new_feedback_id, ', "', input_room_id, '"')
    );
END $$

DELIMITER ;
-- CALL insert_feedback_room('NU00002', 'Excellent room facilities!', 'R001');


DELIMITER $$
drop procedure if exists get_feedback_resource$$
DELIMITER ;
DELIMITER $$
CREATE PROCEDURE get_feedback_resource()
BEGIN
    SELECT 
		f.feedback_id,
        f.user_comment,
        u.username,
        r.resource_name
    FROM feedback f
    JOIN user_roombooking u ON f.user_id = u.user_id
    JOIN resources_feedback fr ON f.feedback_id = fr.feedback_id
    JOIN resources r ON fr.resource_id = r.resource_id;
END $$

DELIMITER ;

-- call get_feedback_resource();


DELIMITER $$
drop procedure if exists insert_into_rents$$
DELIMITER ;

DELIMITER $$

CREATE PROCEDURE insert_into_rents (
    IN in_reservation_date DATE,
    IN in_return_date DATE,
    IN in_resource_id VARCHAR(10),
    IN in_user_id VARCHAR(10)
)
BEGIN
    DECLARE next_quarter_end DATE;
    DECLARE new_payment_id VARCHAR(6);
    DECLARE max_code INT;

    -- Get the maximum numeric part of the existing payment_id
    SELECT CAST(SUBSTRING(MAX(payment_id), 2) AS UNSIGNED) INTO max_code FROM payment;

    -- Generate a new payment_id
    IF max_code IS NULL THEN
        SET new_payment_id = 'P00001';
    ELSE
        SET new_payment_id = CONCAT('P', LPAD(max_code + 1, 5, '0'));
    END IF;

    -- Calculate the next quarter's end date
    SET next_quarter_end = 
        CASE 
            WHEN MONTH(CURDATE()) IN (1, 2, 3) THEN LAST_DAY(DATE_ADD(CURDATE(), INTERVAL 6 MONTH))
            WHEN MONTH(CURDATE()) IN (4, 5, 6) THEN LAST_DAY(DATE_ADD(CURDATE(), INTERVAL 6 MONTH))
            WHEN MONTH(CURDATE()) IN (7, 8, 9) THEN LAST_DAY(DATE_ADD(CURDATE(), INTERVAL 6 MONTH))
            WHEN MONTH(CURDATE()) IN (10, 11, 12) THEN LAST_DAY(DATE_ADD(CURDATE(), INTERVAL 6 MONTH))
        END;

    -- Insert into the payment table
    INSERT INTO payment (payment_id, amount, payment_date, payment_method)
    VALUES (new_payment_id, 5, next_quarter_end, 'student hub');

    -- Insert into the rents table using the generated payment_id
    INSERT INTO rents (reservation_date, return_date, resource_id, payment_id, user_id)
    VALUES (in_reservation_date, in_return_date, in_resource_id, new_payment_id, in_user_id);
END $$

DELIMITER ;

CALL insert_into_rents('2024-12-04','2024-12-11','RES0000001','NU00001');

DELIMITER $$
DROP PROCEDURE IF EXISTS insert_feedback_resource$$
DELIMITER ;

DELIMITER $$

CREATE PROCEDURE insert_feedback_resource(
    IN user_id VARCHAR(255),
    IN user_comment VARCHAR(255),
    IN resource_id VARCHAR(255)
)
BEGIN
    -- Insert into feedback table
    CALL insert_into_table('feedback', 'user_id, user_comment', CONCAT('\'', user_id, '\', \'', user_comment, '\''));
    SET @last_feedback_id = LAST_INSERT_ID();
    CALL insert_into_table('resources_feedback', 'feedback_id, resource_id', CONCAT(@last_feedback_id, ', \'', resource_id, '\''));
END $$

DELIMITER ;

-- CALL insert_feedback_resource('NU00003', 'Excellent resources', 'RES0000001');


DELIMITER $$
drop procedure if exists view_available_rooms$$
DELIMITER ;

DELIMITER $$

CREATE PROCEDURE view_available_rooms(
    IN user_id VARCHAR(10),
    IN start_time TIME,
    IN end_time TIME,
    IN reservation_date DATE
)
BEGIN
    -- Step 1: Remove expired reservations
    DELETE FROM room_user 
    WHERE reservation_status = TRUE
    AND reservation_date = CURRENT_DATE()
    AND end_time < CURRENT_TIME();

    -- Step 2: Select available rooms
    SELECT r.room_id, r.room_no, r.capacity, r.room_type, r.building_id
    FROM room r
    LEFT JOIN room_user ru ON r.room_id = ru.room_id
    WHERE r.room_id NOT IN (
        SELECT ru.room_id
        FROM room_user ru
        WHERE ru.reservation_date = reservation_date
          AND (
              (start_time < ru.end_time AND end_time > ru.start_time)
          )
    )
    ORDER BY r.room_no;
END $$

DELIMITER ;
-- CALL view_available_rooms('NU00003', '20:00:00', '21:00:00', '2024-12-03');


DELIMITER $$
DROP PROCEDURE IF EXISTS CheckResourceAvailability$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE CheckResourceAvailability (
    IN p_reservation_date DATE
)
BEGIN
    DECLARE is_available BOOLEAN;
    
    -- Update the availability of resources based on past return dates
    -- UPDATE resources r
--     SET r.availability_status = 1
--     WHERE r.resource_id = p_resource_id
--       AND EXISTS (
--           SELECT 1
--           FROM rents rt
--           WHERE rt.resource_id = p_resource_id
--             AND rt.return_date < CURDATE()
--       );

    -- Check if the resource is available for the given reservation date
    SELECT 
        CASE 
            WHEN r.availability_status = 1 AND 
                 NOT EXISTS (
                     SELECT 1
                     FROM rents rt
                     WHERE rt.return_date >= p_reservation_date
                 )
            THEN TRUE
            ELSE FALSE
        END INTO is_available
    FROM resources r;

    -- Raise SIGNAL based on the result
    IF is_available THEN
        select distinct r.resource_name,r.availability_status,r.quantity_required, rd.* 
        FROM resources AS r
        JOIN resources_details AS rd
        ON r.resource_id = rd.resource_id
        WHERE r.resource_id = p_resource_id;
    ELSE
        SIGNAL SQLSTATE '45000' -- Custom error
        SET MESSAGE_TEXT = 'Resource is NOT available for the given reservation date';
    END IF;
END$$

DELIMITER ;


-- CALL CheckResourceAvailability('2024-12-15', 'RES0000001');

-- CALL insert_into_table(
--     'rents',
--     'reservation_date, return_date, resource_id, payment_id, user_id',
--     '''2024-12-03'', ''2024-12-10'', ''RES0000001'', ''P00001'', ''NU00001'''
-- );



DELIMITER $$

DROP FUNCTION IF EXISTS get_user_upcoming_reservations$$

DELIMITER ;

DELIMITER $$

CREATE FUNCTION get_user_upcoming_reservations(
    p_date DATE, 
    p_time TIME, 
    p_user_id VARCHAR(50)
) 
RETURNS JSON
DETERMINISTIC
READS SQL DATA
BEGIN
    RETURN JSON_OBJECT(
        'reservations', 
        (SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
                'room_id', room_user.room_id, 
                'room_no', room.room_no, 
                'start_time', room_user.start_time, 
                'reservation_date', room_user.reservation_date
            )
        )
        FROM room_user
        JOIN room ON room_user.room_id = room.room_id
        WHERE room_user.reservation_date = p_date
        AND room_user.end_time > p_time
        AND room_user.user_id = p_user_id
        ORDER BY room_user.end_time)
    );
END $$

DELIMITER ;

-- SELECT get_user_upcoming_reservations('2024-12-13', '17:00:00', 'NU00001');

DELIMITER $$

DROP FUNCTION IF EXISTS get_user_rented_resources$$

DELIMITER ;

DELIMITER $$

DROP FUNCTION IF EXISTS get_user_rented_resources$$

DELIMITER ;

DELIMITER $$

CREATE FUNCTION get_user_rented_resources(
    p_date DATE, 
    p_user_id VARCHAR(10)
) 
RETURNS JSON
DETERMINISTIC
READS SQL DATA
BEGIN
    RETURN JSON_OBJECT(
        'rented_resources', 
        (SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
                'resource_id', rents.resource_id, 
                'resource_name', resources.resource_name,
                'return_date', rents.return_date, 
                'reservation_date', rents.reservation_date,
                'payment_id', rents.payment_id,
                'user_id', rents.user_id
            )
        )
        FROM rents
        JOIN resources ON rents.resource_id = resources.resource_id
        WHERE rents.user_id = p_user_id
        AND rents.reservation_date = p_date
        ORDER BY rents.reservation_date)
    );
END $$

DELIMITER ;

SELECT get_user_rented_resources('2024-12-03', 'NU00001');




-- Inserting data into user

CALL insert_into_table(
    'user_roombooking',
    'username, password, firstname, lastname, email, phone_no, address_street_no, address_street_name, address_city, address_state, address_country, penalty_received, user_role',
    "'johnsmith', 'pass1234', 'John', 'Smith', 'john.smith@example.com', '9876543210', 101, 'Maple Street', 'Boston', 'Massachusetts', 'USA', 0, 'Student'"
);

CALL insert_into_table(
    'user_roombooking',
    'username, password, firstname, lastname, email, phone_no, address_street_no, address_street_name, address_city, address_state, address_country, penalty_received, user_role',
    "'emilybrown', 'securepwd', 'Emily', 'Brown', 'emily.brown@example.com', '8765432109', 202, 'Elm Street', 'Cambridge', 'Massachusetts', 'USA', 15.5, 'Staff'"
);

CALL insert_into_table(
    'user_roombooking',
    'username, password, firstname, lastname, email, phone_no, address_street_no, address_street_name, address_city, address_state, address_country, penalty_received, user_role',
    "'markjones', 'password1', 'Mark', 'Jones', 'mark.jones@example.com', '7654321098', 303, 'Pine Avenue', 'Newton', 'Massachusetts', 'USA', 0, 'Faculty'"
);

CALL insert_into_table(
    'user_roombooking',
    'username, password, firstname, lastname, email, phone_no, address_street_no, address_street_name, address_city, address_state, address_country, penalty_received, user_role',
    "'sarahlee', 'qwerty123', 'Sarah', 'Lee', 'sarah.lee@example.com', '6543210987', 404, 'Oak Boulevard', 'Waltham', 'Massachusetts', 'USA', 10, 'Admin'"
);

CALL insert_into_table(
    'user_roombooking',
    'username, password, firstname, lastname, email, phone_no, address_street_no, address_street_name, address_city, address_state, address_country, penalty_received, user_role',
    "'danielmartin', 'abc12345', 'Daniel', 'Martin', 'daniel.martin@example.com', '5432109876', 505, 'Birch Lane', 'Brookline', 'Massachusetts', 'USA', 0, 'Student'"
);

CALL insert_into_table(
    'user_roombooking',
    'username, password, firstname, lastname, email, phone_no, address_street_no, address_street_name, address_city, address_state, address_country, penalty_received, user_role',
    "'lindawilson', 'linda@2023', 'Linda', 'Wilson', 'linda.wilson@example.com', '4321098765', 606, 'Cedar Drive', 'Somerville', 'Massachusetts', 'USA', 5, 'Staff'"
);

CALL insert_into_table(
    'user_roombooking',
    'username, password, firstname, lastname, email, phone_no, address_street_no, address_street_name, address_city, address_state, address_country, penalty_received, user_role',
    "'michaelgarcia', 'mike!456', 'Michael', 'Garcia', 'michael.garcia@example.com', '3210987654', 707, 'Spruce Way', 'Medford', 'Massachusetts', 'USA', 0, 'Faculty'"
);

CALL insert_into_table(
    'user_roombooking',
    'username, password, firstname, lastname, email, phone_no, address_street_no, address_street_name, address_city, address_state, address_country, penalty_received, user_role',
    "'karenwhite', 'whitepass', 'Karen', 'White', 'karen.white@example.com', '2109876543', 808, 'Aspen Circle', 'Quincy', 'Massachusetts', 'USA', 25.75, 'Admin'"
);

CALL insert_into_table(
    'user_roombooking',
    'username, password, firstname, lastname, email, phone_no, address_street_no, address_street_name, address_city, address_state, address_country, penalty_received, user_role',
    "'jamesanderson', 'james*pass', 'James', 'Anderson', 'james.anderson@example.com', '1098765432', 909, 'Hickory Row', 'Malden', 'Massachusetts', 'USA', 0, 'Student'"
);

CALL insert_into_table(
    'user_roombooking',
    'username, password, firstname, lastname, email, phone_no, address_street_no, address_street_name, address_city, address_state, address_country, penalty_received, user_role',
    "'rachelmoore', 'rachelMoore123', 'Rachel', 'Moore', 'rachel.moore@example.com', '9988776655', 110, 'Willow Grove', 'Lowell', 'Massachusetts', 'USA', 0, 'Staff'"
);

CALL insert_into_table(
    'user_roombooking',
    'username, password, firstname, lastname, email, phone_no, address_street_no, address_street_name, address_city, address_state, address_country, penalty_received, user_role',
    "'patrickclark', 'p@ssw0rd', 'Patrick', 'Clark', 'patrick.clark@example.com', '1122334455', 120, 'Cypress Court', 'Lawrence', 'Massachusetts', 'USA', 12.3, 'Faculty'"
);

CALL insert_into_table(
    'user_roombooking',
    'username, password, firstname, lastname, email, phone_no, address_street_no, address_street_name, address_city, address_state, address_country, penalty_received, user_role',
    "'angelayoung', 'angelaP@55', 'Angela', 'Young', 'angela.young@example.com', '2233445566', 130, 'Cherry Lane', 'Lynn', 'Massachusetts', 'USA', 0, 'Admin'"
);

CALL insert_into_table(
    'user_roombooking',
    'username, password, firstname, lastname, email, phone_no, address_street_no, address_street_name, address_city, address_state, address_country, penalty_received, user_role',
    "'robertharris', 'harris321', 'Robert', 'Harris', 'robert.harris@example.com', '3344556677', 140, 'Juniper Avenue', 'Haverhill', 'Massachusetts', 'USA', 0, 'Student'"
);

CALL insert_into_table(
    'user_roombooking',
    'username, password, firstname, lastname, email, phone_no, address_street_no, address_street_name, address_city, address_state, address_country, penalty_received, user_role',
    "'sophiathomas', 'sophia_secure', 'Sophia', 'Thomas', 'sophia.thomas@example.com', '4455667788', 150, 'Magnolia Path', 'Peabody', 'Massachusetts', 'USA', 8, 'Staff'"
);

CALL insert_into_table(
    'user_roombooking',
    'username, password, firstname, lastname, email, phone_no, address_street_no, address_street_name, address_city, address_state, address_country, penalty_received, user_role',
    "'williamwalker', 'will!123', 'William', 'Walker', 'william.walker@example.com', '5566778899', 160, 'Walnut Place', 'Revere', 'Massachusetts', 'USA', 0, 'Faculty'"
);

CALL insert_into_table(
    'user_roombooking',
    'username, password, firstname, lastname, email, phone_no, address_street_no, address_street_name, address_city, address_state, address_country, penalty_received, user_role',
    "'oliviahill', 'oliviaHILL', 'Olivia', 'Hill', 'olivia.hill@example.com', '6677889900', 170, 'Dogwood Trail', 'Woburn', 'Massachusetts', 'USA', 20, 'Admin'"
);

CALL insert_into_table(
    'user_roombooking',
    'username, password, firstname, lastname, email, phone_no, address_street_no, address_street_name, address_city, address_state, address_country, penalty_received, user_role',
    "'ethantaylor', 'ethanT@123', 'Ethan', 'Taylor', 'ethan.taylor@example.com', '7788990011', 180, 'Sycamore Road', 'Beverly', 'Massachusetts', 'USA', 0, 'Student'"
);

CALL insert_into_table(
    'user_roombooking',
    'username, password, firstname, lastname, email, phone_no, address_street_no, address_street_name, address_city, address_state, address_country, penalty_received, user_role',
    "'averymartinez', 'averyPASS', 'Avery', 'Martinez', 'avery.martinez@example.com', '8899001122', 190, 'Birchwood Lane', 'Fitchburg', 'Massachusetts', 'USA', 5, 'Staff'"
);

CALL insert_into_table(
    'user_roombooking',
    'username, password, firstname, lastname, email, phone_no, address_street_no, address_street_name, address_city, address_state, address_country, penalty_received, user_role',
    "'chloemorris', 'chloe$secure', 'Chloe', 'Morris', 'chloe.morris@example.com', '9900112233', 200, 'Maplewood Drive', 'Leominster', 'Massachusetts', 'USA', 0, 'Faculty'"
);

CALL insert_into_table(
    'user_roombooking',
    'username, password, firstname, lastname, email, phone_no, address_street_no, address_street_name, address_city, address_state, address_country, penalty_received, user_role',
    "'lucashernandez', 'lucasPass123', 'Lucas', 'Hernandez', 'lucas.hernandez@example.com', '1112233445', 210, 'Chestnut Grove', 'New Bedford', 'Massachusetts', 'USA', 10, 'Admin'"
);

CALL insert_into_table(
    'user_roombooking',
    'username, password, firstname, lastname, email, phone_no, address_street_no, address_street_name, address_city, address_state, address_country, penalty_received, user_role',
    "'harperking', 'harper@456', 'Harper', 'King', 'harper.king@example.com', '1223344556', 220, 'Laurel Street', 'Springfield', 'Massachusetts', 'USA', 0, 'Student'"
);

CALL insert_into_table(
    'user_roombooking',
    'username, password, firstname, lastname, email, phone_no, address_street_no, address_street_name, address_city, address_state, address_country, penalty_received, user_role',
    "'jacksonwright', 'jackson@789', 'Jackson', 'Wright', 'jackson.wright@example.com', '1334455667', 230, 'Poplar Court', 'Pittsfield', 'Massachusetts', 'USA', 15, 'Staff'"
);

CALL insert_into_table(
    'user_roombooking',
    'username, password, firstname, lastname, email, phone_no, address_street_no, address_street_name, address_city, address_state, address_country, penalty_received, user_role',
    "'ellamiller', 'ellaMILLER', 'Ella', 'Miller', 'ella.miller@example.com', '1445566778', 240, 'Cottonwood Avenue', 'Salem', 'Massachusetts', 'USA', 0, 'Faculty'"
);

CALL insert_into_table(
    'user_roombooking',
    'username, password, firstname, lastname, email, phone_no, address_street_no, address_street_name, address_city, address_state, address_country, penalty_received, user_role',
    "'scarlettturner', 'scarlett123', 'Scarlett', 'Turner', 'scarlett.turner@example.com', '1556677889', 250, 'Hawthorn Lane', 'Taunton', 'Massachusetts', 'USA', 8, 'Admin'"
);

CALL insert_into_table(
    'user_roombooking',
    'username, password, firstname, lastname, email, phone_no, address_street_no, address_street_name, address_city, address_state, address_country, penalty_received, user_role',
    "'logangomez', 'logan!pass', 'Logan', 'Gomez', 'logan.gomez@example.com', '1667788990', 260, 'Mulberry Path', 'Framingham', 'Massachusetts', 'USA', 0, 'Student'"
);

CALL insert_into_table(
    'user_roombooking',
    'username, password, firstname, lastname, email, phone_no, address_street_no, address_street_name, address_city, address_state, address_country, penalty_received, user_role',
    "'gracemurphy', 'grace@PASS', 'Grace', 'Murphy', 'grace.murphy@example.com', '1778899001', 270, 'Cypress Row', 'Chelsea', 'Massachusetts', 'USA', 20, 'Staff'"
);

CALL insert_into_table(
    'user_roombooking',
    'username, password, firstname, lastname, email, phone_no, address_street_no, address_street_name, address_city, address_state, address_country, penalty_received, user_role',
    "'alexanderscott', 'alex1234', 'Alexander', 'Scott', 'alexander.scott@example.com', '1889900112', 280, 'Aspen Trail', 'Everett', 'Massachusetts', 'USA', 0, 'Faculty'"
);

CALL insert_into_table(
    'user_roombooking',
    'username, password, firstname, lastname, email, phone_no, address_street_no, address_street_name, address_city, address_state, address_country, penalty_received, user_role',
    "'madisoncarter', 'madison!456', 'Madison', 'Carter', 'madison.carter@example.com', '1990011223', 290, 'Fir Lane', 'Marlborough', 'Massachusetts', 'USA', 5, 'Admin'"
);

CALL insert_into_table(
    'user_roombooking',
    'username, password, firstname, lastname, email, phone_no, address_street_no, address_street_name, address_city, address_state, address_country, penalty_received, user_role',
    "'josephdiaz', 'joseph!pass', 'Joseph', 'Diaz', 'joseph.diaz@example.com', '2001122334', 300, 'Linden Court', 'Braintree', 'Massachusetts', 'USA', 0, 'Student'"
);

CALL insert_into_table(
    'user_roombooking',
    'username, password, firstname, lastname, email, phone_no, address_street_no, address_street_name, address_city, address_state, address_country, penalty_received, user_role',
    "'zoerichardson', 'zoePass2024', 'Zoe', 'Richardson', 'zoe.richardson@example.com', '2112233445', 310, 'Hemlock Road', 'Gloucester', 'Massachusetts', 'USA', 12.5, 'Staff'"
);

CALL insert_into_table(
    'user_roombooking',
    'username, password, firstname, lastname, email, phone_no, address_street_no, address_street_name, address_city, address_state, address_country, penalty_received, user_role',
    "'benjamincole', 'benjamin@123', 'Benjamin', 'Cole', 'benjamin.cole@example.com', '2223344556', 320, 'Palm Avenue', 'Holyoke', 'Massachusetts', 'USA', 0, 'Faculty'"
);


-- Inserting data into buildings
CALL insert_into_table(
    'building','building_id, department_name, no_of_floors, no_of_rooms',
    "NULL, 'Cabot Physical Education Center', 5, 0"
);

CALL insert_into_table(
    'building','building_id, department_name, no_of_floors, no_of_rooms',
    "NULL, 'Dana Research Center', 7, 0"
);

CALL insert_into_table(
    'building','building_id, department_name, no_of_floors, no_of_rooms',
    "NULL, 'Snell Library', 10, 0"
);

CALL insert_into_table(
    'building','building_id, department_name, no_of_floors, no_of_rooms',
    "NULL, 'Curry Student Center', 4, 0"
);

CALL insert_into_table(
    'building','building_id, department_name, no_of_floors, no_of_rooms',
    "NULL, 'Dockser Hall', 3, 0"
);

CALL insert_into_table(
    'building','building_id, department_name, no_of_floors, no_of_rooms',
    "NULL, 'Dodge Hall', 6, 0"
);

CALL insert_into_table(
    'building','building_id, department_name, no_of_floors, no_of_rooms',
    "NULL, 'Hastings', 4, 0"
);

CALL insert_into_table(
    'building','building_id, department_name, no_of_floors, no_of_rooms',
    "NULL, 'Speare Hall', 8, 0"
);

CALL insert_into_table(
    'building','building_id, department_name, no_of_floors, no_of_rooms',
    "NULL, 'Stetson Hall', 6, 0"
);

CALL insert_into_table(
    'building','building_id, department_name, no_of_floors, no_of_rooms',
    "NULL, 'White Hall', 7, 0"
);

CALL insert_into_table(
    'building','building_id, department_name, no_of_floors, no_of_rooms',
    "NULL, 'Lake Hall', 5, 0"
);

CALL insert_into_table(
    'building','building_id, department_name, no_of_floors, no_of_rooms',
    "NULL, 'Holmes Hall', 4, 0"
);

CALL insert_into_table(
    'building','building_id, department_name, no_of_floors, no_of_rooms',
    "NULL, 'Nightingale Hall', 6, 0"
);

CALL insert_into_table(
    'building','building_id, department_name, no_of_floors, no_of_rooms',
    "NULL, 'Meserve Hall', 5, 0"
);

CALL insert_into_table(
    'building','building_id, department_name, no_of_floors, no_of_rooms',
    "NULL, 'Interdisciplinary Science and Engineering Complex (ISEC)', 10, 0"
);

CALL insert_into_table(
    'building','building_id, department_name, no_of_floors, no_of_rooms',
    "NULL, 'EXP', 3, 0"
);

CALL insert_into_table(
    'building','building_id, department_name, no_of_floors, no_of_rooms',
    "NULL, 'F. W. Olin Library', 4, 0"
);

CALL insert_into_table(
    'building','building_id, department_name, no_of_floors, no_of_rooms',
    "NULL, 'Betty Irene Moore Natural Sciences Building', 6, 0"
);

CALL insert_into_table(
    'building','building_id, department_name, no_of_floors, no_of_rooms',
    "NULL, 'West Village', 6, 0"
);



-- Procedure for dynamically inserting rooms for each building
DELIMITER $$

CREATE PROCEDURE insert_rooms_for_building(
    IN building_id_param VARCHAR(4),
    IN min_rooms INT,
    IN max_rooms INT
)
BEGIN
    DECLARE room_count INT;
    DECLARE i INT DEFAULT 1;
    DECLARE floor_no INT DEFAULT 1;

    -- Generate a random number of rooms between min_rooms and max_rooms
    SET room_count = FLOOR(RAND() * (max_rooms - min_rooms + 1)) + min_rooms;

    -- Insert rooms
    WHILE i <= room_count DO
        -- Assign room_no in sequence, grouped by floor (101, 102, etc.)
        INSERT INTO room (room_no, capacity, room_type, building_id)
        VALUES (
            floor_no * 100 + (i MOD 100),      -- room_no in order (e.g., 101, 102)
            FLOOR(RAND() * 50 + 20),           -- capacity between 20 and 70
            ELT(FLOOR(RAND() * 3) + 1,         -- random room type
                'Study Room', 'Meeting Room', 'Computer Lab'),
            building_id_param                  -- building_id
        );

        -- Move to the next room, increment floor number every 100 rooms
        SET i = i + 1;
        IF i MOD 100 = 1 THEN
            SET floor_no = floor_no + 1;
        END IF;
    END WHILE;
END$$

DELIMITER ;

CALL insert_rooms_for_building('B001', 10, 30);
CALL insert_rooms_for_building('B002', 10, 30);
CALL insert_rooms_for_building('B003', 10, 30);
CALL insert_rooms_for_building('B004', 10, 30);
CALL insert_rooms_for_building('B005', 10, 30);
CALL insert_rooms_for_building('B006', 10, 30);
CALL insert_rooms_for_building('B007', 10, 30);
CALL insert_rooms_for_building('B008', 10, 30);
CALL insert_rooms_for_building('B009', 10, 30);
CALL insert_rooms_for_building('B010', 10, 30);
CALL insert_rooms_for_building('B011', 10, 30);
CALL insert_rooms_for_building('B012', 10, 30);
CALL insert_rooms_for_building('B013', 10, 30);
CALL insert_rooms_for_building('B014', 10, 30);
CALL insert_rooms_for_building('B015', 10, 30);
CALL insert_rooms_for_building('B016', 10, 30);
CALL insert_rooms_for_building('B017', 10, 30);
CALL insert_rooms_for_building('B018', 10, 30);
CALL insert_rooms_for_building('B019', 10, 30);


-- Insert a valid room_schedule for room 'R001'
INSERT INTO room_schedule (day_of_week, open_time, close_time, room_id)
VALUES ('Monday', '09:00:00', '17:00:00', 'R001');




-- Stored Procedure for inserting Random Payments in payments table
DELIMITER $$

CREATE PROCEDURE insert_random_payments(
    IN number_of_payments INT,      -- Total number of payments to insert
    IN min_amount DECIMAL(10, 2),  -- Minimum payment amount
    IN max_amount DECIMAL(10, 2),  -- Maximum payment amount
    IN start_date DATE,            -- Start date for payment_date
    IN end_date DATE               -- End date for payment_date
)
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE random_amount DECIMAL(10, 2);
    DECLARE random_date DATE;
    DECLARE payment_methods ENUM('Credit Card', 'Cash', 'Online Transfer', 'Cheque');
    DECLARE random_method ENUM('Credit Card', 'Cash', 'Online Transfer', 'Cheque');

    WHILE i <= number_of_payments DO
        -- Generate a random payment amount
        SET random_amount = ROUND(RAND() * (max_amount - min_amount) + min_amount, 2);

        -- Generate a random payment date within the range
        SET random_date = DATE_ADD(start_date, INTERVAL FLOOR(RAND() * DATEDIFF(end_date, start_date)) DAY);

        -- Randomly pick a payment method
        SET random_method = ELT(FLOOR(RAND() * 4) + 1, 'Credit Card', 'Cash', 'Online Transfer', 'Cheque');

        -- Insert the payment record
        INSERT INTO payment (amount, payment_date, payment_method)
        VALUES (random_amount, random_date, random_method);

        -- Increment the counter
        SET i = i + 1;
    END WHILE;
END$$

DELIMITER ;

CALL insert_random_payments(
    20,                     -- Number of payments
    100,                    -- Minimum amount
    5000,                   -- Maximum amount
    '2024-11-01',           -- Start date
    '2024-11-30'            -- End date
);


-- Inserting policy data

CALL insert_into_table(
    'room_policy','policy_text',
    "'Study rooms must be booked at least 24 hours in advance and can be used for a maximum of 2 hours per session.'"
);

CALL insert_into_table(
    'room_policy','policy_text',
    "'Meeting rooms require prior approval and are limited to official university meetings only.'"
);

CALL insert_into_table(
    'room_policy','policy_text',
    "'Computer labs are for academic purposes only and require an active student ID for access.'"
);

CALL insert_into_table(
    'room_policy','policy_text',
    "'Food and beverages are not allowed in any room.'"
);

CALL insert_into_table(
    'room_policy','policy_text',
    "'Rooms must be left clean and tidy after use; violators may face penalties.'"
);



-- Inserting data into resources
-- CALL insert_resource_details('To Kill a Mockingbird', TRUE, 5, 'books', NULL, NULL, NULL, NULL, NULL, 'Harper Lee', 'J.B. Lippincott & Co.', 1960, 1, 'Fiction', 'English');
-- CALL insert_resource_details('1984', TRUE, 4, 'books', NULL, NULL, NULL, NULL, NULL, 'George Orwell', 'Secker & Warburg', 1949, 1, 'Dystopian', 'English');
-- CALL insert_resource_details('The Catcher in the Rye', TRUE, 6, 'books', NULL, NULL, NULL, NULL, NULL, 'J.D. Salinger', 'Little, Brown and Company', 1951, 1, 'Fiction', 'English');
-- CALL insert_resource_details('Pride and Prejudice', TRUE, 7, 'books', NULL, NULL, NULL, NULL, NULL, 'Jane Austen', 'Penguin Books', 1995, 3, 'Romance', 'English');
-- CALL insert_resource_details('Harry Potter and the Sorcerer\'s Stone', TRUE, 10, 'books', NULL, NULL, NULL, NULL, NULL, 'J.K. Rowling', 'Bloomsbury', 1997, 1, 'Fantasy', 'English');
-- CALL insert_resource_details('The Hobbit', TRUE, 3, 'books', NULL, NULL, NULL, NULL, NULL, 'J.R.R. Tolkien', 'George Allen & Unwin', 1937, 2, 'Fantasy', 'English');
-- CALL insert_resource_details('The Great Gatsby', TRUE, 8, 'books', NULL, NULL, NULL, NULL, NULL, 'F. Scott Fitzgerald', 'Scribner', 1925, 1, 'Fiction', 'English');
-- CALL insert_resource_details('Brave New World', TRUE, 5, 'books', NULL, NULL, NULL, NULL, NULL, 'Aldous Huxley', 'Chatto & Windus', 1932, 1, 'Science Fiction', 'English');
-- CALL insert_resource_details('Fahrenheit 451', TRUE, 3, 'books', NULL, NULL, NULL, NULL, NULL, 'Ray Bradbury', 'Ballantine Books', 1953, 1, 'Dystopian', 'English');
-- CALL insert_resource_details('Animal Farm', TRUE, 9, 'books', NULL, NULL, NULL, NULL, NULL, 'George Orwell', 'Secker & Warburg', 1945, 1, 'Satire', 'English');
-- CALL insert_resource_details('Lord of the Flies', TRUE, 4, 'books', NULL, NULL, NULL, NULL, NULL, 'William Golding', 'Faber and Faber', 1954, 1, 'Allegory', 'English');
-- CALL insert_resource_details('The Road', TRUE, 6, 'books', NULL, NULL, NULL, NULL, NULL, 'Cormac McCarthy', 'Alfred A. Knopf', 2006, 1, 'Post-Apocalyptic', 'English');
-- CALL insert_resource_details('The Handmaid\'s Tale', TRUE, 7, 'books', NULL, NULL, NULL, NULL, NULL, 'Margaret Atwood', 'McClelland and Stewart', 1985, 1, 'Dystopian', 'English');
-- CALL insert_resource_details('Life of Pi', TRUE, 8, 'books', NULL, NULL, NULL, NULL, NULL, 'Yann Martel', 'Knopf Canada', 2001, 1, 'Adventure', 'English');
-- CALL insert_resource_details('A Game of Thrones', TRUE, 10, 'books', NULL, NULL, NULL, NULL, NULL, 'George R.R. Martin', 'Bantam Spectra', 1996, 1, 'Fantasy', 'English');
-- CALL insert_resource_details('The Book Thief', TRUE, 7, 'books', NULL, NULL, NULL, NULL, NULL, 'Markus Zusak', 'Picador', 2005, 1, 'Historical Fiction', 'English');
-- CALL insert_resource_details('The Hunger Games', TRUE, 9, 'books', NULL, NULL, NULL, NULL, NULL, 'Suzanne Collins', 'Scholastic Press', 2008, 1, 'Dystopian', 'English');
-- CALL insert_resource_details('Dune', TRUE, 5, 'books', NULL, NULL, NULL, NULL, NULL, 'Frank Herbert', 'Chilton Books', 1965, 1, 'Science Fiction', 'English');
-- CALL insert_resource_details('The Kite Runner', TRUE, 6, 'books', NULL, NULL, NULL, NULL, NULL, 'Khaled Hosseini', 'Riverhead Books', 2003, 1, 'Drama', 'English');
-- CALL insert_resource_details('Percy Jackson & The Lightning Thief', TRUE, 8, 'books', NULL, NULL, NULL, NULL, NULL, 'Rick Riordan', 'Disney Hyperion', 2005, 1, 'Fantasy', 'English');

-- CALL insert_resource_details('Dell XPS 15', TRUE, 4, 'hardware', 'Laptop', 'XPS 15 9500', 'New', TRUE, '2022-05-15', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('HP LaserJet Pro', TRUE, 6, 'hardware', 'Printer', 'MFP M148fdw', 'Excellent', TRUE, '2023-03-10', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Apple MacBook Pro', TRUE, 3, 'hardware', 'Laptop', 'MacBook Pro 14"', 'New', TRUE, '2022-11-05', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Canon EOS 90D', TRUE, 2, 'hardware', 'Camera', 'EOS 90D', 'Like New', TRUE, '2022-02-20', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Samsung Galaxy Tab S8', TRUE, 5, 'hardware', 'Tablet', 'Galaxy Tab S8', 'New', TRUE, '2023-01-14', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Microsoft Surface Laptop', TRUE, 6, 'hardware', 'Laptop', 'Surface Laptop 4', 'New', TRUE, '2022-12-12', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Logitech MX Master 3', TRUE, 8, 'hardware', 'Mouse', 'MX Master 3', 'Excellent', TRUE, '2023-07-20', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Sony WH-1000XM4', TRUE, 10, 'hardware', 'Headphone', 'WH-1000XM4', 'New', TRUE, '2023-02-25', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Lenovo ThinkPad X1 Carbon', TRUE, 7, 'hardware', 'Laptop', 'ThinkPad X1', 'Good', TRUE, '2022-06-11', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Asus ROG Strix', TRUE, 3, 'hardware', 'Desktop', 'ROG Strix G15', 'New', TRUE, '2022-09-18', NULL, NULL, NULL, NULL, NULL, NULL);


-- CALL insert_resource_details('The Maze Runner', TRUE, 8, 'books', NULL, NULL, NULL, NULL, NULL, 'James Dashner', 'Delacorte Press', 2009, 1, 'Dystopian', 'English');
-- CALL insert_resource_details('Twilight', TRUE, 7, 'books', NULL, NULL, NULL, NULL, NULL, 'Stephenie Meyer', 'Little, Brown and Company', 2005, 1, 'Romance', 'English');
-- CALL insert_resource_details('Eleanor & Park', TRUE, 5, 'books', NULL, NULL, NULL, NULL, NULL, 'Rainbow Rowell', 'St. Martin\'s Press', 2013, 1, 'Romance', 'English');
-- CALL insert_resource_details('Divergent', TRUE, 9, 'books', NULL, NULL, NULL, NULL, NULL, 'Veronica Roth', 'Katherine Tegen Books', 2011, 1, 'Dystopian', 'English');
-- CALL insert_resource_details('The Fault in Our Stars', TRUE, 6, 'books', NULL, NULL, NULL, NULL, NULL, 'John Green', 'Dutton Books', 2012, 1, 'Romance', 'English');
-- CALL insert_resource_details('The Alchemist', TRUE, 8, 'books', NULL, NULL, NULL, NULL, NULL, 'Paulo Coelho', 'HarperTorch', 1988, 1, 'Adventure', 'English');
-- CALL insert_resource_details('Gone Girl', TRUE, 7, 'books', NULL, NULL, NULL, NULL, NULL, 'Gillian Flynn', 'Crown Publishing Group', 2012, 1, 'Thriller', 'English');
-- CALL insert_resource_details('The Night Circus', TRUE, 4, 'books', NULL, NULL, NULL, NULL, NULL, 'Erin Morgenstern', 'Doubleday', 2011, 1, 'Fantasy', 'English');
-- CALL insert_resource_details('The Goldfinch', TRUE, 3, 'books', NULL, NULL, NULL, NULL, NULL, 'Donna Tartt', 'Little, Brown and Company', 2013, 1, 'Fiction', 'English');
-- CALL insert_resource_details('Big Little Lies', TRUE, 9, 'books', NULL, NULL, NULL, NULL, NULL, 'Liane Moriarty', 'Penguin Books', 2014, 1, 'Mystery', 'English');
-- CALL insert_resource_details('Me Before You', TRUE, 5, 'books', NULL, NULL, NULL, NULL, NULL, 'Jojo Moyes', 'Michael Joseph', 2012, 1, 'Romance', 'English');
-- CALL insert_resource_details('The Giver of Stars', TRUE, 6, 'books', NULL, NULL, NULL, NULL, NULL, 'Jojo Moyes', 'Penguin Books', 2019, 1, 'Historical Fiction', 'English');
-- CALL insert_resource_details('Where the Crawdads Sing', TRUE, 7, 'books', NULL, NULL, NULL, NULL, NULL, 'Delia Owens', 'G.P. Putnam\'s Sons', 2018, 1, 'Mystery', 'English');
-- CALL insert_resource_details('Circe', TRUE, 3, 'books', NULL, NULL, NULL, NULL, NULL, 'Madeline Miller', 'Little, Brown and Company', 2018, 1, 'Fantasy', 'English');
-- CALL insert_resource_details('The Water Dancer', TRUE, 8, 'books', NULL, NULL, NULL, NULL, NULL, 'Ta-Nehisi Coates', 'One World', 2019, 1, 'Historical Fiction', 'English');
-- CALL insert_resource_details('Normal People', TRUE, 4, 'books', NULL, NULL, NULL, NULL, NULL, 'Sally Rooney', 'Faber and Faber', 2018, 1, 'Fiction', 'English');
-- CALL insert_resource_details('A Man Called Ove', TRUE, 6, 'books', NULL, NULL, NULL, NULL, NULL, 'Fredrik Backman', 'Atria Books', 2014, 1, 'Fiction', 'English');
-- CALL insert_resource_details('The Midnight Library', TRUE, 7, 'books', NULL, NULL, NULL, NULL, NULL, 'Matt Haig', 'Canongate Books', 2020, 1, 'Fantasy', 'English');
-- CALL insert_resource_details('It Ends with Us', TRUE, 9, 'books', NULL, NULL, NULL, NULL, NULL, 'Colleen Hoover', 'Atria Books', 2016, 1, 'Romance', 'English');
-- CALL insert_resource_details('Verity', TRUE, 5, 'books', NULL, NULL, NULL, NULL, NULL, 'Colleen Hoover', 'Grand Central Publishing', 2018, 1, 'Thriller', 'English');


-- CALL insert_resource_details('HP Pavilion 15', TRUE, 6, 'hardware', 'Laptop', 'Pavilion 15-eg0078', 'Excellent', TRUE, '2023-04-18', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Samsung Smart Monitor M8', TRUE, 4, 'hardware', 'Monitor', 'LS32BM80', 'New', TRUE, '2023-01-10', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Logitech C920 HD Pro Webcam', TRUE, 7, 'hardware', 'Webcam', 'C920 HD Pro', 'Excellent', TRUE, '2023-06-05', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('HP EliteDesk 800', TRUE, 3, 'hardware', 'Desktop', 'EliteDesk 800 G6', 'Good', TRUE, '2022-09-12', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Apple iPad Pro', TRUE, 6, 'hardware', 'Tablet', 'iPad Pro 11"', 'New', TRUE, '2022-11-07', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Dell Ultrasharp U2723QE', TRUE, 5, 'hardware', 'Monitor', 'U2723QE', 'New', TRUE, '2023-03-22', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Raspberry Pi 4 Model B', TRUE, 8, 'hardware', 'Microcomputer', 'Pi 4 B 8GB', 'Excellent', TRUE, '2023-05-14', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Corsair K95 RGB Platinum XT', TRUE, 6, 'hardware', 'Keyboard', 'K95 RGB', 'New', TRUE, '2023-01-18', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Sony A7 III', TRUE, 3, 'hardware', 'Camera', 'ILCE-7M3', 'Good', TRUE, '2023-02-20', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Microsoft Surface Pro 8', TRUE, 4, 'hardware', 'Tablet', 'Surface Pro 8', 'Excellent', TRUE, '2023-07-01', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Asus TUF Gaming F15', TRUE, 7, 'hardware', 'Laptop', 'TUF F15 FX506LH', 'Good', TRUE, '2022-12-12', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Canon PIXMA G6020', TRUE, 5, 'hardware', 'Printer', 'PIXMA G6020', 'New', TRUE, '2022-10-10', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('GoPro HERO10 Black', TRUE, 3, 'hardware', 'Action Camera', 'HERO10', 'Excellent', TRUE, '2023-06-22', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Lenovo IdeaPad Flex 5', TRUE, 4, 'hardware', 'Laptop', 'Flex 5 14ITL', 'Good', TRUE, '2023-02-15', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Samsung T7 Portable SSD', TRUE, 8, 'hardware', 'Storage', 'T7 1TB', 'New', TRUE, '2023-03-01', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Acer Predator Helios 300', TRUE, 6, 'hardware', 'Laptop', 'Helios 300 PH315', 'New', TRUE, '2022-11-20', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('HP Omen 25L', TRUE, 4, 'hardware', 'Desktop', 'Omen 25L GT12', 'Good', TRUE, '2023-01-19', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Apple Magic Trackpad', TRUE, 6, 'hardware', 'Accessory', 'Magic Trackpad 2', 'Excellent', TRUE, '2023-05-03', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('BenQ EX3501R', TRUE, 7, 'hardware', 'Monitor', 'EX3501R', 'New', TRUE, '2023-04-14', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Dell XPS 15 9520', TRUE, 5, 'hardware', 'Laptop', 'XPS 15 9520', 'New', TRUE, '2023-02-22', NULL, NULL, NULL, NULL, NULL, NULL);



-- CALL insert_resource_details('To Kill a Mockingbird', TRUE, 10, 'books', NULL, NULL, NULL, NULL, NULL, 'Harper Lee', 'J.B. Lippincott & Co.', 1960, 1, 'Fiction', 'English');
-- CALL insert_resource_details('1984', TRUE, 9, 'books', NULL, NULL, NULL, NULL, NULL, 'George Orwell', 'Secker & Warburg', 1949, 1, 'Dystopian', 'English');
-- CALL insert_resource_details('Moby-Dick', TRUE, 8, 'books', NULL, NULL, NULL, NULL, NULL, 'Herman Melville', 'Harper & Brothers', 1951, 1, 'Adventure', 'English');
-- CALL insert_resource_details('Pride and Prejudice', TRUE, 7, 'books', NULL, NULL, NULL, NULL, NULL, 'Jane Austen', 'T. Egerton', 1913, 1, 'Romance', 'English');
-- CALL insert_resource_details('The Great Gatsby', TRUE, 6, 'books', NULL, NULL, NULL, NULL, NULL, 'F. Scott Fitzgerald', 'Charles Scribner\'s Sons', 1925, 1, 'Fiction', 'English');
-- CALL insert_resource_details('The Catcher in the Rye', TRUE, 7, 'books', NULL, NULL, NULL, NULL, NULL, 'J.D. Salinger', 'Little, Brown and Company', 1951, 1, 'Fiction', 'English');
-- CALL insert_resource_details('War and Peace', TRUE, 10, 'books', NULL, NULL, NULL, NULL, NULL, 'Leo Tolstoy', 'The Russian Messenger', 1969, 1, 'Historical Fiction', 'English');
-- CALL insert_resource_details('Crime and Punishment', TRUE, 9, 'books', NULL, NULL, NULL, NULL, NULL, 'Fyodor Dostoevsky', 'The Russian Messenger', 1966, 1, 'Philosophical Fiction', 'English');
-- CALL insert_resource_details('Jane Eyre', TRUE, 8, 'books', NULL, NULL, NULL, NULL, NULL, 'Charlotte Brontë', 'Smith, Elder & Co.', 1947, 1, 'Gothic Fiction', 'English');
-- CALL insert_resource_details('The Hobbit', TRUE, 7, 'books', NULL, NULL, NULL, NULL, NULL, 'J.R.R. Tolkien', 'George Allen & Unwin', 1937, 1, 'Fantasy', 'English');
-- CALL insert_resource_details('The Lord of the Rings', TRUE, 10, 'books', NULL, NULL, NULL, NULL, NULL, 'J.R.R. Tolkien', 'George Allen & Unwin', 1954, 1, 'Fantasy', 'English');
-- CALL insert_resource_details('Brave New World', TRUE, 9, 'books', NULL, NULL, NULL, NULL, NULL, 'Aldous Huxley', 'Chatto & Windus', 1932, 1, 'Dystopian', 'English');
-- CALL insert_resource_details('Fahrenheit 451', TRUE, 8, 'books', NULL, NULL, NULL, NULL, NULL, 'Ray Bradbury', 'Ballantine Books', 1953, 1, 'Dystopian', 'English');
-- CALL insert_resource_details('Wuthering Heights', TRUE, 6, 'books', NULL, NULL, NULL, NULL, NULL, 'Emily Brontë', 'Thomas Cautley Newby', 1947, 1, 'Gothic Fiction', 'English');
-- CALL insert_resource_details('The Grapes of Wrath', TRUE, 9, 'books', NULL, NULL, NULL, NULL, NULL, 'John Steinbeck', 'The Viking Press', 1939, 1, 'Fiction', 'English');
-- CALL insert_resource_details('Frankenstein', TRUE, 7, 'books', NULL, NULL, NULL, NULL, NULL, 'Mary Shelley', 'Lackington, Hughes, Harding, Mavor & Jones', 1918, 1, 'Gothic Fiction', 'English');
-- CALL insert_resource_details('Anna Karenina', TRUE, 8, 'books', NULL, NULL, NULL, NULL, NULL, 'Leo Tolstoy', 'The Russian Messenger', 1977, 1, 'Romance', 'English');
-- CALL insert_resource_details('Les Misérables', TRUE, 10, 'books', NULL, NULL, NULL, NULL, NULL, 'Victor Hugo', 'A. Lacroix, Verboeckhoven & Cie.', 1962, 1, 'Historical Fiction', 'English');
-- CALL insert_resource_details('Dracula', TRUE, 9, 'books', NULL, NULL, NULL, NULL, NULL, 'Bram Stoker', 'Archibald Constable and Company', 1997, 1, 'Gothic Fiction', 'English');
-- CALL insert_resource_details('The Picture of Dorian Gray', TRUE, 8, 'books', NULL, NULL, NULL, NULL, NULL, 'Oscar Wilde', 'Lippincott\'s Monthly Magazine', 1990, 1, 'Philosophical Fiction', 'English');
-- CALL insert_resource_details('Don Quixote', TRUE, 10, 'books', NULL, NULL, NULL, NULL, NULL, 'Miguel de Cervantes', 'Francisco de Robles', 1905, 1, 'Adventure', 'English');
-- CALL insert_resource_details('The Odyssey', TRUE, 9, 'books', NULL, NULL, NULL, NULL, NULL, 'Homer', 'Ancient Greece', 1930, 1, 'Epic', 'English');
-- CALL insert_resource_details('The Divine Comedy', TRUE, 8, 'books', NULL, NULL, NULL, NULL, NULL, 'Dante Alighieri', 'Italy', 1920, 1, 'Epic', 'English');
-- CALL insert_resource_details('The Iliad', TRUE, 9, 'books', NULL, NULL, NULL, NULL, NULL, 'Homer', 'Ancient Greece', 1970, 1, 'Epic', 'English');
-- CALL insert_resource_details('Hamlet', TRUE, 7, 'books', NULL, NULL, NULL, NULL, NULL, 'William Shakespeare', 'England', 1903, 1, 'Tragedy', 'English');



-- CALL insert_resource_details('Apple MacBook Pro 16"', TRUE, 9, 'hardware', 'Laptop', 'MacBook Pro 16" 2021', 'Excellent', TRUE, '2023-01-01', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Lenovo ThinkPad X1 Carbon', TRUE, 8, 'hardware', 'Laptop', 'ThinkPad X1 Carbon Gen 9', 'Good', TRUE, '2023-02-14', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Dell Alienware Aurora R12', TRUE, 7, 'hardware', 'Desktop', 'Aurora R12', 'Good', TRUE, '2023-03-10', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Asus ROG Zephyrus G14', TRUE, 8, 'hardware', 'Laptop', 'Zephyrus G14', 'Excellent', TRUE, '2023-05-20', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('HP Envy 27 All-in-One', TRUE, 6, 'hardware', 'Desktop', 'Envy 27', 'Good', TRUE, '2023-06-15', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Microsoft Surface Studio 2', TRUE, 7, 'hardware', 'Desktop', 'Surface Studio 2', 'New', TRUE, '2023-07-01', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Acer Nitro 5', TRUE, 9, 'hardware', 'Laptop', 'Nitro 5 AN515', 'Good', TRUE, '2023-08-12', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Canon EOS R6', TRUE, 8, 'hardware', 'Camera', 'EOS R6', 'New', TRUE, '2023-04-10', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Nikon Z6 II', TRUE, 9, 'hardware', 'Camera', 'Z6 II', 'Excellent', TRUE, '2023-05-20', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Sony WH-1000XM4', TRUE, 10, 'hardware', 'Headphones', 'WH-1000XM4', 'New', TRUE, '2023-03-08', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('HyperX Cloud Alpha', TRUE, 8, 'hardware', 'Headphones', 'Cloud Alpha', 'Good', TRUE, '2023-01-20', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Bose QuietComfort 45', TRUE, 9, 'hardware', 'Headphones', 'QuietComfort 45', 'Excellent', TRUE, '2023-02-28', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Corsair K95 RGB Platinum', TRUE, 7, 'hardware', 'Keyboard', 'K95 RGB Platinum', 'New', TRUE, '2023-04-03', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Logitech MX Master 3S', TRUE, 9, 'hardware', 'Mouse', 'MX Master 3S', 'Good', TRUE, '2023-05-10', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Razer DeathAdder V2', TRUE, 8, 'hardware', 'Mouse', 'DeathAdder V2', 'Excellent', TRUE, '2023-06-01', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Asus ProArt Display PA32UCX', TRUE, 10, 'hardware', 'Monitor', 'ProArt Display PA32UCX', 'New', TRUE, '2023-07-10', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Samsung Smart Monitor M8', TRUE, 9, 'hardware', 'Monitor', 'Smart Monitor M8', 'Good', TRUE, '2023-08-05', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('LG UltraGear 27GP850', TRUE, 8, 'hardware', 'Monitor', 'UltraGear 27GP850', 'New', TRUE, '2023-09-01', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Dell UltraSharp U2723QE', TRUE, 7, 'hardware', 'Monitor', 'UltraSharp U2723QE', 'Excellent', TRUE, '2023-09-20', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Alienware AW3423DW', TRUE, 10, 'hardware', 'Monitor', 'AW3423DW', 'Good', TRUE, '2023-07-30', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Apple Magic Keyboard', TRUE, 8, 'hardware', 'Keyboard', 'Magic Keyboard 2', 'New', TRUE, '2023-03-05', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Samsung T7 Touch', TRUE, 9, 'hardware', 'Storage', 'T7 Touch 1TB', 'Good', TRUE, '2023-04-18', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('WD My Passport SSD', TRUE, 8, 'hardware', 'Storage', 'My Passport SSD 2TB', 'Excellent', TRUE, '2023-06-14', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Seagate One Touch SSD', TRUE, 7, 'hardware', 'Storage', 'One Touch SSD 4TB', 'Good', TRUE, '2023-08-15', NULL, NULL, NULL, NULL, NULL, NULL);
-- CALL insert_resource_details('Kingston XS2000', TRUE, 9, 'hardware', 'Storage', 'XS2000 2TB', 'Excellent', TRUE, '2023-09-20', NULL, NULL, NULL, NULL, NULL, NULL);


-- CALL insert_into_table(
--     'room_user',
--     'start_time, end_time, reservation_date, reservation_status, user_id, room_id',
--     "'09:00:00', '10:00:00', '2024-12-02', TRUE, 'NU00001', 'R001'"
-- );

-- CALL insert_into_table(
--     'room_user',
--     'start_time, end_time, reservation_date, reservation_status, user_id, room_id',
--     "'10:00:00', '11:00:00', '2024-12-02', TRUE, 'NU00002', 'R003'"
-- );

-- CALL insert_into_table(
--     'room_user',
--     'start_time, end_time, reservation_date, reservation_status, user_id, room_id',
--     "'11:00:00', '12:00:00', '2024-12-02', TRUE, 'NU00001', 'R005'"
-- );

-- CALL insert_into_table(
--     'room_user',
--     'start_time, end_time, reservation_date, reservation_status, user_id, room_id',
--     "'12:00:00', '13:00:00', '2024-12-02', TRUE, 'NU00003', 'R007'"
-- );

-- CALL insert_into_table(
--     'room_user',
--     'start_time, end_time, reservation_date, reservation_status, user_id, room_id',
--     "'14:00:00', '15:00:00', '2024-12-02', TRUE, 'NU00002', 'R002'"
-- );

-- CALL insert_into_table(
--     'room_user',
--     'start_time, end_time, reservation_date, reservation_status, user_id, room_id',
--     "'09:00:00', '10:00:00', '2024-12-03', TRUE, 'NU00001', 'R001'"
-- );

-- CALL insert_into_table(
--     'room_user',
--     'start_time, end_time, reservation_date, reservation_status, user_id, room_id',
--     "'10:00:00', '11:00:00', '2024-12-03', TRUE, 'NU00002', 'R002'"
-- );

-- CALL insert_into_table(
--     'room_user',
--     'start_time, end_time, reservation_date, reservation_status, user_id, room_id',
--     "'14:00:00', '15:00:00', '2024-12-02', TRUE, 'NU00003', 'R003'"
-- );

-- CALL insert_into_table(
--     'room_user',
--     'start_time, end_time, reservation_date, reservation_status, user_id, room_id',
--     "'20:30:00', '21:30:00', '2024-12-03', TRUE, 'NU00001', 'R004'"
-- );

-- CALL insert_into_table(
--     'room_user',
--     'start_time, end_time, reservation_date, reservation_status, user_id, room_id',
--     "'20:00:00', '21:00:00', '2024-12-03', TRUE, 'NU00002', 'R005'"
-- );


CALL insert_into_table(
    'room_user',
    'start_time, end_time, reservation_date, reservation_status, user_id, room_id',
    "'09:00:00', '10:00:00', '2024-12-05', TRUE, 'NU00001', 'R001'"
);

CALL insert_into_table(
    'room_user',
    'start_time, end_time, reservation_date, reservation_status, user_id, room_id',
    "'11:00:00', '12:30:00', '2024-12-06', TRUE, 'NU00002', 'R033'"
);

CALL insert_into_table(
    'room_user',
    'start_time, end_time, reservation_date, reservation_status, user_id, room_id',
    "'14:00:00', '15:00:00', '2024-12-07', TRUE, 'NU00003', 'R061'"
);

CALL insert_into_table(
    'room_user',
    'start_time, end_time, reservation_date, reservation_status, user_id, room_id',
    "'16:30:00', '17:30:00', '2024-12-08', TRUE, 'NU00004', 'R076'"
);

CALL insert_into_table(
    'room_user',
    'start_time, end_time, reservation_date, reservation_status, user_id, room_id',
    "'18:00:00', '19:00:00', '2024-12-09', TRUE, 'NU00005', 'R001'"
);

CALL insert_into_table(
    'room_user',
    'start_time, end_time, reservation_date, reservation_status, user_id, room_id',
    "'10:00:00', '11:00:00', '2024-12-10', TRUE, 'NU00006', 'R033'"
);

CALL insert_into_table(
    'room_user',
    'start_time, end_time, reservation_date, reservation_status, user_id, room_id',
    "'13:00:00', '14:30:00', '2024-12-11', TRUE, 'NU00007', 'R061'"
);

CALL insert_into_table(
    'room_user',
    'start_time, end_time, reservation_date, reservation_status, user_id, room_id',
    "'15:30:00', '16:30:00', '2024-12-12', TRUE, 'NU00008', 'R076'"
);

CALL insert_into_table(
    'room_user',
    'start_time, end_time, reservation_date, reservation_status, user_id, room_id',
    "'17:00:00', '18:00:00', '2024-12-13', TRUE, 'NU00001', 'R001'"
);

CALL insert_into_table(
    'room_user',
    'start_time, end_time, reservation_date, reservation_status, user_id, room_id',
    "'19:30:00', '20:30:00', '2024-12-14', TRUE, 'NU00002', 'R033'"
);




