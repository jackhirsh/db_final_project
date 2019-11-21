drop database if exists climate;
create database climate;
create database climate;
use climate;
CREATE TABLE location (
    id INT PRIMARY KEY AUTO_INCREMENT,
    longitude INT NOT NULL,
    latitude INT NOT NULL,
    elevation INT NOT NULL
);

CREATE TABLE station (
    id INT PRIMARY KEY,
    stationName VARCHAR(50) NOT NULL,
    location INT NOT NULL,
    CONSTRAINT fk FOREIGN KEY (location)
        REFERENCES location (id)
);



