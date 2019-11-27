USE climate;

-- procedure print_all_info
DROP PROCEDURE IF EXISTS print_all_info;
DELIMITER //
USE climate //
CREATE PROCEDURE print_all_info(
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
DROP PROCEDURE IF EXISTS weather_data_within_date;
DELIMITER //
USE climate //
CREATE PROCEDURE weather_data_within_date(IN weather_type VARCHAR(255),
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
DROP FUNCTION IF EXISTS getLocationID;
CREATE FUNCTION getLocationID(inlongitude INT, inlatitude INT, inelevation INT)
    RETURNS INT
    DETERMINISTIC
    READS SQL DATA
BEGIN
    DECLARE locID INT;
    SELECT id
    INTO locID
    FROM location
    WHERE inlongitude = longitude & inlatitude = latitude & inelevation = elevation;
    RETURN locID;
END;

-- adds a location
DROP PROCEDURE IF EXISTS add_location;
DELIMITER //
USE climate //
CREATE PROCEDURE add_location(IN inlongitude INT, IN inlatitude INT, IN inelevation INT)
BEGIN
    DECLARE locID INT;
    SELECT getLocationID(inlongitude, inlatitude, inelevation) INTO locID;
    IF (locID IS NULL) THEN
        INSERT INTO location(longitude, latitude, elevation)
        VALUES (inlongitude, inlatitude, inelevation);
    END IF;
END //

-- adds a station using location id
DROP PROCEDURE IF EXISTS add_station_wLocID;
DELIMITER //
USE climate //
CREATE PROCEDURE add_station_wLocID(IN name VARCHAR(50), IN locationID INT)
BEGIN
    DECLARE exist INT;
    SELECT count(1)
    INTO exist
    FROM station
    WHERE name = stationName & location = locationID;
    IF (exist = 0) THEN
        INSERT INTO station(stationname, location)
        VALUES (name, locationID);
    END IF;
END //

-- adds a station using location values
DROP PROCEDURE IF EXISTS add_station;
DELIMITER //
USE climate //
CREATE PROCEDURE add_station(IN name VARCHAR(50), IN inlongitude INT, IN inlatitude INT, IN inelevation INT)
BEGIN
    DECLARE exist INT;
    DECLARE locID INT;
    SELECT COUNT(1)
    INTO exist
    FROM station s
             JOIN location l ON s.location = l.id
    WHERE name = stationName & inlongitude = longitude & inlatitude = latitude & inelevation = elevation;
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

-- gets ID of time of given type and value, or null if it isn't currently stored in database
DROP FUNCTION IF EXISTS getTimeID;
CREATE FUNCTION getTimeID(tType VARCHAR(10), tVal INT)
    RETURNS INT
    DETERMINISTIC
    READS SQL DATA
BEGIN
    DECLARE tID INT;
    SELECT timeID
    INTO tID
    FROM time
    WHERE timeType = tType & timeValue = tVal;
    RETURN tID;
END;

-- adds a time
DROP PROCEDURE IF EXISTS add_time;
DELIMITER //
USE climate //
CREATE PROCEDURE add_time(IN tType VARCHAR(10), IN tVal DATE)
BEGIN
    DECLARE exist INT;
    SELECT getTimeID(tType, tVal) INTO exist;
    IF (exist IS NULL) THEN
        INSERT INTO time(timeType, timeValue)
        VALUES (tType, timeValue);
    END IF;
END //

-- gets ID of Reading of given type, time and station, or null if it isn't currently stored in database
DROP FUNCTION IF EXISTS getReadID;
CREATE FUNCTION getReadID(readtype VARCHAR(20), timeID INT, stationID INT)
    RETURNS INT
    DETERMINISTIC
    READS SQL DATA
BEGIN
    DECLARE rID INT;
    SELECT readID
    INTO rID
    FROM reading
    WHERE readtype = typeOfRead & time = timeID & station = stationID;
    RETURN rID;
END;

-- adds a Read pointer that specifies a reading of type, station, and time but not the values of the read.
-- For internal calls, not visible to front-end
DROP PROCEDURE IF EXISTS add_ReadPointer;
DELIMITER //
USE climate //
CREATE PROCEDURE add_ReadPointer(IN readtype VARCHAR(20), IN timeID INT, IN stationID INT)
BEGIN
    DECLARE exist INT;
    SELECT getReadID(readtype, timeID, stationID) INTO exist;
    IF (exist IS NULL) THEN
        INSERT INTO reading(typeOfRead, time, station)
        VALUES (readType, timeID, stationID);
    END IF;
END //


-- adds a precipitation read
DROP PROCEDURE IF EXISTS add_precipitation_read;
DELIMITER //
USE climate //
CREATE PROCEDURE add_precipitation_read(IN fullDate DATE, IN readTimeType VARCHAR(10), IN stationID INT,
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

-- adds a wind read
DROP PROCEDURE IF EXISTS add_wind_read;
DELIMITER //
USE climate //
CREATE PROCEDURE add_wind_read(IN fullDate DATE, IN readTimeType VARCHAR(10), IN stationID INT,
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

-- adds a temperature read
DROP PROCEDURE IF EXISTS add_temperature_read;
DELIMITER //
USE climate //
CREATE PROCEDURE add_temperature_read(IN fullDate DATE, IN readTimeType VARCHAR(10), IN stationID INT,
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
