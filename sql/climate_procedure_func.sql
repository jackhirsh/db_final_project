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
             time ON reading.type = time.timeID
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
             time ON reading.type = time.timeID
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
             time ON reading.type = time.timeID
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
             time ON reading.type = time.timeID
        WHERE time.timeValue >= start_date
          AND time.timeValue <= end_date;
    ELSEIF weather_type = 'temperature' THEN
        SELECT *
        FROM reading
                 JOIN
             temperature ON reading.readID = temperature.id
                 JOIN
             time ON reading.type = time.timeID
        WHERE time.timeValue >= start_date
          AND time.timeValue <= end_date;
    ELSEIF weather_type = 'wind' THEN
        SELECT *
        FROM reading
                 JOIN
             wind ON reading.readID = wind.id
                 JOIN
             time ON reading.type = time.timeID
        WHERE time.timeValue >= start_date
          AND time.timeValue <= end_date;
    END IF;
END //
DELIMITER ;

-- adds a precipitation read
DROP PROCEDURE IF EXISTS add_precipitation_read;
DELIMITER //
USE climate //
CREATE PROCEDURE add_precipitation_read(IN fullDate DATE, IN readTimeType VARCHAR(10), IN stationID INT,
                                        IN precipitationLevel INT)
BEGIN
    DECLARE readingID INT;
    DECLARE timeofID INT;
    INSERT INTO time(timeType, timeValue)
    VALUES (readTimeType, fullDate);
    SELECT max(timeID) INTO timeofID FROM time;
    INSERT INTO reading(time, station)
    VALUES (timeofID, stationID);
    SELECT max(readID) INTO readingID FROM reading;
    INSERT INTO precipitation
    VALUES (readingID, precipitationLevel);
END //
