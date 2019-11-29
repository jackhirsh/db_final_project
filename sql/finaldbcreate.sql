DROP DATABASE IF EXISTS climate;
CREATE DATABASE climate;
USE climate;
CREATE TABLE location
(
    id        INT PRIMARY KEY AUTO_INCREMENT,
    longitude INT NOT NULL,
    latitude  INT NOT NULL,
    elevation INT NOT NULL
);

CREATE TABLE station
(
    id          INT PRIMARY KEY AUTO_INCREMENT,
    stationName VARCHAR(50) NOT NULL,
    location    INT         NOT NULL,
    CONSTRAINT FOREIGN KEY (location)
        REFERENCES location (id)
);

CREATE TABLE timeType
(
    type VARCHAR(10) PRIMARY KEY
);
-- hardcoding initial types of read time-frames available
INSERT INTO timeType
VALUES ('annual');
INSERT INTO timeType
VALUES ('daily');
INSERT INTO timeType
VALUES ('monthly');

CREATE TABLE time
(
    timeID    INT PRIMARY KEY AUTO_INCREMENT,
    timeType  VARCHAR(10) NOT NULL,
    timeValue DATE        NOT NULL,
    CONSTRAINT FOREIGN KEY (timeType)
        REFERENCES timeType (type)
);

CREATE TABLE readType
(
    type VARCHAR(20) PRIMARY KEY
);
-- hardcoding initial types of read types available
INSERT INTO readType
VALUES ('precipitation');
INSERT INTO readType
VALUES ('wind');
INSERT INTO readType
VALUES ('temperature');

CREATE TABLE reading
(
    readID     INT PRIMARY KEY AUTO_INCREMENT,
    time       INT         NOT NULL,
    station    INT         NOT NULL,
    typeOfRead VARCHAR(20) NOT NULL,
    CONSTRAINT FOREIGN KEY (time)
        REFERENCES time (timeID),
    CONSTRAINT FOREIGN KEY (station)
        REFERENCES station (id),
    CONSTRAINT FOREIGN KEY (typeOfRead)
        REFERENCES readType (type)
);

CREATE TABLE wind
(
    id        INT PRIMARY KEY,
    peakSpeed INT NOT NULL,
    peakDir   INT NOT NULL,
    sustSpeed INT NOT NULL,
    sustDir   INT NOT NULL,
    avgSpeed  INT NOT NULL,
    CONSTRAINT FOREIGN KEY (id)
        REFERENCES reading (readID)
);

CREATE TABLE temperature
(
    id  INT PRIMARY KEY,
    max INT NOT NULL,
    min INT NOT NULL,
    avg INT NOT NULL,
    CONSTRAINT FOREIGN KEY (id)
        REFERENCES reading (readID)
);

CREATE TABLE precipitation
(
    id    INT PRIMARY KEY,
    level INT NOT NULL,
    CONSTRAINT FOREIGN KEY (id)
        REFERENCES reading (readID)
);

-- hard coding values into location and station to test procedure for now
INSERT INTO location
VALUES (1, 1, 1, 1);
INSERT INTO station
VALUES (1, 'one', 1);