drop database IF EXISTS climate;
create DATABASE climate;
USE climate;
create TABLE location
(
    id        INT PRIMARY KEY AUTO_INCREMENT,
    longitude INT NOT NULL,
    latitude  INT NOT NULL,
    elevation INT NOT NULL
);

create TABLE station
(
    id          INT PRIMARY KEY AUTO_INCREMENT,
    stationName VARCHAR(50) NOT NULL,
    location    INT         NOT NULL,
    CONSTRAINT FOREIGN KEY (location)
        REFERENCES location (id)
        ON update RESTRICT
        ON delete RESTRICT
);

create TABLE timeType
(
    type VARCHAR(10) PRIMARY KEY
);
-- hardcoding types of read time-frames available
insert into timeType
values ('annual');
insert into timeType
values ('daily');
insert into timeType
values ('monthly');

create TABLE time
(
    timeID    INT PRIMARY KEY AUTO_INCREMENT,
    timeType  VARCHAR(10) NOT NULL,
    timeValue DATE        NOT NULL,
    CONSTRAINT FOREIGN KEY (timeType)
        REFERENCES timeType (type)
		ON update RESTRICT
        ON delete RESTRICT
);

create TABLE readType
(
    type VARCHAR(20) PRIMARY KEY
);
-- hardcoding types of read types available
insert into readType
values ('precipitation');
insert into readType
values ('wind');
insert into readType
values ('temperature');

create TABLE reading
(
    readID     INT PRIMARY KEY AUTO_INCREMENT,
    time       INT         NOT NULL,
    station    INT         NOT NULL,
    typeOfRead VARCHAR(20) NOT NULL,
    CONSTRAINT FOREIGN KEY (time)
        REFERENCES time (timeID)
		ON update RESTRICT
        ON delete RESTRICT,
    CONSTRAINT FOREIGN KEY (station)
        REFERENCES station (id)
		ON update RESTRICT
        ON delete RESTRICT,
    CONSTRAINT FOREIGN KEY (typeOfRead)
        REFERENCES readType (type)
		ON update RESTRICT
        ON delete RESTRICT
);

create TABLE wind
(
    id        INT PRIMARY KEY,
    peakSpeed INT NOT NULL,
    peakDir   INT NOT NULL,
    sustSpeed INT NOT NULL,
    sustDir   INT NOT NULL,
    avgSpeed  INT NOT NULL,
    CONSTRAINT FOREIGN KEY (id)
        REFERENCES reading (readID)
        ON update CASCADE
        ON delete CASCADE
);

create TABLE temperature
(
    id  INT PRIMARY KEY,
    max INT NOT NULL,
    min INT NOT NULL,
    avg INT NOT NULL,
    CONSTRAINT FOREIGN KEY (id)
        REFERENCES reading (readID)
        ON update CASCADE
        ON delete CASCADE
);

create TABLE precipitation
(
    id    INT PRIMARY KEY,
    level INT NOT NULL,
    CONSTRAINT FOREIGN KEY (id)
        REFERENCES reading (readID)
        ON update CASCADE
        ON delete CASCADE
);

-- hard coding values into location and station to test procedure for now
insert into location
values (1, 1, 1, 1);
insert into station
values (1, 'one', 1);