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

CREATE TABLE reading
(
    readID INT PRIMARY KEY AUTO_INCREMENT,
    type   VARCHAR(20) NOT NULL
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

CREATE TABLE time
(
    timeID   INT PRIMARY KEY,
    timeType VARCHAR(10) NOT NULL,
    value    DATE        NOT NULL
)



