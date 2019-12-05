USE climate;

-- procedure print_all_info
drop procedure IF EXISTS print_all_info;
DELIMITER //
USE climate //
create procedure print_all_info(
    IN weather_info_type VARCHAR(255)
)
BEGIN
    IF weather_info_type = 'precipitation' THEN
        SELECT *
        FROM reading
                 JOIN
             precipitation ON reading.readID = precipitation.id
                 JOIN
             time ON reading.time = time.timeID
                 JOIN
             station ON reading.station = station.id
                 JOIN
             location ON station.location = location.id;
    ELSEIF weather_info_type = 'temperature' THEN
        SELECT *
        FROM reading
                 JOIN
             temperature ON reading.readID = temperature.id
                 JOIN
             time ON reading.time = time.timeID
                 JOIN
             station ON reading.station = station.id
                 JOIN
             location ON station.location = location.id;
    ELSEIF weather_info_type = 'wind' THEN
        SELECT *
        FROM reading
                 JOIN
             wind ON reading.readID = wind.id
                 JOIN
             time ON reading.time = time.timeID
                 JOIN
             station ON reading.station = station.id
                 JOIN
             location ON station.location = location.id;
    END IF;
END //
DELIMITER ;

-- procedure weather_data_within_date
drop procedure IF EXISTS weather_data_within_date;
DELIMITER //
USE climate //
create procedure weather_data_within_date(IN weather_type VARCHAR(255),
                                          IN start_date DATE,
                                          IN end_date DATE)
BEGIN
    IF weather_type = 'precipitation' THEN
        SELECT *
        FROM reading
                 JOIN
             precipitation ON reading.readID = precipitation.id
                 JOIN
             time ON reading.time = time.timeID
        WHERE time.timeValue >= start_date
          AND time.timeValue <= end_date;
    ELSEIF weather_type = 'temperature' THEN
        SELECT *
        FROM reading
                 JOIN
             temperature ON reading.readID = temperature.id
                 JOIN
             time ON reading.time = time.timeID
        WHERE time.timeValue >= start_date
          AND time.timeValue <= end_date;
    ELSEIF weather_type = 'wind' THEN
        SELECT *
        FROM reading
                 JOIN
             wind ON reading.readID = wind.id
                 JOIN
             time ON reading.time = time.timeID
        WHERE time.timeValue >= start_date
          AND time.timeValue <= end_date;
    END IF;
END //
DELIMITER ;

-- gets id of location with given values or null if such location not currently in database
drop function IF EXISTS getLocationID;
DELIMITER //
USE climate //
create function getLocationID(inlongitude int, inlatitude int, inelevation int)
    RETURNS INT
    deterministic
    READS SQL DATA
begin
    declare locID int;
    select id
    into locID
    from location
    where (inlongitude = longitude) & (inlatitude = latitude) & (inelevation = elevation);
    RETURN locID;
END //
DELIMITER ;

-- adds a location
drop procedure IF EXISTS add_location;
DELIMITER //
USE climate //
create procedure add_location(IN inlongitude INT, IN inlatitude INT, IN inelevation INT)
BEGIN
    DECLARE locID INT;
    SELECT getLocationID(inlongitude, inlatitude, inelevation) INTO locID;
    IF (locID IS NULL) THEN
        INSERT INTO location(longitude, latitude, elevation)
        VALUES (inlongitude, inlatitude, inelevation);
    END IF;
END //
DELIMITER ;

-- adds a station using location id
drop procedure IF EXISTS add_station_wLocID;
DELIMITER //
USE climate //
create procedure add_station_wLocID(IN name VARCHAR(50), IN locationID INT)
BEGIN
    DECLARE exist INT;
    SELECT count(1)
    INTO exist
    FROM station
    WHERE (name = stationName) & (location = locationID);
    IF (exist = 0) THEN
        INSERT INTO station(stationname, location)
        VALUES (name, locationID);
    END IF;
END //
DELIMITER ;

-- adds a station using location values
drop procedure IF EXISTS add_station;
DELIMITER //
USE climate //
create procedure add_station(IN name VARCHAR(50), IN inlongitude INT, IN inlatitude INT, IN inelevation INT)
BEGIN
    DECLARE exist INT;
    DECLARE locID INT;
    SELECT COUNT(1)
    INTO exist
    FROM station s
             JOIN location l ON s.location = l.id
    WHERE (name = stationName) & (inlongitude = longitude) & (inlatitude = latitude) & (inelevation = elevation);
    IF (exist = 0) THEN
        SELECT getLocationID(inlongitude, inlatitude, inelevation) INTO locID;
        IF (locID IS NULL) THEN
            CALL add_location(inlongitude, inlatitude, inelevation);
            SELECT max(id) INTO locID FROM location;
            INSERT INTO station(stationname, location)
            VALUES (name, locID);
        ELSE
            INSERT INTO station(stationname, location)
            VALUES (name, locID);
        END IF;
    END IF;
END //
DELIMITER ;

-- gets ID of time of given type and value, or null if it isn't currently stored in database
drop function IF EXISTS getTimeID;
DELIMITER //
USE climate //
create function getTimeID(tType varchar(10), tVal date)
    RETURNS INT
    deterministic
    READS SQL DATA
begin
    declare tID int;
    select timeID
    into tID
    from time
    where (timeType = tType) & (timeValue = tVal);
    RETURN tID;
END //
DELIMITER ;

-- adds a time
drop procedure IF EXISTS add_time;
DELIMITER //
USE climate //
create procedure add_time(IN tType VARCHAR(10), IN tVal DATE)
BEGIN
    DECLARE exist INT;
    SELECT getTimeID(tType, tVal) INTO exist;
    IF (exist IS NULL) THEN
        INSERT INTO time(timeType, timeValue)
        VALUES (tType, tVal);
    END IF;
END //
DELIMITER ;

-- gets ID of Reading of given type, time and station, or null if it isn't currently stored in database
drop function IF EXISTS getReadID;
DELIMITER //
USE climate //
create function getReadID(readtype varchar(20), timeID int, stationID int)
    RETURNS INT
    deterministic
    READS SQL DATA
begin
    declare rID int;
    select readID
    into rID
    from reading
    where (readtype = typeOfRead) & (time = timeID) & (station = stationID);
    RETURN rID;
END //
DELIMITER ;

-- gets the all the existing station_id from the database
drop procedure IF EXISTS get_stationIDs;
DELIMITER //
USE climate //
create procedure get_stationIDs()
BEGIN
    SELECT id from station;
END //
DELIMITER ;

-- adds a Read pointer that specifies a reading of type, station, and time but not the values of the read.
-- For internal calls, not visible to front-end
drop procedure IF EXISTS add_ReadPointer;
DELIMITER //
USE climate //
create procedure add_ReadPointer(IN readtype VARCHAR(20), IN timeID INT, IN stationID INT)
BEGIN
    DECLARE exist INT;
    SELECT getReadID(readtype, timeID, stationID) INTO exist;
    IF (exist IS NULL) THEN
        INSERT INTO reading(typeOfRead, time, station)
        VALUES (readType, timeID, stationID);
    END IF;
END //
DELIMITER ;

-- adds a precipitation read
drop procedure IF EXISTS add_precipitation_read;
DELIMITER //
USE climate //
create procedure add_precipitation_read(IN fullDate DATE, IN readTimeType VARCHAR(10), IN stationID INT,
                                        IN precipitationLevel INT)
BEGIN
    DECLARE readingID INT;
    DECLARE timeofID INT;
    CALL add_time(readTimeType, fullDate);
    SELECT getTimeID(readTimeType, fullDate) INTO timeofID;
    CALL add_ReadPointer('precipitation', timeofID, stationID);
    SELECT getReadID('precipitation', timeofID, stationID) INTO readingID;
    INSERT INTO precipitation
    VALUES (readingID, precipitationLevel);
END //
DELIMITER ;

-- adds a wind read
drop procedure IF EXISTS add_wind_read;
DELIMITER //
USE climate //
create procedure add_wind_read(IN fullDate DATE, IN readTimeType VARCHAR(10), IN stationID INT,
                               IN inpeakSpeed INT, IN inpeakDir INT, IN insustSpeed INT,
                               IN insustDir INT, IN inavgSpeed INT)
BEGIN
    DECLARE readingID INT;
    DECLARE timeofID INT;
    CALL add_time(readTimeType, fullDate);
    SELECT getTimeID(readTimeType, fullDate) INTO timeofID;
    CALL add_ReadPointer('wind', timeofID, stationID);
    SELECT getReadID('wind', timeofID, stationID) INTO readingID;
    INSERT INTO wind
    VALUES (readingID, inpeakSpeed, inpeakDir, insustSpeed, insustDir, inavgSpeed);
END //
DELIMITER ;

-- adds a temperature read
drop procedure IF EXISTS add_temperature_read;
DELIMITER //
USE climate //
create procedure add_temperature_read(IN fullDate DATE, IN readTimeType VARCHAR(10), IN stationID INT,
                                      IN inmax INT, IN inmin INT, IN inavg INT)
BEGIN
    DECLARE readingID INT;
    DECLARE timeofID INT;
    CALL add_time(readTimeType, fullDate);
    SELECT getTimeID(readTimeType, fullDate) INTO timeofID;
    CALL add_ReadPointer('temperature', timeofID, stationID);
    SELECT getReadID('temperature', timeofID, stationID) INTO readingID;
    INSERT INTO temperature
    VALUES (readingID, inmax, inmin, inavg);
END //
DELIMITER ;

-- since the edit function hardcodes the types of read it can edit, maybe we shouldn't allow other types to be added
/*
 -- adds a read type
DROP PROCEDURE IF EXISTS add_readType;
CREATE PROCEDURE add_readType(IN rtype VARCHAR(20))
BEGIN
    DECLARE exist INT;
    SELECT count(1) INTO exist FROM readtype WHERE type = rtype;
    IF exist = 0 THEN
        INSERT INTO readType
        VALUES (rtype);
    END IF;
END;

-- adds a time-frame type
DROP PROCEDURE IF EXISTS add_timeType;
CREATE PROCEDURE add_timeType(IN ttype VARCHAR(20))
BEGIN
    DECLARE exist INT;
    SELECT count(1) INTO exist FROM timetype WHERE type = ttype;
    IF exist = 0 THEN
        INSERT INTO timeType
        VALUES (ttype);
    END IF;
END //
*/

-- edits the field based on fieldNo (from left to right in columns not including ID and starting at 1)
-- in a reading of given type
drop procedure IF EXISTS edit_read_field;
DELIMITER //
USE climate //
create procedure edit_read_field(IN idOfRead INT, IN fieldNo INT, IN newValue INT)
BEGIN
    DECLARE rtype VARCHAR(20);
    SELECT typeOfRead INTO rtype FROM reading WHERE readID = idOfRead;
    IF rtype = 'precipitation' THEN
        UPDATE precipitation
        SET level = newValue
        WHERE id = idOfRead;
    ELSEIF rtype = 'temperature' THEN
        IF fieldNo = 1 THEN
            UPDATE temperature
            SET max = newValue
            WHERE id = idOfRead;
        ELSEIF fieldNo = 2 THEN
            UPDATE temperature
            SET min = newValue
            WHERE id = idOfRead;
        ELSEIF fieldNo = 3 THEN
            UPDATE temperature
            SET avg = newValue
            WHERE id = idOfRead;
        END IF;
    ELSEIF rtype = 'wind' THEN
        IF fieldNo = 1 THEN
            UPDATE wind
            SET peakSpeed = newValue
            WHERE id = idOfRead;
        ELSEIF fieldNo = 2 THEN
            UPDATE wind
            SET peakDir = newValue
            WHERE id = idOfRead;
        ELSEIF fieldNo = 3 THEN
            UPDATE wind
            SET sustSpeed = newValue
            WHERE id = idOfRead;
        ELSEIF fieldNo = 4 THEN
            UPDATE wind
            SET sustDir = newValue
            WHERE id = idOfRead;
        ELSEIF fieldNo = 5 THEN
            UPDATE wind
            SET avgSpeed = newValue
            WHERE id = idOfRead;
        END IF;
    END IF;
END //
DELIMITER ;

-- select the smallest reading id of the given date
drop function IF EXISTS get_end_date_reading_id;
delimiter //
USE climate //
create function get_end_date_reading_id(
	end_date date
)
RETURNS INT
deterministic
begin
declare end_date_reading_id int;
select
	max(reading.readID)
into end_date_reading_id
from
	reading
		join
	time on reading.time = time.timeID
where
	time.timeValue >= end_date;
return (end_date_reading_id);
end //
delimiter ;

-- select the greatest reading id of the given date
drop function IF EXISTS get_start_date_reading_id;
delimiter //
USE climate //
create function get_start_date_reading_id(
	start_date date
)
RETURNS INT
deterministic
begin
declare start_date_reading_id int;
select
	min(reading.readID)
into start_date_reading_id
from
	reading
		join
	time on reading.time = time.timeID
where
	time.timeValue <= start_date;
return (start_date_reading_id);
end //
delimiter ;

-- delete all the reading records that are read before or at the given date, regardless of
-- the read type and time type
drop procedure IF EXISTS delete_reading_before_date;
DELIMITER //
USE climate //
create procedure delete_reading_before_date(IN end_date DATE)
BEGIN
DECLARE last_date_reading_id INT;
SELECT get_end_date_reading_id(end_date) INTO last_date_reading_id;
DELETE
	FROM
		reading
	WHERE
		reading.readID <= last_date_reading_id;
END //
DELIMITER ;

-- delete all the reading records that are read after or at the given date, regardless
-- of the read type and time type
drop procedure IF EXISTS delete_reading_after_date;
DELIMITER //
USE climate //
create procedure delete_reading_after_date(IN start_date DATE)
BEGIN
DECLARE first_date_reading_id INT;
SELECT get_start_date_reading_id(start_date) INTO first_date_reading_id;
DELETE
	FROM
		reading
	WHERE
		reading.readID >= first_date_reading_id;
END //
DELIMITER ;

-- delete all the reading records that are read within a time range, regardless of the
-- read type and time type
drop procedure IF EXISTS delete_reading_between_date;
DELIMITER //
USE climate //
create procedure delete_reading_between_date(IN start_date DATE, IN end_date DATE)
BEGIN
DECLARE start_id INT;
DECLARE end_id INT;
SELECT get_start_date_reading_id(start_date) INTO start_id;
SELECT get_end_date_reading_id(end_date) INTO end_id;
DELETE
	FROM
		reading
	WHERE
		reading.readID >= start_id AND reading.readID <= end_id;
END //
DELIMITER ;

-- delete a station and all its related readings
drop procedure IF EXISTS delete_station;
DELIMITER //
USE climate //
create procedure delete_station(IN station_name VARCHAR(50))
BEGIN
DECLARE station_to_delete_id INT;
SELECT station.id
	INTO station_to_delete_id
    FROM station
    WHERE station.stationName = station_name;
DELETE reading, station
FROM reading
	INNER JOIN
station ON reading.station = station.id
WHERE station.id = station_to_delete_id;
END //
DELIMITER ;

-- delete a location and all its related readings
drop procedure IF EXISTS delete_location;
DELIMITER //
USE climate //
create procedure delete_location(IN longitude INT, IN latitude INT, IN elevation INT)
BEGIN
DECLARE location_to_delete_id INT;
SELECT location.id
	INTO location_to_delete_id
    FROM location
    WHERE location.longitude = longitude
		AND location.latitude = latitude
        AND location.elevation = elevation;
DELETE reading, station, location
FROM reading
	INNER JOIN
station ON reading.station = station.id
	INNER JOIN
location ON station.location = location.id
WHERE location.id = location_to_delete_id;
END //
DELIMITER ;

-- delete reading based on a given reading id
drop procedure IF EXISTS delete_reading;
DELIMITER //
USE climate //
create procedure delete_reading(IN id INT)
BEGIN
DELETE
	FROM
		reading
	WHERE
		reading.readID = id;
END //
DELIMITER ;
