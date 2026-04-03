CREATE TABLE restaurants_float (
    id      INT AUTO_INCREMENT,
    name    VARCHAR(100),
    lat     DECIMAL(10, 8),
    lng     DECIMAL(11, 8),
    cuisine VARCHAR(50),

    PRIMARY KEY (id)
);

CREATE TABLE restaurants_spatial (
    id          INT AUTO_INCREMENT,
    name        VARCHAR(100),
    location    POINT NOT NULL,
    cuisine     VARCHAR(50),

    PRIMARY KEY (id),
    SPATIAL INDEX(location)
);
